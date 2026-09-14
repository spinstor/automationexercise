*** Settings ***
Documentation     Product Details coverage.

Suite Setup       Open Browser To Home Page
Test Setup         Navigate To Application Home
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    products    product-details    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/page_keywords/product_page.robot
Resource          ../../resources/page_keywords/home_page.robot

*** Test Cases ***
View Product Details Shows Expected Data
    [Documentation]    Opening a product's details page displays its name,
    ...                category, availability and brand.
    [Tags]    smoke
    Go To Home Page
    Open Product Details    ${PRODUCT_ID}
    Verify Product Details Are Shown    expected_name=${VALID_PRODUCT}

Set Quantity And Add Product To Cart
    [Documentation]    Quantity can be increased before adding to the cart and
    ...                the confirmation modal is displayed.
    [Tags]    regression
    Go To Home Page
    Open Product Details    ${PRODUCT_ID}
    Set Product Quantity    ${QUANTITY}
    Add Current Product To Cart
    Verify Add To Cart Modal Displayed