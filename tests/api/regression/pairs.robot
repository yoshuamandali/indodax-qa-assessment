*** Settings ***
Resource    ../../../keywords/api/api_session.resource
Resource    ../../../keywords/api/api_pairs.resource
Resource    ../../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    regression


*** Test Cases ***
Verify Invalid Endpoint Returns 404
    ${response}=    Get Invalid Trading Pairs Endpoint

    Response Status Should Be    ${response}    404


Verify POST Method Returns 405
    ${response}=    Post Trading Pairs

    Response Status Should Be    ${response}    405