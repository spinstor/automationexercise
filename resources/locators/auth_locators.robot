*** Settings ***
Documentation     Page object LOCATORS for the Authentication area
...               (Login, New User Signup and the Registration form).
...
...               Rule: LOCATORS ONLY - no keywords in this file.

*** Variables ***
# ---------------------------------------------------------------------------
# Login form
# ---------------------------------------------------------------------------
${LOGIN_FORM}                  css=.login-form
${LOGIN_EMAIL_INPUT}           css=input[data-qa=login-email]
${LOGIN_PASSWORD_INPUT}        css=input[data-qa=login-password]
${LOGIN_BUTTON}                css=button[data-qa=login-button]
${LOGIN_ERROR_MESSAGE}         css=.login-form p

# ---------------------------------------------------------------------------
# New User Signup form
# ---------------------------------------------------------------------------
${SIGNUP_FORM}                 css=.signup-form
${SIGNUP_NAME_INPUT}           css=input[data-qa=signup-name]
${SIGNUP_EMAIL_INPUT}          css=input[data-qa=signup-email]
${SIGNUP_BUTTON}               css=button[data-qa=signup-button]
${SIGNUP_ERROR_MESSAGE}        xpath=//div[contains(@class, 'signup-form')]//p

# ---------------------------------------------------------------------------
# Registration / Account information form
# ---------------------------------------------------------------------------
${TITLE_MR_RADIO}              css=#id_gender1
${TITLE_MRS_RADIO}             css=#id_gender2
${REGISTRATION_PASSWORD}       css=#password
${DAY_SELECT}                  css=#days
${MONTH_SELECT}                css=#months
${YEAR_SELECT}                 css=#years
${NEWSLETTER_CHECKBOX}         css=#newsletter
${SPECIAL_OFFERS_CHECKBOX}     css=#optin

${FIRST_NAME_INPUT}            css=#first_name
${LAST_NAME_INPUT}             css=#last_name
${COMPANY_INPUT}               css=#company
${ADDRESS1_INPUT}              css=#address1
${ADDRESS2_INPUT}              css=#address2
${COUNTRY_SELECT}              css=#country
${STATE_INPUT}                 css=#state
${CITY_INPUT}                  css=#city
${ZIPCODE_INPUT}               css=#zipcode
${MOBILE_NUMBER_INPUT}         css=#mobile_number
${CREATE_ACCOUNT_BUTTON}       css=button[data-qa=create-account]

${ACCOUNT_CREATED_HEADING}     css=h2[data-qa=account-created]
${CONTINUE_BUTTON}             css=a[data-qa=continue-button]
${ACCOUNT_DELETED_HEADING}     css=h2[data-qa=account-deleted]

# ---------------------------------------------------------------------------
# Account area (post-login)
# ---------------------------------------------------------------------------
${DELETE_ACCOUNT_LINK}         css=a[href='/delete_account']
${ACCOUNT_LOGGED_IN_BANNER}    xpath=//ul//li//a[contains(text(), 'Logged in as')]