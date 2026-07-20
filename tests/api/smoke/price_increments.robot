*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_price_increments.resource
Resource    ../../../keywords/assertions/api_assertions.resource
Resource    ../../../keywords/assertions/api_business_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Test Cases ***
Verify Price Increments API Returns 200
    ${response}=    Get Price Increments

    Response Status Should Be
    ...    ${response}
    ...    200

    Response Content Type Should Be JSON
    ...    ${response}

    Response Body Should Not Be Empty
    ...    ${response}

    Response Time Should Be Less Than
    ...    ${response}
    ...    1000

    Response Should Match Schema
    ...    ${response}
    ...    data/schema/price_increments_schema.json

    Price Increments Should Be Valid
    ...    ${response}