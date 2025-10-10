

# Projeto ETL - Dados do FMI (TrabalhoSBD2)

[![Airflow](https://img.shields.io/badge/Apache%20Airflow-2.9.1-blue)](https://airflow.apache.org/)
[![Spark](https://img.shields.io/badge/Apache%20Spark-3.5.1-orange)](https://spark.apache.org/)
[![Python](https://img.shields.io/badge/Python-3.12-green)](https://python.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue)](https://docker.com/)

> **Objetivo:** Desenvolver um **pipeline de ETL (Extract, Transform, Load)** automatizado para **coleta, processamento e análise de dados do Fundo Monetário Internacional (FMI)**, utilizando **Apache Airflow** e **Apache Spark**.

---

## Visão Geral

Este projeto implementa uma arquitetura moderna de **ETL orientada a dados**, capaz de coletar informações diretamente da **API SDMX do FMI**, transformá-las via **Spark** e armazenar os resultados em formato analítico (Parquet, CSV e JSON).
Todo o fluxo é **automatizado pelo Airflow**, garantindo escalabilidade, reprodutibilidade e rastreabilidade completa do processo.


<img src="./assets/dld.png" alt="Diagrama Entidade-Relacionamento" style="max-width: 100%; height: auto;">

Schema:

<img src="./assets/dld_schema.png" alt="Diagrama Entidade-Relacionamento" style="max-width: 100%; height: auto;">

---
     



---


