Run Command Cheat Sheet
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

# Mobile Android smoke
ENV=staging robot --include androidANDsmoke --variable REMOTE_URL:http://hub:4723 tests/mobile/

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