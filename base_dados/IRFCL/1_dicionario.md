# Dicionário de Dados – IRFCL (Reservas Internacionais & Liquidez em Moeda Estrangeira)

## 1) Estrutura das colunas

| Coluna           | Tipo     | Descrição                                                                                               | Exemplo                        |
| ---------------- | -------- | ------------------------------------------------------------------------------------------------------- | ------------------------------ |
| **COUNTRY**      | String   | Código do país (ISO-3).                                                                                 | `USA`, `BRA`                   |
| **INDICATOR**    | String   | Código do item IRFCL (inclui, no próprio código, a **moeda** e às vezes “flags” como DIC/XDR etc.).     | `IRFCLDT1_IRFCL65_USD_IRFCL13` |
| **SECTOR**       | String   | Setor institucional que reporta/compõe as informações.                                                  | `S1XS1311`                     |
| **FREQUENCY**    | String   | Frequência temporal.                                                                                    | `Q` (trimestral)               |
| **TIME\_PERIOD** | String   | Período de referência.                                                                                  | `2000-Q4`                      |
| **value**        | Numérico | Valor reportado. **Unidade** geralmente é parte do `INDICATOR` (ex.: `_USD_` no código → valor em USD). | `66930000000.0`                |

> 🔎 **Unidade**: o IRFCL codifica a moeda dentro do **próprio indicador** (ex.: `_USD_`, `_XDR_`). Na sua seleção, todos os códigos têm `_USD_`, então `value` já está em **USD**.

---

## 2) Dicionário dos Indicadores (por blocos)

### 2.1 Tamanho das reservas (nível e composição)

> **O que mede:** Estoque de reservas oficiais e sua decomposição por ativos (ouro, SDR, títulos, depósitos etc.).
> **Uso:** “Pulmão” de liquidez externa e a **qualidade da composição** (o quão líquidas e seguras são as reservas).

| Indicador                                     | Nome (PT)                                   | Leitura / Observação                                                        |
| --------------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------- |
| **IRFCLDT1\_IRFCL65\_USD\_IRFCL13**           | **Reservas oficiais (total)**               | **Headline**: principal série de nível de reservas.                         |
| **IRFCLDT1\_IRFCL54\_USD\_IRFCL13**           | Reservas oficiais **+ outros ativos em FX** | Conceito **amplo**: inclui FX assets fora do núcleo de “reservas” estritas. |
| **IRFCLDT1\_IRFCL56\_USD\_IRFCL13**           | **Ouro** nas reservas                       | Parte das reservas em ouro monetário.                                       |
| **IRFCLDT1\_IRFCL57\_USD\_IRFCL13**           | **Posição de reservas no FMI**              | “Reserve tranche position” (acesso potencial imediato no FMI).              |
| **IRFCLDT1\_IRFCL65\_DIC\_XDR\_USD\_IRFCL13** | **SDR – holdings** (dentro das reservas)    | Parcela de **SDR** que compõe as reservas (lado **ativo**).                 |
| **IRFCLDT1\_IRFCL32\_USD\_IRFCL13**           | **Títulos**                                 | Componentes mais “investidos”/portfólio das reservas.                       |
| **IRFCLDT1\_IRFCLCDCFC\_USD\_IRFCL13**        | **Moeda e Depósitos**                       | Parte mais **líquida** (caixa bancário em FX).                              |

---

### 2.2 “Drenagens” de curto prazo (vencimentos esperados)

> **O que mede:** **Saídas/influxos previstos** em moeda estrangeira a curto prazo, agregados por **baldes de vencimento**.
> **Uso:** Avaliar o **mismatch de liquidez** no curto prazo (parede de vencimentos) comparando com o nível de reservas.

**Headlines por bucket de prazo**

| Indicador                                     | Nome (PT)                                     | Leitura                                                |
| --------------------------------------------- | --------------------------------------------- | ------------------------------------------------------ |
| **IRFCLDT2\_USD\_IRFCL13**                    | **Drenagens líquidas de curto prazo (total)** | **Headline** de risco de liquidez (curto prazo).       |
| **IRFCLDT2\_IRFCL24\_SUTM\_USD\_IRFCL13**     | **Até 1 mês**                                 | Obrigações/fluxos em ≤ 1 mês.                          |
| **IRFCLDT2\_IRFCL24\_SM1MUT3M\_USD\_IRFCL13** | **1 a 3 meses**                               | Bucket intermediário.                                  |
| **IRFCLDT2\_IRFCL24\_SM3MUTY\_USD\_IRFCL13**  | **3 a 12 meses**                              | Parede de vencimentos ao longo do horizonte de um ano. |

**Abertura por tipo de saída (principal x juros)**

| Indicador                                          | Nome (PT)           | Leitura                               |
| -------------------------------------------------- | ------------------- | ------------------------------------- |
| **IRFCLDT2\_IRFCL26\_SUTM\_FO\_USD\_IRFCL13**      | **Principal** ≤ 1M  | Amortizações em até 1 mês.            |
| **IRFCLDT2\_IRFCL26\_SM1MUT3M\_FO\_USD\_IRFCL13**  | **Principal** 1–3M  |                                       |
| **IRFCLDT2\_IRFCL26\_SM3MUTY\_FO\_USD\_IRFCL13**   | **Principal** 3–12M |                                       |
| **IRFCLDT2\_IRFCL151\_SUTM\_FO\_USD\_IRFCL13**     | **Juros** ≤ 1M      | Pagamentos de **juros** em até 1 mês. |
| **IRFCLDT2\_IRFCL151\_SM1MUT3M\_FO\_USD\_IRFCL13** | **Juros** 1–3M      |                                       |
| **IRFCLDT2\_IRFCL151\_SM3MUTY\_FO\_USD\_IRFCL13**  | **Juros** 3–12M     |                                       |

> **Leitura**: Esses códigos mostram **o que exatamente vence** e **quando** (principal vs juros), crucial para o risco de short-term liquidity.

---

### 2.3 Derivativos e forwards/futuros

> **O que mede:** Posições em derivativos e contratos a termo que **afetam a liquidez futura** (entradas/saídas).
> **Uso:** Estimar **buffers ou pressões** adicionais além da dívida “tradicional”.

| Indicador                                        | Nome (PT)                             | Leitura                                                         |
| ------------------------------------------------ | ------------------------------------- | --------------------------------------------------------------- |
| **IRFCLDT2\_IRFCL1\_SUTM\_IN\_LP\_USD\_IRFCL13** | **Entradas** de forwards/futuros ≤ 1M | Inflows esperados (ajudam a liquidez).                          |
| **IRFCLDT2\_IRFCL1\_SUTM\_SHP\_USD\_IRFCL13**    | **Saídas** (posição short) ≤ 1M       | Outflows esperados (pressionam a liquidez).                     |
| **IRFCLDT4\_IRFCLU97\_A\_USD\_IRFCL13**          | **Derivativos (net, a mercado)**      | Memorando: marcação a mercado líquida (pode ajudar/atrapalhar). |

---

### 2.4 Itens de memorando (composição e mobilização)

> **O que mede:** Detalhes de **composição por moeda** e **operações de títulos** (lending/repo) que afetam **mobilizabilidade**.

| Indicador                                      | Nome (PT)                     | Leitura                                                  |
| ---------------------------------------------- | ----------------------------- | -------------------------------------------------------- |
| **IRFCLDT4\_IRFCL11\_DIC\_XDRB\_USD\_IRFCL13** | **Moedas da cesta SDR**       | Composição por moeda “âncora” (USD, EUR, JPY, GBP, CNY). |
| **IRFCLDT4\_IRFCL11\_DIC\_XXDR\_USD\_IRFCL13** | **Outras moedas**             | Fora da cesta SDR.                                       |
| **IRFCLDT4\_IRFCL68\_USD\_IRFCL13**            | **Títulos cedidos/em repo**   | Reduz “o que é mobilizável” de imediato.                 |
| **IRFCLDT4\_IRFCL69X\_USD\_IRFCL13**           | **…não incluídos na seção I** | Complementa a leitura de títulos “emprestados/cedidos”.  |

---

## 3) SECTOR

| Código       | Descrição                                                                                                                                    |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **S1XS1311** | **Monetary Authorities and Central Government (excl. Social Security)** – Autoridades monetárias + governo central (sem previdência social). |

> Em muitos países, **reservas** são geridas pelo **Banco Central** (autoridades monetárias), mas podem envolver componentes no perímetro do governo central. Esse setor agrega o que importa para a **liquidez soberana**.

---

## 4) Frequência, chave e unidade

* **FREQUENCY:** `Q` (trimestral).
* **Unidade:** embutida no `INDICATOR` (nos seus códigos: **USD**).
* **Chave única sugerida:** **COUNTRY + INDICATOR + SECTOR + TIME\_PERIOD**.

---

## 5) Regras de negócio e checagens de consistência

1. **Coerência de composição das reservas**

   * `Reservas totais (IRFCLDT1_IRFCL65_USD_IRFCL13)` **≥** soma de componentes “principais” (ouro, IMF position, SDR holdings, títulos, moeda & depósitos), **ajustada** por itens de memorando como **títulos cedidos** (68/69X) que **reduzem mobilizabilidade**.
   * **Conceito amplo** `IRFCLDT1_IRFCL54_USD_IRFCL13` **≥** `Reservas totais` (tende a ser maior/igual).

2. **Buckets de drenagem**

   * **Total** de drenagens `IRFCLDT2_USD_IRFCL13` deve ser **compatível** com a soma dos buckets (≤1M, 1–3M, 3–12M), levando em conta entradas/saídas e classificações.
   * A soma de **principal** + **juros** por bucket deve ser **coerente** com o total do bucket.

3. **Derivativos**

   * Entradas (`…IN_LP…`) e saídas (`…SHP…`) ≤ 1M devem ser **coerentes** com o **net** (quando disponível) e com a posição **marcada a mercado** (`IRFCLDT4_IRFCLU97_A_USD_IRFCL13`).

4. **Cobertura de curto prazo** (indicadores derivados – ótimos para dashboard)

   * **Import cover**: Reservas totais / Importações mensais (ou trimestrais) em **USD**.
   * **Coverage de curto prazo**: `Reservas totais / Drenagens ≤ 3M` (quanto “colchão” há).
   * **Quality mix** (liquidez): `(Moeda & Depósitos + IMF position + SDR holdings) / Reservas totais`.

5. **Integração com outras bases**

   * **ER** (Exchange Rates): se houver séries em **XDR**, use `XDC_XDR` para conversões coerentes.
   * **IIP**: `R` e `R_F12_MV` (IIP) devem **dialogar** com reservas e **SDR holdings** (IRFCL).
   * **BOP**: variações de reservas no BOP (fluxo) ajudam a explicar **mudanças** do nível de reservas no IRFCL (estoque), junto com preços/câmbio.

---

## 6) Exemplos de interpretação

* Linha exemplo: `(USA, IRFCLDT1_IRFCL65_USD_IRFCL13, S1XS1311, Q, 2000-Q4, 66930000000.0)`
  → **EUA**, **2000-Q4**, **Reservas oficiais (total)** = **USD 66,93 bi**.
  Se, no mesmo trimestre, `Moeda&Depósitos` for 30% e `Títulos` 60%, você tem uma reserva com **liquidez razoável** (boa parcela mobilizável rapidamente) e forte componente em títulos (exposta a preço/mercado).

* Exemplo de risco de curto prazo:
  Se `Drenagens ≤ 3M` = **USD 50 bi** e `Reservas totais` = **USD 60 bi**, a **cobertura de curto prazo** ≈ **1,2×** (confortável, mas sensível a choques).
