--
-- PostgreSQL database dump
--

-- Dumped from database version 15.14
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg22.04+2)

-- Started on 2025-11-24 20:11:01 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- TOC entry 286 (class 1259 OID 17144)
-- Name: dim_tmp; Type: TABLE; Schema: gold; Owner: airflow
--

CREATE TABLE gold.dim_tmp (
    srk_tmp integer NOT NULL,
    cod_per character varying(20) NOT NULL,
    num_ano integer,
    cod_tri character varying(5)
);


ALTER TABLE gold.dim_tmp OWNER TO airflow;

--
-- TOC entry 285 (class 1259 OID 17143)
-- Name: dim_tmp_srk_tmp_seq; Type: SEQUENCE; Schema: gold; Owner: airflow
--

CREATE SEQUENCE gold.dim_tmp_srk_tmp_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gold.dim_tmp_srk_tmp_seq OWNER TO airflow;

--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 285
-- Name: dim_tmp_srk_tmp_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: airflow
--

ALTER SEQUENCE gold.dim_tmp_srk_tmp_seq OWNED BY gold.dim_tmp.srk_tmp;


--
-- TOC entry 3425 (class 2604 OID 17147)
-- Name: dim_tmp srk_tmp; Type: DEFAULT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_tmp ALTER COLUMN srk_tmp SET DEFAULT nextval('gold.dim_tmp_srk_tmp_seq'::regclass);


--
-- TOC entry 3573 (class 0 OID 17144)
-- Dependencies: 286
-- Data for Name: dim_tmp; Type: TABLE DATA; Schema: gold; Owner: airflow
--

INSERT INTO gold.dim_tmp VALUES (1, '2013-Q4', 2013, 'Q4');
INSERT INTO gold.dim_tmp VALUES (2, '2015-Q3', 2015, 'Q3');
INSERT INTO gold.dim_tmp VALUES (3, '2019-Q1', 2019, 'Q1');
INSERT INTO gold.dim_tmp VALUES (4, '2011-Q3', 2011, 'Q3');
INSERT INTO gold.dim_tmp VALUES (5, '2010-Q1', 2010, 'Q1');
INSERT INTO gold.dim_tmp VALUES (6, '2001-Q4', 2001, 'Q4');
INSERT INTO gold.dim_tmp VALUES (7, '2003-Q4', 2003, 'Q4');
INSERT INTO gold.dim_tmp VALUES (8, '2007-Q1', 2007, 'Q1');
INSERT INTO gold.dim_tmp VALUES (9, '2022-Q1', 2022, 'Q1');
INSERT INTO gold.dim_tmp VALUES (10, '2008-Q3', 2008, 'Q3');
INSERT INTO gold.dim_tmp VALUES (11, '2020-Q3', 2020, 'Q3');
INSERT INTO gold.dim_tmp VALUES (12, '2014-Q4', 2014, 'Q4');
INSERT INTO gold.dim_tmp VALUES (13, '2017-Q4', 2017, 'Q4');
INSERT INTO gold.dim_tmp VALUES (14, '2024-Q2', 2024, 'Q2');
INSERT INTO gold.dim_tmp VALUES (15, '2009-Q3', 2009, 'Q3');
INSERT INTO gold.dim_tmp VALUES (16, '2019-Q2', 2019, 'Q2');
INSERT INTO gold.dim_tmp VALUES (17, '2013-Q1', 2013, 'Q1');
INSERT INTO gold.dim_tmp VALUES (18, '2003-Q1', 2003, 'Q1');
INSERT INTO gold.dim_tmp VALUES (19, '2010-Q3', 2010, 'Q3');
INSERT INTO gold.dim_tmp VALUES (20, '2014-Q2', 2014, 'Q2');
INSERT INTO gold.dim_tmp VALUES (21, '2025-Q3', 2025, 'Q3');
INSERT INTO gold.dim_tmp VALUES (22, '2018-Q4', 2018, 'Q4');
INSERT INTO gold.dim_tmp VALUES (23, '2001-Q3', 2001, 'Q3');
INSERT INTO gold.dim_tmp VALUES (24, '2009-Q2', 2009, 'Q2');
INSERT INTO gold.dim_tmp VALUES (25, '2008-Q2', 2008, 'Q2');
INSERT INTO gold.dim_tmp VALUES (26, '2009-Q4', 2009, 'Q4');
INSERT INTO gold.dim_tmp VALUES (27, '2020-Q1', 2020, 'Q1');
INSERT INTO gold.dim_tmp VALUES (28, '2015-Q2', 2015, 'Q2');
INSERT INTO gold.dim_tmp VALUES (29, '2021-Q1', 2021, 'Q1');
INSERT INTO gold.dim_tmp VALUES (30, '2009-Q1', 2009, 'Q1');
INSERT INTO gold.dim_tmp VALUES (31, '2006-Q3', 2006, 'Q3');
INSERT INTO gold.dim_tmp VALUES (32, '2021-Q2', 2021, 'Q2');
INSERT INTO gold.dim_tmp VALUES (33, '2002-Q4', 2002, 'Q4');
INSERT INTO gold.dim_tmp VALUES (34, '2004-Q3', 2004, 'Q3');
INSERT INTO gold.dim_tmp VALUES (35, '2017-Q3', 2017, 'Q3');
INSERT INTO gold.dim_tmp VALUES (36, '2024-Q4', 2024, 'Q4');
INSERT INTO gold.dim_tmp VALUES (37, '2018-Q3', 2018, 'Q3');
INSERT INTO gold.dim_tmp VALUES (38, '2006-Q1', 2006, 'Q1');
INSERT INTO gold.dim_tmp VALUES (39, '2012-Q3', 2012, 'Q3');
INSERT INTO gold.dim_tmp VALUES (40, '2021-Q3', 2021, 'Q3');
INSERT INTO gold.dim_tmp VALUES (41, '2003-Q3', 2003, 'Q3');
INSERT INTO gold.dim_tmp VALUES (42, '2019-Q4', 2019, 'Q4');
INSERT INTO gold.dim_tmp VALUES (43, '2004-Q1', 2004, 'Q1');
INSERT INTO gold.dim_tmp VALUES (44, '2025-Q1', 2025, 'Q1');
INSERT INTO gold.dim_tmp VALUES (45, '2024-Q1', 2024, 'Q1');
INSERT INTO gold.dim_tmp VALUES (46, '2005-Q4', 2005, 'Q4');
INSERT INTO gold.dim_tmp VALUES (47, '2007-Q3', 2007, 'Q3');
INSERT INTO gold.dim_tmp VALUES (48, '2000-Q4', 2000, 'Q4');
INSERT INTO gold.dim_tmp VALUES (49, '2007-Q2', 2007, 'Q2');
INSERT INTO gold.dim_tmp VALUES (50, '2012-Q4', 2012, 'Q4');
INSERT INTO gold.dim_tmp VALUES (51, '2021-Q4', 2021, 'Q4');
INSERT INTO gold.dim_tmp VALUES (52, '2002-Q1', 2002, 'Q1');
INSERT INTO gold.dim_tmp VALUES (53, '2016-Q4', 2016, 'Q4');
INSERT INTO gold.dim_tmp VALUES (54, '2001-Q1', 2001, 'Q1');
INSERT INTO gold.dim_tmp VALUES (55, '2012-Q1', 2012, 'Q1');
INSERT INTO gold.dim_tmp VALUES (56, '2001-Q2', 2001, 'Q2');
INSERT INTO gold.dim_tmp VALUES (57, '2020-Q2', 2020, 'Q2');
INSERT INTO gold.dim_tmp VALUES (58, '2005-Q2', 2005, 'Q2');
INSERT INTO gold.dim_tmp VALUES (59, '2008-Q4', 2008, 'Q4');
INSERT INTO gold.dim_tmp VALUES (60, '2012-Q2', 2012, 'Q2');
INSERT INTO gold.dim_tmp VALUES (61, '2006-Q2', 2006, 'Q2');
INSERT INTO gold.dim_tmp VALUES (62, '2000-Q3', 2000, 'Q3');
INSERT INTO gold.dim_tmp VALUES (63, '2004-Q2', 2004, 'Q2');
INSERT INTO gold.dim_tmp VALUES (64, '2023-Q1', 2023, 'Q1');
INSERT INTO gold.dim_tmp VALUES (65, '2015-Q1', 2015, 'Q1');
INSERT INTO gold.dim_tmp VALUES (66, '2011-Q1', 2011, 'Q1');
INSERT INTO gold.dim_tmp VALUES (67, '2010-Q4', 2010, 'Q4');
INSERT INTO gold.dim_tmp VALUES (68, '2015-Q4', 2015, 'Q4');
INSERT INTO gold.dim_tmp VALUES (69, '2014-Q3', 2014, 'Q3');
INSERT INTO gold.dim_tmp VALUES (70, '2011-Q2', 2011, 'Q2');
INSERT INTO gold.dim_tmp VALUES (71, '2013-Q3', 2013, 'Q3');
INSERT INTO gold.dim_tmp VALUES (72, '2004-Q4', 2004, 'Q4');
INSERT INTO gold.dim_tmp VALUES (73, '2017-Q1', 2017, 'Q1');
INSERT INTO gold.dim_tmp VALUES (74, '2018-Q1', 2018, 'Q1');
INSERT INTO gold.dim_tmp VALUES (75, '2000-Q2', 2000, 'Q2');
INSERT INTO gold.dim_tmp VALUES (76, '2016-Q2', 2016, 'Q2');
INSERT INTO gold.dim_tmp VALUES (77, '2006-Q4', 2006, 'Q4');
INSERT INTO gold.dim_tmp VALUES (78, '2000-Q1', 2000, 'Q1');
INSERT INTO gold.dim_tmp VALUES (79, '2022-Q2', 2022, 'Q2');
INSERT INTO gold.dim_tmp VALUES (80, '2005-Q3', 2005, 'Q3');
INSERT INTO gold.dim_tmp VALUES (81, '2025-Q2', 2025, 'Q2');
INSERT INTO gold.dim_tmp VALUES (82, '2022-Q4', 2022, 'Q4');
INSERT INTO gold.dim_tmp VALUES (83, '2024-Q3', 2024, 'Q3');
INSERT INTO gold.dim_tmp VALUES (84, '2016-Q3', 2016, 'Q3');
INSERT INTO gold.dim_tmp VALUES (85, '2002-Q2', 2002, 'Q2');
INSERT INTO gold.dim_tmp VALUES (86, '2010-Q2', 2010, 'Q2');
INSERT INTO gold.dim_tmp VALUES (87, '2016-Q1', 2016, 'Q1');
INSERT INTO gold.dim_tmp VALUES (88, '2017-Q2', 2017, 'Q2');
INSERT INTO gold.dim_tmp VALUES (89, '2007-Q4', 2007, 'Q4');
INSERT INTO gold.dim_tmp VALUES (90, '2023-Q3', 2023, 'Q3');
INSERT INTO gold.dim_tmp VALUES (91, '2008-Q1', 2008, 'Q1');
INSERT INTO gold.dim_tmp VALUES (92, '2023-Q4', 2023, 'Q4');
INSERT INTO gold.dim_tmp VALUES (93, '2011-Q4', 2011, 'Q4');
INSERT INTO gold.dim_tmp VALUES (94, '2003-Q2', 2003, 'Q2');
INSERT INTO gold.dim_tmp VALUES (95, '2018-Q2', 2018, 'Q2');
INSERT INTO gold.dim_tmp VALUES (96, '2013-Q2', 2013, 'Q2');
INSERT INTO gold.dim_tmp VALUES (97, '2020-Q4', 2020, 'Q4');
INSERT INTO gold.dim_tmp VALUES (98, '2014-Q1', 2014, 'Q1');
INSERT INTO gold.dim_tmp VALUES (99, '2022-Q3', 2022, 'Q3');
INSERT INTO gold.dim_tmp VALUES (100, '2023-Q2', 2023, 'Q2');
INSERT INTO gold.dim_tmp VALUES (101, '2002-Q3', 2002, 'Q3');
INSERT INTO gold.dim_tmp VALUES (102, '2019-Q3', 2019, 'Q3');
INSERT INTO gold.dim_tmp VALUES (103, '2005-Q1', 2005, 'Q1');


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 285
-- Name: dim_tmp_srk_tmp_seq; Type: SEQUENCE SET; Schema: gold; Owner: airflow
--

SELECT pg_catalog.setval('gold.dim_tmp_srk_tmp_seq', 103, true);


--
-- TOC entry 3427 (class 2606 OID 17151)
-- Name: dim_tmp dim_tmp_cod_per_key; Type: CONSTRAINT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_tmp
    ADD CONSTRAINT dim_tmp_cod_per_key UNIQUE (cod_per);


--
-- TOC entry 3429 (class 2606 OID 17149)
-- Name: dim_tmp dim_tmp_pkey; Type: CONSTRAINT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_tmp
    ADD CONSTRAINT dim_tmp_pkey PRIMARY KEY (srk_tmp);


-- Completed on 2025-11-24 20:11:01 -03

--
-- PostgreSQL database dump complete
--

