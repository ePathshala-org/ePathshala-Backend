CREATE OR REPLACE FUNCTION GET_STUDENT_DETAILS(PARAM_USER_ID BIGINT)
RETURNS TABLE(USER_ID BIGINT, FULL_NAME VARCHAR, DATE_OF_BIRTH DATE, BIO VARCHAR, EMAIL VARCHAR, USER_TYPE VARCHAR, DATE_OF_JOIN DATE, RANK_POINT INT)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	RETURN QUERY SELECT 
    USERS.USER_ID, 
    USERS.FULL_NAME,  
    USERS.DATE_OF_BIRTH, 
    TRIM(USERS.BIO)::VARCHAR, 
    USERS.EMAIL, 
    USERS.USER_TYPE::VARCHAR, 
    STUDENTS.DATE_OF_JOIN, 
    STUDENTS.RANK_POINT
FROM USERS
JOIN STUDENTS
ON(USERS.USER_ID = STUDENTS.USER_ID)
WHERE USERS.USER_ID = PARAM_USER_ID;
END;
$$;