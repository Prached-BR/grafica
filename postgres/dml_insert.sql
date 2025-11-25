SET search_path TO grafica;

INSERT INTO cliente (nome, tipo, documento, email, telefone, logradouro, numero, bairro, cidade, estado, cep)
VALUES
('João Silva', 'PF', '12345678901', 'joao@example.com', '11999990000', 'Rua A', '100', 'Centro', 'São Paulo', 'SP', '01000-000'),
('Empresa Alpha Ltda', 'PJ', '12345678000199', 'contato@alpha.com', '1133334444', 'Av. Industrial', '500', 'Distrito', 'Santos', 'SP', '11000-000'),
('Maria Souza', 'PF', '98765432100', 'maria@example.com', '21988887777', 'Rua B', '200', 'Copacabana', 'Rio de Janeiro', 'RJ', '22000-000');

INSERT INTO funcionario (nome, cargo, setor, email, telefone, data_admissao)
VALUES
('Ana Lima', 'Atendente', 'Atendimento', 'ana@grafica.com', '11911112222', CURRENT_DATE - INTERVAL '400 days'),
('Bruno Reis', 'Designer', 'Design', 'bruno@grafica.com', '11922223333', CURRENT_DATE - INTERVAL '300 days'),
('Carlos Melo', 'Operador', 'Produção', 'carlos@grafica.com', '11933334444', CURRENT_DATE - INTERVAL '200 days'),
('Diana Rocha', 'Entregador', 'Entrega', 'diana@grafica.com', '11944445555', CURRENT_DATE - INTERVAL '100 days');

INSERT INTO servico (nome, categoria, descricao, preco_base, unidade)
VALUES
('Impressao PB', 'Impressão', 'Impressão preto e branco', 0.20, 'por página'),
('Impressao Colorida', 'Impressão', 'Impressão colorida', 0.60, 'por página'),
('Laminacao', 'Acabamento', 'Laminação/plastificação', 0.50, 'por unidade'),
('Digitalizacao c/OCR', 'Digitalização', 'Digitalização com OCR', 1.20, 'por página'),
('Entrega Local', 'Logística', 'Entrega em área local', 20.00, 'por pedido');

INSERT INTO maquina (tipo, modelo, fabricante, numero_serie, data_aquisicao)
VALUES
('impressora', 'HP Laser 4000', 'HP', 'HP-4000-XYZ', CURRENT_DATE - INTERVAL '800 days'),
('scanner', 'Epson ScanPro', 'Epson', 'SCN-EP-123', CURRENT_DATE - INTERVAL '700 days'),
('laminadora', 'LaminX 200', 'LamiCo', 'LAM-200-ABC', CURRENT_DATE - INTERVAL '600 days'),
('plotter', 'Canon Plot 900', 'Canon', 'PLT-900-CAN', CURRENT_DATE - INTERVAL '500 days');

INSERT INTO material (nome, tipo, unidade, nivel_estoque, ponto_reposicao)
VALUES
('Papel A4 75g', 'papel', 'folha', 5000, 1000),
('Tinta CMYK', 'tinta', 'ml', 2000, 500);

INSERT INTO pedido (id_cliente, status, prazo_entrega, canal, observacoes)
SELECT id_cliente, 'Aprovado', CURRENT_DATE + INTERVAL '5 days', 'presencial', 'Pedido João'
FROM cliente WHERE documento = '12345678901';

INSERT INTO pedido (id_cliente, status, prazo_entrega, canal, observacoes)
SELECT id_cliente, 'Orçado', CURRENT_DATE + INTERVAL '10 days', 'online', 'Pedido Empresa Alpha'
FROM cliente WHERE documento = '12345678000199';

INSERT INTO pedido (id_cliente, status, prazo_entrega, canal, observacoes)
SELECT id_cliente, 'Em_producao', CURRENT_DATE + INTERVAL '7 days', 'presencial', 'Pedido Maria'
FROM cliente WHERE documento = '98765432100';

INSERT INTO item_pedido (id_pedido, id_servico, quantidade, preco_unitario, desconto, especificacoes)
SELECT p.id_pedido, s.id_servico, 100, 0.20, 0, 'Papel A4 75g, PB'
FROM pedido p
JOIN servico s ON s.nome = 'Impressao PB'
WHERE p.observacoes = 'Pedido João';

INSERT INTO item_pedido (id_pedido, id_servico, quantidade, preco_unitario, desconto, especificacoes)
SELECT p.id_pedido, s.id_servico, 50, 0.50, 0, 'Laminação fosca'
FROM pedido p
JOIN servico s ON s.nome = 'Laminacao'
WHERE p.observacoes = 'Pedido João';

INSERT INTO item_pedido (id_pedido, id_servico, quantidade, preco_unitario, desconto, especificacoes)
SELECT p.id_pedido, s.id_servico, 20, 1.20, 0, '300 dpi, OCR'
FROM pedido p
JOIN servico s ON s.nome = 'Digitalizacao c/OCR'
WHERE p.observacoes = 'Pedido Empresa Alpha';

INSERT INTO item_pedido (id_pedido, id_servico, quantidade, preco_unitario, desconto, especificacoes)
SELECT p.id_pedido, s.id_servico, 200, 0.60, 10.00, 'Cores CMYK, papel couché'
FROM pedido p
JOIN servico s ON s.nome = 'Impressao Colorida'
WHERE p.observacoes = 'Pedido Maria';

INSERT INTO documento (id_item, tipo, nome_arquivo, formato, paginas, confidencial, data_recebimento, url)
SELECT i.id_item, 'entrada', 'arte_joao.pdf', 'PDF', 10, FALSE, CURRENT_TIMESTAMP, 'https://files/arte_joao.pdf'
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
WHERE p.observacoes = 'Pedido João' AND s.nome = 'Impressao PB';

INSERT INTO documento (id_item, tipo, nome_arquivo, formato, paginas, confidencial, data_recebimento, url)
SELECT i.id_item, 'entrada', 'arte_maria.pdf', 'PDF', 15, TRUE, DATE '2023-01-01', 'https://files/arte_maria.pdf'
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
WHERE p.observacoes = 'Pedido Maria' AND s.nome = 'Impressao Colorida';

INSERT INTO documento (id_item, tipo, nome_arquivo, formato, paginas, confidencial, data_recebimento, url)
SELECT i.id_item, 'entrada', 'docs_empresa.zip', 'ZIP', 200, FALSE, CURRENT_TIMESTAMP, 'https://files/docs_empresa.zip'
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
WHERE p.observacoes = 'Pedido Empresa Alpha' AND s.nome = 'Digitalizacao c/OCR';

INSERT INTO execucao_servico (id_item, id_funcionario, id_maquina, inicio, fim, status, observacoes)
SELECT i.id_item, f.id_funcionario, m.id_maquina,
       CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '1 hours', 'concluido', 'Execução PB concluída'
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
JOIN funcionario f ON f.nome = 'Carlos Melo'
JOIN maquina m ON m.tipo = 'impressora'
WHERE p.observacoes = 'Pedido João' AND s.nome = 'Impressao PB';

INSERT INTO execucao_servico (id_item, id_funcionario, id_maquina, inicio, fim, status, observacoes)
SELECT i.id_item, f.id_funcionario, m.id_maquina,
       CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1 hours', 'concluido', 'Laminação concluída'
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
JOIN funcionario f ON f.nome = 'Carlos Melo'
JOIN maquina m ON m.tipo = 'laminadora'
WHERE p.observacoes = 'Pedido João' AND s.nome = 'Laminacao';

INSERT INTO execucao_servico (id_item, id_funcionario, id_maquina, inicio, fim, status, observacoes)
SELECT i.id_item, f.id_funcionario, m.id_maquina,
       CURRENT_TIMESTAMP - INTERVAL '1 hours', CURRENT_TIMESTAMP, 'em_execucao', 'Digitalização em progresso'
FROM item_pedido i
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
JOIN funcionario f ON f.nome = 'Bruno Reis'
JOIN maquina m ON m.tipo = 'scanner'
WHERE p.observacoes = 'Pedido Empresa Alpha' AND s.nome = 'Digitalizacao c/OCR';

INSERT INTO pagamento (id_pedido, forma, valor, data_pagamento, status, parcelas)
SELECT p.id_pedido, 'cartao', 100.00, CURRENT_DATE, 'pago', 1
FROM pedido p WHERE p.observacoes = 'Pedido João';

INSERT INTO pagamento (id_pedido, forma, valor, data_pagamento, status, parcelas)
SELECT p.id_pedido, 'pix', 60.00, CURRENT_DATE, 'parcial', 1
FROM pedido p WHERE p.observacoes = 'Pedido Maria';

INSERT INTO pagamento (id_pedido, forma, valor, data_pagamento, status, parcelas)
SELECT p.id_pedido, 'boleto', 30.00, CURRENT_DATE, 'reembolsado', 1
FROM pedido p WHERE p.observacoes = 'Pedido João';

INSERT INTO entrega (id_pedido, tipo, logradouro, numero, bairro, cidade, estado, cep, data_prevista, status)
SELECT p.id_pedido, 'delivery', 'Rua Entrega', '10', 'Centro', 'São Paulo', 'SP', '01100-000', CURRENT_DATE + INTERVAL '3 days', 'pendente'
FROM pedido p WHERE p.observacoes = 'Pedido João';

INSERT INTO entrega (id_pedido, tipo, data_prevista, status)
SELECT p.id_pedido, 'retirada', CURRENT_DATE + INTERVAL '7 days', 'pendente'
FROM pedido p WHERE p.observacoes = 'Pedido Maria';

INSERT INTO movimento_estoque (id_material, tipo, quantidade, referencia)
SELECT m.id_material, 'entrada', 10000, 'INI2025'
FROM material m WHERE m.nome = 'Papel A4 75g';

INSERT INTO movimento_estoque (id_material, tipo, quantidade, referencia)
SELECT m.id_material, 'entrada', 5000, 'INI2025'
FROM material m WHERE m.nome = 'Tinta CMYK';

INSERT INTO movimento_estoque (id_material, tipo, quantidade, referencia)
SELECT m.id_material, 'saida', 800, 'CONSUMO-JOAO'
FROM material m WHERE m.nome = 'Papel A4 75g';

INSERT INTO movimento_estoque (id_material, tipo, quantidade, referencia)
SELECT m.id_material, 'saida', 300, 'CONSUMO-MARIA'
FROM material m WHERE m.nome = 'Tinta CMYK';

INSERT INTO execucao_material (id_execucao, id_material, quantidade)
SELECT e.id_execucao, m.id_material, 800
FROM execucao_servico e
JOIN item_pedido i ON e.id_item = i.id_item
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
JOIN material m ON m.nome = 'Papel A4 75g'
WHERE p.observacoes = 'Pedido João' AND s.nome = 'Impressao PB' AND e.status = 'concluido';

INSERT INTO execucao_material (id_execucao, id_material, quantidade)
SELECT e.id_execucao, m.id_material, 300
FROM execucao_servico e
JOIN item_pedido i ON e.id_item = i.id_item
JOIN pedido p ON i.id_pedido = p.id_pedido
JOIN servico s ON i.id_servico = s.id_servico
JOIN material m ON m.nome = 'Tinta CMYK'
WHERE p.observacoes = 'Pedido Maria' AND s.nome = 'Impressao Colorida';
