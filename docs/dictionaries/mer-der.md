# Modelo e Diagrama Entidade-Relacionamento (MER / DER)

Este documento apresenta a estrutura lógica do modelo de dados, ilustrando as entidades (tabelas) e os relacionamentos estabelecidos para integrar os domínios de Contas Externas (BOP, IIP, IRFCL, ER) e Demografia (DLD).

---

## 1. Entidades Principais e Atributos

As cinco bases de dados foram mapeadas em cinco entidades principais, cada uma com uma **Chave Primária Composta (PK)** que garante a unicidade da observação.

| Entidade | Descrição | Chaves Primárias (PK) |
| :--- | :--- | :--- |
| **BOP\_FLUXO** | Balança de Pagamentos: Fluxos e transações no período (Crédito, Débito, Líquido). | `COUNTRY`, `BOP_ACCOUNTING_ENTRY`, `INDICATOR`, `TIME_PERIOD` |
| **IIP\_ESTOQUE** | Posição Internacional de Investimentos: Estoques de ativos e passivos em uma data de corte. | `COUNTRY`, `BOP_ACCOUNTING_ENTRY`, `INDICATOR`, `TIME_PERIOD` |
| **IRFCL\_LIQUIDEZ** | Reservas e Liquidez: Detalhes da composição das reservas e drenagens de curto prazo. | `COUNTRY`, `INDICATOR`, `SECTOR`, `TIME_PERIOD` |
| **ER\_CAMBIO** | Taxas de Câmbio: Cotações da moeda doméstica por unidade da moeda âncora (USD, EUR, SDR). | `COUNTRY`, `INDICATOR`, `TYPE_OF_TRANSFORMATION`, `TIME_PERIOD` |
| **DLD\_DEMOGRAFIA** | Indicadores Demográficos: População, Faixas Etárias, Sexo e medidas de saúde/mobilidade. | `REF_AREA`, `MEASURE`, `AGE`, `SEX`, `TERRITORIAL_TYPE`, `TIME_PERIOD` |

---

## 2. Explicação dos Relacionamentos

Os relacionamentos são cruciais para a consistência e a capacidade analítica do modelo.

### R1: Estoque $\leftrightarrow$ Fluxo (`BOP_FLUXO` $\leftrightarrow$ `IIP_ESTOQUE`)

| Característica | Detalhes |
| :--- | :--- |
| **Chave de Ligação** | `COUNTRY`, `TIME_PERIOD` |
| **Cardinalidade** | $1:1$ (Para cada observação BOP no período, há uma posição IIP correspondente no fim do período). |
| **Regra de Negócio** | O fluxo de transações registrado no **BOP** (especialmente o Saldo Líquido da Conta Financeira) deve, teoricamente, explicar a **variação** do estoque do **IIP** entre dois períodos, sendo a diferença ajustada por variações de preço e câmbio. |

### R2: Posição $\leftrightarrow$ Detalhe (`IIP_ESTOQUE` $\leftrightarrow$ `IRFCL_LIQUIDEZ`)

| Característica | Detalhes |
| :--- | :--- |
| **Chave de Ligação** | `COUNTRY`, `TIME_PERIOD` |
| **Cardinalidade** | $1:1$ |
| **Regra de Negócio** | O indicador de **Ativos de Reservas (`R`)** no IIP (lado `A_P`) deve ser **coerente e equivalente** ao indicador de **Reservas Oficiais Totais** no IRFCL. O IRFCL fornece o detalhe vital sobre a composição e a liquidez de curto prazo (drenagens) que o IIP não oferece. |

### R3: Câmbio $\leftrightarrow$ Finanças (`ER_CAMBIO` $\leftrightarrow$ `BOP`/`IIP`/`IRFCL`)

| Característica | Detalhes |
| :--- | :--- |
| **Chave de Ligação** | `COUNTRY`, `TIME_PERIOD` (Necessita de ajuste de frequência Mês $\rightarrow$ Trimestre) |
| **Cardinalidade** | $N:1$ (`ER_CAMBIO` é Mensal, as demais bases são Trimestrais ou Anuais). |
| **Regra de Negócio** | **`ER_CAMBIO`** atua como uma **tabela de conversão**. Deve ser usada para: **a) Fluxos (BOP)**: Usar o câmbio **`PA_RT` (média do período)** para converter valores agregados no período. **b) Estoques (IIP/IRFCL)**: Usar o câmbio **`EOP_RT` (fim do período)** para reavaliar a posição na data de corte. |

### R4: Contexto $\leftrightarrow$ Finanças (`DLD_DEMOGRAFIA` $\leftrightarrow$ Bases Financeiras)

| Característica | Detalhes |
| :--- | :--- |
| **Chave de Ligação** | `REF_AREA` / `COUNTRY`, `TIME_PERIOD` (Apenas no nível do Ano) |
| **Cardinalidade** | $1:N$ (`DLD_DEMOGRAFIA` é Anual, as demais bases são Trimestrais/Mensais). |
| **Regra de Negócio** | Fornecer contexto para normalização. Permite calcular métricas como **NIIP per capita** (usando `POP` do DLD com `NIIP` do IIP) ou analisar a relação entre remessas (`IN2` do BOP) e mobilidade populacional (`NETMOB` do DLD). |











Ferramentas

2.5 Flash

O G