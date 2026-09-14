*** Settings ***
Documentation     DATA-DRIVEN registration: signs up every pending user row
...               from an Excel sheet through the UI (browser actions only, no
...               API). For each row the account is created with the full
...               registration form, login is verified once created, and the
...               account is then deleted to keep the site clean. Execution
...               results (PASS/FAIL with message) are written back to the
...               same Excel file so re-runs pick up only unprocessed rows.

Suite Setup       Initialize Excel Driven Suite
Suite Teardown    Close Browser Session

Force Tags        UI    auth    registration    regression    data-driven

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/workflows/auth_flows.robot
Library           ../../resources/data/excel_manager.py

*** Variables ***
${EXCEL_FILE_PATH}    ${CURDIR}/../../resources/data/test_users.xlsx

*** Test Cases ***
Register All Pending Users From Excel
    [Documentation]    Reads every pending (non-PASS) user row from the Excel
    ...                sheet and completes the full UI signup -> login-verify
    ...                -> delete lifecycle for each one, writing outcome back
    ...                to the sheet.
    [Tags]    regression
    ${failed_emails}=    Create List
    FOR    ${user}    IN    @{EXCEL_USERS}
        TRY
            Register User From Excel    ${user}
            Write Registration Status
            ...    ${EXCEL_FILE_PATH}    ${user}[email]    PASS
            ...    User created, login verified, account cleaned up
        EXCEPT    AS    ${error}
            ${details}=    Evaluate    str($error)
            Run Keyword And Ignore Error
            ...    Write Registration Status    ${EXCEL_FILE_PATH}    ${user}[email]    FAIL    ${details}
            Append To List    ${failed_emails}    ${user}[email]
            Log    Registration FAILED for '${user}[email]': ${details}    WARN
        END
    END
    ${failed_count}=    Get Length    ${failed_emails}
    Run Keyword If    ${failed_count} > 0
    ...    Fail    ${failed_count} user(s) failed signup via UI: ${failed_emails}

*** Keywords ***
Initialize Excel Driven Suite
    [Documentation]    Opens the browser and loads the pending user rows from
    ...                the Excel sheet into the suite-level @{EXCEL_USERS}.
    Open Browser To Home Page
    ${all_users}=    Read User Data From Excel    ${EXCEL_FILE_PATH}
    ${count}=    Get Length    ${all_users}
    Run Keyword If    ${count} == 0
    ...    Fail    No pending user rows found in '${EXCEL_FILE_PATH}' (all already PASS?)
    Set Suite Variable    @{EXCEL_USERS}    @{all_users}
    Log    Loaded ${count} pending signup row(s) from ${EXCEL_FILE_PATH}

Register User From Excel
    [Documentation]    Creates a single user from an Excel row end-to-end via
    ...                pure UI actions: signup form, registration form, account
    ...                confirmation, login-verification, then deletion.
    ...                Retries a couple of times because the site's ad overlays
    ...                intermittently intercept form clicks.
    [Arguments]    ${user}    ${attempts}=2
    FOR    ${attempt}    IN RANGE    ${attempts}
        TRY
            Register User Single Attempt    ${user}
            RETURN
        EXCEPT    AS    ${error}
            Log    Signup attempt ${attempt + 1} failed for '${user}[email]'. Retrying. Error: ${error}    WARN
        END
    END
    Fail    Registration failed for '${user}[email]' after ${attempts} attempts

Register User Single Attempt
    [Documentation]    One UI registration attempt for a single user: signup
    ...                form, registration form, account confirmation,
    ...                login-verification, then deletion.
    [Arguments]    ${user}
    Ensure Anonymous Session
    Go To Signup Login Page
    Start New User Signup    ${user}[name]    ${user}[email]
    Select Checkboxes Via Javascript
    Fill Registration Form
    ...    ${user}[password]    ${user}[first_name]    ${user}[last_name]    ${user}[company]
    ...    ${user}[address1]    ${user}[country]    ${user}[state]    ${user}[city]    ${user}[zipcode]
    ...    ${user}[mobile]
    ...    year=${user}[birth_year]    month=${user}[birth_month]    day=${user}[birth_day]
    ...    select_title=${user}[title]
    Submit Registration Form
    Verify Account Created
    Continue After Account Creation
    User Should Be Logged In As    ${user}[name]
    Delete Current Account

Select Checkboxes Via Javascript
    [Documentation]    Pre-selects the newsletter and special-offers checkboxes
    ...                directly in the DOM. The registration form later calls
    ...                "Select Checkbox", which skips the click when a box is
    ...                already selected - bypassing the ad iframes that
    ...                intermittently cover the page and would intercept a
    ...                normal click.
    Execute JavaScript
    ...    document.getElementById('newsletter').checked = true;
    ...    document.getElementById('optin').checked = true;