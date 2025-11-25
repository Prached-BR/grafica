SET search_path TO grafica;

UPDATE pedido SET status = 'Concluido'
WHERE observacoes = 'Pedido João';

UPDATE item_pedido SET desconto = 5.00
WHERE id_item IN (
  SELECT i.id_item
  FROM item_pedido i
  JOIN pedido p ON i.id_pedido = p.id_pedido
  JOIN cliente c ON p.id_cliente = c.id_cliente
  JOIN servico s ON i.id_servico = s.id_servico
  WHERE c.documento = '12345678000199' AND s.nome = 'Digitalizacao c/OCR'
);

UPDATE material SET nivel_estoque = nivel_estoque + 1000
WHERE nome = 'Papel A4 75g';

DELETE FROM documento
WHERE confidencial = TRUE AND data_recebimento < CURRENT_DATE - INTERVAL '1 year';

DELETE FROM movimento_estoque
WHERE referencia = 'INI2025';

DELETE FROM pagamento
WHERE id_pedido IN (SELECT id_pedido FROM pedido WHERE observacoes = 'Pedido João') AND status = 'reembolsado';
