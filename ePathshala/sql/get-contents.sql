SELECT 
    CONTENTS.CONTENT_ID AS CONTENT_ID, 
    TITLE, 
    DESCRIPTION, 
    RATE, 
    DATE_OF_CREATION, 
    TRIM(CONTENT_TYPE) AS CONTENT_TYPE, 
    COUNT(VIEW_ID) AS VIEW_COUNT
FROM CONTENTS
JOIN CONTENT_VIEWERS
ON(CONTENTS.CONTENT_ID = CONTENT_VIEWERS.CONTENT_ID)
WHERE COURSE_ID = $1
GROUP BY CONTENTS.CONTENT_ID, TITLE, DESCRIPTION, RATE, DATE_OF_CREATION, CONTENT_TYPE
ORDER BY CONTENT_ID