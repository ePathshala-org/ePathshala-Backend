--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_student_enrolled(bigint, bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.check_student_enrolled(param_user_id bigint, param_course_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
	QUERY_COUNT INT;
BEGIN
	SELECT COUNT(*) INTO QUERY_COUNT
	FROM ENROLLED_COURSES
	WHERE USER_ID = PARAM_USER_ID AND COURSE_ID = PARAM_COURSE_ID;
	IF QUERY_COUNT > 0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$;


ALTER FUNCTION public.check_student_enrolled(param_user_id bigint, param_course_id bigint) OWNER TO epathshala;

--
-- Name: conetent_view_complete_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.conetent_view_complete_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	UPDATED_COURSE_ID BIGINT;
BEGIN
	SELECT COURSE_ID INTO UPDATED_COURSE_ID
	FROM CONTENTS
	WHERE CONTENT_ID = NEW.CONTENT_ID;
	UPDATE COURSE_REMAIN_CONTENTS
	SET
		REMAIN_COUNT = REMAIN_COUNT - 1,
		COMPLETE_COUNT = COMPLETE_COUNT + 1
	WHERE USER_ID = NEW.USER_ID AND COURSE_ID = UPDATED_COURSE_ID;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.conetent_view_complete_trigger() OWNER TO epathshala;

--
-- Name: content_view_complete_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.content_view_complete_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.content_view_complete_trigger() OWNER TO epathshala;

--
-- Name: contents_rate_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.contents_rate_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	AVERAGE_RATE NUMERIC;
	ID BIGINT;
BEGIN
	IF NEW.CONTENT_ID IS NOT NULL THEN
		ID := NEW.CONTENT_ID;
	ELSE
		ID := OLD.CONTENT_ID;
	END IF;
	SELECT AVG(RATE) INTO AVERAGE_RATE
	FROM CONTENT_VIEWERS
	WHERE CONTENT_ID = ID AND RATE != 0;
	IF AVERAGE_RATE IS NULL THEN
		AVERAGE_RATE := 0;
	END IF;
	UPDATE CONTENTS
	SET RATE = AVERAGE_RATE
	WHERE CONTENT_ID = ID;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.contents_rate_trigger() OWNER TO epathshala;

--
-- Name: contents_view_count_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.contents_view_count_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_VIEW_COUNT BIGINT;
	ID BIGINT;
BEGIN
	IF NEW.CONTENT_ID IS NOT NULL THEN
		ID := NEW.CONTENT_ID;
	ELSE
		ID := OLD.CONTENT_ID;
	END IF;
	SELECT COUNT(*) INTO NEW_VIEW_COUNT
	FROM CONTENT_VIEWERS
	WHERE CONTENT_ID = ID;
	UPDATE CONTENTS
	SET VIEW_COUNT = NEW_VIEW_COUNT
	WHERE CONTENT_ID = ID;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.contents_view_count_trigger() OWNER TO epathshala;

--
-- Name: course_enroll_insert_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.course_enroll_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	CONTENT_COUNT BIGINT;
BEGIN
	SELECT COUNT(*) INTO CONTENT_COUNT
	FROM CONTENTS
	WHERE COURSE_ID = NEW.COURSE_ID;
	INSERT INTO COURSE_REMAIN_CONTENTS(USER_ID, COURSE_ID, REMAIN_COUNT)
	VALUES
	(NEW.USER_ID, NEW.COURSE_ID, CONTENT_COUNT);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.course_enroll_insert_trigger() OWNER TO epathshala;

--
-- Name: courses_enroll_count_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.courses_enroll_count_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.courses_enroll_count_trigger() OWNER TO epathshala;

--
-- Name: courses_rate_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.courses_rate_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
	WHERE COURSE_ID = ID AND RATE != 0;
	IF AVERAGE_RATE IS NULL THEN
		AVERAGE_RATE := 0;
	END IF;
	UPDATE COURSES
	SET RATE = AVERAGE_RATE
	WHERE COURSE_ID = ID;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.courses_rate_trigger() OWNER TO epathshala;

--
-- Name: delete_comment(bigint); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.delete_comment(IN param_comment_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM COMMENTS
	WHERE COMMENT_ID = PARAM_COMMENT_ID;
END;
$$;


ALTER PROCEDURE public.delete_comment(IN param_comment_id bigint) OWNER TO epathshala;

--
-- Name: delete_content(bigint); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.delete_content(IN param_content_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM CONTENTS
	WHERE CONTENT_ID = PARAM_CONTENT_ID;
END;
$$;


ALTER PROCEDURE public.delete_content(IN param_content_id bigint) OWNER TO epathshala;

--
-- Name: delete_course(bigint); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.delete_course(IN param_course_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM COURSES
	WHERE COURSE_ID = PARAM_COURSE_ID;
END;
$$;


ALTER PROCEDURE public.delete_course(IN param_course_id bigint) OWNER TO epathshala;

--
-- Name: delete_interest(bigint, character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.delete_interest(IN param_student_id bigint, IN param_interest character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM STUDENT_INTERESTS
	WHERE STUDENT_ID = PARAM_STUDENT_ID AND INTEREST = PARAM_INTEREST;
END;
$$;


ALTER PROCEDURE public.delete_interest(IN param_student_id bigint, IN param_interest character varying) OWNER TO epathshala;

--
-- Name: delete_speciality(bigint, character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.delete_speciality(IN param_teacher_id bigint, IN param_speciality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM TEACHER_SPECIALITIES
	WHERE TEACHER_ID = PARAM_TEACHER_ID AND SPECIALITY = PARAM_SPECIALITY;
END;
$$;


ALTER PROCEDURE public.delete_speciality(IN param_teacher_id bigint, IN param_speciality character varying) OWNER TO epathshala;

--
-- Name: enroll_student(bigint, bigint); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.enroll_student(IN param_student_id bigint, IN param_course_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO ENROLLED_COURSES
	(USER_ID, COURSE_ID)
	VALUES(PARAM_STUDENT_ID, PARAM_COURSE_ID);
END;
$$;


ALTER PROCEDURE public.enroll_student(IN param_student_id bigint, IN param_course_id bigint) OWNER TO epathshala;

--
-- Name: enrolled_courses_insert_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.enrolled_courses_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	CONTENT_COUNT BIGINT;
BEGIN
	SELECT COUNT(*) INTO CONTENT_COUNT
	FROM CONTENTS
	WHERE COURSE_ID = NEW.COURSE_ID;
	INSERT INTO COURSE_REMAIN_CONTENTS(USER_ID, COURSE_ID, REMAIN_COUNT)
	VALUES
	(NEW.USER_ID, NEW.COURSE_ID, CONTENT_COUNT);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.enrolled_courses_insert_trigger() OWNER TO epathshala;

--
-- Name: get_comments_by_rate_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_comments_by_rate_asc(param_content_id bigint) RETURNS TABLE(comment_id bigint, content_id bigint, commenter_id bigint, commenter_name character varying, description character varying, time_of_comment time with time zone, date_of_comment date, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COMMENTS.COMMENT_ID,
		COMMENTS.CONTENT_ID,
		COMMENTS.COMMENTER_ID,
		USERS.FULL_NAME,
		TRIM(COMMENTS.DESCRIPTION)::VARCHAR,
		COMMENTS.TIME::TIME(0) WITH TIME ZONE,
		COMMENTS.DATE,
		COMMENTS.RATE::NUMERIC(3, 1)
	FROM COMMENTS
	JOIN USERS
	ON (COMMENTS.COMMENTER_ID = USERS.USER_ID)
	WHERE COMMENTS.CONTENT_ID = PARAM_CONTENT_ID
	ORDER BY COMMENTS.RATE ASC;
END;
$$;


ALTER FUNCTION public.get_comments_by_rate_asc(param_content_id bigint) OWNER TO epathshala;

--
-- Name: get_comments_by_rate_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_comments_by_rate_desc(param_content_id bigint) RETURNS TABLE(comment_id bigint, content_id bigint, commenter_id bigint, commenter_name character varying, description character varying, time_of_comment time with time zone, date_of_comment date, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COMMENTS.COMMENT_ID,
		COMMENTS.CONTENT_ID,
		COMMENTS.COMMENTER_ID,
		USERS.FULL_NAME,
		TRIM(COMMENTS.DESCRIPTION)::VARCHAR,
		COMMENTS.TIME::TIME(0) WITH TIME ZONE,
		COMMENTS.DATE,
		COMMENTS.RATE::NUMERIC(3, 1)
	FROM COMMENTS
	JOIN USERS
	ON (COMMENTS.COMMENTER_ID = USERS.USER_ID)
	WHERE COMMENTS.CONTENT_ID = PARAM_CONTENT_ID
	ORDER BY COMMENTS.RATE DESC;
END;
$$;


ALTER FUNCTION public.get_comments_by_rate_desc(param_content_id bigint) OWNER TO epathshala;

--
-- Name: get_comments_by_time_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_comments_by_time_asc(param_content_id bigint) RETURNS TABLE(comment_id bigint, content_id bigint, commenter_id bigint, commenter_name character varying, description character varying, time_of_comment time with time zone, date_of_comment date, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COMMENTS.COMMENT_ID,
		COMMENTS.CONTENT_ID,
		COMMENTS.COMMENTER_ID,
		USERS.FULL_NAME,
		TRIM(COMMENTS.DESCRIPTION)::VARCHAR,
		COMMENTS.TIME::TIME(0) WITH TIME ZONE,
		COMMENTS.DATE,
		COMMENTS.RATE::NUMERIC(3, 1)
	FROM COMMENTS
	JOIN USERS
	ON (COMMENTS.COMMENTER_ID = USERS.USER_ID)
	WHERE COMMENTS.CONTENT_ID = PARAM_CONTENT_ID
	ORDER BY COMMENTS.DATE ASC, COMMENTS.TIME ASC;
END;
$$;


ALTER FUNCTION public.get_comments_by_time_asc(param_content_id bigint) OWNER TO epathshala;

--
-- Name: get_comments_by_time_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_comments_by_time_desc(param_content_id bigint) RETURNS TABLE(comment_id bigint, content_id bigint, commenter_id bigint, commenter_name character varying, description character varying, time_of_comment time with time zone, date_of_comment date, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COMMENTS.COMMENT_ID,
		COMMENTS.CONTENT_ID,
		COMMENTS.COMMENTER_ID,
		USERS.FULL_NAME,
		TRIM(COMMENTS.DESCRIPTION)::VARCHAR,
		COMMENTS.TIME::TIME(0) WITH TIME ZONE,
		COMMENTS.DATE,
		COMMENTS.RATE::NUMERIC(3, 1)
	FROM COMMENTS
	JOIN USERS
	ON (COMMENTS.COMMENTER_ID = USERS.USER_ID)
	WHERE COMMENTS.CONTENT_ID = PARAM_CONTENT_ID
	ORDER BY COMMENTS.DATE DESC, COMMENTS.TIME DESC;
END;
$$;


ALTER FUNCTION public.get_comments_by_time_desc(param_content_id bigint) OWNER TO epathshala;

--
-- Name: get_content_details(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_content_details(param_content_id bigint) RETURNS TABLE(content_id bigint, date_of_creation date, content_type character varying, rate numeric, title character varying, description character varying, course_id bigint, course_name character varying, view_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		CONTENTS.CONTENT_ID,
		CONTENTS.DATE_OF_CREATION,
		TRIM(CONTENTS.CONTENT_TYPE)::VARCHAR,
		CONTENTS.RATE::NUMERIC(3, 2),
		CONTENTS.TITLE,
		TRIM(CONTENTS.DESCRIPTION)::VARCHAR,
		COURSES.COURSE_ID,
		COURSES.TITLE,
		CONTENTS.VIEW_COUNT
	FROM CONTENTS
	JOIN COURSES
	ON (CONTENTS.COURSE_ID = COURSES.COURSE_ID)
	WHERE CONTENTS.CONTENT_ID = PARAM_CONTENT_ID;
END;
$$;


ALTER FUNCTION public.get_content_details(param_content_id bigint) OWNER TO epathshala;

--
-- Name: get_course_contents_by_rate_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_course_contents_by_rate_asc(param_course_id bigint) RETURNS TABLE(content_id bigint, title character varying, description character varying, rate numeric, date_of_creation date, content_type character varying, view_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		CONTENTS.CONTENT_ID,
		CONTENTS.TITLE,
		TRIM(CONTENTS.DESCRIPTION)::VARCHAR,
		CONTENTS.RATE::NUMERIC(3, 2),
		CONTENTS.DATE_OF_CREATION,
		TRIM(CONTENTS.CONTENT_TYPE)::VARCHAR,
		CONTENTS.VIEW_COUNT
	FROM 
		CONTENTS
	WHERE
		COURSE_ID = PARAM_COURSE_ID
	ORDER BY
		RATE ASC;
END;
$$;


ALTER FUNCTION public.get_course_contents_by_rate_asc(param_course_id bigint) OWNER TO epathshala;

--
-- Name: get_course_contents_by_rate_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_course_contents_by_rate_desc(param_course_id bigint) RETURNS TABLE(content_id bigint, title character varying, description character varying, rate numeric, date_of_creation date, content_type character varying, view_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		CONTENTS.CONTENT_ID,
		CONTENTS.TITLE,
		TRIM(CONTENTS.DESCRIPTION)::VARCHAR,
		CONTENTS.RATE::NUMERIC(3, 2),
		CONTENTS.DATE_OF_CREATION,
		TRIM(CONTENTS.CONTENT_TYPE)::VARCHAR,
		CONTENTS.VIEW_COUNT
	FROM 
		CONTENTS
	WHERE
		COURSE_ID = PARAM_COURSE_ID
	ORDER BY
		RATE DESC;
END;
$$;


ALTER FUNCTION public.get_course_contents_by_rate_desc(param_course_id bigint) OWNER TO epathshala;

--
-- Name: get_course_contents_by_title_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_course_contents_by_title_asc(param_course_id bigint) RETURNS TABLE(content_id bigint, title character varying, description character varying, rate numeric, date_of_creation date, content_type character varying, view_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		CONTENTS.CONTENT_ID,
		CONTENTS.TITLE,
		TRIM(CONTENTS.DESCRIPTION)::VARCHAR,
		CONTENTS.RATE::NUMERIC(3, 2),
		CONTENTS.DATE_OF_CREATION,
		TRIM(CONTENTS.CONTENT_TYPE)::VARCHAR,
		CONTENTS.VIEW_COUNT
	FROM 
		CONTENTS
	WHERE
		COURSE_ID = PARAM_COURSE_ID
	ORDER BY
		TITLE ASC;
END;
$$;


ALTER FUNCTION public.get_course_contents_by_title_asc(param_course_id bigint) OWNER TO epathshala;

--
-- Name: get_course_contents_by_title_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_course_contents_by_title_desc(param_course_id bigint) RETURNS TABLE(content_id bigint, title character varying, description character varying, rate numeric, date_of_creation date, content_type character varying, view_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		CONTENTS.CONTENT_ID,
		CONTENTS.TITLE,
		TRIM(CONTENTS.DESCRIPTION)::VARCHAR,
		CONTENTS.RATE::NUMERIC(3, 2),
		CONTENTS.DATE_OF_CREATION,
		TRIM(CONTENTS.CONTENT_TYPE)::VARCHAR,
		CONTENTS.VIEW_COUNT
	FROM 
		CONTENTS
	WHERE
		COURSE_ID = PARAM_COURSE_ID
	ORDER BY
		TITLE DESC;
END;
$$;


ALTER FUNCTION public.get_course_contents_by_title_desc(param_course_id bigint) OWNER TO epathshala;

--
-- Name: get_course_details(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_course_details(param_course_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, creator_id bigint, creator_name character varying, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.CREATOR_ID, USERS.FULL_NAME, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	JOIN USERS
	ON(COURSES.CREATOR_ID = USERS.USER_ID)
	WHERE COURSES.COURSE_ID = PARAM_COURSE_ID;
END;
$$;


ALTER FUNCTION public.get_course_details(param_course_id bigint) OWNER TO epathshala;

--
-- Name: get_course_remain_content(bigint, bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_course_remain_content(param_user_id bigint, param_course_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	TO_RETURN BIGINT;
BEGIN
	SELECT REMAIN_COUNT INTO TO_RETURN
	FROM COURSE_REMAIN_CONTENTS
	WHERE USER_ID = PARAM_USER_ID AND COURSE_ID = PARAM_COURSE_ID;
	RETURN TO_RETURN;
END;
$$;


ALTER FUNCTION public.get_course_remain_content(param_user_id bigint, param_course_id bigint) OWNER TO epathshala;

--
-- Name: get_courses_by_enroll_count_asc(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_by_enroll_count_asc() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY ENROLL_COUNT ASC;
END;
$$;


ALTER FUNCTION public.get_courses_by_enroll_count_asc() OWNER TO epathshala;

--
-- Name: get_courses_by_enroll_count_desc(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_by_enroll_count_desc() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY ENROLL_COUNT DESC;
END;
$$;


ALTER FUNCTION public.get_courses_by_enroll_count_desc() OWNER TO epathshala;

--
-- Name: get_courses_by_price_asc(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_by_price_asc() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY PRICE ASC;
END;
$$;


ALTER FUNCTION public.get_courses_by_price_asc() OWNER TO epathshala;

--
-- Name: get_courses_by_price_desc(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_by_price_desc() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY PRICE DESC;
END;
$$;


ALTER FUNCTION public.get_courses_by_price_desc() OWNER TO epathshala;

--
-- Name: get_courses_by_rate_desc(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_by_rate_desc() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY RATE DESC;
END;
$$;


ALTER FUNCTION public.get_courses_by_rate_desc() OWNER TO epathshala;

--
-- Name: get_courses_popular(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_popular() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY ENROLL_COUNT DESC;
END;
$$;


ALTER FUNCTION public.get_courses_popular() OWNER TO epathshala;

--
-- Name: get_courses_rate(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_rate() RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	ORDER BY RATE DESC;
END;
$$;


ALTER FUNCTION public.get_courses_rate() OWNER TO epathshala;

--
-- Name: get_courses_teacher_by_date_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_teacher_by_date_asc(param_teacher_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COURSES.COURSE_ID,
		COURSES.TITLE,
		TRIM(COURSES.DESCRIPTION)::VARCHAR,
		COURSES.DATE_OF_CREATION,
		COURSES.PRICE,
		COURSES.RATE::NUMERIC(3, 2),
		COURSES.ENROLL_COUNT
	FROM COURSES
	WHERE CREATOR_ID = PARAM_TEACHER_ID
	ORDER BY DATE_OF_CREATION ASC;
END;
$$;


ALTER FUNCTION public.get_courses_teacher_by_date_asc(param_teacher_id bigint) OWNER TO epathshala;

--
-- Name: get_courses_teacher_by_date_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_teacher_by_date_desc(param_teacher_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COURSES.COURSE_ID,
		COURSES.TITLE,
		TRIM(COURSES.DESCRIPTION)::VARCHAR,
		COURSES.DATE_OF_CREATION,
		COURSES.PRICE,
		COURSES.RATE::NUMERIC(3, 2),
		COURSES.ENROLL_COUNT
	FROM COURSES
	WHERE CREATOR_ID = PARAM_TEACHER_ID
	ORDER BY DATE_OF_CREATION DESC;
END;
$$;


ALTER FUNCTION public.get_courses_teacher_by_date_desc(param_teacher_id bigint) OWNER TO epathshala;

--
-- Name: get_courses_teacher_by_title_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_teacher_by_title_asc(param_teacher_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COURSES.COURSE_ID,
		COURSES.TITLE,
		TRIM(COURSES.DESCRIPTION)::VARCHAR,
		COURSES.DATE_OF_CREATION,
		COURSES.PRICE,
		COURSES.RATE::NUMERIC(3, 2),
		COURSES.ENROLL_COUNT
	FROM COURSES
	WHERE CREATOR_ID = PARAM_TEACHER_ID
	ORDER BY TITLE ASC;
END;
$$;


ALTER FUNCTION public.get_courses_teacher_by_title_asc(param_teacher_id bigint) OWNER TO epathshala;

--
-- Name: get_courses_teacher_by_title_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_courses_teacher_by_title_desc(param_teacher_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		COURSES.COURSE_ID,
		COURSES.TITLE,
		TRIM(COURSES.DESCRIPTION)::VARCHAR,
		COURSES.DATE_OF_CREATION,
		COURSES.PRICE,
		COURSES.RATE::NUMERIC(3, 2),
		COURSES.ENROLL_COUNT
	FROM COURSES
	WHERE CREATOR_ID = PARAM_TEACHER_ID
	ORDER BY TITLE DESC;
END;
$$;


ALTER FUNCTION public.get_courses_teacher_by_title_desc(param_teacher_id bigint) OWNER TO epathshala;

--
-- Name: get_individual_content_rate(bigint, bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_individual_content_rate(param_user_id bigint, param_content_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	RATE_VALUE INT;
BEGIN
	SELECT RATE INTO RATE_VALUE
	FROM CONTENT_VIEWERS
	WHERE USER_ID = PARAM_USER_ID AND CONTENT_ID = PARAM_CONTENT_ID;
	RETURN RATE_VALUE;
END;
$$;


ALTER FUNCTION public.get_individual_content_rate(param_user_id bigint, param_content_id bigint) OWNER TO epathshala;

--
-- Name: get_interests(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_interests(param_user_id bigint) RETURNS TABLE(interest character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		STUDENT_INTERESTS.INTEREST
	FROM STUDENT_INTERESTS
	WHERE STUDENT_ID = PARAM_USER_ID;
END;
$$;


ALTER FUNCTION public.get_interests(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_new_comment_id(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_new_comment_id() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	MAX_COMMENT_ID BIGINT;
	NEW_COMMENT_ID BIGINT;
BEGIN
	SELECT MAX(COMMENT_ID) INTO MAX_COMMENT_ID
	FROM COMMENTS;
	IF MAX_COMMENT_ID IS NULL THEN
		RETURN 1;
	ELSE
		FOR I IN 1..MAX_COMMENT_ID LOOP
			SELECT COMMENT_ID INTO NEW_COMMENT_ID
			FROM COMMENTS
			WHERE COMMENT_ID = I;
			IF NEW_COMMENT_ID IS NULL THEN
				RETURN I;
			END IF;
		END LOOP;
		RETURN MAX_COMMENT_ID + 1;
	END IF;
END;
$$;


ALTER FUNCTION public.get_new_comment_id() OWNER TO epathshala;

--
-- Name: get_new_content_id(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_new_content_id() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	MAX_CONTENT_ID BIGINT;
	NEW_CONTENT_ID BIGINT;
BEGIN
	SELECT MAX(CONTENT_ID) INTO MAX_CONTENT_ID
	FROM CONTENTS;
	IF MAX_CONTENT_ID IS NULL THEN
		RETURN 1;
	ELSE
		FOR I IN 1..MAX_CONTENT_ID LOOP
			SELECT CONTENT_ID INTO NEW_CONTENT_ID
			FROM CONTENTS
			WHERE CONTENT_ID = I;
			IF NEW_CONTENT_ID IS NULL THEN
				RETURN I;
			END IF;
		END LOOP;
		RETURN MAX_CONTENT_ID + 1;
	END IF;
END;
$$;


ALTER FUNCTION public.get_new_content_id() OWNER TO epathshala;

--
-- Name: get_new_course_id(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_new_course_id() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	MAX_COURSE_ID BIGINT;
	NEW_COURSE_ID BIGINT;
BEGIN
	SELECT MAX(COURSE_ID) INTO MAX_COURSE_ID
	FROM COURSES;
	IF MAX_COURSE_ID IS NULL THEN
		RETURN 1;
	ELSE
		FOR I IN 1..MAX_COURSE_ID LOOP
			SELECT COURSE_ID INTO NEW_COURSE_ID
			FROM COURSES
			WHERE COURSE_ID = I;
			IF NEW_COURSE_ID IS NULL THEN
				RETURN I;
			END IF;
		END LOOP;
		RETURN MAX_COURSE_ID + 1;
	END IF;
END;
$$;


ALTER FUNCTION public.get_new_course_id() OWNER TO epathshala;

--
-- Name: get_new_question_id(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_new_question_id() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	MAX_QUESTION_ID BIGINT;
	NEW_QUESTION_ID BIGINT;
BEGIN
	SELECT MAX(QUESTION_ID) INTO MAX_QUESTION_ID
	FROM FORUM_QUESTIONS;
	IF MAX_QUESTION_ID IS NULL THEN
		RETURN 1;
	ELSE
		FOR I IN 1..MAX_QUESTION_ID LOOP
			SELECT QUESTION_ID INTO NEW_QUESTION_ID
			FROM FORUM_QUESTIONS
			WHERE QUESTION_ID = I;
			IF NEW_QUESTION_ID IS NULL THEN
				RETURN I;
			END IF;
		END LOOP;
		RETURN MAX_QUESTION_ID + 1;
	END IF;
END;
$$;


ALTER FUNCTION public.get_new_question_id() OWNER TO epathshala;

--
-- Name: get_new_user_id(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_new_user_id() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	MAX_USER_ID BIGINT;
	NEW_USER_ID BIGINT;
BEGIN
	SELECT MAX(USER_ID) INTO MAX_USER_ID
	FROM USERS;
	IF MAX_USER_ID IS NULL THEN
		RETURN 1;
	ELSE
		FOR I IN 1..MAX_USER_ID LOOP
			SELECT USER_ID INTO NEW_USER_ID
			FROM USERS
			WHERE USER_ID = I;
			IF NEW_USER_ID IS NULL THEN
				RETURN I;
			END IF;
		END LOOP;
		RETURN MAX_USER_ID + 1;
	END IF;
END;
$$;


ALTER FUNCTION public.get_new_user_id() OWNER TO epathshala;

--
-- Name: get_question_details(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_question_details(param_question_id bigint) RETURNS TABLE(question_id bigint, title character varying, asker_id bigint, asker_name character varying, date_of_ask date, time_of_ask time with time zone, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		FORUM_QUESTIONS.QUESTION_ID,
		FORUM_QUESTIONS.TITLE,
		FORUM_QUESTIONS.ASKER_ID,
		USERS.FULL_NAME,
		FORUM_QUESTIONS.DATE_OF_ASK,
		FORUM_QUESTIONS.TIME_OF_ASK::TIME(0) WITH TIME ZONE,
		FORUM_QUESTIONS.RATE::NUMERIC(3, 2)
	FROM FORUM_QUESTIONS
	JOIN USERS
	ON (FORUM_QUESTIONS.ASKER_ID = USERS.USER_ID)
	WHERE FORUM_QUESTIONS.QUESTION_ID = PARAM_QUESTION_ID;
END;
$$;


ALTER FUNCTION public.get_question_details(param_question_id bigint) OWNER TO epathshala;

--
-- Name: get_questions(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_questions() RETURNS TABLE(question_id bigint, title character varying, asker_id bigint, asker_name character varying, date_of_ask date, time_of_ask time with time zone, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		FORUM_QUESTIONS.QUESTION_ID,
		FORUM_QUESTIONS.TITLE,
		FORUM_QUESTIONS.ASKER_ID,
		USERS.FULL_NAME,
		FORUM_QUESTIONS.DATE_OF_ASK,
		FORUM_QUESTIONS.TIME_OF_ASK::TIME(0) WITH TIME ZONE,
		FORUM_QUESTIONS.RATE::NUMERIC(3, 2)
	FROM FORUM_QUESTIONS
	JOIN USERS
	ON (FORUM_QUESTIONS.ASKER_ID = USERS.USER_ID)
	ORDER BY FORUM_QUESTIONS.DATE_OF_ASK DESC;
END;
$$;


ALTER FUNCTION public.get_questions() OWNER TO epathshala;

--
-- Name: get_specialities(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_specialities(param_teacher_id bigint) RETURNS TABLE(speciality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		TEACHER_SPECIALITIES.SPECIALITY
	FROM TEACHER_SPECIALITIES
	WHERE TEACHER_ID = PARAM_TEACHER_ID;
END;
$$;


ALTER FUNCTION public.get_specialities(param_teacher_id bigint) OWNER TO epathshala;

--
-- Name: get_student_courses_by_rate_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_student_courses_by_rate_asc(param_user_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, creator_id bigint, creator_name character varying, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.CREATOR_ID, USERS.FULL_NAME, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	JOIN ENROLLED_COURSES
	ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)
	JOIN USERS
	ON(COURSES.CREATOR_ID = USERS.USER_ID)
	WHERE ENROLLED_COURSES.USER_ID = PARAM_USER_ID
	ORDER BY COURSES.RATE ASC;
END;
$$;


ALTER FUNCTION public.get_student_courses_by_rate_asc(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_student_courses_by_rate_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_student_courses_by_rate_desc(param_user_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, creator_id bigint, creator_name character varying, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.CREATOR_ID, USERS.FULL_NAME, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	JOIN ENROLLED_COURSES
	ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)
	JOIN USERS
	ON(COURSES.CREATOR_ID = USERS.USER_ID)
	WHERE ENROLLED_COURSES.USER_ID = PARAM_USER_ID
	ORDER BY COURSES.RATE DESC;
END;
$$;


ALTER FUNCTION public.get_student_courses_by_rate_desc(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_student_courses_by_title_asc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_student_courses_by_title_asc(param_user_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, creator_id bigint, creator_name character varying, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.CREATOR_ID, USERS.FULL_NAME, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	JOIN ENROLLED_COURSES
	ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)
	JOIN USERS
	ON(COURSES.CREATOR_ID = USERS.USER_ID)
	WHERE ENROLLED_COURSES.USER_ID = PARAM_USER_ID
	ORDER BY COURSES.TITLE ASC;
END;
$$;


ALTER FUNCTION public.get_student_courses_by_title_asc(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_student_courses_by_title_desc(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_student_courses_by_title_desc(param_user_id bigint) RETURNS TABLE(course_id bigint, title character varying, description character varying, date_of_creation date, price integer, creator_id bigint, creator_name character varying, rate numeric, enroll_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT COURSES.COURSE_ID, COURSES.TITLE, TRIM(COURSES.DESCRIPTION)::VARCHAR, COURSES.DATE_OF_CREATION, COURSES.PRICE, COURSES.CREATOR_ID, USERS.FULL_NAME, COURSES.RATE::NUMERIC(3, 2), COURSES.ENROLL_COUNT
	FROM COURSES
	JOIN ENROLLED_COURSES
	ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)
	JOIN USERS
	ON(COURSES.CREATOR_ID = USERS.USER_ID)
	WHERE ENROLLED_COURSES.USER_ID = PARAM_USER_ID
	ORDER BY COURSES.TITLE DESC;
END;
$$;


ALTER FUNCTION public.get_student_courses_by_title_desc(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_student_details(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_student_details(param_user_id bigint) RETURNS TABLE(user_id bigint, full_name character varying, date_of_birth date, bio character varying, email character varying, date_of_join date, rank_point integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT 
	    USERS.USER_ID, 
	    USERS.FULL_NAME,  
	    USERS.DATE_OF_BIRTH, 
	    TRIM(USERS.BIO)::VARCHAR, 
	    USERS.EMAIL, 
	    STUDENTS.DATE_OF_JOIN, 
	    STUDENTS.RANK_POINT
	FROM USERS
	JOIN STUDENTS
	ON(USERS.USER_ID = STUDENTS.USER_ID)
	WHERE USERS.USER_ID = PARAM_USER_ID;
END;
$$;


ALTER FUNCTION public.get_student_details(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_teacher_details(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_teacher_details(param_teacher_id bigint) RETURNS TABLE(user_id bigint, full_name character varying, email character varying, bio character varying, date_of_birth date, date_of_join date, rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		USERS.USER_ID,
		USERS.FULL_NAME,
		USERS.EMAIL,
		TRIM(USERS.BIO)::VARCHAR,
		USERS.DATE_OF_BIRTH,
		TEACHERS.DATE_OF_JOIN,
		TEACHERS.RATE::NUMERIC(3, 2)
	FROM USERS
	JOIN TEACHERS
	ON (USERS.USER_ID = TEACHERS.USER_ID)
	WHERE USERS.USER_ID = PARAM_TEACHER_ID;
END;
$$;


ALTER FUNCTION public.get_teacher_details(param_teacher_id bigint) OWNER TO epathshala;

--
-- Name: get_user_details(bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_user_details(param_user_id bigint) RETURNS TABLE(user_id bigint, full_name character varying, date_of_birth date, bio character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT USERS.USER_ID, USERS.FULL_NAME, USERS.DATE_OF_BIRTH, TRIM(USERS.BIO)::VARCHAR, USERS.EMAIL
	FROM USERS
	WHERE USERS.USER_ID = PARAM_USER_ID;
END;
$$;


ALTER FUNCTION public.get_user_details(param_user_id bigint) OWNER TO epathshala;

--
-- Name: get_user_id(character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.get_user_id(param_email character varying, param_security_key character varying, param_type boolean) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	RETURN_USER_ID BIGINT;
	USER_SECURITY_KEY VARCHAR;
BEGIN
	IF LENGTH(PARAM_EMAIL) = 0 THEN
		RETURN -1;
	END IF;
	IF PARAM_EMAIL NOT LIKE '%_@_%.___' THEN
		RETURN -2;
	END IF;
	IF LENGTH(PARAM_SECURITY_KEY) < 8 OR LENGTH(PARAM_SECURITY_KEY) > 32 THEN
		RETURN -3;
	END IF;
	IF PARAM_TYPE THEN
		SELECT USERS.USER_ID INTO RETURN_USER_ID
		FROM USERS
		JOIN STUDENTS
		ON(USERS.USER_ID = STUDENTS.USER_ID)
		WHERE EMAIL = PARAM_EMAIL;
	ELSE
		SELECT USERS.USER_ID INTO RETURN_USER_ID
		FROM USERS
		JOIN TEACHERS
		ON(USERS.USER_ID = TEACHERS.USER_ID)
		WHERE EMAIL = PARAM_EMAIL;
	END IF;
	IF RETURN_USER_ID IS NULL THEN
		RETURN -4;
	END IF;
	SELECT SECURITY_KEY INTO USER_SECURITY_KEY
	FROM USERS
	WHERE USER_ID = RETURN_USER_ID;
	IF USER_SECURITY_KEY = PARAM_SECURITY_KEY THEN
		RETURN RETURN_USER_ID;
	ELSE
		RETURN -5;
	END IF;
END;
$$;


ALTER FUNCTION public.get_user_id(param_email character varying, param_security_key character varying, param_type boolean) OWNER TO epathshala;

--
-- Name: insert_content(character varying, bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_content(param_content_type character varying, param_course_id bigint, param_title character varying, param_description character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_CONTENT_ID BIGINT;
BEGIN
	NEW_CONTENT_ID := GET_NEW_CONTENT_ID();
	INSERT INTO CONTENTS (CONTENT_ID, TITLE, DESCRIPTION, COURSE_ID, CONTENT_TYPE)
	VALUES (NEW_CONTENT_ID, PARAM_TITLE, PARAM_DESCRIPTION, PARAM_COURSE_ID, PARAM_CONTENT_TYPE);
	RETURN NEW_CONTENT_ID;
END;
$$;


ALTER FUNCTION public.insert_content(param_content_type character varying, param_course_id bigint, param_title character varying, param_description character varying) OWNER TO epathshala;

--
-- Name: insert_course(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_course(param_course_title character varying, param_course_description character varying, param_course_price character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_COURSE_ID BIGINT;
	NEW_COURSE_PRICE INT;
BEGIN
	IF LENGTH(PARAM_COURSE_TITLE) = 0 THEN
		RETURN 1; --EMPTY COURSE TITLE ERROR
	END IF;
	IF LENGTH(PARAM_COURSE_PRICE) = 0 THEN
		NEW_COURSE_PRICE := 0;
	ELSE
		NEW_COURSE_PRICE := PARAM_COURSE_PRICE::INT;
	END IF;
	NEW_COURSE_ID = GET_NEW_COURSE_ID();
	INSERT INTO COURSES
	(COURSE_ID, TITLE, DESCRIPTION, PRICE, CREATOR_ID)
	VALUES(NEW_COURSE_ID, PARAM_COURSE_TITLE, PARAM_COURSE_DESCRIPTION, NEW_COURSE_PRICE, NEW_COURSE_ID);
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.insert_course(param_course_title character varying, param_course_description character varying, param_course_price character varying) OWNER TO epathshala;

--
-- Name: insert_course(bigint, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_course(param_teacher_id bigint, param_course_title character varying, param_course_description character varying, param_course_price character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_COURSE_ID BIGINT;
	NEW_COURSE_PRICE INT;
BEGIN
	IF LENGTH(PARAM_COURSE_TITLE) = 0 THEN
		RETURN 1; --EMPTY COURSE TITLE ERROR
	END IF;
	IF LENGTH(PARAM_COURSE_PRICE) = 0 THEN
		NEW_COURSE_PRICE := 0;
	ELSE
		NEW_COURSE_PRICE := PARAM_COURSE_PRICE::INT;
	END IF;
	NEW_COURSE_ID = GET_NEW_COURSE_ID();
	INSERT INTO COURSES
	(COURSE_ID, TITLE, DESCRIPTION, PRICE, CREATOR_ID)
	VALUES(NEW_COURSE_ID, PARAM_COURSE_TITLE, PARAM_COURSE_DESCRIPTION, NEW_COURSE_PRICE, PARAM_TEACHER_ID);
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.insert_course(param_teacher_id bigint, param_course_title character varying, param_course_description character varying, param_course_price character varying) OWNER TO epathshala;

--
-- Name: insert_interest(bigint, character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.insert_interest(IN param_student_id bigint, IN param_interest character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO STUDENT_INTERESTS (STUDENT_ID, INTEREST)
	VALUES
		(PARAM_STUDENT_ID, PARAM_INTEREST);
END;
$$;


ALTER PROCEDURE public.insert_interest(IN param_student_id bigint, IN param_interest character varying) OWNER TO epathshala;

--
-- Name: insert_question(character varying, character varying[], bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_question(param_title character varying, param_tags character varying[], param_asker_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.insert_question(param_title character varying, param_tags character varying[], param_asker_id bigint) OWNER TO epathshala;

--
-- Name: insert_speciality(bigint, character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.insert_speciality(IN param_teacher_id bigint, IN param_speciality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO TEACHER_SPECIALITIES (TEACHER_ID, SPECIALITY)
	VALUES (PARAM_TEACHER_ID, PARAM_SPECIALITY);
END;
$$;


ALTER PROCEDURE public.insert_speciality(IN param_teacher_id bigint, IN param_speciality character varying) OWNER TO epathshala;

--
-- Name: insert_student(bigint); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.insert_student(IN param_user_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO STUDENTS (USER_ID)
	VALUES
		(PARAM_USER_ID);
END;
$$;


ALTER PROCEDURE public.insert_student(IN param_user_id bigint) OWNER TO epathshala;

--
-- Name: insert_teacher(bigint); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.insert_teacher(IN param_user_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO TEACHERS (USER_ID)
	VALUES (PARAM_USER_ID);
END;
$$;


ALTER PROCEDURE public.insert_teacher(IN param_user_id bigint) OWNER TO epathshala;

--
-- Name: insert_user(character varying, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_user(param_full_name character varying, param_email character varying, param_password character varying, param_date_of_birth character varying, param_student boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_USER_ID BIGINT;
	FOUND_USER BIGINT;
BEGIN
	NEW_USER_ID := GET_NEW_USER_ID();
	IF PARAM_STUDENT THEN
		SELECT USERS.USER_ID INTO FOUND_USER
		FROM USERS
		JOIN STUDENTS
		ON(USERS.USER_ID = STUDENTS.USER_ID)
		WHERE EMAIL = PARAM_EMAIL;
		IF FOUND_USER IS NULL THEN
			SELECT USER_ID INTO FOUND_USER
			FROM USERS
			WHERE EMAIL = PARAM_EMAIL;
			IF FOUND_USER IS NULL THEN
				INSERT INTO USERS (USER_ID, FULL_NAME, EMAIL, SECURITY_KEY, DATE_OF_BIRTH, USER_TYPE)
				VALUES (NEW_USER_ID, PARAM_FULL_NAME, PARAM_EMAIL, PARAM_PASSWORD, TO_DATE(PARAM_DATE_OF_BIRTH, 'YYYY-MM-DD'), 'STUDENT');
			ELSE
				INSERT INTO STUDENTS (USER_ID)
				VALUES (FOUND_USER);
			END IF;
		ELSE
			RETURN 1; --USER PRESENT
		END IF;
	ELSE
		SELECT USERS.USER_ID INTO FOUND_USER
		FROM USERS
		JOIN TEACHERS
		ON(USERS.USER_ID = TEACHERS.USER_ID)
		WHERE EMAIL = PARAM_EMAIL;
		IF FOUND_USER IS NULL THEN
			SELECT USER_ID INTO FOUND_USER
			FROM USERS
			WHERE EMAIL = PARAM_EMAIL;
			IF FOUND_USER IS NULL THEN
				INSERT INTO USERS (USER_ID, FULL_NAME, EMAIL, SECURITY_KEY, DATE_OF_BIRTH, USER_TYPE)
				VALUES (NEW_USER_ID, PARAM_FULL_NAME, PARAM_EMAIL, PARAM_PASSWORD, TO_DATE(PARAM_DATE_OF_BIRTH, 'YYYY-MM-DD'), 'TEACHERS');
			ELSE
				INSERT INTO TEACHERS (USER_ID)
				VALUES (FOUND_USER);
			END IF;
		ELSE
			RETURN 1; --USER PRESENT
		END IF;
	END IF;
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.insert_user(param_full_name character varying, param_email character varying, param_password character varying, param_date_of_birth character varying, param_student boolean) OWNER TO epathshala;

--
-- Name: insert_user_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_user_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
	IF NEW.USER_TYPE = 'STUDENT' THEN
		INSERT INTO STUDENTS
		(USER_ID)
		VALUES (NEW.USER_ID);
	ELSE
		INSERT INTO TEACHERS
		(USER_ID)
		VALUES (NEW.USER_ID);
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_user_trigger() OWNER TO epathshala;

--
-- Name: insert_view(bigint, bigint); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_view(param_user_id bigint, param_content_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO CONTENT_VIEWERS (USER_ID, CONTENT_ID)
	VALUES (PARAM_USER_ID, PARAM_CONTENT_ID);
	RETURN 0; --SUCCESS
EXCEPTION
	WHEN UNIQUE_VIOLATION THEN
		RETURN 1; --ALREADT VIEWED
END;
$$;


ALTER FUNCTION public.insert_view(param_user_id bigint, param_content_id bigint) OWNER TO epathshala;

--
-- Name: is_leap_year(integer); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.is_leap_year(param_year integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN ((PARAM_YEAR % 4 = 0 AND PARAM_YEAR % 1000 != 0) OR PARAM_YEAR % 400 = 0);
END;
$$;


ALTER FUNCTION public.is_leap_year(param_year integer) OWNER TO epathshala;

--
-- Name: is_valid_date(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.is_valid_date(param_day integer, param_month integer, param_year integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
	IF PARAM_MONTH = 2 THEN
		IF IS_LEAP_YEAR(PARAM_YEAR) THEN
			RETURN PARAM_DAY <= 29;
		ELSE
			RETURN PARAM_DAY <= 28;
		END IF;
	END IF;
	IF PARAM_MONTH IN (4, 6, 9, 11) THEN
		RETURN PARAM_DAY <= 30;
	END IF;
	RETURN TRUE;
END;
$$;


ALTER FUNCTION public.is_valid_date(param_day integer, param_month integer, param_year integer) OWNER TO epathshala;

--
-- Name: login(character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.login(param_email character varying, param_password character varying, param_student boolean) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	FOUND_USER_ID BIGINT;
BEGIN
	IF PARAM_STUDENT THEN
		SELECT USERS.USER_ID INTO FOUND_USER_ID
		FROM USERS
		JOIN STUDENTS
		ON (USERS.USER_ID = STUDENTS.USER_ID)
		WHERE EMAIL = PARAM_EMAIL;
	ELSE
		SELECT USERS.USER_ID INTO FOUND_USER_ID
		FROM USERS
		JOIN TEACHERS
		ON (USERS.USER_ID = TEACHERS.USER_ID)
		WHERE EMAIL = PARAM_EMAIL;
	END IF;
	IF FOUND_USER_ID IS NULL THEN
		RETURN -1; --EMAIL NOT FOUND
	END IF;
	SELECT USER_ID INTO FOUND_USER_ID
	FROM USERS
	WHERE EMAIL = PARAM_EMAIL AND SECURITY_KEY = PARAM_PASSWORD;
	IF FOUND_USER_ID IS NULL THEN
		RETURN -2; --PASSWORD NOT MATCHED
	END IF;
	RETURN FOUND_USER_ID; --SUCCESS
END;
$$;


ALTER FUNCTION public.login(param_email character varying, param_password character varying, param_student boolean) OWNER TO epathshala;

--
-- Name: pay_course_teacher_credit(bigint, integer); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.pay_course_teacher_credit(IN param_course_id bigint, IN param_amount integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
	COURSE_TEACHER_ID BIGINT;
BEGIN
	SELECT CREATOR_ID INTO COURSE_TEACHER_ID
	FROM COURSES
	WHERE COURSE_ID = PARAM_COURSE_ID;
	UPDATE TEACHERS
	SET CREDIT = CREDIT + PARAM_AMOUNT
	WHERE USER_ID = COURSE_TEACHER_ID;
END;
$$;


ALTER PROCEDURE public.pay_course_teacher_credit(IN param_course_id bigint, IN param_amount integer) OWNER TO epathshala;

--
-- Name: post_comment(bigint, bigint, character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.post_comment(IN param_user_id bigint, IN param_content_id bigint, IN param_description character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_COMMENT_ID BIGINT;
BEGIN
	NEW_COMMENT_ID := GET_NEW_COMMENT_ID();
	INSERT INTO COMMENTS (COMMENT_ID, CONTENT_ID, COMMENTER_ID, DESCRIPTION)
	VALUES
		(NEW_COMMENT_ID, PARAM_CONTENT_ID, PARAM_USER_ID, PARAM_DESCRIPTION);
END;
$$;


ALTER PROCEDURE public.post_comment(IN param_user_id bigint, IN param_content_id bigint, IN param_description character varying) OWNER TO epathshala;

--
-- Name: print(character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.print(IN to_print character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RAISE NOTICE '%', TO_PRINT;
END;
$$;


ALTER PROCEDURE public.print(IN to_print character varying) OWNER TO epathshala;

--
-- Name: teachers_rate_trigger(); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.teachers_rate_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	AVERAGE_RATE NUMERIC;
	ID BIGINT;
BEGIN
	IF NEW.CREATOR_ID IS NOT NULL THEN
		ID := NEW.CREATOR_ID;
	ELSE
		ID := OLD.CREATOR_ID;
	END IF;
	SELECT AVG(RATE) INTO AVERAGE_RATE
	FROM COURSES
	WHERE CREATOR_ID = ID AND RATE != 0;
	IF AVERAGE_RATE IS NULL THEN
		AVERAGE_RATE := 0;
	END IF;
	UPDATE TEACHERS
	SET RATE = AVERAGE_RATE
	WHERE USER_ID = ID;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.teachers_rate_trigger() OWNER TO epathshala;

--
-- Name: update_comment(bigint, character varying); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.update_comment(IN param_comment_id bigint, IN param_description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE COMMENTS
	SET DESCRIPTION = PARAM_DESCRIPTION
	WHERE COMMENT_ID = PARAM_COMMENT_ID;
END;
$$;


ALTER PROCEDURE public.update_comment(IN param_comment_id bigint, IN param_description character varying) OWNER TO epathshala;

--
-- Name: update_comment_rate(bigint, numeric); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.update_comment_rate(IN param_comment_id bigint, IN param_rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE COMMENTS
	SET RATE = PARAM_RATE
	WHERE COMMENT_ID = PARAM_COMMENT_ID;
END;
$$;


ALTER PROCEDURE public.update_comment_rate(IN param_comment_id bigint, IN param_rate numeric) OWNER TO epathshala;

--
-- Name: update_content_rate(bigint, bigint, integer); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.update_content_rate(IN param_user_id bigint, IN param_content_id bigint, IN param_rate integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE CONTENT_VIEWERS
	SET RATE = PARAM_RATE
	WHERE USER_ID = PARAM_USER_ID AND CONTENT_ID = PARAM_CONTENT_ID;
END;
$$;


ALTER PROCEDURE public.update_content_rate(IN param_user_id bigint, IN param_content_id bigint, IN param_rate integer) OWNER TO epathshala;

--
-- Name: update_course(bigint, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: epathshala
--

CREATE PROCEDURE public.update_course(IN param_course_id bigint, IN param_title character varying, IN param_description character varying, IN param_price integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE COURSES
	SET
		TITLE = PARAM_TITLE,
		DESCRIPTION = PARAM_DESCRIPTION,
		PRICE = PARAM_PRICE
	WHERE
		COURSE_ID = PARAM_COURSE_ID;
END;
$$;


ALTER PROCEDURE public.update_course(IN param_course_id bigint, IN param_title character varying, IN param_description character varying, IN param_price integer) OWNER TO epathshala;

--
-- Name: update_page(bigint, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.update_page(param_content_id bigint, param_title character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	DUPLICATE_PAGE_ID BIGINT;
	CONTENT_COURSE_ID BIGINT;
BEGIN
	SELECT COURSE_ID INTO CONTENT_COURSE_ID
	FROM CONTENTS
	WHERE CONTENT_ID = PARAM_CONTENT_ID;
	SELECT CONTENT_ID INTO DUPLICATE_PAGE_ID
	FROM CONTENTS
	WHERE CONTENT_TYPE = 'PAGE' AND TITLE = PARAM_TITLE AND COURSE_ID = CONTENT_COURSE_ID AND CONTENT_ID != PARAM_CONTENT_ID;
	IF DUPLICATE_PAGE_ID IS NOT NULL THEN
		RETURN -1; --DUPLICATE NAME ERROR
	END IF;
	UPDATE CONTENTS
	SET
		TITLE = PARAM_TITLE
	WHERE CONTENT_ID  = PARAM_CONTENT_ID;
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.update_page(param_content_id bigint, param_title character varying) OWNER TO epathshala;

--
-- Name: update_user_details(bigint, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.update_user_details(param_user_id bigint, param_full_name character varying, param_email character varying, param_password character varying, param_bio character varying, param_date_of_birth character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF LENGTH(PARAM_FULL_NAME) = 0 THEN
		RETURN 1; --EMPTY FULL NAME
	ELSIF LENGTH(PARAM_EMAIL) = 0 THEN
		RETURN 2; --EMPTY EMAIL
	ELSIF PARAM_EMAIL NOT LIKE '%_@_%.___' THEN
		RETURN 3; --INVALID EMAIL
	ELSIF LENGTH(PARAM_PASSWORD) < 8 THEN
		RETURN 4; --PASSWORD TOO SMALL
	ELSIF LENGTH(PARAM_PASSWORD) > 32 THEN
		RETURN 5; --PASSWORD TOO BIG
	END IF;
	UPDATE USERS
	SET FULL_NAME = PARAM_FULL_NAME,
		EMAIL = PARAM_EMAIL,
		SECURITY_KEY = PARAM_PASSWORD,
		BIO = PARAM_BIO,
		DATE_OF_BIRTH = TO_DATE(PARAM_DATE_OF_BIRTH, 'YYYY-MM-DD')
	WHERE USER_ID = PARAM_USER_ID;
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.update_user_details(param_user_id bigint, param_full_name character varying, param_email character varying, param_password character varying, param_bio character varying, param_date_of_birth character varying) OWNER TO epathshala;

--
-- Name: update_video(bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.update_video(param_content_id bigint, param_title character varying, param_description character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	DUPLICATE_VIDEO_ID BIGINT;
	CONTENT_COURSE_ID BIGINT;
BEGIN
	SELECT COURSE_ID INTO CONTENT_COURSE_ID
	FROM CONTENTS
	WHERE CONTENT_ID = PARAM_CONTENT_ID;
	SELECT CONTENT_ID INTO DUPLICATE_VIDEO_ID
	FROM CONTENTS
	WHERE CONTENT_TYPE = 'VIDEO' AND TITLE = PARAM_TITLE AND COURSE_ID = CONTENT_COURSE_ID AND CONTENT_ID != PARAM_CONTENT_ID;
	IF DUPLICATE_VIDEO_ID IS NOT NULL THEN
		RETURN -1; --DUPLICATE NAME ERROR
	END IF;
	UPDATE CONTENTS
	SET
		TITLE = PARAM_TITLE,
		DESCRIPTION = PARAM_DESCRIPTION
	WHERE CONTENT_ID  = PARAM_CONTENT_ID;
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.update_video(param_content_id bigint, param_title character varying, param_description character varying) OWNER TO epathshala;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: banks; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.banks (
    bank_id bigint NOT NULL,
    name character varying,
    CONSTRAINT bank_bank_id_check CHECK ((bank_id > 0))
);


ALTER TABLE public.banks OWNER TO epathshala;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.comments (
    comment_id bigint NOT NULL,
    content_id bigint NOT NULL,
    commenter_id bigint,
    description character(100) DEFAULT ''::bpchar,
    "time" time without time zone DEFAULT CURRENT_TIME,
    date date DEFAULT CURRENT_DATE,
    rate numeric DEFAULT 0,
    CONSTRAINT comments_comment_id_check CHECK ((comment_id > 0)),
    CONSTRAINT comments_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric)))
);


ALTER TABLE public.comments OWNER TO epathshala;

--
-- Name: content_viewers_content_id_seq; Type: SEQUENCE; Schema: public; Owner: epathshala
--

CREATE SEQUENCE public.content_viewers_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.content_viewers_content_id_seq OWNER TO epathshala;

--
-- Name: content_viewers; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.content_viewers (
    view_id bigint DEFAULT (nextval('public.content_viewers_content_id_seq'::regclass))::regclass NOT NULL,
    content_id bigint,
    user_id bigint,
    rate numeric DEFAULT 0,
    completed boolean DEFAULT false,
    CONSTRAINT content_viewers_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric))),
    CONSTRAINT content_viewers_view_id_check CHECK ((view_id > 0))
);


ALTER TABLE public.content_viewers OWNER TO epathshala;

--
-- Name: contents; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.contents (
    content_id bigint NOT NULL,
    date_of_creation date DEFAULT CURRENT_DATE,
    content_type character(10) NOT NULL,
    title character varying DEFAULT ''::character varying,
    description character(100) DEFAULT ''::bpchar,
    course_id bigint,
    rate numeric DEFAULT 0,
    view_count bigint DEFAULT 0,
    CONSTRAINT contents_content_id_check CHECK ((content_id > 0)),
    CONSTRAINT contents_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric))),
    CONSTRAINT contents_view_count_check CHECK ((view_count >= 0))
);


ALTER TABLE public.contents OWNER TO epathshala;

--
-- Name: course_remain_contents; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.course_remain_contents (
    user_id bigint NOT NULL,
    course_id bigint NOT NULL,
    complete_count bigint DEFAULT 0,
    remain_count bigint,
    CONSTRAINT course_remain_contents_complete_count_check CHECK ((complete_count >= 0)),
    CONSTRAINT course_remain_contents_remain_count_check CHECK ((remain_count >= 0))
);


ALTER TABLE public.course_remain_contents OWNER TO epathshala;

--
-- Name: course_tags; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.course_tags (
    course_id bigint NOT NULL,
    tag character varying NOT NULL
);


ALTER TABLE public.course_tags OWNER TO epathshala;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.courses (
    course_id bigint NOT NULL,
    title character varying NOT NULL,
    description character(100) DEFAULT ''::bpchar,
    date_of_creation date DEFAULT CURRENT_DATE NOT NULL,
    price integer DEFAULT 0,
    creator_id bigint,
    rate numeric DEFAULT 0,
    enroll_count bigint DEFAULT 0,
    CONSTRAINT courses_course_id_check CHECK ((course_id > 0)),
    CONSTRAINT courses_enroll_count_check CHECK ((enroll_count >= 0)),
    CONSTRAINT courses_price_check CHECK ((price >= 0)),
    CONSTRAINT courses_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric)))
);


ALTER TABLE public.courses OWNER TO epathshala;

--
-- Name: enrolled_courses; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.enrolled_courses (
    user_id bigint NOT NULL,
    course_id bigint NOT NULL,
    date_of_join date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.enrolled_courses OWNER TO epathshala;

--
-- Name: forum_questions; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.forum_questions (
    question_id bigint NOT NULL,
    asker_id bigint,
    title character varying,
    date_of_ask date DEFAULT CURRENT_DATE,
    rate numeric DEFAULT 0,
    time_of_ask time without time zone DEFAULT CURRENT_TIME,
    CONSTRAINT forum_questions_question_id_check CHECK ((question_id > 0)),
    CONSTRAINT forum_questions_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric)))
);


ALTER TABLE public.forum_questions OWNER TO epathshala;

--
-- Name: forum_questions_tags; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.forum_questions_tags (
    question_id bigint NOT NULL,
    tag character varying NOT NULL
);


ALTER TABLE public.forum_questions_tags OWNER TO epathshala;

--
-- Name: query_count; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.query_count (
    count bigint
);


ALTER TABLE public.query_count OWNER TO epathshala;

--
-- Name: quiz_grades; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.quiz_grades (
    user_id bigint NOT NULL,
    content_id bigint NOT NULL,
    grade integer,
    CONSTRAINT quiz_grades_grade_check CHECK (((0 <= grade) AND (grade <= 100)))
);


ALTER TABLE public.quiz_grades OWNER TO epathshala;

--
-- Name: student_interests; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.student_interests (
    student_id bigint NOT NULL,
    interest character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.student_interests OWNER TO epathshala;

--
-- Name: students; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.students (
    user_id bigint NOT NULL,
    date_of_join date DEFAULT CURRENT_DATE NOT NULL,
    rank_point integer DEFAULT 0,
    CONSTRAINT students_rank_point_check CHECK ((rank_point >= 0))
);


ALTER TABLE public.students OWNER TO epathshala;

--
-- Name: teacher_specialities; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.teacher_specialities (
    teacher_id bigint NOT NULL,
    speciality character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.teacher_specialities OWNER TO epathshala;

--
-- Name: teachers; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.teachers (
    user_id bigint NOT NULL,
    date_of_join date DEFAULT CURRENT_DATE NOT NULL,
    credit integer DEFAULT 0,
    rate numeric DEFAULT 0,
    CONSTRAINT teachers_credit_check CHECK ((credit >= 0)),
    CONSTRAINT teachers_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric)))
);


ALTER TABLE public.teachers OWNER TO epathshala;

--
-- Name: users; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    full_name character varying,
    security_key character(32) NOT NULL,
    date_of_birth date,
    bio character(100) DEFAULT ''::bpchar,
    email character varying NOT NULL,
    CONSTRAINT users_email_check CHECK (((email)::text ~~ '_%@_%.___'::text)),
    CONSTRAINT users_security_key_check CHECK ((length(security_key) >= 8)),
    CONSTRAINT users_user_id_check CHECK ((user_id > 0))
);


ALTER TABLE public.users OWNER TO epathshala;

--
-- Data for Name: banks; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.banks (bank_id, name) FROM stdin;
1	A Bank
2	B Bank
3	C Bank
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.comments (comment_id, content_id, commenter_id, description, "time", date, rate) FROM stdin;
1	5	5	Epic Video                                                                                          	23:43:54.742951	2022-08-09	0
3	5	5	Loved it                                                                                            	20:04:31.84021	2022-08-24	0
4	11	1	Ekta comment                                                                                        	22:44:10.661988	2022-08-29	0
5	11	1	Arekta comment (edited)                                                                             	22:46:22.296031	2022-08-29	0
6	5	1	Make more videos like this                                                                          	23:18:39.012789	2022-08-29	0
\.


--
-- Data for Name: content_viewers; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.content_viewers (view_id, content_id, user_id, rate, completed) FROM stdin;
2431	19	14	3	f
2433	2	2	3	f
2313	24	47	0	f
1	97	1	0	f
78	5	1	0	f
70	11	1	0	f
2	96	1	0	f
3	95	1	0	f
4	98	1	0	f
5	92	1	0	f
6	93	1	0	f
7	89	1	0	f
8	90	1	0	f
9	94	1	0	f
10	91	1	0	f
11	84	1	0	f
12	81	1	0	f
13	88	1	0	f
14	83	1	0	f
15	80	1	0	f
16	85	1	0	f
2314	8	47	0	f
2315	35	47	0	f
17	87	1	0	f
18	79	1	0	f
19	82	1	0	f
20	86	1	0	f
21	73	1	0	f
22	65	1	0	f
23	63	1	0	f
24	75	1	0	f
25	59	1	0	f
26	71	1	0	f
27	66	1	0	f
28	76	1	0	f
29	74	1	0	f
30	58	1	0	f
31	78	1	0	f
32	62	1	0	f
33	64	1	0	f
34	67	1	0	f
35	61	1	0	f
36	69	1	0	f
37	70	1	0	f
38	77	1	0	f
39	68	1	0	f
40	72	1	0	f
41	60	1	0	f
42	57	1	0	f
43	40	1	0	f
44	56	1	0	f
45	53	1	0	f
46	55	1	0	f
47	45	1	0	f
48	36	1	0	f
49	29	1	0	f
50	30	1	0	f
51	49	1	0	f
52	52	1	0	f
53	48	1	0	f
54	43	1	0	f
55	31	1	0	f
56	47	1	0	f
57	44	1	0	f
58	50	1	0	f
59	33	1	0	f
60	41	1	0	f
61	35	1	0	f
62	3	1	0	f
63	22	1	0	f
64	1	1	0	f
65	12	1	0	f
66	2	1	0	f
67	4	1	0	f
68	27	1	0	f
69	26	1	0	f
71	17	1	0	f
72	18	1	0	f
73	19	1	0	f
74	15	1	0	f
75	24	1	0	f
76	8	1	0	f
77	7	1	0	f
79	9	1	0	f
80	10	1	0	f
81	13	1	0	f
82	14	1	0	f
83	21	1	0	f
84	23	1	0	f
85	6	1	0	f
86	16	1	0	f
87	20	1	0	f
88	28	1	0	f
89	25	1	0	f
90	39	1	0	f
91	38	1	0	f
92	51	1	0	f
93	54	1	0	f
94	37	1	0	f
95	42	1	0	f
96	32	1	0	f
97	34	1	0	f
98	46	1	0	f
99	87	3	0	f
100	79	3	0	f
101	82	3	0	f
102	86	3	0	f
103	62	3	0	f
104	64	3	0	f
105	67	3	0	f
106	61	3	0	f
107	69	3	0	f
108	70	3	0	f
109	45	3	0	f
110	36	3	0	f
111	29	3	0	f
112	30	3	0	f
113	49	3	0	f
114	52	3	0	f
115	48	3	0	f
116	43	3	0	f
117	31	3	0	f
118	92	3	0	f
119	93	3	0	f
120	89	3	0	f
121	90	3	0	f
122	94	3	0	f
123	91	3	0	f
124	84	3	0	f
125	81	3	0	f
126	88	3	0	f
127	83	3	0	f
128	80	3	0	f
129	85	3	0	f
130	73	3	0	f
131	65	3	0	f
132	63	3	0	f
133	75	3	0	f
134	59	3	0	f
135	71	3	0	f
136	66	3	0	f
137	76	3	0	f
138	74	3	0	f
139	58	3	0	f
140	78	3	0	f
141	77	3	0	f
142	68	3	0	f
143	72	3	0	f
144	60	3	0	f
145	57	3	0	f
146	40	3	0	f
147	56	3	0	f
148	53	3	0	f
149	55	3	0	f
150	44	3	0	f
151	50	3	0	f
152	33	3	0	f
153	41	3	0	f
154	35	3	0	f
155	3	3	0	f
156	22	3	0	f
157	1	3	0	f
158	12	3	0	f
159	24	3	0	f
160	8	3	0	f
161	7	3	0	f
162	5	3	0	f
163	9	3	0	f
164	10	3	0	f
165	13	3	0	f
166	14	3	0	f
167	21	3	0	f
168	54	3	0	f
169	37	3	0	f
170	42	3	0	f
171	32	3	0	f
172	34	3	0	f
173	46	3	0	f
174	47	3	0	f
175	2	3	0	f
176	4	3	0	f
177	27	3	0	f
178	26	3	0	f
179	11	3	0	f
180	17	3	0	f
181	18	3	0	f
182	19	3	0	f
183	15	3	0	f
184	23	3	0	f
185	6	3	0	f
186	16	3	0	f
187	20	3	0	f
188	28	3	0	f
189	25	3	0	f
190	39	3	0	f
191	38	3	0	f
192	51	3	0	f
193	3	4	0	f
194	23	4	0	f
195	6	4	0	f
196	16	4	0	f
197	20	4	0	f
198	28	4	0	f
199	25	4	0	f
200	22	4	0	f
201	1	4	0	f
202	12	4	0	f
203	24	4	0	f
204	8	4	0	f
205	7	4	0	f
206	5	4	0	f
207	9	4	0	f
208	10	4	0	f
209	13	4	0	f
210	14	4	0	f
211	21	4	0	f
212	2	4	0	f
213	4	4	0	f
214	27	4	0	f
215	26	4	0	f
216	11	4	0	f
217	17	4	0	f
218	18	4	0	f
219	19	4	0	f
220	15	4	0	f
221	76	6	0	f
222	74	6	0	f
223	58	6	0	f
224	78	6	0	f
225	77	6	0	f
226	68	6	0	f
227	72	6	0	f
228	60	6	0	f
229	57	6	0	f
230	40	6	0	f
231	56	6	0	f
232	53	6	0	f
233	55	6	0	f
234	44	6	0	f
235	50	6	0	f
236	33	6	0	f
237	41	6	0	f
238	35	6	0	f
239	39	6	0	f
240	38	6	0	f
241	51	6	0	f
242	3	6	0	f
243	23	6	0	f
244	6	6	0	f
245	16	6	0	f
246	20	6	0	f
247	28	6	0	f
248	25	6	0	f
249	22	6	0	f
250	1	6	0	f
251	87	6	0	f
252	79	6	0	f
253	82	6	0	f
254	86	6	0	f
255	62	6	0	f
256	64	6	0	f
257	67	6	0	f
258	61	6	0	f
259	69	6	0	f
260	70	6	0	f
261	45	6	0	f
262	36	6	0	f
263	29	6	0	f
264	30	6	0	f
265	49	6	0	f
266	52	6	0	f
267	48	6	0	f
268	43	6	0	f
269	31	6	0	f
270	84	6	0	f
271	81	6	0	f
272	88	6	0	f
273	83	6	0	f
274	80	6	0	f
275	85	6	0	f
276	73	6	0	f
277	65	6	0	f
278	63	6	0	f
279	75	6	0	f
280	59	6	0	f
281	71	6	0	f
282	66	6	0	f
283	54	6	0	f
284	37	6	0	f
285	42	6	0	f
286	32	6	0	f
287	34	6	0	f
288	46	6	0	f
289	47	6	0	f
290	12	6	0	f
291	24	6	0	f
292	8	6	0	f
293	7	6	0	f
294	5	6	0	f
295	9	6	0	f
296	10	6	0	f
297	13	6	0	f
298	14	6	0	f
299	21	6	0	f
300	2	6	0	f
301	4	6	0	f
302	27	6	0	f
303	26	6	0	f
304	11	6	0	f
305	17	6	0	f
306	18	6	0	f
307	19	6	0	f
308	15	6	0	f
309	73	8	0	f
310	65	8	0	f
311	63	8	0	f
312	75	8	0	f
313	59	8	0	f
314	71	8	0	f
315	66	8	0	f
316	54	8	0	f
317	37	8	0	f
318	42	8	0	f
319	32	8	0	f
320	34	8	0	f
321	46	8	0	f
322	47	8	0	f
323	12	8	0	f
324	24	8	0	f
325	8	8	0	f
326	7	8	0	f
327	5	8	0	f
328	76	8	0	f
329	74	8	0	f
330	58	8	0	f
331	78	8	0	f
332	77	8	0	f
333	68	8	0	f
334	72	8	0	f
335	60	8	0	f
336	57	8	0	f
337	40	8	0	f
338	56	8	0	f
339	53	8	0	f
340	55	8	0	f
341	44	8	0	f
342	50	8	0	f
343	33	8	0	f
344	41	8	0	f
345	35	8	0	f
346	39	8	0	f
347	38	8	0	f
348	51	8	0	f
349	3	8	0	f
350	23	8	0	f
351	6	8	0	f
352	16	8	0	f
353	20	8	0	f
354	28	8	0	f
355	25	8	0	f
356	22	8	0	f
357	1	8	0	f
358	87	8	0	f
359	79	8	0	f
360	82	8	0	f
361	86	8	0	f
362	62	8	0	f
363	64	8	0	f
364	67	8	0	f
365	61	8	0	f
366	69	8	0	f
367	70	8	0	f
368	45	8	0	f
369	36	8	0	f
370	29	8	0	f
371	30	8	0	f
372	49	8	0	f
373	52	8	0	f
374	48	8	0	f
375	43	8	0	f
376	31	8	0	f
377	84	8	0	f
378	81	8	0	f
379	88	8	0	f
380	83	8	0	f
381	80	8	0	f
382	85	8	0	f
383	9	8	0	f
384	10	8	0	f
385	13	8	0	f
386	14	8	0	f
387	21	8	0	f
388	2	8	0	f
389	4	8	0	f
390	27	8	0	f
391	26	8	0	f
392	11	8	0	f
393	17	8	0	f
394	18	8	0	f
395	19	8	0	f
396	15	8	0	f
397	97	9	0	f
398	96	9	0	f
399	95	9	0	f
400	105	9	0	f
401	104	9	0	f
402	106	9	0	f
403	102	9	0	f
404	101	9	0	f
405	103	9	0	f
406	100	9	0	f
407	99	9	0	f
408	98	9	0	f
409	92	9	0	f
410	93	9	0	f
411	89	9	0	f
412	90	9	0	f
413	94	9	0	f
414	91	9	0	f
415	73	9	0	f
416	65	9	0	f
417	63	9	0	f
418	75	9	0	f
419	59	9	0	f
420	71	9	0	f
421	66	9	0	f
422	54	9	0	f
423	37	9	0	f
424	42	9	0	f
425	32	9	0	f
426	34	9	0	f
427	46	9	0	f
428	47	9	0	f
429	12	9	0	f
430	24	9	0	f
431	8	9	0	f
432	7	9	0	f
433	5	9	0	f
434	76	9	0	f
435	74	9	0	f
436	58	9	0	f
437	78	9	0	f
438	77	9	0	f
439	68	9	0	f
440	72	9	0	f
441	60	9	0	f
442	57	9	0	f
443	40	9	0	f
444	56	9	0	f
445	53	9	0	f
446	55	9	0	f
447	44	9	0	f
448	50	9	0	f
449	33	9	0	f
450	41	9	0	f
451	35	9	0	f
452	39	9	0	f
453	38	9	0	f
454	51	9	0	f
455	3	9	0	f
456	23	9	0	f
457	6	9	0	f
458	16	9	0	f
459	20	9	0	f
460	28	9	0	f
461	25	9	0	f
462	22	9	0	f
463	1	9	0	f
464	87	9	0	f
465	79	9	0	f
466	82	9	0	f
467	86	9	0	f
468	62	9	0	f
469	64	9	0	f
470	67	9	0	f
471	61	9	0	f
472	69	9	0	f
473	70	9	0	f
474	45	9	0	f
475	36	9	0	f
476	29	9	0	f
477	30	9	0	f
478	49	9	0	f
479	52	9	0	f
480	48	9	0	f
481	43	9	0	f
482	31	9	0	f
483	84	9	0	f
484	81	9	0	f
485	88	9	0	f
486	83	9	0	f
487	80	9	0	f
488	85	9	0	f
489	9	9	0	f
490	10	9	0	f
491	13	9	0	f
492	14	9	0	f
493	21	9	0	f
494	2	9	0	f
495	4	9	0	f
496	27	9	0	f
497	26	9	0	f
498	11	9	0	f
499	17	9	0	f
500	18	9	0	f
501	19	9	0	f
502	15	9	0	f
503	108	12	0	f
504	109	12	0	f
505	107	12	0	f
506	97	12	0	f
507	96	12	0	f
508	95	12	0	f
509	105	12	0	f
510	104	12	0	f
511	106	12	0	f
512	102	12	0	f
513	101	12	0	f
514	103	12	0	f
515	100	12	0	f
516	99	12	0	f
517	98	12	0	f
518	92	12	0	f
519	93	12	0	f
520	89	12	0	f
521	90	12	0	f
522	94	12	0	f
523	91	12	0	f
524	73	12	0	f
525	65	12	0	f
526	63	12	0	f
527	75	12	0	f
528	59	12	0	f
529	71	12	0	f
530	66	12	0	f
531	54	12	0	f
532	37	12	0	f
533	42	12	0	f
534	32	12	0	f
535	34	12	0	f
536	46	12	0	f
537	47	12	0	f
538	12	12	0	f
539	24	12	0	f
540	8	12	0	f
541	7	12	0	f
542	5	12	0	f
543	76	12	0	f
544	74	12	0	f
545	58	12	0	f
546	78	12	0	f
547	77	12	0	f
548	68	12	0	f
549	72	12	0	f
550	60	12	0	f
551	57	12	0	f
552	40	12	0	f
553	56	12	0	f
554	53	12	0	f
555	55	12	0	f
556	44	12	0	f
557	50	12	0	f
558	33	12	0	f
559	41	12	0	f
560	35	12	0	f
561	39	12	0	f
562	38	12	0	f
563	51	12	0	f
564	3	12	0	f
565	23	12	0	f
566	6	12	0	f
567	16	12	0	f
568	20	12	0	f
569	28	12	0	f
570	25	12	0	f
571	22	12	0	f
572	1	12	0	f
573	87	12	0	f
574	79	12	0	f
575	82	12	0	f
576	86	12	0	f
577	62	12	0	f
578	64	12	0	f
579	67	12	0	f
580	61	12	0	f
581	69	12	0	f
582	70	12	0	f
583	45	12	0	f
584	36	12	0	f
585	29	12	0	f
586	30	12	0	f
587	49	12	0	f
588	52	12	0	f
589	48	12	0	f
590	43	12	0	f
591	31	12	0	f
592	84	12	0	f
593	81	12	0	f
594	88	12	0	f
595	83	12	0	f
596	80	12	0	f
597	85	12	0	f
598	9	12	0	f
599	10	12	0	f
600	13	12	0	f
601	14	12	0	f
602	21	12	0	f
603	2	12	0	f
604	4	12	0	f
605	27	12	0	f
606	26	12	0	f
607	11	12	0	f
608	17	12	0	f
609	18	12	0	f
610	19	12	0	f
611	15	12	0	f
612	66	16	0	f
613	54	16	0	f
614	37	16	0	f
615	42	16	0	f
616	32	16	0	f
617	34	16	0	f
618	46	16	0	f
619	47	16	0	f
620	12	16	0	f
621	24	16	0	f
622	8	16	0	f
623	7	16	0	f
624	5	16	0	f
625	76	16	0	f
626	74	16	0	f
627	58	16	0	f
628	78	16	0	f
629	77	16	0	f
630	68	16	0	f
631	72	16	0	f
632	60	16	0	f
633	57	16	0	f
634	40	16	0	f
635	56	16	0	f
636	53	16	0	f
637	55	16	0	f
638	44	16	0	f
639	50	16	0	f
640	33	16	0	f
641	41	16	0	f
642	35	16	0	f
643	39	16	0	f
644	38	16	0	f
645	51	16	0	f
646	3	16	0	f
647	23	16	0	f
648	6	16	0	f
649	16	16	0	f
650	108	16	0	f
651	109	16	0	f
652	107	16	0	f
653	97	16	0	f
654	96	16	0	f
655	95	16	0	f
656	105	16	0	f
657	104	16	0	f
658	106	16	0	f
659	102	16	0	f
660	101	16	0	f
661	103	16	0	f
662	100	16	0	f
663	99	16	0	f
664	98	16	0	f
665	92	16	0	f
666	93	16	0	f
667	89	16	0	f
668	90	16	0	f
669	94	16	0	f
670	91	16	0	f
671	73	16	0	f
672	65	16	0	f
673	63	16	0	f
674	75	16	0	f
675	59	16	0	f
676	71	16	0	f
677	20	16	0	f
678	28	16	0	f
679	25	16	0	f
680	22	16	0	f
681	1	16	0	f
682	87	16	0	f
683	79	16	0	f
684	82	16	0	f
685	86	16	0	f
686	62	16	0	f
687	64	16	0	f
688	67	16	0	f
689	61	16	0	f
690	69	16	0	f
691	70	16	0	f
692	45	16	0	f
693	36	16	0	f
694	29	16	0	f
695	30	16	0	f
696	49	16	0	f
697	52	16	0	f
698	48	16	0	f
699	43	16	0	f
700	31	16	0	f
701	84	16	0	f
702	81	16	0	f
703	88	16	0	f
704	83	16	0	f
705	80	16	0	f
706	85	16	0	f
707	9	16	0	f
708	10	16	0	f
709	13	16	0	f
710	14	16	0	f
711	21	16	0	f
712	2	16	0	f
713	4	16	0	f
714	27	16	0	f
715	26	16	0	f
716	11	16	0	f
717	17	16	0	f
718	18	16	0	f
719	19	16	0	f
720	15	16	0	f
721	108	18	0	f
722	109	18	0	f
723	107	18	0	f
724	66	18	0	f
725	54	18	0	f
726	37	18	0	f
727	42	18	0	f
728	32	18	0	f
729	34	18	0	f
730	46	18	0	f
731	47	18	0	f
732	12	18	0	f
733	24	18	0	f
734	8	18	0	f
735	7	18	0	f
736	5	18	0	f
737	76	18	0	f
738	74	18	0	f
739	58	18	0	f
740	78	18	0	f
741	77	18	0	f
742	68	18	0	f
743	72	18	0	f
744	60	18	0	f
745	57	18	0	f
746	40	18	0	f
747	56	18	0	f
748	53	18	0	f
749	55	18	0	f
750	44	18	0	f
751	50	18	0	f
752	33	18	0	f
753	41	18	0	f
754	35	18	0	f
755	39	18	0	f
756	38	18	0	f
757	51	18	0	f
758	3	18	0	f
759	23	18	0	f
760	6	18	0	f
761	16	18	0	f
762	97	18	0	f
763	96	18	0	f
764	95	18	0	f
765	105	18	0	f
766	104	18	0	f
767	106	18	0	f
768	102	18	0	f
769	101	18	0	f
770	103	18	0	f
771	100	18	0	f
772	99	18	0	f
773	98	18	0	f
774	92	18	0	f
775	93	18	0	f
776	89	18	0	f
777	90	18	0	f
778	94	18	0	f
779	91	18	0	f
780	73	18	0	f
781	65	18	0	f
782	63	18	0	f
783	75	18	0	f
784	59	18	0	f
785	71	18	0	f
786	20	18	0	f
787	28	18	0	f
788	25	18	0	f
789	22	18	0	f
790	1	18	0	f
791	87	18	0	f
792	79	18	0	f
793	82	18	0	f
794	86	18	0	f
795	62	18	0	f
796	64	18	0	f
797	67	18	0	f
798	61	18	0	f
799	69	18	0	f
800	70	18	0	f
801	45	18	0	f
802	36	18	0	f
803	29	18	0	f
804	30	18	0	f
805	49	18	0	f
806	52	18	0	f
807	48	18	0	f
808	43	18	0	f
809	31	18	0	f
810	84	18	0	f
811	81	18	0	f
812	88	18	0	f
813	83	18	0	f
814	80	18	0	f
815	85	18	0	f
816	9	18	0	f
817	10	18	0	f
818	13	18	0	f
819	14	18	0	f
820	21	18	0	f
821	2	18	0	f
822	4	18	0	f
823	27	18	0	f
824	26	18	0	f
825	11	18	0	f
826	17	18	0	f
827	18	18	0	f
828	19	18	0	f
829	15	18	0	f
830	66	19	0	f
831	54	19	0	f
832	37	19	0	f
833	42	19	0	f
834	32	19	0	f
835	34	19	0	f
836	46	19	0	f
837	47	19	0	f
838	12	19	0	f
839	24	19	0	f
840	8	19	0	f
841	7	19	0	f
842	5	19	0	f
843	76	19	0	f
844	74	19	0	f
845	58	19	0	f
846	78	19	0	f
847	77	19	0	f
848	68	19	0	f
849	72	19	0	f
850	60	19	0	f
851	57	19	0	f
852	40	19	0	f
853	56	19	0	f
854	53	19	0	f
855	55	19	0	f
856	44	19	0	f
857	50	19	0	f
858	1	19	0	f
859	87	19	0	f
860	79	19	0	f
861	82	19	0	f
862	86	19	0	f
863	62	19	0	f
864	64	19	0	f
865	67	19	0	f
866	61	19	0	f
867	69	19	0	f
868	70	19	0	f
869	45	19	0	f
870	36	19	0	f
871	29	19	0	f
872	30	19	0	f
873	49	19	0	f
874	52	19	0	f
875	48	19	0	f
876	43	19	0	f
877	33	19	0	f
878	41	19	0	f
879	35	19	0	f
880	39	19	0	f
881	38	19	0	f
882	51	19	0	f
883	3	19	0	f
884	23	19	0	f
885	6	19	0	f
886	16	19	0	f
887	97	19	0	f
888	96	19	0	f
889	95	19	0	f
890	105	19	0	f
891	104	19	0	f
892	106	19	0	f
893	102	19	0	f
894	101	19	0	f
895	103	19	0	f
896	100	19	0	f
897	99	19	0	f
898	98	19	0	f
899	92	19	0	f
900	93	19	0	f
901	89	19	0	f
902	90	19	0	f
903	94	19	0	f
904	91	19	0	f
905	73	19	0	f
906	65	19	0	f
907	63	19	0	f
908	75	19	0	f
909	59	19	0	f
910	71	19	0	f
911	20	19	0	f
912	28	19	0	f
913	25	19	0	f
914	22	19	0	f
915	31	19	0	f
916	84	19	0	f
917	81	19	0	f
918	88	19	0	f
919	83	19	0	f
920	80	19	0	f
921	85	19	0	f
922	9	19	0	f
923	10	19	0	f
924	13	19	0	f
925	14	19	0	f
926	21	19	0	f
927	2	19	0	f
928	4	19	0	f
929	27	19	0	f
930	26	19	0	f
931	11	19	0	f
932	17	19	0	f
933	18	19	0	f
934	19	19	0	f
935	15	19	0	f
936	66	21	0	f
937	54	21	0	f
938	37	21	0	f
939	42	21	0	f
940	32	21	0	f
941	34	21	0	f
942	46	21	0	f
943	47	21	0	f
944	12	21	0	f
945	24	21	0	f
946	8	21	0	f
947	7	21	0	f
948	5	21	0	f
949	76	21	0	f
950	74	21	0	f
951	58	21	0	f
952	78	21	0	f
953	77	21	0	f
954	68	21	0	f
955	72	21	0	f
956	60	21	0	f
957	57	21	0	f
958	40	21	0	f
959	56	21	0	f
960	53	21	0	f
961	55	21	0	f
962	44	21	0	f
963	50	21	0	f
964	1	21	0	f
965	87	21	0	f
966	79	21	0	f
967	82	21	0	f
968	86	21	0	f
969	62	21	0	f
970	64	21	0	f
971	67	21	0	f
972	61	21	0	f
973	69	21	0	f
974	70	21	0	f
975	45	21	0	f
976	36	21	0	f
977	29	21	0	f
978	30	21	0	f
979	49	21	0	f
980	52	21	0	f
981	48	21	0	f
982	43	21	0	f
983	33	21	0	f
984	41	21	0	f
985	35	21	0	f
986	39	21	0	f
987	38	21	0	f
988	51	21	0	f
989	3	21	0	f
990	23	21	0	f
991	6	21	0	f
992	16	21	0	f
993	97	21	0	f
994	96	21	0	f
995	95	21	0	f
996	102	21	0	f
997	101	21	0	f
998	103	21	0	f
999	100	21	0	f
1000	99	21	0	f
1001	98	21	0	f
1002	92	21	0	f
1003	93	21	0	f
1004	89	21	0	f
1005	90	21	0	f
1006	94	21	0	f
1007	91	21	0	f
1008	73	21	0	f
1009	65	21	0	f
1010	63	21	0	f
1011	75	21	0	f
1012	59	21	0	f
1013	71	21	0	f
1014	20	21	0	f
1015	28	21	0	f
1016	25	21	0	f
1017	22	21	0	f
1018	31	21	0	f
1019	84	21	0	f
1020	81	21	0	f
1021	88	21	0	f
1022	83	21	0	f
1023	80	21	0	f
1024	85	21	0	f
1025	9	21	0	f
1026	10	21	0	f
1027	13	21	0	f
1028	14	21	0	f
1029	21	21	0	f
1030	2	21	0	f
1031	4	21	0	f
1032	27	21	0	f
1033	26	21	0	f
1034	11	21	0	f
1035	17	21	0	f
1036	18	21	0	f
1037	19	21	0	f
1038	15	21	0	f
1039	108	22	0	f
1040	109	22	0	f
1041	107	22	0	f
1042	105	22	0	f
1043	104	22	0	f
1044	106	22	0	f
1045	66	22	0	f
1046	54	22	0	f
1047	37	22	0	f
1048	42	22	0	f
1049	32	22	0	f
1050	34	22	0	f
1051	46	22	0	f
1052	47	22	0	f
1053	12	22	0	f
1054	24	22	0	f
1055	8	22	0	f
1056	7	22	0	f
1057	5	22	0	f
1058	76	22	0	f
1059	74	22	0	f
1060	58	22	0	f
1061	78	22	0	f
1062	77	22	0	f
1063	68	22	0	f
1064	72	22	0	f
1065	60	22	0	f
1066	57	22	0	f
1067	40	22	0	f
1068	56	22	0	f
1069	53	22	0	f
1070	55	22	0	f
1071	44	22	0	f
1072	50	22	0	f
1073	1	22	0	f
1074	87	22	0	f
1075	79	22	0	f
1076	82	22	0	f
1077	86	22	0	f
1078	62	22	0	f
1079	64	22	0	f
1080	67	22	0	f
1081	61	22	0	f
1082	69	22	0	f
1083	70	22	0	f
1084	45	22	0	f
1085	36	22	0	f
1086	29	22	0	f
1087	30	22	0	f
1088	49	22	0	f
1089	52	22	0	f
1090	48	22	0	f
1091	43	22	0	f
1092	33	22	0	f
1093	41	22	0	f
1094	35	22	0	f
1095	39	22	0	f
1096	38	22	0	f
1097	51	22	0	f
1098	3	22	0	f
1099	23	22	0	f
1100	6	22	0	f
1101	16	22	0	f
1102	97	22	0	f
1103	96	22	0	f
1104	95	22	0	f
1105	102	22	0	f
1106	101	22	0	f
1107	103	22	0	f
1108	100	22	0	f
1109	99	22	0	f
1110	98	22	0	f
1111	92	22	0	f
1112	93	22	0	f
1113	89	22	0	f
1114	90	22	0	f
1115	94	22	0	f
1116	91	22	0	f
1117	73	22	0	f
1118	65	22	0	f
1119	63	22	0	f
1120	75	22	0	f
1121	59	22	0	f
1122	71	22	0	f
1123	20	22	0	f
1124	28	22	0	f
1125	25	22	0	f
1126	22	22	0	f
1127	31	22	0	f
1128	84	22	0	f
1129	81	22	0	f
1130	88	22	0	f
1131	83	22	0	f
1132	80	22	0	f
1133	85	22	0	f
1134	9	22	0	f
1135	10	22	0	f
1136	13	22	0	f
1137	14	22	0	f
1138	21	22	0	f
1139	2	22	0	f
1140	4	22	0	f
1141	27	22	0	f
1142	26	22	0	f
1143	11	22	0	f
1144	17	22	0	f
1145	18	22	0	f
1146	19	22	0	f
1147	15	22	0	f
1148	1	23	0	f
1149	87	23	0	f
1150	79	23	0	f
1151	82	23	0	f
1152	86	23	0	f
1153	62	23	0	f
1154	64	23	0	f
1155	67	23	0	f
1156	61	23	0	f
1157	69	23	0	f
1158	70	23	0	f
1159	45	23	0	f
1160	36	23	0	f
1161	29	23	0	f
1162	30	23	0	f
1163	49	23	0	f
1164	52	23	0	f
1165	48	23	0	f
1166	43	23	0	f
1167	105	23	0	f
1168	104	23	0	f
1169	106	23	0	f
1170	66	23	0	f
1171	54	23	0	f
1172	37	23	0	f
1173	42	23	0	f
1174	32	23	0	f
1175	34	23	0	f
1176	46	23	0	f
1177	47	23	0	f
1178	12	23	0	f
1179	24	23	0	f
1180	8	23	0	f
1181	7	23	0	f
1182	5	23	0	f
1183	76	23	0	f
1184	74	23	0	f
1185	58	23	0	f
1186	78	23	0	f
1187	77	23	0	f
1188	68	23	0	f
1189	72	23	0	f
1190	60	23	0	f
1191	57	23	0	f
1192	40	23	0	f
1193	56	23	0	f
1194	53	23	0	f
1195	55	23	0	f
1196	44	23	0	f
1197	50	23	0	f
1198	33	23	0	f
1199	41	23	0	f
1200	35	23	0	f
1201	39	23	0	f
1202	38	23	0	f
1203	51	23	0	f
1204	3	23	0	f
1205	23	23	0	f
1206	6	23	0	f
1207	16	23	0	f
1208	97	23	0	f
1209	96	23	0	f
1210	95	23	0	f
1211	102	23	0	f
1212	101	23	0	f
1213	103	23	0	f
1214	100	23	0	f
1215	99	23	0	f
1216	98	23	0	f
1217	92	23	0	f
1218	93	23	0	f
1219	89	23	0	f
1220	90	23	0	f
1221	94	23	0	f
1222	91	23	0	f
1223	73	23	0	f
1224	65	23	0	f
1225	63	23	0	f
1226	75	23	0	f
1227	59	23	0	f
1228	71	23	0	f
1229	20	23	0	f
1230	28	23	0	f
1231	25	23	0	f
1232	22	23	0	f
1233	31	23	0	f
1234	84	23	0	f
1235	81	23	0	f
1236	88	23	0	f
1237	83	23	0	f
1238	80	23	0	f
1239	85	23	0	f
1240	9	23	0	f
1241	10	23	0	f
1242	13	23	0	f
1243	14	23	0	f
1244	21	23	0	f
1245	2	23	0	f
1246	4	23	0	f
1247	27	23	0	f
1248	26	23	0	f
1249	11	23	0	f
1250	17	23	0	f
1251	18	23	0	f
1252	19	23	0	f
1253	15	23	0	f
1254	65	25	0	f
1255	63	25	0	f
1256	75	25	0	f
1257	59	25	0	f
1258	71	25	0	f
1259	20	25	0	f
1260	28	25	0	f
1261	25	25	0	f
1262	22	25	0	f
1263	31	25	0	f
1264	84	25	0	f
1265	81	25	0	f
1266	88	25	0	f
1267	83	25	0	f
1268	80	25	0	f
1269	85	25	0	f
1270	9	25	0	f
1271	10	25	0	f
1272	1	25	0	f
1273	87	25	0	f
1274	79	25	0	f
1275	82	25	0	f
1276	86	25	0	f
1277	62	25	0	f
1278	64	25	0	f
1279	67	25	0	f
1280	61	25	0	f
1281	69	25	0	f
1282	70	25	0	f
1283	45	25	0	f
1284	36	25	0	f
1285	29	25	0	f
1286	30	25	0	f
1287	49	25	0	f
1288	52	25	0	f
1289	48	25	0	f
1290	43	25	0	f
1291	66	25	0	f
1292	54	25	0	f
1293	37	25	0	f
1294	42	25	0	f
1295	32	25	0	f
1296	34	25	0	f
1297	46	25	0	f
1298	47	25	0	f
1299	12	25	0	f
1300	24	25	0	f
1301	8	25	0	f
1302	7	25	0	f
1303	5	25	0	f
1304	76	25	0	f
1305	74	25	0	f
1306	58	25	0	f
1307	78	25	0	f
1308	77	25	0	f
1309	68	25	0	f
1310	72	25	0	f
1311	60	25	0	f
1312	57	25	0	f
1313	40	25	0	f
1314	56	25	0	f
1315	53	25	0	f
1316	55	25	0	f
1317	44	25	0	f
1318	50	25	0	f
1319	33	25	0	f
1320	41	25	0	f
1321	35	25	0	f
1322	39	25	0	f
1323	38	25	0	f
1324	51	25	0	f
1325	3	25	0	f
1326	23	25	0	f
1327	6	25	0	f
1328	16	25	0	f
1329	97	25	0	f
1330	96	25	0	f
1331	95	25	0	f
1332	102	25	0	f
1333	101	25	0	f
1334	103	25	0	f
1335	100	25	0	f
1336	99	25	0	f
1337	98	25	0	f
1338	92	25	0	f
1339	93	25	0	f
1340	89	25	0	f
1341	90	25	0	f
1342	94	25	0	f
1343	91	25	0	f
1344	73	25	0	f
1345	13	25	0	f
1346	14	25	0	f
1347	21	25	0	f
1348	2	25	0	f
1349	4	25	0	f
1350	27	25	0	f
1351	26	25	0	f
1352	11	25	0	f
1353	17	25	0	f
1354	18	25	0	f
1355	19	25	0	f
1356	15	25	0	f
1357	65	26	0	f
1358	63	26	0	f
1359	75	26	0	f
1360	59	26	0	f
1361	71	26	0	f
1362	20	26	0	f
1363	28	26	0	f
1364	25	26	0	f
1365	22	26	0	f
1366	31	26	0	f
1367	84	26	0	f
1368	81	26	0	f
1369	88	26	0	f
1370	83	26	0	f
1371	80	26	0	f
1372	85	26	0	f
1373	9	26	0	f
1374	10	26	0	f
1375	1	26	0	f
1376	87	26	0	f
1377	79	26	0	f
1378	82	26	0	f
1379	86	26	0	f
1380	62	26	0	f
1381	64	26	0	f
1382	67	26	0	f
1383	61	26	0	f
1384	69	26	0	f
1385	70	26	0	f
1386	45	26	0	f
1387	36	26	0	f
1388	29	26	0	f
1389	30	26	0	f
1390	49	26	0	f
1391	52	26	0	f
1392	48	26	0	f
1393	43	26	0	f
1394	66	26	0	f
1395	54	26	0	f
1396	37	26	0	f
1397	42	26	0	f
1398	32	26	0	f
1399	34	26	0	f
1400	46	26	0	f
1401	47	26	0	f
1402	12	26	0	f
1403	24	26	0	f
1404	8	26	0	f
1405	7	26	0	f
1406	5	26	0	f
1407	76	26	0	f
1408	74	26	0	f
1409	58	26	0	f
1410	78	26	0	f
1411	77	26	0	f
1412	68	26	0	f
1413	72	26	0	f
1414	60	26	0	f
1415	57	26	0	f
1416	40	26	0	f
1417	56	26	0	f
1418	53	26	0	f
1419	55	26	0	f
1420	44	26	0	f
1421	50	26	0	f
1422	33	26	0	f
1423	41	26	0	f
1424	35	26	0	f
1425	39	26	0	f
1426	38	26	0	f
1427	51	26	0	f
1428	3	26	0	f
1429	23	26	0	f
1430	6	26	0	f
1431	16	26	0	f
1432	97	26	0	f
1433	96	26	0	f
1434	95	26	0	f
1435	98	26	0	f
1436	92	26	0	f
1437	93	26	0	f
1438	89	26	0	f
1439	90	26	0	f
1440	94	26	0	f
1441	91	26	0	f
1442	73	26	0	f
1443	13	26	0	f
1444	14	26	0	f
1445	21	26	0	f
1446	2	26	0	f
1447	4	26	0	f
1448	27	26	0	f
1449	26	26	0	f
1450	11	26	0	f
1451	17	26	0	f
1452	18	26	0	f
1453	19	26	0	f
1454	15	26	0	f
1455	100	27	0	f
1456	99	27	0	f
1457	65	27	0	f
1458	63	27	0	f
1459	75	27	0	f
1460	59	27	0	f
1461	71	27	0	f
1462	20	27	0	f
1463	28	27	0	f
1464	25	27	0	f
1465	22	27	0	f
1466	31	27	0	f
1467	84	27	0	f
1468	81	27	0	f
1469	88	27	0	f
1470	83	27	0	f
1471	80	27	0	f
1472	85	27	0	f
1473	9	27	0	f
1474	10	27	0	f
1475	1	27	0	f
1476	87	27	0	f
1477	79	27	0	f
1478	82	27	0	f
1479	86	27	0	f
1480	62	27	0	f
1481	64	27	0	f
1482	67	27	0	f
1483	61	27	0	f
1484	69	27	0	f
1485	70	27	0	f
1486	45	27	0	f
1487	36	27	0	f
1488	29	27	0	f
1489	30	27	0	f
1490	49	27	0	f
1491	52	27	0	f
1492	48	27	0	f
1493	43	27	0	f
1494	66	27	0	f
1495	54	27	0	f
1496	37	27	0	f
1497	42	27	0	f
1498	32	27	0	f
1499	34	27	0	f
1500	46	27	0	f
1501	47	27	0	f
1502	12	27	0	f
1503	24	27	0	f
1504	8	27	0	f
1505	7	27	0	f
1506	5	27	0	f
1507	76	27	0	f
1508	74	27	0	f
1509	58	27	0	f
1510	78	27	0	f
1511	77	27	0	f
1512	68	27	0	f
1513	72	27	0	f
1514	60	27	0	f
1515	57	27	0	f
1516	40	27	0	f
1517	56	27	0	f
1518	53	27	0	f
1519	55	27	0	f
1520	44	27	0	f
1521	50	27	0	f
1522	33	27	0	f
1523	41	27	0	f
1524	35	27	0	f
1525	39	27	0	f
1526	38	27	0	f
1527	51	27	0	f
1528	3	27	0	f
1529	23	27	0	f
1530	6	27	0	f
1531	16	27	0	f
1532	97	27	0	f
1533	96	27	0	f
1534	95	27	0	f
1535	98	27	0	f
1536	92	27	0	f
1537	93	27	0	f
1538	89	27	0	f
1539	90	27	0	f
1540	94	27	0	f
1541	91	27	0	f
1542	73	27	0	f
1543	13	27	0	f
1544	14	27	0	f
1545	21	27	0	f
1546	2	27	0	f
1547	4	27	0	f
1548	27	27	0	f
1549	26	27	0	f
1550	11	27	0	f
1551	17	27	0	f
1552	18	27	0	f
1553	19	27	0	f
1554	15	27	0	f
1555	7	28	0	f
1556	5	28	0	f
1557	76	28	0	f
1558	74	28	0	f
1559	58	28	0	f
1560	78	28	0	f
1561	77	28	0	f
1562	68	28	0	f
1563	72	28	0	f
1564	60	28	0	f
1565	57	28	0	f
1566	40	28	0	f
1567	56	28	0	f
1568	53	28	0	f
1569	55	28	0	f
1570	44	28	0	f
1571	50	28	0	f
1572	33	28	0	f
1573	41	28	0	f
1574	65	28	0	f
1575	63	28	0	f
1576	75	28	0	f
1577	59	28	0	f
1578	71	28	0	f
1579	20	28	0	f
1580	28	28	0	f
1581	25	28	0	f
1582	22	28	0	f
1583	31	28	0	f
1584	9	28	0	f
1585	10	28	0	f
1586	1	28	0	f
1587	62	28	0	f
1588	64	28	0	f
1589	67	28	0	f
1590	61	28	0	f
1591	69	28	0	f
1592	70	28	0	f
1593	45	28	0	f
1594	36	28	0	f
1595	29	28	0	f
1596	30	28	0	f
1597	49	28	0	f
1598	52	28	0	f
1599	48	28	0	f
1600	43	28	0	f
1601	66	28	0	f
1602	54	28	0	f
1603	37	28	0	f
1604	42	28	0	f
1605	32	28	0	f
1606	34	28	0	f
1607	46	28	0	f
1608	47	28	0	f
1609	12	28	0	f
1610	24	28	0	f
1611	8	28	0	f
1612	35	28	0	f
1613	39	28	0	f
1614	38	28	0	f
1615	51	28	0	f
1616	3	28	0	f
1617	23	28	0	f
1618	6	28	0	f
1619	16	28	0	f
1620	73	28	0	f
1621	13	28	0	f
1622	14	28	0	f
1623	21	28	0	f
1624	2	28	0	f
1625	4	28	0	f
1626	27	28	0	f
1627	26	28	0	f
1628	11	28	0	f
1629	17	28	0	f
1630	18	28	0	f
1631	19	28	0	f
1632	15	28	0	f
1633	84	31	0	f
1634	81	31	0	f
1635	88	31	0	f
1636	83	31	0	f
1637	80	31	0	f
1638	85	31	0	f
1639	87	31	0	f
1640	79	31	0	f
1641	82	31	0	f
1642	86	31	0	f
1643	92	31	0	f
1644	93	31	0	f
1645	89	31	0	f
1646	90	31	0	f
1647	94	31	0	f
1648	91	31	0	f
1649	7	31	0	f
1650	5	31	0	f
1651	76	31	0	f
1652	74	31	0	f
1653	58	31	0	f
1654	78	31	0	f
1655	77	31	0	f
1656	68	31	0	f
1657	72	31	0	f
1658	60	31	0	f
1659	57	31	0	f
1660	40	31	0	f
1661	56	31	0	f
1662	53	31	0	f
1663	55	31	0	f
1664	44	31	0	f
1665	50	31	0	f
1666	33	31	0	f
1667	41	31	0	f
1668	65	31	0	f
1669	63	31	0	f
1670	75	31	0	f
1671	59	31	0	f
1672	71	31	0	f
1673	20	31	0	f
1674	28	31	0	f
1675	25	31	0	f
1676	22	31	0	f
1677	31	31	0	f
1678	9	31	0	f
1679	10	31	0	f
1680	1	31	0	f
1681	62	31	0	f
1682	64	31	0	f
1683	67	31	0	f
1684	61	31	0	f
1685	69	31	0	f
1686	70	31	0	f
1687	45	31	0	f
1688	36	31	0	f
1689	29	31	0	f
1690	30	31	0	f
1691	49	31	0	f
1692	52	31	0	f
1693	48	31	0	f
1694	43	31	0	f
1695	66	31	0	f
1696	54	31	0	f
1697	37	31	0	f
1698	42	31	0	f
1699	32	31	0	f
1700	34	31	0	f
1701	46	31	0	f
1702	47	31	0	f
1703	12	31	0	f
1704	24	31	0	f
1705	8	31	0	f
1706	35	31	0	f
1707	39	31	0	f
1708	38	31	0	f
1709	51	31	0	f
1710	3	31	0	f
1711	23	31	0	f
1712	6	31	0	f
1713	16	31	0	f
1714	73	31	0	f
1715	13	31	0	f
1716	14	31	0	f
1717	21	31	0	f
1718	2	31	0	f
1719	4	31	0	f
1720	27	31	0	f
1721	26	31	0	f
1722	11	31	0	f
1723	17	31	0	f
1724	18	31	0	f
1725	19	31	0	f
1726	15	31	0	f
1727	7	32	0	f
1728	5	32	0	f
1729	57	32	0	f
1730	40	32	0	f
1731	56	32	0	f
1732	53	32	0	f
1733	55	32	0	f
1734	44	32	0	f
1735	50	32	0	f
1736	33	32	0	f
1737	41	32	0	f
1738	20	32	0	f
1739	28	32	0	f
1740	25	32	0	f
1741	22	32	0	f
1742	31	32	0	f
1743	9	32	0	f
1744	10	32	0	f
1745	1	32	0	f
1746	45	32	0	f
1747	36	32	0	f
1748	29	32	0	f
1749	30	32	0	f
1750	49	32	0	f
1751	52	32	0	f
1752	48	32	0	f
1753	43	32	0	f
1754	54	32	0	f
1755	37	32	0	f
1756	42	32	0	f
1757	32	32	0	f
1758	34	32	0	f
1759	46	32	0	f
1760	47	32	0	f
1761	12	32	0	f
1762	24	32	0	f
1763	8	32	0	f
1764	35	32	0	f
1765	39	32	0	f
1766	38	32	0	f
1767	51	32	0	f
1768	3	32	0	f
1769	23	32	0	f
1770	6	32	0	f
1771	16	32	0	f
1772	13	32	0	f
1773	14	32	0	f
1774	21	32	0	f
1775	2	32	0	f
1776	4	32	0	f
1777	27	32	0	f
1778	26	32	0	f
1779	11	32	0	f
1780	17	32	0	f
1781	18	32	0	f
1782	19	32	0	f
1783	15	32	0	f
1784	29	36	0	f
1785	30	36	0	f
1786	49	36	0	f
1787	52	36	0	f
1788	48	36	0	f
1789	43	36	0	f
1790	54	36	0	f
1791	37	36	0	f
1792	42	36	0	f
1793	32	36	0	f
1794	34	36	0	f
1795	46	36	0	f
1796	47	36	0	f
1797	12	36	0	f
1798	24	36	0	f
1799	8	36	0	f
1800	35	36	0	f
1801	39	36	0	f
1802	38	36	0	f
1803	84	36	0	f
1804	81	36	0	f
1805	88	36	0	f
1806	83	36	0	f
1807	80	36	0	f
1808	85	36	0	f
1809	87	36	0	f
1810	79	36	0	f
1811	82	36	0	f
1812	86	36	0	f
1813	92	36	0	f
1814	93	36	0	f
1815	89	36	0	f
1816	90	36	0	f
1817	94	36	0	f
1818	91	36	0	f
1819	76	36	0	f
1820	74	36	0	f
1821	58	36	0	f
1822	78	36	0	f
1823	77	36	0	f
1824	68	36	0	f
1825	72	36	0	f
1826	60	36	0	f
1827	65	36	0	f
1828	63	36	0	f
1829	75	36	0	f
1830	59	36	0	f
1831	71	36	0	f
1832	62	36	0	f
1833	64	36	0	f
1834	67	36	0	f
1835	61	36	0	f
1836	69	36	0	f
1837	70	36	0	f
1838	66	36	0	f
1839	73	36	0	f
1840	7	36	0	f
1841	5	36	0	f
1842	57	36	0	f
1843	40	36	0	f
1844	56	36	0	f
1845	53	36	0	f
1846	55	36	0	f
1847	44	36	0	f
1848	50	36	0	f
1849	33	36	0	f
1850	41	36	0	f
1851	20	36	0	f
1852	28	36	0	f
1853	25	36	0	f
1854	22	36	0	f
1855	31	36	0	f
1856	9	36	0	f
1857	10	36	0	f
1858	1	36	0	f
1859	45	36	0	f
1860	36	36	0	f
1861	51	36	0	f
1862	3	36	0	f
1863	23	36	0	f
1864	6	36	0	f
1865	16	36	0	f
1866	13	36	0	f
1867	14	36	0	f
1868	21	36	0	f
1869	2	36	0	f
1870	4	36	0	f
1871	27	36	0	f
1872	26	36	0	f
1873	11	36	0	f
1874	17	36	0	f
1875	18	36	0	f
1876	19	36	0	f
1877	15	36	0	f
1878	97	37	0	f
1879	96	37	0	f
1880	95	37	0	f
1881	98	37	0	f
1882	29	37	0	f
1883	30	37	0	f
1884	49	37	0	f
1885	52	37	0	f
1886	48	37	0	f
1887	43	37	0	f
1888	54	37	0	f
1889	37	37	0	f
1890	42	37	0	f
1891	32	37	0	f
1892	34	37	0	f
1893	46	37	0	f
1894	47	37	0	f
1895	12	37	0	f
1896	24	37	0	f
1897	8	37	0	f
1898	35	37	0	f
1899	39	37	0	f
1900	38	37	0	f
1901	84	37	0	f
1902	81	37	0	f
1903	88	37	0	f
1904	83	37	0	f
1905	80	37	0	f
1906	85	37	0	f
1907	87	37	0	f
1908	79	37	0	f
1909	82	37	0	f
1910	86	37	0	f
1911	92	37	0	f
1912	93	37	0	f
1913	89	37	0	f
1914	90	37	0	f
1915	94	37	0	f
1916	91	37	0	f
1917	76	37	0	f
1918	74	37	0	f
1919	58	37	0	f
1920	78	37	0	f
1921	77	37	0	f
1922	68	37	0	f
1923	72	37	0	f
1924	60	37	0	f
1925	65	37	0	f
1926	63	37	0	f
1927	75	37	0	f
1928	59	37	0	f
1929	71	37	0	f
1930	62	37	0	f
1931	64	37	0	f
1932	67	37	0	f
1933	61	37	0	f
1934	69	37	0	f
1935	70	37	0	f
1936	66	37	0	f
1937	73	37	0	f
1938	7	37	0	f
1939	5	37	0	f
1940	57	37	0	f
1941	40	37	0	f
1942	56	37	0	f
1943	53	37	0	f
1944	55	37	0	f
1945	44	37	0	f
1946	50	37	0	f
1947	33	37	0	f
1948	41	37	0	f
1949	20	37	0	f
1950	28	37	0	f
1951	25	37	0	f
1952	22	37	0	f
1953	31	37	0	f
1954	9	37	0	f
1955	10	37	0	f
1956	1	37	0	f
1957	45	37	0	f
1958	36	37	0	f
1959	51	37	0	f
1960	3	37	0	f
1961	23	37	0	f
1962	6	37	0	f
1963	16	37	0	f
1964	13	37	0	f
1965	14	37	0	f
1966	21	37	0	f
1967	2	37	0	f
1968	4	37	0	f
1969	27	37	0	f
1970	26	37	0	f
1971	11	37	0	f
1972	17	37	0	f
1973	18	37	0	f
1974	19	37	0	f
1975	15	37	0	f
1976	29	40	0	f
1977	30	40	0	f
1978	49	40	0	f
1979	52	40	0	f
1980	48	40	0	f
1981	43	40	0	f
1982	54	40	0	f
1983	37	40	0	f
1984	42	40	0	f
1985	32	40	0	f
1986	34	40	0	f
1987	46	40	0	f
1988	47	40	0	f
1989	12	40	0	f
1990	24	40	0	f
1991	8	40	0	f
1992	76	40	0	f
1993	74	40	0	f
1994	58	40	0	f
1995	78	40	0	f
1996	77	40	0	f
1997	68	40	0	f
1998	72	40	0	f
1999	60	40	0	f
2000	65	40	0	f
2001	63	40	0	f
2002	75	40	0	f
2003	59	40	0	f
2004	71	40	0	f
2005	62	40	0	f
2006	64	40	0	f
2007	67	40	0	f
2008	61	40	0	f
2009	69	40	0	f
2010	70	40	0	f
2011	66	40	0	f
2012	73	40	0	f
2013	7	40	0	f
2014	5	40	0	f
2015	57	40	0	f
2016	40	40	0	f
2017	56	40	0	f
2018	53	40	0	f
2019	55	40	0	f
2020	44	40	0	f
2021	50	40	0	f
2022	33	40	0	f
2023	41	40	0	f
2024	20	40	0	f
2025	28	40	0	f
2026	25	40	0	f
2027	22	40	0	f
2028	31	40	0	f
2029	9	40	0	f
2030	35	40	0	f
2031	39	40	0	f
2032	38	40	0	f
2033	84	40	0	f
2034	81	40	0	f
2035	88	40	0	f
2036	83	40	0	f
2037	80	40	0	f
2038	85	40	0	f
2039	87	40	0	f
2040	79	40	0	f
2041	82	40	0	f
2042	86	40	0	f
2043	10	40	0	f
2044	1	40	0	f
2045	45	40	0	f
2046	36	40	0	f
2047	51	40	0	f
2048	3	40	0	f
2049	23	40	0	f
2050	6	40	0	f
2051	16	40	0	f
2052	13	40	0	f
2053	14	40	0	f
2054	21	40	0	f
2055	2	40	0	f
2056	4	40	0	f
2057	27	40	0	f
2058	26	40	0	f
2059	11	40	0	f
2060	17	40	0	f
2061	18	40	0	f
2062	19	40	0	f
2063	15	40	0	f
2064	96	44	0	f
2065	95	44	0	f
2066	98	44	0	f
2067	76	44	0	f
2068	74	44	0	f
2069	58	44	0	f
2070	78	44	0	f
2071	77	44	0	f
2072	68	44	0	f
2073	72	44	0	f
2074	60	44	0	f
2075	65	44	0	f
2076	63	44	0	f
2077	75	44	0	f
2078	59	44	0	f
2079	71	44	0	f
2080	62	44	0	f
2081	64	44	0	f
2082	67	44	0	f
2083	61	44	0	f
2084	69	44	0	f
2085	70	44	0	f
2086	66	44	0	f
2087	73	44	0	f
2088	7	44	0	f
2089	5	44	0	f
2090	57	44	0	f
2091	40	44	0	f
2092	56	44	0	f
2093	53	44	0	f
2094	55	44	0	f
2095	44	44	0	f
2096	50	44	0	f
2097	33	44	0	f
2098	41	44	0	f
2099	20	44	0	f
2100	28	44	0	f
2101	25	44	0	f
2102	22	44	0	f
2103	31	44	0	f
2104	9	44	0	f
2105	102	44	0	f
2106	101	44	0	f
2107	103	44	0	f
2108	100	44	0	f
2109	99	44	0	f
2110	97	44	0	f
2111	92	44	0	f
2112	93	44	0	f
2113	89	44	0	f
2114	90	44	0	f
2115	94	44	0	f
2116	91	44	0	f
2117	29	44	0	f
2118	30	44	0	f
2119	49	44	0	f
2120	52	44	0	f
2121	48	44	0	f
2122	43	44	0	f
2123	54	44	0	f
2124	37	44	0	f
2125	42	44	0	f
2126	32	44	0	f
2127	34	44	0	f
2128	46	44	0	f
2129	47	44	0	f
2130	12	44	0	f
2131	24	44	0	f
2132	8	44	0	f
2133	35	44	0	f
2134	39	44	0	f
2135	38	44	0	f
2136	84	44	0	f
2137	81	44	0	f
2138	88	44	0	f
2139	83	44	0	f
2140	80	44	0	f
2141	85	44	0	f
2142	87	44	0	f
2143	79	44	0	f
2144	82	44	0	f
2145	86	44	0	f
2146	10	44	0	f
2147	1	44	0	f
2148	45	44	0	f
2149	36	44	0	f
2150	51	44	0	f
2151	3	44	0	f
2152	23	44	0	f
2153	6	44	0	f
2154	16	44	0	f
2155	13	44	0	f
2156	14	44	0	f
2157	21	44	0	f
2158	2	44	0	f
2159	4	44	0	f
2160	27	44	0	f
2161	26	44	0	f
2162	11	44	0	f
2163	17	44	0	f
2164	18	44	0	f
2165	19	44	0	f
2166	15	44	0	f
2167	66	46	0	f
2168	73	46	0	f
2169	7	46	0	f
2170	5	46	0	f
2171	57	46	0	f
2172	40	46	0	f
2173	56	46	0	f
2174	53	46	0	f
2175	55	46	0	f
2176	44	46	0	f
2177	50	46	0	f
2178	33	46	0	f
2179	41	46	0	f
2180	20	46	0	f
2181	28	46	0	f
2182	25	46	0	f
2183	22	46	0	f
2184	31	46	0	f
2185	9	46	0	f
2186	29	46	0	f
2187	30	46	0	f
2188	49	46	0	f
2189	52	46	0	f
2190	48	46	0	f
2191	43	46	0	f
2192	54	46	0	f
2193	76	46	0	f
2194	74	46	0	f
2195	58	46	0	f
2196	78	46	0	f
2197	77	46	0	f
2198	68	46	0	f
2199	72	46	0	f
2200	60	46	0	f
2201	65	46	0	f
2202	63	46	0	f
2203	75	46	0	f
2204	59	46	0	f
2205	71	46	0	f
2206	62	46	0	f
2207	64	46	0	f
2208	67	46	0	f
2209	61	46	0	f
2210	69	46	0	f
2211	70	46	0	f
2212	37	46	0	f
2213	42	46	0	f
2214	32	46	0	f
2215	34	46	0	f
2216	46	46	0	f
2217	47	46	0	f
2218	12	46	0	f
2219	24	46	0	f
2220	8	46	0	f
2221	35	46	0	f
2222	39	46	0	f
2223	38	46	0	f
2224	84	46	0	f
2225	81	46	0	f
2226	88	46	0	f
2227	83	46	0	f
2228	80	46	0	f
2229	85	46	0	f
2230	87	46	0	f
2231	79	46	0	f
2232	82	46	0	f
2233	86	46	0	f
2234	10	46	0	f
2235	1	46	0	f
2236	45	46	0	f
2237	36	46	0	f
2238	51	46	0	f
2239	3	46	0	f
2240	23	46	0	f
2241	6	46	0	f
2242	16	46	0	f
2243	13	46	0	f
2244	14	46	0	f
2245	21	46	0	f
2246	2	46	0	f
2247	4	46	0	f
2248	27	46	0	f
2249	26	46	0	f
2250	11	46	0	f
2251	17	46	0	f
2252	18	46	0	f
2253	19	46	0	f
2254	15	46	0	f
2255	92	47	0	f
2256	93	47	0	f
2257	89	47	0	f
2258	90	47	0	f
2259	94	47	0	f
2260	91	47	0	f
2261	66	47	0	f
2262	73	47	0	f
2263	7	47	0	f
2264	5	47	0	f
2265	57	47	0	f
2266	40	47	0	f
2267	56	47	0	f
2268	53	47	0	f
2269	55	47	0	f
2270	44	47	0	f
2271	50	47	0	f
2272	33	47	0	f
2273	41	47	0	f
2274	20	47	0	f
2275	28	47	0	f
2276	25	47	0	f
2277	22	47	0	f
2278	31	47	0	f
2279	9	47	0	f
2280	29	47	0	f
2281	30	47	0	f
2282	49	47	0	f
2283	52	47	0	f
2284	48	47	0	f
2285	43	47	0	f
2286	54	47	0	f
2287	76	47	0	f
2288	74	47	0	f
2289	58	47	0	f
2290	78	47	0	f
2291	77	47	0	f
2292	68	47	0	f
2293	72	47	0	f
2294	60	47	0	f
2295	65	47	0	f
2296	63	47	0	f
2297	75	47	0	f
2298	59	47	0	f
2299	71	47	0	f
2300	62	47	0	f
2301	64	47	0	f
2302	67	47	0	f
2303	61	47	0	f
2304	69	47	0	f
2305	70	47	0	f
2306	37	47	0	f
2307	42	47	0	f
2308	32	47	0	f
2309	34	47	0	f
2310	46	47	0	f
2311	47	47	0	f
2312	12	47	0	f
2316	39	47	0	f
2317	38	47	0	f
2318	84	47	0	f
2319	81	47	0	f
2320	88	47	0	f
2321	83	47	0	f
2322	80	47	0	f
2323	85	47	0	f
2324	87	47	0	f
2325	79	47	0	f
2326	82	47	0	f
2327	86	47	0	f
2328	10	47	0	f
2329	1	47	0	f
2330	45	47	0	f
2331	36	47	0	f
2332	51	47	0	f
2333	3	47	0	f
2334	23	47	0	f
2335	6	47	0	f
2336	16	47	0	f
2337	13	47	0	f
2338	14	47	0	f
2339	21	47	0	f
2340	2	47	0	f
2341	4	47	0	f
2342	27	47	0	f
2343	26	47	0	f
2344	11	47	0	f
2345	17	47	0	f
2346	18	47	0	f
2347	19	47	0	f
2348	15	47	0	f
2349	66	48	0	f
2350	73	48	0	f
2351	7	48	0	f
2352	5	48	0	f
2353	57	48	0	f
2354	40	48	0	f
2355	56	48	0	f
2356	53	48	0	f
2357	55	48	0	f
2358	44	48	0	f
2359	50	48	0	f
2360	33	48	0	f
2361	41	48	0	f
2362	20	48	0	f
2363	28	48	0	f
2364	25	48	0	f
2365	22	48	0	f
2366	31	48	0	f
2367	9	48	0	f
2368	29	48	0	f
2369	30	48	0	f
2370	49	48	0	f
2371	52	48	0	f
2372	48	48	0	f
2373	43	48	0	f
2374	54	48	0	f
2375	76	48	0	f
2376	74	48	0	f
2377	58	48	0	f
2378	78	48	0	f
2379	77	48	0	f
2380	68	48	0	f
2381	72	48	0	f
2382	60	48	0	f
2383	65	48	0	f
2384	63	48	0	f
2385	75	48	0	f
2386	59	48	0	f
2387	71	48	0	f
2388	62	48	0	f
2389	64	48	0	f
2390	67	48	0	f
2391	61	48	0	f
2392	69	48	0	f
2393	70	48	0	f
2394	37	48	0	f
2395	42	48	0	f
2396	32	48	0	f
2397	34	48	0	f
2398	46	48	0	f
2399	47	48	0	f
2400	12	48	0	f
2401	24	48	0	f
2402	8	48	0	f
2403	35	48	0	f
2404	39	48	0	f
2405	38	48	0	f
2406	10	48	0	f
2407	1	48	0	f
2408	45	48	0	f
2409	36	48	0	f
2410	51	48	0	f
2411	3	48	0	f
2412	23	48	0	f
2413	6	48	0	f
2414	16	48	0	f
2415	13	48	0	f
2416	14	48	0	f
2417	21	48	0	f
2418	2	48	0	f
2419	4	48	0	f
2420	27	48	0	f
2421	26	48	0	f
2422	11	48	0	f
2423	17	48	0	f
2424	18	48	0	f
2425	19	48	0	f
2426	15	48	0	f
2428	2	14	2	f
\.


--
-- Data for Name: contents; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.contents (content_id, date_of_creation, content_type, title, description, course_id, rate, view_count) FROM stdin;
111	2022-08-29	PAGE      	A Page	                                                                                                    	11	0	0
110	2022-08-26	VIDEO     	A Video	Description of a video                                                                              	11	0	0
108	2021-05-15	VIDEO     	Scarcity	Description of video 'Scarcity'                                                                     	10	0	4
109	2021-05-15	VIDEO     	Normative and positive statements	Description of video 'Normative and positive statements'                                            	10	0	4
107	2021-05-15	VIDEO     	Introoduction to economics	Description of video 'Introoduction to economics'                                                   	10	0	4
105	2021-03-13	VIDEO     	Binary and data	Description of video 'Binary and data'                                                              	9	0	7
104	2021-03-13	PAGE      	How do computers represent data?	Description of page 'How do computers represent data?'                                              	9	0	7
106	2021-03-13	PAGE      	Bits (binary digits)	Description of page 'Bits (binary digits)'                                                          	9	0	7
96	2020-05-08	VIDEO     	Reading pictographs	Description of video 'Reading pictographs'                                                          	6	0	14
95	2020-05-08	VIDEO     	Identifying individuals, variables and catagorical variables in a data set	Description of video 'Identifying individuals, variables and catagorical variables in a data set'   	6	0	14
98	2020-05-08	VIDEO     	Creating a bar graph	Description of video 'Creating a bar graph'                                                         	6	0	14
102	2020-11-13	VIDEO     	Scarcity	Description of video 'Scarcity'                                                                     	8	0	10
101	2020-11-13	VIDEO     	Introduction to economics	Description of video 'Introduction to economics'                                                    	8	0	10
103	2020-11-13	VIDEO     	Scarcity and rivalry	Description of video 'Scarcity and rivalry'                                                         	8	0	10
100	2020-10-16	PAGE      	Learn programming on ePathshala	Description of page 'Learn programming on ePathshala'                                               	7	0	11
99	2020-10-16	VIDEO     	What is Programming?	Description of video 'What is Programming?'                                                         	7	0	11
97	2020-05-08	VIDEO     	Reading bar graphs	Description of video 'Reading bar graphs'                                                           	6	0	14
92	2020-03-12	VIDEO     	Interpreting a histogram	Description of video 'Interpreting a histogram'                                                     	5	0	18
93	2020-03-12	QUIZ      	Create histograms	Description of quiz 'Create histograms'                                                             	5	0	18
89	2020-03-12	VIDEO     	Frequency tables and dot plots	Description of video 'Frequency tables and dot plots'                                               	5	0	18
90	2020-03-12	QUIZ      	Reading dot plots & frequency tables	Description of quiz 'Reading dot plots & frequency tables'                                          	5	0	18
94	2020-03-12	QUIZ      	Read histograms	Description of quiz 'Read histograms'                                                               	5	0	18
91	2020-03-12	VIDEO     	Creating a histogram	Description of video 'Creating a histogram'                                                         	5	0	18
84	2020-03-11	QUIZ      	Use ratios in right triangles	Description of quiz 'Use ratios in right triangles'                                                 	4	0	22
81	2020-03-11	PAGE      	Side ratios in right triangles as afunction of the angles	Description of page 'Side ratios in right triangles as afunction of the angles'                     	4	0	22
88	2020-03-11	QUIZ      	Traingle ratios in right triangles	Description of quiz 'Traingle ratios in right triangles'                                            	4	0	22
83	2020-03-11	VIDEO     	Using right triangle ratios to approximate angle measure	Description of video 'Using right triangle ratios to approximate angle measure'                     	4	0	22
80	2020-03-11	PAGE      	Hypotenuse, opposite and trigonometry	Description of page 'Hypotenuse, opposite and trigonometry'                                         	4	0	22
85	2020-03-11	VIDEO     	Triangle similarity & the trigonometric ratios	Description of video 'Triangle similarity & the trigonometric ratios'                               	4	0	22
87	2020-03-11	PAGE      	Traingle ratios in right triangles	Description of page 'Traingle ratios in right triangles'                                            	4	0	22
79	2020-03-11	PAGE      	Getting ready for right triangles and trigonometry	Description of page 'Getting ready for right triangles and trigonometry'                            	4	0	22
82	2020-03-11	VIDEO     	Using similarity to estimate ratio between side lengths	Description of video 'Using similarity to estimate ratio between side lengths'                      	4	0	22
86	2020-03-11	VIDEO     	Traingle ratios in right triangles	Description of video 'Traingle ratios in right triangles'                                           	4	0	22
66	2020-10-15	PAGE      	Rotations intro	Description of page 'Rotations intro'                                                               	3	0	24
73	2020-10-15	PAGE      	Translating shapes	Description of page 'Translating shapes'                                                            	3	0	24
7	2019-10-19	VIDEO     	What is a variable?	Description of video 'What is a variable?'                                                          	1	0	26
5	2019-10-19	VIDEO     	Intro to the coordinate plane	Description of video 'Intro to the coordinate plane'                                                	1	0	26
57	2019-10-01	QUIZ      	Polynomial special products: perfect square	Description of quiz 'Polynomial special products: perfect square'                                   	2	0	25
40	2019-10-01	QUIZ      	Add and subtract polynomials	Description of quiz 'Add and subtract polynomials'                                                  	2	0	25
56	2019-10-01	QUIZ      	Polynomial special products: difference of squares	Description of quiz 'Polynomial special products: difference of squares'                            	2	0	25
53	2019-10-01	QUIZ      	Multiply binomials by polynomials	Description of quiz 'Multiply binomials by polynomials'                                             	2	0	25
55	2019-10-01	VIDEO     	Polynomial special products: perfect square	Description of video 'Polynomial special products: perfect square'                                  	2	0	25
44	2019-10-01	VIDEO     	Multiplying monomials by polynomials	Description of video 'Multiplying monomials by polynomials'                                         	2	0	25
50	2019-10-01	VIDEO     	Multiply binomials by polynomials	Description of video 'Multiply binomials by polynomials'                                            	2	0	25
33	2019-10-01	QUIZ      	Average rate of change of polynomials	Description of quiz 'Average rate of change of polynomials'                                         	2	0	25
41	2019-10-01	VIDEO     	Multiplying monomials	Description of video 'Multiplying monomials'                                                        	2	0	25
20	2019-10-19	VIDEO     	Combining like terms with rational coefficients	Description of video 'Combining like terms with rational coefficients'                              	1	0	26
28	2019-10-19	VIDEO     	Undefined and indeterminate expressions	Description of video 'Undefined and indeterminate expressions'                                      	1	0	26
25	2019-10-19	QUIZ      	Equivalent expressions	Description of quiz 'Equivalent expressions'                                                        	1	0	26
22	2019-10-19	QUIZ      	Combining like terms with negative coefficients and distribution	Description of quiz 'Combining like terms with negative coefficients and distribution'              	1	0	26
31	2019-10-01	VIDEO     	Finding average rate of change of polynomials	Description of video 'Finding average rate of change of polynomials'                                	2	0	25
9	2019-10-19	VIDEO     	Creativity break: Why is creativity important in STEM jobs?	Description of video 'Creativity break: Why is creativity important in STEM jobs?'                  	1	0	26
29	2019-10-01	VIDEO     	Polinomials intro	Description of video 'Polinomials intro'                                                            	2	0	25
30	2019-10-01	VIDEO     	The parts of polynomial expressions	Description of video 'The parts of polynomial expressions'                                          	2	0	25
49	2019-10-01	VIDEO     	Multiply binomials by polynomials: area model	Description of video 'Multiply binomials by polynomials: area model'                                	2	0	25
52	2019-10-01	QUIZ      	Multiply binomials by polynomials: area model	Description of quiz 'Multiply binomials by polynomials: area model'                                 	2	0	25
48	2019-10-01	QUIZ      	Multiply monomials by polynomials	Description of quiz 'Multiply monomials by polynomials'                                             	2	0	25
43	2019-10-01	VIDEO     	Area model for multiplying monomials with negative terms	Description of video 'Area model for multiplying monomials with negative terms'                     	2	0	25
54	2019-10-01	VIDEO     	Polynomial special products: difference of squares	Description of video 'Polynomial special products: difference of squares'                           	2	0	25
76	2020-10-15	QUIZ      	Translate points	Description of quiz 'Translate points'                                                              	3	0	24
74	2020-10-15	VIDEO     	Transition challenge problem	Description of video 'Transition challenge problem'                                                 	3	0	24
58	2020-10-15	PAGE      	Getting ready for performing transformations	Description of page 'Getting ready for performing transformations'                                  	3	0	24
78	2020-10-15	QUIZ      	Translate shapes	Description of quiz 'Translate shapes'                                                              	3	0	24
77	2020-10-15	QUIZ      	Determining translations	Description of quiz 'Determining translations'                                                      	3	0	24
68	2020-10-15	QUIZ      	Identify transformations	Description of quiz 'Identify transformations'                                                      	3	0	24
72	2020-10-15	VIDEO     	Translating shapes	Description of video 'Translating shapes'                                                           	3	0	24
60	2020-10-15	VIDEO     	Terms & labels in geometry	Description of video 'Terms & labels in geometry'                                                   	3	0	24
65	2020-10-15	PAGE      	Translations intro	Description of page 'Translations intro'                                                            	3	0	24
63	2020-10-15	VIDEO     	Rigid transformations intro	Description of video 'Rigid transformations intro'                                                  	3	0	24
75	2020-10-15	PAGE      	Properties of translations	Description of page 'Properties of translations'                                                    	3	0	24
59	2020-10-15	VIDEO     	Euclid as father of geometry	Description of video 'Euclid as father of geometry'                                                 	3	0	24
71	2020-10-15	PAGE      	Determining translations	Description of page 'Determining translations'                                                      	3	0	24
62	2020-10-15	QUIZ      	Geometric definitions	Description of quiz 'Geometric definitions'                                                         	3	0	24
64	2020-10-15	VIDEO     	Dilations intro	Description of video 'Dilations intro'                                                              	3	0	24
67	2020-10-15	VIDEO     	Identifying transformations	Description of video 'Identifying transformations'                                                  	3	0	24
61	2020-10-15	VIDEO     	Geometric definitions example	Description of video 'Geometric definitions example'                                                	3	0	24
69	2020-10-15	VIDEO     	Translating points	Description of video 'Translating points'                                                           	3	0	24
70	2020-10-15	VIDEO     	Determining translations	Description of video 'Determining translations'                                                     	3	0	24
37	2019-10-01	PAGE      	Adding and subtracting polynomials review	Description of page 'Adding and subtracting polynomials review'                                     	2	0	25
42	2019-10-01	VIDEO     	Multiplying monomials by polynomials: area model	Description of video 'Multiplying monomials by polynomials: area model'                             	2	0	25
32	2019-10-01	VIDEO     	Sign of average rate of change of polynomials	Description of video 'Sign of average rate of change of polynomials'                                	2	0	25
34	2019-10-01	VIDEO     	Adding polynomials	Description of video 'Adding polynomials'                                                           	2	0	25
46	2019-10-01	QUIZ      	Multiply monomials	Description of quiz 'Multiply monomials'                                                            	2	0	25
47	2019-10-01	QUIZ      	Multiply monomials by polynomials: area model	Description of quiz 'Multiply monomials by polynomials: area model'                                 	2	0	25
12	2019-10-19	VIDEO     	Evaluating expressions with two variables	Description of video 'Evaluating expressions with two variables'                                    	1	0	26
24	2019-10-19	VIDEO     	Equivalent expressions	Description of video 'Equivalent expressions'                                                       	1	0	26
8	2019-10-19	VIDEO     	Why aren't we using the multiplication sign?	Description of video 'Why aren't we using the multiplication sign?'                                 	1	0	26
35	2019-10-01	VIDEO     	Subtracting polynomials	Description of video 'Subtracting polynomials'                                                      	2	0	25
39	2019-10-01	QUIZ      	Subtract polynomials (intro)	Description of quiz 'Subtract polynomials (intro)'                                                  	2	0	25
38	2019-10-01	QUIZ      	Add polynomials (intro)	Description of quiz 'Add polynomials (intro)'                                                       	2	0	25
10	2019-10-19	VIDEO     	Evaluating expressions with one variable	Description of video 'Evaluating expressions with one variable'                                     	1	0	26
1	2019-10-19	VIDEO     	Origins of algebra	Description of video 'Origins of algebra'                                                           	1	0	26
45	2019-10-01	PAGE      	Multiplying monomials by polynomials review	Description of page 'Multiplying monomials by polynomials review'                                   	2	0	25
36	2019-10-01	VIDEO     	Polynomial subtraction	Description of video 'Polynomial subtraction'                                                       	2	0	25
51	2019-10-01	PAGE      	Multiply binomials by polynomials review	Description of page 'Multiply binomials by polynomials review'                                      	2	0	25
3	2019-10-19	VIDEO     	The beauty of algebra	Description of video 'The beauty of algebra'                                                        	1	0	26
23	2019-10-19	QUIZ      	Combining like terms with rational coefficients	Description of quiz 'Combining like terms with rational coefficients'                               	1	0	26
6	2019-10-19	VIDEO     	Why all the letters in algebra?	Description of video 'Why all the letters in algebra?'                                              	1	0	26
16	2019-10-19	QUIZ      	Evaluating expressions with multiple variables	Description of quiz 'Evaluating expressions with multiple variables'                                	1	0	26
13	2019-10-19	PAGE      	Evaluating expressions with two variables	Description of page 'Evaluating expressions with two variables'                                     	1	0	26
14	2019-10-19	VIDEO     	Evaluating expressions with two variables: fractions & decimals	Description of video 'Evaluating expressions with two variables: fractions & decimals'              	1	0	26
21	2019-10-19	QUIZ      	Combining like terms with negative coefficients	Description of quiz 'Combining like terms with negative coefficients'                               	1	0	26
4	2019-10-19	VIDEO     	Creativity break: Why is creativity importants in algebra?	Description of video 'Creativity break: Why is creativity importants in algebra?'                   	1	0	26
27	2019-10-19	VIDEO     	The problem with dividing zero by zero	Description of video 'The problem with dividing zero by zero'                                       	1	0	26
26	2019-10-19	VIDEO     	Why dividing by zero is undefined?	Description of video 'Why dividing by zero is undefined?'                                           	1	0	26
11	2019-10-19	PAGE      	Evaluating expressions with one variable	Description of page 'Evaluating expressions with one variable'                                      	1	0	26
17	2019-10-19	QUIZ      	Evaluating expressions with multiple variables: fractions and decimals	Description of quiz 'Evaluating expressions with multiple variables: fractions and decimals'        	1	0	26
18	2019-10-19	VIDEO     	Combining like terms with negative coefficients & distribution	Description of video 'Combining like terms with negative coefficients & distribution'               	1	0	26
15	2019-10-19	PAGE      	Evaluating expressions with two variables: fractions & decimals	Description of page 'Evaluating expressions with two variables: fractions & decimals'               	1	0	26
19	2019-10-19	VIDEO     	Combining like terms with negative coefficients	Description of video 'Combining like terms with negative coefficients'                              	1	3.0000000000000000	27
2	2019-10-19	VIDEO     	Abstract-ness	Description of video 'Abstract-ness'                                                                	1	2.5000000000000000	28
\.


--
-- Data for Name: course_remain_contents; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.course_remain_contents (user_id, course_id, complete_count, remain_count) FROM stdin;
1	1	0	28
1	2	0	29
1	3	0	21
1	4	0	10
1	5	0	6
1	6	0	4
2	1	0	28
3	1	0	28
3	2	0	29
3	3	0	21
3	4	0	10
3	5	0	6
4	1	0	28
5	1	0	28
5	2	0	29
5	3	0	21
5	4	0	10
5	5	0	6
6	1	0	28
6	2	0	29
6	3	0	21
6	4	0	10
7	1	0	28
7	2	0	29
7	3	0	21
8	1	0	28
8	2	0	29
8	3	0	21
8	4	0	10
9	1	0	28
9	2	0	29
9	3	0	21
9	4	0	10
9	5	0	6
9	6	0	4
9	7	0	2
9	8	0	3
9	9	0	3
10	1	0	28
10	2	0	29
10	3	0	21
10	4	0	10
10	5	0	6
10	6	0	4
10	7	0	2
10	8	0	3
10	9	0	3
11	1	0	28
11	2	0	29
11	3	0	21
11	4	0	10
11	5	0	6
11	6	0	4
11	7	0	2
11	8	0	3
12	1	0	28
12	2	0	29
12	3	0	21
12	4	0	10
12	5	0	6
12	6	0	4
12	7	0	2
12	8	0	3
12	9	0	3
12	10	0	3
13	1	0	28
13	2	0	29
13	3	0	21
14	1	0	28
14	2	0	29
14	3	0	21
14	4	0	10
15	1	0	28
15	2	0	29
15	3	0	21
15	4	0	10
15	5	0	6
15	6	0	4
15	7	0	2
15	8	0	3
15	9	0	3
16	1	0	28
16	2	0	29
16	3	0	21
16	4	0	10
16	5	0	6
16	6	0	4
16	7	0	2
16	8	0	3
16	9	0	3
16	10	0	3
17	1	0	28
18	1	0	28
18	2	0	29
18	3	0	21
18	4	0	10
18	5	0	6
18	6	0	4
18	7	0	2
18	8	0	3
18	9	0	3
18	10	0	3
19	1	0	28
19	2	0	29
19	3	0	21
19	4	0	10
19	5	0	6
19	6	0	4
19	7	0	2
19	8	0	3
19	9	0	3
20	1	0	28
20	2	0	29
20	3	0	21
20	4	0	10
20	5	0	6
20	6	0	4
20	7	0	2
20	8	0	3
20	9	0	3
20	10	0	3
21	1	0	28
21	2	0	29
21	3	0	21
21	4	0	10
21	5	0	6
21	6	0	4
21	7	0	2
21	8	0	3
22	1	0	28
22	2	0	29
22	3	0	21
22	4	0	10
22	5	0	6
22	6	0	4
22	7	0	2
22	8	0	3
22	9	0	3
22	10	0	3
23	1	0	28
23	2	0	29
23	3	0	21
23	4	0	10
23	5	0	6
23	6	0	4
23	7	0	2
23	8	0	3
23	9	0	3
24	1	0	28
24	2	0	29
24	3	0	21
24	4	0	10
25	1	0	28
25	2	0	29
25	3	0	21
25	4	0	10
25	5	0	6
25	6	0	4
25	7	0	2
25	8	0	3
26	1	0	28
26	2	0	29
26	3	0	21
26	4	0	10
26	5	0	6
26	6	0	4
27	1	0	28
27	2	0	29
27	3	0	21
27	4	0	10
27	5	0	6
27	6	0	4
27	7	0	2
28	1	0	28
28	2	0	29
28	3	0	21
29	1	0	28
30	1	0	28
30	2	0	29
30	3	0	21
30	4	0	10
30	5	0	6
30	6	0	4
30	7	0	2
31	1	0	28
31	2	0	29
31	3	0	21
31	4	0	10
31	5	0	6
32	1	0	28
32	2	0	29
33	1	0	28
33	2	0	29
33	3	0	21
33	4	0	10
33	5	0	6
33	6	0	4
33	7	0	2
34	1	0	28
34	2	0	29
34	3	0	21
34	4	0	10
34	5	0	6
34	6	0	4
34	7	0	2
34	8	0	3
34	9	0	3
34	10	0	3
35	1	0	28
35	2	0	29
35	3	0	21
35	4	0	10
35	5	0	6
35	6	0	4
35	7	0	2
35	8	0	3
35	9	0	3
36	1	0	28
36	2	0	29
36	3	0	21
36	4	0	10
36	5	0	6
37	1	0	28
37	2	0	29
37	3	0	21
37	4	0	10
37	5	0	6
37	6	0	4
38	1	0	28
38	2	0	29
38	3	0	21
38	4	0	10
38	5	0	6
38	6	0	4
39	1	0	28
39	2	0	29
39	3	0	21
39	4	0	10
39	5	0	6
39	6	0	4
39	7	0	2
39	8	0	3
40	1	0	28
40	2	0	29
40	3	0	21
40	4	0	10
41	1	0	28
41	2	0	29
41	3	0	21
41	4	0	10
41	5	0	6
41	6	0	4
41	7	0	2
42	1	0	28
42	2	0	29
42	3	0	21
42	4	0	10
42	5	0	6
42	6	0	4
42	7	0	2
42	8	0	3
42	9	0	3
42	10	0	3
43	1	0	28
43	2	0	29
43	3	0	21
43	4	0	10
43	5	0	6
43	6	0	4
43	7	0	2
43	8	0	3
43	9	0	3
43	10	0	3
44	1	0	28
44	2	0	29
44	3	0	21
44	4	0	10
44	5	0	6
44	6	0	4
44	7	0	2
44	8	0	3
45	1	0	28
45	2	0	29
45	3	0	21
46	1	0	28
46	2	0	29
46	3	0	21
46	4	0	10
47	1	0	28
47	2	0	29
47	3	0	21
47	4	0	10
47	5	0	6
48	1	0	28
48	2	0	29
48	3	0	21
49	1	0	28
49	2	0	29
49	3	0	21
49	4	0	10
49	5	0	6
49	6	0	4
49	7	0	2
49	8	0	3
49	9	0	3
50	1	0	28
50	2	0	29
50	3	0	21
50	4	0	10
50	5	0	6
50	6	0	4
50	7	0	2
50	8	0	3
50	9	0	3
14	9	0	3
\.


--
-- Data for Name: course_tags; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.course_tags (course_id, tag) FROM stdin;
1	math
2	math
3	math
4	math
5	math
6	math
3	geometry
4	geometry
7	computer
9	computer
9	internet
8	economics
10	economics
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.courses (course_id, title, description, date_of_creation, price, creator_id, rate, enroll_count) FROM stdin;
11	Course	Course Description                                                                                  	2022-08-25	0	51	0	0
10	Macroeconomics	Learn macroeconomics                                                                                	2021-05-15	500	60	0	8
9	Computers and Internet	Learn how the amazing world of internet works                                                       	2021-03-13	1200	59	0	17
8	Microeconomics	Learn microeconomics                                                                                	2020-11-13	500	58	0	21
7	Computer Programming	Learn the art of programming                                                                        	2020-10-16	1000	57	0	25
6	Statistics and Probablity	Learn statistics and probablity                                                                     	2020-05-08	700	56	0	29
5	Statistics	Learn statistics basics                                                                             	2020-03-12	700	55	0	34
4	Trigonometry	Master trigonometry                                                                                 	2020-03-11	600	54	0	40
3	Geometry	Learn geometry having fun                                                                           	2020-10-15	600	53	0	45
1	Algebra 1	Introduction to algebra                                                                             	2019-10-19	500	51	2.7500000000000000	50
2	Algebra 2	Some advanced topics on algebra                                                                     	2019-10-01	500	52	0	46
\.


--
-- Data for Name: enrolled_courses; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.enrolled_courses (user_id, course_id, date_of_join) FROM stdin;
1	1	2022-08-25
1	2	2022-08-25
1	3	2022-08-25
1	4	2022-08-25
1	5	2022-08-25
1	6	2022-08-25
2	1	2022-08-25
3	1	2022-08-25
3	2	2022-08-25
3	3	2022-08-25
3	4	2022-08-25
3	5	2022-08-25
4	1	2022-08-25
5	1	2022-08-25
5	2	2022-08-25
5	3	2022-08-25
5	4	2022-08-25
5	5	2022-08-25
6	1	2022-08-25
6	2	2022-08-25
6	3	2022-08-25
6	4	2022-08-25
7	1	2022-08-25
7	2	2022-08-25
7	3	2022-08-25
8	1	2022-08-25
8	2	2022-08-25
8	3	2022-08-25
8	4	2022-08-25
9	1	2022-08-25
9	2	2022-08-25
9	3	2022-08-25
9	4	2022-08-25
9	5	2022-08-25
9	6	2022-08-25
9	7	2022-08-25
9	8	2022-08-25
9	9	2022-08-25
10	1	2022-08-25
10	2	2022-08-25
10	3	2022-08-25
10	4	2022-08-25
10	5	2022-08-25
10	6	2022-08-25
10	7	2022-08-25
10	8	2022-08-25
10	9	2022-08-25
11	1	2022-08-25
11	2	2022-08-25
11	3	2022-08-25
11	4	2022-08-25
11	5	2022-08-25
11	6	2022-08-25
11	7	2022-08-25
11	8	2022-08-25
12	1	2022-08-25
12	2	2022-08-25
12	3	2022-08-25
12	4	2022-08-25
12	5	2022-08-25
12	6	2022-08-25
12	7	2022-08-25
12	8	2022-08-25
12	9	2022-08-25
12	10	2022-08-25
13	1	2022-08-25
13	2	2022-08-25
13	3	2022-08-25
14	1	2022-08-25
14	2	2022-08-25
14	3	2022-08-25
14	4	2022-08-25
15	1	2022-08-25
15	2	2022-08-25
15	3	2022-08-25
15	4	2022-08-25
15	5	2022-08-25
15	6	2022-08-25
15	7	2022-08-25
15	8	2022-08-25
15	9	2022-08-25
16	1	2022-08-25
16	2	2022-08-25
16	3	2022-08-25
16	4	2022-08-25
16	5	2022-08-25
16	6	2022-08-25
16	7	2022-08-25
16	8	2022-08-25
16	9	2022-08-25
16	10	2022-08-25
17	1	2022-08-25
18	1	2022-08-25
18	2	2022-08-25
18	3	2022-08-25
18	4	2022-08-25
18	5	2022-08-25
18	6	2022-08-25
18	7	2022-08-25
18	8	2022-08-25
18	9	2022-08-25
18	10	2022-08-25
19	1	2022-08-25
19	2	2022-08-25
19	3	2022-08-25
19	4	2022-08-25
19	5	2022-08-25
19	6	2022-08-25
19	7	2022-08-25
19	8	2022-08-25
19	9	2022-08-25
20	1	2022-08-25
20	2	2022-08-25
20	3	2022-08-25
20	4	2022-08-25
20	5	2022-08-25
20	6	2022-08-25
20	7	2022-08-25
20	8	2022-08-25
20	9	2022-08-25
20	10	2022-08-25
21	1	2022-08-25
21	2	2022-08-25
21	3	2022-08-25
21	4	2022-08-25
21	5	2022-08-25
21	6	2022-08-25
21	7	2022-08-25
21	8	2022-08-25
22	1	2022-08-25
22	2	2022-08-25
22	3	2022-08-25
22	4	2022-08-25
22	5	2022-08-25
22	6	2022-08-25
22	7	2022-08-25
22	8	2022-08-25
22	9	2022-08-25
22	10	2022-08-25
23	1	2022-08-25
23	2	2022-08-25
23	3	2022-08-25
23	4	2022-08-25
23	5	2022-08-25
23	6	2022-08-25
23	7	2022-08-25
23	8	2022-08-25
23	9	2022-08-25
24	1	2022-08-25
24	2	2022-08-25
24	3	2022-08-25
24	4	2022-08-25
25	1	2022-08-25
25	2	2022-08-25
25	3	2022-08-25
25	4	2022-08-25
25	5	2022-08-25
25	6	2022-08-25
25	7	2022-08-25
25	8	2022-08-25
26	1	2022-08-25
26	2	2022-08-25
26	3	2022-08-25
26	4	2022-08-25
26	5	2022-08-25
26	6	2022-08-25
27	1	2022-08-25
27	2	2022-08-25
27	3	2022-08-25
27	4	2022-08-25
27	5	2022-08-25
27	6	2022-08-25
27	7	2022-08-25
28	1	2022-08-25
28	2	2022-08-25
28	3	2022-08-25
29	1	2022-08-25
30	1	2022-08-25
30	2	2022-08-25
30	3	2022-08-25
30	4	2022-08-25
30	5	2022-08-25
30	6	2022-08-25
30	7	2022-08-25
31	1	2022-08-25
31	2	2022-08-25
31	3	2022-08-25
31	4	2022-08-25
31	5	2022-08-25
32	1	2022-08-25
32	2	2022-08-25
33	1	2022-08-25
33	2	2022-08-25
33	3	2022-08-25
33	4	2022-08-25
33	5	2022-08-25
33	6	2022-08-25
33	7	2022-08-25
34	1	2022-08-25
34	2	2022-08-25
34	3	2022-08-25
34	4	2022-08-25
34	5	2022-08-25
34	6	2022-08-25
34	7	2022-08-25
34	8	2022-08-25
34	9	2022-08-25
34	10	2022-08-25
35	1	2022-08-25
35	2	2022-08-25
35	3	2022-08-25
35	4	2022-08-25
35	5	2022-08-25
35	6	2022-08-25
35	7	2022-08-25
35	8	2022-08-25
35	9	2022-08-25
36	1	2022-08-25
36	2	2022-08-25
36	3	2022-08-25
36	4	2022-08-25
36	5	2022-08-25
37	1	2022-08-25
37	2	2022-08-25
37	3	2022-08-25
37	4	2022-08-25
37	5	2022-08-25
37	6	2022-08-25
38	1	2022-08-25
38	2	2022-08-25
38	3	2022-08-25
38	4	2022-08-25
38	5	2022-08-25
38	6	2022-08-25
39	1	2022-08-25
39	2	2022-08-25
39	3	2022-08-25
39	4	2022-08-25
39	5	2022-08-25
39	6	2022-08-25
39	7	2022-08-25
39	8	2022-08-25
40	1	2022-08-25
40	2	2022-08-25
40	3	2022-08-25
40	4	2022-08-25
41	1	2022-08-25
41	2	2022-08-25
41	3	2022-08-25
41	4	2022-08-25
41	5	2022-08-25
41	6	2022-08-25
41	7	2022-08-25
42	1	2022-08-25
42	2	2022-08-25
42	3	2022-08-25
42	4	2022-08-25
42	5	2022-08-25
42	6	2022-08-25
42	7	2022-08-25
42	8	2022-08-25
42	9	2022-08-25
42	10	2022-08-25
43	1	2022-08-25
43	2	2022-08-25
43	3	2022-08-25
43	4	2022-08-25
43	5	2022-08-25
43	6	2022-08-25
43	7	2022-08-25
43	8	2022-08-25
43	9	2022-08-25
43	10	2022-08-25
44	1	2022-08-25
44	2	2022-08-25
44	3	2022-08-25
44	4	2022-08-25
44	5	2022-08-25
44	6	2022-08-25
44	7	2022-08-25
44	8	2022-08-25
45	1	2022-08-25
45	2	2022-08-25
45	3	2022-08-25
46	1	2022-08-25
46	2	2022-08-25
46	3	2022-08-25
46	4	2022-08-25
47	1	2022-08-25
47	2	2022-08-25
47	3	2022-08-25
47	4	2022-08-25
47	5	2022-08-25
48	1	2022-08-25
48	2	2022-08-25
48	3	2022-08-25
49	1	2022-08-25
49	2	2022-08-25
49	3	2022-08-25
49	4	2022-08-25
49	5	2022-08-25
49	6	2022-08-25
49	7	2022-08-25
49	8	2022-08-25
49	9	2022-08-25
50	1	2022-08-25
50	2	2022-08-25
50	3	2022-08-25
50	4	2022-08-25
50	5	2022-08-25
50	6	2022-08-25
50	7	2022-08-25
50	8	2022-08-25
50	9	2022-08-25
14	9	2022-08-30
\.


--
-- Data for Name: forum_questions; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.forum_questions (question_id, asker_id, title, date_of_ask, rate, time_of_ask) FROM stdin;
1	61	question 1	2022-08-29	0	05:20:32.154914
2	61	question 2	2022-08-29	0	05:20:57.433963
\.


--
-- Data for Name: forum_questions_tags; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.forum_questions_tags (question_id, tag) FROM stdin;
1	tag 1
1	tag 2
2	tag 1
2	tag 3
\.


--
-- Data for Name: query_count; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.query_count (count) FROM stdin;
0
\.


--
-- Data for Name: quiz_grades; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.quiz_grades (user_id, content_id, grade) FROM stdin;
\.


--
-- Data for Name: student_interests; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.student_interests (student_id, interest) FROM stdin;
1	computer
1	history
2	computer
2	history
2	literature
3	statistics
3	math
3	computer
4	literature
4	statistics
4	math
5	statistics
5	math
5	computer
6	statistics
7	literature
7	statistics
7	math
8	math
8	computer
8	history
9	literature
9	statistics
9	math
10	computer
10	history
10	literature
11	statistics
11	math
11	computer
12	literature
12	statistics
12	math
13	literature
13	statistics
13	math
14	literature
14	statistics
14	math
15	statistics
15	math
15	computer
16	statistics
16	math
16	computer
17	literature
17	statistics
17	math
18	computer
18	history
18	literature
19	statistics
19	math
19	computer
20	literature
20	statistics
20	math
21	history
21	literature
21	statistics
22	history
22	literature
22	statistics
23	computer
23	history
23	literature
24	statistics
24	math
24	computer
25	computer
25	history
25	literature
26	math
26	computer
26	history
27	computer
27	history
27	literature
28	history
28	literature
28	statistics
29	math
29	computer
29	history
30	literature
30	statistics
30	math
31	math
31	computer
31	history
32	computer
32	history
32	literature
33	math
33	computer
33	history
34	computer
34	history
34	literature
35	statistics
35	math
35	computer
36	math
36	computer
36	history
37	math
37	computer
37	history
38	literature
38	statistics
38	math
39	statistics
39	math
39	computer
40	math
40	computer
40	history
41	computer
41	history
41	literature
42	computer
42	history
42	literature
43	literature
43	statistics
43	math
44	statistics
44	math
44	computer
45	statistics
45	math
45	computer
46	math
46	computer
46	history
47	math
47	computer
47	history
48	math
48	computer
48	history
49	statistics
49	math
49	computer
1	math
6	literature
6	math
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.students (user_id, date_of_join, rank_point) FROM stdin;
1	2020-01-08	0
2	2020-05-16	0
3	2021-07-15	0
4	2021-12-14	0
5	2021-06-28	0
6	2021-04-06	0
7	2020-03-15	0
8	2021-09-05	0
9	2021-03-02	0
10	2021-05-04	0
11	2021-01-04	0
12	2020-10-16	0
13	2020-03-08	0
14	2021-02-15	0
15	2021-07-03	0
16	2020-02-16	0
17	2020-01-26	0
18	2021-03-23	0
19	2021-04-09	0
20	2020-02-17	0
21	2020-02-11	0
22	2020-04-21	0
23	2021-02-16	0
24	2020-08-01	0
25	2020-12-15	0
26	2021-07-20	0
27	2021-01-01	0
28	2020-04-27	0
29	2020-12-13	0
30	2021-08-25	0
31	2020-05-17	0
32	2020-05-15	0
33	2021-12-22	0
34	2021-04-28	0
35	2021-03-15	0
36	2020-09-04	0
37	2021-01-28	0
38	2021-11-05	0
39	2020-11-13	0
40	2020-05-26	0
41	2020-08-16	0
42	2021-05-02	0
43	2021-03-03	0
44	2021-12-07	0
45	2020-10-06	0
46	2021-08-20	0
47	2021-09-15	0
48	2020-11-28	0
49	2020-07-11	0
50	2021-07-20	0
61	2022-08-26	0
\.


--
-- Data for Name: teacher_specialities; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.teacher_specialities (teacher_id, speciality) FROM stdin;
51	Computer
52	Math
53	Math
53	History
54	Math
55	Statistics
56	Statistics
57	Computer
57	Math
58	Economics
58	Literature
59	Computer
60	Economics
60	History
51	Math
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.teachers (user_id, date_of_join, credit, rate) FROM stdin;
61	2022-08-26	0	0
60	2021-05-15	0	0
59	2021-03-13	1200	0
58	2020-11-13	0	0
57	2020-10-16	0	0
56	2020-05-08	0	0
55	2020-03-12	2800	0
54	2020-03-11	0	0
51	2019-10-19	1000	2.7500000000000000
53	2020-10-15	0	0
52	2019-10-01	0	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.users (user_id, full_name, security_key, date_of_birth, bio, email) FROM stdin;
2	Marisol Hicks	12345678                        	1997-11-04	                                                                                                    	marisol445@gmail.com
3	Jose Sylvester	12345678                        	2000-03-06	                                                                                                    	jose7038@gmail.com
4	William Adams	12345678                        	1993-11-21	                                                                                                    	william2284@gmail.com
7	Allyson Moschetti	12345678                        	1997-12-05	                                                                                                    	allyson3467@gmail.com
8	Dolores White	12345678                        	1994-09-24	                                                                                                    	dolores2369@gmail.com
9	Dorothy Alford	12345678                        	1998-01-04	                                                                                                    	dorothy1775@gmail.com
10	Beth Smith	12345678                        	1997-09-18	                                                                                                    	beth3902@gmail.com
11	Lila Crawford	12345678                        	1983-10-20	                                                                                                    	lila6053@gmail.com
12	Devon Steger	12345678                        	1991-06-09	                                                                                                    	devon1321@gmail.com
13	Al Lynch	12345678                        	1989-07-24	                                                                                                    	al8986@gmail.com
14	Joi Bellefeuille	12345678                        	1992-11-17	                                                                                                    	joi6193@gmail.com
15	Kimberly Toler	12345678                        	1981-04-06	                                                                                                    	kimberly1991@gmail.com
16	Tonya Harris	12345678                        	1998-03-20	                                                                                                    	tonya6665@gmail.com
17	Joseph Sharp	12345678                        	1993-12-28	                                                                                                    	joseph7068@gmail.com
18	Carrie Andrew	12345678                        	1987-09-24	                                                                                                    	carrie7877@gmail.com
19	Louis Laster	12345678                        	1989-01-12	                                                                                                    	louis9310@gmail.com
20	Dustin Coppinger	12345678                        	1997-11-25	                                                                                                    	dustin8186@gmail.com
21	Hilario Skrine	12345678                        	1995-12-05	                                                                                                    	hilario581@gmail.com
22	Crystal Warnick	12345678                        	1992-10-03	                                                                                                    	crystal478@gmail.com
23	Mamie Richmond	12345678                        	1991-12-04	                                                                                                    	mamie4456@gmail.com
24	Bryan Harker	12345678                        	1984-10-04	                                                                                                    	bryan305@gmail.com
25	Deborah Kachmarsky	12345678                        	1987-06-06	                                                                                                    	deborah8755@gmail.com
26	Sharon Valcourt	12345678                        	1999-03-26	                                                                                                    	sharon6716@gmail.com
27	Steven Hawkins	12345678                        	1992-05-09	                                                                                                    	steven6322@gmail.com
28	Michael Ellis	12345678                        	1988-01-02	                                                                                                    	michael3105@gmail.com
29	Willie Vieira	12345678                        	1985-07-01	                                                                                                    	willie8026@gmail.com
30	Shari Swartz	12345678                        	1982-09-26	                                                                                                    	shari875@gmail.com
31	Thomas Caraballo	12345678                        	1990-01-03	                                                                                                    	thomas476@gmail.com
32	Sharon Acker	12345678                        	1988-11-26	                                                                                                    	sharon5866@gmail.com
33	James Thomas	12345678                        	1984-08-02	                                                                                                    	james8865@gmail.com
1	Mary Prezzia	12345678                        	1986-02-25	                                                                                                    	mary1151@gmail.com
6	Ashley Langston	undefined                       	1980-03-27	Hi, I am Ashley Langston                                                                            	ashley932@gmail.com
34	Reginald Contreras	12345678                        	1992-07-17	                                                                                                    	reginald5090@gmail.com
35	Robert Gartin	12345678                        	1999-02-15	                                                                                                    	robert2831@gmail.com
36	Sharon Gamino	12345678                        	1999-11-17	                                                                                                    	sharon1938@gmail.com
37	Cynthia Gonzalez	12345678                        	1989-05-05	                                                                                                    	cynthia6438@gmail.com
38	Brent Clower	12345678                        	1998-05-18	                                                                                                    	brent4149@gmail.com
39	Philip Vanderloo	12345678                        	1985-05-13	                                                                                                    	philip6560@gmail.com
40	Tana Kinloch	12345678                        	1995-05-24	                                                                                                    	tana6370@gmail.com
41	Maria Summer	12345678                        	1981-10-16	                                                                                                    	maria1475@gmail.com
42	Douglas Mcgowan	12345678                        	1992-05-09	                                                                                                    	douglas2320@gmail.com
43	Noah Jamerson	12345678                        	1984-02-25	                                                                                                    	noah2915@gmail.com
44	Helen Burton	12345678                        	1993-03-18	                                                                                                    	helen2377@gmail.com
45	Crystal Hamby	12345678                        	1986-10-08	                                                                                                    	crystal1815@gmail.com
46	Glen Basista	12345678                        	1997-12-27	                                                                                                    	glen3930@gmail.com
47	Rodney Wolfe	12345678                        	1988-05-10	                                                                                                    	rodney23@gmail.com
48	Lori Gilmore	12345678                        	1986-01-07	                                                                                                    	lori8056@gmail.com
49	Kristina Shriver	12345678                        	1996-11-06	                                                                                                    	kristina8057@gmail.com
50	William Kish	12345678                        	1993-12-07	                                                                                                    	william3749@gmail.com
52	Carolyn Watkins	12345678                        	2000-06-12	                                                                                                    	carolyn8065@gmail.com
53	Diane Jones	12345678                        	1998-06-24	                                                                                                    	diane6212@gmail.com
54	Helena Nolder	12345678                        	1992-11-09	                                                                                                    	helena1754@gmail.com
55	Mike Mills	12345678                        	1985-11-09	                                                                                                    	mike7179@gmail.com
56	Charles Wiltberger	12345678                        	1982-09-21	                                                                                                    	charles2480@gmail.com
57	Henry Depalma	12345678                        	1993-06-27	                                                                                                    	henry4121@gmail.com
60	Pamela Pemberton	12345678                        	1981-02-21	                                                                                                    	pamela4346@gmail.com
58	Mario Barnett	12345678                        	1998-02-23	                                                                                                    	mario4755@gmail.com
59	Hubert Rodriguez	12345678                        	1988-11-19	                                                                                                    	hubert3151@gmail.com
51	Martha Marbley	undefined                       	1986-05-26	                                                                                                    	martha4381@gmail.com
5	Michelle Kimmell	12345678                        	1992-01-01	                                                                                                    	michelle2802@gmail.com
61	Siam	12345678                        	2000-10-16	                                                                                                    	siam11651@outlook.com
\.


--
-- Name: content_viewers_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epathshala
--

SELECT pg_catalog.setval('public.content_viewers_content_id_seq', 2436, true);


--
-- Name: banks bank_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT bank_pkey PRIMARY KEY (bank_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (comment_id);


--
-- Name: content_viewers content_viewers_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.content_viewers
    ADD CONSTRAINT content_viewers_pkey PRIMARY KEY (view_id);


--
-- Name: content_viewers content_viewers_un; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.content_viewers
    ADD CONSTRAINT content_viewers_un UNIQUE (content_id, user_id);


--
-- Name: contents contents_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (content_id);


--
-- Name: course_remain_contents course_remain_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_remain_contents
    ADD CONSTRAINT course_remain_contents_pkey PRIMARY KEY (user_id, course_id);


--
-- Name: course_tags course_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_tags
    ADD CONSTRAINT course_tags_pkey PRIMARY KEY (course_id, tag);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: enrolled_courses enrolled_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.enrolled_courses
    ADD CONSTRAINT enrolled_courses_pkey PRIMARY KEY (user_id, course_id);


--
-- Name: forum_questions forum_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.forum_questions
    ADD CONSTRAINT forum_questions_pkey PRIMARY KEY (question_id);


--
-- Name: forum_questions_tags forum_questions_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.forum_questions_tags
    ADD CONSTRAINT forum_questions_tags_pkey PRIMARY KEY (question_id, tag);


--
-- Name: forum_questions forum_questions_title_asker_id_key; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.forum_questions
    ADD CONSTRAINT forum_questions_title_asker_id_key UNIQUE (title, asker_id);


--
-- Name: quiz_grades quiz_id_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.quiz_grades
    ADD CONSTRAINT quiz_id_pkey PRIMARY KEY (user_id, content_id);


--
-- Name: student_interests student_interests_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.student_interests
    ADD CONSTRAINT student_interests_pkey PRIMARY KEY (student_id, interest);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (user_id);


--
-- Name: teacher_specialities teacher_specialities_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.teacher_specialities
    ADD CONSTRAINT teacher_specialities_pkey PRIMARY KEY (teacher_id, speciality);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: content_viewers content_view_complete_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER content_view_complete_trigger AFTER UPDATE OF completed ON public.content_viewers FOR EACH ROW EXECUTE FUNCTION public.content_view_complete_trigger();


--
-- Name: content_viewers contents_rate_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER contents_rate_trigger AFTER INSERT OR DELETE OR UPDATE OF rate ON public.content_viewers FOR EACH ROW EXECUTE FUNCTION public.contents_rate_trigger();


--
-- Name: content_viewers contents_view_count_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER contents_view_count_trigger AFTER INSERT OR DELETE OR UPDATE ON public.content_viewers FOR EACH ROW EXECUTE FUNCTION public.contents_view_count_trigger();


--
-- Name: enrolled_courses courses_enroll_count_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER courses_enroll_count_trigger AFTER INSERT OR DELETE OR UPDATE ON public.enrolled_courses FOR EACH ROW EXECUTE FUNCTION public.courses_enroll_count_trigger();


--
-- Name: contents courses_rate_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER courses_rate_trigger AFTER INSERT OR DELETE OR UPDATE OF rate ON public.contents FOR EACH ROW EXECUTE FUNCTION public.courses_rate_trigger();


--
-- Name: enrolled_courses enrolled_courses_insert_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER enrolled_courses_insert_trigger AFTER INSERT ON public.enrolled_courses FOR EACH ROW EXECUTE FUNCTION public.enrolled_courses_insert_trigger();


--
-- Name: users insert_user_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER insert_user_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.insert_user_trigger();


--
-- Name: courses teachers_rate_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER teachers_rate_trigger AFTER INSERT OR DELETE OR UPDATE OF rate ON public.courses FOR EACH ROW EXECUTE FUNCTION public.teachers_rate_trigger();


--
-- Name: comments comments_commenter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_commenter_id_fkey FOREIGN KEY (commenter_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: comments comments_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(content_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: content_viewers content_viewers_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.content_viewers
    ADD CONSTRAINT content_viewers_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(content_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: content_viewers content_viewers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.content_viewers
    ADD CONSTRAINT content_viewers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: contents contents_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_remain_contents course_remain_contents_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_remain_contents
    ADD CONSTRAINT course_remain_contents_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_remain_contents course_remain_contents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_remain_contents
    ADD CONSTRAINT course_remain_contents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_tags course_tags_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_tags
    ADD CONSTRAINT course_tags_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: courses courses_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.teachers(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: enrolled_courses enrolled_courses_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.enrolled_courses
    ADD CONSTRAINT enrolled_courses_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: enrolled_courses enrolled_courses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.enrolled_courses
    ADD CONSTRAINT enrolled_courses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.students(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: forum_questions forum_questions_asker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.forum_questions
    ADD CONSTRAINT forum_questions_asker_id_fkey FOREIGN KEY (asker_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: forum_questions_tags forum_questions_tags_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.forum_questions_tags
    ADD CONSTRAINT forum_questions_tags_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.forum_questions(question_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: quiz_grades quiz_id_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.quiz_grades
    ADD CONSTRAINT quiz_id_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(content_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: quiz_grades quiz_id_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.quiz_grades
    ADD CONSTRAINT quiz_id_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.students(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_interests student_interests_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.student_interests
    ADD CONSTRAINT student_interests_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teacher_specialities teacher_specialities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.teacher_specialities
    ADD CONSTRAINT teacher_specialities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teachers teachers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

