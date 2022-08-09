SELECT 
    COMMENT_ID, 
    CONTENT_ID, 
    COMMENTER_ID, 
    FULL_NAME AS COMMENTER_NAME, 
    DESCRIPTION, 
    TIME_OF_COMMENT, 
    DATE_OF_COMMENT, 
    RATE
FROM COMMENTS
JOIN USERS
ON(COMMENTS.COMMENTER_ID = USERS.USER_ID)
WHERE CONTENT_ID = $1