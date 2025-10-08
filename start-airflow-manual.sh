#!/bin/bash

# Script alternativo para inicializar o Airflow manualmente

set -e

echo "=========================================="
echo "Inicialização Manual do Apache Airflow"
echo "=========================================="

# Parar tudo primeiro
echo "Parando containers existentes..."
docker-compose down -v

# Subir apenas o PostgreSQL
echo "Iniciando PostgreSQL..."
docker-compose up -d postgres

# Aguardar PostgreSQL ficar pronto
echo "Aguardando PostgreSQL ficar pronto..."
sleep 10

# Inicializar o banco de dados manualmente
echo "Inicializando banco de dados..."
docker-compose run --rm -e _AIRFLOW_DB_MIGRATE=true -e _AIRFLOW_WWW_USER_CREATE=true airflow-webserver airflow db migrate || true
docker-compose run --rm airflow-webserver airflow users create \
    --username airflow \
    --firstname Airflow \
    --lastname Admin \
    --role Admin \
    --email admin@example.com \
    --password airflow || echo "Usuário já existe"

# Subir os serviços principais
echo "Iniciando Airflow Webserver e Scheduler..."
docker-compose up -d airflow-webserver airflow-scheduler

echo ""
echo "=========================================="
echo "✓ Airflow iniciado!"
echo "=========================================="
echo ""
echo "Aguarde 30 segundos para o Airflow ficar totalmente pronto..."
echo "Depois acesse: http://localhost:8080"
echo "Usuário: airflow"
echo "Senha: airflow"
echo ""
