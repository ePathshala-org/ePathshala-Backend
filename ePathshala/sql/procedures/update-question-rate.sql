CREATE OR REPLACE PROCEDURE UPDATE_QUESTION_RATE(PARAM_USER_ID BIGINT, PARAM_QUESTION_ID BIGINT, PARAM_RATE INT)
LANGUAGE PLPGSQL
AS
$$
DECLARE
	FOUND_RATE INT;
BEGIN
	SELECT RATE INTO FOUND_RATE
	FROM QUESTION_RATES
	WHERE USER_ID = PARAM_USER_ID AND QUESTION_ID = PARAM_QUESTION_ID;
	IF FOUND_RATE IS NULL THEN
		INSERT INTO QUESTION_RATES (USER_ID, QUESTION_ID, RATE)
		VALUES (PARAM_USER_ID, PARAM_QUESTION_ID, PARAM_RATE);
	ELSE
		UPDATE QUESTION_RATES
		SET RATE = PARAM_RATE
		WHERE USER_ID = PARAM_USER_ID AND QUESTION_ID = PARAM_QUESTION_ID;
	END IF;
END;
$$;