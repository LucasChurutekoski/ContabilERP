unit uMovimentoService;

{ Movimentos de estoque integrados a contabilidade.
  Cada operacao atualiza o estoque fisico e gera o lancamento contabil
  automaticamente, tudo na MESMA transacao:

  COMPRA         D conta do item (Estoques ou Despesa)  / C Bancos (a vista) ou Fornecedores (a prazo)
  CONSUMO        D conta de despesa escolhida            / C Estoques (pelo custo medio)
  TRANSFERENCIA  sem lancamento: o bem so muda de prateleira, o patrimonio nao muda
  SERVICO        D Bancos (a vista) ou Clientes (a prazo) / C Receita de Servicos
  MANUTENCAO     D Despesa de Manutencao (pecas + mao de obra)
                 / C Estoques (pecas, pelo custo medio)
                 / C Bancos ou Fornecedores (mao de obra)
                 tudo ligado a um veiculo (centro de custo) }

interface

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Stan.Param,
  FireDAC.Comp.Client, uSessao, uLancamentoService;

type
  EMovimentoInvalido = class(Exception);

  TOperacao = (opCompra, opConsumo, opTransferencia, opServico, opManutencao);

  TItemMovimento = record
    IdItem: Integer;
    IdLocalOrigem: Integer;   // saidas de estoque (0 = nao se aplica)
    IdLocalDestino: Integer;  // compra de produto e transferencia
    Quantidade: Double;
    ValorUnitario: Currency;  // compra e servicos; nas saidas de estoque vale o custo medio
  end;

  TMovimento = record
    Data: TDate;
    Operacao: TOperacao;
    IdEntidade: Integer;      // fornecedor (compra, mao de obra da manutencao) ou cliente (servico)
    AVista: Boolean;          // compra, servico e mao de obra da manutencao
    IdContaDestino: Integer;  // consumo e manutencao: conta de despesa
    IdVeiculo: Integer;       // manutencao
    Observacao: string;
    Itens: TArray<TItemMovimento>;
  end;

  TMovimentoService = class
  private type
    TDadosItem = record
      Descricao: string;
      Tipo: string;           // 'P' produto, 'S' servico
      Grupo: string;          // grupo da conta do item
      IdConta: Integer;
      CustoMedioCentavos: Int64;
    end;
  private
    FConexao: TFDConnection;
    FSessao: TSessao;
    FLancamentos: TLancamentoService;
    procedure ValidarCabecalho(const AMov: TMovimento);
    procedure ValidarEntidade(AIdEntidade: Integer; const ACampoFlag, AMensagem: string);
    procedure ValidarLocal(AIdLocal: Integer; const AQual: string);
    function CarregarItem(AIdItem: Integer): TDadosItem;
    function SaldoNoLocal(AIdItem, AIdLocal: Integer): Double;
    function SaldoTotal(AIdItem: Integer): Double;
    procedure SomarSaldo(AIdItem, AIdLocal: Integer; ADelta: Double);
    function GravarCabecalho(const AMov: TMovimento): Integer;
    procedure GravarItem(AIdMovimento: Integer; const AItem: TItemMovimento; AValorUnitario: Currency);
    function Historico(const AMov: TMovimento; AIdMovimento: Integer): string;
  public
    constructor Create(AConexao: TFDConnection; ASessao: TSessao);
    destructor Destroy; override;

    // Grava o movimento e devolve o numero (id) gerado
    function Registrar(const AMov: TMovimento): Integer;

    class function NomeOperacao(AOperacao: TOperacao): string;
    class function CodigoOperacao(AOperacao: TOperacao): string;
    class function PermissaoOperacao(AOperacao: TOperacao): string;
  end;

implementation

uses
  System.Variants, uContasPadrao;

function Vazio(const AValor: Variant): Boolean;
begin
  Result := VarIsNull(AValor) or VarIsEmpty(AValor);
end;

function NuloSeZero(AValor: Integer): Variant;
begin
  if AValor > 0 then
    Result := AValor
  else
    Result := Null;
end;

function Arredondar(const AValor: Extended): Currency;
begin
  Result := Round(AValor * 100) / 100;
end;

{ TMovimentoService }

constructor TMovimentoService.Create(AConexao: TFDConnection; ASessao: TSessao);
begin
  inherited Create;
  FConexao := AConexao;
  FSessao := ASessao;
  FLancamentos := TLancamentoService.Create(AConexao);
end;

destructor TMovimentoService.Destroy;
begin
  FLancamentos.Free;
  inherited;
end;

class function TMovimentoService.NomeOperacao(AOperacao: TOperacao): string;
begin
  case AOperacao of
    opCompra:        Result := 'Compra';
    opConsumo:       Result := 'Consumo';
    opTransferencia: Result := 'Transferência entre locais';
    opServico:       Result := 'Prestação de serviço';
  else
    Result := 'Manutenção de veículo';
  end;
end;

class function TMovimentoService.CodigoOperacao(AOperacao: TOperacao): string;
begin
  case AOperacao of
    opCompra:        Result := 'COMPRA';
    opConsumo:       Result := 'CONSUMO';
    opTransferencia: Result := 'TRANSFERENCIA';
    opServico:       Result := 'SERVICO';
  else
    Result := 'MANUTENCAO';
  end;
end;

class function TMovimentoService.PermissaoOperacao(AOperacao: TOperacao): string;
begin
  // Uma permissao por operacao: o admin pode liberar so "Compra" para um usuario
  Result := 'MOV_' + CodigoOperacao(AOperacao);
end;

procedure TMovimentoService.ValidarEntidade(AIdEntidade: Integer; const ACampoFlag, AMensagem: string);
var
  Flag: Variant;
begin
  // ACampoFlag e uma constante deste arquivo ('eh_cliente' ou 'eh_fornecedor')
  Flag := FConexao.ExecSQLScalar('SELECT ' + ACampoFlag + ' FROM entidade WHERE id = :id', [AIdEntidade]);
  if Vazio(Flag) or (Flag <> 1) then
    raise EMovimentoInvalido.Create(AMensagem);
end;

procedure TMovimentoService.ValidarCabecalho(const AMov: TMovimento);
begin
  if Length(AMov.Itens) = 0 then
    raise EMovimentoInvalido.Create('Inclua pelo menos um item.');

  case AMov.Operacao of
    opCompra:
      ValidarEntidade(AMov.IdEntidade, 'eh_fornecedor', 'Escolha o fornecedor da compra.');
    opServico:
      ValidarEntidade(AMov.IdEntidade, 'eh_cliente', 'Escolha o cliente do serviço.');
  end;

  if AMov.Operacao in [opConsumo, opManutencao] then
    if FConexao.ExecSQLScalar(
         'SELECT COUNT(*) FROM conta WHERE id = :id AND tipo = ''A'' AND grupo = ''D''',
         [AMov.IdContaDestino]) = 0 then
      raise EMovimentoInvalido.Create('Escolha a conta de despesa (ex.: Despesa de Manutenção).');

  if AMov.Operacao = opManutencao then
    if FConexao.ExecSQLScalar('SELECT COUNT(*) FROM veiculo WHERE id = :id AND ativo = 1',
         [AMov.IdVeiculo]) = 0 then
      raise EMovimentoInvalido.Create('Escolha o veículo que recebeu a manutenção.');
end;

procedure TMovimentoService.ValidarLocal(AIdLocal: Integer; const AQual: string);
var
  Aceita: Variant;
begin
  if AIdLocal <= 0 then
    raise EMovimentoInvalido.CreateFmt('Escolha o local de %s.', [AQual]);
  Aceita := FConexao.ExecSQLScalar('SELECT aceita_estoque FROM local WHERE id = :id', [AIdLocal]);
  if Vazio(Aceita) then
    raise EMovimentoInvalido.CreateFmt('O local de %s não existe.', [AQual]);
  if Aceita <> 1 then
    raise EMovimentoInvalido.CreateFmt(
      'O local de %s é um agrupador: escolha um local final (ex.: uma prateleira).', [AQual]);
end;

function TMovimentoService.CarregarItem(AIdItem: Integer): TDadosItem;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text :=
      'SELECT i.descricao, i.tipo, i.id_conta, i.custo_medio_centavos, c.grupo ' +
      'FROM item i JOIN conta c ON c.id = i.id_conta WHERE i.id = :id';
    Query.ParamByName('id').AsInteger := AIdItem;
    Query.Open;
    if Query.IsEmpty then
      raise EMovimentoInvalido.CreateFmt('Item %d não encontrado.', [AIdItem]);
    Result.Descricao := Query.FieldByName('descricao').AsString;
    Result.Tipo := Query.FieldByName('tipo').AsString;
    Result.Grupo := Query.FieldByName('grupo').AsString;
    Result.IdConta := Query.FieldByName('id_conta').AsInteger;
    Result.CustoMedioCentavos := Query.FieldByName('custo_medio_centavos').AsLargeInt;
  finally
    Query.Free;
  end;
end;

function TMovimentoService.SaldoNoLocal(AIdItem, AIdLocal: Integer): Double;
begin
  Result := FConexao.ExecSQLScalar(
    'SELECT COALESCE(SUM(quantidade), 0) FROM saldo_estoque WHERE id_item = :id_item AND id_local = :id_local',
    [AIdItem, AIdLocal]);
end;

function TMovimentoService.SaldoTotal(AIdItem: Integer): Double;
begin
  Result := FConexao.ExecSQLScalar(
    'SELECT COALESCE(SUM(quantidade), 0) FROM saldo_estoque WHERE id_item = :id_item', [AIdItem]);
end;

procedure TMovimentoService.SomarSaldo(AIdItem, AIdLocal: Integer; ADelta: Double);
begin
  // Atualiza a linha item+local; se ainda nao existe, cria.
  // ROUND evita residuos de ponto flutuante (ex.: 0,30000000004)
  if FConexao.ExecSQL(
       'UPDATE saldo_estoque SET quantidade = ROUND(quantidade + :delta, 4) ' +
       'WHERE id_item = :id_item AND id_local = :id_local',
       [ADelta, AIdItem, AIdLocal]) = 0 then
    FConexao.ExecSQL(
      'INSERT INTO saldo_estoque (id_item, id_local, quantidade) VALUES (:id_item, :id_local, :quantidade)',
      [AIdItem, AIdLocal, ADelta]);
end;

function TMovimentoService.GravarCabecalho(const AMov: TMovimento): Integer;
var
  Pagamento: Variant;
begin
  if AMov.Operacao in [opCompra, opServico, opManutencao] then
  begin
    if AMov.AVista then
      Pagamento := 'VISTA'
    else
      Pagamento := 'PRAZO';
  end
  else
    Pagamento := Null;

  FConexao.ExecSQL(
    'INSERT INTO movimento (data, operacao, id_entidade, pagamento, id_conta_destino, id_veiculo, observacao, id_usuario) ' +
    'VALUES (:data, :operacao, :id_entidade, :pagamento, :id_conta_destino, :id_veiculo, :observacao, :id_usuario)',
    [FormatDateTime('yyyy-mm-dd', AMov.Data), CodigoOperacao(AMov.Operacao),
     NuloSeZero(AMov.IdEntidade), Pagamento, NuloSeZero(AMov.IdContaDestino),
     NuloSeZero(AMov.IdVeiculo), AMov.Observacao, FSessao.IdUsuario],
    [ftString, ftString, ftInteger, ftString, ftInteger, ftInteger, ftString, ftInteger]);
  Result := FConexao.ExecSQLScalar('SELECT last_insert_rowid()');
end;

procedure TMovimentoService.GravarItem(AIdMovimento: Integer; const AItem: TItemMovimento;
  AValorUnitario: Currency);
begin
  FConexao.ExecSQL(
    'INSERT INTO movimento_item (id_movimento, id_item, id_local_origem, id_local_destino, quantidade, valor_unit_centavos) ' +
    'VALUES (:id_movimento, :id_item, :id_local_origem, :id_local_destino, :quantidade, :valor_unit_centavos)',
    [AIdMovimento, AItem.IdItem, NuloSeZero(AItem.IdLocalOrigem), NuloSeZero(AItem.IdLocalDestino),
     AItem.Quantidade, Round(AValorUnitario * 100)],
    [ftInteger, ftInteger, ftInteger, ftInteger, ftFloat, ftLargeint]);
end;

function TMovimentoService.Historico(const AMov: TMovimento; AIdMovimento: Integer): string;
var
  Nome: Variant;
begin
  Result := Format('%s nº %d', [NomeOperacao(AMov.Operacao), AIdMovimento]);
  if AMov.IdVeiculo > 0 then
  begin
    Nome := FConexao.ExecSQLScalar('SELECT placa || '' '' || descricao FROM veiculo WHERE id = :id', [AMov.IdVeiculo]);
    if not Vazio(Nome) then
      Result := Result + ' - ' + VarToStr(Nome);
  end;
  if AMov.IdEntidade > 0 then
  begin
    Nome := FConexao.ExecSQLScalar('SELECT nome FROM entidade WHERE id = :id', [AMov.IdEntidade]);
    if not Vazio(Nome) then
      Result := Result + ' - ' + VarToStr(Nome);
  end;
  if Trim(AMov.Observacao) <> '' then
    Result := Result + ' (' + Trim(AMov.Observacao) + ')';
  Result := Copy(Result, 1, 200);
end;

function TMovimentoService.Registrar(const AMov: TMovimento): Integer;
var
  Item: TItemMovimento;
  Dados: TDadosItem;
  Partidas: TList<TPartida>;
  ValorUnitario, ValorLinha, Total, TotalMaoDeObra: Currency;
  SaldoAntes, Disponivel: Double;
  NovoCusto: Int64;
  TransacaoPropria, FornecedorValidado: Boolean;
begin
  // Seguranca de verdade fica aqui, nao so no menu
  FSessao.Exigir(PermissaoOperacao(AMov.Operacao));
  ValidarCabecalho(AMov);

  Partidas := TList<TPartida>.Create;
  try
    // Mesmo padrao do TLancamentoService: participa de uma transacao ja aberta
    TransacaoPropria := not FConexao.InTransaction;
    if TransacaoPropria then
      FConexao.StartTransaction;
    try
      Result := GravarCabecalho(AMov);
      Total := 0;
      TotalMaoDeObra := 0;
      FornecedorValidado := False;

      for Item in AMov.Itens do
      begin
        if Item.Quantidade <= 0 then
          raise EMovimentoInvalido.Create('A quantidade deve ser maior que zero.');

        // Le o item a cada linha: uma linha anterior pode ter mudado o custo medio
        Dados := CarregarItem(Item.IdItem);
        ValorLinha := 0;

        case AMov.Operacao of
          opCompra:
            begin
              if Item.ValorUnitario <= 0 then
                raise EMovimentoInvalido.CreateFmt('Informe o valor unitário de "%s".', [Dados.Descricao]);
              if Dados.Tipo = 'P' then
              begin
                ValidarLocal(Item.IdLocalDestino, 'destino');
                // Custo medio ponderado: (valor em estoque + valor da entrada) / quantidade total
                SaldoAntes := SaldoTotal(Item.IdItem);
                NovoCusto := Round(
                  (SaldoAntes * Dados.CustoMedioCentavos + Item.Quantidade * Item.ValorUnitario * 100) /
                  (SaldoAntes + Item.Quantidade));
                FConexao.ExecSQL('UPDATE item SET custo_medio_centavos = :custo WHERE id = :id',
                  [NovoCusto, Item.IdItem]);
                SomarSaldo(Item.IdItem, Item.IdLocalDestino, Item.Quantidade);
              end
              else if Dados.Grupo <> 'D' then
                raise EMovimentoInvalido.CreateFmt(
                  '"%s" é um serviço prestado (receita): use a operação Prestação de serviço.', [Dados.Descricao]);
              ValorUnitario := Item.ValorUnitario;
              ValorLinha := Arredondar(Item.Quantidade * Item.ValorUnitario);
              Partidas.Add(TPartida.Debito(Dados.IdConta, ValorLinha));
            end;

          opServico:
            begin
              if (Dados.Tipo <> 'S') or (Dados.Grupo <> 'R') then
                raise EMovimentoInvalido.CreateFmt(
                  '"%s" não é um serviço prestado (precisa de conta de Receita).', [Dados.Descricao]);
              if Item.ValorUnitario <= 0 then
                raise EMovimentoInvalido.CreateFmt('Informe o preço unitário de "%s".', [Dados.Descricao]);
              ValorUnitario := Item.ValorUnitario;
              ValorLinha := Arredondar(Item.Quantidade * Item.ValorUnitario);
              Partidas.Add(TPartida.Credito(Dados.IdConta, ValorLinha));
            end;

        else // opConsumo, opTransferencia, opManutencao
          if (AMov.Operacao = opManutencao) and (Dados.Tipo = 'S') then
          begin
            // Mao de obra da manutencao: servico tomado, pago ao fornecedor
            if Dados.Grupo <> 'D' then
              raise EMovimentoInvalido.CreateFmt(
                '"%s" não é mão de obra (serviço tomado com conta de despesa).', [Dados.Descricao]);
            if Item.ValorUnitario <= 0 then
              raise EMovimentoInvalido.CreateFmt('Informe o valor da mão de obra "%s".', [Dados.Descricao]);
            if not FornecedorValidado then
            begin
              ValidarEntidade(AMov.IdEntidade, 'eh_fornecedor',
                'A manutenção tem mão de obra: escolha o fornecedor que prestou o serviço.');
              FornecedorValidado := True;
            end;
            ValorUnitario := Item.ValorUnitario;
            ValorLinha := Arredondar(Item.Quantidade * Item.ValorUnitario);
            TotalMaoDeObra := TotalMaoDeObra + ValorLinha;
          end
          else
          begin
            // Saida de estoque (peca da manutencao, consumo ou transferencia)
            if Dados.Tipo <> 'P' then
              raise EMovimentoInvalido.CreateFmt('"%s" é um serviço: não tem estoque.', [Dados.Descricao]);
            ValidarLocal(Item.IdLocalOrigem, 'origem');
            Disponivel := SaldoNoLocal(Item.IdItem, Item.IdLocalOrigem);
            if Disponivel + 0.00001 < Item.Quantidade then
              raise EMovimentoInvalido.CreateFmt(
                'Saldo insuficiente de "%s" no local de origem: disponível %s, solicitado %s.',
                [Dados.Descricao, FormatFloat('#,##0.###', Disponivel), FormatFloat('#,##0.###', Item.Quantidade)]);

            // Saida sempre pelo custo medio vigente
            ValorUnitario := Dados.CustoMedioCentavos / 100;
            SomarSaldo(Item.IdItem, Item.IdLocalOrigem, -Item.Quantidade);

            if AMov.Operacao = opTransferencia then
            begin
              ValidarLocal(Item.IdLocalDestino, 'destino');
              if Item.IdLocalDestino = Item.IdLocalOrigem then
                raise EMovimentoInvalido.Create('Origem e destino da transferência são o mesmo local.');
              SomarSaldo(Item.IdItem, Item.IdLocalDestino, Item.Quantidade);
            end
            else
            begin
              ValorLinha := Arredondar(Item.Quantidade * ValorUnitario);
              Partidas.Add(TPartida.Credito(Dados.IdConta, ValorLinha));
            end;
          end;
        end;

        GravarItem(Result, Item, ValorUnitario);
        Total := Total + ValorLinha;
      end;

      // Contrapartida com o total do movimento
      case AMov.Operacao of
        opCompra:
          if AMov.AVista then
            Partidas.Add(TPartida.Credito(FLancamentos.IdConta(CONTA_BANCOS), Total))
          else
            Partidas.Add(TPartida.Credito(FLancamentos.IdConta(CONTA_FORNECEDORES), Total));
        opServico:
          if AMov.AVista then
            Partidas.Insert(0, TPartida.Debito(FLancamentos.IdConta(CONTA_BANCOS), Total))
          else
            Partidas.Insert(0, TPartida.Debito(FLancamentos.IdConta(CONTA_CLIENTES), Total));
        opConsumo:
          Partidas.Insert(0, TPartida.Debito(AMov.IdContaDestino, Total));
        opManutencao:
          begin
            // Despesa = pecas + mao de obra; a mao de obra e devida ao fornecedor
            Partidas.Insert(0, TPartida.Debito(AMov.IdContaDestino, Total));
            if TotalMaoDeObra > 0 then
              if AMov.AVista then
                Partidas.Add(TPartida.Credito(FLancamentos.IdConta(CONTA_BANCOS), TotalMaoDeObra))
              else
                Partidas.Add(TPartida.Credito(FLancamentos.IdConta(CONTA_FORNECEDORES), TotalMaoDeObra));
          end;
      end;

      // Transferencia nao gera lancamento. As demais participam desta transacao.
      if AMov.Operacao <> opTransferencia then
        FLancamentos.Registrar(AMov.Data, Historico(AMov, Result), Partidas.ToArray,
          FSessao.IdUsuario, Result);

      if TransacaoPropria then
        FConexao.Commit;
    except
      if TransacaoPropria then
        FConexao.Rollback; // estoque, custo medio e lancamento voltam juntos
      raise;
    end;
  finally
    Partidas.Free;
  end;
end;

end.
