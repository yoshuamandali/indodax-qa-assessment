*** Settings ***
Resource    ../../resources/mobile.resource

*** Variables ***
# Indodax Android app — package: id.co.bitcoin
# Bottom nav (3 tabs: Home / Market / Others) — uses icon+title
${MARKET_TAB_TITLE}             xpath=//android.widget.TextView[@resource-id='id.co.bitcoin:id/title' and @text='Market']
${MARKET_LIST}                   xpath=//androidx.recyclerview.widget.RecyclerView[@resource-id='id.co.bitcoin:id/rvMarketCoinPairs']
${PAIR_SELECTOR}                 xpath=//android.view.ViewGroup[@resource-id='id.co.bitcoin.market_v3_pro:id/clSearch']
${PAIR_SEARCH_INPUT}             xpath=//android.widget.EditText[@resource-id='id.co.bitcoin.search_lite:id/etSearch']
${PAIR_LIST_ROW}                 xpath=//android.widget.TextView[@resource-id='id.co.bitcoin.search_lite:id/tvMarketPairName']
${PAIR_LIST_ROW_MARKET}          id=id.co.bitcoin:id/tvMarketPairName
${CURRENT_PRICE_TEXT}            xpath=//android.widget.TextView[@resource-id='id.co.bitcoin.detail_lite:id/tvPriceDetail']
${ORDER_BOOK_LIST}               xpath=//androidx.recyclerview.widget.RecyclerView[@resource-id='id.co.bitcoin:id/rvMarketCoinPairs']
${BUY_AMOUNT_INPUT}              xpath=//android.widget.EditText[@resource-id='id.co.bitcoin:id/edit_buy_amount']
${SELL_AMOUNT_INPUT}             xpath=//android.widget.EditText[@resource-id='id.co.bitcoin:id/edit_sell_amount']
${BUY_SUBMIT_BUTTON}             xpath=//android.widget.Button[@resource-id='id.co.bitcoin:id/button_buy']
${SELL_SUBMIT_BUTTON}            xpath=//android.widget.Button[@resource-id='id.co.bitcoin:id/button_sell']
${BACK_BUTTON}                   xpath=//android.widget.ImageButton[@resource-id='id.co.bitcoin.detail_lite:id/btBackDetail']

*** Keywords ***
Tap Market Tab
    Wait Until Page Contains Element    ${MARKET_TAB_TITLE}    10s
    Click Element    ${MARKET_TAB_TITLE}

Tap Pair Selector
    Wait Until Page Contains Element    ${PAIR_SELECTOR}    10s
    Click Element    ${PAIR_SELECTOR}

Input Pair Search
    [Arguments]    ${pair}
    Wait Until Page Contains Element    ${PAIR_SEARCH_INPUT}    10s
    Input Text    ${PAIR_SEARCH_INPUT}    ${pair}

Tap Pair From List
    [Arguments]    ${pair}
    Wait Until Page Contains Element    ${PAIR_LIST_ROW}    20s
    Click Element    ${PAIR_LIST_ROW}

Get Current Price Text
    Wait Until Page Contains Element    ${CURRENT_PRICE_TEXT}    15s
    ${price_text}=    Get Text    ${CURRENT_PRICE_TEXT}
    RETURN    ${price_text}

Wait For Order Book
    Wait Until Page Contains Element    ${ORDER_BOOK_LIST}    15s

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
