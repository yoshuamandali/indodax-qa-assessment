*** Settings ***
Resource    ../../resources/browser.resource

*** Variables ***
# Pro/Classic mode modal (first-visit only)
${MODAL_DIALOG_1}            text=Personalisasi Tampilan Trade
${CLASSIC_MODE_OPTION}       text=Trade Klasik
${SAVE_VIEW_BUTTON}          text=Simpan Tampilan
${MODAL_DIALOG_2}            text=Atur Tampilan Trade Anda
${OKE_BUTTON}                role=button[name='Oke']

# Language toggle (current lang shown as button label)
${LANG_TOGGLE_EN}            role=button[name='EN']
${LANG_TOGGLE_ID}            role=button[name='ID']

# Market page
${PAIR_SEARCH_INPUT}          xpath=//*[@id="searchbox_market"]
${CURRENT_PRICE}              xpath=/html/body/section/div[2]/div[2]/div[4]/div[1]/div[2]/div[1]/div/div[2]/table/tbody/tr[1]/td[1]/strong
${ORDER_BOOK_SELL_TABLE}      table#sell_orders
${ORDER_BOOK_BUY_TABLE}       table#buy_orders

# Trade form
${BUY_AMOUNT_INPUT}          input[name='buy_amount']
${SELL_AMOUNT_INPUT}         input[name='sell_amount']
${BUY_SUBMIT_BUTTON}         role=button[name='Buy']
${BUY_SUBMIT_BUTTON_ID}      text=Beli
${SELL_SUBMIT_BUTTON}        role=button[name='Sell']
${SELL_SUBMIT_BUTTON_ID}     text=Jual

*** Keywords ***
Open Market Page
    Go To    ${BROWSER_URL}

Dismiss Pro Classic Mode Modal
    ${visible1}=    Run Keyword And Return Status    Wait for Elements State    ${MODAL_DIALOG_1}    visible    timeout=5s
    Run Keyword If    ${visible1}    Select Classic Mode
    ${visible2}=    Run Keyword And Return Status    Wait for Elements State    ${MODAL_DIALOG_2}    visible    timeout=5s
    Run Keyword If    ${visible2}    Confirm Second Modal
    # Modal may already be dismissed from previous session — that's OK, continue

Select Classic Mode
    Click    ${CLASSIC_MODE_OPTION}
    Click    ${SAVE_VIEW_BUTTON}

Confirm Second Modal
    Click    ${OKE_BUTTON}

Switch Language To English
    ${visible}=    Run Keyword And Return Status    Wait for Elements State    ${LANG_TOGGLE_EN}    visible    timeout=2s
    Run Keyword If    ${visible}    Click    ${LANG_TOGGLE_EN}

Click Pair Selector
    # Search input always visible in Classic mode — no toggle button
    No Operation

Type Pair Search
    [Arguments]    ${pair}
    Fill Text    ${PAIR_SEARCH_INPUT}    ${pair}

Select Pair From Dropdown
    [Arguments]    ${pair}
    ${row}=    Set Variable    ${PAIR_LIST_ROW} >> text=/${pair}/i
    Click    ${row}

Get Current Price
    ${price_text}=    Get Text    ${CURRENT_PRICE}
    RETURN    ${price_text}

Get Order Book Row Count
    ${sell_rows}=    Get Element Count    ${ORDER_BOOK_SELL_TABLE} >> tr
    ${buy_rows}=    Get Element Count    ${ORDER_BOOK_BUY_TABLE} >> tr
    ${rows}=    Evaluate    ${sell_rows} + ${buy_rows}
    RETURN    ${rows}

Fill Buy Amount
    [Arguments]    ${amount}
    Fill Text    ${BUY_AMOUNT_INPUT}    ${amount}

Fill Sell Amount
    [Arguments]    ${amount}
    Fill Text    ${SELL_AMOUNT_INPUT}    ${amount}

Click Buy Submit
    ${clicked}=    Run Keyword And Ignore Error    Click    ${BUY_SUBMIT_BUTTON}
    Run Keyword If    '${clicked}[0]' == 'FAIL'    Click    ${BUY_SUBMIT_BUTTON_ID}

Click Sell Submit
    ${clicked}=    Run Keyword And Ignore Error    Click    ${SELL_SUBMIT_BUTTON}
    Run Keyword If    '${clicked}[0]' == 'FAIL'    Click    ${SELL_SUBMIT_BUTTON_ID}
