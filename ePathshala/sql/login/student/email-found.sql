SELECT STUDENTS.USER_ID AS USER_ID, SECURITY_KEY
FROM STUDENTS
JOIN USERS
ON(STUDENTS.USER_ID = USERS.USER_ID)
WHERE EMAIL = $1 AND SECURITY_KEY = $2