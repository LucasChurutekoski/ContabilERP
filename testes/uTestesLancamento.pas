unit uTestesLancamento;

{ Testes da Fase 2:
  - TTestesSaldo: calculo de saldo (puro, sem banco)
  - TTestesRegrasLancamento: debito = credito (puro, sem banco)
  - TTestesLancamentoService: servico real contra um SQLite em memoria,
    incluindo o cenario completo do Pet Shop da Bia. }

interface

uses
  DUnitX.TestFramework, uDM, uSaldo, uLancamentoService;

type
  [TestFixture]
  TTestesSaldo = class
  public
    [Test] procedure SaldoDevedorFicaDoLadoMaior;
    [Test] procedure SaldoCredorFicaDoLadoMaior;
    [Test] procedure DebitosIguaisACreditosZeraOSaldo;
    [Test] procedure DetectaSaldoInvertido;
  end;

  [TestFixture]
  TTestesRegrasLancamento = class
  public
    [Test] procedure AceitaLancamentoComVariasPartidasBalanceado;
    [Test] procedure RejeitaLancamentoDesbalanceado;
    [Test] procedure RejeitaValorZeroOuNegativo;
    [Test] procedure RejeitaMenosDeDuasPartidas;
    [Test] procedure RejeitaHistoricoVazio;
  end;

  [TestFixture]
  TTestesLancamentoService = class
  private
    FDM: TDM;
    FServico: TLancamentoService;
    function Conta(const ACodigo: string): Integer;
    function QtdLancamentos: Integer;
    procedure ConferirSaldo(const ACodigo: string; AValor: Currency; ALado: Char);
    procedure LancarCenarioPetShop;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure GravaLancamentoEPartidas;
    [Test] procedure RejeitaDesbalanceadoSemGravarNada;
    [Test] procedure RejeitaContaSinteticaSemGravarNada;
    [Test] procedure CenarioPetShopSaldosDasContas;
    [Test] procedure CenarioPetShopBalanceteFecha;
  end;

implementation

uses
  System.SysUtils, FireDAC.Comp.Client;

const
  ADMIN = 1; // usuario admin do seed

function DataTeste: TDate;
begin
  Result := EncodeDate(2026, 10, 1);
end;

{ TTestesSaldo }

procedure TTestesSaldo.SaldoDevedorFicaDoLadoMaior;
var
  Saldo: TSaldo;
begin
  // Bancos do Pet Shop: D 20.000 + 5.000 / C 4.000 + 3.000 + 1.500 + 3.000
  Saldo := TSaldo.Calcular(25000, 11500);
  Assert.IsTrue(Saldo.Valor = 13500, 'valor');
  Assert.IsTrue(Saldo.Lado = 'D', 'lado');
end;

procedure TTestesSaldo.SaldoCredorFicaDoLadoMaior;
var
  Saldo: TSaldo;
begin
  Saldo := TSaldo.Calcular(0, 20000);
  Assert.IsTrue(Saldo.Valor = 20000, 'valor');
  Assert.IsTrue(Saldo.Lado = 'C', 'lado');
end;

procedure TTestesSaldo.DebitosIguaisACreditosZeraOSaldo;
var
  Saldo: TSaldo;
begin
  // Fornecedores: C 3.000 na compra, D 3.000 no pagamento
  Saldo := TSaldo.Calcular(3000, 3000);
  Assert.IsTrue(Saldo.Valor = 0, 'valor');
  Assert.IsTrue(Saldo.Lado = ' ', 'lado');
end;

procedure TTestesSaldo.DetectaSaldoInvertido;
begin
  Assert.IsTrue(TSaldo.Calcular(100, 500).Invertido('D'), 'conta devedora com saldo credor');
  Assert.IsFalse(TSaldo.Calcular(500, 100).Invertido('D'), 'conta devedora com saldo devedor');
  Assert.IsFalse(TSaldo.Calcular(100, 100).Invertido('C'), 'saldo zerado nunca e invertido');
end;

{ TTestesRegrasLancamento }

procedure TTestesRegrasLancamento.AceitaLancamentoComVariasPartidasBalanceado;
var
  Partidas: TArray<TPartida>;
begin
  // (2) D Estoques 6.000 / C Bancos 3.000 + C Fornecedores 3.000
  Partidas := [TPartida.Debito(1, 6000), TPartida.Credito(2, 3000), TPartida.Credito(3, 3000)];
  Assert.IsTrue(TLancamentoService.TotalDebitos(Partidas) = 6000, 'debitos');
  Assert.IsTrue(TLancamentoService.TotalCreditos(Partidas) = 6000, 'creditos');
  Assert.WillNotRaise(
    procedure
    begin
      TLancamentoService.ValidarRegras('Compra de estoque', Partidas);
    end);
end;

procedure TTestesRegrasLancamento.RejeitaLancamentoDesbalanceado;
var
  Partidas: TArray<TPartida>;
begin
  Partidas := [TPartida.Debito(1, 6000), TPartida.Credito(2, 3000)];
  Assert.WillRaise(
    procedure
    begin
      TLancamentoService.ValidarRegras('Desbalanceado', Partidas);
    end, ELancamentoInvalido);
end;

procedure TTestesRegrasLancamento.RejeitaValorZeroOuNegativo;
var
  Partidas: TArray<TPartida>;
begin
  Partidas := [TPartida.Debito(1, -100), TPartida.Credito(2, -100)];
  Assert.WillRaise(
    procedure
    begin
      TLancamentoService.ValidarRegras('Negativo', Partidas);
    end, ELancamentoInvalido);
end;

procedure TTestesRegrasLancamento.RejeitaMenosDeDuasPartidas;
var
  Partidas: TArray<TPartida>;
begin
  Partidas := [TPartida.Debito(1, 100)];
  Assert.WillRaise(
    procedure
    begin
      TLancamentoService.ValidarRegras('Uma partida so', Partidas);
    end, ELancamentoInvalido);
end;

procedure TTestesRegrasLancamento.RejeitaHistoricoVazio;
var
  Partidas: TArray<TPartida>;
begin
  Partidas := [TPartida.Debito(1, 100), TPartida.Credito(2, 100)];
  Assert.WillRaise(
    procedure
    begin
      TLancamentoService.ValidarRegras('   ', Partidas);
    end, ELancamentoInvalido);
end;

{ TTestesLancamentoService }

procedure TTestesLancamentoService.Setup;
begin
  // Banco novo e vazio para cada teste: schema + seed rodam em memoria
  FDM := TDM.Create(nil);
  FDM.Conectar(':memory:');
  FServico := TLancamentoService.Create(FDM.Conexao);
end;

procedure TTestesLancamentoService.TearDown;
begin
  FServico.Free;
  FDM.Free;
end;

function TTestesLancamentoService.Conta(const ACodigo: string): Integer;
begin
  Result := FServico.IdConta(ACodigo);
end;

function TTestesLancamentoService.QtdLancamentos: Integer;
begin
  Result := FDM.Conexao.ExecSQLScalar('SELECT COUNT(*) FROM lancamento');
end;

procedure TTestesLancamentoService.ConferirSaldo(const ACodigo: string; AValor: Currency; ALado: Char);
var
  Saldo: TSaldo;
begin
  Saldo := FServico.SaldoConta(Conta(ACodigo));
  Assert.IsTrue((Saldo.Valor = AValor) and (Saldo.Lado = ALado),
    Format('Conta %s: esperado %s %s, obtido %s',
      [ACodigo, FormatFloat('#,##0.00', AValor), ALado, Saldo.Texto]));
end;

procedure TTestesLancamentoService.LancarCenarioPetShop;
var
  Bancos, Capital, Moveis, Estoques, Fornecedores, Vendas, CMV, Salarios: Integer;
begin
  Bancos       := Conta('1.1.1.02');
  Capital      := Conta('3.1.01');
  Moveis       := Conta('1.2.1.01');
  Estoques     := Conta('1.1.3.01');
  Fornecedores := Conta('2.1.1.01');
  Vendas       := Conta('4.1.01');
  CMV          := Conta('5.1.01');
  Salarios     := Conta('5.2.01');

  // (i)  Integralizacao do capital
  FServico.Registrar(DataTeste, 'Integralização de capital',
    [TPartida.Debito(Bancos, 20000), TPartida.Credito(Capital, 20000)], ADMIN);
  // (1)  Compra de moveis a vista
  FServico.Registrar(DataTeste, 'Compra de móveis',
    [TPartida.Debito(Moveis, 4000), TPartida.Credito(Bancos, 4000)], ADMIN);
  // (2)  Compra de estoque: metade a vista, metade a prazo
  FServico.Registrar(DataTeste, 'Compra de estoque',
    [TPartida.Debito(Estoques, 6000), TPartida.Credito(Bancos, 3000),
     TPartida.Credito(Fornecedores, 3000)], ADMIN);
  // (3a) Venda a vista
  FServico.Registrar(DataTeste, 'Venda de mercadorias',
    [TPartida.Debito(Bancos, 5000), TPartida.Credito(Vendas, 5000)], ADMIN);
  // (3b) Baixa do custo da mercadoria vendida
  FServico.Registrar(DataTeste, 'CMV da venda',
    [TPartida.Debito(CMV, 3000), TPartida.Credito(Estoques, 3000)], ADMIN);
  // (4)  Pagamento de salarios
  FServico.Registrar(DataTeste, 'Pagamento de salários',
    [TPartida.Debito(Salarios, 1500), TPartida.Credito(Bancos, 1500)], ADMIN);
  // (5)  Pagamento ao fornecedor
  FServico.Registrar(DataTeste, 'Pagamento a fornecedor',
    [TPartida.Debito(Fornecedores, 3000), TPartida.Credito(Bancos, 3000)], ADMIN);
end;

procedure TTestesLancamentoService.GravaLancamentoEPartidas;
var
  Numero: Integer;
begin
  Numero := FServico.Registrar(DataTeste, 'Integralização de capital',
    [TPartida.Debito(Conta('1.1.1.02'), 20000), TPartida.Credito(Conta('3.1.01'), 20000)], ADMIN);

  Assert.AreEqual(1, Numero, 'numero do lancamento');
  Assert.AreEqual(1, QtdLancamentos, 'lancamentos gravados');
  Assert.AreEqual(2, Integer(FDM.Conexao.ExecSQLScalar(
    'SELECT COUNT(*) FROM partida WHERE id_lancamento = :id', [Numero])), 'partidas gravadas');
end;

procedure TTestesLancamentoService.RejeitaDesbalanceadoSemGravarNada;
begin
  Assert.WillRaise(
    procedure
    begin
      FServico.Registrar(DataTeste, 'Desbalanceado',
        [TPartida.Debito(Conta('1.1.3.01'), 6000), TPartida.Credito(Conta('1.1.1.02'), 3000)], ADMIN);
    end, ELancamentoInvalido);
  Assert.AreEqual(0, QtdLancamentos, 'nada pode ter sido gravado');
end;

procedure TTestesLancamentoService.RejeitaContaSinteticaSemGravarNada;
begin
  // 1.1.1 Disponivel e sintetica (so soma Caixa e Bancos)
  Assert.WillRaise(
    procedure
    begin
      FServico.Registrar(DataTeste, 'Conta sintética',
        [TPartida.Debito(Conta('1.1.1'), 100), TPartida.Credito(Conta('3.1.01'), 100)], ADMIN);
    end, ELancamentoInvalido);
  Assert.AreEqual(0, QtdLancamentos, 'nada pode ter sido gravado');
end;

procedure TTestesLancamentoService.CenarioPetShopSaldosDasContas;
begin
  LancarCenarioPetShop;
  Assert.AreEqual(7, QtdLancamentos, 'lancamentos');

  ConferirSaldo('1.1.1.02', 13500, 'D'); // Bancos
  ConferirSaldo('1.2.1.01',  4000, 'D'); // Moveis e Utensilios
  ConferirSaldo('1.1.3.01',  3000, 'D'); // Estoques
  ConferirSaldo('2.1.1.01',     0, ' '); // Fornecedores
  ConferirSaldo('3.1.01',   20000, 'C'); // Capital Social
  ConferirSaldo('4.1.01',    5000, 'C'); // Receita de Vendas
  ConferirSaldo('5.1.01',    3000, 'D'); // CMV
  ConferirSaldo('5.2.01',    1500, 'D'); // Despesa de Salarios
end;

procedure TTestesLancamentoService.CenarioPetShopBalanceteFecha;
var
  Query: TFDQuery;
  Saldo: TSaldo;
  TotalDevedor, TotalCredor: Currency;
begin
  LancarCenarioPetShop;

  // Soma os saldos de todas as contas analiticas, separando por lado
  TotalDevedor := 0;
  TotalCredor := 0;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDM.Conexao;
    Query.Open('SELECT id FROM conta WHERE tipo = ''A''');
    while not Query.Eof do
    begin
      Saldo := FServico.SaldoConta(Query.FieldByName('id').AsInteger);
      if Saldo.Lado = 'D' then
        TotalDevedor := TotalDevedor + Saldo.Valor
      else if Saldo.Lado = 'C' then
        TotalCredor := TotalCredor + Saldo.Valor;
      Query.Next;
    end;
  finally
    Query.Free;
  end;

  Assert.IsTrue(TotalDevedor = 25000, 'Total devedor esperado 25.000, obtido ' + FormatFloat('#,##0.00', TotalDevedor));
  Assert.IsTrue(TotalCredor = 25000, 'Total credor esperado 25.000, obtido ' + FormatFloat('#,##0.00', TotalCredor));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestesSaldo);
  TDUnitX.RegisterTestFixture(TTestesRegrasLancamento);
  TDUnitX.RegisterTestFixture(TTestesLancamentoService);

end.
