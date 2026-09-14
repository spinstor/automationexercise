*** Settings ***
Documentation     Product catalogue coverage: browsing and searching.

Suite Setup       Open Browser To Home Page
Test Setup         Navigate To Application Home
Test Teardown      Take Screenshot On Failure
Suite Teardown     Close Browser Session

Force Tags        UI    products    regression

Resource          ../../resources/common/variables.robot
Resource          ../../resources/common/browser_management.robot
Resource          ../../resources/common/common_keywords.robot
Resource          ../../resources/common/navigation.robot
Resource          ../../resources/page_keywords/product_page.robot

*** Test Cases ***
Browse All Products From Catalogue
    [Documentation]    The catalogue page lists products for browsing.
    [Tags]    smoke
    Go To Products Page
    Verify Products Page Loaded
    Verify Featured Products Visible    minimum_expected=1

Search Valid Product Returns Results
    [Documentation]    Searching a known product name yields matching cards.
    [Tags]    smoke
    Go To Products Page
    Search Product On Catalog    ${VALID_PRODUCT}
    Verify Search Results    ${VALID_PRODUCT}

Search Unknown Term Returns No Results
    [Documentation]    Searching gibberish must not match any product.
    [Tags]    regression
    Go To Products Page
    Search Product On Catalog    zzzz-nonsense-product
    Verify No Search Results