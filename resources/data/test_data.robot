*** Settings ***
Documentation     Static/dataset TEST DATA used across suites. All data here is
...               NON-PERSONAL and safe to commit. Secrets must never live here;
...               they belong in environment variables or a local .env file
...               referenced through the config layer.

*** Variables ***
# ---------------------------------------------------------------------------
# Registration form dataset
# ---------------------------------------------------------------------------
${TEST_TITLE}                  Mr
${TEST_FIRST_NAME}             John
${TEST_LAST_NAME}              Doe
${TEST_COMPANY}                Automation QA Ltd
${TEST_ADDRESS1}               221B Baker Street
${TEST_ADDRESS2}
${TEST_COUNTRY}                India
${TEST_STATE}                  Maharashtra
${TEST_CITY}                   Mumbai
${TEST_ZIPCODE}                400001
${TEST_MOBILE}                 9876543210

# ---------------------------------------------------------------------------
# Date-of-birth dataset
# ---------------------------------------------------------------------------
${DOB_DAY}                     15
${DOB_MONTH}                   June
${DOB_YEAR}                    1990

# ---------------------------------------------------------------------------
# Payment dataset (Visa test card)
# ---------------------------------------------------------------------------
${PAYMENT_NAME}                John Doe
${PAYMENT_CARD_VALUE}          4242424242424242
${PAYMENT_CVC_VALUE}           311
${PAYMENT_EXPIRY_MONTH_VALUE}  12
${PAYMENT_EXPIRY_YEAR_VALUE}   2035
${ORDER_COMMENT}               Automated checkout - please deliver between 9 and 5.