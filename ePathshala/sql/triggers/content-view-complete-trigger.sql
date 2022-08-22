CREATE OR REPLACE FUNCTION CONTENT_VIEW_COMPLETE_TRIGGER()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
DECLARE
	UPDATED_COURSE_ID BIGINT;
BEGIN
	IF OLD.COMPLETED = FALSE AND NEW.COMPLETED = TRUE THEN
		SELECT COURSE_ID INTO UPDATED_COURSE_ID
		FROM CONTENTS
		WHERE CONTENT_ID = NEW.CONTENT_ID;
		UPDATE COURSE_REMAIN_CONTENTS
		SET
			REMAIN_COUNT = REMAIN_COUNT - 1,
			COMPLETE_COUNT = COMPLETE_COUNT + 1
		WHERE USER_ID = NEW.USER_ID AND COURSE_ID = UPDATED_COURSE_ID;
	END IF;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER CONTENT_VIEW_COMPLETE_TRIGGER
AFTER UPDATE
OF COMPLETED
ON CONTENT_VIEWERS
FOR EACH ROW
EXECUTE PROCEDURE CONTENT_VIEW_COMPLETE_TRIGGER();