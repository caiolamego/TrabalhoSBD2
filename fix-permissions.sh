#!/bin/bash
# ==============================================
# Script de Correção de Permissões
# TrabalhoSBD2 - Fix all permission issues
# ==============================================

set -e

echo "🔧 Iniciando correção de permissões..."

# Definir UID do Airflow
AIRFLOW_UID=${AIRFLOW_UID:-50000}

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📁 Corrigindo permissões dos diretórios...${NC}"

# Lista de diretórios que precisam de permissões corretas
directories=(
    "airflow"
    "airflow/dags"
    "airflow/logs"
    "airflow/plugins"
    "airflow/config"
    "base_dados"
    "Resultados"
    "silver"
    "spark_config"
    "notebooks"
    "postgres"
)

# Criar diretórios se não existirem e ajustar permissões
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "  ➕ Criando: $dir"
        mkdir -p "$dir"
    fi
    
    echo "  🔐 Ajustando permissões: $dir"
    # Dar ownership para o usuário atual e permissão total
    sudo chown -R $USER:$USER "$dir" 2>/dev/null || chown -R $USER:$USER "$dir"
    chmod -R 777 "$dir"
done

echo -e "${YELLOW}📝 Corrigindo permissões de arquivos específicos...${NC}"

# Ajustar permissões de arquivos específicos
find . -type f -name "*.sh" -exec chmod +x {} \;
find . -type f -name "*.ipynb" -exec chmod 666 {} \;
find . -type f -name "*.py" -exec chmod 666 {} \;

echo -e "${YELLOW}🐳 Ajustando permissões para containers Docker...${NC}"

# Garantir que o Airflow UID pode escrever em todos os lugares
echo "  🔐 Aplicando permissões 777 (read/write/execute para todos)..."
chmod -R 777 airflow/ Resultados/ silver/ notebooks/ base_dados/ spark_config/ 2>/dev/null || true

echo -e "${GREEN}✅ Permissões corrigidas com sucesso!${NC}"
echo ""
echo "📊 Resumo das permissões:"
echo "  • airflow/     -> $(stat -c '%a' airflow)"
echo "  • Resultados/  -> $(stat -c '%a' Resultados)"
echo "  • silver/      -> $(stat -c '%a' silver)"
echo "  • notebooks/   -> $(stat -c '%a' notebooks)"
echo ""
echo -e "${GREEN}🚀 Agora você pode executar: docker-compose up -d${NC}"
