unit uFrmDiario;

{ Livro Diario: todos os lancamentos de um periodo, com suas partidas,
  na ordem em que aconteceram. Filtro "de ... ate ...". }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmDiario = class(TForm)
    PnlFiltro: TPanel;
    LblDe: TLabel;
    DtpDe: TDateTimePicker;
    LblAte: TLabel;
    DtpAte: TDateTimePicker;
    BtnFiltrar: TButton;
    Grade: TDBGrid;
    PnlRodape: TPanel;
    LblTotais: TLabel;
    BtnFechar: TButton;
    Qry: TFDQuery;
    Ds: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnFiltrarClick(Sender: TObject);
  private
    procedure Filtrar;
  public
    class procedure Executar;
  end;

var
  FrmDiario: TFrmDiario;

implementation

{$R *.dfm}

uses
  System.DateUtils, uDM, uSessao, uConsultaService, uTelaUtil;

class procedure TFrmDiario.Executar;
var
  Form: TFrmDiario;
begin
  // Quem lanca (LANC_INCLUIR) ou quem consulta a contabilidade (REL_CONTABEIS)
  if not (Sessao.Pode('REL_CONTABEIS') or Sessao.Pode('LANC_INCLUIR')) then
    Sessao.Exigir('REL_CONTABEIS');
  Form := TFrmDiario.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmDiario.FormCreate(Sender: TObject);
begin
  // Periodo padrao: do primeiro dia do mes ate hoje
  DtpDe.Date := StartOfTheMonth(Date);
  DtpAte.Date := Date;
  Filtrar;
end;

procedure TFrmDiario.BtnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmDiario.Filtrar;
var
  Consulta: TConsultaService;
  Debitos, Creditos: Int64;
  Lancamentos: Integer;
  UltimoNumero: Integer;
begin
  if DtpDe.Date > DtpAte.Date then
    raise Exception.Create('A data inicial é maior que a final.');

  Consulta := TConsultaService.Create(DM.Conexao);
  try
    Consulta.AbrirDiario(Qry, DtpDe.Date, DtpAte.Date);
  finally
    Consulta.Free;
  end;

  Qry.FieldByName('numero').DisplayLabel := 'Nº';
  Qry.FieldByName('numero').DisplayWidth := 5;
  Qry.FieldByName('data').DisplayLabel := 'Data';
  Qry.FieldByName('historico').DisplayLabel := 'Histórico';
  Qry.FieldByName('historico').DisplayWidth := 40;
  Qry.FieldByName('origem').DisplayLabel := 'Origem (M/E)';
  Qry.FieldByName('origem').DisplayWidth := 6;
  Qry.FieldByName('codigo').DisplayLabel := 'Conta';
  Qry.FieldByName('codigo').DisplayWidth := 9;
  Qry.FieldByName('nome').DisplayLabel := 'Nome da conta';
  Qry.FieldByName('nome').DisplayWidth := 26;
  Qry.FieldByName('dc').DisplayLabel := 'D/C';
  Qry.FieldByName('dc').DisplayWidth := 4;
  Qry.FieldByName('valor_centavos').DisplayLabel := 'Valor';
  FormatarCentavos(Qry.FieldByName('valor_centavos'));

  // Totais do periodo: percorre o resultado sem a grade "piscar"
  Debitos := 0;
  Creditos := 0;
  Lancamentos := 0;
  UltimoNumero := 0;
  Qry.DisableControls;
  try
    Qry.First;
    while not Qry.Eof do
    begin
      if Qry.FieldByName('dc').AsString = 'D' then
        Inc(Debitos, Qry.FieldByName('valor_centavos').AsLargeInt)
      else
        Inc(Creditos, Qry.FieldByName('valor_centavos').AsLargeInt);
      if Qry.FieldByName('numero').AsInteger <> UltimoNumero then
      begin
        Inc(Lancamentos);
        UltimoNumero := Qry.FieldByName('numero').AsInteger;
      end;
      Qry.Next;
    end;
    Qry.First;
  finally
    Qry.EnableControls;
  end;

  LblTotais.Caption := Format('%d lançamento(s) no período     Débitos: %s     Créditos: %s     (M = manual, E = gerado pelo estoque)',
    [Lancamentos, FormatarMoeda(Debitos / 100), FormatarMoeda(Creditos / 100)]);
end;

end.
