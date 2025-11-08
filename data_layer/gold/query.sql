-- CONSULTA 1: Série Temporal da Conta Corrente (BOP) para o G7 (USD)
-- Objetivo: Ver a evolução da balança comercial para as principais economias.
WITH G5_Paises AS (
    SELECT SRK_Pais, Nome_Pais
    FROM DW.Dim_Pais
    WHERE Codigo_Pais IN ('USA', 'CHN', 'JPN', 'DEU', 'GBR', 'FRA', 'ITA')
),
Indicador_ContaCorrente AS (
    SELECT SRK_Indicador
    FROM DW.Dim_Indicador
    WHERE Codigo_Indicador = 'CAB/BOP/NETCD_T'
),
Periodos_Ultimos_10_Anos AS (
    SELECT SRK_Tempo, Periodo_Completo, Ano
    FROM DW.Dim_Tempo
    WHERE Ano >= (SELECT MAX(Ano) FROM DW.Dim_Tempo) - 10
)
SELECT
    p.Nome_Pais,
    t.Periodo_Completo,
    f.Valor
FROM DW.Fato_ObservacaoEconomica f
JOIN G5_Paises p ON f.SRK_Pais = p.SRK_Pais
JOIN Indicador_ContaCorrente i ON f.SRK_Indicador = i.SRK_Indicador
JOIN Periodos_Ultimos_10_Anos t ON f.SRK_Tempo = t.SRK_Tempo
ORDER BY
    p.Nome_Pais,
    t.Periodo_Completo;

---

-- CONSULTA 2: Ranking de Reservas Internacionais (IRFCL) no Último Período
-- Objetivo: Ver quais países têm as maiores reservas (colchão de liquidez).
WITH Ultimo_Periodo AS (
    -- Encontra o período mais recente na tabela de fatos
    SELECT MAX(t.SRK_Tempo) AS Max_SRK_Tempo
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Tempo t ON f.SRK_Tempo = t.SRK_Tempo
),
Indicador_Reservas AS (
    SELECT SRK_Indicador
    FROM DW.Dim_Indicador
    WHERE Codigo_Indicador = 'IRFCLDT1_IRFCL65_USD_IRFCL13'
)
SELECT
    p.Nome_Pais,
    (f.Valor / 1000000000) AS Valor_em_Bilhoes_USD 
FROM DW.Fato_ObservacaoEconomica f
JOIN DW.Dim_Pais p ON f.SRK_Pais = p.SRK_Pais
JOIN Indicador_Reservas i ON f.SRK_Indicador = i.SRK_Indicador
JOIN Ultimo_Periodo up ON f.SRK_Tempo = up.Max_SRK_Tempo
ORDER BY
    Valor_em_Bilhoes_USD DESC
LIMIT 20;

---

-- CONSULTA 3: Posição Líquida de Investimento (NIIP) vs Taxa de Câmbio (ER) para o BRASIL
-- Objetivo: Correlacionar a posição de investimento do Brasil com a variação do dólar.
-- Aqui no PowerBI podemos fazer um gráfico de linhas e colunas clusterizadas para mostrar a correlação
WITH NIIP_Brasil AS (
    SELECT
        t.Ano,
        t.Trimestre,
        AVG(f.Valor) AS NIIP_Valor
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Pais p ON f.SRK_Pais = p.SRK_Pais
    JOIN DW.Dim_Tempo t ON f.SRK_Tempo = t.SRK_Tempo
    JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
    WHERE
        p.Codigo_Pais = 'BRA'
        AND i.Codigo_Indicador = 'NIIP/IIP/NETAL_P'
    GROUP BY t.Ano, t.Trimestre
),
Cambio_Brasil AS (
    SELECT
        t.Ano,
        t.Trimestre,
        AVG(f.Valor) AS Cambio_Valor_USD
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Pais p ON f.SRK_Pais = p.SRK_Pais
    JOIN DW.Dim_Tempo t ON f.SRK_Tempo = t.SRK_Tempo
    JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
    WHERE
        p.Codigo_Pais = 'BRA'
        AND i.Codigo_Indicador = 'XDC_USD'
    GROUP BY t.Ano, t.Trimestre
)
SELECT
    niip.Ano,
    niip.Trimestre,
    niip.NIIP_Valor,
    cb.Cambio_Valor_USD
FROM NIIP_Brasil niip
JOIN Cambio_Brasil cb ON niip.Ano = cb.Ano AND niip.Trimestre = cb.Trimestre
WHERE niip.Ano >= (SELECT MAX(Ano) FROM DW.Dim_Tempo) - 10
ORDER BY
    niip.Ano, niip.Trimestre;

---

-- CONSULTA 4: Ativos vs Passivos (IIP) para a China (Média Anual)
-- Objetivo: Entender a composição da Posição de Investimento da China.
-- Se NEGATIVA: o mundo investiu mais na China. Se POSITIVA: a China investiu mais no mundo
WITH Ativos AS (
    SELECT
        t.Ano,
        AVG(f.Valor) AS Valor_Ativos
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Pais p ON f.SRK_Pais = p.SRK_Pais
    JOIN DW.Dim_Tempo t ON f.SRK_Tempo = t.SRK_Tempo
    JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
    WHERE
        p.Codigo_Pais = 'CHN'
        AND i.Codigo_Indicador = 'D/IIP/A_P'
    GROUP BY t.Ano
),
Passivos AS (
    SELECT
        t.Ano,
        AVG(f.Valor) AS Valor_Passivos
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Pais p ON f.SRK_Pais = p.SRK_Pais
    JOIN DW.Dim_Tempo t ON f.SRK_Tempo = t.SRK_Tempo
    JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
    WHERE
        p.Codigo_Pais = 'CHN'
        AND i.Codigo_Indicador = 'D/IIP/L_P'
    GROUP BY t.Ano
)
SELECT
    a.Ano,
    a.Valor_Ativos,
    p.Valor_Passivos,
    (a.Valor_Ativos - p.Valor_Passivos) AS Posicao_Liquida_Direta
FROM Ativos a
JOIN Passivos p ON a.Ano = p.Ano
WHERE a.Ano >= (SELECT MAX(Ano) FROM DW.Dim_Tempo) - 10
ORDER BY a.Ano DESC;

---

-- CONSULTA 5: Média de População e Taxa de Câmbio vs Dólar para América do Sul (Último Ano Completo)
-- Objetivo: Agregar dados médios por região para indicadores-chave.
-- WITH Ultimo_Ano_Completo AS (
--     -- Pega o último ano que tenha todos os 4 trimestres (ou seja, o ano anterior)
--     SELECT MAX(Ano) - 1 AS Ano_Alvo
--     FROM DW.Dim_Tempo
-- ),
-- Paises_AmSul AS (
--     SELECT SRK_Pais, Nome_Pais
--     FROM DW.Dim_Pais
--     WHERE Codigo_Pais IN ('BRA', 'ARG', 'COL', 'CHL', 'PER', 'URY')
-- )
-- SELECT
--     p.Nome_Pais,
--     i.Nome_Indicador,
--     AVG(f.Valor) AS Media_Anual
-- FROM DW.Fato_ObservacaoEconomica f
-- JOIN Paises_AmSul p ON f.SRK_Pais = p.SRK_Pais
-- JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
-- JOIN DW.Dim_Tempo t ON f.SRK_Tempo = t.SRK_Tempo
-- JOIN Ultimo_Ano_Completo ua ON t.Ano = ua.Ano_Alvo
-- WHERE
--     i.Codigo_Indicador IN ('POP/DM/PS', 'XDC_USD') --
-- GROUP BY
--     p.Nome_Pais,
--     i.Nome_Indicador
-- ORDER BY
--     p.Nome_Pais,
--     i.Nome_Indicador;
    
---





-- CONSULTA 6: Cobertura de Reservas (IRFCL) vs Drenagens de Curto Prazo (IRFCL)
-- Objetivo: Medir o "Colchão de Liquidez" (quantas vezes as reservas cobrem as saídas de curto prazo).
-- Valor_Reservas: É o "colchão" do país. É quanto dinheiro o Banco Central tem "em caixa" para emergências
-- Valor_Drenagens: São as obrigações de curto prazo (até 1 ano) do país.
-- Ratio_Cobertura: "Quantas vezes o meu colchão (Reservas) consegue pagar minhas dívidas de curto prazo (Drenagens)?"
-- Por isso que se o Valor_Drenagens for negativo, o Ratio_Cobertura não faz sentido (divisão por zero ou negativa)
WITH Reservas AS (
    SELECT
        f.SRK_Pais,
        f.SRK_Tempo,
        f.Valor AS Valor_Reservas
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
    WHERE i.Codigo_Indicador = 'IRFCLDT1_IRFCL65_USD_IRFCL13' -- Reservas Totais
),
Drenagens AS (
    SELECT
        f.SRK_Pais,
        f.SRK_Tempo,
        f.Valor AS Valor_Drenagens
    FROM DW.Fato_ObservacaoEconomica f
    JOIN DW.Dim_Indicador i ON f.SRK_Indicador = i.SRK_Indicador
    WHERE i.Codigo_Indicador = 'IRFCLDT2_USD_IRFCL13' -- Drenagens Líquidas Totais
)
SELECT
    p.Nome_Pais,
    t.Periodo_Completo,
    r.Valor_Reservas,
    d.Valor_Drenagens,
    -- Cálculo de Cobertura (Ratio):
    CASE
        WHEN d.Valor_Drenagens > 0 THEN (r.Valor_Reservas / d.Valor_Drenagens)
        ELSE NULL -- para não dividir por zero
    END AS Ratio_Cobertura
FROM Reservas r
JOIN Drenagens d ON r.SRK_Pais = d.SRK_Pais AND r.SRK_Tempo = d.SRK_Tempo
JOIN DW.Dim_Pais p ON r.SRK_Pais = p.SRK_Pais
JOIN DW.Dim_Tempo t ON r.SRK_Tempo = t.SRK_Tempo
WHERE
    p.Codigo_Pais IN ('BRA', 'ARG', 'COL', 'ZAF') -- BRICS / EMs selecionados
    AND t.Ano >= (SELECT MAX(Ano) FROM DW.Dim_Tempo) - 5
ORDER BY
    p.Nome_Pais,
    t.Periodo_Completo DESC;