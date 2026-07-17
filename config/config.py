import os
import yaml

DEFAULT_ENV = os.getenv("ENV", "dev")

CONFIG_PATH = os.path.join(
    os.path.dirname(__file__),
    f"{DEFAULT_ENV}.yaml"
)

with open(CONFIG_PATH, "r") as file:
    CONFIG = yaml.safe_load(file)