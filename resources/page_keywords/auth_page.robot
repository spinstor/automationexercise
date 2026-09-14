*** Settings ***
Documentation     Keywords for the Authentication area: login, new-user signup
...               and the full Registration (account information) form.

Resource          ../common/variables.robot
Resource          ../common/common_keywords.robot
Resource          ../locators/auth_locators.robot

Library           SeleniumLibrary
Library           BuiltIn
Library           Collections

*** Keywords ***
Verify Login Page Loaded
    [Documentation]    Asserts the Login and New User Signup forms are ready.
    Wait Until Element Is Visible    ${LOGIN_FORM}
    Wait Until Element Is Visible    ${SIGNUP_FORM}

Login With Credentials
    [Documentation]    Performs a login using the given email and password.
    [Arguments]    ${email}    ${password}
    Input Text If Visible    ${LOGIN_EMAIL_INPUT}    ${email}
    Input Text If Visible    ${LOGIN_PASSWORD_INPUT}    ${password}
    Click Element    ${LOGIN_BUTTON}

Verify Login Success
    [Documentation]    Asserts the account menu (/logout & user name) is visible
    ...                after a successful login.
    Wait Until Page Contains Element    css=a[href='/logout']

Verify Login Error Displayed
    [Documentation]    Asserts the login failure message is shown.
    Wait Until Element Is Visible    ${LOGIN_ERROR_MESSAGE}
    Assert Element Text Equals    ${LOGIN_ERROR_MESSAGE}
    ...    Your email or password is incorrect!    message=Login error was not displayed

Start New User Signup
    [Documentation]    Fills the New User Signup form on the login page.
    [Arguments]    ${name}    ${email}
    Input Text If Visible    ${SIGNUP_NAME_INPUT}    ${name}
    Input Text If Visible    ${SIGNUP_EMAIL_INPUT}    ${email}
    Click Element    ${SIGNUP_BUTTON}

Verify Signup Error Displayed
    [Documentation]    Asserts the duplicate-email signup error is shown.
    Wait Until Element Is Visible    ${SIGNUP_ERROR_MESSAGE}
    Assert Element Text Equals    ${SIGNUP_ERROR_MESSAGE}
    ...    Email Address already exist!    message=Duplicate email error was not displayed

Fill Registration Form
    [Documentation]    Populates the whole Account Information + Address form.
    [Arguments]    ${password}    ${first_name}    ${last_name}    ${company}
    ...            ${address1}    ${country}    ${state}    ${city}    ${zipcode}
    ...            ${mobile}    ${year}=1990    ${select_title}=Mr    ${month}=January    ${day}=15
    Run Keyword If    '${select_title}' == 'Mr'    Click Element    ${TITLE_MR_RADIO}
    ...    ELSE    Click Element    ${TITLE_MRS_RADIO}
    Input Text    ${REGISTRATION_PASSWORD}    ${password}
    Select From List By Value    ${DAY_SELECT}    ${day}
    Select From List By Label    ${MONTH_SELECT}    ${month}
    Select From List By Value    ${YEAR_SELECT}    ${year}
    Select Checkbox    ${NEWSLETTER_CHECKBOX}
    Select Checkbox    ${SPECIAL_OFFERS_CHECKBOX}
    Input Text    ${FIRST_NAME_INPUT}    ${first_name}
    Input Text    ${LAST_NAME_INPUT}    ${last_name}
    Input Text    ${COMPANY_INPUT}    ${company}
    Input Text    ${ADDRESS1_INPUT}    ${address1}
    Select From List By Label    ${COUNTRY_SELECT}    ${country}
    Input Text    ${STATE_INPUT}    ${state}
    Input Text    ${CITY_INPUT}    ${city}
    Input Text    ${ZIPCODE_INPUT}    ${zipcode}
    Input Text    ${MOBILE_NUMBER_INPUT}    ${mobile}

Submit Registration Form
    [Documentation]    Submits the completed registration form.
    Click Element    ${CREATE_ACCOUNT_BUTTON}

Verify Account Created
    [Documentation]    Asserts the account was created successfully.
    Wait Until Element Is Visible    ${ACCOUNT_CREATED_HEADING}
    Assert Page Contains    Account Created!

Continue After Account Creation
    [Documentation]    Clicks Continue on the Account Created confirmation page.
    Wait Until Element Is Visible And Click    ${CONTINUE_BUTTON}

Delete Account
    [Documentation]    Deletes the currently logged-in account.
    Wait Until Element Is Visible And Click    ${DELETE_ACCOUNT_LINK}

Verify Account Deleted
    [Documentation]    Asserts the account deletion confirmation page appears.
    Wait Until Element Is Visible    ${ACCOUNT_DELETED_HEADING}
    Assert Page Contains    Account Deleted!

Continue After Account Deletion
    [Documentation]    Clicks Continue on the Account Deleted confirmation page.
    Wait Until Element Is Visible And Click    ${CONTINUE_BUTTON}