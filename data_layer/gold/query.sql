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
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
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
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE p.cod_pai = 'BRA'
  AND i.cod_ind IN ('tl_afr/iip/l_p', 'pop/dm/ps')
GROUP BY t.num_ano, p.nom_pai
HAVING MAX(CASE WHEN i.cod_ind = 'tl_afr/iip/l_p' THEN f.vlr_obs END) IS NOT NULL
ORDER BY t.num_ano DESC;


-- =============================================================================
-- 11. Evolução da Posição de Investimento Internacional (NIIP) por País
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    f.vlr_obs AS valor_niip
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind = 'niip/iip/netal_p'
  AND p.cod_pai IN ('USA', 'BRA', 'IND', 'CHN', 'DEU')
  AND t.cod_per >= '2022-Q1'
ORDER BY t.cod_per, p.cod_pai;


-- =============================================================================
-- 12. Evolução dos Ativos e Passivos Externos Totais (EUA e Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'ta_afr/iip/a_p' THEN f.vlr_obs END) AS ativos_totais,
    MAX(CASE WHEN i.cod_ind = 'tl_afr/iip/l_p' THEN f.vlr_obs END) AS passivos_totais
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('ta_afr/iip/a_p', 'tl_afr/iip/l_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA' para o Brasil
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 13. Composição dos Ativos Externos
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd/iip/a_p' THEN f.vlr_obs END) AS inv_direto,
    MAX(CASE WHEN i.cod_ind = 'p_mv/iip/a_p' THEN f.vlr_obs END) AS inv_portfolio,
    MAX(CASE WHEN i.cod_ind = 'o_fl1/iip/a_p' THEN f.vlr_obs END) AS outros_investimentos,
    MAX(CASE WHEN i.cod_ind = 'r/iip/a_p' THEN f.vlr_obs END) AS reservas
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d/iip/a_p', 'p_mv/iip/a_p', 'o_fl1/iip/a_p', 'r/iip/a_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 14. Detalhamento do Investimento Direto (Ativos)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd_f5/iip/a_p' THEN f.vlr_obs END) AS inv_direto_equity,
    MAX(CASE WHEN i.cod_ind = 'd_fl/iip/a_p' THEN f.vlr_obs END) AS inv_direto_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d_f5/iip/a_p', 'd_fl/iip/a_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 15. Detalhamento do Investimento em Portfólio (Ativos)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'p_f5_mv/iip/a_p' THEN f.vlr_obs END) AS portfolio_equity,
    MAX(CASE WHEN i.cod_ind = 'p_f3_mv/iip/a_p' THEN f.vlr_obs END) AS portfolio_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('p_f5_mv/iip/a_p', 'p_f3_mv/iip/a_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 16. Composição dos Passivos Externos
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd/iip/l_p' THEN f.vlr_obs END) AS inv_direto,
    MAX(CASE WHEN i.cod_ind = 'p_mv/iip/l_p' THEN f.vlr_obs END) AS inv_portfolio,
    MAX(CASE WHEN i.cod_ind = 'o_f4_nv/iip/l_p' THEN f.vlr_obs END) AS outros_emprestimos,
    MAX(CASE WHEN i.cod_ind = 'o_f2_nv/iip/l_p' THEN f.vlr_obs END) AS outros_moeda_depositos,
    MAX(CASE WHEN i.cod_ind = 'o_f81/iip/l_p' THEN f.vlr_obs END) AS outros_outros
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d/iip/l_p', 'p_mv/iip/l_p', 'o_f4_nv/iip/l_p', 'o_f2_nv/iip/l_p', 'o_f81/iip/l_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 17. Detalhamento do Investimento Direto (Passivos)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd_f5/iip/l_p' THEN f.vlr_obs END) AS inv_direto_equity,
    MAX(CASE WHEN i.cod_ind = 'd_fl/iip/l_p' THEN f.vlr_obs END) AS inv_direto_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d_f5/iip/l_p', 'd_fl/iip/l_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 18. Detalhamento do Investimento em Portfólio (Passivos)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'p_f5_mv/iip/l_p' THEN f.vlr_obs END) AS portfolio_equity,
    MAX(CASE WHEN i.cod_ind = 'p_f3_mv/iip/l_p' THEN f.vlr_obs END) AS portfolio_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('p_f5_mv/iip/l_p', 'p_f3_mv/iip/l_p')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 19. Composição dos Ativos Externos (Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd/iip/a_p' THEN f.vlr_obs END) AS inv_direto,
    MAX(CASE WHEN i.cod_ind = 'p_mv/iip/a_p' THEN f.vlr_obs END) AS inv_portfolio,
    MAX(CASE WHEN i.cod_ind = 'o_fl1/iip/a_p' THEN f.vlr_obs END) AS outros_investimentos,
    MAX(CASE WHEN i.cod_ind = 'r/iip/a_p' THEN f.vlr_obs END) AS reservas
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d/iip/a_p', 'p_mv/iip/a_p', 'o_fl1/iip/a_p', 'r/iip/a_p')
  AND p.cod_pai = 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 20. Detalhamento do Investimento Direto - Ativos (Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd_f5/iip/a_p' THEN f.vlr_obs END) AS inv_direto_equity,
    MAX(CASE WHEN i.cod_ind = 'd_fl/iip/a_p' THEN f.vlr_obs END) AS inv_direto_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d_f5/iip/a_p', 'd_fl/iip/a_p')
  AND p.cod_pai = 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 21. Detalhamento do Investimento em Portfólio - Ativos (Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'p_f5_mv/iip/a_p' THEN f.vlr_obs END) AS portfolio_equity,
    MAX(CASE WHEN i.cod_ind = 'p_f3_mv/iip/a_p' THEN f.vlr_obs END) AS portfolio_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('p_f5_mv/iip/a_p', 'p_f3_mv/iip/a_p')
  AND p.cod_pai = 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 22. Composição dos Passivos Externos (Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd/iip/l_p' THEN f.vlr_obs END) AS inv_direto,
    MAX(CASE WHEN i.cod_ind = 'p_mv/iip/l_p' THEN f.vlr_obs END) AS inv_portfolio,
    MAX(CASE WHEN i.cod_ind = 'o_f4_nv/iip/l_p' THEN f.vlr_obs END) AS outros_emprestimos,
    MAX(CASE WHEN i.cod_ind = 'o_f2_nv/iip/l_p' THEN f.vlr_obs END) AS outros_moeda_depositos,
    MAX(CASE WHEN i.cod_ind = 'o_f81/iip/l_p' THEN f.vlr_obs END) AS outros_outros
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d/iip/l_p', 'p_mv/iip/l_p', 'o_f4_nv/iip/l_p', 'o_f2_nv/iip/l_p', 'o_f81/iip/l_p')
  AND p.cod_pai = 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 23. Detalhamento do Investimento Direto - Passivos (Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'd_f5/iip/l_p' THEN f.vlr_obs END) AS inv_direto_equity,
    MAX(CASE WHEN i.cod_ind = 'd_fl/iip/l_p' THEN f.vlr_obs END) AS inv_direto_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('d_f5/iip/l_p', 'd_fl/iip/l_p')
  AND p.cod_pai = 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 24. Detalhamento do Investimento em Portfólio - Passivos (Brasil)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'p_f5_mv/iip/l_p' THEN f.vlr_obs END) AS portfolio_equity,
    MAX(CASE WHEN i.cod_ind = 'p_f3_mv/iip/l_p' THEN f.vlr_obs END) AS portfolio_debt
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('p_f5_mv/iip/l_p', 'p_f3_mv/iip/l_p')
  AND p.cod_pai = 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 25. Evolução da Conta Corrente (CAB) por País
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    f.vlr_obs AS conta_corrente
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind = 'cab/bop/netcd_t'
  AND p.cod_pai IN ('USA', 'BRA', 'IND', 'CHN', 'DEU')
  AND t.cod_per >= '2022-Q1'
ORDER BY t.cod_per, p.cod_pai;


-- =============================================================================
-- 26. Conta Corrente com e sem Eventos Extraordinários
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'cab/bop/netcd_t' THEN f.vlr_obs END) AS cab_total,
    MAX(CASE WHEN i.cod_ind = 'cabxef/bop/netcd_t' THEN f.vlr_obs END) AS cab_sem_extraordinarios
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('cab/bop/netcd_t', 'cabxef/bop/netcd_t')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 27. Decomposição da Conta Corrente (Bens/Serviços, Renda, Transferências)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'gs/bop/netcd_t' THEN f.vlr_obs END) AS bens_servicos,
    MAX(CASE WHEN i.cod_ind = 'in1/bop/netcd_t' THEN f.vlr_obs END) AS renda_primaria,
    MAX(CASE WHEN i.cod_ind = 'in2/bop/netcd_t' THEN f.vlr_obs END) AS renda_secundaria
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN ('gs/bop/netcd_t', 'in1/bop/netcd_t', 'in2/bop/netcd_t')
  AND p.cod_pai = 'USA' -- Alterar para 'BRA'
  AND t.cod_per >= '2022-Q1'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per;


-- =============================================================================
-- 28. Financiamento do Déficit (Entrada de Capitais / Passivos)
-- =============================================================================
WITH Financiamento_Deficit AS (
    SELECT 
        t.cod_per AS periodo,
        p.cod_pai AS pais,
        -- Investimento Direto (Passivo) - Soma de Equity e Debt se o agregado não existir
        SUM(CASE WHEN i.cod_ind IN ('d_f5/bop/l_nil_t', 'd_fl/bop/l_nil_t') THEN f.vlr_obs ELSE 0 END) AS inv_direto_passivo,
        -- Investimento Portfólio (Passivo) - Soma de Equity e Debt se o agregado não existir
        SUM(CASE WHEN i.cod_ind IN ('p_f5/bop/l_nil_t', 'p_f3/bop/l_nil_t') THEN f.vlr_obs ELSE 0 END) AS inv_portfolio_passivo,
        -- Outros componentes
        MAX(CASE WHEN i.cod_ind = 'o_f4/bop/l_nil_t' THEN f.vlr_obs END) AS outros_emprestimos,
        MAX(CASE WHEN i.cod_ind = 'o_f2/bop/l_nil_t' THEN f.vlr_obs END) AS outros_moeda_depositos,
        MAX(CASE WHEN i.cod_ind = 'o_f81/bop/l_nil_t' THEN f.vlr_obs END) AS outros_outros,
        MAX(CASE WHEN i.cod_ind = 'rue/bop/nnafanil_t' THEN f.vlr_obs END) AS reservas
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
    WHERE i.cod_ind IN (
        'd_f5/bop/l_nil_t', 'd_fl/bop/l_nil_t', -- Componentes de DXEF
        'p_f5/bop/l_nil_t', 'p_f3/bop/l_nil_t', -- Componentes de PXEF
        'o_f4/bop/l_nil_t', 'o_f2/bop/l_nil_t', 'o_f81/bop/l_nil_t', 'rue/bop/nnafanil_t'
    )
      AND p.cod_pai = 'USA' -- Alterar para 'BRA'
      AND t.cod_per >= '2022-Q1'
    GROUP BY t.cod_per, p.cod_pai
)
SELECT * FROM Financiamento_Deficit
ORDER BY periodo;


-- =============================================================================
-- 29. Saída de Capitais (Investimento no Exterior / Ativos)
-- =============================================================================
WITH Saida_Capitais AS (
    SELECT 
        t.cod_per AS periodo,
        p.cod_pai AS pais,
        -- Investimento Direto (Ativo)
        SUM(CASE WHEN i.cod_ind IN ('d_f5/bop/a_nfa_t', 'd_fl/bop/a_nfa_t') THEN f.vlr_obs ELSE 0 END) AS inv_direto_ativo,
        -- Investimento Portfólio (Ativo)
        SUM(CASE WHEN i.cod_ind IN ('p_f5/bop/a_nfa_t', 'p_f3/bop/a_nfa_t') THEN f.vlr_obs ELSE 0 END) AS inv_portfolio_ativo,
        -- Outros componentes
        MAX(CASE WHEN i.cod_ind = 'o_f4/bop/a_nfa_t' THEN f.vlr_obs END) AS outros_emprestimos,
        MAX(CASE WHEN i.cod_ind = 'o_f2/bop/a_nfa_t' THEN f.vlr_obs END) AS outros_moeda_depositos,
        MAX(CASE WHEN i.cod_ind = 'o_f81/bop/a_nfa_t' THEN f.vlr_obs END) AS outros_outros,
        MAX(CASE WHEN i.cod_ind = 'rue/bop/nnafanil_t' THEN f.vlr_obs END) AS reservas
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
    WHERE i.cod_ind IN (
        'd_f5/bop/a_nfa_t', 'd_fl/bop/a_nfa_t',
        'p_f5/bop/a_nfa_t', 'p_f3/bop/a_nfa_t',
        'o_f4/bop/a_nfa_t', 'o_f2/bop/a_nfa_t', 'o_f81/bop/a_nfa_t', 'rue/bop/nnafanil_t'
    )
      AND p.cod_pai = 'USA' -- Alterar para 'BRA'
      AND t.cod_per >= '2022-Q1'
    GROUP BY t.cod_per, p.cod_pai
)
SELECT * FROM Saida_Capitais
ORDER BY periodo;


-- =============================================================================
-- 30. Composição e Nível das Reservas
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl65_usd_irfcl13' THEN f.vlr_obs END) AS total_reservas,
    MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl56_usd_irfcl13' THEN f.vlr_obs END) AS ouro,
    MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl32_usd_irfcl13' THEN f.vlr_obs END) AS titulos,
    MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfclcdcfc_usd_irfcl13' THEN f.vlr_obs END) AS moeda_depositos,
    MAX(CASE WHEN i.cod_ind = 'irfcldt2_usd_irfcl13' THEN f.vlr_obs END) AS drenos_curto_prazo
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN (
    'irfcldt1_irfcl65_usd_irfcl13', 
    'irfcldt1_irfcl56_usd_irfcl13', 
    'irfcldt1_irfcl32_usd_irfcl13', 
    'irfcldt1_irfclcdcfc_usd_irfcl13', 
    'irfcldt2_usd_irfcl13'
)
  AND p.cod_pai IN ('USA', 'BRA', 'IND', 'CHN', 'DEU')
  AND t.cod_per >= '2022-01' -- Ajustar conforme a granularidade (mensal/trimestral)
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per, p.cod_pai;


-- =============================================================================
-- 31. Crescimento das Reservas (YoY - Year over Year)
-- =============================================================================
WITH reserves AS (
    SELECT 
        t.cod_per AS periodo,
        p.cod_pai AS pais,
        f.vlr_obs AS total_reservas,
        LAG(f.vlr_obs, 4) OVER (PARTITION BY p.cod_pai ORDER BY t.cod_per) AS reservas_ano_anterior
    FROM gold.fat_obs_eco f
    JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
    JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
    JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
    WHERE i.cod_ind = 'irfcldt1_irfcl65_usd_irfcl13'
      AND p.cod_pai IN ('USA', 'BRA', 'IND', 'CHN', 'DEU')
)
SELECT 
    periodo,
    pais,
    total_reservas,
    reservas_ano_anterior,
    ((total_reservas - reservas_ano_anterior) / NULLIF(reservas_ano_anterior, 0)) * 100 AS crescimento_yoy_pct
FROM reserves
WHERE periodo >= '2022-01'
ORDER BY periodo, pais;


-- =============================================================================
-- 32. Adequação das Reservas (Liquidez e Cobertura)
-- =============================================================================
SELECT 
    t.cod_per AS periodo,
    p.cod_pai AS pais,
    MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl65_usd_irfcl13' THEN f.vlr_obs END) AS total_reservas,
    MAX(CASE WHEN i.cod_ind = 'irfcldt2_usd_irfcl13' THEN f.vlr_obs END) AS drenos_curto_prazo,
    -- Liquidez = Títulos + Moeda
    (MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl32_usd_irfcl13' THEN f.vlr_obs ELSE 0 END) + 
     MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfclcdcfc_usd_irfcl13' THEN f.vlr_obs ELSE 0 END)) AS ativos_liquidos,
    -- Cobertura = Reservas / Drenos
    MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl65_usd_irfcl13' THEN f.vlr_obs END) / 
    NULLIF(MAX(CASE WHEN i.cod_ind = 'irfcldt2_usd_irfcl13' THEN f.vlr_obs END), 0) AS indice_cobertura,
    -- Liquidez / Drenos
    (MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfcl32_usd_irfcl13' THEN f.vlr_obs ELSE 0 END) + 
     MAX(CASE WHEN i.cod_ind = 'irfcldt1_irfclcdcfc_usd_irfcl13' THEN f.vlr_obs ELSE 0 END)) /
    NULLIF(MAX(CASE WHEN i.cod_ind = 'irfcldt2_usd_irfcl13' THEN f.vlr_obs END), 0) AS indice_liquidez_drenos
FROM gold.fat_obs_eco f
JOIN gold.dim_pai p ON f.srk_pai = p.srk_pai
JOIN gold.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN gold.dim_ind i ON f.srk_ind = i.srk_ind
WHERE i.cod_ind IN (
    'irfcldt1_irfcl65_usd_irfcl13', 
    'irfcldt2_usd_irfcl13',
    'irfcldt1_irfcl32_usd_irfcl13',
    'irfcldt1_irfclcdcfc_usd_irfcl13'
)
  AND p.cod_pai IN ('USA', 'BRA', 'IND', 'CHN', 'DEU')
  AND t.cod_per >= '2022-01'
GROUP BY t.cod_per, p.cod_pai
ORDER BY t.cod_per, p.cod_pai;
