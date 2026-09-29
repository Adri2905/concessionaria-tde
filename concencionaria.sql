-- Active: 1790638250876@@127.0.0.1@5432@concessionaria
DROP TABLE IF EXISTS his_historico_manutencao CASCADE;
DROP TABLE IF EXISTS ops_ordem_peca CASCADE;
DROP TABLE IF EXISTS orm_ordem_mecanico CASCADE;
DROP TABLE IF EXISTS ord_ordem_servico CASCADE;
DROP TABLE IF EXISTS fat_fatura CASCADE;
DROP TABLE IF EXISTS vnd_venda CASCADE;
DROP TABLE IF EXISTS pec_peca CASCADE;
DROP TABLE IF EXISTS vei_veiculo CASCADE;
DROP TABLE IF EXISTS mec_mecanico CASCADE;
DROP TABLE IF EXISTS ven_vendedor CASCADE;
DROP TABLE IF EXISTS cli_cliente CASCADE;

CREATE TABLE cli_cliente (
    cli_id          SERIAL       PRIMARY KEY,
    cli_nome        VARCHAR(60)  NOT NULL,
    cli_cpf         CHAR(11)     NOT NULL UNIQUE,
    cli_fone        VARCHAR(20)  NOT NULL,
    cli_email       VARCHAR(60)  UNIQUE,
    cli_endereco    VARCHAR(200),
    cli_dtcadastro  DATE         NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO cli_cliente (cli_nome, cli_cpf, cli_fone, cli_email, cli_endereco, cli_dtcadastro) VALUES
('Carlos Henrique Souza',  '11122233344', '(31) 99111-0001', 'carlos.souza@email.com',  'Rua das Flores, 120 - Contagem/MG',      '2026-01-10'),
('Fernanda Lima Duarte',   '22233344455', '(31) 99111-0002', 'fernanda.duarte@email.com','Av. Brasil, 450 - Belo Horizonte/MG',    '2026-02-15'),
('Roberto Alves Pinto',    '33344455566', '(31) 99111-0003', 'roberto.pinto@email.com', 'Rua Minas Gerais, 89 - Betim/MG',         '2026-03-20'),
('Juliana Castro Rocha',   '44455566677', '(31) 99111-0004', NULL,                      NULL,                                     '2026-04-05'),
('Marcos Vinicius Reis',   '55566677788', '(31) 99111-0005', 'marcos.reis@email.com',   'Rua Sete de Setembro, 15 - Contagem/MG', '2026-05-12'),
('Patrícia Gomes Ferraz',  '66677788899', '(31) 99111-0006', 'patricia.ferraz@email.com','Av. Amazonas, 2000 - Belo Horizonte/MG', '2026-06-30');

CREATE TABLE ven_vendedor (
    ven_id         SMALLSERIAL   PRIMARY KEY,
    ven_nome       VARCHAR(60)   NOT NULL,
    ven_cpf        CHAR(11)      NOT NULL UNIQUE,
    ven_fone       VARCHAR(20)   NOT NULL,
    ven_email      VARCHAR(60)   NOT NULL UNIQUE,
    ven_dtadmissao DATE          NOT NULL,
    ven_comissao   DECIMAL(5,2)  NOT NULL DEFAULT 0,
    CONSTRAINT ck_vendedor_comissao CHECK (ven_comissao BETWEEN 0 AND 100)
);

INSERT INTO ven_vendedor (ven_nome, ven_cpf, ven_fone, ven_email, ven_dtadmissao, ven_comissao) VALUES
('Anderson Melo Barbosa', '77788899900', '(31) 98888-0001', 'anderson.melo@concessionaria.com', '2022-03-01', 2.50),
('Luciana Prado Neves',   '88899900011', '(31) 98888-0002', 'luciana.prado@concessionaria.com', '2023-07-15', 3.00),
('Rodrigo Tavares Lins',  '99900011122', '(31) 98888-0003', 'rodrigo.tavares@concessionaria.com','2024-01-20', 2.00);

CREATE TABLE mec_mecanico (
    mec_id           SMALLSERIAL  PRIMARY KEY,
    mec_nome         VARCHAR(60)  NOT NULL,
    mec_cpf          CHAR(11)     NOT NULL UNIQUE,
    mec_fone         VARCHAR(20)  NOT NULL,
    mec_email        VARCHAR(60)  UNIQUE,
    mec_especialidade VARCHAR(30) NOT NULL,
    mec_dtadmissao   DATE         NOT NULL
);

INSERT INTO mec_mecanico (mec_nome, mec_cpf, mec_fone, mec_email, mec_especialidade, mec_dtadmissao) VALUES
('Sérgio Augusto Matos',  '10120230340', '(31) 97777-0001', 'sergio.matos@concessionaria.com', 'Motor',             '2020-05-10'),
('Paulo César Andrade',   '20230340450', '(31) 97777-0002', NULL,                              'Freios e Suspensão', '2021-08-23'),
('Diego Fonseca Leal',    '30340450560', '(31) 97777-0003', 'diego.leal@concessionaria.com',   'Injeção Eletrônica', '2022-11-07'),
('Wagner Moreira Costa',  '40450560670', '(31) 97777-0004', NULL,                              'Elétrica',           '2023-02-14');

CREATE TABLE vei_veiculo (
    vei_numserie      CHAR(17)      PRIMARY KEY,
    vei_marca         VARCHAR(30)   NOT NULL,
    vei_modelo        VARCHAR(40)   NOT NULL,
    vei_anofabricacao SMALLINT      NOT NULL,
    vei_cor           VARCHAR(20),
    vei_placa         CHAR(7)       UNIQUE,
    vei_condicao      VARCHAR(5)    NOT NULL,
    vei_km            INTEGER       NOT NULL DEFAULT 0,
    vei_preco         DECIMAL(12,2),
    CONSTRAINT ck_veiculo_numserie   CHECK (LENGTH(vei_numserie) = 17),
    CONSTRAINT ck_veiculo_ano        CHECK (vei_anofabricacao BETWEEN 1950 AND 2100),
    CONSTRAINT ck_veiculo_condicao   CHECK (vei_condicao IN ('Novo', 'Usado')),
    CONSTRAINT ck_veiculo_km         CHECK (vei_km >= 0),
    CONSTRAINT ck_veiculo_preco      CHECK (vei_preco IS NULL OR vei_preco > 0)
);

INSERT INTO vei_veiculo (vei_numserie, vei_marca, vei_modelo, vei_anofabricacao, vei_cor, vei_placa, vei_condicao, vei_km, vei_preco) VALUES
('9BWZZZ377VT004251', 'Volkswagen', 'Polo 1.0 TSI',    2026, 'Branco',  'RTX1A23', 'Novo',  0,     98500.00),
('9BGKS48U0LG112233', 'Chevrolet',  'Onix Plus',       2025, 'Prata',   'QWE4B56', 'Novo',  0,     92000.00),
('93YLSR7UH8J556677', 'Renault',    'Kwid Zen',        2022, 'Vermelho','PLK7C89', 'Usado', 32000, 45900.00),
('9BD15822734998812', 'Fiat',       'Argo Drive',      2023, 'Preto',   'MNB2D34', 'Usado', 18500, 68000.00),
('9C2KC1670GR334455', 'Honda',      'Civic EXL',       2024, 'Cinza',   NULL,      'Novo',  0,     165000.00),
('8AP372110M2778899', 'Toyota',     'Corolla XEi',     2019, 'Branco',  'HGT5E67', 'Usado', 87000, NULL),
('9BFZK55A0NB661122', 'Ford',       'Ka SE',           2018, 'Azul',    'JKL8F90', 'Usado', 102000,NULL),
('93HGM2650KZ443300', 'Hyundai',    'HB20 Comfort',    2020, 'Prata',   'ZXC9G12', 'Usado', 64000, NULL);

CREATE TABLE vnd_venda (
    vnd_id           SERIAL         PRIMARY KEY,
    vnd_vei_numserie CHAR(17)       NOT NULL UNIQUE,
    vnd_ven_id       SMALLINT       NOT NULL,
    vnd_cli_id       INTEGER        NOT NULL,
    vnd_data         DATE           NOT NULL,
    vnd_valor        DECIMAL(12,2)  NOT NULL,
    CONSTRAINT fk_venda_veiculo
        FOREIGN KEY (vnd_vei_numserie)
        REFERENCES vei_veiculo(vei_numserie),
    CONSTRAINT fk_venda_vendedor
        FOREIGN KEY (vnd_ven_id)
        REFERENCES ven_vendedor(ven_id),
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (vnd_cli_id)
        REFERENCES cli_cliente(cli_id),
    CONSTRAINT ck_venda_valor CHECK (vnd_valor > 0)
);

INSERT INTO vnd_venda (vnd_vei_numserie, vnd_ven_id, vnd_cli_id, vnd_data, vnd_valor) VALUES
('9BWZZZ377VT004251', 1, 1, '2026-08-10',  97000.00),
('9BGKS48U0LG112233', 2, 2, '2026-08-22',  90500.00),
('93YLSR7UH8J556677', 1, 3, '2026-09-03',  44500.00),
('9BD15822734998812', 3, 4, '2026-09-12',  66800.00);

CREATE TABLE fat_fatura (
    fat_id          SERIAL         PRIMARY KEY,
    fat_vnd_id      INTEGER        NOT NULL UNIQUE,
    fat_numero      VARCHAR(20)    NOT NULL UNIQUE,
    fat_dtemissao   DATE           NOT NULL,
    fat_valortotal  DECIMAL(12,2)  NOT NULL,
    fat_formapagto  VARCHAR(20)    NOT NULL,
    fat_situacao    VARCHAR(10)    NOT NULL DEFAULT 'Pendente',
    CONSTRAINT fk_fatura_venda
        FOREIGN KEY (fat_vnd_id)
        REFERENCES vnd_venda(vnd_id),
    CONSTRAINT ck_fatura_valortotal CHECK (fat_valortotal > 0),
    CONSTRAINT ck_fatura_formapagto CHECK (fat_formapagto IN ('À Vista', 'Financiamento', 'Cartão de Crédito', 'Consórcio')),
    CONSTRAINT ck_fatura_situacao   CHECK (fat_situacao IN ('Pendente', 'Paga', 'Cancelada'))
);

INSERT INTO fat_fatura (fat_vnd_id, fat_numero, fat_dtemissao, fat_valortotal, fat_formapagto, fat_situacao) VALUES
(1, 'FAT-2026-0001', '2026-08-10',  97000.00, 'Financiamento',     'Paga'),
(2, 'FAT-2026-0002', '2026-08-22',  90500.00, 'À Vista',           'Paga'),
(3, 'FAT-2026-0003', '2026-09-03',  44500.00, 'Cartão de Crédito', 'Paga'),
(4, 'FAT-2026-0004', '2026-09-12',  66800.00, 'Financiamento',     'Pendente');

CREATE TABLE pec_peca (
    pec_id          SMALLSERIAL   PRIMARY KEY,
    pec_codigo      VARCHAR(20)   NOT NULL UNIQUE,
    pec_nome        VARCHAR(60)   NOT NULL,
    pec_fabricante  VARCHAR(40),
    pec_preco       DECIMAL(10,2) NOT NULL,
    pec_estoque     INTEGER       NOT NULL DEFAULT 0,
    CONSTRAINT ck_peca_preco   CHECK (pec_preco >= 0),
    CONSTRAINT ck_peca_estoque CHECK (pec_estoque >= 0)
);

INSERT INTO pec_peca (pec_codigo, pec_nome, pec_fabricante, pec_preco, pec_estoque) VALUES
('FLT-OLEO-001', 'Filtro de Óleo',            'Mann',    35.00,  50),
('OLE-5W30-001', 'Óleo 5W30 (1 litro)',       'Mobil',   42.00, 120),
('PAS-FRE-001',  'Pastilha de Freio Dianteira','Bosch',  180.00,  25),
('DIS-FRE-001',  'Disco de Freio',            'Fremax',  260.00,  16),
('COR-DEN-001',  'Correia Dentada',           'Gates',   150.00,  20),
('FLT-AR-001',   'Filtro de Ar',              NULL,       45.00,  40);

CREATE TABLE ord_ordem_servico (
    ord_id             SERIAL         PRIMARY KEY,
    ord_cli_id         INTEGER        NOT NULL,
    ord_vei_numserie   CHAR(17)       NOT NULL,
    ord_dtabertura     DATE           NOT NULL DEFAULT CURRENT_DATE,
    ord_dtconclusao    DATE,
    ord_tipo           VARCHAR(15)    NOT NULL,
    ord_situacao       VARCHAR(15)    NOT NULL DEFAULT 'Aberta',
    ord_descricao      VARCHAR(200)   NOT NULL,
    ord_valormaodeobra DECIMAL(10,2)  NOT NULL DEFAULT 0,
    CONSTRAINT fk_ordem_cliente
        FOREIGN KEY (ord_cli_id)
        REFERENCES cli_cliente(cli_id),
    CONSTRAINT fk_ordem_veiculo
        FOREIGN KEY (ord_vei_numserie)
        REFERENCES vei_veiculo(vei_numserie),
    CONSTRAINT uk_ordem_id_veiculo
        UNIQUE (ord_id, ord_vei_numserie),
    CONSTRAINT ck_ordem_tipo      CHECK (ord_tipo IN ('Revisão', 'Reparo', 'Manutenção')),
    CONSTRAINT ck_ordem_situacao  CHECK (ord_situacao IN ('Aberta', 'Em Andamento', 'Concluída', 'Cancelada')),
    CONSTRAINT ck_ordem_datas     CHECK (ord_dtconclusao IS NULL OR ord_dtconclusao >= ord_dtabertura),
    CONSTRAINT ck_ordem_conclusao CHECK (ord_situacao <> 'Concluída' OR ord_dtconclusao IS NOT NULL),
    CONSTRAINT ck_ordem_maodeobra CHECK (ord_valormaodeobra >= 0)
);

INSERT INTO ord_ordem_servico (ord_cli_id, ord_vei_numserie, ord_dtabertura, ord_dtconclusao, ord_tipo, ord_situacao, ord_descricao, ord_valormaodeobra) VALUES
(1, '9BWZZZ377VT004251', '2026-09-01', '2026-09-01', 'Revisão',    'Concluída',    'Revisão dos 10.000 km com troca de óleo e filtro.',   180.00),
(5, '8AP372110M2778899', '2026-09-05', '2026-09-08', 'Reparo',     'Concluída',    'Troca de pastilhas e discos de freio dianteiros.',    320.00),
(6, '93HGM2650KZ443300', '2026-09-10', '2026-09-10', 'Manutenção', 'Concluída',    'Limpeza do bico injetor de combustível.',             120.00),
(5, '9BFZK55A0NB661122', '2026-09-20', NULL,         'Reparo',     'Em Andamento', 'Substituição da correia dentada e ajuste do motor.',  400.00),
(1, '9BWZZZ377VT004251', '2026-09-15', '2026-09-15', 'Manutenção', 'Concluída',    'Troca do filtro de ar.',                               90.00);

CREATE TABLE orm_ordem_mecanico (
    orm_ord_id  INTEGER       NOT NULL,
    orm_mec_id  SMALLINT      NOT NULL,
    orm_horas   DECIMAL(5,2),
    orm_funcao  VARCHAR(30),
    PRIMARY KEY (orm_ord_id, orm_mec_id),
    CONSTRAINT fk_ordmec_ordem
        FOREIGN KEY (orm_ord_id)
        REFERENCES ord_ordem_servico(ord_id),
    CONSTRAINT fk_ordmec_mecanico
        FOREIGN KEY (orm_mec_id)
        REFERENCES mec_mecanico(mec_id),
    CONSTRAINT ck_ordmec_horas CHECK (orm_horas IS NULL OR orm_horas > 0)
);

INSERT INTO orm_ordem_mecanico (orm_ord_id, orm_mec_id, orm_horas, orm_funcao) VALUES
(1, 1, 2.50, 'Responsável'),
(2, 2, 4.00, 'Responsável'),
(2, 1, 3.00, 'Auxiliar'),
(3, 3, 1.50, 'Responsável'),
(4, 1, 2.00, 'Responsável'),
(4, 2, 1.00, 'Auxiliar'),
(5, 4, 0.50, 'Responsável');

CREATE TABLE ops_ordem_peca (
    ops_ord_id      INTEGER        NOT NULL,
    ops_pec_id      SMALLINT       NOT NULL,
    ops_quantidade  SMALLINT       NOT NULL,
    ops_precounit   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (ops_ord_id, ops_pec_id),
    CONSTRAINT fk_ordpec_ordem
        FOREIGN KEY (ops_ord_id)
        REFERENCES ord_ordem_servico(ord_id),
    CONSTRAINT fk_ordpec_peca
        FOREIGN KEY (ops_pec_id)
        REFERENCES pec_peca(pec_id),
    CONSTRAINT ck_ordpec_quantidade CHECK (ops_quantidade > 0),
    CONSTRAINT ck_ordpec_precounit  CHECK (ops_precounit >= 0)
);

INSERT INTO ops_ordem_peca (ops_ord_id, ops_pec_id, ops_quantidade, ops_precounit) VALUES
(1, 1, 1,  35.00),
(1, 2, 4,  42.00),
(2, 3, 2, 180.00),
(2, 4, 2, 260.00),
(4, 5, 1, 150.00),
(5, 6, 1,  45.00);

CREATE TABLE his_historico_manutencao (
    his_vei_numserie CHAR(17)      NOT NULL,
    his_seq          SMALLINT      NOT NULL,
    his_ord_id       INTEGER       NOT NULL UNIQUE,
    his_data         DATE          NOT NULL,
    his_km           INTEGER       NOT NULL,
    his_tiposervico  VARCHAR(15)   NOT NULL,
    his_descricao    VARCHAR(200)  NOT NULL,
    PRIMARY KEY (his_vei_numserie, his_seq),
    CONSTRAINT fk_historico_veiculo
        FOREIGN KEY (his_vei_numserie)
        REFERENCES vei_veiculo(vei_numserie),
    CONSTRAINT fk_historico_ordem
        FOREIGN KEY (his_ord_id, his_vei_numserie)
        REFERENCES ord_ordem_servico(ord_id, ord_vei_numserie),
    CONSTRAINT ck_historico_seq  CHECK (his_seq > 0),
    CONSTRAINT ck_historico_km   CHECK (his_km >= 0),
    CONSTRAINT ck_historico_tipo CHECK (his_tiposervico IN ('Revisão', 'Reparo', 'Manutenção'))
);

INSERT INTO his_historico_manutencao (his_vei_numserie, his_seq, his_ord_id, his_data, his_km, his_tiposervico, his_descricao) VALUES
('9BWZZZ377VT004251', 1, 1, '2026-09-01', 10120, 'Revisão',    'Revisão dos 10.000 km com troca de óleo e filtro.'),
('9BWZZZ377VT004251', 2, 5, '2026-09-15', 10480, 'Manutenção', 'Troca do filtro de ar.'),
('8AP372110M2778899', 1, 2, '2026-09-08', 87200, 'Reparo',     'Troca de pastilhas e discos de freio dianteiros.'),
('93HGM2650KZ443300', 1, 3, '2026-09-10', 64150, 'Manutenção', 'Limpeza do bico injetor de combustível.');