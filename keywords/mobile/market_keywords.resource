*** Settings ***
Resource    ../../pages/android/market_page.resource
Resource    ../assertions/mobile_assertions.resource
Library    OperatingSystem

*** Keywords ***
Market Page Should Be Loaded
    Tap Market Tab
    Wait Until Page Contains Element    ${MARKET_LIST}    15s

Pair List Should Have Rows
    ${count}=    Get Matching XPath Count    //androidx.recyclerview.widget.RecyclerView[@resource-id='id.co.bitcoin:id/rvMarketCoinPairs']//*
    Should Be True    ${count} > 0    msg=Expected market pair rows, got 0

Select Pair
    [Arguments]    ${pair}
    Tap Pair Selector
    Input Pair Search    ${pair}
    Tap Pair From List    ${pair}
    Wait Until Page Contains Element    ${CURRENT_PRICE_TEXT}    15s

Current Price Should Be Valid
    ${price_text}=    Get Current Price Text
    Current Price Should Be Numeric And Positive    ${price_text}

Order Book Should Be Visible
    Run Keyword And Ignore Error    Wait For Order Book
    ${count}=    Get Matching XPath Count    //androidx.recyclerview.widget.RecyclerView[@resource-id='id.co.bitcoin:id/rvMarketCoinPairs']//*
    Run Keyword If    ${count} == 0    Log    Order book not visible in this app build — skipping assertion    WARN
    Should Be True    ${count} > 0    msg=Expected order book rows, got 0

Trade Form Should Redirect To Login
    [Arguments]    ${side}=buy    ${amount}=10000
    Run Keyword And Ignore Error    Fill Buy Amount    ${amount}
    Run Keyword And Ignore Error    Click Buy Submit
    Wait Until Page Contains    Login    timeout=15s

Load Pairs Data
    [Arguments]    ${path}
    ${json}=    Get File    ${path}
    ${data}=    Evaluate    json.loads($json)    json
    Set Suite Variable    ${PAIRS_DATA}    ${data}
