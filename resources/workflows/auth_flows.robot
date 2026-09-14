*** Settings ***
Documentation     BUSINESS FLOW keywords for the Authentication story:
...               registration, login, logout and account lifecycle.
...
...               These keywords orchestrate multiple page keywords and produce
...               high-level, readable operations for the test suites.

Resource          ../common/variables.robot
Resource          ../common/navigation.robot
Resource          ../page_keywords/auth_page.robot
Resource          ../data/test_data.robot
Library           ../data/data_manager.py

*** Variables ***
${NEW_USER_NAME}       ${EMPTY}
${NEW_USER_EMAIL}      ${EMPTY}

*** Keywords ***
Get A Unique Email
    [Documentation]    Convenience wrapper returning a unique address.
    ${email}=    Get Unique Email
    RETURN    ${email}

Get A Unique Name
    [Documentation]    Convenience wrapper returning a random first name.
    ${name}=    Get Unique Name
    RETURN    ${name}

Register A New User
    [Documentation]    Creates a new user end-to-end (signup form, account
    ...                information form, confirmation) and persists the
    ...                generated credentials as suite variables
    ...                ${NEW_USER_NAME} / ${NEW_USER_EMAIL}.
    [Arguments]    ${name}=${EMPTY}    ${email}=${EMPTY}
    IF    '${name}' == '${EMPTY}'
        ${name}=    Get Unique Name
    END
    IF    '${email}' == '${EMPTY}'
        ${email}=    Get Unique Email
    END
    Go To Signup Login Page
    Start New User Signup    ${name}    ${email}
    Fill And Submit Registration Form
    Verify Account Created
    Continue After Account Creation
    Set Suite Variable    ${NEW_USER_NAME}    ${name}
    Set Suite Variable    ${NEW_USER_EMAIL}    ${email}
    Log    New user registered: ${name} <${email}>

Fill And Submit Registration Form
    [Documentation]    Populates the registration form with the shared dataset
    ...                and submits it.
    Fill Registration Form
    ...    ${TEST_PASSWORD}    ${TEST_FIRST_NAME}    ${TEST_LAST_NAME}    ${TEST_COMPANY}
    ...    ${TEST_ADDRESS1}    ${TEST_COUNTRY}    ${TEST_STATE}    ${TEST_CITY}    ${TEST_ZIPCODE}    ${TEST_MOBILE}
    ...    year=${DOB_YEAR}    month=${DOB_MONTH}    day=${DOB_DAY}
    Submit Registration Form

Login As Previously Created User
    [Documentation]    Logs in with the suite-level credentials produced by
    ...                "Register A New User".
    Login With Credentials    ${NEW_USER_EMAIL}    ${TEST_PASSWORD}
    Verify Login Success
    User Should Be Logged In As    ${NEW_USER_NAME}

Register Then Logout User
    [Documentation]    Registers a fresh user, logs out immediately, and leaves
    ...                the credentials available for later login.
    Register A New User
    Logout Current User

Logout Current User
    [Documentation]    Clicks logout from the account menu and asserts the
    ...                session is anonymous.
    Wait Until Element Is Visible And Click    ${NAV_LOGOUT_LINK}
    Wait Until Page Contains Element    ${SIGNUP_NAME_INPUT}
    User Header Should Be Empty

Delete Current Account
    [Documentation]    Deletes the account of the logged-in user, then continues.
    Delete Account
    Verify Account Deleted
    Continue After Account Deletion