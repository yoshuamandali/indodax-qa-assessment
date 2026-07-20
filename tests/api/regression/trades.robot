*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_trades.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression

*** Test Cases ***
Verify Trades With Invalid Pair Returns 404
    ${response}=    Get Trades With Invalid Pair

    Response Status Should Be    ${response}    404


Verify POST Recent Trades Returns Method Not Allowed
    ${response}=    Post Recent Trades

    Response Status Should Be    ${response}    405
