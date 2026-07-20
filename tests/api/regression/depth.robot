*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_depth.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression

*** Test Cases ***
Verify Depth With Invalid Pair Returns 404
    ${response}=    Get Depth With Invalid Pair

    Response Status Should Be    ${response}    404


Verify POST Order Book Depth Returns Method Not Allowed
    ${response}=    Post Order Book Depth

    Response Status Should Be    ${response}    405
