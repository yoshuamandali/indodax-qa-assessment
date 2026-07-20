*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_ticker_all.resource
Resource    ../../../keywords/assertions/api_assertions.resource
Resource    ../../../keywords/assertions/api_business_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Test Cases ***
Verify All Tickers API Returns 200
    ${response}=    Get All Tickers

    Response Status Should Be              ${response}    200
    Response Content Type Should Be JSON   ${response}
    Response Body Should Not Be Empty      ${response}
    Response Time Should Be Less Than      ${response}    3000
    Response Should Match Schema           ${response}    data/schema/ticker_all_schema.json
    All Tickers Should Be Valid            ${response}
