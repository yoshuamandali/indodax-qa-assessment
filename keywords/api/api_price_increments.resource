*** Settings ***
Resource    api_client.resource

*** Keywords ***
Get Price Increments
    ${response}=    Execute GET Request
    ...    /price_increments

    RETURN    ${response}