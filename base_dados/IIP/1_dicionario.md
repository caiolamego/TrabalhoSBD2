# Dicionário de Dados – IIP (International Investment Position)

## 1) Estrutura das colunas

| Coluna                     | Tipo     | Descrição                                                                                  | Exemplo            |
| -------------------------- | -------- | ------------------------------------------------------------------------------------------ | ------------------ |
| **COUNTRY**                | String   | Código do país (ISO-3)                                                                     | `USA`, `BRA`       |
| **BOP\_ACCOUNTING\_ENTRY** | String   | Entrada contábil (estoques): **A\_P** (ativos), **L\_P** (passivos), **NETAL\_P** (A − L). | `NETAL_P`          |
| **INDICATOR**              | String   | Indicador da posição internacional (vide seção 2).                                         | `NIIP`, `TA_AFR`   |
| **UNIT**                   | String   | Unidade monetária.                                                                         | `USD`              |
| **FREQUENCY**              | String   | Frequência temporal da série.                                                              | `Q` (trimestral)   |
| **TIME\_PERIOD**           | String   | Período de referência.                                                                     | `2005-Q4`          |
| **value**                  | Numérico | Valor do estoque no período (em USD). Pode ser positivo/negativo em séries líquidas.       | `-1857865000000.0` |

> **Observação**: No IIP falamos de **estoques** (posições) em uma **data de corte** (fim de trimestre). Diferente do BOP (fluxos), aqui **não** é soma no período, é “quanto existe” na data.

---

## 2) Dicionário dos Indicadores

### 2.1 Cabeçalhos (“headline”)

| Indicador   | Nome (PT)                                          | Definição / Uso                                                                                                        | Pares típicos de BOP\_ACCOUNTING\_ENTRY |
| ----------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| **NIIP**    | Posição Internacional de Investimentos **Líquida** | **Ativos externos − Passivos externos**. >0 = credor líquido; <0 = devedor líquido.                                    | `NETAL_P`                               |
| **TA\_AFR** | **Ativos** externos totais                         | Tudo que **residentes** possuem lá fora (ações, títulos, depósitos, empréstimos a não-residentes, reservas etc.).      | `A_P`                                   |
| **TL\_AFR** | **Passivos** externos totais                       | Tudo que **não-residentes** possuem aqui (ações emitidas localmente, títulos do governo, depósitos, empréstimos etc.). | `L_P`                                   |

> Esses três contam a história principal: **tamanho dos estoques** (TA/TL) e **sinal líquido** (NIIP).

---

### 2.2 Composição por categoria funcional

> Cada categoria **pode aparecer com A\_P (lado ativo)** e **L\_P (lado passivo)**. Quando estiver com `NETAL_P`, o valor é o **líquido da categoria** (ativos − passivos), se a série existir nesse formato para o código.

#### Investimento Direto (mais estável)

| Indicador | Nome (PT)                   | Leitura                                                           |
| --------- | --------------------------- | ----------------------------------------------------------------- |
| **D**     | IED total (posição)         | Posição total de **investimento direto**.                         |
| **D\_F5** | IED – **equity**            | Participação/ações (capital de longo prazo, controle/influência). |
| **D\_FL** | IED – **dívida intragrupo** | Empréstimos entre empresas relacionadas (matriz/filial).          |

#### Investimento em Portfólio (mais volátil)

| Indicador     | Nome (PT)                 | Leitura                                                                        |
| ------------- | ------------------------- | ------------------------------------------------------------------------------ |
| **P\_MV**     | Portfólio total (posição) | Ações + títulos de dívida detidos/emiti dos entre residentes e não-residentes. |
| **P\_F5\_MV** | Portfólio – **equity**    | Participações acionárias/fundos de portfólio.                                  |
| **P\_F3\_MV** | Portfólio – **dívida**    | Títulos de renda fixa (bonds/notes).                                           |

#### Outros Investimentos (bancos, empréstimos, depósitos, crédito comercial)

| Indicador     | Nome (PT)                | Leitura                                                       |
| ------------- | ------------------------ | ------------------------------------------------------------- |
| **O\_FL1**    | “Outros” total (posição) | Empréstimos, depósitos, créditos comerciais, outros.          |
| **O\_F4\_NV** | **Empréstimos**          | Posição em loans (interbancários, organismos, etc.).          |
| **O\_F2\_NV** | **Moeda e Depósitos**    | Depósitos/contas correntes entre residentes e não-residentes. |
| **O\_F81**    | **Crédito comercial**    | Fornecedores/adiantamentos comerciais.                        |

#### Reservas Internacionais (ativos do BC)

| Indicador      | Nome (PT)                       | Leitura                                                                  |
| -------------- | ------------------------------- | ------------------------------------------------------------------------ |
| **R**          | Reservas internacionais (total) | Posição total de **ativos de reserva** (ativos **sempre do lado A\_P**). |
| **R\_F11\_MV** | Ouro nas reservas               | Posição de ouro monetário.                                               |
| **R\_FK\_MV**  | Posição de reservas no FMI      | Reserve Tranche Position.                                                |
| **R\_F12\_MV** | **SDR – holdings**              | Direitos Especiais de Saque **detidos** (ativo).                         |

**Observação útil (SDR: ativos vs passivos)**

| Indicador                                           | Lado           | Leitura             | Como analisar                      |
| --------------------------------------------------- | -------------- | ------------------- | ---------------------------------- |
| **R\_F12\_MV**                                      | Ativo (A\_P)   | **SDR holdings**    | Parte de **Reservas** (ativo).     |
| **O\_F12**                                          | Passivo (L\_P) | **SDR allocations** | Passivo em “Outros Investimentos”. |
| → **SDR líquido** ≈ `R_F12_MV (A_P) − O_F12 (L_P)`. |                |                     |                                    |

---

## 3) Dicionário dos **BOP\_ACCOUNTING\_ENTRY**

| Código       | Nome (EN)                     | Nome (PT)              | Interpretação macro                                    |
| ------------ | ----------------------------- | ---------------------- | ------------------------------------------------------ |
| **A\_P**     | Assets, Positions             | **Ativos – posição**   | Estoque de ativos externos detidos por residentes.     |
| **L\_P**     | Liabilities, Positions        | **Passivos – posição** | Estoque de passivos externos devidos a não-residentes. |
| **NETAL\_P** | Net (assets less liabilities) | **Líquido (A − L)**    | Posição líquida; > 0 = credor, < 0 = devedor.          |

> Dica: para **headlines**, normalmente: `NIIP` com `NETAL_P`, `TA_AFR` com `A_P`, `TL_AFR` com `L_P`.

---

## 4) Unidade, frequência e chave de unicidade

* **UNIT**: sempre **USD**.
* **FREQUENCY**: **Q** (trimestral).
* **Chave única (PRIMARY KEY)**: **COUNTRY + BOP\_ACCOUNTING\_ENTRY + INDICATOR + TIME\_PERIOD**.

---

## 5) Regras de negócio e checagens de consistência

1. **Identidade básica (headline)**
   Para cada `COUNTRY` e `TIME_PERIOD`:

   * `NIIP (NETAL_P)` **≈** `TA_AFR (A_P)` **−** `TL_AFR (L_P)`.

2. **Soma por composição (por lado)**

   * **Ativos**: soma das categorias por `A_P` (Direto + Portfólio + Outros + Reservas) **≈** `TA_AFR (A_P)`.
   * **Passivos**: soma das categorias por `L_P` (Direto + Portfólio + Outros; *Reservas não tem L\_P*) **≈** `TL_AFR (L_P)`.

3. **Sinais**

   * `A_P` e `L_P` costumam ser **positivos** (estoques ≥ 0).
   * `NETAL_P` pode ser **negativo** (devedor líquido).
   * Se encontrar negativos inesperados em `A_P`/`L_P`, investigue revisões/metodologia.

4. **Mapeamento BOP ↔ IIP**

   * **BOP** (fluxos) explica **variação do IIP** (estoques) entre datas.
   * Diferenças vêm de **variações de preços**, **reavaliação cambial** e **outros ajustes**.

5. **SDR (coerência)**

   * Calcule **SDR líquido** = `R_F12_MV (A_P) − O_F12 (L_P)` e monitore contra mudanças no **XDR** (taxa SDR) se cruzar com bases em SDR.

6. **Moeda e conversões**

   * Aqui já está em **USD**. Se cruzar com séries em **SDR** (IRFCL/IIP em XDR), documente a taxa usada (ver ER `XDC_XDR`).
