SET search_path TO grafica;

SELECT p.id_pedido, c.nome, v.total_itens, v.total_pago, v.saldo_a_receber
FROM vw_pedido_totais v
JOIN pedido p ON p.id_pedido = v.id_pedido
JOIN cliente c ON c.id_cliente = p.id_cliente
ORDER BY v.saldo_a_receber DESC;

SELECT i.id_item, c.nome, s.nome AS servico, i.quantidade, i.preco_unitario
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN cliente c ON p.id_cliente = c.id_cliente
JOIN servico s ON i.id_servico = s.id_servico
WHERE p.status IN ('Aprovado','Em_producao')
ORDER BY c.nome, s.nome
LIMIT 20;

SELECT d.id_documento, i.id_item, d.nome_arquivo, d.confidencial, d.data_recebimento
FROM documento d
JOIN item_pedido i ON d.id_item = i.id_item
WHERE d.confidencial = TRUE
ORDER BY d.data_recebimento DESC
LIMIT 10;

SELECT m.id_material, m.nome, m.nivel_estoque, m.ponto_reposicao
FROM material m
WHERE m.nivel_estoque <= m.ponto_reposicao
ORDER BY m.nivel_estoque;

SELECT e.id_execucao, c.nome AS cliente, s.nome AS servico, f.nome AS funcionario, m.modelo AS maquina, e.status, e.inicio, e.fim
FROM execucao_servico e
JOIN item_pedido i ON e.id_item = i.id_item
JOIN servico s ON i.id_servico = s.id_servico
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN cliente c ON p.id_cliente = c.id_cliente
JOIN funcionario f ON e.id_funcionario = f.id_funcionario
JOIN maquina m ON e.id_maquina = m.id_maquina
ORDER BY e.inicio DESC
LIMIT 10;
