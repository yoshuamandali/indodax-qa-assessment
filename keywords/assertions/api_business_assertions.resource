*** Settings ***
Library    ../../libraries/api_validator.py

*** Keywords ***
Server Time Should Be Valid
    [Arguments]    ${response}

    Validate Server Time    ${response}


Price Increments Should Be Valid
    [Arguments]    ${response}

    Validate Price Increments    ${response}


Trading Pairs Should Be Valid
    [Arguments]    ${response}

    Validate Pairs    ${response}


Summaries Should Be Valid
    [Arguments]    ${response}

    Validate Summaries    ${response}


Ticker Should Be Valid
    [Arguments]    ${response}

    Validate Ticker    ${response}


All Tickers Should Be Valid
    [Arguments]    ${response}

    Validate Ticker All    ${response}


Order Book Depth Should Be Valid
    [Arguments]    ${response}

    Validate Depth    ${response}


Trades Should Be Valid
    [Arguments]    ${response}

    Validate Trades    ${response}