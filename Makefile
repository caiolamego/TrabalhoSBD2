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
	@echo "🔧 Permissões & Troubleshooting:"
	@echo "  make fix-permissions    - Corrige permissões de arquivos/diretórios"
	@echo "  make check-permissions  - Verifica permissões atuais"
	@echo "  make quick-fix          - Fix rápido (permissões + restart)"
	@echo "  make emergency-restart  - Restart emergencial completo"
	@echo "  make test-connections   - Testa conexões PostgreSQL"
	@echo "  make init-connections   - Configura conexões do Airflow"
	@echo ""
	@echo "�🗄️  Data Warehouse:"
	@echo "  make dw-shell       - Acessa shell do PostgreSQL (Data Warehouse)"
	@echo "  make dw-connect     - Conecta ao banco data_warehouse via psql"
	@echo "  make dw-backup      - Faz backup do banco data_warehouse"
	@echo "  make dw-restore     - Restaura backup do data_warehouse"
	@echo "  make dw-list-tables - Lista todas as tabelas do data_warehouse"
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
	@echo "  - Data Warehouse DB: data_warehouse"

# ==============================================
# BUILD & DEPLOY
# ==============================================
build:
	@echo "🔨 Buildando todas as imagens Docker..."
	@echo "⚠️  Removendo volumes antigos para garantir inicialização limpa..."
	$(DC) down -v
	@echo "🏗️  Buildando imagens..."
	$(DC) build --pull --no-cache

up:
	@echo "🚀 Iniciando todos os serviços..."
	$(DC) up -d
	@echo "✅ Serviços iniciados!"
	@echo "📊 Airflow Web UI: http://localhost:8081"
	@echo "🗄️  PostgreSQL: localhost:5433"
	@echo "📂 Data Warehouse: data_warehouse (schemas: staging, bronze, silver, gold)"

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
	@mkdir -p {base_dados,Resultados,spark_config,notebooks,db_init}
	@echo "🔧 Corrigindo permissões..."
	@chmod +x fix-permissions.sh
	@./fix-permissions.sh
	@echo "🧹 Limpando volumes antigos..."
	$(DC) down -v 2>/dev/null || true
	@echo "🔨 Buildando imagens..."
	$(MAKE) build
	@echo "🚀 Iniciando serviços..."
	$(MAKE) up
	@echo ""
	@echo "✅ Projeto inicializado com sucesso!"
	@echo "📊 Acesse o Airflow em: http://localhost:8081"
	@echo "👤 Usuário: admin | Senha: admin123"
	@echo "🗄️  PostgreSQL: localhost:5433"
	@echo "📂 Data Warehouse: data_warehouse"
	@echo ""
	@echo "⏳ Aguarde ~30 segundos para o Airflow inicializar completamente..."

shell:
	@echo "🐚 Acessando shell do container Airflow..."
	$(DC) exec airflow-webserver bash

# ==============================================
# PERMISSÕES & TROUBLESHOOTING
# ==============================================
fix-permissions:
	@echo "🔧 Corrigindo permissões de arquivos e diretórios..."
	@chmod +x fix-permissions.sh entrypoint.sh 2>/dev/null || true
	@./fix-permissions.sh
	@echo "✅ Permissões corrigidas!"

check-permissions:
	@echo "🔍 Verificando permissões dos diretórios importantes:"
	@echo "  airflow/     -> $$(stat -c '%a %U:%G' airflow 2>/dev/null || echo 'N/A')"
	@echo "  Resultados/  -> $$(stat -c '%a %U:%G' Resultados 2>/dev/null || echo 'N/A')"
	@echo "  silver/      -> $$(stat -c '%a %U:%G' silver 2>/dev/null || echo 'N/A')"
	@echo "  notebooks/   -> $$(stat -c '%a %U:%G' notebooks 2>/dev/null || echo 'N/A')"
	@echo "  base_dados/  -> $$(stat -c '%a %U:%G' base_dados 2>/dev/null || echo 'N/A')"

quick-fix:
	@echo "🚀 Executando fix rápido..."
	@$(MAKE) fix-permissions
	@$(MAKE) restart
	@echo "✅ Fix rápido concluído!"

emergency-restart:
	@echo "🚨 RESTART EMERGENCIAL..."
	@echo "🛑 Parando todos os serviços..."
	@$(DC) down
	@echo "🔧 Corrigindo permissões..."
	@chmod +x fix-permissions.sh entrypoint.sh 2>/dev/null || true
	@./fix-permissions.sh
	@echo "🚀 Reiniciando serviços..."
	@$(DC) up -d
	@echo "✅ Sistema reiniciado!"
	@echo "📊 Acesse: http://localhost:8081"

test-connections:
	@echo "🔍 Testando conexões PostgreSQL..."
	@$(DC) exec airflow-webserver airflow connections test postgres_default || true
	@$(DC) exec airflow-webserver airflow connections test postgres_dw || true

init-connections:
	@echo "🔗 Configurando conexões do Airflow..."
	@$(DC) exec airflow-webserver /opt/airflow/config/init_connections.sh
	@echo "✅ Conexões configuradas!"

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

# ==============================================
# DATA WAREHOUSE
# ==============================================
dw-shell:
	@echo "🗄️  Acessando shell do PostgreSQL (Data Warehouse)..."
	$(DC) exec postgres bash

dw-connect:
	@echo "🔗 Conectando ao banco data_warehouse..."
	$(DC) exec postgres psql -U airflow -d data_warehouse

dw-connect-dw-user:
	@echo "🔗 Conectando ao banco data_warehouse com usuário dw_user..."
	$(DC) exec postgres psql -U dw_user -d data_warehouse

dw-backup:
	@echo "💾 Fazendo backup do Data Warehouse..."
	@mkdir -p backups
	$(DC) exec postgres pg_dump -U airflow data_warehouse > backups/dw_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup do Data Warehouse salvo em backups/"

dw-restore:
	@echo "📥 Para restaurar um backup, execute:"
	@echo "cat backups/<arquivo_backup>.sql | docker-compose exec -T postgres psql -U airflow -d data_warehouse"

dw-list-tables:
	@echo "📋 Listando todas as tabelas do Data Warehouse..."
	@echo ""
	@echo "=== SCHEMA: staging ==="
	@$(DC) exec postgres psql -U airflow -d data_warehouse -c "\dt staging.*" || true
	@echo ""
	@echo "=== SCHEMA: bronze ==="
	@$(DC) exec postgres psql -U airflow -d data_warehouse -c "\dt bronze.*" || true
	@echo ""
	@echo "=== SCHEMA: silver ==="
	@$(DC) exec postgres psql -U airflow -d data_warehouse -c "\dt silver.*" || true
	@echo ""
	@echo "=== SCHEMA: gold ==="
	@$(DC) exec postgres psql -U airflow -d data_warehouse -c "\dt gold.*" || true

dw-list-schemas:
	@echo "📂 Listando schemas do Data Warehouse..."
	$(DC) exec postgres psql -U airflow -d data_warehouse -c "\dn+"

dw-info:
	@echo "📊 Informações do Data Warehouse:"
	@echo ""
	@echo "🗄️  Banco de dados: data_warehouse"
	@echo "👤 Usuário principal: airflow"
	@echo "👤 Usuário DW: dw_user"
	@echo "📂 Schemas disponíveis: staging, bronze, silver, gold"
	@echo ""
	@echo "Para conectar via psql:"
	@echo "  make dw-connect"
	@echo ""
	@echo "Para listar tabelas:"
	@echo "  make dw-list-tables"

# ==============================================
# VERIFICAÇÃO DE CONEXÕES E DADOS
# ==============================================
check-all-databases:
	@echo "🔍 VERIFICANDO TODOS OS BANCOS DE DADOS..."
	@echo ""
	@echo "================================================"
	@echo "📊 BANCO: airflow (metadados do Airflow)"
	@echo "================================================"
	@echo "Conexão Airflow: postgres_default"
	@echo "User: airflow | Database: airflow"
	@echo ""
	@echo "--- Schemas disponíveis ---"
	@$(DC) exec postgres psql -U airflow -d airflow -c "\dn" || true
	@echo ""
	@echo "--- Tabelas no schema bronze ---"
	@$(DC) exec postgres psql -U airflow -d airflow -c "\dt bronze.*" || true
	@echo ""
	@echo "--- Tabelas no schema silver ---"
	@$(DC) exec postgres psql -U airflow -d airflow -c "\dt silver.*" || true
	@echo ""
	@echo "================================================"
	@echo "🏦 BANCO: data_warehouse (dados analíticos)"
	@echo "================================================"
	@echo "Conexão Airflow: postgres_dw"
	@echo "User: dw_user | Database: data_warehouse"
	@echo ""
	@echo "--- Schemas disponíveis ---"
	@$(DC) exec postgres psql -U dw_user -d data_warehouse -c "\dn" || true
	@echo ""
	@echo "--- Tabelas no schema bronze ---"
	@$(DC) exec postgres psql -U dw_user -d data_warehouse -c "\dt bronze.*" || true
	@echo ""
	@echo "--- Tabelas no schema silver ---"
	@$(DC) exec postgres psql -U dw_user -d data_warehouse -c "\dt silver.*" || true
	@echo ""
	@echo "✅ Verificação completa!"

check-bop-data:
	@echo "🔍 VERIFICANDO ONDE ESTÁ A TABELA bop_clean..."
	@echo ""
	@echo "📊 Verificando banco AIRFLOW..."
	@$(DC) exec postgres psql -U airflow -d airflow -c "SELECT 'AIRFLOW - bronze.bop_clean' as location, COUNT(*) as total_rows FROM bronze.bop_clean;" 2>/dev/null || echo "❌ Não encontrada no airflow.bronze"
	@echo ""
	@echo "🏦 Verificando banco DATA_WAREHOUSE..."
	@$(DC) exec postgres psql -U dw_user -d data_warehouse -c "SELECT 'DATA_WAREHOUSE - bronze.bop_clean' as location, COUNT(*) as total_rows FROM bronze.bop_clean;" 2>/dev/null || echo "❌ Não encontrada no data_warehouse.bronze"
	@echo ""
	@echo "✅ Verificação completa!"

verify-connections:
	@echo "🔗 VERIFICANDO CONEXÕES DO AIRFLOW..."
	@echo ""
	@echo "--- Lista de conexões configuradas ---"
	@$(DC) exec airflow-webserver airflow connections list
	@echo ""
	@echo "--- Testando postgres_default (banco airflow) ---"
	@$(DC) exec airflow-webserver airflow connections test postgres_default || true
	@echo ""
	@echo "--- Testando postgres_dw (banco data_warehouse) ---"
	@$(DC) exec airflow-webserver airflow connections test postgres_dw || true
	@echo ""
	@echo "✅ Testes de conexão completos!"
