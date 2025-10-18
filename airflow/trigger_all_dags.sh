#!/usr/bin/env bash
## ==============================================
# trigger_all_dags.sh
#
# Script profissional e organizado para:
# - Aguardar o Airflow Webserver ficar disponível
# - Listar todos os DAGs via API REST
# - Despausar cada DAG (para permitir execução)
# - Disparar uma DAG run para cada DAG
#
# Coloque esse arquivo em `airflow/` e monte-o no container
# para ser executado uma vez na inicialização pelo docker-compose.
## ==============================================

set -euo pipefail

### Configuráveis
AIRFLOW_HOST=${AIRFLOW_HOST:-http://airflow-webserver:8080}
API_USER=${API_USER:-${_AIRFLOW_WWW_USER_USERNAME:-admin}}
API_PASS=${API_PASS:-${_AIRFLOW_WWW_USER_PASSWORD:-admin}}
TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-120}
SLEEP_INTERVAL=${SLEEP_INTERVAL:-5}

LOG_PREFIX="[trigger_all_dags]"

echo "${LOG_PREFIX} Iniciando script de disparo de DAGs"

start_ts=$(date +%s)

echo "${LOG_PREFIX} Aguardando Webserver em ${AIRFLOW_HOST}/health (timeout ${TIMEOUT_SECONDS}s)..."
until curl -sSf --max-time 5 "${AIRFLOW_HOST}/health" >/dev/null 2>&1; do
    now=$(date +%s)
    elapsed=$((now - start_ts))
    if [ "$elapsed" -ge "$TIMEOUT_SECONDS" ]; then
        echo "${LOG_PREFIX} Erro: tempo excedido ao aguardar webserver" >&2
        exit 2
    fi
    echo "${LOG_PREFIX} Webserver não disponível ainda. Aguardando ${SLEEP_INTERVAL}s..."
    sleep ${SLEEP_INTERVAL}
done

echo "${LOG_PREFIX} Webserver disponível. Continuando..."

# Helper: chamada à API com autenticação básica
api_call() {
    method="$1"; shift
    url="$1"; shift
    data="${1:-}"
    headers=( -u "${API_USER}:${API_PASS}" -H "Content-Type: application/json" )
    if [ -n "$data" ]; then
        curl -sS "${headers[@]}" -X "$method" "$url" -d "$data"
    else
        curl -sS "${headers[@]}" -X "$method" "$url"
    fi
}

echo "${LOG_PREFIX} Consultando lista de DAGs via API..."
dag_list_json=$(api_call GET "${AIRFLOW_HOST}/api/v1/dags?only_active=false&limit=1000" || true)
if [ -z "${dag_list_json}" ]; then
    echo "${LOG_PREFIX} Falha ao obter lista de DAGs ou resposta vazia" >&2
    exit 3
fi

# Extrair dag_ids (usa jq se disponível, fallback para grep/sed)
if command -v jq >/dev/null 2>&1; then
    dag_ids=$(echo "$dag_list_json" | jq -r '.dags[].dag_id')
else
    # simples e frágil, mas funciona em ambientes sem jq
    dag_ids=$(echo "$dag_list_json" | grep -o '"dag_id"[[:space:]]*:[[:space:]]*"[^"]\+"' | sed -E 's/"dag_id"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/')
fi

if [ -z "$(echo "$dag_ids" | tr -d '[:space:]')" ]; then
    echo "${LOG_PREFIX} Nenhum DAG encontrado na API." >&2
    exit 0
fi

echo "${LOG_PREFIX} Encontrados os seguintes DAGs:";
echo "$dag_ids" | sed 's/^/  - /'

for dag in $dag_ids; do
    echo "${LOG_PREFIX} Processando DAG: $dag"

    # 1) Despausar o DAG (necessary to allow manual runs if paused)
    echo "${LOG_PREFIX}  - Despausando $dag"
    airflow dags unpause "$dag" 2>/dev/null || echo "${LOG_PREFIX}    ⚠️  Falha ao despausar (DAG pode já estar despausado)"

    # 2) Criar uma DAG run usando o CLI do Airflow
    run_id="manual__$(date +%Y%m%dT%H%M%S)"
    echo "${LOG_PREFIX}  - Criando DAG run ${run_id}"
    airflow dags trigger "$dag" --run-id "$run_id" 2>/dev/null || \
        echo "${LOG_PREFIX}    ⚠️  Falha ao criar DAG run para ${dag}"

done

echo "${LOG_PREFIX} Disparo de DAGs finalizado."

exit 0
