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
-- Name: add_credit(bigint, character varying, integer); Type: FUNCTION; Schema: public; Owner: a_bank
--

CREATE FUNCTION public.add_credit(param_client_id bigint, param_password character varying, param_amount integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.add_credit(param_client_id bigint, param_password character varying, param_amount integer) OWNER TO a_bank;

--
-- Name: subtract(bigint, character varying, integer); Type: FUNCTION; Schema: public; Owner: a_bank
--

CREATE FUNCTION public.subtract(param_client_id bigint, param_password character varying, param_amount integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
	SELECT CREDIT INTO AMOUNT
	FROM CLIENTS
	WHERE CLIENT_ID = PARAM_CLIENT_ID;
	IF PARAM_AMOUNT > AMOUNT THEN
		RETURN 2; --INSUFFICIENT CREDIT
	END IF;
	UPDATE CLIENTS
	SET CREDIT = CREDIT - PARAM_AMOUNT
	WHERE CLIENT_ID = PARAM_CLIENT_ID;
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.subtract(param_client_id bigint, param_password character varying, param_amount integer) OWNER TO a_bank;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: a_bank
--

CREATE TABLE public.clients (
    client_id bigint NOT NULL,
    security_key character varying NOT NULL,
    credit integer DEFAULT 0 NOT NULL,
    CONSTRAINT client_client_id_check CHECK ((client_id > 0)),
    CONSTRAINT client_credit_check CHECK ((0 <= credit)),
    CONSTRAINT client_security_key_check CHECK (((8 <= length((security_key)::text)) AND (length((security_key)::text) <= 32)))
);


ALTER TABLE public.clients OWNER TO a_bank;

--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: a_bank
--

COPY public.clients (client_id, security_key, credit) FROM stdin;
15	12345678	100000
18	12345678	100000
21	12345678	100000
23	12345678	100000
25	12345678	100000
26	12345678	100000
32	12345678	100000
33	12345678	100000
37	12345678	100000
38	12345678	100000
40	12345678	100000
43	12345678	100000
45	12345678	100000
46	12345678	100000
47	12345678	100000
49	12345678	100000
54	12345678	100000
56	12345678	100000
9	12345678	0
8	12345678	98000
13	12345678	97600
14	12345678	103200
2	12345678	97600
\.


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: a_bank
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- PostgreSQL database dump complete
--

