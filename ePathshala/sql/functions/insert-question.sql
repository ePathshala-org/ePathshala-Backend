CREATE OR REPLACE FUNCTION INSERT_QUESTION(PARAM_TITLE VARCHAR, PARAM_TAGS VARCHAR[], PARAM_ASKER_ID BIGINT)
RETURNS BIGINT
LANGUAGE PLPGSQL
AS
$$
DECLARE
	NEW_QUESTION_ID BIGINT;
BEGIN
	NEW_QUESTION_ID := GET_NEW_QUESTION_ID();
	INSERT INTO FORUM_QUESTIONS (QUESTION_ID, ASKER_ID, TITLE)
	VALUES (NEW_QUESTION_ID, PARAM_ASKER_ID, PARAM_TITLE);
	FOR I IN 1..CARDINALITY(PARAM_TAGS) LOOP
		INSERT INTO FORUM_QUESTIONS_TAGS (QUESTION_ID, TAG)
		VALUES(NEW_QUESTION_ID, PARAM_TAGS[I]);
	END LOOP;
	RETURN NEW_QUESTION_ID;
EXCEPTION
	WHEN unique_violation THEN
		RETURN -1; --DUPLICATE QUESTION TOPIC BY SAME USER
END;