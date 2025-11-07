
# Projeto ETL - Dados do FMI

Bem-vindo à documentação do TrabalhoSBD2. Este projeto implementa um pipeline de ETL para coletar, transformar e armazenar indicadores do Fundo Monetário Internacional (FMI) com foco em automação, reprodutibilidade e rastreabilidade.

## Visão geral do projeto

- Orquestração: Apache Airflow (DAGs para coleta e transformação)
- Transformação: PySpark nas camadas Bronze → Silver → Gold
- Armazenamento: PostgreSQL e arquivos analíticos (Parquet/CSV)
- Entrada de dados: API SDMX do FMI + notebooks de coleta e análise

Para começar rapidamente:

- Como subir o ambiente: veja "1. Como subir o ambiente"
- Arquitetura do pipeline: veja "2. Arquitetura do Pipeline"
- Modelagem de dados (MER/DER): veja "3. Modelagem (MER/DER)"
- Referência de arquivos essenciais: veja "4. Arquivos do Projeto"

## Diagrama Lógico de Dados - Schema Gold

<img src="assets/dld_schema.png" alt="Diagrama Lógico - Schema Gold" style="max-width: 100%; height: auto;">




