CREATE OR REPLACE PROCEDURE DELETE_ANSWER(PARAM_ANSWER_ID BIGINT)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	DELETE FROM FORUM_ANSWERS
	WHERE ANSWER_ID = PARAM_ANSWER_ID;
END;
$$;