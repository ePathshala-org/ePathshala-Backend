CREATE OR REPLACE FUNCTION GET_COURSE_DETAILS(PARAM_COURSE_ID BIGINT)
RETURNS TABLE(COURSE_ID BIGINT, TITLE VARCHAR, DESCRIPTION VARCHAR, DATE_OF_CREATION DATE, PRICE INT, CREATOR_ID BIGINT, CREATOR_NAME VARCHAR, RATE NUMERIC, ENROLL_COUNT BIGINT)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.CREATOR_ID, USERS.FULL_NAME, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	JOIN USERS
	ON(COURSES.CREATOR_ID = USERS.USER_ID)
	WHERE COURSES.COURSE_ID = PARAM_COURSE_ID;
END;
$$;