*** Settings ***
Library    RequestsLibrary
Variables    ../config/config.py

*** Keywords ***
Create API Session
    Create Session
    ...    indodax
    ...    ${BASE_URL}
    ...    verify=${False}
    ...    timeout=${API_TIMEOUT}