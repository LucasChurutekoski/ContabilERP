-- =====================================================================
-- ContabilERP - estrutura do banco (SQLite)
-- Executado automaticamente pelo DataModule quando o banco ainda nao existe.
-- Convencoes:
--   * valores em dinheiro sempre em CENTAVOS (INTEGER) -> sem erro de ponto flutuante
--   * datas no formato ISO 'AAAA-MM-DD' (o FireDAC converte para TDate)
--   * flags booleanas como INTEGER 0/1
-- =====================================================================

-- ---------------------------------------------------------------------
-- Contabilidade
-- ---------------------------------------------------------------------

-- Plano de contas: arvore (id_pai aponta para a propria tabela)
CREATE TABLE conta (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo    VARCHAR(20)  NOT NULL UNIQUE,                             -- ex.: 1.1.1.02
  nome      VARCHAR(100) NOT NULL,
  id_pai    INTEGER REFERENCES conta(id),                             -- NULL nas contas raiz
  grupo     VARCHAR(2)   NOT NULL CHECK (grupo IN ('A','P','PL','R','D')), -- Ativo, Passivo, PL, Receita, Despesa
  tipo      VARCHAR(1)   NOT NULL CHECK (tipo IN ('S','A')),               -- Sintetica / Analitica
  natureza  VARCHAR(1)   NOT NULL CHECK (natureza IN ('D','C'))            -- Devedora / Credora
);

-- ---------------------------------------------------------------------
-- Seguranca: usuario -> perfil -> permissoes (RBAC simples)
-- ---------------------------------------------------------------------

CREATE TABLE perfil (
  id    INTEGER PRIMARY KEY AUTOINCREMENT,
  nome  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE permissao (
  codigo     VARCHAR(30) PRIMARY KEY,        -- ex.: MOV_COMPRA
  descricao  VARCHAR(100) NOT NULL
);

CREATE TABLE perfil_permissao (
  id_perfil         INTEGER NOT NULL REFERENCES perfil(id),
  codigo_permissao  VARCHAR(30) NOT NULL REFERENCES permissao(codigo),
  PRIMARY KEY (id_perfil, codigo_permissao)
);

CREATE TABLE usuario (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  login       VARCHAR(30)  NOT NULL UNIQUE,
  nome        VARCHAR(100) NOT NULL,
  senha_hash  VARCHAR(64)  NOT NULL,        -- SHA-256(salt + senha), nunca a senha em texto
  salt        VARCHAR(32)  NOT NULL,
  id_perfil   INTEGER NOT NULL REFERENCES perfil(id),
  ativo       INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0,1))
);

-- ---------------------------------------------------------------------
-- Cadastros do ERP
-- ---------------------------------------------------------------------

-- Clientes e fornecedores no mesmo cadastro (uma empresa pode ser os dois)
CREATE TABLE entidade (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  nome           VARCHAR(100) NOT NULL,
  documento      VARCHAR(20)  UNIQUE,                                     -- CPF ou CNPJ
  eh_cliente     INTEGER NOT NULL DEFAULT 0 CHECK (eh_cliente IN (0,1)),
  eh_fornecedor  INTEGER NOT NULL DEFAULT 0 CHECK (eh_fornecedor IN (0,1)),
  CHECK (eh_cliente = 1 OR eh_fornecedor = 1)
);

-- Locais de estoque: arvore como o plano de contas.
-- So locais "folha" (aceita_estoque = 1) guardam itens.
CREATE TABLE local (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo          VARCHAR(20)  NOT NULL UNIQUE,                           -- ex.: ALM.1A
  nome            VARCHAR(100) NOT NULL,
  id_pai          INTEGER REFERENCES local(id),
  aceita_estoque  INTEGER NOT NULL DEFAULT 1 CHECK (aceita_estoque IN (0,1))
);

-- Unidades de medida (UN, L, KG, H...)
CREATE TABLE unidade (
  sigla      VARCHAR(5)  PRIMARY KEY,
  descricao  VARCHAR(50) NOT NULL
);

-- Produtos (tem estoque) e servicos (nao tem)
CREATE TABLE item (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo                VARCHAR(20)  NOT NULL UNIQUE,
  descricao             VARCHAR(100) NOT NULL,
  tipo                  VARCHAR(1)   NOT NULL CHECK (tipo IN ('P','S')),  -- Produto / Servico
  unidade               VARCHAR(5)   NOT NULL DEFAULT 'UN' REFERENCES unidade(sigla),
  id_conta              INTEGER NOT NULL REFERENCES conta(id),       -- produto = Estoques, servico = despesa
  custo_medio_centavos  INTEGER NOT NULL DEFAULT 0 CHECK (custo_medio_centavos >= 0)
);

-- Saldo fisico por item + local. Atualizado SOMENTE pelo servico de movimentos,
-- dentro da mesma transacao que grava o movimento.
CREATE TABLE saldo_estoque (
  id_item     INTEGER NOT NULL REFERENCES item(id),
  id_local    INTEGER NOT NULL REFERENCES local(id),
  quantidade  REAL    NOT NULL DEFAULT 0 CHECK (quantidade >= 0),    -- rede de seguranca: nunca negativo
  PRIMARY KEY (id_item, id_local)
);

-- Veiculos da frota. Contabilmente sao bens do Imobilizado; aqui funcionam
-- como CENTRO DE CUSTO: cada manutencao fica ligada ao veiculo.
CREATE TABLE veiculo (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  placa      VARCHAR(8)   NOT NULL UNIQUE,
  descricao  VARCHAR(100) NOT NULL,
  ano        INTEGER,
  ativo      INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0,1))
);

-- ---------------------------------------------------------------------
-- Movimentacao de estoque (cabecalho + itens)
-- ---------------------------------------------------------------------

CREATE TABLE movimento (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  data              DATE    NOT NULL,
  operacao          VARCHAR(15) NOT NULL CHECK (operacao IN ('COMPRA','CONSUMO','TRANSFERENCIA','SERVICO','MANUTENCAO')),
  id_entidade       INTEGER REFERENCES entidade(id),                 -- fornecedor (compra) ou cliente (servico)
  pagamento         VARCHAR(5)  CHECK (pagamento IN ('VISTA','PRAZO')),  -- compra e servico
  id_conta_destino  INTEGER REFERENCES conta(id),                    -- consumo e manutencao (ex.: Desp. Manutencao)
  id_veiculo        INTEGER REFERENCES veiculo(id),                  -- so na manutencao
  observacao        VARCHAR(200),
  id_usuario        INTEGER NOT NULL REFERENCES usuario(id),
  criado_em         DATETIME NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE movimento_item (
  id                   INTEGER PRIMARY KEY AUTOINCREMENT,
  id_movimento         INTEGER NOT NULL REFERENCES movimento(id),
  id_item              INTEGER NOT NULL REFERENCES item(id),
  id_local_origem      INTEGER REFERENCES local(id),                 -- consumo e transferencia
  id_local_destino     INTEGER REFERENCES local(id),                 -- compra e transferencia
  quantidade           REAL    NOT NULL CHECK (quantidade > 0),
  valor_unit_centavos  INTEGER NOT NULL CHECK (valor_unit_centavos >= 0)
);

-- ---------------------------------------------------------------------
-- Lancamentos contabeis (cabecalho + partidas)
-- ---------------------------------------------------------------------

CREATE TABLE lancamento (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,                   -- numero do lancamento
  data          DATE    NOT NULL,
  historico     VARCHAR(200) NOT NULL,
  origem        VARCHAR(1)   NOT NULL DEFAULT 'M' CHECK (origem IN ('M','E')), -- Manual / Estoque
  id_movimento  INTEGER REFERENCES movimento(id),                    -- preenchido quando origem = 'E'
  id_usuario    INTEGER NOT NULL REFERENCES usuario(id),
  criado_em     DATETIME NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE partida (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  id_lancamento   INTEGER NOT NULL REFERENCES lancamento(id),
  id_conta        INTEGER NOT NULL REFERENCES conta(id),
  dc              VARCHAR(1)   NOT NULL CHECK (dc IN ('D','C')),
  valor_centavos  INTEGER NOT NULL CHECK (valor_centavos > 0)
);

-- Indices para as consultas mais frequentes (razonete e balancete agrupam por conta)
CREATE INDEX ix_partida_conta      ON partida(id_conta);
CREATE INDEX ix_partida_lancamento ON partida(id_lancamento);
CREATE INDEX ix_movitem_movimento  ON movimento_item(id_movimento);
