# Dicionário de Dados – ER (Exchange Rates)

## 1) Estrutura das colunas

| Coluna                       | Tipo     | Descrição                                                                                                  | Exemplo                         |
| ---------------------------- | -------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| **COUNTRY**                  | String   | Código do país (ISO-3) cujo **câmbio doméstico** está sendo cotado.                                        | `COL`, `BRA`, `USA`             |
| **INDICATOR**                | String   | Paridade/forma de cotação da taxa de câmbio (vide seção 2).                                                | `XDC_EUR`, `XDC_USD`, `XDC_XDR` |
| **TYPE\_OF\_TRANSFORMATION** | String   | Forma de agregação no período: **EOP\_RT** (fim do período) ou **PA\_RT** (média do período).              | `PA_RT`                         |
| **FREQUENCY**                | String   | Frequência: **M** (mensal).                                                                                | `M`                             |
| **TIME\_PERIOD**             | String   | Período temporal.                                                                                          | `2011-M06`                      |
| **value**                    | Numérico | Valor numérico da taxa de câmbio, **na moeda doméstica do país**, por unidade do denominador do indicador. | `2564.791474090893`             |

> **Interpretação do `value`**: sempre leia como “**moeda doméstica por 1 unidade da moeda do indicador**”.
> Ex.: `XDC_EUR` para `COL` ⇒ **COP por 1 EUR**.

---

## 2) Dicionário dos Indicadores (cotação)

Todos os três abaixo usam o **mesmo sentido de cotação**: **XDC / Moeda-Âncora**, isto é, **moeda doméstica por 1 unidade da âncora**.

| Indicador    | Nome (EN)                       | Nome (PT)                       | Interpretação / Uso                                                                   |
| ------------ | ------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------- |
| **XDC\_USD** | Domestic currency per US Dollar | Moeda doméstica por 1 Dólar     | **Âncora global** em finanças; facilita comparações e conversões. Ex.: BRL por 1 USD. |
| **XDC\_EUR** | Domestic currency per Euro      | Moeda doméstica por 1 Euro      | Útil em análises com Europa; **segunda âncora** relevante. Ex.: COP por 1 EUR.        |
| **XDC\_XDR** | Domestic currency per SDR (IMF) | Moeda doméstica por 1 SDR (DEG) | Alinha com bases **IRFCL/IIP** quando os dados estiverem em **SDR**.                  |

> Observação: se um dia você usar indicadores no **sentido inverso** (ex.: `USD_XDC`), a leitura muda para “**USD por 1 unidade de moeda doméstica**”. Nos três que você escolheu (XDC\_USD, XDC\_EUR, XDC\_XDR), é **sempre doméstica por 1 âncora**.

---

## 3) TYPE\_OF\_TRANSFORMATION (agregação no período)

| Código      | Nome (EN)      | Nome (PT)            | Interpretação / Quando usar                                                                                                                                        |
| ----------- | -------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **EOP\_RT** | End-of-period  | Fim do período (EoP) | Valor do **último dia** do mês. Útil para **posições** e reconciliações em data de corte (ex.: fechar balanço).                                                    |
| **PA\_RT**  | Period average | Média do período     | Média dos valores **ao longo do mês**. Melhor para **fluxos** e conversões de valores agregados no período (ex.: média do mês para converter importações mensais). |

**Regra prática**:

* **PA\_RT** para converter **fluxos** (ex.: importações/ exportações mensais).
* **EOP\_RT** para converter **estoques/posições** (ex.: posição de reservas no fim do mês).

---

## 4) FREQUENCY

| Código | Nome (EN) | Nome (PT) | Observação                                                                                                         |
| ------ | --------- | --------- | ------------------------------------------------------------------------------------------------------------------ |
| **M**  | Monthly   | Mensal    | Nesta base você está usando apenas mensal. (As séries podem existir em A/Q em outros catálogos, mas aqui é **M**.) |

---

## 5) Regras de negócio, chaves e unidades

### 5.1 Chave de unicidade (PRIMARY KEY)

* **COUNTRY + INDICATOR + TYPE\_OF\_TRANSFORMATION + TIME\_PERIOD**
  Garante uma observação única por paridade, tipo de agregação e mês.

### 5.2 Unidade e escala

* `value` está em **moeda doméstica do COUNTRY por 1 unidade da âncora** (USD, EUR, XDR).
* A **escala** depende do país (ex.: COP por EUR pode estar na casa dos milhares; JPY por USD pode ser dezenas/centenas).
* Não há símbolo de moeda na célula (só o número). O significado vem do `INDICATOR`.

### 5.3 Conversões e consistência

* Se você precisa de **USD por moeda doméstica** (inverso do `XDC_USD`), use `1 / value` (atenção a casas decimais e zeros).
* **Taxa cruzada** (ex.: estimar EUR/ USD via duas cotações domésticas):

  $$
  \frac{\text{XDC}}{\text{EUR}} \div \frac{\text{XDC}}{\text{USD}} \approx \frac{\text{USD}}{\text{EUR}}
  $$

  e o inverso para obter `EUR/USD`. Melhor ainda: busque diretamente o par desejado quando disponível.

---

## 6) Tabela-resumo

### 6.1 Colunas

| Coluna                   | Regra de Preenchimento                           |
| ------------------------ | ------------------------------------------------ |
| COUNTRY                  | ISO-3 do país (ex.: BRA, USA, COL).              |
| INDICATOR                | Um de: `XDC_USD`, `XDC_EUR`, `XDC_XDR`.          |
| TYPE\_OF\_TRANSFORMATION | `EOP_RT` (fim do mês) ou `PA_RT` (média do mês). |
| FREQUENCY                | `M`.                                             |
| TIME\_PERIOD             | `YYYY-MMM` (ex.: 2011-M06).                      |
| value                    | Número real (moeda doméstica por 1 âncora).      |

### 6.2 Indicadores

| INDICATOR | Leitura         | Uso principal                           |
| --------- | --------------- | --------------------------------------- |
| XDC\_USD  | Doméstica/1 USD | Comparações globais, conversões gerais. |
| XDC\_EUR  | Doméstica/1 EUR | Análises com Europa; segunda âncora.    |
| XDC\_XDR  | Doméstica/1 SDR | Integração com IRFCL/IIP em SDR.        |

### 6.3 Type of Transformation

| Código  | Definição         | Quando preferir            |
| ------- | ----------------- | -------------------------- |
| PA\_RT  | Média do mês      | Conversão de **fluxos**.   |
| EOP\_RT | Último dia do mês | Conversão de **estoques**. |


