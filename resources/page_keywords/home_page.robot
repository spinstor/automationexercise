*** Settings ***
Documentation     Keywords for interacting with the HOME page. A page-keyword
...               resource exposes reusable actions for ONE page, orchestrated
...               by workflow/resources or directly by test suites.

Resource          ../common/variables.robot
Resource          ../common/common_keywords.robot
Resource          ../locators/home_locators.robot

Library           SeleniumLibrary
Library           BuiltIn

*** Keywords ***
Verify Home Page Is Loaded
    [Documentation]    Asserts the distinguishing elements of the Home page are
    ...                visible (carousel + featured items section).
    Wait Until Element Is Visible    ${HOME_CAROUSEL}
    Wait Until Element Is Visible    ${FEATURES_ITEMS_SECTION}

Verify Home Page Element Displayed
    [Documentation]    Asserts the Given element is visible on the Home page.
    [Arguments]    ${locator}    ${message}=Expected element not visible on Home page
    Wait Until Element Is Visible    ${locator}    message=${message}

Verify Categories Sidebar Displayed
    [Documentation]    Asserts the Category and Brands side bar panels render.
    Wait Until Element Is Visible    ${CATEGORY_HEADING}
    Wait Until Element Is Visible    ${BRANDS_HEADING}

Add Featured Product To Cart
    [Documentation]    Clicks "Add to cart" for the product identified by
    ...                ${product_id} on the featured card and leaves the
    ...                confirmation modal OPEN for the caller to act upon.
    [Arguments]    ${product_id}=${PRODUCT_ID}
    ${locator}=    Set Variable    xpath=//a[contains(@class,'add-to-cart') and @data-product-id='${product_id}']
    Wait Until Element Is Visible And Click    ${locator}
    Verify Add To Cart Modal Displayed

Close Add To Cart Modal
    [Documentation]    Closes the "Added!" confirmation modal (Continue Shopping).
    Wait Until Element Is Visible And Click    ${CONTINUE_SHOPPING_BUTTON}

Verify Add To Cart Modal Displayed
    [Documentation]    Asserts the "Added!" confirmation modal opened.
    Wait Until Element Is Visible    ${CART_MODAL}
    Assert Page Contains    Added!

Open Cart From Added Modal
    [Documentation]    Clicks "View Cart" inside the add-to-cart confirmation modal.
    Wait Until Element Is Visible And Click    ${VIEW_CART_MODAL_LINK}

Subscribe On Home Page
    [Documentation]    Fills the footer Subscription widget and submits it.
    [Arguments]    ${email}
    Scroll Page To Bottom
    Wait Until Element Is Visible    ${SUBSCRIPTION_EMAIL_INPUT}
    Input Text    ${SUBSCRIPTION_EMAIL_INPUT}    ${email}
    Click Element    ${SUBSCRIPTION_SUBMIT}

Verify Subscription Success Message
    [Documentation]    Asserts the footer shows the subscription confirmation.
    Wait Until Element Is Visible    ${SUBSCRIPTION_SUCCESS}
    Assert Element Text Equals    ${SUBSCRIPTION_SUCCESS}
    ...    You have been successfully subscribed!    message=Subscription confirmation missing