SELECT TEACHERS.USER_ID AS USER_ID, SECURITY_KEY
FROM TEACHERS
JOIN USERS
ON(TEACHERS.USER_ID = USERS.USER_ID)
WHERE EMAIL = $1 AND SECURITY_KEY = $2