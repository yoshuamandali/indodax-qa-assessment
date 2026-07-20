*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_client.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression


*** Test Cases ***
Verify Invalid Price Increment Endpoint Returns 404
    ${response}=    Execute GET Request
    ...    /price_incrementssss

    Response Status Should Be
    ...    ${response}
    ...    404