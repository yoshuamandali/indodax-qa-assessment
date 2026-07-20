*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_ticker_all.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression

*** Test Cases ***
Verify Invalid Tickers Endpoint Returns 404
    ${response}=    Get Invalid Tickers Endpoint

    Response Status Should Be    ${response}    404


Verify POST All Tickers Returns Method Not Allowed
    ${response}=    Post All Tickers

    Response Status Should Be    ${response}    405
