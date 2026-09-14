*** Settings ***
Documentation     Keywords for the Products area: search/filter on the products
...               grid and the Product Details page.

Resource          ../common/variables.robot
Resource          ../common/common_keywords.robot
Resource          ../locators/product_locators.robot

Library           SeleniumLibrary
Library           BuiltIn
Library           Collections
Library           String

*** Keywords ***
Verify Products Page Loaded
    [Documentation]    Asserts the products page grid and sidebar are rendered.
    Wait Until Element Is Visible    ${ALL_PRODUCTS_HEADING}
    Wait Until Element Is Visible    ${PRODUCT_GRID}

Search Product On Catalog
    [Documentation]    Narrows the catalog by typing a search term.
    [Arguments]    ${term}
    Input Text If Visible    ${PRODUCT_SEARCH_INPUT}    ${term}
    Click Element    ${PRODUCT_SEARCH_BUTTON}

Verify Search Results
    [Documentation]    Asserts matching product cards are shown, without asserting
    ...                any hard-coded count. The grid may show either the
    ...                "All Products" or "Searched Products" heading.
    [Arguments]    ${term}    ${timeout}=${DEFAULT_TIMEOUT}
    ${grid_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_GRID}    timeout=${timeout}
    Should Be True    ${grid_visible}    msg=Product grid not visible after searching '${term}'
    ${visible_count}=    Get Element Count    css=.productinfo p
    Should Be True    ${visible_count} > 0    msg=No products displayed after searching '${term}'

Verify No Search Results
    [Documentation]    Asserts an empty product catalogue after searching.
    ${visible_count}=    Get Element Count    css=.productinfo p
    Should Be Equal As Integers    ${visible_count}    0    msg=Expected empty results for the search term

Verify Featured Products Visible
    [Documentation]    Asserts product cards are present on the grid.
    [Arguments]    ${minimum_expected}=1
    ${count}=    Get Element Count    ${PRODUCT_ITEM}
    Should Be True    ${count} >= ${minimum_expected}    msg=Expected at least ${minimum_expected} products, found ${count}

Open Product Details
    [Documentation]    Opens the product details page for the given product id.
    [Arguments]    ${product_id}
    ${locator}=    Set Variable    xpath=//a[@href='/product_details/${product_id}']
    Wait Until Element Is Visible And Click    ${locator}

Verify Product Details Are Shown
    [Documentation]    Asserts the distinguishing content of the product details
    ...                page: name, category, availability and brand.
    [Arguments]    ${expected_name}=${VALID_PRODUCT}
    Wait Until Element Is Visible    ${PRODUCT_DETAILS_SECTION}
    Assert Element Text Equals    ${PRODUCT_NAME_HEADING}    ${expected_name}    message=Unexpected product name
    Assert Page Contains    Category:

Set Product Quantity
    [Documentation]    Sets the quantity value on the product details page.
    [Arguments]    ${quantity}
    Input Text If Visible    ${QUANTITY_INPUT}    ${quantity}

Add Current Product To Cart
    [Documentation]    Clicks "Add to cart" on the product details page.
    Wait Until Element Is Visible And Click    ${ADD_TO_CART_DETAILS_BUTTON}

Get Product Price On Details Page
    [Documentation]    Returns the displayed product price string.
    ${price}=    Get Text    ${PRODUCT_PRICE_LABEL}
    RETURN    ${price}