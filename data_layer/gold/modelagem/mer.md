### MODELO ENTIDADE-RELACIONLAMENTO (ME-R)

#### IDENTIFICAÇÃO DAS ENTIDADES:

* PAIS
* INDICADOR
* TEMPO
* INDICADORES

#### DESCRIÇÃO DAS ENTIDADES (ATRIBUTOS):

* **DIM_PAI** (`srk_pai`, `cod_pai`, `nom_pai`)
    * *Observação: `cod_pai` é o código de negócio (ex: 'USA').*

* **DIM_IND** (`srk_ind`, `cod_ind`, `nom_ind`, `nom_fnt`, `des_cat`)
    * *`cod_ind` é o código de negócio (ex: 'CAB').*

* **DIM_TMP** (`srk_tmp`, `cod_per`, `num_ano`, `cod_tri`)

* **FAT_OBS_ECO** (`srk_pai`, `srk_ind`, `srk_tmp`, `vlr_obs`)
    * *Observação: Esta é a entidade Fato. Seus identificadores são as chaves das entidades dimensionais às quais se conecta, e seu atributo principal é a métrica `vrl_obs`.*

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