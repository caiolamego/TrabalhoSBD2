# Como subir o ambiente

Este projeto utiliza Docker Compose para disponibilizar Airflow (webserver, scheduler), PostgreSQL e o ambiente necessário para executar as DAGs e notebooks (Papermill/Spark).

## Pré-requisitos

- Docker e Docker Compose instalados
- 8GB+ de RAM disponível
- Portas livres:
  - 8081 (Airflow Web UI)
  - 5433 (PostgreSQL)

## Passo a passo

1) Clone o repositório

```bash
git clone https://github.com/caiolamego/TrabalhoSBD2.git
cd TrabalhoSBD2
```

2) Inicialize o projeto

```bash
make init
```

O comando acima irá:
- Criar diretórios necessários (airflow/, Resultados/, silver/, notebooks/, base_dados/)
- Ajustar permissões
- Buildar as imagens
- Subir os serviços (Postgres, Airflow webserver/scheduler)

3) Acesse os serviços

- Airflow Web UI: http://localhost:8081
- PostgreSQL: localhost:5433 (database: data_warehouse)

4) Disparar as DAGs automaticamente (opcional)

O serviço `airflow-trigger` (ativado com `docker compose up -d airflow-trigger`) executa `airflow/trigger_all_dags.sh` que:
- Aguarda o webserver ficar saudável
- Despausa todas as DAGs
- Dispara uma execução manual para cada DAG

Você pode acionar manualmente:

```bash
docker compose up -d airflow-trigger
```

## Principais comandos

Use o Makefile para tarefas comuns:

```bash
make help
make up
make down
make restart
make logs
make status
```

Para troubleshooting de permissões ou conexões, veja também:

```bash
make fix-permissions
make verify-connections
make check-all-databases
```

## Usuários e credenciais (padrão de desenvolvimento)

- Airflow UI: usuário `admin`, senha `admin123` (configurada via variáveis de ambiente)
- PostgreSQL (Data Warehouse): host `localhost`, porta `5433`, banco `data_warehouse`, user `airflow`, password `airflow`

Ajuste credenciais em `.env` conforme necessário.
