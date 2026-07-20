*** Settings ***
Resource    ../../../../keywords/mobile/market_keywords.resource
Resource    ../../../../keywords/assertions/mobile_assertions.resource
Resource    ../../../../resources/mobile.resource
Suite Setup    Suite Setup For Mobile Market
Test Setup    Open Mobile Session
Test Teardown    Test Teardown For Mobile
Test Tags    mobile    android    smoke    market

*** Test Cases ***
Market Tab Loads And Shows Price
    [Documentation]    Smoke: verify Market tab active, price element visible, numeric, > 0
    Market Page Should Be Loaded
    Current Price Should Be Valid

Select Pair Template
    [Documentation]    Data-driven via [Template] — explicit pairs inline
    [Template]    Verify Pair Selection
    USDTIDR    USDT/IDR
    BTCIDR     BTC/IDR
    ETHIDR     ETH/IDR
    INVALID    ZZZ/IDR

Select All Pairs From Fixture
    [Documentation]    Data-driven via JSON fixture — exhaustive
    [Tags]    mobile    android    smoke    data-driven
    Verify All Pairs From Fixture

Order Book Is Visible
    [Documentation]    Smoke: order book recycler has rows
    Market Page Should Be Loaded
    Order Book Should Be Visible

Trade Form Redirects To Login For Non Logged In User
    [Documentation]    Negative: non-logged-in user tapping trade submit should reach login screen
    [Tags]    mobile    android    smoke    negative
    Market Page Should Be Loaded
    Trade Form Should Redirect To Login    buy    10000

*** Keywords ***
Suite Setup For Mobile Market
    Load Pairs Data    ${CURDIR}/../../../../data/mobile/pairs.json

Verify Pair Selection
    [Arguments]    ${symbol}    ${display}
    Market Page Should Be Loaded
    Run Keyword And Ignore Error    Select Pair    ${symbol}
    Run Keyword If    '${symbol}' != 'INVALID'    Current Price Should Be Valid

Verify All Pairs From Fixture
    Market Page Should Be Loaded
    FOR    ${pair}    IN    @{PAIRS_DATA}[pairs]
        Run Keyword If    '${pair}[category]' != 'negative'    Run Keywords    Select Pair    ${pair}[symbol]    AND    Current Price Should Be Valid
    END
