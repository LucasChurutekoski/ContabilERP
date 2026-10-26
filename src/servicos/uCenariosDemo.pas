unit uCenariosDemo;

{ Cenarios prontos para a demonstracao (menu Sistema > Demonstracao).
  Usam os MESMOS servicos que as telas, entao tambem servem de teste manual:
  depois de carregar, o balancete e o resumo devem bater com os valores
  calculados a mao. Restrito ao Administrador. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, uSessao;

// Apaga lancamentos, movimentos e saldos (cadastros ficam). Numeracao volta a 1.
procedure ZerarMovimentos(AConexao: TFDConnection; ASessao: TSessao);

// Pet Shop da Bia: 7 lancamentos manuais. Balancete 25.000 = 25.000.
procedure CarregarPetShop(AConexao: TFDConnection; ASessao: TSessao);

// Frota com pneus: capital, 2 compras, transferencia, consumo e servico prestado.
procedure CarregarPneus(AConexao: TFDConnection; ASessao: TSessao);

implementation

uses
  System.Variants, uLancamentoService, uMovimentoService;

function IdPor(AConexao: TFDConnection; const ATabela, ACampo, AValor: string): Integer;
var
  Id: Variant;
begin
  // ATabela/ACampo sao constantes deste arquivo, nunca texto digitado pelo usuario
  Id := AConexao.ExecSQLScalar(Format('SELECT id FROM %s WHERE %s = :valor', [ATabela, ACampo]), [AValor]);
  if VarIsNull(Id) or VarIsEmpty(Id) then
    raise Exception.CreateFmt('Cadastro não encontrado: %s.%s = %s (o seed foi alterado?)', [ATabela, ACampo, AValor]);
  Result := Id;
end;

procedure ZerarMovimentos(AConexao: TFDConnection; ASessao: TSessao);
begin
  ASessao.Exigir('USU_GERENCIAR');
  AConexao.StartTransaction;
  try
    AConexao.ExecSQL('DELETE FROM partida');
    AConexao.ExecSQL('DELETE FROM lancamento');
    AConexao.ExecSQL('DELETE FROM movimento_item');
    AConexao.ExecSQL('DELETE FROM movimento');
    AConexao.ExecSQL('DELETE FROM saldo_estoque');
    AConexao.ExecSQL('UPDATE item SET custo_medio_centavos = 0');
    // sqlite_sequence guarda o ultimo AUTOINCREMENT de cada tabela
    AConexao.ExecSQL('DELETE FROM sqlite_sequence WHERE name IN (''partida'', ''lancamento'', ''movimento_item'', ''movimento'')');
    AConexao.Commit;
  except
    AConexao.Rollback;
    raise;
  end;
end;

procedure CarregarPetShop(AConexao: TFDConnection; ASessao: TSessao);
var
  Servico: TLancamentoService;
  Bancos, Capital, Moveis, Estoques, Fornecedores, Vendas, CMV, Salarios: Integer;
  Hoje: TDate;
begin
  ASessao.Exigir('USU_GERENCIAR');
  Servico := TLancamentoService.Create(AConexao);
  try
    Bancos       := Servico.IdConta('1.1.1.02');
    Capital      := Servico.IdConta('3.1.01');
    Moveis       := Servico.IdConta('1.2.1.01');
    Estoques     := Servico.IdConta('1.1.3.01');
    Fornecedores := Servico.IdConta('2.1.1.01');
    Vendas       := Servico.IdConta('4.1.01');
    CMV          := Servico.IdConta('5.1.01');
    Salarios     := Servico.IdConta('5.2.01');
    Hoje := Date;

    // Tudo ou nada: os 7 lancamentos participam de uma unica transacao
    AConexao.StartTransaction;
    try
      Servico.RegistrarManual(ASessao, Hoje, '(i) Integralização de capital',
        [TPartida.Debito(Bancos, 20000), TPartida.Credito(Capital, 20000)]);
      Servico.RegistrarManual(ASessao, Hoje, '(1) Compra de móveis à vista',
        [TPartida.Debito(Moveis, 4000), TPartida.Credito(Bancos, 4000)]);
      Servico.RegistrarManual(ASessao, Hoje, '(2) Compra de estoque: metade à vista, metade a prazo',
        [TPartida.Debito(Estoques, 6000), TPartida.Credito(Bancos, 3000), TPartida.Credito(Fornecedores, 3000)]);
      Servico.RegistrarManual(ASessao, Hoje, '(3a) Venda de mercadorias à vista',
        [TPartida.Debito(Bancos, 5000), TPartida.Credito(Vendas, 5000)]);
      Servico.RegistrarManual(ASessao, Hoje, '(3b) Baixa do custo da mercadoria vendida',
        [TPartida.Debito(CMV, 3000), TPartida.Credito(Estoques, 3000)]);
      Servico.RegistrarManual(ASessao, Hoje, '(4) Pagamento de salários',
        [TPartida.Debito(Salarios, 1500), TPartida.Credito(Bancos, 1500)]);
      Servico.RegistrarManual(ASessao, Hoje, '(5) Pagamento ao fornecedor',
        [TPartida.Debito(Fornecedores, 3000), TPartida.Credito(Bancos, 3000)]);
      AConexao.Commit;
    except
      AConexao.Rollback;
      raise;
    end;
  finally
    Servico.Free;
  end;
end;

function NovoItem(AIdItem, AIdOrigem, AIdDestino: Integer; AQuantidade: Double;
  AValorUnitario: Currency): TItemMovimento;
begin
  Result.IdItem := AIdItem;
  Result.IdLocalOrigem := AIdOrigem;
  Result.IdLocalDestino := AIdDestino;
  Result.Quantidade := AQuantidade;
  Result.ValorUnitario := AValorUnitario;
end;

procedure CarregarPneus(AConexao: TFDConnection; ASessao: TSessao);
var
  Lancamentos: TLancamentoService;
  Movimentos: TMovimentoService;
  Mov: TMovimento;
  Pneu, SuporteTecnico, Prateleira1A, Prateleira2B, Fornecedor, Cliente, Manutencao: Integer;
begin
  ASessao.Exigir('USU_GERENCIAR');
  Pneu           := IdPor(AConexao, 'item', 'codigo', 'PNEU-175');
  SuporteTecnico := IdPor(AConexao, 'item', 'codigo', 'SUP-TEC');
  Prateleira1A   := IdPor(AConexao, 'local', 'codigo', 'ALM.1A');
  Prateleira2B   := IdPor(AConexao, 'local', 'codigo', 'ALM.2B');
  Fornecedor     := IdPor(AConexao, 'entidade', 'documento', '11.222.333/0001-81'); // Pneus Sul
  Cliente        := IdPor(AConexao, 'entidade', 'documento', '99.888.777/0001-00'); // Transportes Silva
  Manutencao     := IdPor(AConexao, 'conta', 'codigo', '5.2.02');

  Lancamentos := TLancamentoService.Create(AConexao);
  Movimentos := TMovimentoService.Create(AConexao, ASessao);
  try
    AConexao.StartTransaction;
    try
      // (0) Capital inicial, para o caixa nao ficar negativo
      Lancamentos.RegistrarManual(ASessao, Date, 'Integralização de capital',
        [TPartida.Debito(Lancamentos.IdConta('1.1.1.02'), 10000),
         TPartida.Credito(Lancamentos.IdConta('3.1.01'), 10000)]);

      // (1) Compra a vista: 4 pneus x 500 na prateleira 1A
      Mov := Default(TMovimento);
      Mov.Data := Date;
      Mov.Operacao := opCompra;
      Mov.IdEntidade := Fornecedor;
      Mov.AVista := True;
      Mov.Itens := [NovoItem(Pneu, 0, Prateleira1A, 4, 500)];
      Movimentos.Registrar(Mov);

      // (2) Compra a prazo: 2 pneus x 560 na prateleira 2B -> custo medio 520
      Mov.AVista := False;
      Mov.Itens := [NovoItem(Pneu, 0, Prateleira2B, 2, 560)];
      Movimentos.Registrar(Mov);

      // (3) Transferencia: 1 pneu da 2B para a 1A (nao gera lancamento)
      Mov := Default(TMovimento);
      Mov.Data := Date;
      Mov.Operacao := opTransferencia;
      Mov.Itens := [NovoItem(Pneu, Prateleira2B, Prateleira1A, 1, 0)];
      Movimentos.Registrar(Mov);

      // (4) Consumo: 1 pneu da 1A na manutencao da frota -> D Desp. Manutencao 520
      Mov := Default(TMovimento);
      Mov.Data := Date;
      Mov.Operacao := opConsumo;
      Mov.IdContaDestino := Manutencao;
      Mov.Observacao := 'Troca de pneu do caminhão ABC-1234';
      Mov.Itens := [NovoItem(Pneu, Prateleira1A, 0, 1, 0)];
      Movimentos.Registrar(Mov);

      // (5) Servico prestado a vista: 2 horas de suporte tecnico x 150
      Mov := Default(TMovimento);
      Mov.Data := Date;
      Mov.Operacao := opServico;
      Mov.IdEntidade := Cliente;
      Mov.AVista := True;
      Mov.Itens := [NovoItem(SuporteTecnico, 0, 0, 2, 150)];
      Movimentos.Registrar(Mov);

      AConexao.Commit;
    except
      AConexao.Rollback;
      raise;
    end;
  finally
    Movimentos.Free;
    Lancamentos.Free;
  end;
end;

end.
