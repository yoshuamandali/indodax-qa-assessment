*** Settings ***
Resource    ../../pages/web/market_page.resource
Resource    ../assertions/web_assertions.resource
Library    OperatingSystem

*** Keywords ***
Market Page Should Be Loaded
    ${url}=    Get Url
    Should Contain    ${url}    /market/USDTIDR    msg=Expected /market/USDTIDR in URL, got ${url}
    Dismiss Pro Classic Mode Modal
    Element Should Be Visible Within Timeout    ${CURRENT_PRICE}    timeout=20s

Select Pair
    [Arguments]    ${pair}
    Click Pair Selector
    Type Pair Search    ${pair}
    Select Pair From Dropdown    ${pair}

Current Price Should Be Valid
    ${price_text}=    Get Current Price
    Current Price Should Be Numeric And Positive    ${price_text}

Order Book Should Be Visible
    Element Should Be Visible Within Timeout    ${ORDER_BOOK_SELL_TABLE}
    Element Should Be Visible Within Timeout    ${ORDER_BOOK_BUY_TABLE}
    ${rows}=    Get Order Book Row Count
    Should Be True    ${rows} > 0    msg=Expected order book rows, got 0

Trade Form Should Redirect To Login
    [Arguments]    ${side}=buy    ${amount}=10000
    Run Keyword If    '${side}' == 'buy'    Fill Buy Amount    ${amount}
    Run Keyword If    '${side}' == 'buy'    Click Buy Submit
    Run Keyword If    '${side}' == 'sell'    Fill Sell Amount    ${amount}
    Run Keyword If    '${side}' == 'sell'    Click Sell Submit
    ${url}=    Get Url
    Should Contain    ${url}    /login    msg=Expected redirect to /login for non-logged-in user, got ${url}

Load Pairs Data
    [Arguments]    ${path}
    ${json}=    Get File    ${path}
    ${data}=    Evaluate    json.loads($json)    json
    Set Suite Variable    ${PAIRS_DATA}    ${data}
