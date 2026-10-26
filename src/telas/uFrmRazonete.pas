unit uFrmRazonete;

{ Razonete (conta em T): debitos a esquerda, creditos a direita,
  com o numero do lancamento, e o saldo calculado pelo TSaldo. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmRazonete = class(TForm)
    PnlTopo: TPanel;
    LblConta: TLabel;
    CbConta: TDBLookupComboBox;
    PnlT: TPanel;
    LblTitulo: TLabel;
    PnlDebito: TPanel;
    LblDebito: TLabel;
    GradeDebito: TDBGrid;
    LblTotalDebito: TLabel;
    PnlLinha: TPanel;
    PnlCredito: TPanel;
    LblCredito: TLabel;
    GradeCredito: TDBGrid;
    LblTotalCredito: TLabel;
    PnlSaldo: TPanel;
    LblSaldo: TLabel;
    QryContas: TFDQuery;
    DsContas: TDataSource;
    QryDebitos: TFDQuery;
    DsDebitos: TDataSource;
    QryCreditos: TFDQuery;
    DsCreditos: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CbContaClick(Sender: TObject);
  private
    procedure Atualizar;
    procedure AjustarGrade(AQuery: TFDQuery);
  public
    class procedure Executar;
  end;

var
  FrmRazonete: TFrmRazonete;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uSaldo, uLancamentoService, uConsultaService, uTelaUtil;

class procedure TFrmRazonete.Executar;
var
  Form: TFrmRazonete;
begin
  Sessao.Exigir('REL_CONTABEIS');
  Form := TFrmRazonete.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmRazonete.FormCreate(Sender: TObject);
begin
  QryContas.Connection := DM.Conexao;
  QryContas.Open;
  // Abre ja em Bancos, a conta mais movimentada nos cenarios de teste
  CbConta.KeyValue := QryContas.Lookup('codigo', '1.1.1.02', 'id');
  Atualizar;
end;

procedure TFrmRazonete.FormResize(Sender: TObject);
begin
  // As duas metades do T sempre com a mesma largura.
  // O OnResize pode disparar enquanto o form ainda esta sendo montado.
  if Assigned(PnlT) and Assigned(PnlDebito) and Assigned(PnlLinha) then
    PnlDebito.Width := (PnlT.ClientWidth - PnlLinha.Width) div 2;
end;

procedure TFrmRazonete.CbContaClick(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmRazonete.AjustarGrade(AQuery: TFDQuery);
begin
  AQuery.FieldByName('numero').DisplayLabel := 'Nº';
  AQuery.FieldByName('numero').DisplayWidth := 5;
  AQuery.FieldByName('data').DisplayLabel := 'Data';
  AQuery.FieldByName('historico').DisplayLabel := 'Histórico';
  AQuery.FieldByName('historico').DisplayWidth := 30;
  AQuery.FieldByName('valor_centavos').DisplayLabel := 'Valor';
  AQuery.FieldByName('valor_centavos').DisplayWidth := 12;
  FormatarCentavos(AQuery.FieldByName('valor_centavos'));
end;

procedure TFrmRazonete.Atualizar;
var
  Consulta: TConsultaService;
  Lancamentos: TLancamentoService;
  Saldo: TSaldo;
  IdConta: Integer;
  Natureza, TextoNatureza: string;
begin
  if VarIsNull(CbConta.KeyValue) or VarIsEmpty(CbConta.KeyValue) then
    Exit;
  IdConta := CbConta.KeyValue;
  Natureza := VarToStr(QryContas.Lookup('id', IdConta, 'natureza'));
  LblTitulo.Caption := VarToStr(QryContas.Lookup('id', IdConta, 'codigo')) + '  ' +
    VarToStr(QryContas.Lookup('id', IdConta, 'nome'));

  Consulta := TConsultaService.Create(DM.Conexao);
  Lancamentos := TLancamentoService.Create(DM.Conexao);
  try
    Consulta.AbrirRazonete(QryDebitos, IdConta, 'D');
    Consulta.AbrirRazonete(QryCreditos, IdConta, 'C');
    AjustarGrade(QryDebitos);
    AjustarGrade(QryCreditos);
    Saldo := Lancamentos.SaldoConta(IdConta);
  finally
    Lancamentos.Free;
    Consulta.Free;
  end;

  LblTotalDebito.Caption := 'Total de débitos: ' + FormatarMoeda(Saldo.Debitos);
  LblTotalCredito.Caption := 'Total de créditos: ' + FormatarMoeda(Saldo.Creditos);

  if Natureza = 'D' then
    TextoNatureza := 'natureza devedora'
  else
    TextoNatureza := 'natureza credora';

  if Saldo.Lado = ' ' then
  begin
    LblSaldo.Caption := 'Saldo: zerado (' + TextoNatureza + ')';
    LblSaldo.Font.Color := clWindowText;
  end
  else if Saldo.Invertido(Natureza[1]) then
  begin
    LblSaldo.Caption := 'Saldo: ' + Saldo.Texto + '   ATENÇÃO: saldo invertido para uma conta de ' + TextoNatureza;
    LblSaldo.Font.Color := clRed;
  end
  else
  begin
    LblSaldo.Caption := 'Saldo: ' + Saldo.Texto + '   (' + TextoNatureza + ')';
    LblSaldo.Font.Color := clGreen;
  end;
end;

end.
