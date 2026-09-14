*** Settings ***
Documentation     Keywords for testing the AutomationExercise public REST API.
...
...               API under test:  ${API_BASE_URL}  (defaults to
...               https://automationexercise.com/api). All responses are
...               expected to carry { "responseCode": <int>, "message": <str> }.

Library           RequestsLibrary
Library           Collections
Library           BuiltIn
Resource          ../data/test_data.robot

*** Variables ***
${API_SESSION_ALIAS}    aeapi

*** Keywords ***
Create Api Session
    [Documentation]    Opens a requests session against ${API_BASE_URL}.
    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    Create Session    ${API_SESSION_ALIAS}    ${API_BASE_URL}    headers=${headers}    verify=True
    Log    API session created: ${API_BASE_URL}

Delete Api Session
    [Documentation]    Closes and removes the API session.
    Run Keyword And Ignore Error    Delete All Sessions

Get Products List Via Api
    [Documentation]    Returns the full products catalogue response.
    ${response}=    GET On Session    ${API_SESSION_ALIAS}    /api/productsList
    RETURN    ${response}

Get Brands List Via Api
    [Documentation]    Returns the brands catalogue response.
    ${response}=    GET On Session    ${API_SESSION_ALIAS}    /api/brandsList
    RETURN    ${response}

Search Product Via Api
    [Documentation]    Searches products by name using the search endpoint.
    [Arguments]    ${term}
    &{payload}=    Create Dictionary    search_product=${term}
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /api/searchProduct    data=${payload}
    RETURN    ${response}

Verify Login Via Api
    [Documentation]    Performs a login verification request.
    [Arguments]    ${email}=${EMPTY}    ${password}=${EMPTY}
    &{payload}=    Create Dictionary    email=${email}    password=${password}
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /api/verifyLogin    data=${payload}
    RETURN    ${response}

Create Account Via Api
    [Documentation]    Creates a new account through the API. Success returns
    ...                code 201 with message "User created!". A duplicate email
    ...                returns code 200 with an "already exists" message.
    [Arguments]    ${name}    ${email}    ${password}=${TEST_PASSWORD}    ${first_name}=${TEST_FIRST_NAME}
    &{payload}=    Create Dictionary
    ...    name=${name}    email=${email}    password=${password}    title=${TEST_TITLE}
    ...    birth_date=${DOB_DAY}    birth_month=${DOB_MONTH}    birth_year=${DOB_YEAR}
    ...    firstname=${first_name}    lastname=${TEST_LAST_NAME}    company=${TEST_COMPANY}
    ...    address1=${TEST_ADDRESS1}    address2=${TEST_ADDRESS2}    country=${TEST_COUNTRY}
    ...    zipcode=${TEST_ZIPCODE}    state=${TEST_STATE}    city=${TEST_CITY}
    ...    mobile_number=${TEST_MOBILE}
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /api/createAccount    data=${payload}
    RETURN    ${response}

Get User Detail Via Api
    [Documentation]    Retrieves account details for an email.
    [Arguments]    ${email}
    &{payload}=    Create Dictionary    email=${email}
    ${response}=    GET On Session    ${API_SESSION_ALIAS}    /api/getUserDetailByEmail    params=${payload}
    RETURN    ${response}

Delete Account Via Api
    [Documentation]    Deletes the account bound to an email / password pair.
    [Arguments]    ${email}
    &{payload}=    Create Dictionary    email=${email}    password=${TEST_PASSWORD}
    ${response}=    DELETE On Session    ${API_SESSION_ALIAS}    /api/deleteAccount    data=${payload}
    RETURN    ${response}

Api Response Code Should Be
    [Documentation]    Asserts the 'responseCode' field of the JSON payload.
    [Arguments]    ${response}    ${expected_code}    ${message}=Unexpected API response code
    ${json}=    Get Response Json    ${response}
    ${code}=    Get From Dictionary    ${json}    responseCode
    Should Be Equal As Strings    ${code}    ${expected_code}    msg=${message} (got ${code})

Api Response Message Should Be
    [Documentation]    Asserts the 'message' field of the JSON payload.
    [Arguments]    ${response}    ${expected_message}    ${message}=Unexpected API message
    ${json}=    Get Response Json    ${response}
    ${actual}=    Get From Dictionary    ${json}    message
    Should Be Equal As Strings    ${actual}    ${expected_message}    msg=${message} (got "${actual}")

Get Response Json
    [Documentation]    Returns the parsed JSON body of a requests response.
    [Arguments]    ${response}
    ${json}=    Evaluate    $response.json()
    RETURN    ${json}

Api Response Code From Json
    [Documentation]    Returns the 'responseCode' value as a string.
    [Arguments]    ${response}
    ${json}=    Get Response Json    ${response}
    ${code}=    Get From Dictionary    ${json}    responseCode
    RETURN    ${code}

Api Response Message From Json
    [Documentation]    Returns the 'message' value of the JSON payload.
    [Arguments]    ${response}
    ${json}=    Get Response Json    ${response}
    ${message}=    Get From Dictionary    ${json}    message
    RETURN    ${message}

Ensure Account Exists Via Api
    [Documentation]    Idempotently makes sure an account with the given
    ...                credentials exists on the site: it creates it via the
    ...                API when needed and tolerates responses for an
    ...                already-existing account so it is safe to run
    ...                repeatedly. Useful when credentials are provisioned
    ...                externally (e.g. MongoDB).
    ...
    ...                RETURNS the authoritative display name to assert against
    ...                after a UI login: the site's stored name for accounts
    ...                that already existed, otherwise the given ${name}.
    [Arguments]    ${name}    ${email}    ${password}=${TEST_PASSWORD}
    Create Api Session
    ${response}=    Create Account Via Api    ${name}    ${email}    ${password}
    ${code}=    Api Response Code From Json    ${response}
    ${message}=    Api Response Message From Json    ${response}
    IF    '${code}' in ['200', '201']
        Log    createAccount (${code}): ${message} for ${email}
        ${site_name}=    Set Variable    ${name}
    ELSE IF    '${code}' == '400' and 'already exists' in '${message}'.lower()
        Log    createAccount (${code}): ${message} for ${email}
        Log    Account already provisioned; reading its real name from the API.    WARN
        ${site_name}=    Get Site Account Name Via Api    ${email}
    ELSE
        Fail    createAccount returned unexpected responseCode ${code} with message: ${message}
    END
    Delete Api Session
    RETURN    ${site_name}

Get Site Account Name Via Api
    [Documentation]    Returns the display name the site stores for an email.
    [Arguments]    ${email}
    ${response}=    Get User Detail Via Api    ${email}
    ${code}=    Api Response Code From Json    ${response}
    IF    '${code}' != '200'
        Fail    getUserDetailByEmail returned responseCode ${code} for ${email}
    END
    ${json}=    Get Response Json    ${response}
    ${user}=    Get From Dictionary    ${json}    user
    ${site_name}=    Get From Dictionary    ${user}    name
    RETURN    ${site_name}

Api Should Contain Product
    [Documentation]    Asserts the products payload contains a product named ${name}.
    [Arguments]    ${response}    ${name}
    ${json}=    Get Response Json    ${response}
    ${products}=    Get From Dictionary    ${json}    products
    ${found}=    Evaluate    any(p['name'] == '${name}' for p in $products)
    Should Be True    ${found}    msg=Product '${name}' not present in API response