*** Settings ***
Documentation     BUSINESS FLOW keywords for the Shopping Cart story.

Resource          ../common/variables.robot
Resource          ../common/navigation.robot
Resource          ../page_keywords/home_page.robot
Resource          ../page_keywords/product_page.robot
Resource          ../page_keywords/cart_page.robot

*** Keywords ***
Prepare Clean Cart
    [Documentation]    Empties the cart completely and opens the Home page,
    ...                guaranteeing an isolated starting point for every cart test
    ...                (the cart is stored client-side and would otherwise carry
    ...                over between tests in the same suite session).
    Empty Cart
    Navigate To Application Home

Add Product To Cart From Home
    [Documentation]    Adds a product to the cart directly from the Home page
    ...                feature slider and keeps the confirmation modal open.
    [Arguments]    ${product_id}=${PRODUCT_ID}
    Add Featured Product To Cart    ${product_id}

Add Product To Cart From Catalog
    [Documentation]    Adds a product to the cart from the Products catalogue.
    [Arguments]    ${product_id}=${PRODUCT_ID}
    Go To Products Page
    ${locator}=    Set Variable    xpath=//a[contains(@class,'add-to-cart') and @data-product-id='${product_id}']
    Wait Until Element Is Visible And Click    ${locator}
    Verify Add To Cart Modal Displayed

Open Cart And Verify Product Added
    [Documentation]    Opens the cart through the modal and asserts the expected
    ...                product is listed.
    [Arguments]    ${expected_product}=${VALID_PRODUCT}
    Open Cart From Added Modal
    Verify Product Present In Cart    ${expected_product}

Add Products And Open Cart
    [Documentation]    Adds several products (default: two) then opens the cart.
    ...                The confirmation modal is closed between adds so each
    ...                product is added from a clean state (avoids races where
    ...                a second add is swallowed by the still-open modal).
    [Arguments]    ${first_product}=${PRODUCT_ID}    ${second_product}=2
    Add Product To Cart From Home    ${first_product}
    Close Add To Cart Modal
    Add Product To Cart From Home    ${second_product}
    Go To    ${BASE_URL}/view_cart
    Verify Cart Page Loaded

Remove Product From Cart And Verify
    [Documentation]    Removes a product and asserts only what remains.
    [Arguments]    ${product_name}    ${expected_remaining}=0
    Remove Product From Cart    ${product_name}
    IF    '${expected_remaining}' == '0'
        Verify Cart Is Empty
    END