/*
    ARQUIVO: query.sql
    OBJETIVO: 10 Consultas Focadas em Dívida e Solvência para Power BI
    PÚBLICO: Executivos e Analistas não-economistas.
    ESTRUTURA: 6 CTEs + 4 Consultas Diretas.
*/

-- =============================================================================
-- 1. [CTE] O Brasil deve mais do que tem? (Posição Líquida - NIIP)
-- EXPLICAÇÃO: Imagine o "Patrimônio Líquido" do país.
-- Se for negativo, o país deve mais ao mundo do que tem de ativos lá fora.
-- =============================================================================
WITH Patrimonio_Internacional AS (
    SELECT 
        t.num_ano,
        t.cod_per,
        f.vlr_obs
    FROM gold.FAT_OBS_ECO f
    JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
    JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
    JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
    WHERE p.cod_pai = 'BRA'
      AND i.cod_ind = 'niip/iip/netal_p' -- Posição de Investimento Internacional Líquida
)
SELECT 
    num_ano,
    cod_per,
    vlr_obs AS Saldo_Liquido_USD,
    CASE 
        WHEN vlr_obs < 0 THEN 'Devedor Líquido (Devemos mais)'
        ELSE 'Credor Líquido (Temos mais haveres)'
    END AS Status_Pais
FROM Patrimonio_Internacional
ORDER BY num_ano DESC;


-- =============================================================================
-- 2. [CTE] A "Fatura" da Dívida: Juros Pagos ao Exterior
-- EXPLICAÇÃO: Quanto dinheiro sai do país só para pagar juros de dívidas?
-- É como ver o extrato do cartão de crédito e somar apenas os juros pagos.
-- =============================================================================
WITH Pagamento_Juros AS (
    SELECT 
        t.num_ano,
        t.cod_per,
        f.vlr_obs
    FROM gold.FAT_OBS_ECO f
    JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
    JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
    JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
    WHERE p.cod_pai = 'BRA'
      AND i.cod_ind = 'in1/bop/db_t' -- Renda Primária (Débito) - Juros e Lucros enviados
)
SELECT 
    num_ano,
    cod_per,
    ABS(vlr_obs) AS Juros_Lucros_Pagos_USD -- Usamos ABS para mostrar positivo no gráfico
FROM Pagamento_Juros
ORDER BY num_ano DESC;


-- =============================================================================
-- 3. [CTE] Composição da Dívida: Quem são nossos credores?
-- EXPLICAÇÃO: Quebra a dívida em tipos.
-- "Matriz/Filial" (Dívida estável entre empresas).
-- "Mercado Financeiro" (Títulos/Bonds - mais volátil).
-- "Bancos/Empréstimos" (Dívida bancária tradicional).
-- =============================================================================
WITH Detalhe_Divida AS (
    SELECT 
        t.num_ano,
        i.cod_ind,
        f.vlr_obs
    FROM gold.FAT_OBS_ECO f
    JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
    JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
    JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
    WHERE p.cod_pai = 'BRA'
      AND t.num_ano = 2023 -- Foco no ano recente para gráfico de Pizza/Rosca
      AND i.cod_ind IN (
          'd_fl/iip/l_p',    -- Investimento Direto: Dívida (Intercompany)
          'p_f3_mv/iip/l_p', -- Investimento em Carteira: Títulos de Dívida (Bonds)
          'o_fl1/iip/a_p'    -- Outros Investimentos: Empréstimos (Proxy usada, ajustar se L_P disponível)
      )
)
SELECT 
    num_ano,
    CASE 
        WHEN cod_ind = 'd_fl/iip/l_p' THEN 'Dívida com Matrizes (Intercompany)'
        WHEN cod_ind = 'p_f3_mv/iip/l_p' THEN 'Títulos de Dívida (Mercado)'
        ELSE 'Empréstimos Bancários e Outros'
    END AS Tipo_Divida,
    vlr_obs AS Valor_USD
FROM Detalhe_Divida
ORDER BY vlr_obs DESC;


-- =============================================================================
-- 4. [CTE] Temos Dólar suficiente no cofre? (Reservas vs Dívida Curto Prazo)
-- EXPLICAÇÃO: O indicador de segurança máxima.
-- Compara o dinheiro que temos no cofre (Reservas) com as contas que vencem em menos de 1 ano.
-- Se o índice for maior que 1, estamos seguros. Se menor, alerta vermelho.
-- =============================================================================
WITH Analise_Solvencia AS (
    SELECT 
        t.num_ano,
        t.cod_per,
        SUM(CASE WHEN i.cod_ind = 'irfcldt1_irfcl65_usd_irfcl13' THEN f.vlr_obs ELSE 0 END) AS Dinheiro_No_Cofre,
        SUM(CASE WHEN i.cod_ind = 'irfcldt2_usd_irfcl13' THEN f.vlr_obs ELSE 0 END) AS Contas_Vencendo_1Ano
    FROM gold.FAT_OBS_ECO f
    JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
    JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
    JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
    WHERE p.cod_pai = 'BRA'
      AND i.cod_ind IN ('irfcldt1_irfcl65_usd_irfcl13', 'irfcldt2_usd_irfcl13')
    GROUP BY t.num_ano, t.cod_per
)
SELECT 
    num_ano,
    cod_per,
    Dinheiro_No_Cofre,
    ABS(Contas_Vencendo_1Ano) AS Divida_Curto_Prazo,
    (Dinheiro_No_Cofre / NULLIF(ABS(Contas_Vencendo_1Ano), 0)) AS Indice_Seguranca_Liquidez
FROM Analise_Solvencia
WHERE Dinheiro_No_Cofre > 0
ORDER BY num_ano DESC;


-- =============================================================================
-- 5. [CTE] Qualidade do Financiamento: Fábricas vs Especulação
-- EXPLICAÇÃO: Como o dinheiro entra no Brasil?
-- "Sócio" (IED): Vem para construir fábrica, ficar longo prazo. É bom.
-- "Especulador" (Portfólio): Vem ganhar juros e pode sair a qualquer momento. É risco.
-- =============================================================================
WITH Qualidade_Fluxo AS (
    SELECT 
        t.num_ano,
        -- IED (Investimento Direto)
        SUM(CASE WHEN i.cod_ind = 'dxef/bop/l_nil_t' THEN f.vlr_obs ELSE 0 END) AS Entrada_Socio_Fabrica,
        -- Portfólio (Investimento em Carteira)
        SUM(CASE WHEN i.cod_ind = 'pxef/bop/l_nil_t' THEN f.vlr_obs ELSE 0 END) AS Entrada_Especulativa
    FROM gold.FAT_OBS_ECO f
    JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
    JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
    JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
    WHERE p.cod_pai = 'BRA'
      AND i.cod_ind IN ('dxef/bop/l_nil_t', 'pxef/bop/l_nil_t')
    GROUP BY t.num_ano
)
SELECT 
    num_ano,
    Entrada_Socio_Fabrica,
    Entrada_Especulativa,
    CASE 
        WHEN Entrada_Socio_Fabrica > Entrada_Especulativa THEN 'Fluxo Saudável (Mais IED)'
        ELSE 'Fluxo Volátil (Mais Portfólio)'
    END AS Analise_Qualidade
FROM Qualidade_Fluxo
ORDER BY num_ano DESC;


-- =============================================================================
-- 6. [CTE] Dívida Total Comparada (Brasil vs Vizinhos e Emergentes)
-- EXPLICAÇÃO: Quem deve mais em valores absolutos?
-- Compara o Passivo Externo Total (Tudo que o país deve lá fora).
-- =============================================================================
WITH Comparativo_Divida AS (
    SELECT 
        p.nom_pai,
        t.num_ano,
        MAX(f.vlr_obs) AS Divida_Total_Externa
    FROM gold.FAT_OBS_ECO f
    JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
    JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
    JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
    WHERE i.cod_ind = 'tl_afr/iip/l_p' -- Total Liabilities (Passivo Total)
      AND p.cod_pai IN ('BRA', 'MEX', 'ARG', 'ZAF', 'IND', 'RUS') -- Países comparáveis
    GROUP BY p.nom_pai, t.num_ano
)
SELECT 
    nom_pai,
    num_ano,
    Divida_Total_Externa
FROM Comparativo_Divida
ORDER BY Divida_Total_Externa DESC;


-- =============================================================================
-- 7. A Poupança Nacional (Reservas Internacionais)
-- EXPLICAÇÃO: Gráfico de Linha simples.
-- Mostra se estamos acumulando ou queimando nossas reservas ("guardando dinheiro").
-- =============================================================================
SELECT 
    t.num_ano,
    t.cod_per,
    p.nom_pai,
    f.vlr_obs AS Reservas_USD
FROM gold.FAT_OBS_ECO f
JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
WHERE p.cod_pai = 'BRA'
  AND i.cod_ind = 'irfcldt1_irfcl65_usd_irfcl13' -- Reservas Oficiais Totais
ORDER BY t.num_ano, t.cod_per;


-- =============================================================================
-- 8. Conta Corrente: O País gastou mais do que ganhou?
-- EXPLICAÇÃO: Se negativo (Déficit), o país consumiu mais produtos/serviços do mundo
-- do que vendeu. Esse "buraco" precisa ser financiado (gerando dívida ou atraindo sócios).
-- =============================================================================
SELECT 
    t.num_ano,
    t.cod_per,
    f.vlr_obs AS Saldo_Conta_Corrente_USD
FROM gold.FAT_OBS_ECO f
JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
WHERE p.cod_pai = 'BRA'
  AND i.cod_ind = 'cab/bop/netcd_t'
ORDER BY t.num_ano DESC;


-- =============================================================================
-- 9. Preço do Dólar (Cotação)
-- EXPLICAÇÃO: Quantos Reais custa 1 Dólar?
-- Impacta diretamente o valor da dívida quando convertida para moeda local.
-- =============================================================================
SELECT 
    t.num_ano,
    t.cod_per,
    f.vlr_obs AS Taxa_Cambio_BRL_por_USD
FROM gold.FAT_OBS_ECO f
JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
WHERE p.cod_pai = 'BRA'
  AND i.cod_ind = 'xdc_usd'
ORDER BY t.num_ano, t.cod_per;


-- =============================================================================
-- 10. Dívida por Pessoa (Per Capita)
-- EXPLICAÇÃO: Se dividíssemos tudo que o país deve lá fora por cada habitante,
-- quanto cada brasileiro "deveria"? Ajuda a dar dimensão ao número gigante.
-- =============================================================================
SELECT 
    t.num_ano,
    p.nom_pai,
    -- Dívida Total (Passivos) / População
    MAX(CASE WHEN i.cod_ind = 'tl_afr/iip/l_p' THEN f.vlr_obs END) / 
    NULLIF(MAX(CASE WHEN i.cod_ind = 'pop/dm/ps' THEN f.vlr_obs END), 0) AS Divida_Externa_Por_Habitante_USD
FROM gold.FAT_OBS_ECO f
JOIN gold.DIM_PAI p ON f.srk_pai = p.srk_pai
JOIN gold.DIM_TMP t ON f.srk_tmp = t.srk_tmp
JOIN gold.DIM_IND i ON f.srk_ind = i.srk_ind
WHERE p.cod_pai = 'BRA'
  AND i.cod_ind IN ('tl_afr/iip/l_p', 'pop/dm/ps')
GROUP BY t.num_ano, p.nom_pai
HAVING MAX(CASE WHEN i.cod_ind = 'tl_afr/iip/l_p' THEN f.vlr_obs END) IS NOT NULL
ORDER BY t.num_ano DESC;