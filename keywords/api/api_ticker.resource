*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Ticker
    [Arguments]    ${pair}

    ${response}=    Execute GET Request    /${pair}/ticker

    RETURN    ${response}


Get Ticker With Invalid Pair
    ${response}=    Execute GET Request    /invalid_pair_xyz_abc/ticker

    RETURN    ${response}


Post Ticker
    [Arguments]    ${pair}=btc_idr

    ${response}=    Execute POST Request    /${pair}/ticker

    RETURN    ${response}
