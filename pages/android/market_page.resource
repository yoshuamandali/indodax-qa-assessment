*** Settings ***
Resource    ../../resources/mobile.resource

*** Variables ***
# Primary: accessibility_id. Fallback: resource ID. Tertiary: uiautomator text.
${MARKET_TAB}                accessibility_id=market_tab
${MARKET_TAB_ID}             id=com.indodax.android:id/nav_market
${PAIR_SELECTOR}             accessibility_id=pair_selector
${PAIR_SEARCH_INPUT}         id=com.indodax.android:id/edit_search
${PAIR_LIST_ROW}             id=com.indodax.android:id/text_pair_symbol
${CURRENT_PRICE_TEXT}        id=com.indodax.android:id/text_last_price
${ORDER_BOOK_LIST}           id=com.indodax.android:id/recyclerview_orderbook
${BUY_AMOUNT_INPUT}          id=com.indodax.android:id/edit_buy_amount
${SELL_AMOUNT_INPUT}         id=com.indodax.android:id/edit_sell_amount
${BUY_SUBMIT_BUTTON}         id=com.indodax.android:id/button_buy
${SELL_SUBMIT_BUTTON}        id=com.indodax.android:id/button_sell

*** Keywords ***
Tap Market Tab
    ${clicked}=    Run Keyword And Ignore Error    Wait Until Page Contains Element    ${MARKET_TAB}    5s
    Run Keyword If    '${clicked}[0]' == 'PASS'    Click Element    ${MARKET_TAB}
    Run Keyword If    '${clicked}[0]' == 'FAIL'    Click Element    ${MARKET_TAB_ID}

Tap Pair Selector
    Click Element    ${PAIR_SELECTOR}

Input Pair Search
    [Arguments]    ${pair}
    Wait Until Page Contains Element    ${PAIR_SEARCH_INPUT}    10s
    Input Text    ${PAIR_SEARCH_INPUT}    ${pair}

Tap Pair From List
    [Arguments]    ${pair}
    Wait Until Page Contains Element    ${PAIR_LIST_ROW}    10s
    Click Element    ${PAIR_LIST_ROW}

Get Current Price Text
    Wait Until Page Contains Element    ${CURRENT_PRICE_TEXT}    10s
    ${price_text}=    Get Text    ${CURRENT_PRICE_TEXT}
    RETURN    ${price_text}

Wait For Order Book
    Wait Until Page Contains Element    ${ORDER_BOOK_LIST}    10s

Fill Buy Amount
    [Arguments]    ${amount}
    Wait Until Page Contains Element    ${BUY_AMOUNT_INPUT}    10s
    Input Text    ${BUY_AMOUNT_INPUT}    ${amount}

Fill Sell Amount
    [Arguments]    ${amount}
    Wait Until Page Contains Element    ${SELL_AMOUNT_INPUT}    10s
    Input Text    ${SELL_AMOUNT_INPUT}    ${amount}

Click Buy Submit
    Wait Until Page Contains Element    ${BUY_SUBMIT_BUTTON}    10s
    Click Element    ${BUY_SUBMIT_BUTTON}

Click Sell Submit
    Wait Until Page Contains Element    ${SELL_SUBMIT_BUTTON}    10s
    Click Element    ${SELL_SUBMIT_BUTTON}
