# Dicionário de Dados - Camada Gold (Padrão Mnemônico)

Este documento detalha a padronização mnemônica utilizada nas tabelas do Data Warehouse.

## Tabelas Dimensionais

### `DIM_PAI` (Dimensão País)
| Atributo | Tipo (SQL) | Descrição Completa | Mnemônico Explicado |
| :--- | :--- | :--- | :--- |
| **srk_pai** | INT (PK) | Surrogate Key do País | `srk` (Surrogate Key) + `pas` (País) |
| **cod_pai** | VARCHAR | Código ISO do País (Natural) | `cod` (Código) + `pas` (País) |
| **nom_pai** | VARCHAR | Nome do País (Pt-Br) | `nom` (Nome) + `pas` (País) |

### `DIM_TMP` (Dimensão Tempo)
| Atributo | Tipo (SQL) | Descrição Completa | Mnemônico Explicado |
| :--- | :--- | :--- | :--- |
| **srk_tmp** | INT (PK) | Surrogate Key do Tempo | `srk` (Surrogate Key) + `tmp` (Tempo) |
| **cod_per** | VARCHAR | Código Período (ex: 2024-Q1) | `cod` (Código) + `per` (Período) |
| **num_ano** | INT | Número do Ano | `num` (Número) + `ano` (Ano) |
| **cod_tri** | VARCHAR | Código do Trimestre (ex: Q1) | `cod` (Código) + `tri` (Trimestre) |

### `DIM_IND` (Dimensão Indicador)
| Atributo | Tipo (SQL) | Descrição Completa | Mnemônico Explicado |
| :--- | :--- | :--- | :--- |
| **srk_ind** | INT (PK) | Surrogate Key do Indicador | `srk` (Surrogate Key) + `ind` (Indicador) |
| **cod_ind** | VARCHAR | Código Original do Indicador | `cod` (Código) + `ind` (Indicador) |
| **nom_ind** | VARCHAR | Nome do Indicador | `nom` (Nome) + `ind` (Indicador) |
| **nom_fnt** | VARCHAR | Fonte dos Dados (ex: BOP, IIP) | `nom` (Nome) + `fnt` (Fonte) |
| **des_cat** | VARCHAR | Descrição da Categoria | `des` (Descrição) + `cat` (Categoria) |

---

## Tabela Fato

### `FAT_OBS_ECO` (Fato Observação Econômica)
| Atributo | Tipo (SQL) | Descrição Completa | Mnemônico Explicado |
| :--- | :--- | :--- | :--- |
| **srk_pai** | INT (FK) | Chave Estrangeira País | Referência à `DIM_PAI` |
| **srk_tmp** | INT (FK) | Chave Estrangeira Tempo | Referência à `DIM_TMP` |
| **srk_ind** | INT (FK) | Chave Estrangeira Indicador | Referência à `DIM_IND` |
| **vlr_obs** | DECIMAL | Valor Observado da Métrica | `vlr` (Valor) + `obs` (Observação) |

## Glossário de Mnemônicos

Abaixo, o resumo consolidado de todos os mnemônicos utilizados para construção dos objetos e atributos.

| Mnemônico | Palavra / Significado |
| :--- | :--- |
| **ano** | Ano |
| **cat** | Categoria |
| **cod** | Código |
| **des** | Descrição |
| **dim** | Dimensão |
| **eco** | Econômica |
| **fat** | Fato |
| **fnt** | Fonte |
| **ind** | Indicador |
| **nom** | Nome |
| **num** | Número |
| **obs** | Observação |
| **pas** | País |
| **per** | Período |
| **srk** | Surrogate Key (Chave Substituta) |
| **tmp** | Tempo |
| **tri** | Trimestre |
| **vlr** | Valor |