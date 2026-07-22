# Automation Architecture

## Objective

Create a scalable automation framework supporting:
- Web
- API
- Android
- iOS
using Robot Framework.

---

## Overview & Tech Stack

| Layer | Technology | Justification |
|---|---|---|
| Automation Framework | Robot Framework 7.x | Keyword-driven, platform-agnostic, tabular test syntax, mature ecosystem, team-friendly |
| Web Engine | Playwright (via `robotframework-browser`) | Native async, auto-wait, reliable selectors, Chromium/Firefox/WebKit |
| Mobile Engine | Appium (via `robotframework-appiumlibrary`) | Cross-platform (Android + iOS), W3C WebDriver, real device + emulator support |
| API Engine | Requests (via `robotframework-requests`) | De facto Python HTTP, session reuse, simple |
| Load Testing | Locust | Python-native, distributed, scriptable scenarios |
| Schema Validation | `jsonschema` (custom library) | Contract testing for public Indodax API |
| Config | YAML + Python loader | Env isolation, version-controlled, no hardcoded URLs |
| CI/CD | GitHub Actions | Planned. `.github/workflows/` currently empty — target topology uses self-hosted VM runners (Web/API) + local Appium device farm (Mobile) |

---

## Folder Structure

```
indodax-qa-assessment/
├── config/                              # Config layer
│   ├── config.py                        # Loads {ENV}.yaml via ENV env var
│   ├── dev.yaml                         # Dev env config
│   ├── staging.yaml                     # Staging env config
│   └── prod.yaml                        # Production env config (read-only runs)
│
├── resources/                           # Infra / Drivers layer
│   ├── common.resource                  # BuiltIn, OperatingSystem, String — shared libs
│   ├── api.resource                     # RequestsLibrary session factory
│   ├── browser.resource                 # Browser (Playwright) session factory
│   └── mobile.resource                  # AppiumLibrary session factory
│
├── keywords/                            # Domain / Application layer
│   ├── api/                             # API business keywords
│   │   ├── api_session.resource         # Initialize API Session (wraps resources/api.resource)
│   │   ├── api_client.resource          # Generic GET/POST/PUT/DELETE + logging
│   │   ├── api_ticker.resource          # Get Ticker, Post Ticker, Get Ticker With Invalid Pair
│   │   ├── api_ticker_all.resource
│   │   ├── api_pairs.resource
│   │   ├── api_summaries.resource
│   │   ├── api_depth.resource
│   │   ├── api_trades.resource
│   │   ├── api_price_increments.resource
│   │   └── api_server_time.resource
│   ├── assertions/                      # Assertion keywords (separate from business)
│   │   ├── api_assertions.resource      # HTTP-level: status, header, schema, response time
│   │   ├── api_business_assertions.resource  # Domain: Ticker Should Be Valid, Trading Pairs Should Be Valid
│   │   ├── web_assertions.resource      # Web: Element Should Be Visible, Current Price Should Be Numeric And Positive
│   │   └── mobile_assertions.resource   # Mobile: same shape as web_assertions via AppiumLibrary
│   ├── utils/                           # Cross-platform utilities
│   │   ├── logger.resource              # Structured request/response logging
│   │   └── retry.resource               # Execute Keyword With Retry (flaky network guard)
│   ├── web/                             # Web business keywords
│   │   └── market_keywords.resource     # Market Page Should Be Loaded, Select Pair, Order Book Should Be Visible
│   └── mobile/                          # Mobile business keywords
│       └── market_keywords.resource     # Market Page Should Be Loaded, Select Pair, Trade Form Should Redirect To Login
│
├── libraries/                           # Framework plugins (Python)
│   ├── schema_validator.py              # JSON Schema validation (contract testing)
│   └── api_validator.py                 # Business invariants: low <= high, server_time > 0, etc.
│
├── data/                                # Test data + schemas
│   ├── api/
│   │   └── pairs.json                   # Data-driven fixtures
│   ├── web/
│   │   └── pairs.json                   # Web pairs fixture (USDTIDR, BTCIDR, ETHIDR, INVALID)
│   ├── mobile/
│   │   └── pairs.json                   # Mobile pairs fixture (same shape as web)
│   └── schema/                          # 8 JSON Schemas (ticker, pairs, depth, trades, ...)
│
├── tests/                               # Test layer (use cases)
│   ├── api/
│   │   ├── smoke/                       # 9 files: happy path + health_check
│   │   └── regression/                  # 8 files: negative + edge cases
│   ├── web/
│   │   └── smoke/
│   │       └── market.robot             # Market page smoke (web)
│   └── mobile/                          # Mobile — Android smoke implemented (see below); iOS planned
│       └── android/smoke/
│           └── market.robot             # Market Tab Loads, Select Pair, Order Book, Trade Form Redirects To Login
│
├── pages/                               # Page Object / Screen abstraction
│   ├── web/
│   │   └── market_page.resource         # Locators + actions: Open Market Page, Select Pair, Get Current Price
│   └── android/
│       └── market_page.resource         # Screen object: Tap Market Tab, pair selector, order book, trade form
│
├── load/                                # Locust load scenarios + Flask runner UI
│   ├── getAllEmployee.py                # GET /api/v1/employees (dummy.restapiexample.com)
│   ├── getEmployeeById.py               # GET /api/v1/employee/{id}
│   ├── config/
│   │   └── thresholds.py                # TARGET_RPS, MAX_P95_MS, MAX_ERROR_RATE, RAMP/HOLD seconds
│   ├── listeners/
│   │   ├── assert_listener.py           # compute_stats, assert_verdict, write_reports, register
│   │   └── test_assert_listener.py      # pytest unit tests for compute_stats
│   ├── runner/
│   │   ├── app.py                       # Flask UI on 127.0.0.1:5001 — script/RPS/users picker, live status
│   │   └── templates/
│   │       └── runner.html              # Live status, endpoints table, past reports
│   └── reports/                         # Locust CSV/JSON/Markdown artifacts per run
│
├── reports/                             # Execution artifacts (report.html, log.html, output.xml)
│   └── smoke/
│
├── .github/                             # GitHub Actions workflows
├── requirements.txt                     # Pinned dependencies
└── README.md
```


---

## Environment Strategy
Configuration Model

```
ENV env var (dev | staging | prod)
        │
        ▼
config/config.py  ──►  config/{env}.yaml  ──►  Python CONFIG dict
        │
        ▼
Resources consume via:  Variables    ../config/config.py
```

### YAML Structure (consistent across envs)

```yaml
# config/staging.yaml — actual shape
base_url: "https://indodax.com"

api:
  base_url: "https://indodax.com/api"
  timeout: 30

browser:
  type: chromium
  headless: true        # false in dev, true in staging/prod
  url: "https://indodax.com/market/USDTIDR"
  timeout: 30

mobile:
  platform: android     # android | ios (ios config block not yet defined)
  android:
    platformName: Android
    automationName: UiAutomator2
    appPackage: id.co.bitcoin
    appActivity: id.co.bitcoin.ui.main.SplashScreenActivity
    deviceName: Pixel-7
    noReset: true
    newCommandTimeout: 300
```

### Environment Selection

| Env | Trigger | Headless | Used For |
|---|---|---|---|
| `dev` | `ENV=dev` (default) | false | Local development, debugging |
| `staging` | `ENV=staging` | true | CI smoke + regression |
| `prod` | `ENV=prod` | true | Read-only smoke, contract verification |

Run example:
```bash
ENV=staging robot --include smoke tests/api/
```

### Safety Guardrails

- **Default fallback**: `config.py` falls back to `dev` if `ENV` unset — prevents accidental prod runs.
- **Prod is read-only**: API tests against prod only use GET endpoints. No POST/PUT/DELETE against prod unless `ALLOW_PROD_WRITE=true` env var set.
- **CI injection**: GitHub Actions sets `ENV` per job — never committed to yaml.
- **Secret isolation**: API keys, tokens injected via GitHub Secrets → `os.getenv()` in Python, never in yaml.

---

## Tagging Strategy (Multi-Tag per Test Case)

Why Multi-Tag

A single test case belongs to multiple dimensions simultaneously. Example: `Verify Ticker API Returns 200 For BTC IDR` is `api`, `smoke`, `critical`, and `ticker`. Multi-tag enables orthogonal selection.

### Tag Dimensions

| Dimension | Tags | Example Use |
|---|---|---|
| **Platform** | `api` `web` `android` `ios` | Run only API tests |
| **Suite Type** | `smoke` `regression` | Run smoke only on PR |
| **Criticality** | `critical` `non-critical` | Selective critical run pre-deploy |
| **Feature** | `ticker` `pairs` `depth` `trades` `summaries` `server_time` `price_increments` `trade` `auth` | Single feature debug |
| **Type** | `positive` `negative` | Negative path only (regression) |

### Tag Placement

- **Suite-level**: `Test Tags    api    smoke` in `.robot` file header (applies to all cases in suite)
- **Case-level**: `[Tags]    api    smoke    critical    ticker` for override/augmentation

### Existing Examples

```robotframework
# tests/api/smoke/ticker.robot
Test Tags    api    smoke

# tests/api/regression/ticker.robot
Test Tags    api    regression
```

---

## Error Handling & Reporting

Error Handling Layers

| Layer | Strategy | Example |
|---|---|---|
| HTTP | `expected_status=any` in `api_client.resource` → assertion decides, not the call | GET returns 404 → test asserts 404, not hard-fail |
| Schema | `schema_validator.py` raises `AssertionError` with JSON path | `Schema validation failed at '$.ticker.high': ...` |
| Business invariant | `api_validator.py` asserts domain rules | `low <= high`, `server_time > 0`, `type ∈ {buy, sell}` |
| Network | `retry.resource` wraps flaky calls | 3 retries, 2s interval |
| Session | `Suite Setup` fails fast | `Initialize API Session` failure aborts suite |

### Assertion Separation

Two-tier assertion model:

1. **HTTP assertions** (`api_assertions.resource`): generic, reusable
   - `Response Status Should Be`
   - `Response Content Type Should Be JSON`
   - `Response Time Should Be Less Than`
   - `Response Should Match Schema`

2. **Business assertions** (`api_business_assertions.resource`): domain-specific
   - `Ticker Should Be Valid` (calls `api_validator.py::validate_ticker`)
   - `Trading Pairs Should Be Valid`
   - `Order Book Depth Should Be Valid`

Test cases compose both:
```robotframework
${response}=    Get Ticker    ${PAIR}
Response Status Should Be           ${response}    200
Response Should Match Schema         ${response}    data/schema/ticker_schema.json
Ticker Should Be Valid               ${response}
```

### Logging

`keywords/utils/logger.resource` provides structured logging:

```
=====================================
API REQUEST
Method : GET
Endpoint : /btc_idr/ticker
=====================================
API RESPONSE
Status : 200
Response Time : 142.3 ms
Headers : {...}
Body :
{...}
=====================================
```

### Reporting

| Output | File | Purpose |
|---|---|---|
| HTML report | `report.html` | Executive summary, pass/fail per suite |
| Log file | `log.html` | Full keyword trace, debugging |
| XML output | `output.xml` | Machine-readable, CI parsing, xUnit conversion |
| Console | stdout | Real-time CI feedback |

Report structure: `reports/{env}/{suite-type}/{timestamp}/`

CI artifacts uploaded as GitHub Actions artifacts, retained 30 days.

---

## CI/CD

GitHub Actions

---