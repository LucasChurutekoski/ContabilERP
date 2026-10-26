unit uFrmHistoricoMovimentos;

{ Historico de movimentos (kardex): tudo o que entrou, saiu ou mudou de
  prateleira, com filtro por periodo, item e operacao. Mostra tambem as
  transferencias, que nao aparecem no Diario porque nao geram lancamento. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmHistoricoMovimentos = class(TForm)
    PnlFiltro: TPanel;
    LblDe: TLabel;
    DtpDe: TDateTimePicker;
    LblAte: TLabel;
    DtpAte: TDateTimePicker;
    LblItem: TLabel;
    CbItem: TDBLookupComboBox;
    LblOperacao: TLabel;
    CbOperacao: TComboBox;
    BtnFiltrar: TButton;
    Grade: TDBGrid;
    PnlRodape: TPanel;
    LblResumo: TLabel;
    BtnFechar: TButton;
    Qry: TFDQuery;
    Ds: TDataSource;
    QryItens: TFDQuery;
    DsItens: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnFiltrarClick(Sender: TObject);
  private
    procedure Filtrar;
  public
    class procedure Executar;
  end;

var
  FrmHistoricoMovimentos: TFrmHistoricoMovimentos;

implementation

{$R *.dfm}

uses
  System.DateUtils, uDM, uSessao, uConsultaService, uTelaUtil;

const
  // Mesma ordem dos itens do CbOperacao (o indice 0 e "Todas")
  CODIGOS_OPERACAO: array[0..5] of string =
    ('', 'COMPRA', 'CONSUMO', 'TRANSFERENCIA', 'SERVICO', 'MANUTENCAO');

class procedure TFrmHistoricoMovimentos.Executar;
var
  Form: TFrmHistoricoMovimentos;
begin
  Sessao.Exigir('EST_CONSULTAR');
  Form := TFrmHistoricoMovimentos.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmHistoricoMovimentos.FormCreate(Sender: TObject);
begin
  QryItens.Connection := DM.Conexao;
  QryItens.Open;
  DtpDe.Date := StartOfTheMonth(Date);
  DtpAte.Date := Date;
  CbOperacao.ItemIndex := 0;
  CbItem.KeyValue := Null;
  Filtrar;
end;

procedure TFrmHistoricoMovimentos.BtnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmHistoricoMovimentos.Filtrar;
var
  Consulta: TConsultaService;
  IdItem: Integer;
  Movimentos, UltimoNumero: Integer;
begin
  if DtpDe.Date > DtpAte.Date then
    raise Exception.Create('A data inicial é maior que a final.');

  if VarIsNull(CbItem.KeyValue) or VarIsEmpty(CbItem.KeyValue) then
    IdItem := 0
  else
    IdItem := CbItem.KeyValue;

  Consulta := TConsultaService.Create(DM.Conexao);
  try
    Consulta.AbrirHistoricoMovimentos(Qry, DtpDe.Date, DtpAte.Date, IdItem,
      CODIGOS_OPERACAO[CbOperacao.ItemIndex]);
  finally
    Consulta.Free;
  end;

  Qry.FieldByName('numero').DisplayLabel := 'Nº mov.';
  Qry.FieldByName('numero').DisplayWidth := 6;
  Qry.FieldByName('data').DisplayLabel := 'Data';
  Qry.FieldByName('operacao').DisplayLabel := 'Operação';
  Qry.FieldByName('operacao').DisplayWidth := 14;
  Qry.FieldByName('codigo').DisplayLabel := 'Código';
  Qry.FieldByName('codigo').DisplayWidth := 10;
  Qry.FieldByName('descricao').DisplayLabel := 'Item';
  Qry.FieldByName('descricao').DisplayWidth := 24;
  Qry.FieldByName('origem').DisplayLabel := 'Origem';
  Qry.FieldByName('origem').DisplayWidth := 14;
  Qry.FieldByName('destino').DisplayLabel := 'Destino';
  Qry.FieldByName('destino').DisplayWidth := 14;
  Qry.FieldByName('quantidade').DisplayLabel := 'Qtd';
  (Qry.FieldByName('quantidade') as TNumericField).DisplayFormat := '#,##0.###';
  Qry.FieldByName('valor_unit_centavos').DisplayLabel := 'Valor unit.';
  Qry.FieldByName('total_c').DisplayLabel := 'Total';
  Qry.FieldByName('usuario').DisplayLabel := 'Usuário';
  Qry.FieldByName('usuario').DisplayWidth := 10;
  Qry.FieldByName('observacao').DisplayLabel := 'Observação';
  Qry.FieldByName('observacao').DisplayWidth := 30;
  FormatarCentavos(Qry.FieldByName('valor_unit_centavos'));
  FormatarCentavos(Qry.FieldByName('total_c'));

  // Conta os movimentos distintos (um movimento pode ter varios itens)
  Movimentos := 0;
  UltimoNumero := 0;
  Qry.DisableControls;
  try
    Qry.First;
    while not Qry.Eof do
    begin
      if Qry.FieldByName('numero').AsInteger <> UltimoNumero then
      begin
        Inc(Movimentos);
        UltimoNumero := Qry.FieldByName('numero').AsInteger;
      end;
      Qry.Next;
    end;
    Qry.First;
  finally
    Qry.EnableControls;
  end;
  LblResumo.Caption := Format('%d movimento(s), %d linha(s) de item no período.   ' +
    'Origem = de onde saiu; Destino = para onde foi.', [Movimentos, Qry.RecordCount]);
end;

end.
