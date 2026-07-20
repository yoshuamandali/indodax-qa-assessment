*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Server Time
    ${response}=    Execute GET Request
    ...    /server_time

    RETURN    ${response}