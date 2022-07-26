CREATE OR REPLACE FUNCTION COURSES_ENROLL_COUNT_TRIGGER()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
DECLARE
	ID BIGINT;
	NEW_ENROLL_COUNT BIGINT;
BEGIN
	IF NEW.COURSE_ID IS NOT NULL THEN
		ID := NEW.COURSE_ID;
	ELSE
		ID := OLD.COURSE_ID;
	END IF;
	SELECT COUNT(*) INTO NEW_ENROLL_COUNT
	FROM ENROLLED_COURSES
	WHERE COURSE_ID = ID;
	UPDATE COURSES
	SET ENROLL_COUNT = NEW_ENROLL_COUNT
	WHERE COURSE_ID = ID;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER COURSES_ENROLL_COUNT_TRIGGER
AFTER INSERT OR DELETE OR UPDATE
ON ENROLLED_COURSES
FOR EACH ROW
EXECUTE PROCEDURE COURSES_ENROLL_COUNT_TRIGGER();