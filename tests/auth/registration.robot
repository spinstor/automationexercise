*** Settings ***
Documentation     Registration coverage: successful signup of a new account and
...               rejection of a duplicate (existing) email address.

Suite Setup       Open Browser To Home Page
Test Setup         Ensure Anonymous Session
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    auth    registration    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/workflows/auth_flows.robot

*** Test Cases ***
Register New User Successfully
    [Documentation]    A unique e-mail must allow full registration and produce
    ...                the "Account Created!" confirmation.
    [Tags]    smoke
    Register A New User
    User Should Be Logged In As    ${NEW_USER_NAME}

Cannot Register With Existing Email
    [Documentation]    Re-using a registered email must surface the
    ...                "Email Address already exist!" error.
    [Tags]    regression
    Register A New User
    Logout Current User
    Start New User Signup    ${NEW_USER_NAME}    ${NEW_USER_EMAIL}
    Verify Signup Error Displayed