CREATE OR REPLACE PROCEDURE DELETE_CONTENT(PARAM_CONTENT_ID BIGINT)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	DELETE FROM CONTENTS
	WHERE CONTENT_ID = PARAM_CONTENT_ID;
END;
$$;