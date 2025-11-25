
CREATE SCHEMA IF NOT EXISTS gold;

-- 2. Limpeza Inicial (Cuidado: isso apaga dados existentes)
DROP TABLE IF EXISTS gold.FAT_OBS_ECO CASCADE;
DROP TABLE IF EXISTS gold.DIM_IND CASCADE;
DROP TABLE IF EXISTS gold.DIM_TMP CASCADE;
DROP TABLE IF EXISTS gold.DIM_PAI CASCADE;



-- Tabela: Dimensão País (DIM_PAI)
CREATE TABLE gold.DIM_PAI (
    srk_pai SERIAL PRIMARY KEY,
    cod_pai VARCHAR(10) NOT NULL UNIQUE, 
    nom_pai VARCHAR(100)                
);

-- Tabela: Dimensão Tempo (DIM_TMP)
CREATE TABLE gold.DIM_TMP (
    srk_tmp SERIAL PRIMARY KEY, 
    cod_per VARCHAR(20) NOT NULL UNIQUE,
    num_ano INTEGER,
    cod_tri VARCHAR(5) 
);

-- Tabela: Dimensão Indicador (DIM_IND)
CREATE TABLE gold.DIM_IND (
    srk_ind SERIAL PRIMARY KEY, 
    cod_ind VARCHAR(100) NOT NULL UNIQUE,
    nom_ind VARCHAR(255),
    nom_fnt VARCHAR(50),
    des_cat VARCHAR(100)
);


-- Tabela: Fato Observação Econômica (FAT_OBS_ECO)
CREATE TABLE gold.FAT_OBS_ECO (
    srk_pai INTEGER NOT NULL,
    srk_tmp INTEGER NOT NULL,
    srk_ind INTEGER NOT NULL,
    vlr_obs DECIMAL(30, 8),

    CONSTRAINT pk_fat_obs_eco PRIMARY KEY (srk_pai, srk_tmp, srk_ind),
    
    CONSTRAINT fk_fat_pai FOREIGN KEY (srk_pai) 
        REFERENCES gold.DIM_PAI (srk_pai),
        
    CONSTRAINT fk_fat_tmp FOREIGN KEY (srk_tmp) 
        REFERENCES gold.DIM_TMP (srk_tmp),
        
    CONSTRAINT fk_fat_ind FOREIGN KEY (srk_ind) 
        REFERENCES gold.DIM_IND (srk_ind)
);