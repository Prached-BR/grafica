-- DDL para PostgreSQL baseado no MER da gráfica
-- Schema: grafica

CREATE SCHEMA IF NOT EXISTS grafica;
SET search_path TO grafica;

-- =====================
-- TABELAS DE CADASTRO
-- =====================

CREATE TABLE IF NOT EXISTS cliente (
    id_cliente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    tipo CHAR(2) NOT NULL,
    documento VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(30),
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    data_cadastro DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'ativo',
    CONSTRAINT uq_cliente_documento UNIQUE (documento),
    CONSTRAINT ck_cliente_tipo CHECK (tipo IN ('PF','PJ')),
    CONSTRAINT ck_cliente_status CHECK (status IN ('ativo','inativo','suspenso'))
);

CREATE TABLE IF NOT EXISTS funcionario (
    id_funcionario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    setor VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(30),
    data_admissao DATE,
    status VARCHAR(20) DEFAULT 'ativo',
    CONSTRAINT ck_funcionario_status CHECK (status IN ('ativo','inativo'))
);

CREATE TABLE IF NOT EXISTS servico (
    id_servico BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    categoria VARCHAR(40) NOT NULL,
    descricao TEXT,
    preco_base NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    unidade VARCHAR(50),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_servico_categoria CHECK (
        categoria IN ('Impressão','Acabamento','Digitalização','Design','Logística')
    )
);

-- =====================
-- TABELAS DE NEGÓCIO
-- =====================

CREATE TABLE IF NOT EXISTS pedido (
    id_pedido BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL,
    data_pedido DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'Orçado',
    prazo_entrega DATE,
    canal VARCHAR(20) DEFAULT 'presencial',
    observacoes TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_pedido_status CHECK (
        status IN ('Orçado','Aprovado','Em_producao','Concluido','Entregue','Cancelado')
    ),
    CONSTRAINT ck_pedido_canal CHECK (canal IN ('presencial','online'))
);

CREATE TABLE IF NOT EXISTS item_pedido (
    id_item BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido BIGINT NOT NULL,
    id_servico BIGINT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(12,2) NOT NULL CHECK (preco_unitario >= 0),
    desconto NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (desconto >= 0),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    especificacoes TEXT,
    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_item_servico FOREIGN KEY (id_servico)
        REFERENCES servico(id_servico) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS documento (
    id_documento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_item BIGINT NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    nome_arquivo VARCHAR(255),
    formato VARCHAR(20),
    paginas INT,
    confidencial BOOLEAN NOT NULL DEFAULT FALSE,
    data_recebimento TIMESTAMP,
    url TEXT,
    CONSTRAINT fk_documento_item FOREIGN KEY (id_item)
        REFERENCES item_pedido(id_item) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_documento_tipo CHECK (tipo IN ('entrada','saida'))
);

CREATE TABLE IF NOT EXISTS maquina (
    id_maquina BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR(30) NOT NULL,
    modelo VARCHAR(120),
    fabricante VARCHAR(120),
    numero_serie VARCHAR(60),
    data_aquisicao DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'operacional',
    CONSTRAINT uq_maquina_numero_serie UNIQUE (numero_serie),
    CONSTRAINT ck_maquina_tipo CHECK (
        tipo IN ('impressora','scanner','envelopadora','laminadora','plotter')
    ),
    CONSTRAINT ck_maquina_status CHECK (status IN ('operacional','manutencao','inativo'))
);

CREATE TABLE IF NOT EXISTS execucao_servico (
    id_execucao BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_item BIGINT NOT NULL,
    id_funcionario BIGINT NOT NULL,
    id_maquina BIGINT NOT NULL,
    inicio TIMESTAMP,
    fim TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'fila',
    observacoes TEXT,
    CONSTRAINT fk_exec_item FOREIGN KEY (id_item)
        REFERENCES item_pedido(id_item) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_exec_func FOREIGN KEY (id_funcionario)
        REFERENCES funcionario(id_funcionario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exec_maquina FOREIGN KEY (id_maquina)
        REFERENCES maquina(id_maquina) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_exec_status CHECK (
        status IN ('fila','em_execucao','pausado','concluido','erro')
    )
);

CREATE TABLE IF NOT EXISTS pagamento (
    id_pagamento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido BIGINT NOT NULL,
    forma VARCHAR(20) NOT NULL,
    valor NUMERIC(12,2) NOT NULL CHECK (valor >= 0),
    data_pagamento DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'pendente',
    parcelas INT NOT NULL DEFAULT 1 CHECK (parcelas >= 1),
    CONSTRAINT fk_pag_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_pag_forma CHECK (forma IN ('dinheiro','cartao','pix','boleto')),
    CONSTRAINT ck_pag_status CHECK (status IN ('pendente','pago','reembolsado','parcial'))
);

CREATE TABLE IF NOT EXISTS entrega (
    id_entrega BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido BIGINT NOT NULL UNIQUE,
    tipo VARCHAR(20) NOT NULL,
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    data_prevista DATE,
    data_real DATE,
    status VARCHAR(20) DEFAULT 'pendente',
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_entrega_tipo CHECK (tipo IN ('retirada','delivery'))
);

-- =====================
-- ESTOQUE E CONSUMO
-- =====================

CREATE TABLE IF NOT EXISTS material (
    id_material BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    tipo VARCHAR(40) NOT NULL,
    unidade VARCHAR(30) NOT NULL,
    nivel_estoque NUMERIC(12,3) NOT NULL DEFAULT 0,
    ponto_reposicao NUMERIC(12,3) NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS movimento_estoque (
    id_mov BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_material BIGINT NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    quantidade NUMERIC(12,3) NOT NULL CHECK (quantidade > 0),
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(60),
    observacoes TEXT,
    CONSTRAINT fk_mov_material FOREIGN KEY (id_material)
        REFERENCES material(id_material) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_mov_tipo CHECK (tipo IN ('entrada','saida'))
);

-- Tabela de junção para consumo de materiais por execução (N:M)
CREATE TABLE IF NOT EXISTS execucao_material (
    id_execucao BIGINT NOT NULL,
    id_material BIGINT NOT NULL,
    quantidade NUMERIC(12,3) NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (id_execucao, id_material),
    CONSTRAINT fk_em_exec FOREIGN KEY (id_execucao)
        REFERENCES execucao_servico(id_execucao) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_em_mat FOREIGN KEY (id_material)
        REFERENCES material(id_material) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================
-- ÍNDICES
-- =====================

CREATE INDEX IF NOT EXISTS idx_pedido_cliente ON pedido(id_cliente);
CREATE INDEX IF NOT EXISTS idx_item_pedido ON item_pedido(id_pedido);
CREATE INDEX IF NOT EXISTS idx_item_servico ON item_pedido(id_servico);
CREATE INDEX IF NOT EXISTS idx_documento_item ON documento(id_item);
CREATE INDEX IF NOT EXISTS idx_exec_item ON execucao_servico(id_item);
CREATE INDEX IF NOT EXISTS idx_exec_func ON execucao_servico(id_funcionario);
CREATE INDEX IF NOT EXISTS idx_exec_maquina ON execucao_servico(id_maquina);
CREATE INDEX IF NOT EXISTS idx_pag_pedido ON pagamento(id_pedido);
CREATE INDEX IF NOT EXISTS idx_entrega_pedido ON entrega(id_pedido);
CREATE INDEX IF NOT EXISTS idx_mov_material ON movimento_estoque(id_material);
CREATE INDEX IF NOT EXISTS idx_em_exec ON execucao_material(id_execucao);
CREATE INDEX IF NOT EXISTS idx_em_mat ON execucao_material(id_material);

-- =====================
-- COMENTÁRIOS (opcional)
-- =====================
COMMENT ON SCHEMA grafica IS 'Schema da gráfica: pedidos, produção, estoque e logística.';
COMMENT ON TABLE cliente IS 'Cadastro de clientes PF/PJ.';
COMMENT ON TABLE servico IS 'Catálogo de serviços (impressão, acabamento, etc.).';
COMMENT ON TABLE pedido IS 'Pedidos do cliente com status e prazo.';
COMMENT ON TABLE item_pedido IS 'Itens de serviços do pedido com especificações.';
COMMENT ON TABLE documento IS 'Arquivos de entrada/saída associados a itens do pedido.';
COMMENT ON TABLE funcionario IS 'Colaboradores por cargo/setor.';
COMMENT ON TABLE maquina IS 'Equipamentos utilizados na produção.';
COMMENT ON TABLE execucao_servico IS 'Execuções operacionais por item, funcionário e máquina.';
COMMENT ON TABLE pagamento IS 'Pagamentos (parciais ou totais) do pedido.';
COMMENT ON TABLE entrega IS 'Entrega opcional do pedido; 0:1 com pedido.';
COMMENT ON TABLE material IS 'Materiais/insumos e seus estoques.';
COMMENT ON TABLE movimento_estoque IS 'Movimentações de estoque (entrada/saída).';
COMMENT ON TABLE execucao_material IS 'Consumo de materiais por execução (N:M).';

-- =====================
-- TRIGGERS
-- =====================
-- Garante que o subtotal do item seja calculado automaticamente
CREATE OR REPLACE FUNCTION grafica.fn_item_pedido_calc_subtotal()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    NEW.subtotal := GREATEST(
        COALESCE(NEW.quantidade, 0)::numeric * COALESCE(NEW.preco_unitario, 0) - COALESCE(NEW.desconto, 0),
        0
    );
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_item_pedido_calc_subtotal_ins ON grafica.item_pedido;
CREATE TRIGGER trg_item_pedido_calc_subtotal_ins
BEFORE INSERT ON grafica.item_pedido
FOR EACH ROW EXECUTE FUNCTION grafica.fn_item_pedido_calc_subtotal();

DROP TRIGGER IF EXISTS trg_item_pedido_calc_subtotal_upd ON grafica.item_pedido;
CREATE TRIGGER trg_item_pedido_calc_subtotal_upd
BEFORE UPDATE OF quantidade, preco_unitario, desconto ON grafica.item_pedido
FOR EACH ROW EXECUTE FUNCTION grafica.fn_item_pedido_calc_subtotal();

-- =====================
-- VIEWS FINANCEIRAS
-- =====================
-- Totais por pedido: total de itens, total pago (considerando reembolso negativo) e saldo
CREATE OR REPLACE VIEW grafica.vw_pedido_totais AS
SELECT
    p.id_pedido,
    p.id_cliente,
    p.status,
    COALESCE(SUM(i.subtotal), 0) AS total_itens,
    COALESCE(
        (
            SELECT SUM(CASE
                        WHEN pg.status IN ('pago','parcial') THEN pg.valor
                        WHEN pg.status = 'reembolsado' THEN -pg.valor
                        ELSE 0
                      END)
            FROM grafica.pagamento pg
            WHERE pg.id_pedido = p.id_pedido
        ), 0
    ) AS total_pago,
    COALESCE(SUM(i.subtotal), 0) - COALESCE(
        (
            SELECT SUM(CASE
                        WHEN pg.status IN ('pago','parcial') THEN pg.valor
                        WHEN pg.status = 'reembolsado' THEN -pg.valor
                        ELSE 0
                      END)
            FROM grafica.pagamento pg
            WHERE pg.id_pedido = p.id_pedido
        ), 0
    ) AS saldo_a_receber
FROM grafica.pedido p
LEFT JOIN grafica.item_pedido i ON i.id_pedido = p.id_pedido
GROUP BY p.id_pedido, p.id_cliente, p.status;

-- Resumo financeiro por cliente
CREATE OR REPLACE VIEW grafica.vw_cliente_financeiro AS
SELECT
    c.id_cliente,
    c.nome,
    COUNT(DISTINCT p.id_pedido) AS qtd_pedidos,
    COALESCE(SUM(v.total_itens), 0) AS total_pedidos,
    COALESCE(SUM(v.total_pago), 0) AS total_pago,
    COALESCE(SUM(v.saldo_a_receber), 0) AS saldo_a_receber
FROM grafica.cliente c
LEFT JOIN grafica.pedido p ON p.id_cliente = c.id_cliente
LEFT JOIN grafica.vw_pedido_totais v ON v.id_pedido = p.id_pedido
GROUP BY c.id_cliente, c.nome;