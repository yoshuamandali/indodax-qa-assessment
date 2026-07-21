"""Flask UI: pick locust script + RPS, run, view live status."""

import os
import re
import subprocess
import sys
import threading
import time
from datetime import datetime
from glob import glob

from flask import Flask, jsonify, render_template, request

# Make `load` package importable when run as `python -m load.runner.app`
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from load.config.thresholds import TARGET_RPS, TEST_DURATION_SECONDS

LOAD_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPORTS_DIR = os.path.join(LOAD_DIR, "reports")
HOST = "127.0.0.1"
PORT = 5001

app = Flask(__name__, template_folder=os.path.join(os.path.dirname(__file__), "templates"))

# Single-slot run registry — only one locust run at a time
_current_run = {
    "run_id": None,
    "pid": None,
    "proc": None,
    "script": None,
    "rps": None,
    "start_time": None,
    "state": "idle",  # idle | running | passed | failed | stopped
    "exit_code": None,
    "stdout_buf": [],
    "stderr_buf": [],
}
_lock = threading.Lock()


def _list_scripts():
    """List .py files directly under load/, excluding __init__.py and runner/ subdir."""
    files = []
    for path in sorted(glob(os.path.join(LOAD_DIR, "*.py"))):
        name = os.path.basename(path)
        if name == "__init__.py":
            continue
        files.append(name)
    return files


def _read_stream(stream, buf):
    """Read stream lines into buf until EOF."""
    while True:
        line = stream.readline()
        if not line:
            break
        buf.append(line.decode("utf-8", errors="replace"))
    stream.close()


def _spawn_locust(script, rps, users):
    """Start locust subprocess. Caller holds _lock."""
    run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    script_path = os.path.join(LOAD_DIR, os.path.basename(script))
    if not os.path.isfile(script_path):
        raise FileNotFoundError(f"Script not found: {script_path}")
    csv_prefix = os.path.join(REPORTS_DIR, f"load_{run_id}")
    os.makedirs(REPORTS_DIR, exist_ok=True)

    cmd = [
        sys.executable, "-u", "-m", "locust",
        "-f", script_path,
        "--headless",
        "-u", str(users),
        "-r", str(max(1, users // 5)),
        "--run-time", f"{TEST_DURATION_SECONDS}s",
        "--csv", csv_prefix,
        "--print-stats",
    ]
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=os.path.dirname(os.path.dirname(LOAD_DIR)),
        env={**os.environ, "PYTHONUNBUFFERED": "1"},
    )
    _current_run.update({
        "run_id": run_id,
        "pid": proc.pid,
        "proc": proc,
        "script": script,
        "rps": rps,
        "users": users,
        "start_time": time.time(),
        "state": "running",
        "exit_code": None,
        "stdout_buf": [],
        "stderr_buf": [],
    })

    # Drain stdout (stderr merged into stdout via STDOUT redirect) in background thread
    threading.Thread(target=_read_stream, args=(proc.stdout, _current_run["stdout_buf"]), daemon=True).start()

    # Watcher thread to update state on process exit
    def _watch():
        code = proc.wait()
        with _lock:
            # Only update if still our run
            if _current_run.get("run_id") == run_id:
                if _current_run["state"] == "running":
                    _current_run["state"] = "passed" if code == 0 else "failed"
                _current_run["exit_code"] = code

    threading.Thread(target=_watch, daemon=True).start()
    return run_id, proc.pid


def _parse_live_stats(stdout_tail):
    """Best-effort parse current RPS + error rate from locust's periodic stdout table."""
    current_rps = None
    current_errors = None
    # Locust prints lines like: "GET /api/v1/employees   1     0  ...  10.5   0.0%"
    # The last stats line in each refresh has aggregated columns. We look for RPS + fail%.
    for line in reversed(stdout_tail):
        line = line.strip()
        if not line or line.startswith("Type") or line.startswith("Name") or line.startswith("-"):
            continue
        # match patterns like "10.5" (RPS) and "0.2%" (error rate)
        pct_match = re.search(r"(\d+(?:\.\d+)?)\s*%", line)
        rps_match = re.search(r"\s(\d+(?:\.\d+)?)\s*$", line)
        if rps_match:
            try:
                current_rps = float(rps_match.group(1))
            except ValueError:
                pass
        if pct_match:
            try:
                current_errors = float(pct_match.group(1))
            except ValueError:
                pass
        if current_rps is not None and current_errors is not None:
            break
    return current_rps, current_errors


def _parse_endpoint_counts(stdout_tail):
    """Parse per-endpoint request counts from latest Locust stats table.

    Locust prints a stats table every ~3s. Each data row looks like:
      GET /api/v1/employees    540   0   0.00   180  250  320  9.5  0.0%
      GET /api/v1/employee/{id} 612  2   0.33   210  400  480  10.2 0.3%

    Returns list of {method, name, count, fail_count, fail_pct} dicts.
    Only parses rows from the most recent stats table (last block ending before
    a fresh Aggregated or separator line).
    """
    endpoints = []
    # Walk reversed, collect data rows until we hit header/separator
    seen_header = False
    for line in reversed(stdout_tail):
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("Type") or stripped.startswith("Name"):
            seen_header = True
            break
        if stripped.startswith("---") or stripped.startswith("Aggregated"):
            continue
        # Locust stats row format:
        #   GET      GET /api/v1/employee/{id}    46  46(100.00%) |    659 ... |    3.40  3.40
        # Columns: Type | Name | #reqs | #fails(count)(pct%) | avg... | req/s failures/s
        # Name column itself starts with the method, so match method + name + counts.
        m = re.match(
            r"^(GET|POST|PUT|DELETE|PATCH|HEAD)\s+(.+?)\s+(\d+)\s+(\d+)\(([\d.]+)%\)\s*\|",
            stripped,
        )
        if m:
            endpoints.append({
                "method": m.group(1),
                "name": m.group(2).strip(),
                "count": int(m.group(3)),
                "fail_count": int(m.group(4)),
                "fail_pct": float(m.group(5)),
            })
    if not seen_header:
        return []
    return endpoints


@app.route("/")
def index():
    return render_template("runner.html")


@app.route("/api/scripts")
def api_scripts():
    return jsonify({"scripts": _list_scripts()})


@app.route("/api/run", methods=["POST"])
def api_run():
    data = request.get_json(force=True)
    script = data.get("script")
    rps = data.get("rps", TARGET_RPS)
    users = data.get("users", 10)
    if not script:
        return jsonify({"error": "script required"}), 400
    try:
        rps = int(rps)
    except (TypeError, ValueError):
        return jsonify({"error": "rps must be integer"}), 400
    if rps < 1 or rps > 100:
        return jsonify({"error": "rps must be 1-100"}), 400
    try:
        users = int(users)
    except (TypeError, ValueError):
        return jsonify({"error": "users must be integer"}), 400
    if users < 1 or users > 500:
        return jsonify({"error": "users must be 1-500"}), 400

    with _lock:
        if _current_run["state"] == "running":
            return jsonify({"error": "a run is already active"}), 409
        try:
            run_id, pid = _spawn_locust(script, rps, users)
        except FileNotFoundError as e:
            return jsonify({"error": str(e)}), 404
    return jsonify({"run_id": run_id, "pid": pid})


@app.route("/api/status/<run_id>")
def api_status(run_id):
    with _lock:
        if _current_run.get("run_id") != run_id:
            return jsonify({"error": "unknown run_id"}), 404
        duration_s = 0
        if _current_run["start_time"]:
            duration_s = int(time.time() - _current_run["start_time"])
        stdout_tail = "".join(_current_run["stdout_buf"][-200:])
        current_rps, current_errors = _parse_live_stats(_current_run["stdout_buf"][-50:])
        endpoints = _parse_endpoint_counts(_current_run["stdout_buf"][-200:])
        return jsonify({
            "run_id": run_id,
            "state": _current_run["state"],
            "pid": _current_run["pid"],
            "script": _current_run["script"],
            "rps": _current_run["rps"],
            "users": _current_run.get("users"),
            "endpoints": endpoints,
            "duration_s": duration_s,
            "duration_target_s": TEST_DURATION_SECONDS,
            "current_rps": current_rps,
            "current_errors_pct": current_errors,
            "exit_code": _current_run["exit_code"],
            "stdout_tail": stdout_tail,
        })


@app.route("/api/stop/<run_id>", methods=["POST"])
def api_stop(run_id):
    with _lock:
        if _current_run.get("run_id") != run_id:
            return jsonify({"error": "unknown run_id"}), 404
        if _current_run["state"] != "running":
            return jsonify({"error": "run is not active"}), 409
        proc = _current_run["proc"]
        if proc is not None:
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
        _current_run["state"] = "stopped"
    return jsonify({"stopped": True, "run_id": run_id})


@app.route("/api/reports")
def api_reports():
    reports = []
    for ext in ("json", "csv", "md"):
        for path in sorted(glob(os.path.join(REPORTS_DIR, f"load_*.{ext}"))):
            reports.append({
                "file": os.path.basename(path),
                "size_bytes": os.path.getsize(path),
                "modified": datetime.fromtimestamp(os.path.getmtime(path)).isoformat(),
            })
    return jsonify({"reports": reports})


@app.route("/api/reports/<filename>")
def api_report_download(filename):
    """Return raw report file content. Markdown rendered as HTML, others as plain text."""
    safe = os.path.basename(filename)
    path = os.path.join(REPORTS_DIR, safe)
    if not os.path.isfile(path):
        return jsonify({"error": "not found"}), 404
    with open(path, "r", errors="replace") as f:
        content = f.read()
    if safe.endswith(".md"):
        # Minimal markdown -> HTML escape + basic formatting
        import html
        import re as _re
        esc = html.escape(content)
        # tables
        lines = esc.split("\n")
        out = []
        in_table = False
        for line in lines:
            if line.strip().startswith("|") and "---|" in line or "|---" in line:
                continue
            if line.strip().startswith("|"):
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if not in_table:
                    out.append("<table border='1' cellpadding='4' style='border-collapse:collapse'><tr>" +
                               "".join(f"<th>{c}</th>" for c in cells) + "</tr>")
                    in_table = True
                else:
                    out.append("<tr>" + "".join(f"<td>{c}</td>" for c in cells) + "</tr>")
            else:
                if in_table:
                    out.append("</table>")
                    in_table = False
                # headings
                if line.startswith("# "):
                    out.append(f"<h1>{line[2:]}</h1>")
                elif line.startswith("## "):
                    out.append(f"<h2>{line[3:]}</h2>")
                elif line.startswith("**") and line.endswith("**"):
                    out.append(f"<p><strong>{line[2:-2]}</strong></p>")
                elif "**" in line:
                    # inline bold segments
                    out.append("<p>" + _re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", line) + "</p>")
                elif line.startswith("- "):
                    out.append(f"<li>{line[2:]}</li>")
                elif line.strip() == "":
                    out.append("<br>")
                else:
                    out.append(f"<p>{line}</p>")
        if in_table:
            out.append("</table>")
        return "\n".join(out), 200, {"Content-Type": "text/html; charset=utf-8"}
    return content, 200, {"Content-Type": "text/plain; charset=utf-8"}


if __name__ == "__main__":
    os.makedirs(REPORTS_DIR, exist_ok=True)
    print(f"Starting Locust runner UI on http://{HOST}:{PORT}")
    app.run(host=HOST, port=PORT, debug=False)
