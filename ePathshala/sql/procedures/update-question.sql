CREATE OR REPLACE PROCEDURE UPDATE_QUESTION(PARAM_QUESTION_ID BIGINT, PARAM_QUESTION VARCHAR)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	UPDATE FORUM_QUESTIONS
	SET QUESTION = PARAM_QUESTION
	WHERE QUESTION_ID = PARAM_QUESTION_ID;
END;
$$;