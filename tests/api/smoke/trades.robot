*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_trades.resource
Resource    ../../../keywords/assertions/api_assertions.resource
Resource    ../../../keywords/assertions/api_business_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Variables ***
${PAIR}    btcidr

*** Test Cases ***
Verify Recent Trades API Returns 200 For BTC IDR
    ${response}=    Get Recent Trades    ${PAIR}

    Response Status Should Be              ${response}    200
    Response Content Type Should Be JSON   ${response}
    Response Body Should Not Be Empty      ${response}
    Response Time Should Be Less Than      ${response}    1000
    Response Should Match Schema           ${response}    data/schema/trades_schema.json
    Trades Should Be Valid                 ${response}
