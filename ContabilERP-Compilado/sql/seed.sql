-- =====================================================================
-- ContabilERP - dados iniciais (seed)
-- Somente CADASTROS. Nenhum lancamento/movimento: os cenarios de teste
-- (Pet Shop da Bia e pneus) sao digitados na demonstracao ou rodados nos testes.
--
-- Usuarios de TESTE (senha = SHA-256 de salt + senha):
--   admin      / admin123    -> Administrador
--   contador   / contador123 -> Contador
--   estoquista / estoque123  -> Estoquista
-- =====================================================================

-- ---------------------------------------------------------------------
-- Plano de contas
-- Colunas: codigo, nome, pai, grupo (A/P/PL/R/D), tipo (S/A), natureza (D/C)
-- O pai e localizado pelo codigo com uma subconsulta.
-- ---------------------------------------------------------------------

-- 1 ATIVO
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1',        'Ativo',                    NULL,                                          'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1',      'Ativo Circulante',         (SELECT id FROM conta WHERE codigo = '1'),     'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.1',    'Disponível',               (SELECT id FROM conta WHERE codigo = '1.1'),   'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.1.01', 'Caixa',                    (SELECT id FROM conta WHERE codigo = '1.1.1'), 'A', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.1.02', 'Bancos',                   (SELECT id FROM conta WHERE codigo = '1.1.1'), 'A', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.2',    'Créditos',                 (SELECT id FROM conta WHERE codigo = '1.1'),   'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.2.01', 'Clientes',                 (SELECT id FROM conta WHERE codigo = '1.1.2'), 'A', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.3',    'Estoques',                 (SELECT id FROM conta WHERE codigo = '1.1'),   'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.1.3.01', 'Estoques',                 (SELECT id FROM conta WHERE codigo = '1.1.3'), 'A', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.2',      'Ativo Não Circulante',     (SELECT id FROM conta WHERE codigo = '1'),     'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.2.1',    'Imobilizado',              (SELECT id FROM conta WHERE codigo = '1.2'),   'A', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.2.1.01', 'Móveis e Utensílios',      (SELECT id FROM conta WHERE codigo = '1.2.1'), 'A', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.2.1.02', 'Veículos',                 (SELECT id FROM conta WHERE codigo = '1.2.1'), 'A', 'A', 'D');
-- Conta retificadora: grupo Ativo, mas natureza CREDORA
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('1.2.1.09', '(-) Depreciação Acumulada', (SELECT id FROM conta WHERE codigo = '1.2.1'), 'A', 'A', 'C');

-- 2 PASSIVO
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('2',        'Passivo',                  NULL,                                          'P', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('2.1',      'Passivo Circulante',       (SELECT id FROM conta WHERE codigo = '2'),     'P', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('2.1.1',    'Obrigações',               (SELECT id FROM conta WHERE codigo = '2.1'),   'P', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('2.1.1.01', 'Fornecedores',             (SELECT id FROM conta WHERE codigo = '2.1.1'), 'P', 'A', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('2.1.1.02', 'Salários a Pagar',         (SELECT id FROM conta WHERE codigo = '2.1.1'), 'P', 'A', 'C');

-- 3 PATRIMONIO LIQUIDO
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('3',        'Patrimônio Líquido',       NULL,                                          'PL', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('3.1',      'Capital',                  (SELECT id FROM conta WHERE codigo = '3'),     'PL', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('3.1.01',   'Capital Social',           (SELECT id FROM conta WHERE codigo = '3.1'),   'PL', 'A', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('3.2',      'Reservas e Resultados',    (SELECT id FROM conta WHERE codigo = '3'),     'PL', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('3.2.01',   'Lucros ou Prejuízos Acumulados', (SELECT id FROM conta WHERE codigo = '3.2'), 'PL', 'A', 'C');

-- 4 RECEITAS
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('4',        'Receitas',                 NULL,                                          'R', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('4.1',      'Receitas Operacionais',    (SELECT id FROM conta WHERE codigo = '4'),     'R', 'S', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('4.1.01',   'Receita de Vendas',        (SELECT id FROM conta WHERE codigo = '4.1'),   'R', 'A', 'C');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('4.1.02',   'Receita de Serviços',      (SELECT id FROM conta WHERE codigo = '4.1'),   'R', 'A', 'C');

-- 5 DESPESAS
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5',        'Despesas',                 NULL,                                          'D', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5.1',      'Custos',                   (SELECT id FROM conta WHERE codigo = '5'),     'D', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5.1.01',   'CMV',                      (SELECT id FROM conta WHERE codigo = '5.1'),   'D', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5.2',      'Despesas Operacionais',    (SELECT id FROM conta WHERE codigo = '5'),     'D', 'S', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5.2.01',   'Despesa de Salários',      (SELECT id FROM conta WHERE codigo = '5.2'),   'D', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5.2.02',   'Despesa de Manutenção',    (SELECT id FROM conta WHERE codigo = '5.2'),   'D', 'A', 'D');
INSERT INTO conta (codigo, nome, id_pai, grupo, tipo, natureza) VALUES ('5.2.03',   'Serviços de Terceiros',    (SELECT id FROM conta WHERE codigo = '5.2'),   'D', 'A', 'D');

-- ---------------------------------------------------------------------
-- Seguranca
-- ---------------------------------------------------------------------
INSERT INTO permissao (codigo, descricao) VALUES ('CAD_CONTAS',    'Manter plano de contas');
INSERT INTO permissao (codigo, descricao) VALUES ('CAD_ENTIDADES', 'Manter clientes e fornecedores');
INSERT INTO permissao (codigo, descricao) VALUES ('CAD_ITENS',     'Manter itens e serviços');
INSERT INTO permissao (codigo, descricao) VALUES ('CAD_LOCAIS',    'Manter locais de estoque');
INSERT INTO permissao (codigo, descricao) VALUES ('CAD_VEICULOS',  'Manter veículos da frota');
INSERT INTO permissao (codigo, descricao) VALUES ('LANC_INCLUIR',  'Incluir lançamento contábil manual');
INSERT INTO permissao (codigo, descricao) VALUES ('MOV_COMPRA',        'Registrar compras');
INSERT INTO permissao (codigo, descricao) VALUES ('MOV_CONSUMO',       'Registrar consumos de estoque');
INSERT INTO permissao (codigo, descricao) VALUES ('MOV_TRANSFERENCIA', 'Transferir itens entre locais');
INSERT INTO permissao (codigo, descricao) VALUES ('MOV_SERVICO',       'Registrar prestação de serviço');
INSERT INTO permissao (codigo, descricao) VALUES ('MOV_MANUTENCAO',    'Registrar manutenção de veículo');
INSERT INTO permissao (codigo, descricao) VALUES ('EST_CONSULTAR', 'Consultar saldo de estoque e custo por veículo');
INSERT INTO permissao (codigo, descricao) VALUES ('REL_CONTABEIS', 'Razonete, balancete e resumo patrimonial');
INSERT INTO permissao (codigo, descricao) VALUES ('USU_GERENCIAR', 'Gerenciar usuários');

INSERT INTO perfil (nome) VALUES ('Administrador');
INSERT INTO perfil (nome) VALUES ('Contador');
INSERT INTO perfil (nome) VALUES ('Estoquista');

-- Administrador: todas as permissoes
INSERT INTO perfil_permissao (id_perfil, codigo_permissao)
  SELECT (SELECT id FROM perfil WHERE nome = 'Administrador'), codigo FROM permissao;

-- Contador: contabilidade + consulta de estoque
INSERT INTO perfil_permissao (id_perfil, codigo_permissao)
  SELECT (SELECT id FROM perfil WHERE nome = 'Contador'), codigo FROM permissao
  WHERE codigo IN ('CAD_CONTAS', 'LANC_INCLUIR', 'REL_CONTABEIS', 'EST_CONSULTAR');

-- Estoquista: cadastros do ERP + movimentos, sem lancamento manual
INSERT INTO perfil_permissao (id_perfil, codigo_permissao)
  SELECT (SELECT id FROM perfil WHERE nome = 'Estoquista'), codigo FROM permissao
  WHERE codigo IN ('CAD_ENTIDADES', 'CAD_ITENS', 'CAD_LOCAIS', 'CAD_VEICULOS', 'EST_CONSULTAR',
                   'MOV_COMPRA', 'MOV_CONSUMO', 'MOV_TRANSFERENCIA', 'MOV_SERVICO', 'MOV_MANUTENCAO');

INSERT INTO usuario (login, nome, senha_hash, salt, id_perfil) VALUES
  ('admin', 'Administrador', '8007bfee665eaee3c82d828f6effd77df4b3eaf330adcf73a0acfda9887ad186', 'a1f3c9e07b2d4e58',
   (SELECT id FROM perfil WHERE nome = 'Administrador'));
INSERT INTO usuario (login, nome, senha_hash, salt, id_perfil) VALUES
  ('contador', 'Carla Contadora', '2641d666b24ebaf8a615cfc9e6244438024e68666875e6bd93483f9c402c25e7', '5d82b0e6c4a19f37',
   (SELECT id FROM perfil WHERE nome = 'Contador'));
INSERT INTO usuario (login, nome, senha_hash, salt, id_perfil) VALUES
  ('estoquista', 'Edu Estoquista', '90e7a53be59a5d0507ab156d6be5b229065d2a918801bbe367f5f33f5b67d645', 'e7c4192a6fb03d85',
   (SELECT id FROM perfil WHERE nome = 'Estoquista'));

-- ---------------------------------------------------------------------
-- Locais de estoque (2 niveis: almoxarifado > prateleiras)
-- ---------------------------------------------------------------------
INSERT INTO local (codigo, nome, id_pai, aceita_estoque) VALUES ('ALM',    'Almoxarifado Central', NULL, 0);
INSERT INTO local (codigo, nome, id_pai, aceita_estoque) VALUES ('ALM.1A', 'Prateleira 1A', (SELECT id FROM local WHERE codigo = 'ALM'), 1);
INSERT INTO local (codigo, nome, id_pai, aceita_estoque) VALUES ('ALM.1B', 'Prateleira 1B', (SELECT id FROM local WHERE codigo = 'ALM'), 1);
INSERT INTO local (codigo, nome, id_pai, aceita_estoque) VALUES ('ALM.2A', 'Prateleira 2A', (SELECT id FROM local WHERE codigo = 'ALM'), 1);
INSERT INTO local (codigo, nome, id_pai, aceita_estoque) VALUES ('ALM.2B', 'Prateleira 2B', (SELECT id FROM local WHERE codigo = 'ALM'), 1);

-- ---------------------------------------------------------------------
-- Unidades de medida
-- ---------------------------------------------------------------------
INSERT INTO unidade (sigla, descricao) VALUES ('UN', 'Unidade');
INSERT INTO unidade (sigla, descricao) VALUES ('PC', 'Peça');
INSERT INTO unidade (sigla, descricao) VALUES ('CX', 'Caixa');
INSERT INTO unidade (sigla, descricao) VALUES ('KG', 'Quilograma');
INSERT INTO unidade (sigla, descricao) VALUES ('L',  'Litro');
INSERT INTO unidade (sigla, descricao) VALUES ('M',  'Metro');
INSERT INTO unidade (sigla, descricao) VALUES ('H',  'Hora');

-- ---------------------------------------------------------------------
-- Entidades e itens de exemplo
-- ---------------------------------------------------------------------
-- Documentos com digito verificador valido (a tela valida CPF/CNPJ)
INSERT INTO entidade (nome, documento, eh_cliente, eh_fornecedor) VALUES ('Pneus Sul Ltda',       '11.222.333/0001-81', 0, 1);
INSERT INTO entidade (nome, documento, eh_cliente, eh_fornecedor) VALUES ('Auto Peças Brasil SA', '55.666.777/0001-81', 1, 1);
INSERT INTO entidade (nome, documento, eh_cliente, eh_fornecedor) VALUES ('Transportes Silva',    '99.888.777/0001-00', 1, 0);

INSERT INTO veiculo (placa, descricao, ano) VALUES ('ABC1D23', 'Caminhão Volvo FH 540', 2022);
INSERT INTO veiculo (placa, descricao, ano) VALUES ('XYZ9E87', 'Van Mercedes Sprinter', 2020);

INSERT INTO item (codigo, descricao, tipo, unidade, id_conta) VALUES
  ('PNEU-175', 'Pneu 175/70 R14', 'P', 'UN', (SELECT id FROM conta WHERE codigo = '1.1.3.01'));
INSERT INTO item (codigo, descricao, tipo, unidade, id_conta) VALUES
  ('OLEO-5W30', 'Óleo de motor 5W30', 'P', 'L', (SELECT id FROM conta WHERE codigo = '1.1.3.01'));
-- Servico TOMADO (compramos de terceiros): Despesa
INSERT INTO item (codigo, descricao, tipo, unidade, id_conta) VALUES
  ('MO-MEC', 'Mão de obra mecânica', 'S', 'H', (SELECT id FROM conta WHERE codigo = '5.2.03'));
-- Servico PRESTADO (vendemos): Receita
INSERT INTO item (codigo, descricao, tipo, unidade, id_conta) VALUES
  ('SUP-TEC', 'Suporte técnico', 'S', 'H', (SELECT id FROM conta WHERE codigo = '4.1.02'));
