CREATE OR REPLACE PROCEDURE INSERT_INTEREST(PARAM_STUDENT_ID BIGINT, PARAM_INTEREST VARCHAR)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	INSERT INTO STUDENT_INTERESTS (STUDENT_ID, INTEREST)
	VALUES
		(PARAM_STUDENT_ID, PARAM_INTEREST);
END;
$$;