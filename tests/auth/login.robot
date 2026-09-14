*** Settings ***
Documentation     Login coverage: valid credentials and invalid credentials.
...
...               Account SETUP is performed through the API so the UI test can
...               focus on the login behaviour alone (fast + robust).
...
...               When MongoDB is reachable, ${LOGIN_EMAIL}/${LOGIN_PASSWORD}
...               from config\mongo_login.py are used for the valid-credentials
...               test; otherwise a throw-away account is generated.

Variables          ../../config/mongo_login.py

Suite Setup       Open Browser To Home Page
Test Setup         Ensure Anonymous Session
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    auth    login    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/page_keywords/auth_page.robot
Resource          ../../resources/api/api_keywords.robot

*** Test Cases ***
Login With Valid Credentials
    [Documentation]    A registered user can log in and the header shows the name.
    ...                Uses the stored MongoDB credentials when launched with
    ...                bin\run_mongo.cmd; otherwise provisions a throw-away
    ...                account through the API.
    [Tags]    smoke    kasira
    ${mongo_email}=    Get Variable Value    ${LOGIN_EMAIL}
    IF    $mongo_email != ${None}
        ${expected_name}=    Ensure Account Exists Via Api
        ...    ${LOGIN_NAME}    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
        Go To Signup Login Page
        Login With Credentials    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
        Verify Login Success
        User Should Be Logged In As    ${expected_name}
    ELSE
        Create Test Account Through Api
        Go To Signup Login Page
        Login With Credentials    ${TEST_ACCOUNT_EMAIL}    ${TEST_PASSWORD}
        Verify Login Success
        User Should Be Logged In As    ${TEST_ACCOUNT_NAME}
    END

Login With Invalid Credentials
    [Documentation]    Wrong credentials must fail with the expected error text.
    [Tags]    regression
    Go To Signup Login Page
    ${random_email}=    Get Unique Email    prefix=invalid
    Login With Credentials    ${random_email}    wrong-password
    Verify Login Error Displayed

*** Keywords ***
Create Test Account Through Api
    [Documentation]    Creates a throw-away account via the API and stores its
    ...                credentials for the UI login step.
    Create Api Session
    ${name}=    Get Unique Name
    ${email}=    Get Unique Email    prefix=ui.login
    ${response}=    Create Account Via Api    ${name}    ${email}
    Api Response Code Should Be    ${response}    201
    Delete Api Session
    Set Test Variable    ${TEST_ACCOUNT_NAME}    ${name}
    Set Test Variable    ${TEST_ACCOUNT_EMAIL}    ${email}