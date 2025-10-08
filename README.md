# Apache Airflow - Coleta Automatizada de Dados FMI

## Início Rápido

Execute o script de inicialização:

```bash
./init-airflow.sh
```

Aguarde 30-60 segundos e acesse:
- **URL**: http://localhost:8080
- **Usuário**: `airflow`
- **Senha**: `airflow`

## DAGs Disponíveis

Todas executam diariamente de madrugada:

- `bop_data_collection` (02:00)
- `er_data_collection` (02:15)  
- `iip_data_collection` (02:30)
- `irfcl_data_collection` (02:45)

## Documentação Completa

Veja [AIRFLOW_README.md](AIRFLOW_README.md) para instruções detalhadas.

## Comandos Principais

```bash
# Ver status
docker-compose -f docker-compose-simple.yml ps

# Ver logs
docker-compose -f docker-compose-simple.yml logs -f

# Parar
docker-compose -f docker-compose-simple.yml down
```

## Resultados

Os arquivos CSV gerados ficam em `./Resultados/`:
- BOP.csv
- ER.csv
- IIP.csv
- IRFCL.csv
