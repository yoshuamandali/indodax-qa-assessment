*** Settings ***
Resource    ../../pages/android/market_page.resource
Resource    ../assertions/mobile_assertions.resource
Library    OperatingSystem

*** Keywords ***
Market Page Should Be Loaded
    Tap Market Tab
    Element Should Be Visible Within Timeout    ${CURRENT_PRICE_TEXT}

Select Pair
    [Arguments]    ${pair}
    Tap Pair Selector
    Input Pair Search    ${pair}
    Tap Pair From List    ${pair}

Current Price Should Be Valid
    ${price_text}=    Get Current Price Text
    Current Price Should Be Numeric And Positive    ${price_text}

Order Book Should Be Visible
    Wait For Order Book
    ${count}=    Get Matching XPath Count    //androidx.recyclerview.widget.RecyclerView[@resource-id='com.indodax.android:id/recyclerview_orderbook']//*
    Should Be True    ${count} > 0    msg=Expected order book rows, got 0

Trade Form Should Redirect To Login
    [Arguments]    ${side}=buy    ${amount}=10000
    Run Keyword If    '${side}' == 'buy'    Fill Buy Amount    ${amount}
    Run Keyword If    '${side}' == 'buy'    Click Buy Submit
    Run Keyword If    '${side}' == 'sell'    Fill Sell Amount    ${amount}
    Run Keyword If    '${side}' == 'sell'    Click Sell Submit
    # Login screen may be native activity or webview. Assert login element visible.
    Wait Until Page Contains    Login    timeout=15s

Load Pairs Data
    [Arguments]    ${path}
    ${json}=    Get File    ${path}
    ${data}=    Evaluate    json.loads($json)    json
    Set Suite Variable    ${PAIRS_DATA}    ${data}
