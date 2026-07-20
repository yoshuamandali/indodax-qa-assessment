*** Settings ***
Library    BuiltIn

*** Keywords ***
Execute Keyword With Retry
    [Arguments]    ${retry}=3    ${interval}=2s    ${keyword}    @{args}

    Wait Until Keyword Succeeds
    ...    ${retry}
    ...    ${interval}
    ...    ${keyword}
    ...    @{args}