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
-- Name: insert_user(character varying, character varying, character varying, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: epathshala
--

CREATE FUNCTION public.insert_user(param_full_name character varying, param_email character varying, param_password character varying, param_day integer, param_month integer, param_year integer, param_user_type character varying, param_gender character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	NEW_USER_ID BIGINT;
BEGIN
	IF LENGTH(PARAM_FULL_NAME) = 0 THEN
		RETURN 1; --EMPTY NAME ERROR
	END IF;
	IF LENGTH(PARAM_EMAIL) = 0 THEN
		RETURN 2; --EMPTY EMAIL ERROR
	END IF;
	IF PARAM_EMAIL NOT LIKE '%_@_%.___' THEN
		RETURN 3; --INVALID EMAIL ERROR
	END IF;
	IF LENGTH(PARAM_PASSWORD) < 8 THEN
		RETURN 4; --PASSWORD TOO SHORT ERROR
	END IF;
	IF LENGTH(PARAM_PASSWORD) > 32 THEN
		RETURN 5; --PASSWORD TOO LONG ERROR
	END IF;
	IF NOT IS_VALID_DATE(PARAM_DAY, PARAM_MONTH, PARAM_YEAR) THEN
		RETURN 6; --INVALID DATE ERROR
	END IF;
	SELECT USERS.USER_ID INTO NEW_USER_ID
	FROM USERS
	JOIN STUDENTS
	ON(USERS.USER_ID = STUDENTS.USER_ID)
	WHERE EMAIL = PARAM_EMAIL;
	IF NEW_USER_ID IS NOT NULL THEN
		RETURN 7; --STUDENT ALREADY PRESENT
	END IF;
	SELECT USERS.USER_ID INTO NEW_USER_ID
	FROM USERS
	JOIN TEACHERS
	ON(USERS.USER_ID = TEACHERS.USER_ID)
	WHERE EMAIL = PARAM_EMAIL;
	IF NEW_USER_ID IS NOT NULL THEN
		RETURN 8; --TEACHER ALREADY PRESENT
	END IF;
	NEW_USER_ID = GET_NEW_USER_ID();
	INSERT INTO USERS
	(USER_ID, FULL_NAME, EMAIL, SECURITY_KEY, USER_TYPE, GENDER)
	VALUES(NEW_USER_ID, PARAM_FULL_NAME, PARAM_EMAIL, PARAM_PASSWORD, PARAM_USER_TYPE, PARAM_GENDER);
	RETURN 0; --SUCCESS
END;
$$;


ALTER FUNCTION public.insert_user(param_full_name character varying, param_email character varying, param_password character varying, param_day integer, param_month integer, param_year integer, param_user_type character varying, param_gender character varying) OWNER TO epathshala;

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
-- Name: content_viewers; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.content_viewers (
    view_id bigint NOT NULL,
    content_id bigint,
    user_id bigint,
    rate numeric,
    completed boolean DEFAULT false,
    CONSTRAINT content_viewers_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric))),
    CONSTRAINT content_viewers_view_id_check CHECK ((view_id > 0))
);


ALTER TABLE public.content_viewers OWNER TO epathshala;

--
-- Name: content_viewers_view_id_seq; Type: SEQUENCE; Schema: public; Owner: epathshala
--

CREATE SEQUENCE public.content_viewers_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.content_viewers_view_id_seq OWNER TO epathshala;

--
-- Name: content_viewers_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epathshala
--

ALTER SEQUENCE public.content_viewers_view_id_seq OWNED BY public.content_viewers.view_id;


--
-- Name: contents; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.contents (
    content_id bigint NOT NULL,
    date_of_creation date,
    content_type character(10) NOT NULL,
    title character varying DEFAULT ''::character varying,
    description character(100) DEFAULT ''::bpchar,
    course_id bigint,
    rate numeric,
    CONSTRAINT contents_content_id_check CHECK ((content_id > 0)),
    CONSTRAINT contents_rate_check CHECK ((((0)::numeric <= rate) AND (rate <= (5)::numeric)))
);


ALTER TABLE public.contents OWNER TO epathshala;

--
-- Name: contents_content_id_seq; Type: SEQUENCE; Schema: public; Owner: epathshala
--

CREATE SEQUENCE public.contents_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contents_content_id_seq OWNER TO epathshala;

--
-- Name: contents_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epathshala
--

ALTER SEQUENCE public.contents_content_id_seq OWNED BY public.contents.content_id;


--
-- Name: course_tags; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.course_tags (
    tag_id bigint NOT NULL,
    course_id bigint NOT NULL
);


ALTER TABLE public.course_tags OWNER TO epathshala;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.courses (
    course_id bigint NOT NULL,
    title character varying NOT NULL,
    description character(100) DEFAULT ''::bpchar,
    date_of_creation date NOT NULL,
    price integer DEFAULT 0,
    creator_id bigint,
    CONSTRAINT courses_course_id_check CHECK ((course_id > 0)),
    CONSTRAINT courses_price_check CHECK ((price >= 0))
);


ALTER TABLE public.courses OWNER TO epathshala;

--
-- Name: enrolled_courses; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.enrolled_courses (
    user_id bigint NOT NULL,
    course_id bigint NOT NULL,
    date_of_join date NOT NULL
);


ALTER TABLE public.enrolled_courses OWNER TO epathshala;

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
-- Name: tags; Type: TABLE; Schema: public; Owner: epathshala
--

CREATE TABLE public.tags (
    tag_id bigint NOT NULL,
    tag_name character(10) NOT NULL,
    CONSTRAINT tags_tag_id_check CHECK ((tag_id > 0)),
    CONSTRAINT tags_tag_name_check CHECK ((length(tag_name) > 0))
);


ALTER TABLE public.tags OWNER TO epathshala;

--
-- Name: tags_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: epathshala
--

CREATE SEQUENCE public.tags_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tags_tag_id_seq OWNER TO epathshala;

--
-- Name: tags_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epathshala
--

ALTER SEQUENCE public.tags_tag_id_seq OWNED BY public.tags.tag_id;


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
    date_of_join date DEFAULT CURRENT_DATE NOT NULL
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
    user_type character(10) NOT NULL,
    credit_card_id bigint,
    bank_id bigint,
    CONSTRAINT users_email_check CHECK (((email)::text ~~ '_%@_%.___'::text)),
    CONSTRAINT users_security_key_check CHECK ((length(security_key) >= 8)),
    CONSTRAINT users_user_id_check CHECK ((user_id > 0)),
    CONSTRAINT users_user_type_check CHECK ((user_type = ANY (ARRAY['TEACHER'::bpchar, 'STUDENT'::bpchar])))
);


ALTER TABLE public.users OWNER TO epathshala;

--
-- Name: content_viewers view_id; Type: DEFAULT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.content_viewers ALTER COLUMN view_id SET DEFAULT nextval('public.content_viewers_view_id_seq'::regclass);


--
-- Name: contents content_id; Type: DEFAULT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.contents ALTER COLUMN content_id SET DEFAULT nextval('public.contents_content_id_seq'::regclass);


--
-- Name: tags tag_id; Type: DEFAULT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.tags ALTER COLUMN tag_id SET DEFAULT nextval('public.tags_tag_id_seq'::regclass);


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
2	5	6	Nice Content                                                                                        	23:47:13.830674	2022-08-09	0
\.


--
-- Data for Name: content_viewers; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.content_viewers (view_id, content_id, user_id, rate, completed) FROM stdin;
1	58	1	\N	f
2	58	2	\N	f
3	58	3	\N	f
4	58	4	\N	f
5	58	5	\N	f
6	58	6	\N	f
7	58	7	\N	f
8	58	8	\N	f
9	58	9	\N	f
10	58	10	\N	f
11	58	11	\N	f
12	58	12	\N	f
13	58	13	\N	f
14	58	14	\N	f
15	58	15	\N	f
16	58	16	\N	f
17	58	17	\N	f
18	58	18	\N	f
19	58	19	\N	f
20	58	20	\N	f
21	58	21	\N	f
22	58	22	\N	f
23	58	23	\N	f
24	58	24	\N	f
25	58	25	\N	f
26	58	26	\N	f
27	58	27	\N	f
28	58	28	\N	f
29	58	29	\N	f
30	58	30	\N	f
31	58	31	\N	f
32	58	32	\N	f
33	58	33	\N	f
34	58	34	\N	f
35	58	35	\N	f
36	58	36	\N	f
37	58	37	\N	f
38	58	38	\N	f
39	58	39	\N	f
40	58	40	\N	f
41	74	1	\N	f
42	74	2	\N	f
43	74	3	\N	f
44	74	4	\N	f
45	74	5	\N	f
46	74	6	\N	f
47	74	7	\N	f
48	74	8	\N	f
49	74	9	\N	f
50	74	10	\N	f
51	74	11	\N	f
52	74	12	\N	f
53	74	13	\N	f
54	74	14	\N	f
55	74	15	\N	f
56	74	16	\N	f
57	74	17	\N	f
58	74	18	\N	f
59	74	19	\N	f
60	74	20	\N	f
61	74	21	\N	f
62	74	22	\N	f
63	74	23	\N	f
64	74	24	\N	f
65	74	25	\N	f
66	74	26	\N	f
67	74	27	\N	f
68	74	28	\N	f
69	74	29	\N	f
70	74	30	\N	f
71	74	31	\N	f
72	74	32	\N	f
73	74	33	\N	f
74	74	34	\N	f
75	75	1	\N	f
76	75	2	\N	f
77	76	1	\N	f
78	76	2	\N	f
79	76	3	\N	f
80	76	4	\N	f
81	76	5	\N	f
82	76	6	\N	f
83	76	7	\N	f
84	76	8	\N	f
85	76	9	\N	f
86	76	10	\N	f
87	76	11	\N	f
88	76	12	\N	f
89	76	13	\N	f
90	76	14	\N	f
91	76	15	\N	f
92	76	16	\N	f
93	76	17	\N	f
94	76	18	\N	f
95	76	19	\N	f
96	76	20	\N	f
97	76	21	\N	f
98	76	22	\N	f
99	76	23	\N	f
100	76	24	\N	f
101	76	25	\N	f
102	76	26	\N	f
103	76	27	\N	f
104	76	28	\N	f
105	76	29	\N	f
106	76	30	\N	f
107	76	31	\N	f
108	76	32	\N	f
109	76	33	\N	f
110	76	34	\N	f
111	76	35	\N	f
112	76	36	\N	f
113	76	37	\N	f
114	76	38	\N	f
115	76	39	\N	f
116	76	40	\N	f
117	1	1	\N	f
118	1	2	\N	f
119	1	3	\N	f
120	1	4	\N	f
121	1	5	\N	f
122	1	6	\N	f
123	1	7	\N	f
124	2	1	\N	f
125	2	2	\N	f
126	2	3	\N	f
127	2	4	\N	f
128	2	5	\N	f
129	2	6	\N	f
130	2	7	\N	f
131	2	8	\N	f
132	2	9	\N	f
133	2	10	\N	f
134	2	11	\N	f
135	2	12	\N	f
136	2	13	\N	f
137	2	14	\N	f
138	2	15	\N	f
139	2	16	\N	f
140	2	17	\N	f
141	2	18	\N	f
142	2	19	\N	f
143	2	20	\N	f
144	2	21	\N	f
145	2	22	\N	f
146	2	23	\N	f
147	2	24	\N	f
148	2	25	\N	f
149	2	26	\N	f
150	2	27	\N	f
151	2	28	\N	f
152	2	29	\N	f
153	2	30	\N	f
154	2	31	\N	f
155	2	32	\N	f
156	2	33	\N	f
157	2	34	\N	f
158	2	35	\N	f
159	2	36	\N	f
160	2	37	\N	f
161	2	38	\N	f
162	2	39	\N	f
163	2	40	\N	f
164	2	41	\N	f
165	2	42	\N	f
166	2	43	\N	f
167	2	44	\N	f
168	2	45	\N	f
169	2	46	\N	f
170	2	47	\N	f
171	3	1	\N	f
172	3	2	\N	f
173	3	3	\N	f
174	3	4	\N	f
175	3	5	\N	f
176	3	6	\N	f
177	3	7	\N	f
178	3	8	\N	f
179	3	9	\N	f
180	3	10	\N	f
181	3	11	\N	f
182	3	12	\N	f
183	3	13	\N	f
184	3	14	\N	f
185	3	15	\N	f
186	3	16	\N	f
187	3	17	\N	f
188	3	18	\N	f
189	3	19	\N	f
190	4	1	\N	f
191	4	2	\N	f
192	4	3	\N	f
193	4	4	\N	f
194	4	5	\N	f
195	4	6	\N	f
196	4	7	\N	f
197	4	8	\N	f
198	4	9	\N	f
199	4	10	\N	f
200	4	11	\N	f
201	4	12	\N	f
202	4	13	\N	f
203	4	14	\N	f
204	4	15	\N	f
205	4	16	\N	f
206	4	17	\N	f
207	5	1	\N	f
208	5	2	\N	f
209	5	3	\N	f
210	5	4	\N	f
211	5	5	\N	f
212	5	6	\N	f
213	5	7	\N	f
214	5	8	\N	f
215	5	9	\N	f
216	5	10	\N	f
217	5	11	\N	f
218	5	12	\N	f
219	5	13	\N	f
220	5	14	\N	f
221	5	15	\N	f
222	6	1	\N	f
223	6	2	\N	f
224	6	3	\N	f
225	6	4	\N	f
226	6	5	\N	f
227	6	6	\N	f
228	6	7	\N	f
229	6	8	\N	f
230	6	9	\N	f
231	6	10	\N	f
232	6	11	\N	f
233	6	12	\N	f
234	7	1	\N	f
235	7	2	\N	f
236	7	3	\N	f
237	7	4	\N	f
238	7	5	\N	f
239	7	6	\N	f
240	7	7	\N	f
241	7	8	\N	f
242	7	9	\N	f
243	7	10	\N	f
244	7	11	\N	f
245	7	12	\N	f
246	7	13	\N	f
247	7	14	\N	f
248	7	15	\N	f
249	7	16	\N	f
250	7	17	\N	f
251	7	18	\N	f
252	7	19	\N	f
253	7	20	\N	f
254	7	21	\N	f
255	7	22	\N	f
256	8	1	\N	f
257	8	2	\N	f
258	8	3	\N	f
259	8	4	\N	f
260	8	5	\N	f
261	8	6	\N	f
262	8	7	\N	f
263	8	8	\N	f
264	8	9	\N	f
265	8	10	\N	f
266	8	11	\N	f
267	8	12	\N	f
268	8	13	\N	f
269	8	14	\N	f
270	8	15	\N	f
271	8	16	\N	f
272	8	17	\N	f
273	8	18	\N	f
274	8	19	\N	f
275	8	20	\N	f
276	8	21	\N	f
277	8	22	\N	f
278	8	23	\N	f
279	8	24	\N	f
280	8	25	\N	f
281	8	26	\N	f
282	8	27	\N	f
283	8	28	\N	f
284	8	29	\N	f
285	8	30	\N	f
286	8	31	\N	f
287	8	32	\N	f
288	9	1	\N	f
289	9	2	\N	f
290	9	3	\N	f
291	9	4	\N	f
292	9	5	\N	f
293	9	6	\N	f
294	9	7	\N	f
295	9	8	\N	f
296	9	9	\N	f
297	9	10	\N	f
298	9	11	\N	f
299	9	12	\N	f
300	9	13	\N	f
301	9	14	\N	f
302	9	15	\N	f
303	9	16	\N	f
304	9	17	\N	f
305	9	18	\N	f
306	9	19	\N	f
307	9	20	\N	f
308	9	21	\N	f
309	9	22	\N	f
310	9	23	\N	f
311	9	24	\N	f
312	9	25	\N	f
313	9	26	\N	f
314	9	27	\N	f
315	9	28	\N	f
316	9	29	\N	f
317	9	30	\N	f
318	9	31	\N	f
319	9	32	\N	f
320	9	33	\N	f
321	9	34	\N	f
322	9	35	\N	f
323	9	36	\N	f
324	9	37	\N	f
325	9	38	\N	f
326	9	39	\N	f
327	9	40	\N	f
328	9	41	\N	f
329	9	42	\N	f
330	9	43	\N	f
331	9	44	\N	f
332	9	45	\N	f
333	9	46	\N	f
334	9	47	\N	f
335	10	1	\N	f
336	10	2	\N	f
337	10	3	\N	f
338	10	4	\N	f
339	10	5	\N	f
340	10	6	\N	f
341	10	7	\N	f
342	10	8	\N	f
343	10	9	\N	f
344	10	10	\N	f
345	10	11	\N	f
346	10	12	\N	f
347	10	13	\N	f
348	10	14	\N	f
349	10	15	\N	f
350	10	16	\N	f
351	10	17	\N	f
352	10	18	\N	f
353	10	19	\N	f
354	10	20	\N	f
355	10	21	\N	f
356	10	22	\N	f
357	10	23	\N	f
358	10	24	\N	f
359	10	25	\N	f
360	10	26	\N	f
361	10	27	\N	f
362	10	28	\N	f
363	10	29	\N	f
364	10	30	\N	f
365	10	31	\N	f
366	10	32	\N	f
367	10	33	\N	f
368	11	1	\N	f
369	11	2	\N	f
370	11	3	\N	f
371	11	4	\N	f
372	11	5	\N	f
373	11	6	\N	f
374	11	7	\N	f
375	11	8	\N	f
376	11	9	\N	f
377	11	10	\N	f
378	11	11	\N	f
379	11	12	\N	f
380	11	13	\N	f
381	11	14	\N	f
382	11	15	\N	f
383	12	1	\N	f
384	12	2	\N	f
385	12	3	\N	f
386	12	4	\N	f
387	12	5	\N	f
388	12	6	\N	f
389	12	7	\N	f
390	12	8	\N	f
391	12	9	\N	f
392	12	10	\N	f
393	12	11	\N	f
394	12	12	\N	f
395	12	13	\N	f
396	12	14	\N	f
397	12	15	\N	f
398	12	16	\N	f
399	12	17	\N	f
400	12	18	\N	f
401	12	19	\N	f
402	12	20	\N	f
403	12	21	\N	f
404	12	22	\N	f
405	12	23	\N	f
406	12	24	\N	f
407	12	25	\N	f
408	12	26	\N	f
409	12	27	\N	f
410	12	28	\N	f
411	12	29	\N	f
412	12	30	\N	f
413	12	31	\N	f
414	12	32	\N	f
415	12	33	\N	f
416	12	34	\N	f
417	12	35	\N	f
418	12	36	\N	f
419	12	37	\N	f
420	12	38	\N	f
421	12	39	\N	f
422	12	40	\N	f
423	12	41	\N	f
424	12	42	\N	f
425	12	43	\N	f
426	12	44	\N	f
427	12	45	\N	f
428	12	46	\N	f
429	13	1	\N	f
430	13	2	\N	f
431	13	3	\N	f
432	13	4	\N	f
433	13	5	\N	f
434	13	6	\N	f
435	13	7	\N	f
436	13	8	\N	f
437	13	9	\N	f
438	13	10	\N	f
439	13	11	\N	f
440	13	12	\N	f
441	13	13	\N	f
442	13	14	\N	f
443	13	15	\N	f
444	13	16	\N	f
445	13	17	\N	f
446	13	18	\N	f
447	13	19	\N	f
448	13	20	\N	f
449	13	21	\N	f
450	13	22	\N	f
451	13	23	\N	f
452	13	24	\N	f
453	13	25	\N	f
454	13	26	\N	f
455	13	27	\N	f
456	14	1	\N	f
457	14	2	\N	f
458	14	3	\N	f
459	14	4	\N	f
460	14	5	\N	f
461	14	6	\N	f
462	14	7	\N	f
463	14	8	\N	f
464	14	9	\N	f
465	14	10	\N	f
466	14	11	\N	f
467	14	12	\N	f
468	14	13	\N	f
469	14	14	\N	f
470	14	15	\N	f
471	14	16	\N	f
472	14	17	\N	f
473	14	18	\N	f
474	14	19	\N	f
475	14	20	\N	f
476	14	21	\N	f
477	14	22	\N	f
478	14	23	\N	f
479	14	24	\N	f
480	14	25	\N	f
481	14	26	\N	f
482	14	27	\N	f
483	14	28	\N	f
484	14	29	\N	f
485	14	30	\N	f
486	14	31	\N	f
487	14	32	\N	f
488	14	33	\N	f
489	14	34	\N	f
490	14	35	\N	f
491	14	36	\N	f
492	14	37	\N	f
493	14	38	\N	f
494	14	39	\N	f
495	14	40	\N	f
496	14	41	\N	f
497	14	42	\N	f
498	14	43	\N	f
499	14	44	\N	f
500	15	1	\N	f
501	15	2	\N	f
502	15	3	\N	f
503	15	4	\N	f
504	15	5	\N	f
505	15	6	\N	f
506	15	7	\N	f
507	15	8	\N	f
508	15	9	\N	f
509	15	10	\N	f
510	15	11	\N	f
511	15	12	\N	f
512	15	13	\N	f
513	15	14	\N	f
514	15	15	\N	f
515	15	16	\N	f
516	15	17	\N	f
517	15	18	\N	f
518	15	19	\N	f
519	15	20	\N	f
520	15	21	\N	f
521	15	22	\N	f
522	15	23	\N	f
523	15	24	\N	f
524	15	25	\N	f
525	15	26	\N	f
526	15	27	\N	f
527	16	1	\N	f
528	16	2	\N	f
529	16	3	\N	f
530	16	4	\N	f
531	16	5	\N	f
532	16	6	\N	f
533	16	7	\N	f
534	16	8	\N	f
535	16	9	\N	f
536	16	10	\N	f
537	16	11	\N	f
538	16	12	\N	f
539	16	13	\N	f
540	16	14	\N	f
541	16	15	\N	f
542	16	16	\N	f
543	17	1	\N	f
544	17	2	\N	f
545	17	3	\N	f
546	17	4	\N	f
547	17	5	\N	f
548	17	6	\N	f
549	17	7	\N	f
550	17	8	\N	f
551	17	9	\N	f
552	17	10	\N	f
553	17	11	\N	f
554	17	12	\N	f
555	17	13	\N	f
556	17	14	\N	f
557	17	15	\N	f
558	17	16	\N	f
559	17	17	\N	f
560	17	18	\N	f
561	17	19	\N	f
562	17	20	\N	f
563	17	21	\N	f
564	17	22	\N	f
565	17	23	\N	f
566	17	24	\N	f
567	18	1	\N	f
568	18	2	\N	f
569	18	3	\N	f
570	18	4	\N	f
571	18	5	\N	f
572	18	6	\N	f
573	18	7	\N	f
574	18	8	\N	f
575	18	9	\N	f
576	18	10	\N	f
577	18	11	\N	f
578	18	12	\N	f
579	18	13	\N	f
580	18	14	\N	f
581	18	15	\N	f
582	18	16	\N	f
583	18	17	\N	f
584	18	18	\N	f
585	18	19	\N	f
586	18	20	\N	f
587	18	21	\N	f
588	18	22	\N	f
589	18	23	\N	f
590	18	24	\N	f
591	18	25	\N	f
592	18	26	\N	f
593	18	27	\N	f
594	18	28	\N	f
595	18	29	\N	f
596	18	30	\N	f
597	18	31	\N	f
598	18	32	\N	f
599	18	33	\N	f
600	18	34	\N	f
601	18	35	\N	f
602	18	36	\N	f
603	18	37	\N	f
604	18	38	\N	f
605	18	39	\N	f
606	18	40	\N	f
607	18	41	\N	f
608	18	42	\N	f
609	18	43	\N	f
610	18	44	\N	f
611	18	45	\N	f
612	18	46	\N	f
613	18	47	\N	f
614	18	48	\N	f
615	18	49	\N	f
616	18	50	\N	f
617	19	1	\N	f
618	19	2	\N	f
619	19	3	\N	f
620	19	4	\N	f
621	19	5	\N	f
622	19	6	\N	f
623	19	7	\N	f
624	19	8	\N	f
625	19	9	\N	f
626	19	10	\N	f
627	19	11	\N	f
628	19	12	\N	f
629	19	13	\N	f
630	19	14	\N	f
631	19	15	\N	f
632	19	16	\N	f
633	19	17	\N	f
634	19	18	\N	f
635	19	19	\N	f
636	19	20	\N	f
637	19	21	\N	f
638	19	22	\N	f
639	20	1	\N	f
640	20	2	\N	f
641	20	3	\N	f
642	20	4	\N	f
643	20	5	\N	f
644	20	6	\N	f
645	20	7	\N	f
646	20	8	\N	f
647	20	9	\N	f
648	20	10	\N	f
649	20	11	\N	f
650	20	12	\N	f
651	20	13	\N	f
652	20	14	\N	f
653	20	15	\N	f
654	20	16	\N	f
655	20	17	\N	f
656	20	18	\N	f
657	20	19	\N	f
658	20	20	\N	f
659	20	21	\N	f
660	20	22	\N	f
661	20	23	\N	f
662	20	24	\N	f
663	20	25	\N	f
664	20	26	\N	f
665	20	27	\N	f
666	20	28	\N	f
667	20	29	\N	f
668	20	30	\N	f
669	20	31	\N	f
670	20	32	\N	f
671	20	33	\N	f
672	21	1	\N	f
673	21	2	\N	f
674	21	3	\N	f
675	21	4	\N	f
676	21	5	\N	f
677	21	6	\N	f
678	21	7	\N	f
679	21	8	\N	f
680	21	9	\N	f
681	21	10	\N	f
682	21	11	\N	f
683	21	12	\N	f
684	21	13	\N	f
685	21	14	\N	f
686	21	15	\N	f
687	21	16	\N	f
688	21	17	\N	f
689	21	18	\N	f
690	21	19	\N	f
691	21	20	\N	f
692	21	21	\N	f
693	21	22	\N	f
694	21	23	\N	f
695	21	24	\N	f
696	21	25	\N	f
697	22	1	\N	f
698	22	2	\N	f
699	22	3	\N	f
700	22	4	\N	f
701	22	5	\N	f
702	22	6	\N	f
703	22	7	\N	f
704	22	8	\N	f
705	22	9	\N	f
706	22	10	\N	f
707	22	11	\N	f
708	22	12	\N	f
709	22	13	\N	f
710	22	14	\N	f
711	22	15	\N	f
712	22	16	\N	f
713	22	17	\N	f
714	22	18	\N	f
715	23	1	\N	f
716	23	2	\N	f
717	23	3	\N	f
718	23	4	\N	f
719	23	5	\N	f
720	23	6	\N	f
721	23	7	\N	f
722	23	8	\N	f
723	23	9	\N	f
724	23	10	\N	f
725	23	11	\N	f
726	23	12	\N	f
727	23	13	\N	f
728	24	1	\N	f
729	24	2	\N	f
730	24	3	\N	f
731	24	4	\N	f
732	24	5	\N	f
733	24	6	\N	f
734	24	7	\N	f
735	24	8	\N	f
736	24	9	\N	f
737	24	10	\N	f
738	24	11	\N	f
739	24	12	\N	f
740	24	13	\N	f
741	24	14	\N	f
742	24	15	\N	f
743	24	16	\N	f
744	24	17	\N	f
745	24	18	\N	f
746	24	19	\N	f
747	24	20	\N	f
748	24	21	\N	f
749	24	22	\N	f
750	24	23	\N	f
751	24	24	\N	f
752	24	25	\N	f
753	25	1	\N	f
754	25	2	\N	f
755	25	3	\N	f
756	25	4	\N	f
757	25	5	\N	f
758	25	6	\N	f
759	25	7	\N	f
760	25	8	\N	f
761	25	9	\N	f
762	25	10	\N	f
763	25	11	\N	f
764	25	12	\N	f
765	25	13	\N	f
766	25	14	\N	f
767	25	15	\N	f
768	25	16	\N	f
769	25	17	\N	f
770	25	18	\N	f
771	25	19	\N	f
772	25	20	\N	f
773	25	21	\N	f
774	25	22	\N	f
775	25	23	\N	f
776	25	24	\N	f
777	25	25	\N	f
778	25	26	\N	f
779	25	27	\N	f
780	25	28	\N	f
781	25	29	\N	f
782	25	30	\N	f
783	25	31	\N	f
784	25	32	\N	f
785	25	33	\N	f
786	25	34	\N	f
787	25	35	\N	f
788	25	36	\N	f
789	25	37	\N	f
790	25	38	\N	f
791	25	39	\N	f
792	25	40	\N	f
793	25	41	\N	f
794	25	42	\N	f
795	25	43	\N	f
796	25	44	\N	f
797	25	45	\N	f
798	25	46	\N	f
799	25	47	\N	f
800	25	48	\N	f
801	26	1	\N	f
802	26	2	\N	f
803	26	3	\N	f
804	26	4	\N	f
805	26	5	\N	f
806	26	6	\N	f
807	26	7	\N	f
808	26	8	\N	f
809	26	9	\N	f
810	26	10	\N	f
811	26	11	\N	f
812	26	12	\N	f
813	26	13	\N	f
814	26	14	\N	f
815	27	1	\N	f
816	27	2	\N	f
817	27	3	\N	f
818	27	4	\N	f
819	27	5	\N	f
820	27	6	\N	f
821	27	7	\N	f
822	27	8	\N	f
823	27	9	\N	f
824	27	10	\N	f
825	27	11	\N	f
826	27	12	\N	f
827	27	13	\N	f
828	27	14	\N	f
829	27	15	\N	f
830	27	16	\N	f
831	27	17	\N	f
832	27	18	\N	f
833	27	19	\N	f
834	27	20	\N	f
835	27	21	\N	f
836	27	22	\N	f
837	27	23	\N	f
838	27	24	\N	f
839	27	25	\N	f
840	27	26	\N	f
841	27	27	\N	f
842	27	28	\N	f
843	27	29	\N	f
844	27	30	\N	f
845	27	31	\N	f
846	27	32	\N	f
847	27	33	\N	f
848	27	34	\N	f
849	27	35	\N	f
850	27	36	\N	f
851	27	37	\N	f
852	27	38	\N	f
853	27	39	\N	f
854	27	40	\N	f
855	27	41	\N	f
856	27	42	\N	f
857	27	43	\N	f
858	27	44	\N	f
859	27	45	\N	f
860	27	46	\N	f
861	27	47	\N	f
862	27	48	\N	f
863	28	1	\N	f
864	28	2	\N	f
865	28	3	\N	f
866	28	4	\N	f
867	28	5	\N	f
868	28	6	\N	f
869	28	7	\N	f
870	28	8	\N	f
871	28	9	\N	f
872	28	10	\N	f
873	28	11	\N	f
874	28	12	\N	f
875	28	13	\N	f
876	28	14	\N	f
877	28	15	\N	f
878	28	16	\N	f
879	28	17	\N	f
880	28	18	\N	f
881	28	19	\N	f
882	29	1	\N	f
883	29	2	\N	f
884	29	3	\N	f
885	29	4	\N	f
886	29	5	\N	f
887	29	6	\N	f
888	29	7	\N	f
889	29	8	\N	f
890	29	9	\N	f
891	29	10	\N	f
892	29	11	\N	f
893	29	12	\N	f
894	29	13	\N	f
895	30	1	\N	f
896	30	2	\N	f
897	30	3	\N	f
898	30	4	\N	f
899	30	5	\N	f
900	30	6	\N	f
901	30	7	\N	f
902	30	8	\N	f
903	30	9	\N	f
904	30	10	\N	f
905	30	11	\N	f
906	30	12	\N	f
907	30	13	\N	f
908	30	14	\N	f
909	30	15	\N	f
910	30	16	\N	f
911	30	17	\N	f
912	30	18	\N	f
913	30	19	\N	f
914	30	20	\N	f
915	30	21	\N	f
916	30	22	\N	f
917	30	23	\N	f
918	30	24	\N	f
919	30	25	\N	f
920	30	26	\N	f
921	30	27	\N	f
922	30	28	\N	f
923	31	1	\N	f
924	31	2	\N	f
925	31	3	\N	f
926	31	4	\N	f
927	31	5	\N	f
928	31	6	\N	f
929	31	7	\N	f
930	32	1	\N	f
931	32	2	\N	f
932	32	3	\N	f
933	32	4	\N	f
934	32	5	\N	f
935	32	6	\N	f
936	32	7	\N	f
937	32	8	\N	f
938	32	9	\N	f
939	32	10	\N	f
940	32	11	\N	f
941	32	12	\N	f
942	32	13	\N	f
943	32	14	\N	f
944	32	15	\N	f
945	32	16	\N	f
946	32	17	\N	f
947	32	18	\N	f
948	32	19	\N	f
949	32	20	\N	f
950	32	21	\N	f
951	32	22	\N	f
952	32	23	\N	f
953	32	24	\N	f
954	32	25	\N	f
955	32	26	\N	f
956	33	1	\N	f
957	33	2	\N	f
958	33	3	\N	f
959	33	4	\N	f
960	33	5	\N	f
961	33	6	\N	f
962	33	7	\N	f
963	33	8	\N	f
964	33	9	\N	f
965	33	10	\N	f
966	33	11	\N	f
967	33	12	\N	f
968	33	13	\N	f
969	34	1	\N	f
970	34	2	\N	f
971	34	3	\N	f
972	34	4	\N	f
973	34	5	\N	f
974	34	6	\N	f
975	34	7	\N	f
976	34	8	\N	f
977	34	9	\N	f
978	34	10	\N	f
979	34	11	\N	f
980	34	12	\N	f
981	34	13	\N	f
982	34	14	\N	f
983	34	15	\N	f
984	34	16	\N	f
985	34	17	\N	f
986	34	18	\N	f
987	34	19	\N	f
988	34	20	\N	f
989	34	21	\N	f
990	34	22	\N	f
991	34	23	\N	f
992	34	24	\N	f
993	34	25	\N	f
994	34	26	\N	f
995	34	27	\N	f
996	34	28	\N	f
997	34	29	\N	f
998	34	30	\N	f
999	34	31	\N	f
1000	34	32	\N	f
1001	34	33	\N	f
1002	34	34	\N	f
1003	34	35	\N	f
1004	34	36	\N	f
1005	34	37	\N	f
1006	34	38	\N	f
1007	34	39	\N	f
1008	35	1	\N	f
1009	35	2	\N	f
1010	36	1	\N	f
1011	36	2	\N	f
1012	36	3	\N	f
1013	36	4	\N	f
1014	37	1	\N	f
1015	37	2	\N	f
1016	37	3	\N	f
1017	37	4	\N	f
1018	38	1	\N	f
1019	38	2	\N	f
1020	39	1	\N	f
1021	39	2	\N	f
1022	39	3	\N	f
1023	39	4	\N	f
1024	39	5	\N	f
1025	39	6	\N	f
1026	39	7	\N	f
1027	39	8	\N	f
1028	39	9	\N	f
1029	39	10	\N	f
1030	39	11	\N	f
1031	39	12	\N	f
1032	39	13	\N	f
1033	39	14	\N	f
1034	39	15	\N	f
1035	39	16	\N	f
1036	39	17	\N	f
1037	39	18	\N	f
1038	39	19	\N	f
1039	39	20	\N	f
1040	39	21	\N	f
1041	39	22	\N	f
1042	39	23	\N	f
1043	39	24	\N	f
1044	39	25	\N	f
1045	39	26	\N	f
1046	39	27	\N	f
1047	39	28	\N	f
1048	39	29	\N	f
1049	39	30	\N	f
1050	39	31	\N	f
1051	39	32	\N	f
1052	39	33	\N	f
1053	39	34	\N	f
1054	39	35	\N	f
1055	39	36	\N	f
1056	39	37	\N	f
1057	39	38	\N	f
1058	39	39	\N	f
1059	39	40	\N	f
1060	39	41	\N	f
1061	39	42	\N	f
1062	39	43	\N	f
1063	39	44	\N	f
1064	39	45	\N	f
1065	39	46	\N	f
1066	39	47	\N	f
1067	39	48	\N	f
1068	39	49	\N	f
1069	39	50	\N	f
1070	40	1	\N	f
1071	40	2	\N	f
1072	40	3	\N	f
1073	40	4	\N	f
1074	40	5	\N	f
1075	40	6	\N	f
1076	40	7	\N	f
1077	40	8	\N	f
1078	40	9	\N	f
1079	40	10	\N	f
1080	40	11	\N	f
1081	40	12	\N	f
1082	40	13	\N	f
1083	40	14	\N	f
1084	40	15	\N	f
1085	40	16	\N	f
1086	40	17	\N	f
1087	40	18	\N	f
1088	40	19	\N	f
1089	40	20	\N	f
1090	40	21	\N	f
1091	40	22	\N	f
1092	40	23	\N	f
1093	40	24	\N	f
1094	40	25	\N	f
1095	40	26	\N	f
1096	40	27	\N	f
1097	40	28	\N	f
1098	40	29	\N	f
1099	41	1	\N	f
1100	41	2	\N	f
1101	41	3	\N	f
1102	41	4	\N	f
1103	41	5	\N	f
1104	41	6	\N	f
1105	41	7	\N	f
1106	41	8	\N	f
1107	41	9	\N	f
1108	41	10	\N	f
1109	41	11	\N	f
1110	41	12	\N	f
1111	41	13	\N	f
1112	41	14	\N	f
1113	41	15	\N	f
1114	41	16	\N	f
1115	41	17	\N	f
1116	41	18	\N	f
1117	41	19	\N	f
1118	41	20	\N	f
1119	41	21	\N	f
1120	41	22	\N	f
1121	41	23	\N	f
1122	41	24	\N	f
1123	41	25	\N	f
1124	41	26	\N	f
1125	41	27	\N	f
1126	41	28	\N	f
1127	41	29	\N	f
1128	41	30	\N	f
1129	41	31	\N	f
1130	41	32	\N	f
1131	41	33	\N	f
1132	41	34	\N	f
1133	41	35	\N	f
1134	41	36	\N	f
1135	41	37	\N	f
1136	41	38	\N	f
1137	41	39	\N	f
1138	41	40	\N	f
1139	41	41	\N	f
1140	41	42	\N	f
1141	41	43	\N	f
1142	41	44	\N	f
1143	41	45	\N	f
1144	41	46	\N	f
1145	41	47	\N	f
1146	41	48	\N	f
1147	41	49	\N	f
1148	42	1	\N	f
1149	42	2	\N	f
1150	42	3	\N	f
1151	42	4	\N	f
1152	42	5	\N	f
1153	42	6	\N	f
1154	42	7	\N	f
1155	42	8	\N	f
1156	42	9	\N	f
1157	42	10	\N	f
1158	42	11	\N	f
1159	42	12	\N	f
1160	42	13	\N	f
1161	42	14	\N	f
1162	42	15	\N	f
1163	42	16	\N	f
1164	42	17	\N	f
1165	42	18	\N	f
1166	43	1	\N	f
1167	43	2	\N	f
1168	43	3	\N	f
1169	43	4	\N	f
1170	43	5	\N	f
1171	43	6	\N	f
1172	43	7	\N	f
1173	92	1	\N	f
1174	92	2	\N	f
1175	92	3	\N	f
1176	92	4	\N	f
1177	92	5	\N	f
1178	92	6	\N	f
1179	92	7	\N	f
1180	92	8	\N	f
1181	92	9	\N	f
1182	92	10	\N	f
1183	92	11	\N	f
1184	92	12	\N	f
1185	92	13	\N	f
1186	92	14	\N	f
1187	92	15	\N	f
1188	92	16	\N	f
1189	92	17	\N	f
1190	92	18	\N	f
1191	92	19	\N	f
1192	92	20	\N	f
1193	92	21	\N	f
1194	92	22	\N	f
1195	92	23	\N	f
1196	92	24	\N	f
1197	92	25	\N	f
1198	92	26	\N	f
1199	92	27	\N	f
1200	92	28	\N	f
1201	92	29	\N	f
1202	92	30	\N	f
1203	92	31	\N	f
1204	92	32	\N	f
1205	92	33	\N	f
1206	92	34	\N	f
1207	92	35	\N	f
1208	92	36	\N	f
1209	92	37	\N	f
1210	92	38	\N	f
1211	92	39	\N	f
1212	93	1	\N	f
1213	93	2	\N	f
1214	93	3	\N	f
1215	93	4	\N	f
1216	93	5	\N	f
1217	93	6	\N	f
1218	93	7	\N	f
1219	93	8	\N	f
1220	93	9	\N	f
1221	93	10	\N	f
1222	93	11	\N	f
1223	93	12	\N	f
1224	93	13	\N	f
1225	93	14	\N	f
1226	93	15	\N	f
1227	93	16	\N	f
1228	93	17	\N	f
1229	93	18	\N	f
1230	93	19	\N	f
1231	93	20	\N	f
1232	93	21	\N	f
1233	93	22	\N	f
1234	93	23	\N	f
1235	93	24	\N	f
1236	93	25	\N	f
1237	93	26	\N	f
1238	93	27	\N	f
1239	93	28	\N	f
1240	93	29	\N	f
1241	93	30	\N	f
1242	93	31	\N	f
1243	93	32	\N	f
1244	94	1	\N	f
1245	94	2	\N	f
1246	94	3	\N	f
1247	94	4	\N	f
1248	94	5	\N	f
1249	94	6	\N	f
1250	94	7	\N	f
1251	94	8	\N	f
1252	94	9	\N	f
1253	94	10	\N	f
1254	94	11	\N	f
1255	94	12	\N	f
1256	94	13	\N	f
1257	94	14	\N	f
1258	94	15	\N	f
1259	94	16	\N	f
1260	94	17	\N	f
1261	94	18	\N	f
1262	94	19	\N	f
1263	94	20	\N	f
1264	94	21	\N	f
1265	94	22	\N	f
1266	94	23	\N	f
1267	94	24	\N	f
1268	94	25	\N	f
1269	94	26	\N	f
1270	94	27	\N	f
1271	94	28	\N	f
1272	94	29	\N	f
1273	94	30	\N	f
1274	94	31	\N	f
1275	94	32	\N	f
1276	94	33	\N	f
1277	94	34	\N	f
1278	95	1	\N	f
1279	95	2	\N	f
1280	95	3	\N	f
1281	95	4	\N	f
1282	95	5	\N	f
1283	95	6	\N	f
1284	95	7	\N	f
1285	95	8	\N	f
1286	95	9	\N	f
1287	95	10	\N	f
1288	95	11	\N	f
1289	95	12	\N	f
1290	95	13	\N	f
1291	95	14	\N	f
1292	95	15	\N	f
1293	95	16	\N	f
1294	95	17	\N	f
1295	95	18	\N	f
1296	95	19	\N	f
1297	95	20	\N	f
1298	95	21	\N	f
1299	95	22	\N	f
1300	95	23	\N	f
1301	95	24	\N	f
1302	95	25	\N	f
1303	95	26	\N	f
1304	95	27	\N	f
1305	95	28	\N	f
1306	95	29	\N	f
1307	95	30	\N	f
1308	96	1	\N	f
1309	96	2	\N	f
1310	96	3	\N	f
1311	96	4	\N	f
1312	96	5	\N	f
1313	96	6	\N	f
1314	96	7	\N	f
1315	96	8	\N	f
1316	96	9	\N	f
1317	96	10	\N	f
1318	96	11	\N	f
1319	96	12	\N	f
1320	96	13	\N	f
1321	96	14	\N	f
1322	96	15	\N	f
1323	97	1	\N	f
1324	97	2	\N	f
1325	97	3	\N	f
1326	97	4	\N	f
1327	97	5	\N	f
1328	97	6	\N	f
1329	97	7	\N	f
1330	97	8	\N	f
1331	97	9	\N	f
1332	97	10	\N	f
1333	97	11	\N	f
1334	97	12	\N	f
1335	97	13	\N	f
1336	97	14	\N	f
1337	97	15	\N	f
1338	97	16	\N	f
1339	97	17	\N	f
1340	97	18	\N	f
1341	97	19	\N	f
1342	97	20	\N	f
1343	97	21	\N	f
1344	97	22	\N	f
1345	97	23	\N	f
1346	97	24	\N	f
1347	97	25	\N	f
1348	97	26	\N	f
1349	97	27	\N	f
1350	97	28	\N	f
1351	97	29	\N	f
1352	97	30	\N	f
1353	97	31	\N	f
1354	97	32	\N	f
1355	97	33	\N	f
1356	97	34	\N	f
1357	97	35	\N	f
1358	97	36	\N	f
1359	97	37	\N	f
1360	97	38	\N	f
1361	97	39	\N	f
1362	97	40	\N	f
1363	97	41	\N	f
1364	97	42	\N	f
1365	97	43	\N	f
1366	97	44	\N	f
1367	97	45	\N	f
1368	97	46	\N	f
1369	97	47	\N	f
1370	97	48	\N	f
1371	97	49	\N	f
1372	102	1	\N	f
1373	102	2	\N	f
1374	102	3	\N	f
1375	102	4	\N	f
1376	102	5	\N	f
1377	102	6	\N	f
1378	102	7	\N	f
1379	102	8	\N	f
1380	102	9	\N	f
1381	102	10	\N	f
1382	102	11	\N	f
1383	102	12	\N	f
1384	102	13	\N	f
1385	102	14	\N	f
1386	102	15	\N	f
1387	102	16	\N	f
1388	89	1	\N	f
1389	89	2	\N	f
1390	89	3	\N	f
1391	89	4	\N	f
1392	89	5	\N	f
1393	89	6	\N	f
1394	89	7	\N	f
1395	89	8	\N	f
1396	89	9	\N	f
1397	89	10	\N	f
1398	89	11	\N	f
1399	89	12	\N	f
1400	89	13	\N	f
1401	89	14	\N	f
1402	89	15	\N	f
1403	89	16	\N	f
1404	89	17	\N	f
1405	89	18	\N	f
1406	89	19	\N	f
1407	89	20	\N	f
1408	89	21	\N	f
1409	89	22	\N	f
1410	89	23	\N	f
1411	90	1	\N	f
1412	90	2	\N	f
1413	90	3	\N	f
1414	90	4	\N	f
1415	90	5	\N	f
1416	90	6	\N	f
1417	90	7	\N	f
1418	90	8	\N	f
1419	90	9	\N	f
1420	90	10	\N	f
1421	90	11	\N	f
1422	90	12	\N	f
1423	90	13	\N	f
1424	90	14	\N	f
1425	90	15	\N	f
1426	90	16	\N	f
1427	90	17	\N	f
1428	90	18	\N	f
1429	90	19	\N	f
1430	90	20	\N	f
1431	90	21	\N	f
1432	90	22	\N	f
1433	90	23	\N	f
1434	90	24	\N	f
1435	90	25	\N	f
1436	90	26	\N	f
1437	90	27	\N	f
1438	90	28	\N	f
1439	91	1	\N	f
1440	59	1	\N	f
1441	59	2	\N	f
1442	59	3	\N	f
1443	59	4	\N	f
1444	59	5	\N	f
1445	59	6	\N	f
1446	59	7	\N	f
1447	59	8	\N	f
1448	59	9	\N	f
1449	59	10	\N	f
1450	59	11	\N	f
1451	59	12	\N	f
1452	59	13	\N	f
1453	59	14	\N	f
1454	59	15	\N	f
1455	59	16	\N	f
1456	59	17	\N	f
1457	59	18	\N	f
1458	59	19	\N	f
1459	59	20	\N	f
1460	59	21	\N	f
1461	59	22	\N	f
1462	60	1	\N	f
1463	60	2	\N	f
1464	61	1	\N	f
1465	61	2	\N	f
1466	61	3	\N	f
1467	61	4	\N	f
1468	61	5	\N	f
1469	61	6	\N	f
1470	61	7	\N	f
1471	61	8	\N	f
1472	61	9	\N	f
1473	61	10	\N	f
1474	61	11	\N	f
1475	61	12	\N	f
1476	61	13	\N	f
1477	61	14	\N	f
1478	61	15	\N	f
1479	61	16	\N	f
1480	61	17	\N	f
1481	61	18	\N	f
1482	61	19	\N	f
1483	62	1	\N	f
1484	62	2	\N	f
1485	62	3	\N	f
1486	62	4	\N	f
1487	62	5	\N	f
1488	62	6	\N	f
1489	62	7	\N	f
1490	62	8	\N	f
1491	62	9	\N	f
1492	62	10	\N	f
1493	62	11	\N	f
1494	62	12	\N	f
1495	62	13	\N	f
1496	62	14	\N	f
1497	62	15	\N	f
1498	62	16	\N	f
1499	62	17	\N	f
1500	62	18	\N	f
1501	62	19	\N	f
1502	62	20	\N	f
1503	62	21	\N	f
1504	62	22	\N	f
1505	62	23	\N	f
1506	62	24	\N	f
1507	62	25	\N	f
1508	62	26	\N	f
1509	62	27	\N	f
1510	62	28	\N	f
1511	62	29	\N	f
1512	62	30	\N	f
1513	62	31	\N	f
1514	62	32	\N	f
1515	62	33	\N	f
1516	62	34	\N	f
1517	62	35	\N	f
1518	62	36	\N	f
1519	62	37	\N	f
1520	62	38	\N	f
1521	62	39	\N	f
1522	62	40	\N	f
1523	62	41	\N	f
1524	62	42	\N	f
1525	62	43	\N	f
1526	62	44	\N	f
1527	62	45	\N	f
1528	62	46	\N	f
1529	63	1	\N	f
1530	63	2	\N	f
1531	63	3	\N	f
1532	63	4	\N	f
1533	63	5	\N	f
1534	63	6	\N	f
1535	63	7	\N	f
1536	63	8	\N	f
1537	63	9	\N	f
1538	63	10	\N	f
1539	63	11	\N	f
1540	63	12	\N	f
1541	63	13	\N	f
1542	63	14	\N	f
1543	63	15	\N	f
1544	63	16	\N	f
1545	63	17	\N	f
1546	63	18	\N	f
1547	63	19	\N	f
1548	63	20	\N	f
1549	63	21	\N	f
1550	63	22	\N	f
1551	63	23	\N	f
1552	63	24	\N	f
1553	63	25	\N	f
1554	63	26	\N	f
1555	63	27	\N	f
1556	63	28	\N	f
1557	63	29	\N	f
1558	63	30	\N	f
1559	63	31	\N	f
1560	63	32	\N	f
1561	63	33	\N	f
1562	63	34	\N	f
1563	63	35	\N	f
1564	63	36	\N	f
1565	63	37	\N	f
1566	63	38	\N	f
1567	63	39	\N	f
1568	63	40	\N	f
1569	64	1	\N	f
1570	64	2	\N	f
1571	64	3	\N	f
1572	64	4	\N	f
1573	64	5	\N	f
1574	64	6	\N	f
1575	64	7	\N	f
1576	64	8	\N	f
1577	65	1	\N	f
1578	65	2	\N	f
1579	65	3	\N	f
1580	65	4	\N	f
1581	65	5	\N	f
1582	65	6	\N	f
1583	65	7	\N	f
1584	65	8	\N	f
1585	65	9	\N	f
1586	65	10	\N	f
1587	65	11	\N	f
1588	65	12	\N	f
1589	65	13	\N	f
1590	65	14	\N	f
1591	65	15	\N	f
1592	65	16	\N	f
1593	65	17	\N	f
1594	65	18	\N	f
1595	65	19	\N	f
1596	65	20	\N	f
1597	65	21	\N	f
1598	65	22	\N	f
1599	65	23	\N	f
1600	65	24	\N	f
1601	65	25	\N	f
1602	65	26	\N	f
1603	65	27	\N	f
1604	65	28	\N	f
1605	65	29	\N	f
1606	65	30	\N	f
1607	65	31	\N	f
1608	65	32	\N	f
1609	65	33	\N	f
1610	65	34	\N	f
1611	65	35	\N	f
1612	65	36	\N	f
1613	65	37	\N	f
1614	65	38	\N	f
1615	65	39	\N	f
1616	65	40	\N	f
1617	65	41	\N	f
1618	65	42	\N	f
1619	65	43	\N	f
1620	65	44	\N	f
1621	65	45	\N	f
1622	65	46	\N	f
1623	65	47	\N	f
1624	65	48	\N	f
1625	66	1	\N	f
1626	66	2	\N	f
1627	66	3	\N	f
1628	66	4	\N	f
1629	66	5	\N	f
1630	66	6	\N	f
1631	66	7	\N	f
1632	66	8	\N	f
1633	66	9	\N	f
1634	66	10	\N	f
1635	66	11	\N	f
1636	66	12	\N	f
1637	66	13	\N	f
1638	67	1	\N	f
1639	67	2	\N	f
1640	67	3	\N	f
1641	67	4	\N	f
1642	67	5	\N	f
1643	67	6	\N	f
1644	67	7	\N	f
1645	67	8	\N	f
1646	67	9	\N	f
1647	67	10	\N	f
1648	67	11	\N	f
1649	67	12	\N	f
1650	67	13	\N	f
1651	67	14	\N	f
1652	67	15	\N	f
1653	67	16	\N	f
1654	67	17	\N	f
1655	67	18	\N	f
1656	67	19	\N	f
1657	67	20	\N	f
1658	67	21	\N	f
1659	67	22	\N	f
1660	67	23	\N	f
1661	67	24	\N	f
1662	67	25	\N	f
1663	67	26	\N	f
1664	67	27	\N	f
1665	67	28	\N	f
1666	67	29	\N	f
1667	67	30	\N	f
1668	68	1	\N	f
1669	68	2	\N	f
1670	69	1	\N	f
1671	69	2	\N	f
1672	69	3	\N	f
1673	69	4	\N	f
1674	69	5	\N	f
1675	69	6	\N	f
1676	69	7	\N	f
1677	69	8	\N	f
1678	69	9	\N	f
1679	69	10	\N	f
1680	69	11	\N	f
1681	69	12	\N	f
1682	69	13	\N	f
1683	69	14	\N	f
1684	69	15	\N	f
1685	69	16	\N	f
1686	69	17	\N	f
1687	69	18	\N	f
1688	69	19	\N	f
1689	69	20	\N	f
1690	69	21	\N	f
1691	69	22	\N	f
1692	69	23	\N	f
1693	69	24	\N	f
1694	70	1	\N	f
1695	70	2	\N	f
1696	70	3	\N	f
1697	70	4	\N	f
1698	70	5	\N	f
1699	70	6	\N	f
1700	70	7	\N	f
1701	70	8	\N	f
1702	70	9	\N	f
1703	70	10	\N	f
1704	70	11	\N	f
1705	70	12	\N	f
1706	70	13	\N	f
1707	70	14	\N	f
1708	70	15	\N	f
1709	70	16	\N	f
1710	70	17	\N	f
1711	70	18	\N	f
1712	70	19	\N	f
1713	70	20	\N	f
1714	71	1	\N	f
1715	71	2	\N	f
1716	71	3	\N	f
1717	71	4	\N	f
1718	71	5	\N	f
1719	71	6	\N	f
1720	71	7	\N	f
1721	71	8	\N	f
1722	71	9	\N	f
1723	71	10	\N	f
1724	71	11	\N	f
1725	71	12	\N	f
1726	72	1	\N	f
1727	72	2	\N	f
1728	72	3	\N	f
1729	72	4	\N	f
1730	72	5	\N	f
1731	72	6	\N	f
1732	72	7	\N	f
1733	72	8	\N	f
1734	72	9	\N	f
1735	72	10	\N	f
1736	72	11	\N	f
1737	72	12	\N	f
1738	72	13	\N	f
1739	72	14	\N	f
1740	72	15	\N	f
1741	72	16	\N	f
1742	73	1	\N	f
1743	73	2	\N	f
1744	73	3	\N	f
1745	73	4	\N	f
1746	73	5	\N	f
1747	73	6	\N	f
1748	73	7	\N	f
1749	73	8	\N	f
1750	73	9	\N	f
1751	73	10	\N	f
1752	73	11	\N	f
1753	73	12	\N	f
1754	73	13	\N	f
1755	73	14	\N	f
1756	73	15	\N	f
1757	73	16	\N	f
1758	73	17	\N	f
1759	73	18	\N	f
1760	73	19	\N	f
1761	73	20	\N	f
1762	73	21	\N	f
1763	73	22	\N	f
1764	73	23	\N	f
1765	73	24	\N	f
1766	73	25	\N	f
1767	73	26	\N	f
1768	73	27	\N	f
1769	73	28	\N	f
1770	44	1	\N	f
1771	44	2	\N	f
1772	44	3	\N	f
1773	44	4	\N	f
1774	44	5	\N	f
1775	44	6	\N	f
1776	44	7	\N	f
1777	44	8	\N	f
1778	44	9	\N	f
1779	44	10	\N	f
1780	44	11	\N	f
1781	44	12	\N	f
1782	44	13	\N	f
1783	45	1	\N	f
1784	45	2	\N	f
1785	45	3	\N	f
1786	45	4	\N	f
1787	45	5	\N	f
1788	45	6	\N	f
1789	45	7	\N	f
1790	45	8	\N	f
1791	45	9	\N	f
1792	45	10	\N	f
1793	45	11	\N	f
1794	45	12	\N	f
1795	45	13	\N	f
1796	45	14	\N	f
1797	45	15	\N	f
1798	45	16	\N	f
1799	45	17	\N	f
1800	45	18	\N	f
1801	45	19	\N	f
1802	45	20	\N	f
1803	45	21	\N	f
1804	45	22	\N	f
1805	45	23	\N	f
1806	45	24	\N	f
1807	45	25	\N	f
1808	45	26	\N	f
1809	45	27	\N	f
1810	45	28	\N	f
1811	45	29	\N	f
1812	45	30	\N	f
1813	45	31	\N	f
1814	45	32	\N	f
1815	45	33	\N	f
1816	45	34	\N	f
1817	45	35	\N	f
1818	45	36	\N	f
1819	45	37	\N	f
1820	45	38	\N	f
1821	45	39	\N	f
1822	45	40	\N	f
1823	45	41	\N	f
1824	46	1	\N	f
1825	46	2	\N	f
1826	46	3	\N	f
1827	46	4	\N	f
1828	46	5	\N	f
1829	46	6	\N	f
1830	46	7	\N	f
1831	46	8	\N	f
1832	46	9	\N	f
1833	46	10	\N	f
1834	46	11	\N	f
1835	46	12	\N	f
1836	46	13	\N	f
1837	46	14	\N	f
1838	46	15	\N	f
1839	46	16	\N	f
1840	46	17	\N	f
1841	46	18	\N	f
1842	46	19	\N	f
1843	46	20	\N	f
1844	46	21	\N	f
1845	46	22	\N	f
1846	46	23	\N	f
1847	46	24	\N	f
1848	46	25	\N	f
1849	47	1	\N	f
1850	47	2	\N	f
1851	47	3	\N	f
1852	47	4	\N	f
1853	47	5	\N	f
1854	48	1	\N	f
1855	48	2	\N	f
1856	48	3	\N	f
1857	48	4	\N	f
1858	48	5	\N	f
1859	48	6	\N	f
1860	48	7	\N	f
1861	48	8	\N	f
1862	48	9	\N	f
1863	48	10	\N	f
1864	48	11	\N	f
1865	48	12	\N	f
1866	48	13	\N	f
1867	48	14	\N	f
1868	48	15	\N	f
1869	48	16	\N	f
1870	48	17	\N	f
1871	48	18	\N	f
1872	48	19	\N	f
1873	48	20	\N	f
1874	49	1	\N	f
1875	49	2	\N	f
1876	49	3	\N	f
1877	49	4	\N	f
1878	49	5	\N	f
1879	50	1	\N	f
1880	50	2	\N	f
1881	50	3	\N	f
1882	50	4	\N	f
1883	50	5	\N	f
1884	50	6	\N	f
1885	50	7	\N	f
1886	50	8	\N	f
1887	50	9	\N	f
1888	50	10	\N	f
1889	50	11	\N	f
1890	50	12	\N	f
1891	50	13	\N	f
1892	50	14	\N	f
1893	50	15	\N	f
1894	50	16	\N	f
1895	50	17	\N	f
1896	50	18	\N	f
1897	50	19	\N	f
1898	50	20	\N	f
1899	50	21	\N	f
1900	50	22	\N	f
1901	50	23	\N	f
1902	50	24	\N	f
1903	50	25	\N	f
1904	50	26	\N	f
1905	50	27	\N	f
1906	51	1	\N	f
1907	51	2	\N	f
1908	51	3	\N	f
1909	51	4	\N	f
1910	51	5	\N	f
1911	51	6	\N	f
1912	51	7	\N	f
1913	51	8	\N	f
1914	51	9	\N	f
1915	51	10	\N	f
1916	51	11	\N	f
1917	51	12	\N	f
1918	51	13	\N	f
1919	51	14	\N	f
1920	51	15	\N	f
1921	51	16	\N	f
1922	51	17	\N	f
1923	51	18	\N	f
1924	51	19	\N	f
1925	51	20	\N	f
1926	51	21	\N	f
1927	51	22	\N	f
1928	51	23	\N	f
1929	51	24	\N	f
1930	51	25	\N	f
1931	51	26	\N	f
1932	52	1	\N	f
1933	52	2	\N	f
1934	52	3	\N	f
1935	52	4	\N	f
1936	52	5	\N	f
1937	52	6	\N	f
1938	52	7	\N	f
1939	52	8	\N	f
1940	52	9	\N	f
1941	52	10	\N	f
1942	52	11	\N	f
1943	52	12	\N	f
1944	52	13	\N	f
1945	52	14	\N	f
1946	52	15	\N	f
1947	52	16	\N	f
1948	53	1	\N	f
1949	53	2	\N	f
1950	53	3	\N	f
1951	53	4	\N	f
1952	53	5	\N	f
1953	53	6	\N	f
1954	53	7	\N	f
1955	53	8	\N	f
1956	53	9	\N	f
1957	53	10	\N	f
1958	53	11	\N	f
1959	53	12	\N	f
1960	53	13	\N	f
1961	53	14	\N	f
1962	53	15	\N	f
1963	53	16	\N	f
1964	53	17	\N	f
1965	53	18	\N	f
1966	53	19	\N	f
1967	53	20	\N	f
1968	53	21	\N	f
1969	53	22	\N	f
1970	53	23	\N	f
1971	53	24	\N	f
1972	53	25	\N	f
1973	53	26	\N	f
1974	53	27	\N	f
1975	53	28	\N	f
1976	53	29	\N	f
1977	53	30	\N	f
1978	53	31	\N	f
1979	53	32	\N	f
1980	53	33	\N	f
1981	53	34	\N	f
1982	53	35	\N	f
1983	53	36	\N	f
1984	53	37	\N	f
1985	53	38	\N	f
1986	53	39	\N	f
1987	53	40	\N	f
1988	53	41	\N	f
1989	53	42	\N	f
1990	53	43	\N	f
1991	53	44	\N	f
1992	53	45	\N	f
1993	53	46	\N	f
1994	53	47	\N	f
1995	53	48	\N	f
1996	54	1	\N	f
1997	54	2	\N	f
1998	54	3	\N	f
1999	54	4	\N	f
2000	54	5	\N	f
2001	54	6	\N	f
2002	54	7	\N	f
2003	54	8	\N	f
2004	54	9	\N	f
2005	55	1	\N	f
2006	56	1	\N	f
2007	56	2	\N	f
2008	56	3	\N	f
2009	56	4	\N	f
2010	56	5	\N	f
2011	56	6	\N	f
2012	56	7	\N	f
2013	56	8	\N	f
2014	56	9	\N	f
2015	56	10	\N	f
2016	56	11	\N	f
2017	56	12	\N	f
2018	56	13	\N	f
2019	56	14	\N	f
2020	56	15	\N	f
2021	56	16	\N	f
2022	56	17	\N	f
2023	56	18	\N	f
2024	56	19	\N	f
2025	56	20	\N	f
2026	56	21	\N	f
2027	56	22	\N	f
2028	56	23	\N	f
2029	56	24	\N	f
2030	56	25	\N	f
2031	57	1	\N	f
2032	57	2	\N	f
2033	57	3	\N	f
2034	57	4	\N	f
2035	57	5	\N	f
2036	57	6	\N	f
2037	57	7	\N	f
2038	57	8	\N	f
2039	57	9	\N	f
2040	57	10	\N	f
2041	57	11	\N	f
2042	57	12	\N	f
2043	57	13	\N	f
2044	57	14	\N	f
2045	57	15	\N	f
2046	57	16	\N	f
2047	57	17	\N	f
2048	57	18	\N	f
2049	57	19	\N	f
2050	57	20	\N	f
2051	57	21	\N	f
2052	57	22	\N	f
2053	57	23	\N	f
2054	57	24	\N	f
2055	57	25	\N	f
2056	57	26	\N	f
2057	57	27	\N	f
2058	57	28	\N	f
2059	57	29	\N	f
2060	57	30	\N	f
2061	57	31	\N	f
2062	57	32	\N	f
2063	57	33	\N	f
2064	57	34	\N	f
2065	57	35	\N	f
2066	57	36	\N	f
2067	57	37	\N	f
2068	57	38	\N	f
2069	57	39	\N	f
2070	57	40	\N	f
2071	57	41	\N	f
2072	57	42	\N	f
2073	57	43	\N	f
2074	77	1	\N	f
2075	77	2	\N	f
2076	77	3	\N	f
2077	77	4	\N	f
2078	77	5	\N	f
2079	77	6	\N	f
2080	78	1	\N	f
2081	78	2	\N	f
2082	78	3	\N	f
2083	78	4	\N	f
2084	78	5	\N	f
2085	78	6	\N	f
2086	78	7	\N	f
2087	78	8	\N	f
2088	78	9	\N	f
2089	78	10	\N	f
2090	78	11	\N	f
2091	78	12	\N	f
2092	78	13	\N	f
2093	78	14	\N	f
2094	78	15	\N	f
2095	78	16	\N	f
2096	78	17	\N	f
2097	78	18	\N	f
2098	78	19	\N	f
2099	78	20	\N	f
2100	78	21	\N	f
2101	78	22	\N	f
2102	78	23	\N	f
2103	78	24	\N	f
2104	78	25	\N	f
2105	78	26	\N	f
2106	78	27	\N	f
2107	78	28	\N	f
2108	78	29	\N	f
2109	78	30	\N	f
2110	78	31	\N	f
2111	78	32	\N	f
2112	78	33	\N	f
2113	78	34	\N	f
2114	78	35	\N	f
2115	78	36	\N	f
2116	79	1	\N	f
2117	79	2	\N	f
2118	79	3	\N	f
2119	79	4	\N	f
2120	79	5	\N	f
2121	79	6	\N	f
2122	79	7	\N	f
2123	79	8	\N	f
2124	79	9	\N	f
2125	79	10	\N	f
2126	79	11	\N	f
2127	79	12	\N	f
2128	79	13	\N	f
2129	79	14	\N	f
2130	79	15	\N	f
2131	79	16	\N	f
2132	79	17	\N	f
2133	79	18	\N	f
2134	79	19	\N	f
2135	79	20	\N	f
2136	79	21	\N	f
2137	79	22	\N	f
2138	79	23	\N	f
2139	79	24	\N	f
2140	79	25	\N	f
2141	79	26	\N	f
2142	79	27	\N	f
2143	79	28	\N	f
2144	79	29	\N	f
2145	79	30	\N	f
2146	79	31	\N	f
2147	79	32	\N	f
2148	79	33	\N	f
2149	79	34	\N	f
2150	79	35	\N	f
2151	79	36	\N	f
2152	79	37	\N	f
2153	79	38	\N	f
2154	79	39	\N	f
2155	79	40	\N	f
2156	79	41	\N	f
2157	79	42	\N	f
2158	79	43	\N	f
2159	79	44	\N	f
2160	79	45	\N	f
2161	79	46	\N	f
2162	79	47	\N	f
2163	79	48	\N	f
2164	79	49	\N	f
2165	80	1	\N	f
2166	80	2	\N	f
2167	80	3	\N	f
2168	80	4	\N	f
2169	80	5	\N	f
2170	80	6	\N	f
2171	80	7	\N	f
2172	80	8	\N	f
2173	81	1	\N	f
2174	81	2	\N	f
2175	81	3	\N	f
2176	81	4	\N	f
2177	81	5	\N	f
2178	81	6	\N	f
2179	81	7	\N	f
2180	81	8	\N	f
2181	81	9	\N	f
2182	81	10	\N	f
2183	81	11	\N	f
2184	81	12	\N	f
2185	81	13	\N	f
2186	81	14	\N	f
2187	81	15	\N	f
2188	81	16	\N	f
2189	81	17	\N	f
2190	81	18	\N	f
2191	81	19	\N	f
2192	81	20	\N	f
2193	81	21	\N	f
2194	81	22	\N	f
2195	81	23	\N	f
2196	81	24	\N	f
2197	81	25	\N	f
2198	81	26	\N	f
2199	81	27	\N	f
2200	81	28	\N	f
2201	81	29	\N	f
2202	81	30	\N	f
2203	81	31	\N	f
2204	81	32	\N	f
2205	81	33	\N	f
2206	81	34	\N	f
2207	82	1	\N	f
2208	82	2	\N	f
2209	82	3	\N	f
2210	82	4	\N	f
2211	82	5	\N	f
2212	82	6	\N	f
2213	82	7	\N	f
2214	82	8	\N	f
2215	82	9	\N	f
2216	82	10	\N	f
2217	82	11	\N	f
2218	82	12	\N	f
2219	82	13	\N	f
2220	83	1	\N	f
2221	83	2	\N	f
2222	83	3	\N	f
2223	83	4	\N	f
2224	83	5	\N	f
2225	83	6	\N	f
2226	83	7	\N	f
2227	83	8	\N	f
2228	83	9	\N	f
2229	83	10	\N	f
2230	83	11	\N	f
2231	83	12	\N	f
2232	83	13	\N	f
2233	83	14	\N	f
2234	83	15	\N	f
2235	83	16	\N	f
2236	83	17	\N	f
2237	83	18	\N	f
2238	83	19	\N	f
2239	83	20	\N	f
2240	83	21	\N	f
2241	83	22	\N	f
2242	83	23	\N	f
2243	83	24	\N	f
2244	83	25	\N	f
2245	83	26	\N	f
2246	83	27	\N	f
2247	83	28	\N	f
2248	83	29	\N	f
2249	83	30	\N	f
2250	83	31	\N	f
2251	83	32	\N	f
2252	83	33	\N	f
2253	83	34	\N	f
2254	83	35	\N	f
2255	84	1	\N	f
2256	84	2	\N	f
2257	84	3	\N	f
2258	84	4	\N	f
2259	84	5	\N	f
2260	84	6	\N	f
2261	84	7	\N	f
2262	84	8	\N	f
2263	84	9	\N	f
2264	84	10	\N	f
2265	84	11	\N	f
2266	84	12	\N	f
2267	84	13	\N	f
2268	84	14	\N	f
2269	84	15	\N	f
2270	84	16	\N	f
2271	84	17	\N	f
2272	84	18	\N	f
2273	84	19	\N	f
2274	84	20	\N	f
2275	84	21	\N	f
2276	84	22	\N	f
2277	84	23	\N	f
2278	84	24	\N	f
2279	84	25	\N	f
2280	84	26	\N	f
2281	84	27	\N	f
2282	84	28	\N	f
2283	84	29	\N	f
2284	84	30	\N	f
2285	84	31	\N	f
2286	84	32	\N	f
2287	84	33	\N	f
2288	84	34	\N	f
2289	84	35	\N	f
2290	84	36	\N	f
2291	84	37	\N	f
2292	84	38	\N	f
2293	84	39	\N	f
2294	84	40	\N	f
2295	84	41	\N	f
2296	84	42	\N	f
2297	84	43	\N	f
2298	84	44	\N	f
2299	84	45	\N	f
2300	84	46	\N	f
2301	84	47	\N	f
2302	84	48	\N	f
2303	84	49	\N	f
2304	85	1	\N	f
2305	85	2	\N	f
2306	85	3	\N	f
2307	85	4	\N	f
2308	85	5	\N	f
2309	85	6	\N	f
2310	85	7	\N	f
2311	85	8	\N	f
2312	85	9	\N	f
2313	85	10	\N	f
2314	85	11	\N	f
2315	85	12	\N	f
2316	85	13	\N	f
2317	85	14	\N	f
2318	85	15	\N	f
2319	85	16	\N	f
2320	85	17	\N	f
2321	85	18	\N	f
2322	85	19	\N	f
2323	85	20	\N	f
2324	85	21	\N	f
2325	85	22	\N	f
2326	85	23	\N	f
2327	85	24	\N	f
2328	85	25	\N	f
2329	85	26	\N	f
2330	86	1	\N	f
2331	86	2	\N	f
2332	86	3	\N	f
2333	86	4	\N	f
2334	87	1	\N	f
2335	87	2	\N	f
2336	87	3	\N	f
2337	87	4	\N	f
2338	87	5	\N	f
2339	87	6	\N	f
2340	87	7	\N	f
2341	87	8	\N	f
2342	87	9	\N	f
2343	87	10	\N	f
2344	87	11	\N	f
2345	87	12	\N	f
2346	87	13	\N	f
2347	87	14	\N	f
2348	87	15	\N	f
2349	87	16	\N	f
2350	87	17	\N	f
2351	87	18	\N	f
2352	87	19	\N	f
2353	87	20	\N	f
2354	87	21	\N	f
2355	87	22	\N	f
2356	88	1	\N	f
2357	88	2	\N	f
2358	88	3	\N	f
2359	88	4	\N	f
2360	88	5	\N	f
2361	88	6	\N	f
2362	88	7	\N	f
2363	88	8	\N	f
2364	88	9	\N	f
2365	88	10	\N	f
2366	88	11	\N	f
2367	88	12	\N	f
2368	88	13	\N	f
2369	88	14	\N	f
2370	88	15	\N	f
2371	88	16	\N	f
2372	88	17	\N	f
2373	88	18	\N	f
2374	98	1	\N	f
2375	98	2	\N	f
2376	98	3	\N	f
2377	98	4	\N	f
2378	98	5	\N	f
2379	98	6	\N	f
2380	98	7	\N	f
2381	98	8	\N	f
2382	98	9	\N	f
2383	98	10	\N	f
2384	98	11	\N	f
2385	98	12	\N	f
2386	98	13	\N	f
2387	98	14	\N	f
2388	98	15	\N	f
2389	99	1	\N	f
2390	99	2	\N	f
2391	99	3	\N	f
2392	99	4	\N	f
2393	99	5	\N	f
2394	99	6	\N	f
2395	99	7	\N	f
2396	99	8	\N	f
2397	99	9	\N	f
2398	99	10	\N	f
2399	99	11	\N	f
2400	99	12	\N	f
2401	99	13	\N	f
2402	99	14	\N	f
2403	99	15	\N	f
2404	99	16	\N	f
2405	99	17	\N	f
2406	99	18	\N	f
2407	99	19	\N	f
2408	99	20	\N	f
2409	99	21	\N	f
2410	99	22	\N	f
2411	99	23	\N	f
2412	99	24	\N	f
2413	99	25	\N	f
2414	99	26	\N	f
2415	99	27	\N	f
2416	99	28	\N	f
2417	99	29	\N	f
2418	99	30	\N	f
2419	99	31	\N	f
2420	99	32	\N	f
2421	99	33	\N	f
2422	99	34	\N	f
2423	99	35	\N	f
2424	99	36	\N	f
2425	99	37	\N	f
2426	99	38	\N	f
2427	99	39	\N	f
2428	99	40	\N	f
2429	99	41	\N	f
2430	99	42	\N	f
2431	99	43	\N	f
2432	99	44	\N	f
2433	99	45	\N	f
2434	99	46	\N	f
2435	100	1	\N	f
2436	104	1	\N	f
2437	104	2	\N	f
2438	104	3	\N	f
2439	104	4	\N	f
2440	104	5	\N	f
2441	104	6	\N	f
2442	104	7	\N	f
2443	104	8	\N	f
2444	104	9	\N	f
2445	104	10	\N	f
2446	104	11	\N	f
2447	104	12	\N	f
2448	104	13	\N	f
2449	104	14	\N	f
2450	104	15	\N	f
2451	104	16	\N	f
2452	104	17	\N	f
2453	104	18	\N	f
2454	104	19	\N	f
2455	104	20	\N	f
2456	104	21	\N	f
2457	104	22	\N	f
2458	105	1	\N	f
2459	105	2	\N	f
2460	105	3	\N	f
2461	105	4	\N	f
2462	105	5	\N	f
2463	105	6	\N	f
2464	105	7	\N	f
2465	105	8	\N	f
2466	105	9	\N	f
2467	105	10	\N	f
2468	105	11	\N	f
2469	105	12	\N	f
2470	105	13	\N	f
2471	105	14	\N	f
2472	105	15	\N	f
2473	105	16	\N	f
2474	105	17	\N	f
2475	105	18	\N	f
2476	105	19	\N	f
2477	105	20	\N	f
2478	105	21	\N	f
2479	105	22	\N	f
2480	105	23	\N	f
2481	105	24	\N	f
2482	105	25	\N	f
2483	105	26	\N	f
2484	105	27	\N	f
2485	105	28	\N	f
2486	105	29	\N	f
2487	105	30	\N	f
2488	105	31	\N	f
2489	105	32	\N	f
2490	105	33	\N	f
2491	105	34	\N	f
2492	105	35	\N	f
2493	105	36	\N	f
2494	105	37	\N	f
2495	106	1	\N	f
2496	106	2	\N	f
2497	106	3	\N	f
2498	106	4	\N	f
2499	106	5	\N	f
2500	106	6	\N	f
2501	106	7	\N	f
2502	101	1	\N	f
2503	101	2	\N	f
2504	103	1	\N	f
2505	103	2	\N	f
2506	103	3	\N	f
2507	103	4	\N	f
2508	103	5	\N	f
2509	103	6	\N	f
2510	103	7	\N	f
2511	103	8	\N	f
2512	103	9	\N	f
2513	103	10	\N	f
2514	103	11	\N	f
2515	103	12	\N	f
2516	103	13	\N	f
2517	103	14	\N	f
2518	103	15	\N	f
2519	103	16	\N	f
2520	103	17	\N	f
2521	103	18	\N	f
2522	103	19	\N	f
2523	103	20	\N	f
2524	103	21	\N	f
2525	103	22	\N	f
2526	103	23	\N	f
2527	103	24	\N	f
2528	103	25	\N	f
2529	103	26	\N	f
2530	103	27	\N	f
2531	103	28	\N	f
2532	103	29	\N	f
2533	103	30	\N	f
2534	103	31	\N	f
2535	103	32	\N	f
2536	103	33	\N	f
2537	103	34	\N	f
2538	103	35	\N	f
2539	103	36	\N	f
2540	103	37	\N	f
2541	103	38	\N	f
2542	103	39	\N	f
2543	103	40	\N	f
2544	103	41	\N	f
2545	103	42	\N	f
2546	103	43	\N	f
2547	103	44	\N	f
2548	103	45	\N	f
2549	103	46	\N	f
2550	103	47	\N	f
2551	107	1	\N	f
2552	107	2	\N	f
2553	107	3	\N	f
2554	107	4	\N	f
2555	107	5	\N	f
2556	107	6	\N	f
2557	107	7	\N	f
2558	107	8	\N	f
2559	107	9	\N	f
2560	107	10	\N	f
2561	107	11	\N	f
2562	107	12	\N	f
2563	108	1	\N	f
2564	108	2	\N	f
2565	108	3	\N	f
2566	108	4	\N	f
2567	108	5	\N	f
2568	108	6	\N	f
2569	108	7	\N	f
2570	108	8	\N	f
2571	108	9	\N	f
2572	108	10	\N	f
2573	108	11	\N	f
2574	108	12	\N	f
2575	108	13	\N	f
2576	108	14	\N	f
2577	108	15	\N	f
2578	108	16	\N	f
2579	108	17	\N	f
2580	108	18	\N	f
2581	108	19	\N	f
2582	108	20	\N	f
2583	108	21	\N	f
2584	108	22	\N	f
2585	108	23	\N	f
2586	108	24	\N	f
2587	108	25	\N	f
2588	108	26	\N	f
2589	108	27	\N	f
2590	108	28	\N	f
2591	108	29	\N	f
2592	108	30	\N	f
2593	108	31	\N	f
2594	108	32	\N	f
2595	108	33	\N	f
2596	108	34	\N	f
2597	108	35	\N	f
2598	108	36	\N	f
2599	108	37	\N	f
2600	108	38	\N	f
2601	109	1	\N	f
2602	109	2	\N	f
2603	109	3	\N	f
2604	109	4	\N	f
2605	109	5	\N	f
2606	109	6	\N	f
2607	109	7	\N	f
2608	109	8	\N	f
2609	109	9	\N	f
2610	109	10	\N	f
2611	109	11	\N	f
2612	109	12	\N	f
2613	109	13	\N	f
2614	109	14	\N	f
2615	109	15	\N	f
2616	109	16	\N	f
2617	109	17	\N	f
2618	109	18	\N	f
2619	109	19	\N	f
2620	109	20	\N	f
2621	109	21	\N	f
2622	109	22	\N	f
2623	109	23	\N	f
2624	109	24	\N	f
2625	109	25	\N	f
2626	109	26	\N	f
2627	109	27	\N	f
2628	109	28	\N	f
2629	109	29	\N	f
2630	109	30	\N	f
2631	109	31	\N	f
2632	109	32	\N	f
\.


--
-- Data for Name: contents; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.contents (content_id, date_of_creation, content_type, title, description, course_id, rate) FROM stdin;
58	2020-10-15	PAGE      	Getting ready for performing transformations	Description of page 'Getting ready for performing transformations'                                  	3	0
75	2020-10-15	PAGE      	Properties of translations	Description of page 'Properties of translations'                                                    	3	0
76	2020-10-15	QUIZ      	Translate points	Description of quiz 'Translate points'                                                              	3	0
11	2019-10-19	PAGE      	Evaluating expressions with one variable	Description of page 'Evaluating expressions with one variable'                                      	1	0
13	2019-10-19	PAGE      	Evaluating expressions with two variables	Description of page 'Evaluating expressions with two variables'                                     	1	0
15	2019-10-19	PAGE      	Evaluating expressions with two variables: fractions & decimals	Description of page 'Evaluating expressions with two variables: fractions & decimals'               	1	0
16	2019-10-19	QUIZ      	Evaluating expressions with multiple variables	Description of quiz 'Evaluating expressions with multiple variables'                                	1	0
17	2019-10-19	QUIZ      	Evaluating expressions with multiple variables: fractions and decimals	Description of quiz 'Evaluating expressions with multiple variables: fractions and decimals'        	1	0
21	2019-10-19	QUIZ      	Combining like terms with negative coefficients	Description of quiz 'Combining like terms with negative coefficients'                               	1	0
22	2019-10-19	QUIZ      	Combining like terms with negative coefficients and distribution	Description of quiz 'Combining like terms with negative coefficients and distribution'              	1	0
23	2019-10-19	QUIZ      	Combining like terms with rational coefficients	Description of quiz 'Combining like terms with rational coefficients'                               	1	0
88	2020-03-11	QUIZ      	Traingle ratios in right triangles	Description of quiz 'Traingle ratios in right triangles'                                            	4	0
74	2020-10-15	VIDEO     	Transition challenge problem	Description of video 'Transition challenge problem'                                                 	3	0
12	2019-10-19	VIDEO     	Evaluating expressions with two variables	Description of video 'Evaluating expressions with two variables'                                    	1	0
14	2019-10-19	VIDEO     	Evaluating expressions with two variables: fractions & decimals	Description of video 'Evaluating expressions with two variables: fractions & decimals'              	1	0
18	2019-10-19	VIDEO     	Combining like terms with negative coefficients & distribution	Description of video 'Combining like terms with negative coefficients & distribution'               	1	0
19	2019-10-19	VIDEO     	Combining like terms with negative coefficients	Description of video 'Combining like terms with negative coefficients'                              	1	0
48	2019-10-01	QUIZ      	Multiply monomials by polynomials	Description of quiz 'Multiply monomials by polynomials'                                             	2	0
51	2019-10-01	PAGE      	Multiply binomials by polynomials review	Description of page 'Multiply binomials by polynomials review'                                      	2	0
52	2019-10-01	QUIZ      	Multiply binomials by polynomials: area model	Description of quiz 'Multiply binomials by polynomials: area model'                                 	2	0
77	2020-10-15	QUIZ      	Determining translations	Description of quiz 'Determining translations'                                                      	3	0
4	2019-10-19	VIDEO     	Creativity break: Why is creativity importants in algebra?	Description of video 'Creativity break: Why is creativity importants in algebra?'                   	1	0
5	2019-10-19	VIDEO     	Intro to the coordinate plane	Description of video 'Intro to the coordinate plane'                                                	1	0
6	2019-10-19	VIDEO     	Why all the letters in algebra?	Description of video 'Why all the letters in algebra?'                                              	1	0
7	2019-10-19	VIDEO     	What is a variable?	Description of video 'What is a variable?'                                                          	1	0
8	2019-10-19	VIDEO     	Why aren't we using the multiplication sign?	Description of video 'Why aren't we using the multiplication sign?'                                 	1	0
9	2019-10-19	VIDEO     	Creativity break: Why is creativity important in STEM jobs?	Description of video 'Creativity break: Why is creativity important in STEM jobs?'                  	1	0
25	2019-10-19	QUIZ      	Equivalent expressions	Description of quiz 'Equivalent expressions'                                                        	1	0
33	2019-10-01	QUIZ      	Average rate of change of polynomials	Description of quiz 'Average rate of change of polynomials'                                         	2	0
37	2019-10-01	PAGE      	Adding and subtracting polynomials review	Description of page 'Adding and subtracting polynomials review'                                     	2	0
10	2019-10-19	VIDEO     	Evaluating expressions with one variable	Description of video 'Evaluating expressions with one variable'                                     	1	0
20	2019-10-19	VIDEO     	Combining like terms with rational coefficients	Description of video 'Combining like terms with rational coefficients'                              	1	0
24	2019-10-19	VIDEO     	Equivalent expressions	Description of video 'Equivalent expressions'                                                       	1	0
26	2019-10-19	VIDEO     	Why dividing by zero is undefined?	Description of video 'Why dividing by zero is undefined?'                                           	1	0
99	2020-10-16	VIDEO     	What is Programming?	Description of video 'What is Programming?'                                                         	7	0
27	2019-10-19	VIDEO     	The problem with dividing zero by zero	Description of video 'The problem with dividing zero by zero'                                       	1	0
28	2019-10-19	VIDEO     	Undefined and indeterminate expressions	Description of video 'Undefined and indeterminate expressions'                                      	1	0
29	2019-10-01	VIDEO     	Polinomials intro	Description of video 'Polinomials intro'                                                            	2	0
30	2019-10-01	VIDEO     	The parts of polynomial expressions	Description of video 'The parts of polynomial expressions'                                          	2	0
31	2019-10-01	VIDEO     	Finding average rate of change of polynomials	Description of video 'Finding average rate of change of polynomials'                                	2	0
32	2019-10-01	VIDEO     	Sign of average rate of change of polynomials	Description of video 'Sign of average rate of change of polynomials'                                	2	0
34	2019-10-01	VIDEO     	Adding polynomials	Description of video 'Adding polynomials'                                                           	2	0
35	2019-10-01	VIDEO     	Subtracting polynomials	Description of video 'Subtracting polynomials'                                                      	2	0
36	2019-10-01	VIDEO     	Polynomial subtraction	Description of video 'Polynomial subtraction'                                                       	2	0
41	2019-10-01	VIDEO     	Multiplying monomials	Description of video 'Multiplying monomials'                                                        	2	0
42	2019-10-01	VIDEO     	Multiplying monomials by polynomials: area model	Description of video 'Multiplying monomials by polynomials: area model'                             	2	0
43	2019-10-01	VIDEO     	Area model for multiplying monomials with negative terms	Description of video 'Area model for multiplying monomials with negative terms'                     	2	0
92	2020-03-12	VIDEO     	Interpreting a histogram	Description of video 'Interpreting a histogram'                                                     	5	0
50	2019-10-01	VIDEO     	Multiply binomials by polynomials	Description of video 'Multiply binomials by polynomials'                                            	2	0
57	2019-10-01	QUIZ      	Polynomial special products: perfect square	Description of quiz 'Polynomial special products: perfect square'                                   	2	0
78	2020-10-15	QUIZ      	Translate shapes	Description of quiz 'Translate shapes'                                                              	3	0
79	2020-03-11	PAGE      	Getting ready for right triangles and trigonometry	Description of page 'Getting ready for right triangles and trigonometry'                            	4	0
80	2020-03-11	PAGE      	Hypotenuse, opposite and trigonometry	Description of page 'Hypotenuse, opposite and trigonometry'                                         	4	0
38	2019-10-01	QUIZ      	Add polynomials (intro)	Description of quiz 'Add polynomials (intro)'                                                       	2	0
39	2019-10-01	QUIZ      	Subtract polynomials (intro)	Description of quiz 'Subtract polynomials (intro)'                                                  	2	0
40	2019-10-01	QUIZ      	Add and subtract polynomials	Description of quiz 'Add and subtract polynomials'                                                  	2	0
93	2020-03-12	QUIZ      	Create histograms	Description of quiz 'Create histograms'                                                             	5	0
94	2020-03-12	QUIZ      	Read histograms	Description of quiz 'Read histograms'                                                               	5	0
90	2020-03-12	QUIZ      	Reading dot plots & frequency tables	Description of quiz 'Reading dot plots & frequency tables'                                          	5	0
62	2020-10-15	QUIZ      	Geometric definitions	Description of quiz 'Geometric definitions'                                                         	3	0
65	2020-10-15	PAGE      	Translations intro	Description of page 'Translations intro'                                                            	3	0
66	2020-10-15	PAGE      	Rotations intro	Description of page 'Rotations intro'                                                               	3	0
68	2020-10-15	QUIZ      	Identify transformations	Description of quiz 'Identify transformations'                                                      	3	0
71	2020-10-15	PAGE      	Determining translations	Description of page 'Determining translations'                                                      	3	0
73	2020-10-15	PAGE      	Translating shapes	Description of page 'Translating shapes'                                                            	3	0
45	2019-10-01	PAGE      	Multiplying monomials by polynomials review	Description of page 'Multiplying monomials by polynomials review'                                   	2	0
46	2019-10-01	QUIZ      	Multiply monomials	Description of quiz 'Multiply monomials'                                                            	2	0
47	2019-10-01	QUIZ      	Multiply monomials by polynomials: area model	Description of quiz 'Multiply monomials by polynomials: area model'                                 	2	0
53	2019-10-01	QUIZ      	Multiply binomials by polynomials	Description of quiz 'Multiply binomials by polynomials'                                             	2	0
56	2019-10-01	QUIZ      	Polynomial special products: difference of squares	Description of quiz 'Polynomial special products: difference of squares'                            	2	0
81	2020-03-11	PAGE      	Side ratios in right triangles as afunction of the angles	Description of page 'Side ratios in right triangles as afunction of the angles'                     	4	0
84	2020-03-11	QUIZ      	Use ratios in right triangles	Description of quiz 'Use ratios in right triangles'                                                 	4	0
87	2020-03-11	PAGE      	Traingle ratios in right triangles	Description of page 'Traingle ratios in right triangles'                                            	4	0
100	2020-10-16	PAGE      	Learn programming on ePathshala	Description of page 'Learn programming on ePathshala'                                               	7	0
104	2021-03-13	PAGE      	How do computers represent data?	Description of page 'How do computers represent data?'                                              	9	0
106	2021-03-13	PAGE      	Bits (binary digits)	Description of page 'Bits (binary digits)'                                                          	9	0
95	2020-05-08	VIDEO     	Identifying individuals, variables and catagorical variables in a data set	Description of video 'Identifying individuals, variables and catagorical variables in a data set'   	6	0
96	2020-05-08	VIDEO     	Reading pictographs	Description of video 'Reading pictographs'                                                          	6	0
97	2020-05-08	VIDEO     	Reading bar graphs	Description of video 'Reading bar graphs'                                                           	6	0
102	2020-11-13	VIDEO     	Scarcity	Description of video 'Scarcity'                                                                     	8	0
89	2020-03-12	VIDEO     	Frequency tables and dot plots	Description of video 'Frequency tables and dot plots'                                               	5	0
91	2020-03-12	VIDEO     	Creating a histogram	Description of video 'Creating a histogram'                                                         	5	0
59	2020-10-15	VIDEO     	Euclid as father of geometry	Description of video 'Euclid as father of geometry'                                                 	3	0
60	2020-10-15	VIDEO     	Terms & labels in geometry	Description of video 'Terms & labels in geometry'                                                   	3	0
61	2020-10-15	VIDEO     	Geometric definitions example	Description of video 'Geometric definitions example'                                                	3	0
63	2020-10-15	VIDEO     	Rigid transformations intro	Description of video 'Rigid transformations intro'                                                  	3	0
64	2020-10-15	VIDEO     	Dilations intro	Description of video 'Dilations intro'                                                              	3	0
1	2019-10-19	VIDEO     	Origins of algebra	Description of video 'Origins of algebra'                                                           	1	0
2	2019-10-19	VIDEO     	Abstract-ness	Description of video 'Abstract-ness'                                                                	1	0
3	2019-10-19	VIDEO     	The beauty of algebra	Description of video 'The beauty of algebra'                                                        	1	0
67	2020-10-15	VIDEO     	Identifying transformations	Description of video 'Identifying transformations'                                                  	3	0
69	2020-10-15	VIDEO     	Translating points	Description of video 'Translating points'                                                           	3	0
70	2020-10-15	VIDEO     	Determining translations	Description of video 'Determining translations'                                                     	3	0
72	2020-10-15	VIDEO     	Translating shapes	Description of video 'Translating shapes'                                                           	3	0
44	2019-10-01	VIDEO     	Multiplying monomials by polynomials	Description of video 'Multiplying monomials by polynomials'                                         	2	0
49	2019-10-01	VIDEO     	Multiply binomials by polynomials: area model	Description of video 'Multiply binomials by polynomials: area model'                                	2	0
54	2019-10-01	VIDEO     	Polynomial special products: difference of squares	Description of video 'Polynomial special products: difference of squares'                           	2	0
55	2019-10-01	VIDEO     	Polynomial special products: perfect square	Description of video 'Polynomial special products: perfect square'                                  	2	0
82	2020-03-11	VIDEO     	Using similarity to estimate ratio between side lengths	Description of video 'Using similarity to estimate ratio between side lengths'                      	4	0
83	2020-03-11	VIDEO     	Using right triangle ratios to approximate angle measure	Description of video 'Using right triangle ratios to approximate angle measure'                     	4	0
98	2020-05-08	VIDEO     	Creating a bar graph	Description of video 'Creating a bar graph'                                                         	6	0
85	2020-03-11	VIDEO     	Triangle similarity & the trigonometric ratios	Description of video 'Triangle similarity & the trigonometric ratios'                               	4	0
86	2020-03-11	VIDEO     	Traingle ratios in right triangles	Description of video 'Traingle ratios in right triangles'                                           	4	0
105	2021-03-13	VIDEO     	Binary and data	Description of video 'Binary and data'                                                              	9	0
101	2020-11-13	VIDEO     	Introduction to economics	Description of video 'Introduction to economics'                                                    	8	0
103	2020-11-13	VIDEO     	Scarcity and rivalry	Description of video 'Scarcity and rivalry'                                                         	8	0
107	2021-05-15	VIDEO     	Introoduction to economics	Description of video 'Introoduction to economics'                                                   	10	0
108	2021-05-15	VIDEO     	Scarcity	Description of video 'Scarcity'                                                                     	10	0
109	2021-05-15	VIDEO     	Normative and positive statements	Description of video 'Normative and positive statements'                                            	10	0
\.


--
-- Data for Name: course_tags; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.course_tags (tag_id, course_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
2	3
2	4
3	7
3	9
4	9
5	8
5	10
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.courses (course_id, title, description, date_of_creation, price, creator_id) FROM stdin;
1	Algebra 1	Introduction to algebra                                                                             	2019-10-19	500	51
2	Algebra 2	Some advanced topics on algebra                                                                     	2019-10-01	500	52
3	Geometry	Learn geometry having fun                                                                           	2020-10-15	600	53
4	Trigonometry	Master trigonometry                                                                                 	2020-03-11	600	54
5	Statistics	Learn statistics basics                                                                             	2020-03-12	700	55
6	Statistics and Probablity	Learn statistics and probablity                                                                     	2020-05-08	700	56
7	Computer Programming	Learn the art of programming                                                                        	2020-10-16	1000	57
8	Microeconomics	Learn microeconomics                                                                                	2020-11-13	500	58
9	Computers and Internet	Learn how the amazing world of internet works                                                       	2021-03-13	1200	59
10	Macroeconomics	Learn macroeconomics                                                                                	2021-05-15	500	60
\.


--
-- Data for Name: enrolled_courses; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.enrolled_courses (user_id, course_id, date_of_join) FROM stdin;
1	1	2020-01-08
1	2	2020-01-08
2	1	2020-05-16
2	2	2020-05-16
2	3	2020-05-16
2	4	2020-05-16
2	5	2020-05-16
2	6	2020-05-16
2	7	2020-05-16
2	8	2020-05-16
3	1	2021-07-15
3	2	2021-07-15
4	1	2021-12-14
5	1	2021-06-28
6	1	2021-04-06
6	2	2021-04-06
6	3	2021-04-06
6	4	2021-04-06
7	1	2020-03-15
7	2	2020-03-15
7	3	2020-03-15
7	4	2020-03-15
7	5	2020-03-15
7	6	2020-03-15
8	1	2021-09-05
8	2	2021-09-05
8	3	2021-09-05
8	4	2021-09-05
8	5	2021-09-05
8	6	2021-09-05
8	7	2021-09-05
9	1	2021-03-02
9	2	2021-03-02
9	3	2021-03-02
9	4	2021-03-02
9	5	2021-03-02
9	6	2021-03-02
9	7	2021-03-02
9	8	2021-03-02
9	9	2021-03-02
10	1	2021-05-04
10	2	2021-05-04
10	3	2021-05-04
10	4	2021-05-04
10	5	2021-05-04
10	6	2021-05-04
10	7	2021-05-04
10	8	2021-05-04
10	9	2021-05-04
11	1	2021-01-04
11	2	2021-01-04
11	3	2021-01-04
11	4	2021-01-04
11	5	2021-01-04
11	6	2021-01-04
11	7	2021-01-04
12	1	2020-10-16
12	2	2020-10-16
12	3	2020-10-16
12	4	2020-10-16
12	5	2020-10-16
12	6	2020-10-16
12	7	2020-10-16
13	1	2020-03-08
13	2	2020-03-08
13	3	2020-03-08
14	1	2021-02-15
14	2	2021-02-15
14	3	2021-02-15
14	4	2021-02-15
14	5	2021-02-15
14	6	2021-02-15
14	7	2021-02-15
14	8	2021-02-15
14	9	2021-02-15
14	10	2021-02-15
15	1	2021-07-03
15	2	2021-07-03
15	3	2021-07-03
15	4	2021-07-03
16	1	2020-02-16
16	2	2020-02-16
16	3	2020-02-16
17	1	2020-01-26
17	2	2020-01-26
17	3	2020-01-26
17	4	2020-01-26
17	5	2020-01-26
17	6	2020-01-26
17	7	2020-01-26
17	8	2020-01-26
18	1	2021-03-23
18	2	2021-03-23
18	3	2021-03-23
19	1	2021-04-09
19	2	2021-04-09
19	3	2021-04-09
19	4	2021-04-09
19	5	2021-04-09
20	1	2020-02-17
20	2	2020-02-17
20	3	2020-02-17
20	4	2020-02-17
20	5	2020-02-17
21	1	2020-02-11
21	2	2020-02-11
21	3	2020-02-11
22	1	2020-04-21
22	2	2020-04-21
23	1	2021-02-16
23	2	2021-02-16
23	3	2021-02-16
23	4	2021-02-16
23	5	2021-02-16
24	1	2020-08-01
24	2	2020-08-01
24	3	2020-08-01
25	1	2020-12-15
25	2	2020-12-15
25	3	2020-12-15
25	4	2020-12-15
25	5	2020-12-15
25	6	2020-12-15
26	1	2021-07-20
26	2	2021-07-20
26	3	2021-07-20
27	1	2021-01-01
28	1	2020-04-27
28	2	2020-04-27
28	3	2020-04-27
28	4	2020-04-27
28	5	2020-04-27
29	1	2020-12-13
29	2	2020-12-13
29	3	2020-12-13
29	4	2020-12-13
30	1	2021-08-25
30	2	2021-08-25
30	3	2021-08-25
31	1	2020-05-17
31	2	2020-05-17
31	3	2020-05-17
31	4	2020-05-17
31	5	2020-05-17
32	1	2020-05-15
32	2	2020-05-15
32	3	2020-05-15
33	1	2021-12-22
33	2	2021-12-22
33	3	2021-12-22
33	4	2021-12-22
33	5	2021-12-22
33	6	2021-12-22
33	7	2021-12-22
33	8	2021-12-22
34	1	2021-04-28
34	2	2021-04-28
34	3	2021-04-28
34	4	2021-04-28
34	5	2021-04-28
34	6	2021-04-28
35	1	2021-03-15
35	2	2021-03-15
35	3	2021-03-15
35	4	2021-03-15
35	5	2021-03-15
36	1	2020-09-04
36	2	2020-09-04
36	3	2020-09-04
36	4	2020-09-04
36	5	2020-09-04
36	6	2020-09-04
37	1	2021-01-28
37	2	2021-01-28
37	3	2021-01-28
37	4	2021-01-28
37	5	2021-01-28
38	1	2021-11-05
38	2	2021-11-05
38	3	2021-11-05
38	4	2021-11-05
38	5	2021-11-05
39	1	2020-11-13
39	2	2020-11-13
39	3	2020-11-13
39	4	2020-11-13
39	5	2020-11-13
39	6	2020-11-13
39	7	2020-11-13
39	8	2020-11-13
39	9	2020-11-13
40	1	2020-05-26
40	2	2020-05-26
40	3	2020-05-26
41	1	2020-08-16
41	2	2020-08-16
41	3	2020-08-16
41	4	2020-08-16
41	5	2020-08-16
41	6	2020-08-16
41	7	2020-08-16
42	1	2021-05-02
42	2	2021-05-02
42	3	2021-05-02
42	4	2021-05-02
42	5	2021-05-02
42	6	2021-05-02
42	7	2021-05-02
43	1	2021-03-03
43	2	2021-03-03
43	3	2021-03-03
43	4	2021-03-03
43	5	2021-03-03
43	6	2021-03-03
43	7	2021-03-03
43	8	2021-03-03
43	9	2021-03-03
44	1	2021-12-07
44	2	2021-12-07
44	3	2021-12-07
45	1	2020-10-06
45	2	2020-10-06
45	3	2020-10-06
45	4	2020-10-06
46	1	2021-08-20
46	2	2021-08-20
46	3	2021-08-20
46	4	2021-08-20
46	5	2021-08-20
46	6	2021-08-20
47	1	2021-09-15
47	2	2021-09-15
47	3	2021-09-15
47	4	2021-09-15
47	5	2021-09-15
47	6	2021-09-15
47	7	2021-09-15
48	1	2020-11-28
48	2	2020-11-28
48	3	2020-11-28
48	4	2020-11-28
48	5	2020-11-28
48	6	2020-11-28
49	1	2020-07-11
49	2	2020-07-11
49	3	2020-07-11
49	4	2020-07-11
49	5	2020-07-11
50	1	2021-07-20
50	2	2021-07-20
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
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.tags (tag_id, tag_name) FROM stdin;
1	math      
2	geometry  
3	computer  
4	internet  
5	economics 
\.


--
-- Data for Name: teacher_specialities; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.teacher_specialities (teacher_id, speciality) FROM stdin;
51	Math
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
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.teachers (user_id, date_of_join) FROM stdin;
51	2019-10-19
52	2019-10-01
53	2020-10-15
54	2020-03-11
55	2020-03-12
56	2020-05-08
57	2020-10-16
58	2020-11-13
59	2021-03-13
60	2021-05-15
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: epathshala
--

COPY public.users (user_id, full_name, security_key, date_of_birth, bio, email, user_type, credit_card_id, bank_id) FROM stdin;
2	Marisol Hicks	12345678                        	1997-11-04	                                                                                                    	marisol445@gmail.com	STUDENT   	2	1
3	Jose Sylvester	12345678                        	2000-03-06	                                                                                                    	jose7038@gmail.com	STUDENT   	3	3
4	William Adams	12345678                        	1993-11-21	                                                                                                    	william2284@gmail.com	STUDENT   	4	2
5	Michelle Kimmell	12345678                        	1992-05-18	                                                                                                    	michelle2802@gmail.com	STUDENT   	5	2
6	Ashley Langston	12345678                        	1980-03-27	                                                                                                    	ashley932@gmail.com	STUDENT   	6	2
7	Allyson Moschetti	12345678                        	1997-12-05	                                                                                                    	allyson3467@gmail.com	STUDENT   	7	2
8	Dolores White	12345678                        	1994-09-24	                                                                                                    	dolores2369@gmail.com	STUDENT   	8	1
9	Dorothy Alford	12345678                        	1998-01-04	                                                                                                    	dorothy1775@gmail.com	STUDENT   	9	1
10	Beth Smith	12345678                        	1997-09-18	                                                                                                    	beth3902@gmail.com	STUDENT   	10	3
11	Lila Crawford	12345678                        	1983-10-20	                                                                                                    	lila6053@gmail.com	STUDENT   	11	3
12	Devon Steger	12345678                        	1991-06-09	                                                                                                    	devon1321@gmail.com	STUDENT   	12	3
13	Al Lynch	12345678                        	1989-07-24	                                                                                                    	al8986@gmail.com	STUDENT   	13	1
14	Joi Bellefeuille	12345678                        	1992-11-17	                                                                                                    	joi6193@gmail.com	STUDENT   	14	1
15	Kimberly Toler	12345678                        	1981-04-06	                                                                                                    	kimberly1991@gmail.com	STUDENT   	15	1
16	Tonya Harris	12345678                        	1998-03-20	                                                                                                    	tonya6665@gmail.com	STUDENT   	16	3
17	Joseph Sharp	12345678                        	1993-12-28	                                                                                                    	joseph7068@gmail.com	STUDENT   	17	2
18	Carrie Andrew	12345678                        	1987-09-24	                                                                                                    	carrie7877@gmail.com	STUDENT   	18	1
19	Louis Laster	12345678                        	1989-01-12	                                                                                                    	louis9310@gmail.com	STUDENT   	19	3
20	Dustin Coppinger	12345678                        	1997-11-25	                                                                                                    	dustin8186@gmail.com	STUDENT   	20	2
21	Hilario Skrine	12345678                        	1995-12-05	                                                                                                    	hilario581@gmail.com	STUDENT   	21	1
22	Crystal Warnick	12345678                        	1992-10-03	                                                                                                    	crystal478@gmail.com	STUDENT   	22	2
23	Mamie Richmond	12345678                        	1991-12-04	                                                                                                    	mamie4456@gmail.com	STUDENT   	23	1
24	Bryan Harker	12345678                        	1984-10-04	                                                                                                    	bryan305@gmail.com	STUDENT   	24	2
25	Deborah Kachmarsky	12345678                        	1987-06-06	                                                                                                    	deborah8755@gmail.com	STUDENT   	25	1
26	Sharon Valcourt	12345678                        	1999-03-26	                                                                                                    	sharon6716@gmail.com	STUDENT   	26	1
27	Steven Hawkins	12345678                        	1992-05-09	                                                                                                    	steven6322@gmail.com	STUDENT   	27	2
28	Michael Ellis	12345678                        	1988-01-02	                                                                                                    	michael3105@gmail.com	STUDENT   	28	3
29	Willie Vieira	12345678                        	1985-07-01	                                                                                                    	willie8026@gmail.com	STUDENT   	29	2
30	Shari Swartz	12345678                        	1982-09-26	                                                                                                    	shari875@gmail.com	STUDENT   	30	2
31	Thomas Caraballo	12345678                        	1990-01-03	                                                                                                    	thomas476@gmail.com	STUDENT   	31	2
32	Sharon Acker	12345678                        	1988-11-26	                                                                                                    	sharon5866@gmail.com	STUDENT   	32	1
33	James Thomas	12345678                        	1984-08-02	                                                                                                    	james8865@gmail.com	STUDENT   	33	1
1	Mary Prezzia	12345678                        	1986-02-25	                                                                                                    	mary1151@gmail.com	STUDENT   	1	3
34	Reginald Contreras	12345678                        	1992-07-17	                                                                                                    	reginald5090@gmail.com	STUDENT   	34	2
35	Robert Gartin	12345678                        	1999-02-15	                                                                                                    	robert2831@gmail.com	STUDENT   	35	3
36	Sharon Gamino	12345678                        	1999-11-17	                                                                                                    	sharon1938@gmail.com	STUDENT   	36	2
37	Cynthia Gonzalez	12345678                        	1989-05-05	                                                                                                    	cynthia6438@gmail.com	STUDENT   	37	1
38	Brent Clower	12345678                        	1998-05-18	                                                                                                    	brent4149@gmail.com	STUDENT   	38	1
39	Philip Vanderloo	12345678                        	1985-05-13	                                                                                                    	philip6560@gmail.com	STUDENT   	39	3
40	Tana Kinloch	12345678                        	1995-05-24	                                                                                                    	tana6370@gmail.com	STUDENT   	40	1
41	Maria Summer	12345678                        	1981-10-16	                                                                                                    	maria1475@gmail.com	STUDENT   	41	2
42	Douglas Mcgowan	12345678                        	1992-05-09	                                                                                                    	douglas2320@gmail.com	STUDENT   	42	2
43	Noah Jamerson	12345678                        	1984-02-25	                                                                                                    	noah2915@gmail.com	STUDENT   	43	1
44	Helen Burton	12345678                        	1993-03-18	                                                                                                    	helen2377@gmail.com	STUDENT   	44	2
45	Crystal Hamby	12345678                        	1986-10-08	                                                                                                    	crystal1815@gmail.com	STUDENT   	45	1
46	Glen Basista	12345678                        	1997-12-27	                                                                                                    	glen3930@gmail.com	STUDENT   	46	1
47	Rodney Wolfe	12345678                        	1988-05-10	                                                                                                    	rodney23@gmail.com	STUDENT   	47	1
48	Lori Gilmore	12345678                        	1986-01-07	                                                                                                    	lori8056@gmail.com	STUDENT   	48	3
49	Kristina Shriver	12345678                        	1996-11-06	                                                                                                    	kristina8057@gmail.com	STUDENT   	49	1
50	William Kish	12345678                        	1993-12-07	                                                                                                    	william3749@gmail.com	STUDENT   	50	3
51	Martha Marbley	12345678                        	1986-05-26	                                                                                                    	martha4381@gmail.com	TEACHER   	51	3
52	Carolyn Watkins	12345678                        	2000-06-12	                                                                                                    	carolyn8065@gmail.com	TEACHER   	52	3
53	Diane Jones	12345678                        	1998-06-24	                                                                                                    	diane6212@gmail.com	TEACHER   	53	3
54	Helena Nolder	12345678                        	1992-11-09	                                                                                                    	helena1754@gmail.com	TEACHER   	54	1
55	Mike Mills	12345678                        	1985-11-09	                                                                                                    	mike7179@gmail.com	TEACHER   	55	2
56	Charles Wiltberger	12345678                        	1982-09-21	                                                                                                    	charles2480@gmail.com	TEACHER   	56	1
57	Henry Depalma	12345678                        	1993-06-27	                                                                                                    	henry4121@gmail.com	TEACHER   	57	3
60	Pamela Pemberton	12345678                        	1981-02-21	                                                                                                    	pamela4346@gmail.com	TEACHER   	60	3
58	Mario Barnett	12345678                        	1998-02-23	                                                                                                    	mario4755@gmail.com	TEACHER   	58	3
59	Hubert Rodriguez	12345678                        	1988-11-19	                                                                                                    	hubert3151@gmail.com	TEACHER   	59	3
\.


--
-- Name: content_viewers_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epathshala
--

SELECT pg_catalog.setval('public.content_viewers_view_id_seq', 1, false);


--
-- Name: contents_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epathshala
--

SELECT pg_catalog.setval('public.contents_content_id_seq', 109, true);


--
-- Name: tags_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epathshala
--

SELECT pg_catalog.setval('public.tags_tag_id_seq', 1, false);


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
-- Name: contents contents_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (content_id);


--
-- Name: course_tags course_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_tags
    ADD CONSTRAINT course_tags_pkey PRIMARY KEY (tag_id, course_id);


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
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag_id);


--
-- Name: tags tags_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_tag_name_key UNIQUE (tag_name);


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
-- Name: users insert_user_trigger; Type: TRIGGER; Schema: public; Owner: epathshala
--

CREATE TRIGGER insert_user_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.insert_user_trigger();


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
-- Name: course_tags course_tags_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_tags
    ADD CONSTRAINT course_tags_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_tags course_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: epathshala
--

ALTER TABLE ONLY public.course_tags
    ADD CONSTRAINT course_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(tag_id) ON UPDATE CASCADE ON DELETE CASCADE;


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

