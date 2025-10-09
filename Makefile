# ==============================================
# TrabalhoSBD2 - Makefile para automação
# ==============================================

# Definir variáveis
DC = docker-compose -f docker-compose.yml
PROJECT_NAME = trabalho-sbd2

.PHONY: help build up down restart logs clean status health init

# ==============================================
# HELP - Lista todos os comandos disponíveis
# ==============================================
help:
	@echo "🏗️  TrabalhoSBD2 - Comandos Disponíveis:"
	@echo ""
	@echo "📦 Build & Deploy:"
	@echo "  make build          - Builda todas as imagens Docker"
	@echo "  make up             - Inicia todos os serviços"
	@echo "  make down           - Para todos os serviços"
	@echo "  make restart        - Reinicia todos os serviços"
	@echo ""
	@echo "🔍 Monitoramento:"
	@echo "  make logs           - Exibe logs de todos os serviços"
	@echo "  make logs-follow    - Exibe logs em tempo real"
	@echo "  make status         - Mostra status dos containers"
	@echo "  make health         - Verifica health dos serviços"
	@echo ""
	@echo "🧹 Limpeza:"
	@echo "  make clean          - Remove containers, networks e volumes"
	@echo "  make clean-all      - Remove tudo + imagens Docker"
	@echo ""
	@echo "⚙️  Configuração:"
	@echo "  make init           - Inicializa o projeto (primeira vez)"
	@echo "  make shell          - Acessa shell do container Airflow"
	@echo ""
	@echo "🌐 URLs úteis:"
	@echo "  - Airflow Web UI: http://localhost:8081"
	@echo "  - PostgreSQL: localhost:5433"

# ==============================================
# BUILD & DEPLOY
# ==============================================
build:
	@echo "🔨 Buildando todas as imagens Docker..."
	$(DC) build --pull --no-cache

up:
	@echo "🚀 Iniciando todos os serviços..."
	$(DC) up -d
	@echo "✅ Serviços iniciados!"
	@echo "📊 Airflow Web UI: http://localhost:8081"
	@echo "🗄️  PostgreSQL: localhost:5433"

down:
	@echo "🛑 Parando todos os serviços..."
	$(DC) down
	@echo "✅ Serviços parados!"

restart:
	@echo "🔄 Reiniciando serviços..."
	$(DC) down
	$(DC) up -d
	@echo "✅ Serviços reiniciados!"

# ==============================================
# MONITORAMENTO
# ==============================================
logs:
	@echo "📋 Exibindo logs dos serviços..."
	$(DC) logs --tail=100

logs-follow:
	@echo "📋 Acompanhando logs em tempo real..."
	$(DC) logs -f

status:
	@echo "📊 Status dos containers:"
	$(DC) ps

health:
	@echo "🏥 Verificando health dos serviços..."
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=$(PROJECT_NAME)"

# ==============================================
# LIMPEZA
# ==============================================
clean:
	@echo "🧹 Removendo containers, networks e volumes..."
	$(DC) down -v --remove-orphans
	@docker system prune -f
	@echo "✅ Limpeza concluída!"

clean-all:
	@echo "🧹 Removendo tudo (incluindo imagens)..."
	$(DC) down -v --remove-orphans --rmi all
	@docker system prune -af
	@echo "✅ Limpeza completa concluída!"

# ==============================================
# CONFIGURAÇÃO
# ==============================================
init:
	@echo "⚙️  Inicializando projeto TrabalhoSBD2..."
	@echo "📁 Criando diretórios necessários..."
	@mkdir -p airflow/{dags,logs,plugins,config}
	@mkdir -p {base_dados,Resultados,spark_config,notebooks}
	@echo "🔨 Buildando imagens..."
	$(MAKE) build
	@echo "🚀 Iniciando serviços..."
	$(MAKE) up
	@echo ""
	@echo "✅ Projeto inicializado com sucesso!"
	@echo "📊 Acesse o Airflow em: http://localhost:8081"
	@echo "👤 Usuário: admin | Senha: admin123"

shell:
	@echo "🐚 Acessando shell do container Airflow..."
	$(DC) exec airflow-webserver bash

# ==============================================
# UTILITÁRIOS DE DESENVOLVIMENTO
# ==============================================
airflow-logs:
	@echo "📋 Logs do Airflow..."
	$(DC) logs airflow-webserver airflow-scheduler

db-logs:
	@echo "📋 Logs do PostgreSQL..."
	$(DC) logs postgres

test-connection:
	@echo "🔗 Testando conexão com banco de dados..."
	$(DC) exec postgres psql -U airflow -d airflow -c "SELECT version();"

backup-db:
	@echo "💾 Fazendo backup do banco de dados..."
	@mkdir -p backups
	$(DC) exec postgres pg_dump -U airflow airflow > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup salvo em backups/"