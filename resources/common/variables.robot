*** Settings ***
Documentation     Central default variables for the AutomationExercise framework.
...
...               All variables in this file act as DEFAULTS and are used
...               automatically when the framework is executed. Values can be
...               overridden without touching source code using command line
...               options, e.g.:
...
...               robot --variable BROWSER:headlesschrome tests
...
...               For a more advanced configuration layer see the optional
...               config/variables.py file (loaded via --variablefile).

*** Variables ***
${BASE_URL}            https://automationexercise.com
# NOTE: the public API shares the host. All API endpoints already contain
# the /api prefix, e.g. ${API_BASE_URL}/api/productsList
${API_BASE_URL}        https://automationexercise.com

${BROWSER}             chrome
${HEADLESS}            false
${IMPLICIT_WAIT}       20
${PAGE_LOAD_TIMEOUT}   45
${DEFAULT_TIMEOUT}     20
${RETRY_ATTEMPTS}      3

${OUTPUT_DIR}          output
${SCREENSHOT_DIR}      ${OUTPUT_DIR}/screenshots

${TEST_PASSWORD}       Passw0rd!123
${TEST_EMAIL_DOMAIN}   example.com

${VALID_PRODUCT}       Blue Top
${PRODUCT_ID}          1
${QUANTITY}            2