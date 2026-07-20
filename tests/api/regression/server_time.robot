*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_client.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression

*** Test Cases ***
Verify Invalid Server Time Endpoint Returns 404
    ${response}=    Execute GET Request    /server_time_invalid

    Response Status Should Be    ${response}    404


Verify POST Server Time Returns Method Not Allowed
    ${response}=    Execute POST Request    /server_time

    Response Status Should Be    ${response}    405