unit uLancamentoService;

{ Regras de negocio dos lancamentos contabeis.
  Nao conhece nenhuma tela: recebe a conexao no construtor (injecao de
  dependencia) e e usado tanto pelos formularios quanto pelos testes. }

interface

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Param, FireDAC.Comp.Client, uSaldo, uSessao;

type
  ELancamentoInvalido = class(Exception);

  TPartida = record
    IdConta: Integer;
    DC: Char;          // 'D' = debito, 'C' = credito
    Valor: Currency;

    class function Debito(AIdConta: Integer; AValor: Currency): TPartida; static;
    class function Credito(AIdConta: Integer; AValor: Currency): TPartida; static;
  end;

  TLancamentoService = class
  private
    FConexao: TFDConnection;
    procedure ValidarContas(const APartidas: TArray<TPartida>);
  public
    constructor Create(AConexao: TFDConnection);

    // Regras puras (sem banco): usadas pela tela para mostrar a diferenca em tempo real
    class function TotalDebitos(const APartidas: TArray<TPartida>): Currency;
    class function TotalCreditos(const APartidas: TArray<TPartida>): Currency;
    class procedure ValidarRegras(const AHistorico: string; const APartidas: TArray<TPartida>);

    { Grava o lancamento e devolve o numero (id) gerado.
      AIdMovimento > 0 indica lancamento gerado pelo estoque (origem 'E'). }
    function Registrar(AData: TDate; const AHistorico: string;
      const APartidas: TArray<TPartida>; AIdUsuario: Integer;
      AIdMovimento: Integer = 0): Integer;

    // Lancamento digitado pelo usuario: exige a permissao LANC_INCLUIR
    function RegistrarManual(ASessao: TSessao; AData: TDate; const AHistorico: string;
      const APartidas: TArray<TPartida>): Integer;

    function IdConta(const ACodigo: string): Integer;
    function SaldoConta(AIdConta: Integer): TSaldo;
  end;

implementation

uses
  System.Variants;

function EmCentavos(const AValor: Currency): Int64;
begin
  Result := Round(AValor * 100);
end;

{ TPartida }

class function TPartida.Debito(AIdConta: Integer; AValor: Currency): TPartida;
begin
  Result.IdConta := AIdConta;
  Result.DC := 'D';
  Result.Valor := AValor;
end;

class function TPartida.Credito(AIdConta: Integer; AValor: Currency): TPartida;
begin
  Result.IdConta := AIdConta;
  Result.DC := 'C';
  Result.Valor := AValor;
end;

{ TLancamentoService }

constructor TLancamentoService.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
end;

class function TLancamentoService.TotalDebitos(const APartidas: TArray<TPartida>): Currency;
var
  Partida: TPartida;
begin
  Result := 0;
  for Partida in APartidas do
    if Partida.DC = 'D' then
      Result := Result + Partida.Valor;
end;

class function TLancamentoService.TotalCreditos(const APartidas: TArray<TPartida>): Currency;
var
  Partida: TPartida;
begin
  Result := 0;
  for Partida in APartidas do
    if Partida.DC = 'C' then
      Result := Result + Partida.Valor;
end;

class procedure TLancamentoService.ValidarRegras(const AHistorico: string;
  const APartidas: TArray<TPartida>);
var
  Partida: TPartida;
  Debitos, Creditos: Currency;
begin
  if Trim(AHistorico) = '' then
    raise ELancamentoInvalido.Create('Informe o histórico do lançamento.');

  if Length(APartidas) < 2 then
    raise ELancamentoInvalido.Create('O lançamento precisa de pelo menos duas partidas (um débito e um crédito).');

  for Partida in APartidas do
  begin
    if Partida.IdConta <= 0 then
      raise ELancamentoInvalido.Create('Há uma partida sem conta informada.');
    if not CharInSet(Partida.DC, ['D', 'C']) then
      raise ELancamentoInvalido.Create('Cada partida deve ser D (débito) ou C (crédito).');
    if Partida.Valor <= 0 then
      raise ELancamentoInvalido.Create('Os valores das partidas devem ser maiores que zero.');
  end;

  // Partidas dobradas: total de debitos = total de creditos
  Debitos := TotalDebitos(APartidas);
  Creditos := TotalCreditos(APartidas);
  if Debitos <> Creditos then
    raise ELancamentoInvalido.CreateFmt(
      'Lançamento desbalanceado: débitos %s, créditos %s (diferença %s).',
      [FormatFloat('#,##0.00', Debitos), FormatFloat('#,##0.00', Creditos),
       FormatFloat('#,##0.00', Abs(Debitos - Creditos))]);
end;

procedure TLancamentoService.ValidarContas(const APartidas: TArray<TPartida>);
var
  Query: TFDQuery;
  Partida: TPartida;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT codigo, nome, tipo FROM conta WHERE id = :id';
    for Partida in APartidas do
    begin
      Query.Close;
      Query.ParamByName('id').AsInteger := Partida.IdConta;
      Query.Open;

      if Query.IsEmpty then
        raise ELancamentoInvalido.CreateFmt('A conta %d não existe.', [Partida.IdConta]);

      if Query.FieldByName('tipo').AsString <> 'A' then
        raise ELancamentoInvalido.CreateFmt(
          'A conta %s - %s é sintética: só contas analíticas recebem lançamentos.',
          [Query.FieldByName('codigo').AsString, Query.FieldByName('nome').AsString]);
    end;
  finally
    Query.Free;
  end;
end;

function TLancamentoService.Registrar(AData: TDate; const AHistorico: string;
  const APartidas: TArray<TPartida>; AIdUsuario: Integer; AIdMovimento: Integer): Integer;
var
  TransacaoPropria: Boolean;
  Partida: TPartida;
  Origem: string;
  IdMovimento: Variant;
begin
  // 1) Valida tudo ANTES de tocar no banco
  ValidarRegras(AHistorico, APartidas);
  ValidarContas(APartidas);

  if AIdMovimento > 0 then
  begin
    Origem := 'E';
    IdMovimento := AIdMovimento;
  end
  else
  begin
    Origem := 'M';
    IdMovimento := Null;
  end;

  // 2) Grava cabecalho + partidas numa transacao.
  //    Se quem chamou ja abriu uma (ex.: servico de estoque), participa dela.
  TransacaoPropria := not FConexao.InTransaction;
  if TransacaoPropria then
    FConexao.StartTransaction;
  try
    FConexao.ExecSQL(
      'INSERT INTO lancamento (data, historico, origem, id_movimento, id_usuario) ' +
      'VALUES (:data, :historico, :origem, :id_movimento, :id_usuario)',
      [FormatDateTime('yyyy-mm-dd', AData), AHistorico, Origem, IdMovimento, AIdUsuario],
      [ftString, ftString, ftString, ftInteger, ftInteger]);

    Result := FConexao.ExecSQLScalar('SELECT last_insert_rowid()');

    for Partida in APartidas do
      FConexao.ExecSQL(
        'INSERT INTO partida (id_lancamento, id_conta, dc, valor_centavos) ' +
        'VALUES (:id_lancamento, :id_conta, :dc, :valor_centavos)',
        [Result, Partida.IdConta, string(Partida.DC), EmCentavos(Partida.Valor)],
        [ftInteger, ftInteger, ftString, ftLargeint]);

    if TransacaoPropria then
      FConexao.Commit;
  except
    if TransacaoPropria then
      FConexao.Rollback;
    raise;
  end;
end;

function TLancamentoService.RegistrarManual(ASessao: TSessao; AData: TDate;
  const AHistorico: string; const APartidas: TArray<TPartida>): Integer;
begin
  ASessao.Exigir('LANC_INCLUIR');
  Result := Registrar(AData, AHistorico, APartidas, ASessao.IdUsuario);
end;

function TLancamentoService.IdConta(const ACodigo: string): Integer;
var
  Id: Variant;
begin
  Id := FConexao.ExecSQLScalar('SELECT id FROM conta WHERE codigo = :codigo', [ACodigo]);
  if VarIsNull(Id) or VarIsEmpty(Id) then
    raise ELancamentoInvalido.CreateFmt('Conta de código %s não encontrada.', [ACodigo]);
  Result := Id;
end;

function TLancamentoService.SaldoConta(AIdConta: Integer): TSaldo;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text :=
      'SELECT COALESCE(SUM(CASE WHEN dc = ''D'' THEN valor_centavos END), 0) AS debitos, ' +
      '       COALESCE(SUM(CASE WHEN dc = ''C'' THEN valor_centavos END), 0) AS creditos ' +
      'FROM partida WHERE id_conta = :id_conta';
    Query.ParamByName('id_conta').AsInteger := AIdConta;
    Query.Open;
    Result := TSaldo.Calcular(
      Query.FieldByName('debitos').AsLargeInt / 100,
      Query.FieldByName('creditos').AsLargeInt / 100);
  finally
    Query.Free;
  end;
end;

end.
