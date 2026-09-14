*** Settings ***
Documentation     API smoke coverage for the AutomationExercise public API.
...
...               Reference: https://automationexercise.com/api_list
...
...               These tests do NOT require a browser and can run on any
...               agent (CI included) that has network access.

Suite Setup       Create Api Session
Suite Teardown    Delete Api Session

Force Tags        API    smoke    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/api/api_keywords.robot
Library           ../../resources/data/data_manager.py

*** Test Cases ***
Get All Products List
    [Documentation]    API 1: GET /api/productsList returns the full catalogue.
    ${response}=    Get Products List Via Api
    Api Response Code Should Be    ${response}    200
    Api Should Contain Product    ${response}    ${VALID_PRODUCT}

POST To Products List Is Not Supported
    [Documentation]    API 2: POST method must be rejected with 405.
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /api/productsList
    Api Response Code Should Be    ${response}    405    message=POST /productsList should be rejected

Get All Brands List
    [Documentation]    API 3: GET /api/brandsList returns brands.
    ${response}=    Get Brands List Via Api
    Api Response Code Should Be    ${response}    200

Search Product With Valid Term
    [Documentation]    API 5: POST /api/searchProduct returns matching products.
    ${response}=    Search Product Via Api    ${VALID_PRODUCT}
    Api Response Code Should Be    ${response}    200
    Api Should Contain Product    ${response}    ${VALID_PRODUCT}

Search Product Without Parameter Is Rejected
    [Documentation]    API 6: missing search_product parameter yields 400.
    &{empty_payload}=    Create Dictionary
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /api/searchProduct    data=${empty_payload}
    Api Response Code Should Be    ${response}    400    message=Empty search should be rejected

Verify Login With Valid Credentials
    [Documentation]    API 7: valid email/password is resolved to "User exists!".
    ${name}=    Get Unique Name
    ${email}=    Get Unique Email    prefix=verify
    ${created}=    Create Account Via Api    ${name}    ${email}
    Api Response Code Should Be    ${created}    201
    ${response}=    Verify Login Via Api    ${email}    ${TEST_PASSWORD}
    Api Response Code Should Be    ${response}    200    message=Valid login should succeed
    Api Response Message Should Be    ${response}    User exists!

Verify Login With Invalid Credentials
    [Documentation]    API 10: unknown email must yield "User not found!".
    ${email}=    Get Unique Email    prefix=notexists
    ${response}=    Verify Login Via Api    ${email}    wrong-password
    Api Response Code Should Be    ${response}    404    message=Invalid login should fail
    Api Response Message Should Be    ${response}    User not found!

Verify Login Without Email Is Rejected
    [Documentation]    API 8: omitting the email parameter yields a 400 bad request.
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /api/verifyLogin    data=password=${TEST_PASSWORD}
    Api Response Code Should Be    ${response}    400    message=Missing email should be rejected

DELETE On Verify Login Is Not Supported
    [Documentation]    API 9: DELETE method must not be supported.
    ${response}=    DELETE On Session    ${API_SESSION_ALIAS}    /api/verifyLogin
    Api Response Code Should Be    ${response}    405    message=DELETE /verifyLogin should be rejected

Account Lifecycle Create Get And Delete
    [Documentation]    API 11/12/14: create, fetch details and delete an account.
    ${name}=    Get Unique Name
    ${email}=    Get Unique Email    prefix=lifecycle
    ${created}=    Create Account Via Api    ${name}    ${email}
    Api Response Code Should Be    ${created}    201    message=Account should be created
    Api Response Message Should Be    ${created}    User created!
    ${details}=    Get User Detail Via Api    ${email}
    Api Response Code Should Be    ${details}    200    message=Fetching account details failed
    ${deleted}=    Delete Account Via Api    ${email}
    Api Response Code Should Be    ${deleted}    200    message=Account should be deleted
    Api Response Message Should Be    ${deleted}    Account deleted!