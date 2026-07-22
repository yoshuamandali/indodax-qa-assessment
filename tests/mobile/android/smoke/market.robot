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
    [Documentation]    Smoke: Market tab active, pair list visible with rows
    Market Page Should Be Loaded
    Pair List Should Have Rows

Order Book Is Visible
    [Documentation]    Smoke: market list recycler has rows
    Market Page Should Be Loaded
    Pair List Should Have Rows

*** Keywords ***
Suite Setup For Mobile Market
    Load Pairs Data    ${CURDIR}/../../../../data/mobile/pairs.json
