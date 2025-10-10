
## Pipelines ETL

Os pipelines são executados automaticamente pelo Airflow em horários configurados.
Cada DAG representa uma coleta e transformação de um dataset específico do FMI:

| DAG                     | Fonte FMI | Descrição                             | Horário |
| ----------------------- | --------- | ------------------------------------- | ------- |
| `bop_data_collection`   | BOP       | Balança de Pagamentos                 | 02:00   |
| `er_data_collection`    | ER        | Taxas de Câmbio                       | 02:15   |
| `iip_data_collection`   | IIP       | Posição de Investimento Internacional | 02:30   |
| `irfcl_data_collection` | IRFCL     | Reservas Internacionais               | 02:45   |

---