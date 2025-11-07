# Dicionário de Dados – BOP (Balance of Payments)

## 1. Estrutura das colunas

| Coluna                     | Tipo     | Descrição                                                                           | Exemplo          |
| -------------------------- | -------- | ----------------------------------------------------------------------------------- | ---------------- |
| **COUNTRY**                | String   | Código do país (ISO 3 letras)                                                       | `USA`, `BRA`     |
| **BOP\_ACCOUNTING\_ENTRY** | String   | Tipo de entrada contábil: crédito, débito, líquido, ativos, passivos (vide seção 3) | `NETCD_T`        |
| **INDICATOR**              | String   | Indicador de conta do BOP (macro, composição, reservas – vide seção 2)              | `CAB`            |
| **UNIT**                   | String   | Unidade de medida (normalmente dólares americanos – `USD`)                          | `USD`            |
| **FREQUENCY**              | String   | Frequência do dado: anual (A), trimestral (Q), mensal (M)                           | `Q`              |
| **TIME\_PERIOD**           | String   | Período temporal da observação                                                      | `2000-Q1`        |
| **value**                  | Numérico | Valor observado da série (positivo ou negativo, em unidade definida)                | `-84585000000.0` |

---

## 2. Dicionário dos Indicadores

### (1) Sinal geral do país (resultado da conta corrente e contas agregadas)

| Indicador   | Nome (EN)                                                  | Nome (PT)                                               | Interpretação                                                |
| ----------- | ---------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| **CAB**     | Current Account Balance                                    | Saldo da Conta Corrente                                 | “Placar” central: bens + serviços + rendas + transferências. |
| **CABXEF**  | Current Account excl. Exceptional Financing                | Saldo da Conta Corrente (sem financiamento excepcional) | Séries mais limpas.                                          |
| **KAB**     | Capital Account Balance                                    | Conta de Capital                                        | Normalmente pequeno, fecha a conta corrente.                 |
| **FAB**     | Financial Account Balance                                  | Conta Financeira                                        | Como o país se financiou (entrada/saída de capitais).        |
| **FABXRRI** | Financial Account Balance excl. reserves and related items | Conta Financeira (sem reservas)                         | Foca em financiamento “de mercado”.                          |
| **EO**      | Errors and Omissions                                       | Erros e Omissões                                        | Ajuste para “fechar” as contas (checagem de qualidade).      |

---

### (2) O “motor” do CAB: bens, serviços, rendas e transferências

| Indicador | Nome (EN)        | Nome (PT)          | Interpretação                                 |
| --------- | ---------------- | ------------------ | --------------------------------------------- |
| **SF**    | Trade Balance    | Saldo Comercial    | Exportações – Importações.                    |
| **GS**    | Goods & Services | Bens e Serviços    | Saldo agregado de bens e serviços.            |
| **IN1**   | Primary Income   | Rendas Primárias   | Juros, lucros, salários.                      |
| **IN2**   | Secondary Income | Rendas Secundárias | Transferências correntes (remessas, doações). |

---

### (3) A **composição do financiamento** (mix de fluxos financeiros)

| Indicador  | Nome (EN)                              | Nome (PT)                                | Interpretação                             |
| ---------- | -------------------------------------- | ---------------------------------------- | ----------------------------------------- |
| **DXEF**   | Direct Investment excl. Exceptional    | Investimento Direto (sem exceções)       | IED total.                                |
| **D\_F5**  | Direct Investment – Equity             | Investimento Direto – Ações              | Participação acionária (capital estável). |
| **D\_FL**  | Direct Investment – Debt               | Investimento Direto – Dívida             | Empréstimos intragrupo.                   |
| **PXEF**   | Portfolio Investment excl. Exceptional | Investimento em Portfólio (sem exceções) | Títulos financeiros (volátil).            |
| **P\_F5**  | Portfolio Equity                       | Portfólio – Ações                        | Ações/fundos.                             |
| **P\_F3**  | Portfolio Debt                         | Portfólio – Dívida                       | Títulos de dívida.                        |
| **O\_F4**  | Other Investment – Loans               | Outros Investimentos – Empréstimos       | Empréstimos bancários/organismos.         |
| **O\_F2**  | Other Investment – Currency & Deposits | Outros Investimentos – Moeda/Depósitos   | Variações de caixa bancário.              |
| **O\_F81** | Trade Credit                           | Crédito Comercial                        | Fornecedores.                             |

---

### (4) Reservas (uso/variação e posição operacional no BOP)

| Indicador | Nome (EN)                  | Nome (PT)                     | Interpretação                       |
| --------- | -------------------------- | ----------------------------- | ----------------------------------- |
| **RUE**   | Reserves and Related Items | Reservas e Itens Relacionados | Uso/variação de reservas no BOP.    |
| **R\_F**  | Reserve Assets             | Ativos de Reservas            | Estoque de reservas internacionais. |

---

## 3. Dicionário dos Accounting Entries

| Código          | Nome (EN)                           | Nome (PT)                         | Regra de Negócio / Interpretação                                    |
| --------------- | ----------------------------------- | --------------------------------- | ------------------------------------------------------------------- |
| **CD\_T**       | Credit                              | Crédito                           | Entradas do país (exportações, juros recebidos, serviços vendidos). |
| **DB\_T**       | Debit                               | Débito                            | Saídas do país (importações, juros pagos, serviços comprados).      |
| **NETCD\_T**    | Net Credit – Debit                  | Saldo Líquido                     | Placar: Créditos − Débitos (positivo = entrou mais que saiu).       |
| **A\_NFA\_T**   | Net Acquisition of Financial Assets | Aquisição Líquida de Ativos       | Residentes compram ativos no exterior (saída de moeda).             |
| **L\_NIL\_T**   | Net Incurrence of Liabilities       | Incorporação Líquida de Passivos  | País emite títulos/ações para fora (entrada de moeda).              |
| **NNAFANIL\_T** | A\_NFA − L\_NIL                     | Saldo Líquido da Conta Financeira | >0 saída líquida, <0 entrada líquida.                               |
| **A\_T**        | Assets, Total                       | Ativos (Total)                    | Volume bruto de ativos adquiridos.                                  |
| **L\_T**        | Liabilities, Total                  | Passivos (Total)                  | Volume bruto de passivos emitidos.                                  |

---

**Resumo de uso**:

* Use **COUNTRY + INDICATOR + BOP\_ACCOUNTING\_ENTRY + TIME\_PERIOD** para identificar unicamente uma observação, ou seja, como PK composta.
* Os indicadores contam **o que** está sendo medido (CAB, FAB, SF, etc.).
* Os accounting entries contam **como** a contabilidade foi registrada (crédito, débito, líquido, ativos/passivos).
* O campo `value` é o número em USD, em geral negativo/positivo, dependendo do sinal econômico.











<!-- 

### 1) Sinal geral do país (resultado da conta corrente e contas agregadas)

* **CAB** – *Current Account Balance*: saldo da conta corrente (o “placar” central: bens+serviços+rendas+transferências).
* **CABXEF** – igual ao anterior, **exclui financiamento excepcional** (series mais “limpas”).
* **KAB** – *Capital Account Balance*: saldo da conta de capital (normalmente pequeno, mas fecha a conta corrente).
* **FAB** – *Financial Account Balance*: como o país **se financiou** (entra/saí recurso financeiro).
* **FABXRRI** – FAB **excluindo reservas e itens relacionados** (foca no financiamento “de mercado”).
* **EO** – *Errors and Omissions*: checagem de **qualidade/fechamento** dos dados (se está “vazando” algo).

> Regra de neǵocio: Esse bloco dá o quadro “macro” do ano/período e mostra se o país está gerando/consumindo poupança externa e **como** fecha a conta.

---

### 2) O “motor” do CAB: bens, serviços, rendas e transferências

* **SF** – *Trade balance*: saldo comercial (exportações – importações).
* **GS** – *Goods & Services*: saldo agregado de bens e serviços.
* **IN1** – *Primary income*: rendas primárias (juros, lucros, salários pagos/recebidos).
* **IN2** – *Secondary income*: transferências correntes (remessas, doações etc.).

> Regra de negócio: Juntos, explicam **por que** o CAB ficou positivo/negativo.

---

### (3) A **composição do financiamento** (mix de fluxos financeiros)

* **DXEF** – *Direct investment (FDI), excl. exceptional*: investimento direto (controle/influência).
* **D\_F5** – FDI **equity** (participação/ações) — “capital de longo prazo”.
* **D\_FL** – FDI **debt** (dívida intragrupo) — “empréstimos entre partes relacionadas”.
* **PXEF** – *Portfolio investment, excl. exceptional*: investimento em **títulos** (volátil).
* **P\_F5** – Portfólio **equity** (ações/fundos).
* **P\_F3** – Portfólio **debt** (bônus/notes).
* **O\_F4** – *Other investment – loans*: **empréstimos** (bancos, organismos, etc.).
* **O\_F2** – *Other investment – currency & deposits*: **moeda e depósitos** (mudanças de caixa bancário).
* **O\_F81** – *Trade credit*: **crédito comercial** (fornecedores).

> Regra de negócio: Esse bloco mostra **de onde veio o dinheiro**: IED (mais estável), portfólio (mais volátil), empréstimos, depósitos e crédito comercial.

---

### 4) Reservas (uso/variação e posição operacional no BOP)

* **RUE** – *Reserves and related items*: variação de **reservas** usada para fechar o BOP.
* **R\_F** – *Reserve assets (total)*: ativo de **reservas internacionais** no BOP.

> Regra de negócio: Indica **intervenções**/acúmulo ou uso de reservas para acomodar desequilíbrios. -->



