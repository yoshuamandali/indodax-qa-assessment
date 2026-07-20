*** Settings ***
Library    AppiumLibrary
Library    String

*** Keywords ***
Element Should Be Visible Within Timeout
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Page Contains Element    ${locator}    timeout=${timeout}

Current Price Should Be Numeric And Positive
    [Arguments]    ${price_text}
    ${cleaned}=    Replace String    ${price_text}    ,    ${EMPTY}
    Should Match Regexp    ${cleaned}    ^\\d+(\\.\\d+)?
    ${price}=    Convert To Number    ${cleaned}
    Should Be True    ${price} > 0    msg=Expected price > 0, got ${price}
