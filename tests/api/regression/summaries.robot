*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_summaries.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression

*** Test Cases ***
Verify Invalid Summaries Endpoint Returns 404
    ${response}=    Get Invalid Summaries Endpoint

    Response Status Should Be    ${response}    404


Verify POST Summaries Returns Method Not Allowed
    ${response}=    Post Summaries

    Response Status Should Be    ${response}    405
