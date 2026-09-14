*** Settings ***
Documentation     Framework-wide generic keywords used by every other layer.
...
...               These keywords wrap SeleniumLibrary with retry/robustness
...               behaviour so that lower layers and tests stay short, readable
...               and free of duplication.

Library           SeleniumLibrary
Library           BuiltIn
Library           Collections
Library           String
Library           ../data/data_manager.py

*** Keywords ***
Wait Until Element Is Visible And Click
    [Documentation]    Waits for an element to be present/visible then clicks it.
    ...                Retries on transient failures and falls back to a
    ...                JavaScript click when the element is intercepted by an
    ...                overlapping node (common on this site's product cards).
    ...                FAILS after ${RETRY_ATTEMPTS} unsuccessful attempts.
    [Arguments]    ${locator}    ${timeout}=${DEFAULT_TIMEOUT}
    ${attempt}=    Set Variable    0
    ${clicked}=    Set Variable    False
    WHILE    ${attempt} < ${RETRY_ATTEMPTS}
        TRY
            Wait Until Element Is Visible    ${locator}    timeout=${timeout}
            Scroll Element Into View    ${locator}
            Click Element    ${locator}
            ${clicked}=    Set Variable    True
            BREAK
        EXCEPT    AS    ${error}
            ${msg}=    Evaluate    str($error)
            IF    "intercept" in $msg.lower()
                Log    Element click intercepted, falling back to JS click    WARN
                Click Element With Javascript    ${locator}
                ${clicked}=    Set Variable    True
                BREAK
            ELSE
                Log    Click attempt ${attempt} failed: ${msg}    WARN
            END
        END
        ${attempt}=    Evaluate    ${attempt} + 1
    END
    Run Keyword If    not ${clicked}    Fail    Failed to click '${locator}' after ${RETRY_ATTEMPTS} attempts

Click Element With Javascript
    [Documentation]    Clicks an element via the WebDriver JavaScript executor,
    ...                bypassing overlay/visibility intercepts.
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${element}

Input Text If Visible
    [Documentation]    Clears and types into an input only after confirming it is
    ...                visible, avoiding flakiness on hidden/lazy fields.
    [Arguments]    ${locator}    ${text}    ${timeout}=${DEFAULT_TIMEOUT}
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Input Text    ${locator}    ${text}

Click Element If Visible
    [Documentation]    Clicks a button/link only when it is visible on screen,
    ...                otherwise logs and skips gracefully.
    [Arguments]    ${locator}    ${timeout}=5
    ${visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${timeout}    error=N/A
    IF    ${visible}
        Click Element    ${locator}
    END

Assert Element Text Equals
    [Documentation]    Fetches an element's text and asserts it equals the expected
    ...                value, normalizing whitespace to avoid brittle failures.
    [Arguments]    ${locator}    ${expected}    ${message}=Element text mismatch
    ${actual}=    Get Text    ${locator}
    ${actual}=    Normalize Text For Comparison    ${actual}
    ${expected}=    Normalize Text For Comparison    ${expected}
    Should Be Equal As Strings    ${actual}    ${expected}    msg=${message}

Normalize Text For Comparison
    [Documentation]    Collapses whitespace (tabs, repeated spaces, line breaks)
    ...                into a single space before string comparison.
    [Arguments]    ${text}
    ${text}=    Replace String Using Regexp    ${text}    \\s+    ${SPACE}
    ${text}=    Strip String    ${text}
    RETURN    ${text}

Assert Page Contains
    [Documentation]    Asserts an expected text is present on the current page
    ...                with a readable failure message.
    [Arguments]    ${text}    ${timeout}=${DEFAULT_TIMEOUT}
    Wait Until Page Contains    ${text}    timeout=${timeout}
    Page Should Contain    ${text}

Assert Page Does Not Contain
    [Documentation]    Asserts an unexpected text is absent on the current page.
    [Arguments]    ${text}    ${timeout}=3
    ${present}=    Run Keyword And Return Status    Page Should Contain    ${text}
    Should Not Be True    ${present}    msg=Unexpected text '${text}' found on page

Wait Until Page Is Loaded
    [Documentation]    Waits for the document ready-state to settle after navigation,
    ...                guarding against early assertions racing the page load.
    Wait Until Keyword Succeeds    1 min    2 s    Page Ready State Should Be Complete
    Log    Page ready-state reported complete

Page Ready State Should Be Complete
    [Documentation]    Fails unless the document ready state is 'complete'.
    ${state}=    Execute JavaScript    return document.readyState
    Should Be Equal    ${state}    complete    msg=Page not fully loaded, readyState=${state}

Scroll Page To Bottom
    [Documentation]    Scrolls the current page to the very bottom, used e.g. to
    ...                reach the Subscription area of the footer.
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)

Scroll Page To Top
    [Documentation]    Returns the scroll position to the top of the page.
    Execute JavaScript    window.scrollTo(0, 0)

Get Current Url
    [Documentation]    Convenience wrapper returning the current browser location.
    ${location}=    Get Location
    RETURN    ${location}