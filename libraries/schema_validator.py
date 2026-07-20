import json


def validate_schema(response_text, schema_path):
    """
    Validate that a JSON response body conforms to a JSON Schema.

    Arguments:
    - response_text: raw JSON string (response.text)
    - schema_path:   path to the .json schema file (relative to CWD)

    Raises AssertionError with a descriptive message on failure.
    """
    from jsonschema import validate, ValidationError

    try:
        response = json.loads(response_text)
    except json.JSONDecodeError as e:
        raise AssertionError(f"Response body is not valid JSON: {e}")

    try:
        with open(schema_path) as f:
            schema = json.load(f)
    except FileNotFoundError:
        raise AssertionError(f"Schema file not found: '{schema_path}'")
    except json.JSONDecodeError as e:
        raise AssertionError(f"Schema file '{schema_path}' contains invalid JSON: {e}")

    try:
        validate(instance=response, schema=schema)
    except ValidationError as e:
        raise AssertionError(f"Schema validation failed at '{e.json_path}': {e.message}")