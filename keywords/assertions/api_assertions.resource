*** Settings ***
Library    Collections
Library    ../../libraries/schema_validator.py

*** Keywords ***
Response Status Should Be
    [Arguments]    ${response}    ${expected}

    Should Be Equal As Integers
    ...    ${response.status_code}
    ...    ${expected}
    ...    Expected HTTP ${expected}, but got ${response.status_code}


Response Body Should Not Be Empty
    [Arguments]    ${response}

    Should Not Be Empty
    ...    ${response.text}
    ...    Response body is empty.


Response Header Should Exist
    [Arguments]    ${response}    ${header}

    Dictionary Should Contain Key
    ...    ${response.headers}
    ...    ${header}


Response Header Should Be
    [Arguments]    ${response}    ${header}    ${expected}

    Should Be Equal
    ...    ${response.headers['${header}']}
    ...    ${expected}


Response Content Type Should Be JSON
    [Arguments]    ${response}

    Should Contain
    ...    ${response.headers['Content-Type']}
    ...    application/json


Response Time Should Be Less Than
    [Arguments]    ${response}    ${milliseconds}

    ${elapsed}=    Set Variable    ${response.elapsed.total_seconds() * 1000}

    Log    Response Time: ${elapsed} ms

    Should Be True
    ...    ${elapsed} < ${milliseconds}
    ...    Response time ${elapsed} ms exceeded ${milliseconds} ms.


Response Should Match Schema
    [Arguments]
    ...    ${response}
    ...    ${schema}

    Validate Schema
    ...    ${response.text}
    ...    ${schema}


JSON Should Contain Key
    [Arguments]
    ...    ${response}
    ...    ${key}

    ${json}=    Evaluate
    ...    ${response.json()}

    Dictionary Should Contain Key
    ...    ${json}
    ...    ${key}