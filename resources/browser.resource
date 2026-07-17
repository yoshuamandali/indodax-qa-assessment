*** Settings ***
Library    Browser

*** Variables ***
${BROWSER}    chromium
${HEADLESS}   False

*** Keywords ***
Open Browser Session
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context
    New Page

Close Browser Session
    Close Browser