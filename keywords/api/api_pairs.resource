*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Trading Pairs
    ${response}=    Execute GET Request    /pairs

    RETURN    ${response}


Get Invalid Trading Pairs Endpoint
    ${response}=    Execute GET Request    /pairssss

    RETURN    ${response}


Post Trading Pairs
    ${response}=    Execute POST Request    /pairs

    RETURN    ${response}