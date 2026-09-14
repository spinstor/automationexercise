*** Settings ***
Documentation     Logout coverage: after logout the session becomes anonymous
...               and the Signup / Login page is shown.

Suite Setup       Open Browser To Home Page
Test Setup         Ensure Anonymous Session
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    auth    logout    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/workflows/auth_flows.robot

*** Test Cases ***
Login Then Logout Returns To Anonymous State
    [Documentation]    A full round trip: register -> logout -> login -> logout.
    [Tags]    smoke
    Register A New User
    Logout Current User
    Go To Signup Login Page
    Login With Credentials    ${NEW_USER_EMAIL}    ${TEST_PASSWORD}
    Verify Login Success
    Logout Current User
    User Header Should Be Empty