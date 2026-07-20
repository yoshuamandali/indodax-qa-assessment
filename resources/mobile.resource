*** Settings ***
Library    AppiumLibrary
Variables    ../config/config.py

*** Keywords ***
Open Mobile Session
    Open Application    ${REMOTE_URL}    &{MOBILE_CAPABILITIES}

Close Mobile Session
    Close Application

Take Screenshot On Failure
    ${name}=    Set Variable    ${TEST NAME}
    ${safe_name}=    Replace String    ${name}    ${SPACE}    _
    Capture Page Screenshot    reports/${safe_name}.png

Test Teardown For Mobile
    Run Keyword If Test Failed    Take Screenshot On Failure
    Close Mobile Session
