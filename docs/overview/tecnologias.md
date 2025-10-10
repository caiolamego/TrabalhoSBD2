## Tecnologias Principais

| Camada             | Tecnologia                                    | Descrição                              |
| ------------------ | --------------------------------------------- | -------------------------------------- |
| **Orquestração**   | [Apache Airflow](https://airflow.apache.org/) | Agendamento e automação dos pipelines  |
| **Processamento**  | [Apache Spark](https://spark.apache.org/)     | Transformações e análises distribuídas |
| **Armazenamento**  | PostgreSQL / Parquet / CSV / JSON             | Dados intermediários e resultados      |
| **Infraestrutura** | Docker Compose                                | Ambientes isolados e reproduzíveis     |
| **Linguagem**      | Python 3.12                                   | Scripts ETL, análise e automação       |

---

## Como Executar

### Pré-requisitos

* Docker e Docker Compose instalados
* 8GB+ RAM disponível
* Portas **8081** (Airflow) e **5433** (PostgreSQL) livres

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/TrabalhoSBD2.git
cd TrabalhoSBD2

# 2. Inicialize o ambiente completo
make init
```

Após o processo, os serviços estarão disponíveis em:

* **Airflow Web UI:** [http://localhost:8081](http://localhost:8081)
 Usuário: `admin` | 🔐 Senha: `admin123`
* **PostgreSQL:** `localhost:5433`
* **Data Warehouse:** `data_warehouse` (schemas: staging, bronze, silver, gold)

---
 **Conexão PostgreSQL**                  

 **Host:**          localhost            
 **Port:**          5433                 
 **Database:**      data_warehouse       
 **Username:**      airflow              
 **Password:**      airflow              
 **Show all databases:** (marcado)  



 ## Comandos Makefile Principais

```bash
# Ver comandos disponíveis
make help

# Inicializar projeto completo
make init

# Subir / parar / reiniciar serviços
make up
make down
make restart

# Monitoramento
make status       # Containers ativos
make logs         # Logs dos serviços
make logs-follow  # Logs em tempo real
make health       # Health check

# Limpeza
make clean        # Containers e volumes
make clean-all    # Tudo + imagens Docker
```