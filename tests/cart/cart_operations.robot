*** Settings ***
Documentation     Shopping Cart coverage: adding, verifying, counting and
...               removing products.

Suite Setup       Open Browser To Home Page
Test Setup         Prepare Clean Cart
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    cart    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/workflows/cart_flows.robot

*** Test Cases ***
Add Product To Cart From Home And Verify
    [Documentation]    A featured product added on Home must appear in the cart.
    [Tags]    smoke
    Add Product To Cart From Home
    Open Cart And Verify Product Added    ${VALID_PRODUCT}

Add Multiple Products Shows Correct Count
    [Documentation]    Adding two different products results in two cart rows.
    [Tags]    regression
    Add Products And Open Cart    ${PRODUCT_ID}    2
    ${row_count}=    Get Cart Row Count
    Should Be Equal As Integers    ${row_count}    2    msg=Expected 2 cart rows, found ${row_count}

Remove Product Empties The Cart
    [Documentation]    Removing the only product leaves the empty-cart message.
    [Tags]    regression
    Add Product To Cart From Home
    Open Cart And Verify Product Added    ${VALID_PRODUCT}
    Remove Product From Cart And Verify    ${VALID_PRODUCT}    0