*** Settings ***
Documentation     Application-wide navigation keywords. The global header is
...               present on every page, so navigation lives in a single,
...               shared component resource.

Library           SeleniumLibrary

*** Variables ***
${NAV_HOME_LINK}             xpath=//header//a[@href='/']
${NAV_PRODUCTS_LINK}         xpath=//header//a[@href='/products']
${NAV_CART_LINK}             xpath=//header//a[@href='/view_cart']
${NAV_SIGNUP_LOGIN_LINK}     xpath=//header//a[@href='/login']
${NAV_LOGOUT_LINK}           xpath=//header//a[@href='/logout']
${NAV_CONTACT_LINK}          xpath=//header//a[@href='/contact_us']
${NAV_LOGGED_IN_USER}        xpath=//header//ul/li//b

*** Keywords ***
Navigate To Application Home
    [Documentation]    Hard-navigates the browser to ${BASE_URL}, guaranteeing a
    ...                known starting point for every test. Used as Test Setup
    ...                so tests are independent of each other's previous state.
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    css=#header

Go To Home Page
    [Documentation]    Navigates to the Home page using the global header.
    Click Element    ${NAV_HOME_LINK}
    Wait Until Page Contains Element    css=#header

Go To Products Page
    [Documentation]    Navigates to the Products page using the global header.
    Click Element    ${NAV_PRODUCTS_LINK}
    Wait Until Page Contains Element    css=#search_product

Go To Cart Page
    [Documentation]    Navigates to the Cart page using the global header.
    Click Element    ${NAV_CART_LINK}
    Wait Until Page Contains Element    css=#cart_info_table

Nav Logout Link Should Not Be Visible
    [Documentation]    Asserts the account Logout link is absent (anonymous session).
    Run Keyword And Expect Error    ERROR:*    Element Should Be Visible    ${NAV_LOGOUT_LINK}

Ensure Anonymous Session
    [Documentation]    Drops any logged-in session client-side (cookies, local and
    ...                session storage) and lands on the clean Home page. Needed
    ...                because the site redirects already-authenticated visitors
    ...                away from /login, so tests that must reach the login page
    ...                after another test has signed in require a fresh session.
    Delete All Cookies
    Execute JavaScript    window.localStorage.clear()
    Execute JavaScript    window.sessionStorage.clear()
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    css=#header

Go To Signup Login Page
    [Documentation]    Navigates to the Signup / Login page, reaching it directly by
    ...                URL instead of the header link (the header only shows
    ...                "Signup / Login" for anonymous sessions, so clicking it
    ...                fails once the user is logged in).
    Go To    ${BASE_URL}/login
    Wait Until Page Contains Element    css=.login-form

Go To Contact Us Page
    [Documentation]    Navigates to the Contact us page using the global header.
    Click Element    ${NAV_CONTACT_LINK}
    Wait Until Page Contains Element    css=#contact-us-form

Get Logged In User Name
    [Documentation]    Returns the name of the currently logged-in user as
    ...                displayed in the global header, or ${EMPTY} if anonymous.
    ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${NAV_LOGGED_IN_USER}
    IF    not ${visible}
        RETURN    ${EMPTY}
    END
    ${name}=    Get Text    ${NAV_LOGGED_IN_USER}
    RETURN    ${name}

User Should Be Logged In As
    [Documentation]    Asserts the user displayed in the header matches ${expected}.
    [Arguments]    ${expected}
    ${actual}=    Get Logged In User Name
    Run Keyword If    '${actual}' != '${expected}'
    ...    Fail    Expected logged-in user '${expected}' but header shows '${actual}'.

User Header Should Be Empty
    [Documentation]    Asserts no user name is shown in the header (anonymous session).
    ${actual}=    Get Logged In User Name
    Run Keyword If    '${actual}' != '${EMPTY}'
    ...    Fail    Header still shows user '${actual}', anonymous session expected.