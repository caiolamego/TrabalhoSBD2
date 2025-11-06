### MODELO ENTIDADE-RELACIONLAMENTO (ME-R)

#### IDENTIFICAÇÃO DAS ENTIDADES:

* PAIS
* INDICADOR
* TEMPO
* INDICADORES

#### DESCRIÇÃO DAS ENTIDADES (ATRIBUTOS):

* **PAIS** (`SRK_Pais`, `codigoPais`, `nomePais`)
    * *Observação: `codigoPais` é o código de negócio (ex: 'USA').*

* **INDICADOR** (`SRK_Indicador`, `codigoIndicador`, `categoriaIndicador`, `unidadeMedida`)
    * *`codigoIndicador` é o código de negócio (ex: 'CAB').*

* **TEMPO** (`SRK_Tempo`, `dataCompleta`, `ano`, `mes`, `trimestre`)

* **FATO** (`SRK_Tempo`, `SRK_Pais`, `SRK_Indicador`, `valor`)
    * *Observação: Esta é a entidade Fato. Seus identificadores são as chaves das entidades dimensionais às quais se conecta, e seu atributo principal é a métrica `valor`.*

#### DESCRIÇÃO DOS RELACIONAMENTOS:

* **PAIS – possui – FATO**
    * Um PAIS pode registrar várias (N) MEDIÇÕES\_INDICADOR, mas uma MEDIÇÃO\_INDICADOR é registrada por apenas um (1) PAIS.
    * **Cardinalidade: 1:n**

* **INDICADOR – possui – FATO**
    * Um INDICADOR pode ser medido por várias (N) MEDIÇÕES\_INDICADOR, mas uma MEDIÇÃO\_INDICADOR refere-se a apenas um (1) INDICADOR.
    * **Cardinalidade: 1:n**

* **TEMPO – possui – FATO**
    * Um TEMPO (dia) pode ter várias (N) MEDIÇÕES\_INDICADOR registradas, mas uma MEDIÇÃO\_INDICADOR ocorre em apenas um (1) TEMPO (dia).
    * **Cardinalidade: 1:n**