*** Settings ***
Documentation     Smoke & regression coverage for the HOME page.
...
...               Covers page identity, the sidebar (Categories/Brands) and
...               the footer Subscription widget.

Suite Setup       Open Browser To Home Page
Test Setup         Navigate To Application Home
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    home    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/page_keywords/home_page.robot
Library           SeleniumLibrary

*** Test Cases ***
Verify Home Page Title And Header
    [Documentation]    Sanity check that the application loads with the expected
    ...                title and the global header is present.
    [Tags]    smoke
    Verify Home Page Is Loaded
    ${title}=    Get Title
    Should Be Equal    ${title}    Automation Exercise
    Wait Until Page Contains Element    css=#header

Verify Categories And Brands Sidebar Displayed
    [Documentation]    The Home page must show the Category and Brands side bar.
    [Tags]    smoke
    Verify Categories Sidebar Displayed

Verify Footer Subscription Shows Success
    [Documentation]    Subscribing with a valid email should display the footer
    ...                confirmation banner.
    [Tags]    regression
    ${email}=    Get Unique Email    prefix=subscriber
    Subscribe On Home Page    ${email}
    Verify Subscription Success Message