*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get All Tickers
    ${response}=    Execute GET Request    /tickers

    RETURN    ${response}


Get Invalid Tickers Endpoint
    ${response}=    Execute GET Request    /tickerssss

    RETURN    ${response}


Post All Tickers
    ${response}=    Execute POST Request    /tickers

    RETURN    ${response}
