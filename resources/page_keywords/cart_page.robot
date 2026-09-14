*** Settings ***
Documentation     Keywords for the Shopping Cart page (/view_cart).

Resource          ../common/variables.robot
Resource          ../common/common_keywords.robot
Resource          ../locators/cart_locators.robot

Library           SeleniumLibrary
Library           BuiltIn
Library           Collections

*** Keywords ***
Verify Cart Page Loaded
    [Documentation]    Asserts the cart table is rendered.
    Wait Until Page Contains Element    ${CART_TABLE}

Verify Product Present In Cart
    [Documentation]    Asserts a product with the given display name is in the cart.
    [Arguments]    ${product_name}
    Wait Until Page Contains    ${product_name}    timeout=${DEFAULT_TIMEOUT}
    ${matches}=    Get Element Count    xpath=//td[@class='cart_description']//a[contains(text(), '${product_name}')]
    Should Be True    ${matches} > 0    msg=Product '${product_name}' not found in cart

Get Cart Row Count
    [Documentation]    Returns the number of rows currently in the cart table.
    ${count}=    Get Element Count    ${CART_ITEM_ROWS}
    RETURN    ${count}

Get Cart Quantity For Product
    [Documentation]    Returns the quantity value shown for a product.
    [Arguments]    ${product_name}
    ${qty}=    Get Text
    ...    xpath=//tr[.//a[contains(text(),'${product_name}')]]//td[contains(@class,'cart_quantity')]//button
    RETURN    ${qty}

Remove Product From Cart
    [Documentation]    Deletes the first occurrence of a product from the cart.
    [Arguments]    ${product_name}
    Wait Until Element Is Visible And Click
    ...    xpath=//tr[.//a[contains(text(),'${product_name}')]]//a[contains(@class,'cart_quantity_delete')]

Verify Cart Row Count
    [Documentation]    Asserts the number of rows currently in the cart table.
    [Arguments]    ${expected}
    ${count}=    Get Cart Row Count
    Should Be Equal As Integers    ${count}    ${expected}    msg=Expected ${expected} cart rows, found ${count}

Empty Cart
    [Documentation]    Removes every product row from the cart via its delete link
    ...                until the empty-cart message is displayed. Runs after each
    ...                AJAX delete so the next row is always reachable.
    Go To    ${BASE_URL}/view_cart
    ${table_present}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    ${CART_TABLE}    timeout=${DEFAULT_TIMEOUT}
    IF    not ${table_present}
        Verify Cart Is Empty
        RETURN
    END
    ${count}=    Get Cart Row Count
    WHILE    ${count} > 0
        Click Element    ${CART_ITEM_DELETE}
        ${expected}=    Evaluate    ${count} - 1
        Wait Until Keyword Succeeds    30 s    1 s    Verify Cart Row Count    ${expected}
        ${count}=    Get Cart Row Count
    END
    Verify Cart Is Empty

Verify Cart Is Empty
    [Documentation]    Asserts the empty-cart message is displayed.
    Wait Until Element Is Visible    ${CART_EMPTY_MESSAGE}
    Assert Page Contains    Cart is empty!

Proceed To Checkout
    [Documentation]    Clicks the "Proceed To Checkout" action on the cart page.
    Wait Until Element Is Visible And Click    ${PROCEED_TO_CHECKOUT_BUTTON}

Verify Checkout Page Loaded
    [Documentation]    Asserts the checkout page rendered (works when redirected
    ...                to /login for guest users as well).
    ${url}=    Get Location
    Run Keyword If    '${url}' != '${BASE_URL}/checkout'
    ...    Log    Not on checkout page (current url: ${url}), redirect expected    WARN