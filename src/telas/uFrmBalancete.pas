unit uFrmBalancete;

{ Balancete de verificacao: contas movimentadas com saldo devedor ou credor,
  totais das duas colunas e o indicador de que fecharam. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmBalancete = class(TForm)
    Grade: TDBGrid;
    PnlRodape: TPanel;
    LblTotais: TLabel;
    LblSituacao: TLabel;
    BtnAtualizar: TButton;
    BtnImprimir: TButton;
    BtnFechar: TButton;
    Qry: TFDQuery;
    Ds: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
    procedure BtnImprimirClick(Sender: TObject);
  private
    procedure Atualizar;
  public
    class procedure Executar;
  end;

var
  FrmBalancete: TFrmBalancete;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uConsultaService, uTelaUtil, uRelBalancete;

class procedure TFrmBalancete.Executar;
var
  Form: TFrmBalancete;
begin
  Sessao.Exigir('REL_CONTABEIS');
  Form := TFrmBalancete.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmBalancete.FormCreate(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmBalancete.Atualizar;
var
  Consulta: TConsultaService;
  Totais: TTotaisBalancete;
begin
  Consulta := TConsultaService.Create(DM.Conexao);
  try
    Consulta.AbrirBalancete(Qry);
    Totais := Consulta.TotaisBalancete;
  finally
    Consulta.Free;
  end;

  Qry.FieldByName('codigo').DisplayLabel := 'Código';
  Qry.FieldByName('codigo').DisplayWidth := 10;
  Qry.FieldByName('nome').DisplayLabel := 'Conta';
  Qry.FieldByName('nome').DisplayWidth := 34;
  Qry.FieldByName('natureza').DisplayLabel := 'Nat.';
  Qry.FieldByName('natureza').DisplayWidth := 4;
  Qry.FieldByName('debitos_c').DisplayLabel := 'Débitos';
  Qry.FieldByName('creditos_c').DisplayLabel := 'Créditos';
  Qry.FieldByName('saldo_devedor_c').DisplayLabel := 'Saldo devedor';
  Qry.FieldByName('saldo_credor_c').DisplayLabel := 'Saldo credor';
  FormatarCentavos(Qry.FieldByName('debitos_c'));
  FormatarCentavos(Qry.FieldByName('creditos_c'));
  FormatarCentavos(Qry.FieldByName('saldo_devedor_c'));
  FormatarCentavos(Qry.FieldByName('saldo_credor_c'));

  LblTotais.Caption := Format('Total devedor: %s     Total credor: %s',
    [FormatarMoeda(Totais.Devedor), FormatarMoeda(Totais.Credor)]);

  if Qry.IsEmpty then
  begin
    LblSituacao.Caption := 'Nenhum lançamento ainda.';
    LblSituacao.Font.Color := clWindowText;
  end
  else if Totais.Fecha then
  begin
    LblSituacao.Caption := '✓ Balancete fechado: devedores = credores';
    LblSituacao.Font.Color := clGreen;
  end
  else
  begin
    LblSituacao.Caption := '✗ Balancete NÃO fechou';
    LblSituacao.Font.Color := clRed;
  end;
end;

procedure TFrmBalancete.BtnAtualizarClick(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmBalancete.BtnImprimirClick(Sender: TObject);
begin
  ImprimirBalancete(DM.Conexao, Sessao.Nome);
end;

end.
