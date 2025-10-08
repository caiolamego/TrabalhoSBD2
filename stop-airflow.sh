#!/bin/bash

# Script para parar o Apache Airflow

set -e

echo "=========================================="
echo "Parando Apache Airflow"
echo "=========================================="

docker-compose down

echo ""
echo "✓ Airflow parado com sucesso!"
echo ""
echo "Para remover completamente (incluindo volumes):"
echo "  docker-compose down -v"
echo ""
echo "Para reiniciar:"
echo "  ./start-airflow.sh"
echo ""
