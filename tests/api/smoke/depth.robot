*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_depth.resource
Resource    ../../../keywords/assertions/api_assertions.resource
Resource    ../../../keywords/assertions/api_business_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Variables ***
${PAIR}    btc_idr

*** Test Cases ***
Verify Order Book Depth API Returns 200 For BTC IDR
    ${response}=    Get Order Book Depth    ${PAIR}

    Response Status Should Be              ${response}    200
    Response Content Type Should Be JSON   ${response}
    Response Body Should Not Be Empty      ${response}
    Response Time Should Be Less Than      ${response}    1000
    Response Should Match Schema           ${response}    data/schema/depth_schema.json
    Order Book Depth Should Be Valid       ${response}
