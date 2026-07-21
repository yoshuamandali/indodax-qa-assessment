"""Single source of truth for load test pass/fail criteria."""

TARGET_RPS = 10
MAX_P95_MS = 2000          # public API, generous
MAX_ERROR_RATE = 0.05      # 5% — 429s from throttle count as errors
RAMP_SECONDS = 30
HOLD_SECONDS = 120

# Derived — convenience for runner subprocess
TEST_DURATION_SECONDS = RAMP_SECONDS + HOLD_SECONDS  # 150s
