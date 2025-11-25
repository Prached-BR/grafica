# grafica
O script cria o schema `grafica` e as tabelas, FKs, checks e índices. - Se você precisar MySQL/SQL Server, gerar scripts equivalentes.

# DDL da Gráfica

Arquivos:
- `sql/postgres/ddl.sql` — DDL para PostgreSQL (schema `grafica`).
- `sql/postgres/dml_insert.sql` — Inserções de dados consistentes com o modelo.
- `sql/postgres/dml_queries.sql` — Consultas SELECT de exemplo.
- `sql/postgres/dml_updates_deletes.sql` — Exemplos de UPDATE e DELETE.

## Como utilizar (PostgreSQL)
- Crie o banco de dados e rode o script:

```sql
-- no psql
CREATE DATABASE grafica_db;
\c grafica_db
\i sql/postgres/ddl.sql
\i sql/postgres/dml_insert.sql
\i sql/postgres/dml_queries.sql
\i sql/postgres/dml_updates_deletes.sql
```

Ou com `psql` via terminal:

```bash
psql -U seu_usuario -d grafica_db -f sql/postgres/ddl.sql
psql -U seu_usuario -d grafica_db -f sql/postgres/dml_insert.sql
psql -U seu_usuario -d grafica_db -f sql/postgres/dml_queries.sql
psql -U seu_usuario -d grafica_db -f sql/postgres/dml_updates_deletes.sql
```

Observações:
- O script cria o schema `grafica` e as tabelas, FKs, checks e índices.
- Se você precisar MySQL/SQL Server, gerar scripts equivalentes.

## Melhorias incluídas
- Trigger `fn_item_pedido_calc_subtotal` garante `subtotal = quantidade * preco_unitario - desconto` em `item_pedido`.
- View `vw_pedido_totais`: `total_itens`, `total_pago` (considera reembolso negativo) e `saldo_a_receber` por pedido.
- View `vw_cliente_financeiro`: resumo financeiro por cliente (quantidade de pedidos, totais e saldo).

### Consultas úteis
```sql
SET search_path TO grafica;

-- Totais por pedido
SELECT * FROM vw_pedido_totais ORDER BY id_pedido;

-- Financeiro por cliente
SELECT * FROM vw_cliente_financeiro ORDER BY nome;

-- Itens com pedido/serviço
SELECT i.id_item, p.id_pedido, s.nome FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
ORDER BY p.id_pedido;
```
