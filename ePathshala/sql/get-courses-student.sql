SELECT 
    COURSES2.COURSE_ID AS COURSE_ID, 
    TITLE,
    TRIM(DESCRIPTION) AS DESCRIPTION, 
    DATE_OF_CREATION, 
    PRICE, 
    CREATOR_ID,
    FULL_NAME AS CREATOR_NAME, 
    RATE,
    COUNT(USERS.USER_ID) AS ENROLL_COUNT
FROM 
	(
		SELECT 
			COURSES.COURSE_ID,
			COURSES.TITLE AS TITLE,
			COURSES.DESCRIPTION AS DESCRIPTION,
			COURSES.DATE_OF_CREATION AS DATE_OF_CREATION,
			PRICE,
			CREATOR_ID,
			AVG(RATE) AS RATE
		FROM COURSES
		JOIN CONTENTS
		ON(COURSES.COURSE_ID = CONTENTS.COURSE_ID)
		GROUP BY COURSES.COURSE_ID, COURSES.TITLE, COURSES.DESCRIPTION, COURSES.DATE_OF_CREATION, PRICE, CREATOR_ID, RATE
	) COURSES2
JOIN ENROLLED_COURSES
ON(COURSES2.COURSE_ID = ENROLLED_COURSES.COURSE_ID)
JOIN USERS
ON(COURSES2.CREATOR_ID = USERS.USER_ID)
WHERE ENROLLED_COURSES.USER_ID = $1
GROUP BY COURSES2.COURSE_ID, TITLE, DESCRIPTION, DATE_OF_CREATION, PRICE, CREATOR_ID, CREATOR_NAME, RATE