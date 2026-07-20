*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Summaries
    ${response}=    Execute GET Request    /summaries

    RETURN    ${response}


Get Invalid Summaries Endpoint
    ${response}=    Execute GET Request    /summariessss

    RETURN    ${response}


Post Summaries
    ${response}=    Execute POST Request    /summaries

    RETURN    ${response}
