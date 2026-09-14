*** Settings ***
Documentation     Page object LOCATORS for the Checkout and Payment flow
...               (/checkout and /payment).
...
...               Rule: LOCATORS ONLY - no keywords in this file.

*** Variables ***
# ---------------------------------------------------------------------------
# Checkout page (/checkout)
# ---------------------------------------------------------------------------
${CHECKOUT_HEADING}            xpath=//h2[contains(text(), 'Checkout')]
${ADDRESS_DELIVERY_SECTION}    xpath=//h2[contains(@class, 'heading') and contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'address details')]
${REVIEW_ORDER_HEADING}        xpath=//h2[contains(@class, 'heading') and contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'review your order')]
${ORDER_TABLE}                 css=#cart_info
${PRODUCT_NAME_IN_ORDER}       css=#cart_info td.cart_description h4 a
${COMMENT_TEXTAREA}            css=textarea[name=message]
${PLACE_ORDER_BUTTON}          css=a.check_out

# ---------------------------------------------------------------------------
# Payment page (/payment)
# ---------------------------------------------------------------------------
${PAYMENT_HEADING}             xpath=//h2[contains(text(), 'Payment')]
${PAYMENT_NAME_ON_CARD}        css=input[data-qa=name-on-card]
${PAYMENT_CARD_NUMBER}         css=input[data-qa=card-number]
${PAYMENT_CVC}                 css=input[data-qa=cvc]
${PAYMENT_EXPIRY_MONTH}        css=input[data-qa=expiry-month]
${PAYMENT_EXPIRY_YEAR}         css=input[data-qa=expiry-year]
${PAYMENT_SUBMIT_BUTTON}       css=button[data-qa=pay-button]
${ORDER_SUCCESS_MESSAGE}       xpath=//div[contains(@class, 'alert-success')]
${ORDER_CONFIRMATION_TEXT}     xpath=//p[contains(., 'Congratulations! Your order has been confirmed!')]
${DOWNLOAD_INVOICE_LINK}       css=a[href='/download_invoice']
${ORDER_PLACED_CONTINUE}       css=a[data-qa=continue-button]