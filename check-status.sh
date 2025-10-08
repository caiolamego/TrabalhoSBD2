#!/bin/bash

# Script para verificar o status do Airflow

echo "╔════════════════════════════════════════════════════════╗"
echo "║         STATUS DO APACHE AIRFLOW                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando!"
    echo "   Inicie o Docker e tente novamente."
    exit 1
fi

echo "✅ Docker está rodando"
echo ""

# Verificar containers
echo "📦 CONTAINERS:"
docker-compose ps

echo ""
echo "🌐 INTERFACE WEB:"
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Airflow está acessível em http://localhost:8080"
else
    echo "❌ Airflow não está acessível"
    echo "   Execute: ./start-airflow.sh"
fi

echo ""
echo "📊 ÚLTIMOS LOGS (últimas 10 linhas):"
docker-compose logs --tail=10 airflow-scheduler 2>/dev/null || echo "Scheduler não está rodando"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Comandos úteis:"
echo "  ./start-airflow.sh     - Iniciar Airflow"
echo "  ./stop-airflow.sh      - Parar Airflow"
echo "  docker-compose logs -f - Ver logs em tempo real"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
