unit uFrmLancamento;

{ Lancamento contabil manual com varias partidas.
  As partidas ficam num TFDMemTable (uma "tabela em memoria") ate o usuario
  gravar; so entao o TLancamentoService valida e grava tudo numa transacao. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uLancamentoService;

type
  TFrmLancamento = class(TForm)
    PnlCabecalho: TPanel;
    LblData: TLabel;
    DtpData: TDateTimePicker;
    LblHistorico: TLabel;
    EdtHistorico: TEdit;
    BtnDiario: TButton;
    PnlPartida: TPanel;
    LblConta: TLabel;
    CbConta: TDBLookupComboBox;
    RgDC: TRadioGroup;
    LblValor: TLabel;
    EdtValor: TEdit;
    BtnAdicionar: TButton;
    Grade: TDBGrid;
    PnlRodape: TPanel;
    BtnRemover: TButton;
    LblTotais: TLabel;
    BtnGravar: TButton;
    BtnFechar: TButton;
    QryContas: TFDQuery;
    DsContas: TDataSource;
    MemPartidas: TFDMemTable;
    DsPartidas: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnAdicionarClick(Sender: TObject);
    procedure BtnRemoverClick(Sender: TObject);
    procedure BtnGravarClick(Sender: TObject);
    procedure BtnDiarioClick(Sender: TObject);
  private
    function Partidas: TArray<TPartida>;
    procedure AtualizarTotais;
    procedure Limpar;
  public
    class procedure Executar;
  end;

var
  FrmLancamento: TFrmLancamento;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil, uFrmDiario;

class procedure TFrmLancamento.Executar;
var
  Form: TFrmLancamento;
begin
  Sessao.Exigir('LANC_INCLUIR');
  Form := TFrmLancamento.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmLancamento.FormCreate(Sender: TObject);
begin
  QryContas.Connection := DM.Conexao;
  QryContas.Open;

  // Estrutura da tabela em memoria: definida em codigo e criada vazia
  MemPartidas.FieldDefs.Add('id_conta', ftInteger);
  MemPartidas.FieldDefs.Add('codigo', ftString, 20);
  MemPartidas.FieldDefs.Add('conta', ftString, 100);
  MemPartidas.FieldDefs.Add('dc', ftString, 1);
  MemPartidas.FieldDefs.Add('valor', ftCurrency);
  MemPartidas.CreateDataSet;

  MemPartidas.FieldByName('id_conta').Visible := False;
  MemPartidas.FieldByName('codigo').DisplayLabel := 'Código';
  MemPartidas.FieldByName('codigo').DisplayWidth := 12;
  MemPartidas.FieldByName('conta').DisplayLabel := 'Conta';
  MemPartidas.FieldByName('conta').DisplayWidth := 45;
  MemPartidas.FieldByName('dc').DisplayLabel := 'D/C';
  MemPartidas.FieldByName('dc').DisplayWidth := 5;
  MemPartidas.FieldByName('valor').DisplayLabel := 'Valor';
  (MemPartidas.FieldByName('valor') as TCurrencyField).currency := False;
  (MemPartidas.FieldByName('valor') as TCurrencyField).DisplayFormat := '#,##0.00';

  DtpData.Date := Date;
  Limpar;
end;

function TFrmLancamento.Partidas: TArray<TPartida>;
var
  Lista: TArray<TPartida>;
  Partida: TPartida;
begin
  Lista := [];
  MemPartidas.DisableControls; // percorre sem a grade "piscar"
  try
    MemPartidas.First;
    while not MemPartidas.Eof do
    begin
      Partida.IdConta := MemPartidas.FieldByName('id_conta').AsInteger;
      Partida.DC := MemPartidas.FieldByName('dc').AsString[1];
      Partida.Valor := MemPartidas.FieldByName('valor').AsCurrency;
      Lista := Lista + [Partida];
      MemPartidas.Next;
    end;
  finally
    MemPartidas.EnableControls;
  end;
  Result := Lista;
end;

procedure TFrmLancamento.AtualizarTotais;
var
  Lista: TArray<TPartida>;
  Debitos, Creditos, Diferenca: Currency;
begin
  // Reaproveita as regras puras do servico: a tela nao recalcula nada por conta propria
  Lista := Partidas;
  Debitos := TLancamentoService.TotalDebitos(Lista);
  Creditos := TLancamentoService.TotalCreditos(Lista);
  Diferenca := Debitos - Creditos;

  LblTotais.Caption := Format('Débitos: %s     Créditos: %s     Diferença: %s',
    [FormatarMoeda(Debitos), FormatarMoeda(Creditos), FormatarMoeda(Abs(Diferenca))]);

  if (Diferenca = 0) and (Length(Lista) >= 2) then
    LblTotais.Font.Color := clGreen
  else
    LblTotais.Font.Color := clRed;
  BtnGravar.Enabled := (Diferenca = 0) and (Length(Lista) >= 2);
  BtnRemover.Enabled := not MemPartidas.IsEmpty;

  // Sugere a proxima partida: o lado e o valor que faltam para fechar
  if Diferenca > 0 then
  begin
    RgDC.ItemIndex := 1;
    EdtValor.Text := FormatFloat('0.00', Diferenca);
  end
  else if Diferenca < 0 then
  begin
    RgDC.ItemIndex := 0;
    EdtValor.Text := FormatFloat('0.00', -Diferenca);
  end
  else
    EdtValor.Clear;
end;

procedure TFrmLancamento.BtnAdicionarClick(Sender: TObject);
var
  Valor: Currency;
  IdConta: Integer;
begin
  if VarIsNull(CbConta.KeyValue) or VarIsEmpty(CbConta.KeyValue) then
    raise Exception.Create('Escolha a conta.');
  if not LerValor(EdtValor.Text, Valor) or (Valor <= 0) then
    raise Exception.Create('Informe um valor maior que zero (ex.: 1500,00).');

  IdConta := CbConta.KeyValue;
  MemPartidas.Append;
  MemPartidas.FieldByName('id_conta').AsInteger := IdConta;
  MemPartidas.FieldByName('codigo').AsString := VarToStr(QryContas.Lookup('id', IdConta, 'codigo'));
  MemPartidas.FieldByName('conta').AsString := VarToStr(QryContas.Lookup('id', IdConta, 'nome'));
  if RgDC.ItemIndex = 0 then
    MemPartidas.FieldByName('dc').AsString := 'D'
  else
    MemPartidas.FieldByName('dc').AsString := 'C';
  MemPartidas.FieldByName('valor').AsCurrency := Valor;
  MemPartidas.Post;

  CbConta.KeyValue := Null;
  AtualizarTotais;
  CbConta.SetFocus;
end;

procedure TFrmLancamento.BtnRemoverClick(Sender: TObject);
begin
  if not MemPartidas.IsEmpty then
    MemPartidas.Delete;
  AtualizarTotais;
end;

procedure TFrmLancamento.BtnGravarClick(Sender: TObject);
var
  Servico: TLancamentoService;
  Numero: Integer;
begin
  Servico := TLancamentoService.Create(DM.Conexao);
  try
    try
      Numero := Servico.RegistrarManual(Sessao, DtpData.Date, EdtHistorico.Text, Partidas);
      ShowMessage(Format('Lançamento nº %d gravado.', [Numero]));
      Limpar;
    except
      // Erros de regra viram aviso; erros inesperados seguem para o tratador padrao
      on E: ELancamentoInvalido do
        ShowMessage(E.Message);
      on E: EAcessoNegado do
        ShowMessage(E.Message);
    end;
  finally
    Servico.Free;
  end;
end;

procedure TFrmLancamento.BtnDiarioClick(Sender: TObject);
begin
  TFrmDiario.Executar;
end;

procedure TFrmLancamento.Limpar;
begin
  MemPartidas.EmptyDataSet;
  EdtHistorico.Clear;
  CbConta.KeyValue := Null;
  RgDC.ItemIndex := 0;
  AtualizarTotais;
end;

end.
