SELECT
    USER_ID,
    FULL_NAME,
    TRIM(SECURITY_KEY) AS SECURITY_KEY,
    DATE_OF_BIRTH,
    TRIM(BIO) AS BIO,
    EMAIL,
    ADDRESS,
    TRIM(USER_TYPE) AS USER_TYPE,
    GENDER,
    CREDIT_CARD_ID,
    BANK_ID
FROM USERS
WHERE USER_ID = $1