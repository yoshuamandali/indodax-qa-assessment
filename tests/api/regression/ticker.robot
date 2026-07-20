*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_ticker.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression

*** Test Cases ***
Verify Ticker With Invalid Pair Returns 404
    ${response}=    Get Ticker With Invalid Pair

    Response Status Should Be    ${response}    404


Verify POST Ticker Returns Method Not Allowed
    ${response}=    Post Ticker

    Response Status Should Be    ${response}    405
