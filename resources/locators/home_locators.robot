*** Settings ***
Documentation     Page object LOCATORS for the Home page (/).
...
...               Rule: LOCATORS ONLY - no keywords in this file.

*** Variables ***
# ---------------------------------------------------------------------------
# Page identity / layout
# ---------------------------------------------------------------------------
${HOME_CAROUSEL}               css=#slider-carousel
${HOME_HEADING}                xpath=//div[contains(@class, 'active')]//h2

# ---------------------------------------------------------------------------
# Side bar sections
# ---------------------------------------------------------------------------
${CATEGORY_SECTION}            xpath=//div[@class='left-sidebar']//following-sibling::div[1]/h2[text()='Category'] | //h2[text()='Category']
${CATEGORY_HEADING}            xpath=//h2[text()='Category']
${BRANDS_HEADING}              xpath=//h2[text()='Brands']
${CATEGORY_PRODUCTS}           css=div#accordian .panel-heading .panel-title a

# ---------------------------------------------------------------------------
# Featured products
# ---------------------------------------------------------------------------
${FEATURES_ITEMS_SECTION}      css=.features_items
${FEATURES_ITEMS_HEADING}      xpath=//div[contains(@class,'features_items')]//h2
${PRODUCT_CARD}                css=.product-image-wrapper
${PRODUCT_TITLE}               css=.productinfo p
${PRODUCT_PRICE}               css=.productinfo h2
${ADD_TO_CART_BUTTON}          xpath=//a[contains(@class,'add-to-cart') and @data-product-id='${PRODUCT_ID}']
${VIEW_PRODUCT_LINK}           xpath=//a[@href='/product_details/${PRODUCT_ID}']

# ---------------------------------------------------------------------------
# Add-to-cart confirmation modal
# ---------------------------------------------------------------------------
${CART_MODAL}                  css=#cartModal .modal-content
${ADDED_MODAL_HEADING}         xpath=//h4[contains(text(), 'Added!')]
${VIEW_CART_MODAL_LINK}        xpath=//div[@id='cartModal']//a[contains(@href, '/view_cart')]
${CONTINUE_SHOPPING_BUTTON}    xpath=//div[@id='cartModal']//button[contains(@class, 'close-modal')]

# ---------------------------------------------------------------------------
# Footer Subscription component
# ---------------------------------------------------------------------------
${SUBSCRIPTION_EMAIL_INPUT}    css=#susbscribe_email
${SUBSCRIPTION_SUBMIT}         css=#subscribe
${SUBSCRIPTION_SUCCESS}        css=#success-subscribe .alert-success