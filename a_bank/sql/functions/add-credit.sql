CREATE OR REPLACE FUNCTION ADD_CREDIT(PARAM_CLIENT_ID BIGINT, PARAM_PASSWORD VARCHAR, PARAM_AMOUNT INT)
RETURNS INT
LANGUAGE PLPGSQL
AS
$$
DECLARE
	SELECTED_CLIENT_ID BIGINT;
	AMOUNT INT;
BEGIN
	SELECT CLIENT_ID INTO SELECTED_CLIENT_ID
	FROM CLIENTS
	WHERE CLIENT_ID = PARAM_CLIENT_ID AND SECURITY_KEY = PARAM_PASSWORD;
	IF SELECTED_CLIENT_ID IS NULL THEN
		RETURN 1; --INVALID CREDENTIALS
	END IF;
	UPDATE CLIENTS
	SET CREDIT = CREDIT + PARAM_AMOUNT
	WHERE CLIENT_ID = PARAM_CLIENT_ID;
	RETURN 0; --SUCCESS
END;
$$;