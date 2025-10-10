## Arquitetura do Sistema

O sistema deverá seguir a arquitetura respeitando o Star Schema com as camadas Raw, Silver e Gold. Atualmente, a estrutura se encontra em andamento já na camada Silver, da seguinte maneira:

```
TrabalhoSBD2/
├── docker-compose.yml      # Orquestração dos serviços (Airflow, Spark, Postgres)
├── Makefile               # Automação de build e execução
├── .env                    # Variáveis de ambiente
├── requirements.txt        # Dependências Python
│
├── airflow/                # Configurações e DAGs do Airflow
│   ├── dags/                  # Pipelines ETL (coleta, limpeza e transformação)
│   ├── logs/                  # Logs de execução
│   ├── plugins/               # Plugins e hooks customizados
│   └── config/                # Configurações adicionais
│
├── base_dados/             # Dados brutos e processados
│   ├── BOP/                   # Balance of Payments
│   ├── ER/                    # Exchange Rates
│   ├── IIP/                   # International Investment Position
│   ├── IRFCL/                 # International Reserves
│   └── Resultados/            # Saídas finais dos pipelines
├
├── Silver/ 
│   ├── modelagem/  
|
├── Gold/ 
|______
├── spark_config/           # Configurações e scripts Spark
├── notebooks/              # Jupyter notebooks analíticos
└── Resultados/             # Indicadores agregados e relatórios
```
