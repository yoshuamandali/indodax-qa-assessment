import os
import yaml

DEFAULT_ENV = os.getenv("ENV", "dev")

CONFIG_PATH = os.path.join(
    os.path.dirname(__file__),
    f"{DEFAULT_ENV}.yaml"
)

with open(CONFIG_PATH, "r") as file:
    CONFIG = yaml.safe_load(file)

# ========= API =========
BASE_URL = CONFIG["api"]["base_url"]
API_TIMEOUT = CONFIG["api"].get("timeout", 30)

# ========= Browser =========
BROWSER = CONFIG["browser"]["type"]
HEADLESS = CONFIG["browser"]["headless"]
BROWSER_URL = CONFIG["browser"]["url"]
BROWSER_TIMEOUT = CONFIG["browser"].get("timeout", 30)

# ========= Mobile =========
PLATFORM = CONFIG["mobile"]["platform"]
MOBILE_CAPABILITIES = CONFIG["mobile"][PLATFORM]
REMOTE_URL = CONFIG["mobile"].get("remote_url", "http://localhost:4723")
