*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Order Book Depth
    [Arguments]    ${pair}

    ${response}=    Execute GET Request    /${pair}/depth

    RETURN    ${response}


Get Depth With Invalid Pair
    ${response}=    Execute GET Request    /invalid_pair_xyz_abc/depth

    RETURN    ${response}


Post Order Book Depth
    [Arguments]    ${pair}=btc_idr

    ${response}=    Execute POST Request    /${pair}/depth

    RETURN    ${response}
