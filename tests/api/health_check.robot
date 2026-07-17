*** Settings ***
Resource    ../../resources/common.resource
Resource    ../../resources/api.resource

Suite Setup       Create API Session
Test Setup        Log Test Start
Test Teardown     Log Test End

*** Test Cases ***
Verify API Is Reachable
    ${response}=    GET On Session
    ...    indodax
    ...    /pairs

    Status Should Be    200    ${response}