# Indodax QA Assessment

Robot Framework + Locust test suite covering API, web, mobile, and load testing.

## How to Run

### Prerequisites

- Python 3.10+
- Virtualenv (recommended)

### Setup

```bash
# Clone
git clone <repo-url>
cd indodax-qa-assessment

# Create + activate venv
python -m venv .venv
source .venv/bin/activate        # macOS/Linux
# .venv\Scripts\activate         # Windows

# Install deps
pip install -r requirements.txt
```

### Configuration

Env selected via `ENV` var (`dev` | `staging` | `prod`). Values in `config/{env}.yaml`.

## Run Command
```bash
# Dev smoke
ENV=dev robot --include smoke tests/api/

# Staging regression
ENV=staging robot --include regression tests/api/

# Critical only across all platforms
ENV=staging robot --include critical tests/

# Parallel API regression
ENV=staging pabot --processes 4 --include regression tests/api/

# Single feature
ENV=staging robot --include ticker tests/api/

# Exclude non-critical
ENV=staging robot --exclude non-critical tests/

# Mobile Android smoke (local)
# 1. Start Appium server (separate terminal)
appium --port 4723

# 2. Verify device connected
adb devices

# 3. Run suite
ENV=dev robot --include smoke tests/mobile/android/smoke/

# Generate report to custom dir
ENV=staging robot --outputdir reports/staging/smoke/$(date +%Y%m%d_%H%M%S) --include smoke tests/
```

Layer-to-File Cross-Reference

| Layer | File | Role |
|---|---|---|
| Config | `config/config.py` | Env loader |
| Config | `config/{env}.yaml` | Env values |
| Infra | `resources/api.resource` | RequestsLibrary session |
| Infra | `resources/browser.resource` | Playwright session |
| Infra | `resources/mobile.resource` | AppiumLibrary session |
| Infra | `resources/common.resource` | Shared BuiltIn libs |
| Domain | `keywords/api/api_client.resource` | Generic HTTP wrapper |
| Domain | `keywords/api/api_ticker.resource` | Ticker endpoint |
| Domain | `keywords/api/api_session.resource` | Session init |
| Domain | `keywords/assertions/api_assertions.resource` | HTTP assertions |
| Domain | `keywords/assertions/api_business_assertions.resource` | Business assertions |
| Utils | `keywords/utils/logger.resource` | Structured logging |
| Utils | `keywords/utils/retry.resource` | Retry wrapper |
| Libraries | `libraries/schema_validator.py` | JSON Schema validation |
| Libraries | `libraries/api_validator.py` | Business invariants |
| Data | `data/api/pairs.json` | Fixture |
| Data | `data/schema/*.json` | 8 JSON Schemas |
| Tests | `tests/api/smoke/*.robot` | Happy path |
| Tests | `tests/api/regression/*.robot` | Negative + edge |

## Load Testing

### Run via Flask UI (recommended for interactive runs)

```bash
python3 -m load.runner.app
# Open http://127.0.0.1:5001  (port 5000 is used by macOS AirPlay)
# Pick script + set Target RPS + Users -> Run
# Endpoints table populates live; click a past report row to view rendered markdown
```

### Run via CLI (headless)

```bash
# Full 10-user run with ramp + hold (150s total)
locust -f load/getAllEmployee.py --headless -u 10 -r 2 --run-time 150s

# Smoke run with 2 users for 10s
locust -f load/getEmployeeById.py --headless -u 2 -r 1 --run-time 10s

# With CSV output
locust -f load/getAllEmployee.py --headless -u 10 -r 2 --run-time 150s \
       --csv load/reports/load_$(date +%Y%m%d_%H%M%S)
```

### Pass/Fail Criteria (in `load/config/thresholds.py`)

| Assertion | Target |
|---|---|
| Achieved RPS | >= 90% of TARGET_RPS |
| p95 latency | <= 2000 ms |
| Error rate | <= 5% |

### Reports

Written to `load/reports/`:
- `load_<timestamp>.json` — full per-request samples + summary stats
- `load_<timestamp>.csv` — per-sample CSV
- `load_<timestamp>.md` — short written interpretation with verdict

### Exit Code

Exit code `0` = all assertions passed. `1` = at least one assertion failed (CI-friendly).
