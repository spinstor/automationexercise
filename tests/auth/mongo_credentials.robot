*** Settings ***
Documentation     Login coverage driven by credentials sourced from MongoDB.
...
...               The login email/password come from the first ENABLED document
...               in the robot_auth.users collection, injected through the
...               config/mongo_login.py variablefile:
...
...                   bin\run_mongo.cmd tests\auth\mongo_credentials.robot
...
...               The account is ensured on the site through the API (idempotent)
...               so the credentials you seed in MongoDB are the ones that log in.

Variables          ../../config/mongo_login.py

Suite Setup       Validate Mongo Credentials And Open Home Page
Test Setup         Ensure Anonymous Session
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    auth    login    mongo    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/page_keywords/auth_page.robot
Resource          ../../resources/api/api_keywords.robot

*** Test Cases ***
Login With Mongo Stored Credentials
    [Documentation]    Logs in with the credentials that MongoDB provides and
    ...                asserts the account menu shows the account's display
    ...                name (the site's real name for existing accounts).
    [Tags]    smoke
    ${expected_name}=    Ensure Account Exists Via Api
    ...    ${LOGIN_NAME}    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    Go To Signup Login Page
    Login With Credentials    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    Verify Login Success
    User Should Be Logged In As    ${expected_name}

*** Keywords ***
Validate Mongo Credentials And Open Home Page
    [Documentation]    Fails fast with a helpful message when the Mongo
    ...                variablefile was not supplied, then opens the browser.
    Variable Should Exist    ${LOGIN_EMAIL}    msg=LOGIN_EMAIL not defined. Run with: bin\run_mongo.cmd tests\auth\mongo_credentials.robot --variablefile config\mongo_login.py
    Variable Should Exist    ${LOGIN_PASSWORD}    msg=LOGIN_PASSWORD not defined - is the MongoDB connection string correct? See README on MongoDB connections.
    Variable Should Exist    ${LOGIN_NAME}    msg=LOGIN_NAME not defined - add a "name" field to the enabled users document.
    Open Browser To Home Page