CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS dw.Dim_Pais (
    SRK_Pais SERIAL PRIMARY KEY,
    CodigoPais VARCHAR(10) NOT NULL UNIQUE,
    NomePais VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.Dim_Tempo (
    SRK_Tempo SERIAL PRIMARY KEY,
    DataCompleta DATE NOT NULL UNIQUE,
    Ano INT NOT NULL,
    Mes INT NOT NULL,
    Trimestre VARCHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.Dim_Indicador (
    SRK_Indicador SERIAL PRIMARY KEY,
    CodigoIndicador VARCHAR(50) NOT NULL UNIQUE,
    CategoriaIndicador VARCHAR(50) NOT NULL,
    UnidadeMedida VARCHAR(50)
);


CREATE TABLE IF NOT EXISTS dw.Fato_Indicadores (
    SRK_Tempo INT NOT NULL,
    SRK_Pais INT NOT NULL,
    SRK_Indicador INT NOT NULL,
    Valor NUMERIC(20, 4),
    PRIMARY KEY (SRK_Tempo, SRK_Pais, SRK_Indicador),

    CONSTRAINT fk_tempo FOREIGN KEY (SRK_Tempo) REFERENCES dw.Dim_Tempo (SRK_Tempo),
    CONSTRAINT fk_pais FOREIGN KEY (SRK_Pais) REFERENCES dw.Dim_Pais (SRK_Pais),
    CONSTRAINT fk_indicador FOREIGN KEY (SRK_Indicador) REFERENCES dw.Dim_Indicador (SRK_Indicador)
);