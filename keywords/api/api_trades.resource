*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Recent Trades
    [Arguments]    ${pair}

    ${response}=    Execute GET Request    /${pair}/trades

    RETURN    ${response}


Get Trades With Invalid Pair
    ${response}=    Execute GET Request    /invalid_pair_xyz_abc/trades

    RETURN    ${response}


Post Recent Trades
    [Arguments]    ${pair}=btc_idr

    ${response}=    Execute POST Request    /${pair}/trades

    RETURN    ${response}
