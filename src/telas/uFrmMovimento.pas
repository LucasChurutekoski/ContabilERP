unit uFrmMovimento;

{ Uma tela para as cinco operacoes de estoque (compra, consumo, transferencia,
  prestacao de servico e manutencao de veiculo). Os campos visiveis mudam
  conforme a operacao; a regra de negocio inteira esta no TMovimentoService. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uMovimentoService;

type
  TFrmMovimento = class(TForm)
    PnlCabecalho: TPanel;
    LblData: TLabel;
    DtpData: TDateTimePicker;
    LblEntidade: TLabel;
    CbEntidade: TDBLookupComboBox;
    RgPagamento: TRadioGroup;
    LblObservacao: TLabel;
    EdtObservacao: TEdit;
    LblVeiculo: TLabel;
    CbVeiculo: TDBLookupComboBox;
    LblContaDestino: TLabel;
    CbContaDestino: TDBLookupComboBox;
    PnlItem: TPanel;
    LblItem: TLabel;
    CbItem: TDBLookupComboBox;
    LblOrigem: TLabel;
    CbOrigem: TDBLookupComboBox;
    LblDestino: TLabel;
    CbDestino: TDBLookupComboBox;
    LblQuantidade: TLabel;
    EdtQuantidade: TEdit;
    LblValor: TLabel;
    EdtValor: TEdit;
    BtnAdicionar: TButton;
    LblDisponivel: TLabel;
    Grade: TDBGrid;
    PnlRodape: TPanel;
    BtnRemover: TButton;
    LblTotal: TLabel;
    BtnGravar: TButton;
    BtnFechar: TButton;
    QryEntidades: TFDQuery;
    DsEntidades: TDataSource;
    QryItens: TFDQuery;
    DsItens: TDataSource;
    QryLocais: TFDQuery;
    DsLocais: TDataSource;
    QryOrigens: TFDQuery;
    DsOrigens: TDataSource;
    QryDespesas: TFDQuery;
    DsDespesas: TDataSource;
    QryVeiculos: TFDQuery;
    DsVeiculos: TDataSource;
    MemItens: TFDMemTable;
    DsMemItens: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnAdicionarClick(Sender: TObject);
    procedure BtnRemoverClick(Sender: TObject);
    procedure BtnGravarClick(Sender: TObject);
    procedure CbItemClick(Sender: TObject);
    procedure CbOrigemClick(Sender: TObject);
  private
    FOperacao: TOperacao;
    procedure ConfigurarConsultas;
    procedure ConfigurarTela;
    procedure CriarTabelaItens;
    procedure CarregarOrigens;
    procedure AtualizarTotal;
    procedure AtualizarDisponivel;
    procedure LimparItens;
    function Itens: TArray<TItemMovimento>;
    function ItemSelecionadoEhProduto: Boolean;
    function UsaOrigem: Boolean;
    function UsaDestino: Boolean;
    function UsaValor: Boolean;
  public
    constructor CriarPara(AOperacao: TOperacao);
    class procedure Executar(AOperacao: TOperacao);
  end;

var
  FrmMovimento: TFrmMovimento;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil, uLancamentoService;

const
  SQL_ITENS = 'SELECT i.id, i.codigo, i.descricao, i.tipo, i.custo_medio_centavos ' +
              'FROM item i JOIN conta c ON c.id = i.id_conta ';

  // Atribuido em codigo: ao receber o SQL.Text, o FireDAC cria o parametro :id_item
  SQL_ORIGENS = 'SELECT l.id, l.codigo, l.nome, s.quantidade ' +
                'FROM saldo_estoque s JOIN local l ON l.id = s.id_local ' +
                'WHERE s.id_item = :id_item AND s.quantidade > 0 ' +
                'ORDER BY l.codigo';

function Chave(ACombo: TDBLookupComboBox): Integer;
begin
  if VarIsNull(ACombo.KeyValue) or VarIsEmpty(ACombo.KeyValue) then
    Result := 0
  else
    Result := ACombo.KeyValue;
end;

constructor TFrmMovimento.CriarPara(AOperacao: TOperacao);
begin
  // O campo e preenchido antes do inherited: o OnCreate ja encontra a operacao
  FOperacao := AOperacao;
  inherited Create(nil);
end;

class procedure TFrmMovimento.Executar(AOperacao: TOperacao);
var
  Form: TFrmMovimento;
begin
  Sessao.Exigir(TMovimentoService.PermissaoOperacao(AOperacao));
  Form := TFrmMovimento.CriarPara(AOperacao);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

function TFrmMovimento.UsaOrigem: Boolean;
begin
  Result := FOperacao in [opConsumo, opTransferencia, opManutencao];
end;

function TFrmMovimento.UsaDestino: Boolean;
begin
  Result := FOperacao in [opCompra, opTransferencia];
end;

function TFrmMovimento.UsaValor: Boolean;
begin
  Result := FOperacao in [opCompra, opServico, opManutencao];
end;

function TFrmMovimento.ItemSelecionadoEhProduto: Boolean;
begin
  Result := (Chave(CbItem) > 0) and (VarToStr(QryItens.Lookup('id', Chave(CbItem), 'tipo')) = 'P');
end;

procedure TFrmMovimento.FormCreate(Sender: TObject);
begin
  Caption := TMovimentoService.NomeOperacao(FOperacao);
  ConfigurarConsultas;
  CriarTabelaItens;
  ConfigurarTela;
  DtpData.Date := Date;
  RgPagamento.ItemIndex := 0;
  LimparItens;
end;

procedure TFrmMovimento.ConfigurarConsultas;
begin
  case FOperacao of
    opCompra, opManutencao:
      begin
        QryEntidades.SQL.Text := 'SELECT id, nome FROM entidade WHERE eh_fornecedor = 1 ORDER BY nome';
        // Produtos e servicos tomados (mao de obra)
        QryItens.SQL.Text := SQL_ITENS + 'WHERE i.tipo = ''P'' OR c.grupo = ''D'' ORDER BY i.codigo';
      end;
    opServico:
      begin
        QryEntidades.SQL.Text := 'SELECT id, nome FROM entidade WHERE eh_cliente = 1 ORDER BY nome';
        QryItens.SQL.Text := SQL_ITENS + 'WHERE i.tipo = ''S'' AND c.grupo = ''R'' ORDER BY i.codigo';
      end;
  else
    QryItens.SQL.Text := SQL_ITENS + 'WHERE i.tipo = ''P'' ORDER BY i.codigo';
  end;

  QryItens.Connection := DM.Conexao;
  QryItens.Open;
  QryLocais.Connection := DM.Conexao;
  QryLocais.Open;
  QryDespesas.Connection := DM.Conexao;
  QryDespesas.Open;
  QryOrigens.Connection := DM.Conexao;
  QryOrigens.SQL.Text := SQL_ORIGENS;
  if FOperacao in [opCompra, opServico, opManutencao] then
  begin
    QryEntidades.Connection := DM.Conexao;
    QryEntidades.Open;
  end;
  if FOperacao = opManutencao then
  begin
    QryVeiculos.Connection := DM.Conexao;
    QryVeiculos.Open;
  end;
end;

procedure TFrmMovimento.CriarTabelaItens;
begin
  MemItens.FieldDefs.Add('id_item', ftInteger);
  MemItens.FieldDefs.Add('item', ftString, 130);
  MemItens.FieldDefs.Add('id_origem', ftInteger);
  MemItens.FieldDefs.Add('origem', ftString, 100);
  MemItens.FieldDefs.Add('id_destino', ftInteger);
  MemItens.FieldDefs.Add('destino', ftString, 100);
  MemItens.FieldDefs.Add('quantidade', ftFloat);
  MemItens.FieldDefs.Add('valor_unit', ftCurrency);
  MemItens.FieldDefs.Add('total', ftCurrency);
  MemItens.CreateDataSet;

  MemItens.FieldByName('id_item').Visible := False;
  MemItens.FieldByName('id_origem').Visible := False;
  MemItens.FieldByName('id_destino').Visible := False;
  MemItens.FieldByName('item').DisplayLabel := 'Item';
  MemItens.FieldByName('item').DisplayWidth := 40;
  MemItens.FieldByName('origem').DisplayLabel := 'Origem';
  MemItens.FieldByName('origem').DisplayWidth := 18;
  MemItens.FieldByName('origem').Visible := UsaOrigem;
  MemItens.FieldByName('destino').DisplayLabel := 'Destino';
  MemItens.FieldByName('destino').DisplayWidth := 18;
  MemItens.FieldByName('destino').Visible := UsaDestino;
  MemItens.FieldByName('quantidade').DisplayLabel := 'Quantidade';
  (MemItens.FieldByName('quantidade') as TFloatField).DisplayFormat := '#,##0.###';
  MemItens.FieldByName('valor_unit').DisplayLabel := 'Valor unit.';
  (MemItens.FieldByName('valor_unit') as TCurrencyField).currency := False;
  (MemItens.FieldByName('valor_unit') as TCurrencyField).DisplayFormat := '#,##0.00';
  MemItens.FieldByName('total').DisplayLabel := 'Total';
  (MemItens.FieldByName('total') as TCurrencyField).currency := False;
  (MemItens.FieldByName('total') as TCurrencyField).DisplayFormat := '#,##0.00';
  // Na transferencia nao ha valor (o patrimonio nao muda)
  MemItens.FieldByName('valor_unit').Visible := FOperacao <> opTransferencia;
  MemItens.FieldByName('total').Visible := FOperacao <> opTransferencia;
end;

procedure TFrmMovimento.ConfigurarTela;
var
  ComEntidade: Boolean;
begin
  ComEntidade := FOperacao in [opCompra, opServico, opManutencao];
  LblEntidade.Visible := ComEntidade;
  CbEntidade.Visible := ComEntidade;
  RgPagamento.Visible := ComEntidade;
  case FOperacao of
    opServico:    LblEntidade.Caption := 'Cliente';
    opManutencao: LblEntidade.Caption := 'Fornecedor da mão de obra (se houver)';
  else
    LblEntidade.Caption := 'Fornecedor';
  end;

  LblVeiculo.Visible := FOperacao = opManutencao;
  CbVeiculo.Visible := FOperacao = opManutencao;
  LblContaDestino.Visible := FOperacao in [opConsumo, opManutencao];
  CbContaDestino.Visible := FOperacao in [opConsumo, opManutencao];
  if FOperacao = opManutencao then
    CbContaDestino.KeyValue := QryDespesas.Lookup('codigo', '5.2.02', 'id'); // Despesa de Manutencao

  // So a manutencao usa a segunda linha do cabecalho (veiculo + conta).
  // No consumo, a conta sobe para o espaco do fornecedor, que ele nao usa.
  if FOperacao <> opManutencao then
    PnlCabecalho.Height := 64;
  if FOperacao = opConsumo then
  begin
    LblContaDestino.Left := LblEntidade.Left;
    LblContaDestino.Top := LblEntidade.Top;
    CbContaDestino.Left := CbEntidade.Left;
    CbContaDestino.Top := CbEntidade.Top;
    CbContaDestino.Width := EdtObservacao.Left - CbEntidade.Left - 16;
  end;

  LblOrigem.Visible := UsaOrigem;
  CbOrigem.Visible := UsaOrigem;
  LblDisponivel.Visible := UsaOrigem;
  LblDestino.Visible := UsaDestino;
  CbDestino.Visible := UsaDestino;

  LblValor.Visible := UsaValor;
  EdtValor.Visible := UsaValor;
  case FOperacao of
    opServico:    LblValor.Caption := 'Preço unit.';
    opManutencao: LblValor.Caption := 'Valor (só mão de obra)';
  else
    LblValor.Caption := 'Valor unit.';
  end;
  LblTotal.Visible := FOperacao <> opTransferencia;
end;

procedure TFrmMovimento.CarregarOrigens;
begin
  // So as prateleiras que tem o item escolhido, com a quantidade disponivel
  QryOrigens.Close;
  if not UsaOrigem or not ItemSelecionadoEhProduto then
    Exit;
  QryOrigens.ParamByName('id_item').AsInteger := Chave(CbItem);
  QryOrigens.Open;
  QryOrigens.FieldByName('quantidade').DisplayLabel := 'Disponível';
  (QryOrigens.FieldByName('quantidade') as TNumericField).DisplayFormat := '#,##0.###';
  if QryOrigens.RecordCount = 1 then
    CbOrigem.KeyValue := QryOrigens.FieldByName('id').Value; // so ha uma: ja escolhe
end;

procedure TFrmMovimento.AtualizarDisponivel;
var
  Saldo: Double;
begin
  if not UsaOrigem then
    Exit;
  if Chave(CbItem) = 0 then
    LblDisponivel.Caption := 'Escolha o item: a lista de origem mostra só as prateleiras que o têm'
  else if not ItemSelecionadoEhProduto then
    LblDisponivel.Caption := 'Mão de obra: não sai do estoque, informe o valor'
  else if QryOrigens.Active and QryOrigens.IsEmpty then
    LblDisponivel.Caption := 'Este item não tem saldo em nenhuma prateleira'
  else if Chave(CbOrigem) = 0 then
    LblDisponivel.Caption := 'Escolha a origem'
  else
  begin
    Saldo := DM.Conexao.ExecSQLScalar(
      'SELECT COALESCE(SUM(quantidade), 0) FROM saldo_estoque WHERE id_item = :id_item AND id_local = :id_local',
      [Chave(CbItem), Chave(CbOrigem)]);
    LblDisponivel.Caption := Format('Disponível em %s: %s',
      [VarToStr(QryLocais.Lookup('id', Chave(CbOrigem), 'nome')), FormatFloat('#,##0.###', Saldo)]);
  end;
end;

procedure TFrmMovimento.CbItemClick(Sender: TObject);
begin
  CbOrigem.KeyValue := Null;
  CarregarOrigens;
  AtualizarDisponivel;
end;

procedure TFrmMovimento.CbOrigemClick(Sender: TObject);
begin
  AtualizarDisponivel;
end;

function TFrmMovimento.Itens: TArray<TItemMovimento>;
var
  Lista: TArray<TItemMovimento>;
  Item: TItemMovimento;
begin
  Lista := [];
  MemItens.DisableControls;
  try
    MemItens.First;
    while not MemItens.Eof do
    begin
      Item.IdItem := MemItens.FieldByName('id_item').AsInteger;
      Item.IdLocalOrigem := MemItens.FieldByName('id_origem').AsInteger;
      Item.IdLocalDestino := MemItens.FieldByName('id_destino').AsInteger;
      Item.Quantidade := MemItens.FieldByName('quantidade').AsFloat;
      Item.ValorUnitario := MemItens.FieldByName('valor_unit').AsCurrency;
      Lista := Lista + [Item];
      MemItens.Next;
    end;
  finally
    MemItens.EnableControls;
  end;
  Result := Lista;
end;

procedure TFrmMovimento.AtualizarTotal;
var
  Total: Currency;
begin
  Total := 0;
  MemItens.DisableControls;
  try
    MemItens.First;
    while not MemItens.Eof do
    begin
      Total := Total + MemItens.FieldByName('total').AsCurrency;
      MemItens.Next;
    end;
  finally
    MemItens.EnableControls;
  end;

  case FOperacao of
    opCompra, opServico: LblTotal.Caption := 'Total: ' + FormatarMoeda(Total);
    opConsumo, opManutencao:
      LblTotal.Caption := 'Total estimado: ' + FormatarMoeda(Total) + '  (peças pelo custo médio atual)';
  else
    LblTotal.Caption := '';
  end;
  BtnGravar.Enabled := not MemItens.IsEmpty;
  BtnRemover.Enabled := not MemItens.IsEmpty;
end;

procedure TFrmMovimento.BtnAdicionarClick(Sender: TObject);
var
  IdItem, IdOrigem, IdDestino: Integer;
  Quantidade: Double;
  ValorUnitario: Currency;
  Produto: Boolean;
begin
  IdItem := Chave(CbItem);
  if IdItem = 0 then
    raise Exception.Create('Escolha o item.');
  if not LerQuantidade(EdtQuantidade.Text, Quantidade) or (Quantidade <= 0) then
    raise Exception.Create('Informe uma quantidade maior que zero.');
  Produto := ItemSelecionadoEhProduto;

  IdOrigem := 0;
  if UsaOrigem and Produto then
  begin
    IdOrigem := Chave(CbOrigem);
    if IdOrigem = 0 then
      raise Exception.Create('Escolha o local de origem.');
  end;

  IdDestino := 0;
  if UsaDestino and Produto then
  begin
    IdDestino := Chave(CbDestino);
    if IdDestino = 0 then
      raise Exception.Create('Escolha o local de destino.');
  end;

  // Peca que sai do estoque vale o custo medio atual (o servico recalcula ao gravar);
  // compra, servico prestado e mao de obra pedem o valor digitado
  if UsaOrigem and Produto then
    ValorUnitario := QryItens.Lookup('id', IdItem, 'custo_medio_centavos') / 100
  else if UsaValor then
  begin
    if not LerValor(EdtValor.Text, ValorUnitario) or (ValorUnitario <= 0) then
      raise Exception.Create('Informe o valor unitário (ex.: 560,00).');
  end
  else
    ValorUnitario := 0;

  MemItens.Append;
  MemItens.FieldByName('id_item').AsInteger := IdItem;
  MemItens.FieldByName('item').AsString := VarToStr(QryItens.Lookup('id', IdItem, 'codigo')) + ' - ' +
    VarToStr(QryItens.Lookup('id', IdItem, 'descricao'));
  MemItens.FieldByName('id_origem').AsInteger := IdOrigem;
  if IdOrigem > 0 then
    MemItens.FieldByName('origem').AsString := VarToStr(QryLocais.Lookup('id', IdOrigem, 'nome'));
  MemItens.FieldByName('id_destino').AsInteger := IdDestino;
  if IdDestino > 0 then
    MemItens.FieldByName('destino').AsString := VarToStr(QryLocais.Lookup('id', IdDestino, 'nome'));
  MemItens.FieldByName('quantidade').AsFloat := Quantidade;
  MemItens.FieldByName('valor_unit').AsCurrency := ValorUnitario;
  MemItens.FieldByName('total').AsCurrency := Round(Quantidade * ValorUnitario * 100) / 100;
  MemItens.Post;

  CbItem.KeyValue := Null;
  CbOrigem.KeyValue := Null;
  QryOrigens.Close;
  EdtQuantidade.Clear;
  EdtValor.Clear;
  AtualizarTotal;
  AtualizarDisponivel;
  CbItem.SetFocus;
end;

procedure TFrmMovimento.BtnRemoverClick(Sender: TObject);
begin
  if not MemItens.IsEmpty then
    MemItens.Delete;
  AtualizarTotal;
end;

procedure TFrmMovimento.BtnGravarClick(Sender: TObject);
var
  Servico: TMovimentoService;
  Mov: TMovimento;
  Numero: Integer;
  Lancamento: Variant;
begin
  Mov := Default(TMovimento);
  Mov.Data := DtpData.Date;
  Mov.Operacao := FOperacao;
  if CbEntidade.Visible then
    Mov.IdEntidade := Chave(CbEntidade);
  Mov.AVista := RgPagamento.ItemIndex = 0;
  if CbContaDestino.Visible then
    Mov.IdContaDestino := Chave(CbContaDestino);
  if CbVeiculo.Visible then
    Mov.IdVeiculo := Chave(CbVeiculo);
  Mov.Observacao := EdtObservacao.Text;
  Mov.Itens := Itens;

  Servico := TMovimentoService.Create(DM.Conexao, Sessao);
  try
    try
      Numero := Servico.Registrar(Mov);
      Lancamento := DM.Conexao.ExecSQLScalar('SELECT id FROM lancamento WHERE id_movimento = :id', [Numero]);
      if VarIsNull(Lancamento) or VarIsEmpty(Lancamento) then
        ShowMessage(Format('Movimento nº %d gravado.' + sLineBreak +
          'Transferência não gera lançamento contábil: o patrimônio não mudou, só o local físico.', [Numero]))
      else
        ShowMessage(Format('Movimento nº %d gravado.' + sLineBreak +
          'Lançamento contábil nº %d gerado automaticamente.', [Numero, Integer(Lancamento)]));
      QryItens.Refresh; // custo medio pode ter mudado
      LimparItens;
    except
      on E: EMovimentoInvalido do
        ShowMessage(E.Message);
      on E: ELancamentoInvalido do
        ShowMessage(E.Message);
      on E: EAcessoNegado do
        ShowMessage(E.Message);
    end;
  finally
    Servico.Free;
  end;
end;

procedure TFrmMovimento.LimparItens;
begin
  MemItens.EmptyDataSet;
  EdtObservacao.Clear;
  CbItem.KeyValue := Null;
  CbOrigem.KeyValue := Null;
  CbDestino.KeyValue := Null;
  QryOrigens.Close;
  EdtQuantidade.Clear;
  EdtValor.Clear;
  AtualizarTotal;
  AtualizarDisponivel;
end;

end.
