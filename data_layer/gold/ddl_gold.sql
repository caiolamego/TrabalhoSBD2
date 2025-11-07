
CREATE SCHEMA IF NOT EXISTS DW;

CREATE TABLE DW.Dim_Pais (
    SRK_Pais SERIAL PRIMARY KEY,
    Codigo_Pais VARCHAR(10) NOT NULL UNIQUE,
    Nome_Pais VARCHAR(100)                 
);

CREATE TABLE DW.Dim_Tempo (
    SRK_Tempo SERIAL PRIMARY KEY,
    Periodo_Completo VARCHAR(10) NOT NULL UNIQUE,
    Ano INT NOT NULL,
    Trimestre VARCHAR(2),
    Mes INT
);

CREATE TABLE DW.Dim_Indicador (
    SRK_Indicador SERIAL PRIMARY KEY,
    Codigo_Indicador VARCHAR(255) NOT NULL UNIQUE, 
    Nome_Indicador TEXT,             
    Fonte_Dados VARCHAR(20),      
    Categoria VARCHAR(100)   
);

CREATE TABLE DW.Fato_ObservacaoEconomica (
    SRK_Observacao SERIAL PRIMARY KEY,

    SRK_Pais INT NOT NULL REFERENCES DW.Dim_Pais(SRK_Pais),
    SRK_Tempo INT NOT NULL REFERENCES DW.Dim_Tempo(SRK_Tempo),
    SRK_Indicador INT NOT NULL REFERENCES DW.Dim_Indicador(SRK_Indicador),
    Valor NUMERIC(30, 8),

    CONSTRAINT uk_fato_observacao UNIQUE (SRK_Pais, SRK_Tempo, SRK_Indicador)
);