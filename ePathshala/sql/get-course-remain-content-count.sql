SELECT COUNT(*) AS CONTENT_COUNT
FROM CONTENT_VIEWERS
JOIN CONTENTS
ON (CONTENT_VIEWERS.CONTENT_ID = CONTENTS.CONTENT_ID)
WHERE USER_ID = $1 AND COURSE_ID = $2 AND COMPLETED = FALSE;