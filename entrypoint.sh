#!/bin/bash
# ==============================================
# Custom Entrypoint for Airflow Container
# Ensures proper permissions on startup
# ==============================================

set -e

echo "🔧 Custom Entrypoint - Verificando permissões..."

# Diretórios que precisam de permissão de escrita
WRITABLE_DIRS=(
    "/opt/airflow/logs"
    "/opt/airflow/Resultados"
    "/opt/airflow/silver"
    "/opt/airflow/notebooks"
    "/opt/airflow/base_dados"
)

# Criar e ajustar permissões dos diretórios
for dir in "${WRITABLE_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "  ➕ Criando diretório: $dir"
        mkdir -p "$dir"
    fi
    
    # Ajustar permissões (777 = rwxrwxrwx)
    echo "  🔐 Ajustando permissões: $dir"
    chmod -R 777 "$dir" 2>/dev/null || true
done

echo "✅ Permissões verificadas!"

# Executar o entrypoint original do Airflow
exec /entrypoint "$@"
