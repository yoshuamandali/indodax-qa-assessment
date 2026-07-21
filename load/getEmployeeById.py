"""Locust entry point: GET-only load test against https://dummy.restapiexample.com.

Endpoints:
  - GET /api/v1/employees         (weight 1)
  - GET /api/v1/employee/{id}      (weight 4, id 1-25)

Load shape (users, spawn rate, duration) is driven by locust CLI flags
`-u`, `-r`, `--run-time` passed by the Flask runner or CLI user.
"""

import random
import sys
import os

from locust import HttpUser, between, task, events

# Make `load` package importable when locust runs from repo root
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from load.listeners.assert_listener import register


class EmployeeUser(HttpUser):
    host = "https://dummy.restapiexample.com"
    wait_time = between(1, 2)

    def on_start(self):
        # Server's ModSecurity blocks default `python-requests` UA with 406.
        # Override the session UA to a browser-like string.
        self.client.headers.update({
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                          "AppleWebKit/537.36 (KHTML, like Gecko) "
                          "Chrome/120.0.0.0 Safari/537.36",
        })

    @task(1)
    def get_employee(self):
        emp_id = random.randint(1, 25)
        self.client.get(f"/api/v1/employee/{emp_id}", name="GET /api/v1/employee/{id}")


# Register the custom listener with Locust events
@events.test_start.add_listener
def _on_start(environment, **kwargs):
    register(environment)
