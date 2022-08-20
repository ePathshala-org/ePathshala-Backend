CREATE OR REPLACE FUNCTION COURSES_RATE_TRIGGER()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
DECLARE
	AVERAGE_RATE NUMERIC;
	ID BIGINT;
BEGIN
	IF NEW.COURSE_ID IS NOT NULL THEN
		ID := NEW.COURSE_ID;
	ELSE
		ID := OLD.COURSE_ID;
	END IF;
	SELECT AVG(RATE) INTO AVERAGE_RATE
	FROM CONTENTS
	WHERE COURSE_ID = ID;
	UPDATE COURSES
	SET RATE = AVERAGE_RATE
	WHERE COURSE_ID = ID;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER COURSES_RATE_TRIGGER
AFTER INSERT OR DELETE OR UPDATE
OF RATE
ON CONTENTS
FOR EACH ROW
EXECUTE PROCEDURE COURSES_RATE_TRIGGER();