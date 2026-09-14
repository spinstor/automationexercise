*** Settings ***
Documentation     End-to-end purchase coverage: register, add to cart,
...               place the order and confirm it.

Suite Setup       Open Browser To Home Page
Test Setup         Navigate To Application Home
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    checkout    e2e    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/workflows/auth_flows.robot
Resource          ../../resources/workflows/cart_flows.robot
Resource          ../../resources/workflows/checkout_flows.robot

*** Test Cases ***
Register Add To Cart And Place Order
    [Documentation]    Full happy path: a new user registers, adds a product,
    ...                checks out and receives the order confirmation.
    [Tags]    smoke
    Register A New User
    Add Product To Cart From Home
    Open Cart And Verify Product Added    ${VALID_PRODUCT}
    Purchase Current Cart Contents
    Delete Current Account