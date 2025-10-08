# Trabalho SBD2 - Coleta Automatizada de Dados FMI

Este projeto automatiza a coleta diária de dados econômicos do FMI (Fundo Monetário Internacional) usando Apache Airflow e Jupyter Notebooks.

## 📊 Bases de Dados Coletadas

O projeto coleta automaticamente dados de 4 bases do FMI:

1. **BOP** - Balance of Payments (Balança de Pagamentos)
2. **ER** - Exchange Rate (Taxa de Câmbio)
3. **IIP** - International Investment Position (Posição Internacional de Investimento)
4. **IRFCL** - International Reserves and Foreign Currency Liquidity (Reservas Internacionais e Liquidez em Moeda Estrangeira)

## 🚀 Como Usar

### Pré-requisitos

- Docker
- Docker Compose
- Git (opcional)

### Iniciar o Ambiente

1. Clone o repositório (se ainda não tiver):
```bash
git clone <seu-repositorio>
cd TrabalhoSBD2
```

2. Dê permissão de execução ao script de inicialização:
```bash
chmod +x init-airflow.sh
```

3. Execute o script de inicialização:
```bash
./init-airflow.sh
```

Este script irá:
- Limpar qualquer instalação anterior
- Inicializar o banco de dados PostgreSQL
- Criar o usuário admin do Airflow
- Subir todos os serviços (Airflow Webserver, Scheduler e PostgreSQL)
- Instalar automaticamente as dependências Python necessárias (sdmx1, pandas, papermill, ipykernel, jupyter)

### Acessar a Interface Web

Após a inicialização (aguarde cerca de 1-2 minutos), acesse:

**URL**: http://localhost:8080

**Credenciais**:
- Usuário: `airflow`
- Senha: `airflow`

## 📅 Agendamento das DAGs

Todas as DAGs estão configuradas para executar diariamente:

| DAG | Horário | Descrição |
|-----|---------|-----------|
| `bop_data_collection` | 02:00 | Coleta dados BOP |
| `er_data_collection` | 02:15 | Coleta dados de Taxa de Câmbio |
| `iip_data_collection` | 02:30 | Coleta dados IIP |
| `irfcl_data_collection` | 02:45 | Coleta dados IRFCL |

## 📂 Estrutura do Projeto

```
TrabalhoSBD2/
├── airflow/
│   ├── dags/              # DAGs do Airflow
│   │   ├── bop_dag.py
│   │   ├── er_dag.py
│   │   ├── iip_dag.py
│   │   └── irfcl_dag.py
│   ├── logs/              # Logs de execução
│   ├── plugins/           # Plugins do Airflow
│   └── config/            # Configurações
├── base_dados/
│   ├── BOP/
│   │   └── 2_coleta.ipynb
│   ├── ER/
│   │   └── 2_coleta.ipynb
│   ├── IIP/
│   │   └── 2_coleta.ipynb
│   └── IRFCL/
│       └── 2_coleta.ipynb
├── Resultados/            # Arquivos CSV gerados
│   ├── BOP.csv
│   ├── ER.csv
│   ├── IIP.csv
│   └── IRFCL.csv
├── docker-compose.yml     # Configuração do Docker
├── .env                   # Variáveis de ambiente
└── start-airflow.sh       # Script de inicialização
```

## 🔧 Comandos Úteis

### Gerenciar os Serviços

```bash
# Ver status dos containers
docker-compose -f docker-compose-simple.yml ps

# Ver logs em tempo real
docker-compose -f docker-compose-simple.yml logs -f

# Ver logs de um serviço específico
docker-compose -f docker-compose-simple.yml logs -f airflow-scheduler

# Parar todos os serviços
docker-compose -f docker-compose-simple.yml down

# Reiniciar os serviços
docker-compose -f docker-compose-simple.yml restart

# Limpar tudo (incluindo volumes)
docker-compose -f docker-compose-simple.yml down -v
```

### Executar uma DAG Manualmente

1. Acesse a interface web (http://localhost:8080)
2. Encontre a DAG desejada na lista
3. Clique no botão ▶️ (Play) à direita da DAG
4. Selecione "Trigger DAG"

Ou via linha de comando:

```bash
# Executar a DAG BOP
docker-compose -f docker-compose-simple.yml exec airflow-scheduler airflow dags trigger bop_data_collection

# Executar a DAG ER
docker-compose -f docker-compose-simple.yml exec airflow-scheduler airflow dags trigger er_data_collection

# Executar a DAG IIP
docker-compose -f docker-compose-simple.yml exec airflow-scheduler airflow dags trigger iip_data_collection

# Executar a DAG IRFCL
docker-compose -f docker-compose-simple.yml exec airflow-scheduler airflow dags trigger irfcl_data_collection
```

## 🐛 Troubleshooting

### Os serviços não sobem

1. Verifique se as portas 8080 e 5432 não estão em uso:
```bash
sudo lsof -i :8080
sudo lsof -i :5432
```

2. Limpe os containers antigos:
```bash
docker-compose -f docker-compose-simple.yml down -v
./init-airflow.sh
```

### DAG não aparece na interface

1. Verifique os logs do scheduler:
```bash
docker-compose -f docker-compose-simple.yml logs airflow-scheduler
```

2. Verifique se há erros de sintaxe nas DAGs:
```bash
docker-compose -f docker-compose-simple.yml exec airflow-scheduler airflow dags list
```

### Notebook não executa

1. Verifique se as dependências estão instaladas (sdmx1, pandas, papermill)
2. Verifique os logs da execução na pasta `airflow/logs/`
3. Execute manualmente para debug:
```bash
docker-compose -f docker-compose-simple.yml exec airflow-scheduler python -c "import sdmx, pandas, papermill; print('OK')"
```

## 📦 Dependências

As seguintes bibliotecas Python são instaladas automaticamente no container do Airflow:

- `sdmx1` - Para coletar dados do FMI
- `pandas` - Para manipulação de dados
- `papermill` - Para executar notebooks programaticamente
- `ipykernel` - Kernel Python para notebooks
- `jupyter` - Ambiente Jupyter

## 🔐 Segurança

**IMPORTANTE**: As credenciais padrão (`airflow/airflow`) são apenas para desenvolvimento local. Para produção:

1. Altere as credenciais no arquivo `.env`:
```bash
_AIRFLOW_WWW_USER_USERNAME=seu_usuario
_AIRFLOW_WWW_USER_PASSWORD=sua_senha_forte
```

2. Gere uma nova Fernet Key:
```bash
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

3. Adicione a key no `docker-compose.yml` em `AIRFLOW__CORE__FERNET_KEY`

## 📝 Notas

- Os notebooks originais em `base_dados/*/2_coleta.ipynb` não são modificados
- Cada execução gera um novo notebook de output com timestamp em `airflow/logs/`
- Os arquivos CSV são sobrescritos a cada execução em `Resultados/`
- O Airflow usa PostgreSQL como backend database
- O executor configurado é `LocalExecutor` (adequado para ambiente local/pequeno)

## 🤝 Contribuindo

Para adicionar novas DAGs ou modificar as existentes, edite os arquivos em `airflow/dags/`.

## 📄 Licença

Este projeto é parte do Trabalho SBD2.
