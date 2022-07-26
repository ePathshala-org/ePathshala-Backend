CREATE OR REPLACE FUNCTION GET_INDIVIDUAL_ANSWER_RATE(PARAM_USER_ID BIGINT, PARAM_ANSWER_ID BIGINT)
RETURNS INT
LANGUAGE PLPGSQL
AS
$$
DECLARE
	RATE_VALUE INT;
BEGIN
	SELECT RATE INTO RATE_VALUE
	FROM ANSWER_RATES
	WHERE USER_ID = PARAM_USER_ID AND ANSWER_ID = PARAM_ANSWER_ID;
	RETURN RATE_VALUE;
END;
$$;