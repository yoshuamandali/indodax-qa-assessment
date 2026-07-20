*** Settings ***
Resource    ../../keywords/api/api_session.resource
Resource    ../../keywords/api/api_pairs.resource
Resource    ../../keywords/assertions/api_assertions.resource

Suite Setup    Initialize API Session

Test Tags    api    smoke

*** Test Cases ***
Verify API Is Reachable
    ${response}=    Get Trading Pairs

    Response Status Should Be    ${response}    200