unit uConsultaService;

{ Consultas contabeis e de estoque. As telas e o relatorio do FastReport
  usam ESTAS consultas: a regra de calculo fica num lugar so.
  Valores em dinheiro saem em centavos (inteiros); a tela formata em reais. }

interface

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Param, FireDAC.Comp.Client;

type
  TTotaisBalancete = record
    Devedor: Currency;
    Credor: Currency;
    function Fecha: Boolean;
  end;

  TResumoPatrimonial = record
    Ativo: Currency;
    Passivo: Currency;
    PatrimonioLiquido: Currency;  // capital e reservas (sem o resultado do periodo)
    Receitas: Currency;
    Despesas: Currency;
    function Lucro: Currency;
    function PLComResultado: Currency;
    function Fecha: Boolean;      // Ativo = Passivo + PL
  end;

  TConciliacaoEstoque = record
    Fisico: Currency;    // quantidade x custo medio
    Contabil: Currency;  // saldo das contas usadas pelos produtos
    function Diferenca: Currency;
  end;

  TConsultaService = class
  private
    FConexao: TFDConnection;
  public
    constructor Create(AConexao: TFDConnection);

    // Partidas de uma conta de um lado do T ('D' ou 'C')
    procedure AbrirRazonete(AQuery: TFDQuery; AIdConta: Integer; const ADC: string);
    // Contas analiticas movimentadas com debitos, creditos e saldo
    procedure AbrirBalancete(AQuery: TFDQuery);
    // Saldo fisico por item e local
    procedure AbrirSaldoEstoque(AQuery: TFDQuery);
    // Livro Diario: lancamentos e partidas entre duas datas
    procedure AbrirDiario(AQuery: TFDQuery; ADe, AAte: TDate);
    // Resumo do custo de manutencao de cada veiculo
    procedure AbrirCustoPorVeiculo(AQuery: TFDQuery);
    { Historico de movimentos (kardex): cada item de cada movimento no periodo.
      AIdItem = 0 traz todos os itens; AOperacao = '' traz todas as operacoes. }
    procedure AbrirHistoricoMovimentos(AQuery: TFDQuery; ADe, AAte: TDate;
      AIdItem: Integer; const AOperacao: string);

    function TotaisBalancete: TTotaisBalancete;
    function Resumo: TResumoPatrimonial;
    function ConciliacaoEstoque: TConciliacaoEstoque;
  end;

const
  SQL_RAZONETE =
    'SELECT l.id AS numero, l.data, l.historico, p.valor_centavos ' +
    'FROM partida p JOIN lancamento l ON l.id = p.id_lancamento ' +
    'WHERE p.id_conta = :id_conta AND p.dc = :dc ' +
    'ORDER BY l.data, l.id';

  // "liquido" = debitos - creditos. Positivo = saldo devedor; negativo = credor.
  SQL_BALANCETE =
    'SELECT c.codigo, c.nome, c.natureza, ' +
    '  SUM(CASE WHEN p.dc = ''D'' THEN p.valor_centavos ELSE 0 END) AS debitos_c, ' +
    '  SUM(CASE WHEN p.dc = ''C'' THEN p.valor_centavos ELSE 0 END) AS creditos_c, ' +
    '  MAX(SUM(CASE WHEN p.dc = ''D'' THEN p.valor_centavos ELSE -p.valor_centavos END), 0) AS saldo_devedor_c, ' +
    '  MAX(-SUM(CASE WHEN p.dc = ''D'' THEN p.valor_centavos ELSE -p.valor_centavos END), 0) AS saldo_credor_c ' +
    'FROM conta c JOIN partida p ON p.id_conta = c.id ' +
    'GROUP BY c.id, c.codigo, c.nome, c.natureza ' +
    'ORDER BY c.codigo';

  SQL_TOTAIS_BALANCETE =
    'SELECT COALESCE(SUM(MAX(liquido, 0)), 0) AS devedor_c, ' +
    '       COALESCE(SUM(MAX(-liquido, 0)), 0) AS credor_c ' +
    'FROM (SELECT SUM(CASE WHEN dc = ''D'' THEN valor_centavos ELSE -valor_centavos END) AS liquido ' +
    '      FROM partida GROUP BY id_conta)';

  SQL_RESUMO =
    'SELECT c.grupo, SUM(CASE WHEN p.dc = ''D'' THEN p.valor_centavos ELSE -p.valor_centavos END) AS liquido_c ' +
    'FROM partida p JOIN conta c ON c.id = p.id_conta ' +
    'GROUP BY c.grupo';

  SQL_SALDO_ESTOQUE =
    'SELECT i.codigo, i.descricao, i.unidade, l.codigo AS local_codigo, l.nome AS local_nome, ' +
    '       s.quantidade, i.custo_medio_centavos, ' +
    '       CAST(ROUND(s.quantidade * i.custo_medio_centavos) AS INTEGER) AS valor_total_c ' +
    'FROM saldo_estoque s ' +
    'JOIN item i ON i.id = s.id_item ' +
    'JOIN local l ON l.id = s.id_local ' +
    'WHERE s.quantidade > 0 ' +
    'ORDER BY i.codigo, l.codigo';

  // Debitos primeiro dentro de cada lancamento ('D' > 'C' em ordem decrescente)
  SQL_DIARIO =
    'SELECT l.id AS numero, l.data, l.historico, l.origem, c.codigo, c.nome, p.dc, p.valor_centavos ' +
    'FROM lancamento l ' +
    'JOIN partida p ON p.id_lancamento = l.id ' +
    'JOIN conta c ON c.id = p.id_conta ' +
    'WHERE l.data BETWEEN :de AND :ate ' +
    'ORDER BY l.data, l.id, p.dc DESC, p.id';

  // Valor de cada linha = quantidade x valor unitario gravado no movimento
  // (pecas: custo medio da epoca; mao de obra: valor pago)
  SQL_CUSTO_VEICULO =
    'SELECT v.id, v.placa, v.descricao, COUNT(DISTINCT m.id) AS manutencoes, ' +
    '  COALESCE(SUM(CASE WHEN i.tipo = ''P'' THEN CAST(ROUND(mi.quantidade * mi.valor_unit_centavos) AS INTEGER) END), 0) AS pecas_c, ' +
    '  COALESCE(SUM(CASE WHEN i.tipo = ''S'' THEN CAST(ROUND(mi.quantidade * mi.valor_unit_centavos) AS INTEGER) END), 0) AS mao_de_obra_c, ' +
    '  COALESCE(SUM(CAST(ROUND(mi.quantidade * mi.valor_unit_centavos) AS INTEGER)), 0) AS total_c ' +
    'FROM veiculo v ' +
    'LEFT JOIN movimento m ON m.id_veiculo = v.id AND m.operacao = ''MANUTENCAO'' ' +
    'LEFT JOIN movimento_item mi ON mi.id_movimento = m.id ' +
    'LEFT JOIN item i ON i.id = mi.id_item ' +
    'GROUP BY v.id, v.placa, v.descricao ' +
    'ORDER BY v.placa';

  // Detalhe de um veiculo (usado em master-detail: o :id vem da query mestre)
  SQL_ITENS_MANUTENCAO =
    'SELECT m.id AS numero, m.data, i.codigo, i.descricao, mi.quantidade, ' +
    '  CAST(ROUND(mi.quantidade * mi.valor_unit_centavos) AS INTEGER) AS valor_c ' +
    'FROM movimento m ' +
    'JOIN movimento_item mi ON mi.id_movimento = m.id ' +
    'JOIN item i ON i.id = mi.id_item ' +
    'WHERE m.id_veiculo = :id AND m.operacao = ''MANUTENCAO'' ' +
    'ORDER BY m.data, m.id, mi.id';

  // Base do historico: os filtros opcionais (item, operacao) sao acrescentados em codigo
  SQL_HISTORICO_MOVIMENTOS =
    'SELECT m.id AS numero, m.data, m.operacao, i.codigo, i.descricao, ' +
    '       lo.nome AS origem, ld.nome AS destino, mi.quantidade, mi.valor_unit_centavos, ' +
    '       CAST(ROUND(mi.quantidade * mi.valor_unit_centavos) AS INTEGER) AS total_c, ' +
    '       u.login AS usuario, m.observacao ' +
    'FROM movimento m ' +
    'JOIN movimento_item mi ON mi.id_movimento = m.id ' +
    'JOIN item i ON i.id = mi.id_item ' +
    'LEFT JOIN local lo ON lo.id = mi.id_local_origem ' +
    'LEFT JOIN local ld ON ld.id = mi.id_local_destino ' +
    'JOIN usuario u ON u.id = m.id_usuario ' +
    'WHERE m.data BETWEEN :de AND :ate ';

  SQL_ESTOQUE_FISICO =
    'SELECT COALESCE(SUM(CAST(ROUND(s.quantidade * i.custo_medio_centavos) AS INTEGER)), 0) ' +
    'FROM saldo_estoque s JOIN item i ON i.id = s.id_item';

  SQL_ESTOQUE_CONTABIL =
    'SELECT COALESCE(SUM(CASE WHEN dc = ''D'' THEN valor_centavos ELSE -valor_centavos END), 0) ' +
    'FROM partida WHERE id_conta IN (SELECT DISTINCT id_conta FROM item WHERE tipo = ''P'')';

implementation

{ TTotaisBalancete }

function TTotaisBalancete.Fecha: Boolean;
begin
  Result := Devedor = Credor;
end;

{ TResumoPatrimonial }

function TResumoPatrimonial.Lucro: Currency;
begin
  Result := Receitas - Despesas;
end;

function TResumoPatrimonial.PLComResultado: Currency;
begin
  Result := PatrimonioLiquido + Lucro;
end;

function TResumoPatrimonial.Fecha: Boolean;
begin
  Result := Ativo = Passivo + PLComResultado;
end;

{ TConciliacaoEstoque }

function TConciliacaoEstoque.Diferenca: Currency;
begin
  Result := Fisico - Contabil;
end;

{ TConsultaService }

constructor TConsultaService.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
end;

procedure TConsultaService.AbrirRazonete(AQuery: TFDQuery; AIdConta: Integer; const ADC: string);
begin
  AQuery.Close;
  AQuery.Connection := FConexao;
  AQuery.SQL.Text := SQL_RAZONETE;
  AQuery.ParamByName('id_conta').AsInteger := AIdConta;
  AQuery.ParamByName('dc').AsString := ADC;
  AQuery.Open;
end;

procedure TConsultaService.AbrirBalancete(AQuery: TFDQuery);
begin
  AQuery.Close;
  AQuery.Connection := FConexao;
  AQuery.SQL.Text := SQL_BALANCETE;
  AQuery.Open;
end;

procedure TConsultaService.AbrirSaldoEstoque(AQuery: TFDQuery);
begin
  AQuery.Close;
  AQuery.Connection := FConexao;
  AQuery.SQL.Text := SQL_SALDO_ESTOQUE;
  AQuery.Open;
end;

procedure TConsultaService.AbrirDiario(AQuery: TFDQuery; ADe, AAte: TDate);
begin
  AQuery.Close;
  AQuery.Connection := FConexao;
  AQuery.SQL.Text := SQL_DIARIO;
  // As datas ficam gravadas como texto ISO (AAAA-MM-DD): comparar texto ISO = comparar datas
  AQuery.ParamByName('de').AsString := FormatDateTime('yyyy-mm-dd', ADe);
  AQuery.ParamByName('ate').AsString := FormatDateTime('yyyy-mm-dd', AAte);
  AQuery.Open;
end;

procedure TConsultaService.AbrirCustoPorVeiculo(AQuery: TFDQuery);
begin
  AQuery.Close;
  AQuery.Connection := FConexao;
  AQuery.SQL.Text := SQL_CUSTO_VEICULO;
  AQuery.Open;
end;

procedure TConsultaService.AbrirHistoricoMovimentos(AQuery: TFDQuery; ADe, AAte: TDate;
  AIdItem: Integer; const AOperacao: string);
var
  SQL: string;
begin
  // Monta o WHERE so com os filtros usados; os valores sempre vao por parametro
  SQL := SQL_HISTORICO_MOVIMENTOS;
  if AIdItem > 0 then
    SQL := SQL + 'AND mi.id_item = :id_item ';
  if AOperacao <> '' then
    SQL := SQL + 'AND m.operacao = :operacao ';
  SQL := SQL + 'ORDER BY m.data, m.id, mi.id';

  AQuery.Close;
  AQuery.Connection := FConexao;
  AQuery.SQL.Text := SQL;
  AQuery.ParamByName('de').AsString := FormatDateTime('yyyy-mm-dd', ADe);
  AQuery.ParamByName('ate').AsString := FormatDateTime('yyyy-mm-dd', AAte);
  if AIdItem > 0 then
    AQuery.ParamByName('id_item').AsInteger := AIdItem;
  if AOperacao <> '' then
    AQuery.ParamByName('operacao').AsString := AOperacao;
  AQuery.Open;
end;

function TConsultaService.TotaisBalancete: TTotaisBalancete;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.Open(SQL_TOTAIS_BALANCETE);
    Result.Devedor := Query.FieldByName('devedor_c').AsLargeInt / 100;
    Result.Credor := Query.FieldByName('credor_c').AsLargeInt / 100;
  finally
    Query.Free;
  end;
end;

function TConsultaService.Resumo: TResumoPatrimonial;
var
  Query: TFDQuery;
  Grupo: string;
  Liquido: Currency;
begin
  Result := Default(TResumoPatrimonial);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.Open(SQL_RESUMO);
    while not Query.Eof do
    begin
      Grupo := Query.FieldByName('grupo').AsString;
      Liquido := Query.FieldByName('liquido_c').AsLargeInt / 100;
      // Ativo e Despesa crescem no debito; Passivo, PL e Receita, no credito
      if Grupo = 'A' then
        Result.Ativo := Liquido
      else if Grupo = 'P' then
        Result.Passivo := -Liquido
      else if Grupo = 'PL' then
        Result.PatrimonioLiquido := -Liquido
      else if Grupo = 'R' then
        Result.Receitas := -Liquido
      else if Grupo = 'D' then
        Result.Despesas := Liquido;
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TConsultaService.ConciliacaoEstoque: TConciliacaoEstoque;
begin
  Result.Fisico := Int64(FConexao.ExecSQLScalar(SQL_ESTOQUE_FISICO)) / 100;
  Result.Contabil := Int64(FConexao.ExecSQLScalar(SQL_ESTOQUE_CONTABIL)) / 100;
end;

end.
