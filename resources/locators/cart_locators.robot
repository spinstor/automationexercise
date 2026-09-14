*** Settings ***
Documentation     Page object LOCATORS for the Shopping Cart page (/view_cart).
...
...               Rule: LOCATORS ONLY - no keywords in this file.

*** Variables ***
${CART_TABLE}                  css=#cart_info_table
${CART_ITEM_ROWS}              css=#cart_info_table tbody tr
${CART_ITEM_NAME}              css=td.cart_description h4 a
${CART_ITEM_PRICE}             css=td.cart_price p
${CART_ITEM_QUANTITY}          css=td.cart_quantity button
${CART_ITEM_TOTAL}             css=td.cart_total p
${CART_ITEM_DELETE}            css=td.cart_delete a.cart_quantity_delete
${CART_EMPTY_MESSAGE}          css=#empty_cart p
${PROCEED_TO_CHECKOUT_BUTTON}  css=a.check_out
${CART_PAGE_HEADING}           xpath=//div[@id='cart_info']//h2