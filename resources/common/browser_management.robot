*** Settings ***
Documentation     Keywords responsible for browser SESSION lifecycle and
...               consistent WebDriver configuration across every suite.
...
...               Every UI suite imports this resource and uses
...               "Open Browser To Home Page" in its Suite Setup and
...               "Close Browser Session" in its Suite Teardown. Keeping the
...               WebDriver configuration in ONE place guarantees a consistent,
...               maintainable execution setup.
...
...               BROWSER value may be any of: chrome, firefox, edge,
...               headlesschrome, headlessfirefox, headlessedge.

Library           SeleniumLibrary

*** Keywords ***
Open Browser To Home Page
    [Documentation]    Creates a WebDriver using the centrally configured
    ...                browser profile and navigates to the application home.
    ${effective_browser}=    Resolve Browser Flavour
    ${profile_dir}=    Create Fresh Profile Dir    ${effective_browser}
    ${options}=    Get Browser Options    ${effective_browser}    ${profile_dir}
    Open Browser    ${BASE_URL}    browser=${effective_browser}    options=${options}
    Set Global Timeouts
    Wait Until Element Is Visible    css=#header
    IF    $profile_dir != ''
        Set Suite Variable    ${SELENIUM_PROFILE_DIR}    ${profile_dir}
    END

Resolve Browser Flavour
    [Documentation]    Returns the effective browser value honouring the
    ...                ${HEADLESS} flag when set to true.
    ${effective}=    Set Variable    ${BROWSER}
    IF    '${HEADLESS}' == 'true'
        ${effective}=    Evaluate    'headless' + '${BROWSER}' if not str('${BROWSER}').startswith('headless') else '${BROWSER}'
    END
    RETURN    ${effective}

Get Browser Options
    [Documentation]    Builds the WebDriver options string for a browser flavour.
    ...                ${profile_dir} is an isolated Chrome profile used only by
    ...                HEADED runs so a session never clashes with a user's own
    ...                running Chrome (prevents DevToolsActivePort errors).
    [Arguments]    ${browser}    ${profile_dir}=${EMPTY}
    ${options}=    Set Variable    add_argument("--start-maximized")
    IF    $browser == 'chrome' and $profile_dir != ''
        ${options}=    Set Variable    add_argument("--start-maximized");add_argument("--user-data-dir=${profile_dir}");add_argument("--remote-debugging-port=0")
    END
    IF    '${browser}' == 'headlesschrome'
        ${options}=    Set Variable    add_argument("--headless=new");add_argument("--window-size=1280,800");add_argument("--disable-gpu");add_argument("--no-sandbox")
    END
    IF    '${browser}' == 'headlessfirefox'
        ${options}=    Set Variable    add_argument("--headless");add_argument("--window-size=1280,800")
    END
    IF    '${browser}' == 'headlessedge'
        ${options}=    Set Variable    add_argument("--headless");add_argument("--window-size=1280,800")
    END
    RETURN    ${options}

Set Global Timeouts
    [Documentation]    Applies the framework-wide wait/timeout values to the WebDriver.
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT} seconds
    Set Selenium Timeout    ${DEFAULT_TIMEOUT} seconds

Close Browser Session
    [Documentation]    Safely closes every browser opened by the suite.
    Run Keyword And Ignore Error    Close All Browsers
    Run Keyword And Ignore Error    Remove Selenium Profile Dir

Take Screenshot On Failure
    [Documentation]    Captures a page screenshot automatically when the executing
    ...                test FAILS. Register this keyword through the suite-level
    ...                "Test Teardown" setting so it runs after every test.
    ...
    ...                usage (suite Settings):
    ...                    Test Teardown       Take Screenshot On Failure
    ...                    Suite Teardown      Close Browser Session
    Run Keyword If Test Failed    Capture Page Screenshot

Create Fresh Profile Dir
    [Documentation]    Returns a brand-new temporary Chrome profile directory
    ...                (forward-slash path) for HEADED runs, or ${EMPTY} when the
    ...                browser does not need an isolated profile.
    [Arguments]    ${browser}
    IF    '${browser}' == 'chrome'
        ${dir}=    Evaluate    tempfile.mkdtemp(prefix='selenium_pf_').replace(chr(92), '/')    modules=tempfile
    ELSE
        ${dir}=    Set Variable    ${EMPTY}
    END
    RETURN    ${dir}

Remove Selenium Profile Dir
    [Documentation]    Best-effort cleanup of the temporary Chrome profile directory.
    ${dir}=    Get Variable Value    ${SELENIUM_PROFILE_DIR}
    IF    $dir != ${None} and $dir != ''
        Evaluate    shutil.rmtree('${dir}', ignore_errors=True)    modules=shutil
    END