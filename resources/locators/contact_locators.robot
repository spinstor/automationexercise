*** Settings ***
Documentation     Page object LOCATORS for the Contact us page (/contact_us).
...
...               Rule: LOCATORS ONLY - no keywords in this file.

*** Variables ***
${CONTACT_FORM}                css=#contact-us-form
${CONTACT_NAME_INPUT}          css=input[data-qa=name]
${CONTACT_EMAIL_INPUT}         css=input[data-qa=email]
${CONTACT_SUBJECT_INPUT}       css=input[data-qa=subject]
${CONTACT_MESSAGE_INPUT}       css=textarea[data-qa=message]
${CONTACT_FILE_INPUT}          css=.form-control[type='file']
${CONTACT_SUBMIT_BUTTON}       css=input[data-qa=submit-button]
${CONTACT_SUCCESS_MESSAGE}     css=.status.alert-success
${CONTACT_HEADING}             xpath=//h2[contains(text(), 'Contact')]