*** Settings ***
Documentation     BUSINESS FLOW keywords for the Checkout / Payment story and the
...               full end-to-end purchase journey.

Resource          ../common/variables.robot
Resource          ../page_keywords/cart_page.robot
Resource          ../page_keywords/checkout_page.robot
Resource          ../data/test_data.robot
Library           ../data/data_manager.py

*** Keywords ***
Fill And Pay Order
    [Documentation]    Places the order with the standard payment dataset and
    ...                asserts the confirmation.
    [Arguments]    ${comment}=${ORDER_COMMENT}
    Add Comment To Order    ${comment}
    Place Order
    Fill Payment Details
...    ${PAYMENT_NAME}    ${PAYMENT_CARD_VALUE}    ${PAYMENT_CVC_VALUE}
...    ${PAYMENT_EXPIRY_MONTH_VALUE}    ${PAYMENT_EXPIRY_YEAR_VALUE}
    Confirm Payment
    Verify Order Placed

Purchase Current Cart Contents
    [Documentation]    High level purchase flow that proceeds from the cart to
    ...                a confirmed order.
    Proceed To Checkout
    Verify Order Review Section
    Fill And Pay Order
    Log    Order placed successfully