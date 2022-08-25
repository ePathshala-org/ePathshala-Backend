CREATE OR REPLACE FUNCTION GET_NEW_COMMENT_ID()
RETURNS BIGINT
LANGUAGE PLPGSQL
AS
$$
DECLARE
	MAX_COMMENT_ID BIGINT;
	NEW_COMMENT_ID BIGINT;
BEGIN
	SELECT MAX(COMMENT_ID) INTO MAX_COMMENT_ID
	FROM COMMENTS;
	IF MAX_COMMENT_ID IS NULL THEN
		RETURN 1;
	ELSE
		FOR I IN 1..MAX_COMMENT_ID LOOP
			SELECT COMMENT_ID INTO NEW_COMMENT_ID
			FROM COMMENTS
			WHERE COMMENT_ID = I;
			IF NEW_COMMENT_ID IS NULL THEN
				RETURN I;
			END IF;
		END LOOP;
		RETURN MAX_COMMENT_ID + 1;
	END IF;
END;
$$;