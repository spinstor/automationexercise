*** Settings ***
Documentation     Keywords for the Checkout and Payment flow.

Resource          ../common/variables.robot
Resource          ../common/common_keywords.robot
Resource          ../locators/checkout_locators.robot

Library           SeleniumLibrary
Library           BuiltIn

*** Keywords ***
Verify Order Review Section
    [Documentation]    Asserts checkout rendered the address + review sections.
    Wait Until Element Is Visible    ${ADDRESS_DELIVERY_SECTION}
    Wait Until Element Is Visible    ${REVIEW_ORDER_HEADING}
    Wait Until Page Contains Element    ${ORDER_TABLE}

Add Comment To Order
    [Documentation]    Types an optional comment into the checkout textarea.
    [Arguments]    ${comment}
    Input Text If Visible    ${COMMENT_TEXTAREA}    ${comment}

Place Order
    [Documentation]    Clicks "Place Order" to open the payment form.
    Wait Until Element Is Visible And Click    ${PLACE_ORDER_BUTTON}
    Wait Until Element Is Visible    ${PAYMENT_SUBMIT_BUTTON}

Fill Payment Details
    [Documentation]    Populates the payment card form.
    [Arguments]    ${name}    ${card_number}    ${cvc}    ${month}    ${year}
    Input Text If Visible    ${PAYMENT_NAME_ON_CARD}    ${name}
    Input Text If Visible    ${PAYMENT_CARD_NUMBER}    ${card_number}
    Input Text If Visible    ${PAYMENT_CVC}    ${cvc}
    Input Text If Visible    ${PAYMENT_EXPIRY_MONTH}    ${month}
    Input Text If Visible    ${PAYMENT_EXPIRY_YEAR}    ${year}

Confirm Payment
    [Documentation]    Submits the payment form.
    Click Element    ${PAYMENT_SUBMIT_BUTTON}

Verify Order Placed
    [Documentation]    Asserts the order confirmation page and message appear.
    Wait Until Element Is Visible    ${ORDER_CONFIRMATION_TEXT}
    Assert Page Contains    Congratulations! Your order has been confirmed!