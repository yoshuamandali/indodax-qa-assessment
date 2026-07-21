"""Locust event listener: captures per-request samples, enforces assertions, writes reports."""

import csv
import json
import math
import os
import statistics
import sys
import time
from datetime import datetime

from load.config.thresholds import (
    TARGET_RPS,
    MAX_P95_MS,
    MAX_ERROR_RATE,
    RAMP_SECONDS,
    HOLD_SECONDS,
    TEST_DURATION_SECONDS,
)

REPORTS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "reports")

SUCCESS_STATUSES = {200, 201, 202, 204, 301, 302, 304}


def compute_stats(samples):
    """Compute summary stats from a list of sample dicts.

    Each sample: {"endpoint", "status", "response_time_ms"}.
    Returns dict with count, p50/p95/p99 ms, error_count, error_rate.
    """
    if not samples:
        return {
            "count": 0,
            "p50_ms": 0,
            "p95_ms": 0,
            "p99_ms": 0,
            "error_count": 0,
            "error_rate": 0.0,
        }

    latencies = sorted(s["response_time_ms"] for s in samples)
    n = len(latencies)

    def percentile(sorted_list, p):
        if not sorted_list:
            return 0
        # nearest-rank method — ceil(p/100 * n) per test comment
        rank = max(1, math.ceil(p / 100.0 * n))
        return sorted_list[rank - 1]

    error_count = sum(1 for s in samples if s["status"] not in SUCCESS_STATUSES)

    return {
        "count": n,
        "p50_ms": percentile(latencies, 50),
        "p95_ms": percentile(latencies, 95),
        "p99_ms": percentile(latencies, 99),
        "error_count": error_count,
        "error_rate": error_count / n,
    }


def assert_verdict(stats, overall_rps):
    """Return list of assertion row dicts comparing actuals against thresholds."""
    return [
        {
            "name": "RPS >= 90% of target",
            "target": f">= {TARGET_RPS * 0.9}",
            "actual": f"{overall_rps:.2f}",
            "passed": overall_rps >= TARGET_RPS * 0.9,
        },
        {
            "name": "p95 latency <= threshold",
            "target": f"<= {MAX_P95_MS} ms",
            "actual": f"{stats['p95_ms']} ms",
            "passed": stats["p95_ms"] <= MAX_P95_MS,
        },
        {
            "name": "Error rate <= threshold",
            "target": f"<= {MAX_ERROR_RATE * 100:.1f}%",
            "actual": f"{stats['error_rate'] * 100:.2f}%",
            "passed": stats["error_rate"] <= MAX_ERROR_RATE,
        },
    ]


def write_reports(run_id, samples, stats, verdicts):
    """Write JSON, CSV, Markdown reports under load/reports/. Return (json, csv, md) paths."""
    os.makedirs(REPORTS_DIR, exist_ok=True)
    ts = run_id

    json_path = os.path.join(REPORTS_DIR, f"load_{ts}.json")
    csv_path = os.path.join(REPORTS_DIR, f"load_{ts}.csv")
    md_path = os.path.join(REPORTS_DIR, f"load_{ts}.md")

    # JSON — samples + stats + verdicts
    with open(json_path, "w") as f:
        json.dump({
            "run_id": run_id,
            "stats": stats,
            "verdicts": verdicts,
            "samples": samples,
        }, f, indent=2)

    # CSV — one row per sample
    if samples:
        with open(csv_path, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["ts", "endpoint", "method", "status", "response_time_ms", "exception"])
            writer.writeheader()
            for s in samples:
                writer.writerow({
                    "ts": s.get("ts", ""),
                    "endpoint": s.get("endpoint", ""),
                    "method": s.get("method", ""),
                    "status": s.get("status", ""),
                    "response_time_ms": s.get("response_time_ms", ""),
                    "exception": s.get("exception", ""),
                })

    # Markdown — interpretation
    overall_pass = all(v["passed"] for v in verdicts)
    overall_rps = float(verdicts[0]["actual"]) if verdicts else 0.0
    md = ["# Load Test Report", ""]
    md.append(f"**Run ID:** {run_id}  ")
    md.append(f"**Overall verdict:** {'PASS' if overall_pass else 'FAIL'}  ")
    md.append(f"**Duration target:** {TEST_DURATION_SECONDS}s ({RAMP_SECONDS}s ramp + {HOLD_SECONDS}s hold)  ")
    md.append("")
    md.append("## Assertions")
    md.append("")
    md.append("| Assertion | Target | Actual | Result |")
    md.append("|---|---|---|---|")
    for v in verdicts:
        md.append(f"| {v['name']} | {v['target']} | {v['actual']} | {'PASS' if v['passed'] else 'FAIL'} |")
    md.append("")
    md.append("## Summary Stats")
    md.append("")
    md.append(f"- Total samples: {stats['count']}")
    md.append(f"- p50: {stats['p50_ms']} ms")
    md.append(f"- p95: {stats['p95_ms']} ms")
    md.append(f"- p99: {stats['p99_ms']} ms")
    md.append(f"- Errors: {stats['error_count']} ({stats['error_rate'] * 100:.2f}%)")
    md.append("")
    md.append("## Interpretation")
    md.append("")
    if overall_pass:
        md.append("- API held the target RPS within latency and error thresholds.")
        if stats["p95_ms"] < MAX_P95_MS * 0.5:
            md.append(f"- p95 latency ({stats['p95_ms']} ms) is well under the {MAX_P95_MS} ms ceiling — significant headroom.")
        if stats["error_rate"] < MAX_ERROR_RATE * 0.2:
            md.append(f"- Error rate ({stats['error_rate'] * 100:.2f}%) is low — throttle not a concern at this RPS.")
        if overall_rps >= TARGET_RPS:
            md.append(f"- Achieved RPS ({overall_rps:.2f}) met the target — capacity exists for sustained load.")
    else:
        md.append("- One or more assertions failed. See verdict table above.")
        for v in verdicts:
            if not v["passed"]:
                md.append(f"  - {v['name']}: target {v['target']}, actual {v['actual']}")

    with open(md_path, "w") as f:
        f.write("\n".join(md))

    return json_path, csv_path, md_path


def register(env):
    """Wire the Listener to Locust events. Call from locustfile at import time."""
    listener = Listener()
    env.events.request.add_listener(listener.on_request)
    env.events.quitting.add_listener(listener.on_quitting)
    env.events.test_start.add_listener(listener.on_test_start)
    env.events.test_stop.add_listener(listener.on_test_stop)


class Listener:
    def __init__(self):
        self.samples = []
        self.start_time = None
        self.run_id = datetime.now().strftime("%Y%m%d_%H%M%S")

    def on_test_start(self, environment, **kwargs):
        self.start_time = time.time()
        self.samples = []
        print(f"\n=== LOAD TEST START (run_id={self.run_id}) ===\n", flush=True)

    def on_test_stop(self, environment, **kwargs):
        print(f"\n=== LOAD TEST STOP (run_id={self.run_id}) ===\n", flush=True)

    def on_request(self, request_type, name, response_time, response_length, exception, context, **kwargs):
        # Determine status: Locust doesn't expose HTTP status directly here,
        # so we treat exceptions as errors (status 0), success otherwise.
        # For 4xx/5xx without exception, Locust marks response_time but no exception.
        # We rely on environment.stats for status-code breakdown at quitting.
        if exception is not None:
            status = 0  # connection / timeout error
        else:
            status = 200  # success path — refined at quitting from env.stats
        self.samples.append({
            "ts": time.time(),
            "endpoint": name,
            "method": request_type,
            "status": status,
            "response_time_ms": int(response_time or 0),
            "exception": str(exception) if exception else "",
        })

    def on_quitting(self, environment, **kwargs):
        end_time = time.time()
        duration = (end_time - self.start_time) if self.start_time else 0

        # Refine error counts from env.stats — Locust tracks per-request failure
        # in environment.stats.total.fail_ratio. We override our samples' error_rate
        # using authoritative Locust numbers.
        total_stats = environment.stats.total
        locust_error_count = total_stats.num_failures
        locust_total = total_stats.num_requests
        locust_error_rate = total_stats.fail_ratio

        # Rebuild samples' status from env.stats per-name entries for accuracy
        # (per-request hook lacks HTTP status; env.stats has it).
        for entry in environment.stats.entries.values():
            entry_name = entry.name
            entry_method = entry.method
            # For each Locust stats entry, we trust its counts.
            # We don't have per-sample status, so we mark samples under this entry:
            matching = [s for s in self.samples if s["endpoint"] == entry_name and s["method"] == entry_method]
            # If failures exist for this entry, mark proportion of matching samples as failed.
            if matching and entry.num_requests > 0:
                fail_ratio = entry.num_failures / entry.num_requests
                n_fail = int(round(len(matching) * fail_ratio))
                for i, s in enumerate(matching):
                    if i < n_fail:
                        s["status"] = 0  # treat as error
                    else:
                        s["status"] = 200

        # Compute overall stats from refined samples
        stats = compute_stats(self.samples)
        # Override count/error with authoritative Locust numbers
        stats["count"] = locust_total
        stats["error_count"] = locust_error_count
        stats["error_rate"] = locust_error_rate

        # Compute overall RPS achieved
        overall_rps = locust_total / duration if duration > 0 else 0

        verdicts = assert_verdict(stats, overall_rps)
        json_path, csv_path, md_path = write_reports(self.run_id, self.samples, stats, verdicts)

        # Print verdict
        print("\n" + "=" * 50, flush=True)
        print("=== LOAD TEST VERDICT ===", flush=True)
        for v in verdicts:
            tag = "PASS" if v["passed"] else "FAIL"
            print(f"  {v['name']:<32} target={v['target']:<18} actual={v['actual']:<14} [{tag}]", flush=True)
        overall_pass = all(v["passed"] for v in verdicts)
        print(f"\nOverall: {'PASS' if overall_pass else 'FAIL'}", flush=True)
        print(f"  Samples: {stats['count']}  p50={stats['p50_ms']}ms  p95={stats['p95_ms']}ms  p99={stats['p99_ms']}ms", flush=True)
        print(f"  Errors: {stats['error_count']} ({stats['error_rate'] * 100:.2f}%)  Achieved RPS: {overall_rps:.2f}", flush=True)
        print(f"  Reports: {json_path} | {csv_path} | {md_path}", flush=True)
        print("=" * 50 + "\n", flush=True)

        if not overall_pass:
            sys.exit(1)
