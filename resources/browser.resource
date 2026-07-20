*** Settings ***
Library    Browser
Variables    ../config/config.py

*** Keywords ***
Open Browser Session
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context
    New Page
    Go To    ${BROWSER_URL}

Close Browser Session
    Close Browser

Take Screenshot On Failure
    ${name}=    Set Variable    ${TEST NAME}
    ${safe_name}=    Replace String    ${name}    ${SPACE}    _
    Take Screenshot    reports/${safe_name}.png

Test Teardown For Web
    Run Keyword If Test Failed    Take Screenshot On Failure
    Close Browser Session
