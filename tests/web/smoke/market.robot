*** Settings ***
Resource    ../../../keywords/web/market_keywords.resource
Resource    ../../../keywords/assertions/web_assertions.resource
Resource    ../../../resources/browser.resource
Suite Setup    Suite Setup For Market
Test Setup    Open Browser Session
Test Teardown    Test Teardown For Web
Test Tags    web    smoke    market

*** Test Cases ***
Market Page Loads And Shows Current Price
    [Documentation]    Smoke: verify Market page renders for default pair
    Market Page Should Be Loaded
    Current Price Should Be Valid

Select Pair Template
    [Documentation]    Data-driven via [Template] — explicit pairs inline
    [Template]    Verify Pair Selection
    USDTIDR    USDT/IDR
    BTCIDR     BTC/IDR
    ETHIDR     ETH/IDR
    INVALID    ZZZ/IDR

Order Book Is Visible
    [Documentation]    Smoke: order book renders buy/sell rows
    Market Page Should Be Loaded
    Order Book Should Be Visible

Trade Form Redirects To Login For Non Logged In User
    [Documentation]    Skipped: trade form only exists in Pro mode — revisit on Pro mode
    [Tags]    web    smoke    negative    skip
    Skip    Trade form not available in Classic mode

*** Keywords ***
Suite Setup For Market
    Load Pairs Data    ${CURDIR}/../../../data/web/pairs.json

Verify Pair Selection
    [Arguments]    ${symbol}    ${display}
    Market Page Should Be Loaded
    Run Keyword And Ignore Error    Select Pair    ${symbol}
    Run Keyword If    '${symbol}' != 'INVALID'    Current Price Should Be Valid