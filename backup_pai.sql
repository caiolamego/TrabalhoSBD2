--
-- PostgreSQL database dump
--

-- Dumped from database version 15.14
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg22.04+2)

-- Started on 2025-11-24 20:10:45 -03

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
-- TOC entry 284 (class 1259 OID 17135)
-- Name: dim_pai; Type: TABLE; Schema: gold; Owner: airflow
--

CREATE TABLE gold.dim_pai (
    srk_pai integer NOT NULL,
    cod_pai character varying(10) NOT NULL,
    nom_pai character varying(100)
);


ALTER TABLE gold.dim_pai OWNER TO airflow;

--
-- TOC entry 283 (class 1259 OID 17134)
-- Name: dim_pai_srk_pai_seq; Type: SEQUENCE; Schema: gold; Owner: airflow
--

CREATE SEQUENCE gold.dim_pai_srk_pai_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gold.dim_pai_srk_pai_seq OWNER TO airflow;

--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 283
-- Name: dim_pai_srk_pai_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: airflow
--

ALTER SEQUENCE gold.dim_pai_srk_pai_seq OWNED BY gold.dim_pai.srk_pai;


--
-- TOC entry 3425 (class 2604 OID 17138)
-- Name: dim_pai srk_pai; Type: DEFAULT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_pai ALTER COLUMN srk_pai SET DEFAULT nextval('gold.dim_pai_srk_pai_seq'::regclass);


--
-- TOC entry 3573 (class 0 OID 17135)
-- Dependencies: 284
-- Data for Name: dim_pai; Type: TABLE DATA; Schema: gold; Owner: airflow
--

INSERT INTO gold.dim_pai VALUES (1, 'POL', 'Polônia');
INSERT INTO gold.dim_pai VALUES (2, 'BRA', 'Brasil');
INSERT INTO gold.dim_pai VALUES (3, 'FRA', 'França');
INSERT INTO gold.dim_pai VALUES (4, 'URY', 'Uruguai');
INSERT INTO gold.dim_pai VALUES (5, 'ITA', 'Itália');
INSERT INTO gold.dim_pai VALUES (6, 'GHA', 'Gana');
INSERT INTO gold.dim_pai VALUES (7, 'QAT', 'Catar');
INSERT INTO gold.dim_pai VALUES (8, 'GBR', 'Reino Unido');
INSERT INTO gold.dim_pai VALUES (9, 'ARE', 'Emirados Árabes Unidos');
INSERT INTO gold.dim_pai VALUES (10, 'AUS', 'Austrália');
INSERT INTO gold.dim_pai VALUES (11, 'MEX', 'México');
INSERT INTO gold.dim_pai VALUES (12, 'HUN', 'Hungria');
INSERT INTO gold.dim_pai VALUES (13, 'THA', 'Tailândia');
INSERT INTO gold.dim_pai VALUES (14, 'NOR', 'Noruega');
INSERT INTO gold.dim_pai VALUES (15, 'FIN', 'Finlândia');
INSERT INTO gold.dim_pai VALUES (16, 'SAU', 'Arábia Saudita');
INSERT INTO gold.dim_pai VALUES (17, 'KWT', 'Kuwait');
INSERT INTO gold.dim_pai VALUES (18, 'PER', 'Peru');
INSERT INTO gold.dim_pai VALUES (19, 'NLD', 'Holanda');
INSERT INTO gold.dim_pai VALUES (20, 'LUX', 'Luxemburgo');
INSERT INTO gold.dim_pai VALUES (21, 'AUT', 'Áustria');
INSERT INTO gold.dim_pai VALUES (22, 'USA', 'Estados Unidos');
INSERT INTO gold.dim_pai VALUES (23, 'VNM', 'Vietnã');
INSERT INTO gold.dim_pai VALUES (24, 'KOR', 'Coreia do Sul');
INSERT INTO gold.dim_pai VALUES (25, 'ZAF', 'África do Sul');
INSERT INTO gold.dim_pai VALUES (26, 'ISR', 'Israel');
INSERT INTO gold.dim_pai VALUES (27, 'PRT', 'Portugal');
INSERT INTO gold.dim_pai VALUES (28, 'IRN', 'Irã');
INSERT INTO gold.dim_pai VALUES (29, 'TWN', 'Taiwan');
INSERT INTO gold.dim_pai VALUES (30, 'MYS', 'Malásia');
INSERT INTO gold.dim_pai VALUES (31, 'CHL', 'Chile');
INSERT INTO gold.dim_pai VALUES (32, 'CAN', 'Canadá');
INSERT INTO gold.dim_pai VALUES (33, 'COL', 'Colômbia');
INSERT INTO gold.dim_pai VALUES (34, 'RUS', 'Rússia');
INSERT INTO gold.dim_pai VALUES (35, 'ROU', 'Romênia');
INSERT INTO gold.dim_pai VALUES (36, 'ARG', 'Argentina');
INSERT INTO gold.dim_pai VALUES (37, 'DNK', 'Dinamarca');
INSERT INTO gold.dim_pai VALUES (38, 'ESP', 'Espanha');
INSERT INTO gold.dim_pai VALUES (39, 'KEN', 'Quênia');
INSERT INTO gold.dim_pai VALUES (40, 'IRL', 'Irlanda');
INSERT INTO gold.dim_pai VALUES (41, 'SWE', 'Suécia');
INSERT INTO gold.dim_pai VALUES (42, 'NGA', 'Nigéria');
INSERT INTO gold.dim_pai VALUES (43, 'GRC', 'Grécia');
INSERT INTO gold.dim_pai VALUES (44, 'SGP', 'Singapura');
INSERT INTO gold.dim_pai VALUES (45, 'IND', 'Índia');
INSERT INTO gold.dim_pai VALUES (46, 'HKG', 'Hong Kong');
INSERT INTO gold.dim_pai VALUES (47, 'BEL', 'Bélgica');
INSERT INTO gold.dim_pai VALUES (48, 'CHN', 'China');
INSERT INTO gold.dim_pai VALUES (49, 'IDN', 'Indonésia');
INSERT INTO gold.dim_pai VALUES (50, 'DEU', 'Alemanha');
INSERT INTO gold.dim_pai VALUES (51, 'JPN', 'Japão');
INSERT INTO gold.dim_pai VALUES (52, 'CHE', 'Suíça');
INSERT INTO gold.dim_pai VALUES (53, 'CZE', 'República Tcheca');
INSERT INTO gold.dim_pai VALUES (54, 'PHL', 'Filipinas');
INSERT INTO gold.dim_pai VALUES (55, 'EGY', 'Egito');


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 283
-- Name: dim_pai_srk_pai_seq; Type: SEQUENCE SET; Schema: gold; Owner: airflow
--

SELECT pg_catalog.setval('gold.dim_pai_srk_pai_seq', 55, true);


--
-- TOC entry 3427 (class 2606 OID 17142)
-- Name: dim_pai dim_pai_cod_pai_key; Type: CONSTRAINT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_pai
    ADD CONSTRAINT dim_pai_cod_pai_key UNIQUE (cod_pai);


--
-- TOC entry 3429 (class 2606 OID 17140)
-- Name: dim_pai dim_pai_pkey; Type: CONSTRAINT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_pai
    ADD CONSTRAINT dim_pai_pkey PRIMARY KEY (srk_pai);


-- Completed on 2025-11-24 20:10:45 -03

--
-- PostgreSQL database dump complete
--

