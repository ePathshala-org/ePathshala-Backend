CREATE OR REPLACE FUNCTION SEARCH_PAGES(PARAM_SEARCH_TERM VARCHAR)
RETURNS TABLE(CONTENT_ID BIGINT, TITLE VARCHAR, COURSE_ID BIGINT)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	RETURN QUERY SELECT
		CONTENTS.CONTENT_ID,
		CONTENTS.TITLE,
		CONTENTS.COURSE_ID
	FROM 
		CONTENTS
	WHERE
		CONTENTS.CONTENT_TYPE = 'PAGE' AND LOWER(CONTENTS.TITLE) LIKE CONCAT('%', LOWER(PARAM_SEARCH_TERM), '%');
END;
$$;