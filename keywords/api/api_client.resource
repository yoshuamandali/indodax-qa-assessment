*** Settings ***
Resource    api_session.resource
Resource    ../utils/logger.resource

*** Keywords ***
Execute GET Request
    [Arguments]    ${endpoint}    ${expected_status}=any

    Log API Request    GET    ${endpoint}

    ${response}=    GET On Session
    ...    indodax
    ...    ${endpoint}
    ...    expected_status=${expected_status}

    Log API Response    ${response}

    RETURN    ${response}


Execute POST Request
    [Arguments]    ${endpoint}    ${body}=${None}    ${expected_status}=any

    Log API Request    POST    ${endpoint}

    ${response}=    POST On Session
    ...    indodax
    ...    ${endpoint}
    ...    json=${body}
    ...    expected_status=${expected_status}

    Log API Response    ${response}

    RETURN    ${response}


Execute PUT Request
    [Arguments]    ${endpoint}    ${body}=${None}    ${expected_status}=any

    Log API Request    PUT    ${endpoint}

    ${response}=    PUT On Session
    ...    indodax
    ...    ${endpoint}
    ...    json=${body}
    ...    expected_status=${expected_status}

    Log API Response    ${response}

    RETURN    ${response}


Execute DELETE Request
    [Arguments]    ${endpoint}    ${expected_status}=any

    Log API Request    DELETE    ${endpoint}

    ${response}=    DELETE On Session
    ...    indodax
    ...    ${endpoint}
    ...    expected_status=${expected_status}

    Log API Response    ${response}

    RETURN    ${response}