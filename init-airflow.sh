#!/bin/bash

# Script para inicializar Airflow sem o container airflow-init problemático

set -e

echo "=========================================="
echo "Inicializando Apache Airflow (Versão Simplificada)"
echo "=========================================="

# Limpar tudo primeiro
echo "Limpando containers anteriores..."
docker-compose -f docker-compose-simple.yml down -v 2>/dev/null || true

# Subir apenas PostgreSQL primeiro
echo "Iniciando PostgreSQL..."
docker-compose -f docker-compose-simple.yml up -d postgres

# Aguardar PostgreSQL
echo "Aguardando PostgreSQL..."
sleep 10

# Inicializar o banco e criar usuário
echo "Inicializando banco de dados do Airflow..."
docker-compose -f docker-compose-simple.yml run --rm airflow-webserver bash -c "
  airflow db migrate &&
  airflow users create \
    --username airflow \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password airflow
" || echo "Banco já inicializado"

# Subir os serviços
echo "Iniciando Airflow Webserver e Scheduler..."
docker-compose -f docker-compose-simple.yml up -d airflow-webserver airflow-scheduler

# Aguardar containers iniciarem
sleep 5

# Ajustar permissões da pasta Resultados
echo "Ajustando permissões..."
docker-compose -f docker-compose-simple.yml exec -u root airflow-webserver chmod -R 777 /opt/airflow/Resultados || true

echo ""
echo "=========================================="
echo "✓ Airflow iniciado com sucesso!"
echo "=========================================="
echo ""
echo "⏳ Aguarde cerca de 30-60 segundos para o Airflow ficar pronto..."
echo ""
echo "Acesse: http://localhost:8080"
echo "Usuário: airflow"
echo "Senha: airflow"
echo ""
echo "Verificar status:"
echo "  docker-compose -f docker-compose-simple.yml ps"
echo ""
echo "Ver logs:"
echo "  docker-compose -f docker-compose-simple.yml logs -f"
echo ""
echo "Parar:"
echo "  docker-compose -f docker-compose-simple.yml down"
echo ""
