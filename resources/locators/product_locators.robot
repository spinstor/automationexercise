*** Settings ***
Documentation     Page object LOCATORS for the Products area: the products
...               grid (/products), Brand/Category filtered views and the
...               Product Details page (/product_details/{id}).
...
...               Product relative identifiers such as ${PRODUCT_ID} are
...               expected to be injected from the caller before use, e.g. via
...               resource/variables or Set Test Variable.

*** Variables ***
# ---------------------------------------------------------------------------
# Products page (/products)
# ---------------------------------------------------------------------------
${PRODUCTS_HEADING}            xpath=//div[contains(@class,'features_items')]//h2
${PRODUCT_GRID}                css=.features_items
${PRODUCT_SEARCH_INPUT}        css=#search_product
${PRODUCT_SEARCH_BUTTON}       css=#submit_search
${PRODUCT_ITEM}                css=.product-image-wrapper
${PRODUCT_ITEM_NAME}           css=.productinfo p
${PRODUCT_ITEM_PRICE}          css=.productinfo h2
${ALL_PRODUCTS_HEADING}        xpath=//h2[contains(text(), 'All Products')]

# ---------------------------------------------------------------------------
# Product Details page (/product_details/{id})
# ---------------------------------------------------------------------------
${PRODUCT_NAME_HEADING}        css=.product-information h2
${PRODUCT_CATEGORY_LABEL}      xpath=//p[contains(text(), 'Category:')]
${PRODUCT_PRICE_LABEL}         css=.product-information span span
${PRODUCT_AVAILABILITY}        xpath=//p[contains(., 'Availability:')]
${PRODUCT_CONDITION}           xpath=//p[contains(., 'Condition:')]
${PRODUCT_BRAND}               xpath=//p[contains(., 'Brand:')]
${PRODUCT_DETAILS_SECTION}     css=.product-information
${QUANTITY_INPUT}              css=#quantity
${PRODUCT_ID_HIDDEN}           css=#product_id
${ADD_TO_CART_DETAILS_BUTTON}  css=.product-information button.cart
${REVIEWS_HEADING}             xpath=//a[contains(text(), 'Write Your Review')]