*** Keywords ***
Log Info
    [Arguments]    ${message}

    Log    ${message}
    Log To Console    ${message}


Log Separator
    Log Info    =====================================


Log API Request
    [Arguments]    ${method}    ${endpoint}

    Log Separator
    Log Info    API REQUEST
    Log Info    Method : ${method}
    Log Info    Endpoint : ${endpoint}
    Log Separator


Log API Response
    [Arguments]    ${response}

    Log Separator
    Log Info    API RESPONSE
    Log Info    Status : ${response.status_code}

    ${time}=    Evaluate    round(${response.elapsed.total_seconds()} * 1000, 2)
    Log Info    Response Time : ${time} ms

    Log Info    Headers : ${response.headers}
    Log Info    Body :
    Log Info    ${response.text}
    Log Separator