# Modelo e Diagrama Entidade-Relacionamento (MER / DER)

Este documento apresenta a estrutura lógica do modelo de dados, ilustrando as entidades (tabelas) e os relacionamentos estabelecidos para integrar os domínios de Contas Externas (BOP, IIP, IRFCL, ER) e Demografia (DEMOGRAPHY).

---

## 1. Diagrama Entidade-Relacionamento (DER)

Primeiramente desenvolveu-se o DER para representar os dados da maneira como foram extraídos:

<img src="../../assets/der.png" alt="Diagrama Entidade-Relacionamento" style="max-width: 100%; height: auto;">

Afim de esclarecer a futura estrutura que será utilizada na camada Gold, foi desenvolvido, também o DER da futura estrutura do Data Lakehouse:

<img src="../../assets/der_schema.png" alt="Diagrama Entidade-Relacionamento" style="max-width: 100%; height: auto;">

## 2. Diagrama Lógico de Dados (DLD)

Complementarmente ao DER, evolui-se os Diagramas Entidade-Relacionamento para um modelo mais próximo do nível físico, os chamados Diagramas Lógicos de Dados (DLD).

Segue, respectivamente, o DLD da estrutura dos dados e da estrutura que será usada na camada Gold.

Dados:

<img src="../../assets/dld.png" alt="Diagrama Entidade-Relacionamento" style="max-width: 100%; height: auto;">

O Schema será separado em uma grande tabela Fato, centralizando todos os dados. Ela terá relação direta com as Dimensões: País, Frequência e Indicador, conforme ilustrado abaixo.

<img src="../../assets/dld_schema.png" alt="Diagrama Entidade-Relacionamento" style="max-width: 100%; height: auto;">








