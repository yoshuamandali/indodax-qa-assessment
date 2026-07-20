*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_ticker.resource
Resource    ../../../keywords/assertions/api_assertions.resource
Resource    ../../../keywords/assertions/api_business_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Variables ***
${PAIR}    btc_idr

*** Test Cases ***
Verify Ticker API Returns 200 For BTC IDR
    ${response}=    Get Ticker    ${PAIR}

    Response Status Should Be              ${response}    200
    Response Content Type Should Be JSON   ${response}
    Response Body Should Not Be Empty      ${response}
    Response Time Should Be Less Than      ${response}    1000
    Response Should Match Schema           ${response}    data/schema/ticker_schema.json
    Ticker Should Be Valid                 ${response}
