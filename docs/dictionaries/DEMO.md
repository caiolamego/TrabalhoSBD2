# Dicionário de Dados – Indicadores Demográficos e de Saúde

## 1) Estrutura das colunas

| Coluna                | Tipo     | Descrição                                                                                              | Exemplo                     |
| --------------------- | -------- | ------------------------------------------------------------------------------------------------------ | --------------------------- |
| **FREQ**              | String   | Frequência temporal dos dados. Usualmente `A` para anual.                                              | `A`                         |
| **TERRITORIAL_LEVEL** | String   | Nível territorial da observação. Neste caso, `CTRY` representa agregação por país.                     | `CTRY`                      |
| **REF_AREA**          | String   | Código do país de referência (formato ISO 3166-1 alfa-3).                                              | `BRA`, `USA`, `FRA`         |
| **TERRITORIAL_TYPE**  | String   | Tipologia territorial (ex.: acesso a centros urbanos, áreas rurais etc.).                              | `TYPO_METRO`                |
| **MEASURE**           | String   | Indicador medido (ver seção 2).                                                                        | `POP`, `MORT`, `FERT_RATIO` |
| **AGE**               | String   | Faixa etária da população analisada. Pode ser `_T` (total), `Y0` (0 anos), entre outras (ver seção 3). | `_T`, `Y0`                  |
| **SEX**               | String   | Sexo da população: `M` (masculino), `F` (feminino), `_T` (total).                                      | `M`, `F`, `_T`              |
| **UNIT_MEASURE**      | String   | Unidade de medida do valor. Ex: número de pessoas (`PS`), anos de vida (`Y`), nascimentos (`BR`), etc. | `PS`, `Y`, `BR`             |
| **TIME_PERIOD**       | String   | Ano de referência da observação.                                                                       | `2023`                      |
| **value**             | Numérico | Valor numérico correspondente à medida e unidade informada.                                            | `21234567.0`                |

---

## 2) Dicionário dos Indicadores (`MEASURE`)

| Código                  | Nome (EN)                                        | Nome (PT)                                       |
| ----------------------- | ------------------------------------------------ | ----------------------------------------------- |
| `POP`                   | Population                                       | População total                                 |
| `MORT`                  | Deaths                                           | Número de mortes registradas                    |
| `FERT_RATIO`            | Fertility rate                                   | Taxa de fertilidade                             |
| `NETMOB`                | Net inter-regional mobility                      | Mobilidade líquida entre regiões                |
| `OUTMOB`                | Out-migration to another region of same country  | Saídas para outras regiões                      |
| `INMOB`                 | In-migration from another region of same country | Entradas vindas de outras regiões               |
| `MORT_ICDV_CRUDE_RATIO` | Mortality rate: transport accidents              | Taxa de mortalidade por acidentes de transporte |
| `LFEXP`                 | Life expectancy                                  | Expectativa de vida                             |
| `LIVE_BIRTHS`           | Live births                                      | Nascimentos vivos                               |
| `MORT_ICDJ_CRUDE_RATIO` | Mortality rate: respiratory diseases             | Taxa de mortalidade por doenças respiratórias   |
| `MORT_ICDI_CRUDE_RATIO` | Mortality rate: circulatory diseases             | Taxa de mortalidade por doenças circulatórias   |
| `LAND_AREA`             | Land area                                        | Área terrestre                                  |

---

## 3) Faixas Etárias (`AGE`)

| Código        | Descrição                            |
| ------------- | ------------------------------------ |
| `_T`          | Total (todas as idades)              |
| `Y0`          | 0 anos (nascimentos no ano)          |

---

## 4) Sexo (`SEX`)

| Código | Descrição              |
| ------ | ---------------------- |
| `M`    | Masculino              |
| `F`    | Feminino               |
| `_T`   | Total (ambos os sexos) |

---

## 5) Tipos Territoriais (`TERRITORIAL_TYPE`)

| Código       | Descrição                                                    |
| ------------ | ------------------------------------------------------------ |
| `_Z`         | Not applicable                                               |
| `TYPO_METRO` | Tipologia agregada com base em acesso a áreas metropolitanas |


---

## 6) Unidade de Medida (`UNIT_MEASURE`)

| Código   | Descrição                                      | Exemplo de uso                         |
| -------- | ---------------------------------------------- | -------------------------------------- |
| `PS`     | Pessoas (Population Stock)                     | POP, MORT                              |
| `Y`      | Anos de vida                                   | LFEXP (Expectativa de vida)            |
| `BR`     | Nascimentos (Births)                           | LIVE_BIRTHS                            |
| `DT`     | Taxa bruta (por mil habitantes, por exemplo)   | MORT_ICDI_CRUDE_RATIO                  |
| `BR_L_W` | Nascimentos por 1.000 mulheres em idade fértil | FERT_RATIO                             |
| `10P5HB` | Por 10.000 habitantes                          | Taxas específicas (ex: óbitos por 10k) |
| `KM2`    | Quilômetros quadrados                          | Área territorial                       |

---

## 7) Frequência (`FREQ`)

| Código | Nome (EN) | Nome (PT) | Observação          |
| ------ | --------- | --------- | ------------------- |
| `A`    | Annual    | Anual     | Apenas dados anuais |

---

## 8) Período (`TIME_PERIOD`)

| Formato | Exemplo | Descrição         |
| ------- | ------- | ----------------- |
| `YYYY`  | `2023`  | Ano da observação |

