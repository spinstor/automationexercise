*** Settings ***
Documentation     Keywords for the Contact us page.

Resource          ../common/variables.robot
Resource          ../common/common_keywords.robot
Resource          ../locators/contact_locators.robot

Library           SeleniumLibrary
Library           BuiltIn

*** Keywords ***
Verify Contact Page Loaded
    [Documentation]    Asserts the contact form is rendered.
    Wait Until Element Is Visible    ${CONTACT_HEADING}
    Wait Until Element Is Visible    ${CONTACT_NAME_INPUT}

Fill Contact Form
    [Documentation]    Fills the contact form fields.
    [Arguments]    ${name}    ${email}    ${subject}    ${message}
    Input Text If Visible    ${CONTACT_NAME_INPUT}    ${name}
    Input Text If Visible    ${CONTACT_EMAIL_INPUT}    ${email}
    Input Text If Visible    ${CONTACT_SUBJECT_INPUT}    ${subject}
    Input Text If Visible    ${CONTACT_MESSAGE_INPUT}    ${message}

Submit Contact Form
    [Documentation]    Submits the contact form and swallows the browser alert.
    Click Element    ${CONTACT_SUBMIT_BUTTON}
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT

Verify Contact Success Message
    [Documentation]    Asserts the confirmation message after submission.
    Wait Until Element Is Visible    ${CONTACT_SUCCESS_MESSAGE}
    Assert Page Contains    Success! Your details have been submitted successfully.