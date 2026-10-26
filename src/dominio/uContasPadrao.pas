unit uContasPadrao;

{ Contas usadas como contrapartida nos lancamentos automaticos do estoque.
  Num ERP real isso seria configuravel (tabela de parametros / naturezas de
  operacao); aqui ficam fixas para manter o MVP simples. }

interface

const
  CONTA_BANCOS       = '1.1.1.02';
  CONTA_CLIENTES     = '1.1.2.01';
  CONTA_FORNECEDORES = '2.1.1.01';

implementation

end.
