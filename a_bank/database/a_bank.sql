--
-- PostgreSQL database dump
--

-- Dumped from database version 14.3
-- Dumped by pg_dump version 14.3

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
2	12345678	100000
8	12345678	100000
9	12345678	100000
13	12345678	100000
14	12345678	100000
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
\.


--
-- PostgreSQL database dump complete
--

