#!/bin/bash

# Script de inicialização do ambiente Airflow
# Este script configura e inicia o Apache Airflow com Docker

set -e

echo "=========================================="
echo "Inicializando Apache Airflow"
echo "=========================================="

# Criar diretórios necessários se não existirem
echo "Criando estrutura de diretórios..."
mkdir -p airflow/dags airflow/logs airflow/plugins airflow/config Resultados

# Verificar se .env existe, se não, criar
if [ ! -f .env ]; then
    echo "Criando arquivo .env..."
    cat > .env << EOF
AIRFLOW_UID=50000
AIRFLOW_PROJ_DIR=.
_AIRFLOW_WWW_USER_USERNAME=airflow
_AIRFLOW_WWW_USER_PASSWORD=airflow
EOF
fi

# Inicializar o banco de dados do Airflow
echo "Inicializando banco de dados..."
docker-compose up airflow-init

# Subir os serviços
echo "Iniciando serviços do Airflow..."
docker-compose up -d

echo ""
echo "=========================================="
echo "✓ Airflow iniciado com sucesso!"
echo "=========================================="
echo ""
echo "Acesse a interface web em: http://localhost:8080"
echo "Usuário: airflow"
echo "Senha: airflow"
echo ""
echo "DAGs configuradas:"
echo "  - bop_data_collection    (2:00 AM diariamente)"
echo "  - er_data_collection     (2:15 AM diariamente)"
echo "  - iip_data_collection    (2:30 AM diariamente)"
echo "  - irfcl_data_collection  (2:45 AM diariamente)"
echo ""
echo "Comandos úteis:"
echo "  docker-compose ps              # Ver status dos containers"
echo "  docker-compose logs -f         # Ver logs em tempo real"
echo "  docker-compose down            # Parar os serviços"
echo "  docker-compose restart         # Reiniciar os serviços"
echo ""
