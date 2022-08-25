CREATE OR REPLACE FUNCTION GET_SPECIALITIES(PARAM_TEACHER_ID BIGINT)
RETURNS TABLE(SPECIALITY VARCHAR)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	RETURN QUERY SELECT
		TEACHER_SPECIALITIES.SPECIALITY
	FROM TEACHER_SPECIALITIES
	WHERE TEACHER_ID = PARAM_TEACHER_ID;
END;
$$;