*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_server_time.resource
Resource    ../../../keywords/assertions/api_assertions.resource
Resource    ../../../keywords/assertions/api_business_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Test Cases ***
Verify Server Time API Returns 200

    ${response}=    Get Server Time

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
    ...    data/schema/server_time_schema.json

    Server Time Should Be Valid
    ...    ${response}