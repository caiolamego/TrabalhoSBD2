--
-- PostgreSQL database dump
--

-- Dumped from database version 15.14
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg22.04+2)

-- Started on 2025-11-24 20:10:29 -03

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
-- TOC entry 288 (class 1259 OID 17153)
-- Name: dim_ind; Type: TABLE; Schema: gold; Owner: airflow
--

CREATE TABLE gold.dim_ind (
    srk_ind integer NOT NULL,
    cod_ind character varying(100) NOT NULL,
    nom_ind character varying(255),
    nom_fnt character varying(50),
    des_cat character varying(100)
);


ALTER TABLE gold.dim_ind OWNER TO airflow;

--
-- TOC entry 287 (class 1259 OID 17152)
-- Name: dim_ind_srk_ind_seq; Type: SEQUENCE; Schema: gold; Owner: airflow
--

CREATE SEQUENCE gold.dim_ind_srk_ind_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gold.dim_ind_srk_ind_seq OWNER TO airflow;

--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 287
-- Name: dim_ind_srk_ind_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: airflow
--

ALTER SEQUENCE gold.dim_ind_srk_ind_seq OWNED BY gold.dim_ind.srk_ind;


--
-- TOC entry 3425 (class 2604 OID 17156)
-- Name: dim_ind srk_ind; Type: DEFAULT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_ind ALTER COLUMN srk_ind SET DEFAULT nextval('gold.dim_ind_srk_ind_seq'::regclass);


--
-- TOC entry 3573 (class 0 OID 17153)
-- Dependencies: 288
-- Data for Name: dim_ind; Type: TABLE DATA; Schema: gold; Owner: airflow
--

INSERT INTO gold.dim_ind VALUES (1, 'unit/bop', 'Indicador - unit/bop', 'Desconhecida', 'Desconhecida');
INSERT INTO gold.dim_ind VALUES (2, 'cab/bop/netcd_t', 'Conta Corrente, Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (3, 'cabxef/bop/netcd_t', 'Conta Corrente (Excl. Financiamento Excepcional), Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (4, 'dxef/bop/l_nil_t', 'Investimento Direto (Excl. Financ. Excepcional), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (5, 'd_f5/bop/a_nfa_t', 'Invest. Direto (Derivativos Financ.), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (6, 'd_f5/bop/l_nil_t', 'Invest. Direto (Derivativos Financ.), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (7, 'd_fl/bop/a_nfa_t', 'Invest. Direto (Ações e Títulos), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (8, 'd_fl/bop/l_nil_t', 'Invest. Direto (Ações e Títulos), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (9, 'eo/bop/netcd_t', 'Erros e Omissões, Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (10, 'fab/bop/nnafanil_t', 'Conta Financeira, Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (11, 'fabxrri/bop/nnafanil_t', 'Conta Financeira (Excl. Reservas), Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (12, 'gs/bop/cd_t', 'Bens e Serviços, Crédito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (13, 'd_f5/iip/l_p', 'Invest. Direto (Derivativos Financ.), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (14, 'd_fl/iip/a_p', 'Invest. Direto (Ações e Títulos), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (15, 'd_fl/iip/l_p', 'Invest. Direto (Ações e Títulos), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (16, 'niip/iip/netal_p', 'Posição de Investimento Internacional Líquida (NIIP)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (17, 'o_f12/iip/l_p', 'Outros Investimentos (Alocação SDR), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (18, 'o_f2_nv/iip/a_p', 'Outros Investimentos (Moeda e Depósitos), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (19, 'o_f2_nv/iip/l_p', 'Outros Investimentos (Moeda e Depósitos), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (20, 'o_f4_nv/iip/a_p', 'Outros Investimentos (Títulos de Dívida), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (21, 'o_f4_nv/iip/l_p', 'Outros Investimentos (Títulos de Dívida), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (22, 'o_f81/iip/a_p', 'Outros Investimentos (Créditos Comerciais), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (23, 'o_f81/iip/l_p', 'Outros Investimentos (Créditos Comerciais), Passivo', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (24, 'o_fl1/iip/a_p', 'Outros Investimentos (Empréstimos), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (25, 'irfcldt1_irfcl32_usd_irfcl13', 'Títulos nas Reservas', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (26, 'irfcldt1_irfcl54_usd_irfcl13', 'Reservas Oficiais + Outros Ativos FX', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (27, 'irfcldt1_irfcl56_usd_irfcl13', 'Ouro nas Reservas', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (28, 'irfcldt1_irfcl57_usd_irfcl13', 'Posição de Reservas no FMI', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (29, 'irfcldt1_irfcl65_dic_xdr_usd_irfcl13', 'SDR (Holdings) nas Reservas', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (30, 'irfcldt1_irfcl65_usd_irfcl13', 'Reservas Oficiais (Total)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (31, 'irfcldt1_irfclcdcfc_usd_irfcl13', 'Moeda e Depósitos nas Reservas', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (32, 'irfcldt2_irfcl151_sm1mut3m_fo_usd_irfcl13', 'Drenagens: Juros (1-3 Meses)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (33, 'irfcldt2_irfcl151_sm3muty_fo_usd_irfcl13', 'Drenagens: Juros (3-12 Meses)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (34, 'irfcldt2_irfcl151_sutm_fo_usd_irfcl13', 'Drenagens: Juros (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (35, 'irfcldt2_irfcl1_sutm_in_lp_usd_irfcl13', 'Drenagens: Entradas Forwards (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (36, 'irfcldt2_irfcl1_sutm_shp_usd_irfcl13', 'Drenagens: Saídas Forwards (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (37, 'gs/bop/db_t', 'Bens e Serviços, Débito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (38, 'gs/bop/netcd_t', 'Bens e Serviços, Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (39, 'in1/bop/cd_t', 'Renda Primária, Crédito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (40, 'in1/bop/db_t', 'Renda Primária, Débito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (41, 'in1/bop/netcd_t', 'Renda Primária, Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (42, 'in2/bop/cd_t', 'Renda Secundária, Crédito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (43, 'in2/bop/db_t', 'Renda Secundária, Débito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (44, 'in2/bop/netcd_t', 'Renda Secundária, Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (45, 'kab/bop/netcd_t', 'Conta Capital, Líquida', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (46, 'o_f2/bop/a_nfa_t', 'Outros Investimentos (Moeda e Depósitos), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (47, 'o_f2/bop/l_nil_t', 'Outros Investimentos (Moeda e Depósitos), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (48, 'o_f2/bop/nnafanil_t', 'Outros Investimentos (Moeda e Depósitos), Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (49, 'o_f4/bop/a_nfa_t', 'Outros Investimentos (Títulos de Dívida), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (50, 'o_f4/bop/l_nil_t', 'Outros Investimentos (Títulos de Dívida), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (51, 'o_f4/bop/nnafanil_t', 'Outros Investimentos (Títulos de Dívida), Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (52, 'o_f81/bop/a_nfa_t', 'Outros Investimentos (Créditos Comerciais), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (53, 'o_f81/bop/l_nil_t', 'Outros Investimentos (Créditos Comerciais), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (54, 'o_f81/bop/nnafanil_t', 'Outros Investimentos (Créditos Comerciais), Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (55, 'pxef/bop/l_nil_t', 'Invest. Carteira (Excl. Financ. Excepcional), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (56, 'p_f3/bop/a_nfa_t', 'Invest. Carteira (Títulos de Dívida), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (57, 'p_f3/bop/l_nil_t', 'Invest. Carteira (Títulos de Dívida), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (58, 'p_f5/bop/a_nfa_t', 'Invest. Carteira (Ações), Ativo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (59, 'p_f5/bop/l_nil_t', 'Invest. Carteira (Ações), Passivo', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (60, 'rue/bop/nnafanil_t', 'Ativos de Reserva, Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (61, 'r_f/bop/a_t', 'Ativos de Reserva (Ativos Totais)', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (62, 'sf/bop/cd_t', 'Serviços, Crédito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (63, 'sf/bop/db_t', 'Serviços, Débito', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (64, 'sf/bop/netcd_t', 'Serviços, Líquido', 'BOP', 'Balanço de Pagamentos');
INSERT INTO gold.dim_ind VALUES (65, 'type_of_transformation/er', 'Indicador - type_of_transformation/er', 'Desconhecida', 'Desconhecida');
INSERT INTO gold.dim_ind VALUES (66, 'xdc_eur', 'Taxa de Câmbio (Moeda Local por EUR)', 'ER', 'Taxa de Câmbio');
INSERT INTO gold.dim_ind VALUES (67, 'xdc_usd', 'Taxa de Câmbio (Moeda Local por USD)', 'ER', 'Taxa de Câmbio');
INSERT INTO gold.dim_ind VALUES (68, 'xdc_xdr', 'Taxa de Câmbio (Moeda Local por XDR)', 'ER', 'Taxa de Câmbio');
INSERT INTO gold.dim_ind VALUES (69, 'unit/iip', 'Indicador - unit/iip', 'Desconhecida', 'Desconhecida');
INSERT INTO gold.dim_ind VALUES (70, 'd/iip/a_p', 'Investimento Direto, Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (71, 'd/iip/l_p', 'Investimento Direto, Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (72, 'd_f5/iip/a_p', 'Invest. Direto (Derivativos Financ.), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (73, 'irfcldt2_irfcl24_sm1mut3m_usd_irfcl13', 'Drenagens: Total (1-3 Meses)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (74, 'irfcldt2_irfcl24_sm3muty_usd_irfcl13', 'Drenagens: Total (3-12 Meses)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (75, 'irfcldt2_irfcl24_sutm_usd_irfcl13', 'Drenagens: Total (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (76, 'irfcldt2_irfcl26_sm1mut3m_fo_usd_irfcl13', 'Drenagens: Principal (1-3 Meses)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (77, 'irfcldt2_irfcl26_sm3muty_fo_usd_irfcl13', 'Drenagens: Principal (3-12 Meses)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (78, 'irfcldt2_irfcl26_sutm_fo_usd_irfcl13', 'Drenagens: Principal (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (79, 'irfcldt2_usd_irfcl13', 'Drenagens Líquidas de Curto Prazo (Total)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (80, 'irfcldt4_irfcl11_dic_xdrb_usd_irfcl13', 'Memo: Moedas da Cesta SDR', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (81, 'irfcldt4_irfcl11_dic_xxdr_usd_irfcl13', 'Memo: Moedas Fora da Cesta SDR', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (82, 'irfcldt4_irfcl68_usd_irfcl13', 'Memo: Títulos Cedidos/em Repo', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (83, 'irfcldt4_irfcl69x_usd_irfcl13', 'Memo: Títulos Cedidos (Não Incl. Seção I)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (84, 'irfcldt4_irfclu97_a_usd_irfcl13', 'Memo: Derivativos (Net MTM)', 'IRFCL', 'Reservas Internacionais');
INSERT INTO gold.dim_ind VALUES (85, 'fert_ratio/dm/br_l_w', 'Taxa de Fertilidade', 'DM', 'Demografia');
INSERT INTO gold.dim_ind VALUES (86, 'lfexp/dm/y', 'Expectativa de Vida', 'DM', 'Demografia');
INSERT INTO gold.dim_ind VALUES (87, 'mort/dm/dt', 'Taxa de Mortalidade', 'DM', 'Demografia');
INSERT INTO gold.dim_ind VALUES (88, 'pop/dm/ps', 'População Total', 'DM', 'Demografia');
INSERT INTO gold.dim_ind VALUES (89, 'p_f3_mv/iip/a_p', 'Invest. Carteira (Títulos de Dívida), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (90, 'p_f3_mv/iip/l_p', 'Invest. Carteira (Títulos de Dívida), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (91, 'p_f5_mv/iip/a_p', 'Invest. Carteira (Ações), Ativos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (92, 'p_f5_mv/iip/l_p', 'Invest. Carteira (Ações), Passivos', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (93, 'p_mv/iip/a_p', 'Investimento em Carteira, Ativos (Total)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (94, 'p_mv/iip/l_p', 'Investimento em Carteira, Passivos (Total)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (95, 'r/iip/a_p', 'Ativos de Reserva (Total)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (96, 'r_f11_mv/iip/a_p', 'Reservas (Ouro Monetário)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (97, 'r_f12_mv/iip/a_p', 'Reservas (SDRs)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (98, 'r_fk_mv/iip/a_p', 'Reservas (Outros Ativos)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (99, 'ta_afr/iip/a_p', 'Total Ativos (Excl. Reservas)', 'IIP', 'Posição de Investimento');
INSERT INTO gold.dim_ind VALUES (100, 'tl_afr/iip/l_p', 'Total Passivos', 'IIP', 'Posição de Investimento');


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 287
-- Name: dim_ind_srk_ind_seq; Type: SEQUENCE SET; Schema: gold; Owner: airflow
--

SELECT pg_catalog.setval('gold.dim_ind_srk_ind_seq', 100, true);


--
-- TOC entry 3427 (class 2606 OID 17162)
-- Name: dim_ind dim_ind_cod_ind_key; Type: CONSTRAINT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_ind
    ADD CONSTRAINT dim_ind_cod_ind_key UNIQUE (cod_ind);


--
-- TOC entry 3429 (class 2606 OID 17160)
-- Name: dim_ind dim_ind_pkey; Type: CONSTRAINT; Schema: gold; Owner: airflow
--

ALTER TABLE ONLY gold.dim_ind
    ADD CONSTRAINT dim_ind_pkey PRIMARY KEY (srk_ind);


-- Completed on 2025-11-24 20:10:29 -03

--
-- PostgreSQL database dump complete
--

