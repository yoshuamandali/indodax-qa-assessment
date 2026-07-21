import os
import sys

# Make `load` package importable when run from repo root
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from load.listeners.assert_listener import compute_stats


def test_compute_stats_basic():
    samples = [
        {"endpoint": "/a", "status": 200, "response_time_ms": 100},
        {"endpoint": "/a", "status": 200, "response_time_ms": 200},
        {"endpoint": "/a", "status": 200, "response_time_ms": 300},
        {"endpoint": "/a", "status": 200, "response_time_ms": 400},
        {"endpoint": "/a", "status": 429, "response_time_ms": 500},
    ]
    stats = compute_stats(samples)
    assert stats["count"] == 5
    assert stats["error_count"] == 1
    assert stats["error_rate"] == 0.2
    # p50 of [100,200,300,400,500] = 300
    assert stats["p50_ms"] == 300
    # p95 of 5 samples — index ceil(0.95*5)-1 = 4
    assert stats["p95_ms"] == 500


def test_compute_stats_empty():
    stats = compute_stats([])
    assert stats["count"] == 0
    assert stats["error_count"] == 0
    assert stats["error_rate"] == 0.0


def test_compute_stats_all_errors():
    samples = [
        {"endpoint": "/a", "status": 500, "response_time_ms": 10},
        {"endpoint": "/a", "status": 429, "response_time_ms": 5},
    ]
    stats = compute_stats(samples)
    assert stats["count"] == 2
    assert stats["error_count"] == 2
    assert stats["error_rate"] == 1.0
