*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    https://indodax.com/api

*** Keywords ***
Create API Session
    Create Session
    ...    indodax
    ...    ${BASE_URL}