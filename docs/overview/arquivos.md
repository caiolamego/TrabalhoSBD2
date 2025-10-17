# Arquivos do Projeto

Esta página descreve os principais arquivos e diretórios para você entender rapidamente onde estão os componentes críticos do pipeline.

## Raiz do projeto

- `docker-compose.yml`: Orquestra os serviços (PostgreSQL, Airflow webserver, scheduler e utilitários) e volumes. Define variáveis e permissões necessárias para execução das DAGs e notebooks.
- `docker-compose.override.yml`: Sobreposições locais (se presente) para desenvolvimento.
- `Dockerfile`: Imagem base do Airflow com Python 3.12, Java 17 (para Spark) e dependências do projeto.
- `requirements.txt`: Dependências Python (sdmx1, pandas, pyspark, papermill, psycopg2, etc.).
- `Makefile`: Comandos utilitários para build, up/down, logs, health, backup/restauração e troubleshooting.
- `entrypoint.sh`: Entrypoint customizado da imagem do Airflow.
- `fix-permissions.sh`: Script para ajustar permissões de diretórios montados.
- `mkdocs.yml`: Configuração do site de documentação (esta GitHub Pages). Navegação, plugins e tema.
- `README.md`: Resumo do projeto (espelha parte da documentação).

## Airflow

- `airflow/dags/`: DAGs do Airflow que orquestram coleta, transformação e validações.
  - `bop_dag.py`, `er_dag.py`, `iip_dag.py`, `irfcl_dag.py`: DAGs de coleta dos conjuntos de dados do FMI (BOP, ER, IIP, IRFCL) via notebooks ou scripts na pasta `base_dados/`.
  - `silver_bop_dag.py`: Rotinas de transformação/validação específicas de BOP na camada Silver.
  - `bronze_silver_dag.py`: DAG que executa o notebook `silver/bronze_silver.ipynb` via Papermill para promover dados da camada Bronze para Silver.
- `airflow/trigger_all_dags.sh`: Script de automação para despausar e disparar todas as DAGs após o Airflow estar saudável.
- `airflow/config/`, `airflow/plugins/`, `airflow/logs/`: Configurações, extensões e logs do Airflow, respectivamente.

## Coleta e análises (Base de dados)

- `base_dados/`: Repositório de notebooks e scripts de coleta da API SDMX do FMI e análises exploratórias.
  - Subpastas: `BOP/`, `ER/`, `IIP/`, `IRFCL/`, `DEMOGRAPHY/` organizam bases por domínio.
  - `sdmx.ipynb`: Notebook com lógica de acesso/extração SDMX.
  - `script.py`: Utilitários de coleta e processamento inicial.
  - `Resultados/`: Saídas geradas (por exemplo, `BOP.csv`, `ER.csv`). Também existe uma pasta global `Resultados/` na raiz montada no Airflow.

## Transformação (Silver)

- `silver/bronze_silver.ipynb`: Notebook principal de transformação da camada Bronze para Silver (normalizações, limpeza, padronizações e junções).
- `silver/bop_analysis.ipynb`: Análises específicas de BOP na camada Silver.
- `silver/test_postgres_insert_v2.ipynb`: Exemplo de carga de dados Silver no PostgreSQL.
- `silver/install_dependencies.sh`: Script auxiliar de setup dentro do container para rodar notebooks quando necessário.

## Notebooks e resultados

- `notebooks/`: Notebooks auxiliares de exploração.
- `Resultados/`: Execuções de notebooks do Airflow via Papermill, com carimbo de data/hora, e arquivos CSV resultantes.

## Postgres (Data Warehouse)

- `postgres/`: Inicialização e utilitários do banco de dados.
  - `init.sh` e `plugins/`, `helpers/`: Scripts e extensões para criação de schemas (staging/bronze/silver/gold), usuários e utilitários.

## Configuração Spark

- `spark_config/`: Configurações e helpers para criação de SparkSession e parâmetros de leitura/escrita.

## Documentação

- `docs/`: Conteúdo da GitHub Pages com MkDocs.
  - `index.md`: Visão geral do projeto.
  - `overview/`: Páginas de arquitetura, como subir o ambiente e pipelines.
  - `modeling/mer-der.md`: Modelagem de dados (MER/DER e DLDs).
  - `dictionaries/`: Dicionários de dados por domínio (BOP, DEMO, IIP, IRFCL, ER).
  - `assets/`: Imagens utilizadas na documentação (diagramas DER/DLD etc.).

## Itens mais importantes para entender o projeto

1. DAGs em `airflow/dags/` — componentes que automatizam a orquestração, incluindo a execução de notebooks via Papermill.
2. Notebook `silver/bronze_silver.ipynb` — transformação Bronze → Silver.
3. `airflow/trigger_all_dags.sh` — automatiza despausar e disparar DAGs quando o ambiente sobe.
4. `base_dados/` — notebooks de coleta SDMX e análises pós-coleta.
5. `docs/dictionaries/` — dicionários de dados por base, úteis para interpretação e modelagem.
