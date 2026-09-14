*** Settings ***
Documentation     Contact us form coverage.

Suite Setup       Open Browser To Home Page
Test Setup         Navigate To Application Home
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    contact    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/page_keywords/contact_page.robot
Resource          ../../resources/data/test_data.robot

*** Test Cases ***
Submit Contact Form Shows Success Message
    [Documentation]    Filling the full contact form and submitting yields the
    ...                success confirmation.
    [Tags]    smoke
    ${random_email}=    Get Unique Email    prefix=contact
    Go To Contact Us Page
    Verify Contact Page Loaded
    Fill Contact Form
    ...    ${TEST_FIRST_NAME}    ${random_email}    Automated subject line
    ...    Automated body for the contact us form.
    Submit Contact Form
    Verify Contact Success Message