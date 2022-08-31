CREATE OR REPLACE FUNCTION ANSWER_RATE_TRIGGER()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
DECLARE
	AVG_RATE NUMERIC;
	ID BIGINT;
BEGIN
	IF NEW.ANSWER_ID IS NOT NULL THEN
		ID := NEW.ANSWER_ID;
	ELSE
		ID := OLD.ANSWER_ID;
	END IF;
	SELECT AVG(RATE) INTO AVG_RATE
	FROM ANSWER_RATES
	WHERE ANSWER_ID = ID AND RATE != 0;
	IF AVG_RATE IS NULL THEN
		AVG_RATE := 0;
	END IF;
	UPDATE ANSWERS
	SET RATE = AVG_RATE
	WHERE ANSWER_ID = ID;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER ANSWER_RATE_TRIGGER
AFTER INSERT OR DELETE OR UPDATE
OF RATE
ON ANSWER_RATES
FOR EACH ROW
EXECUTE PROCEDURE ANSWER_RATE_TRIGGER();