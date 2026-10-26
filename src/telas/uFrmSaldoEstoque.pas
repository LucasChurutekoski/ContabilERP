unit uFrmSaldoEstoque;

{ Saldo fisico por item e local + conciliacao com a contabilidade:
  quantidade x custo medio deve bater com o saldo da conta Estoques. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmSaldoEstoque = class(TForm)
    Grade: TDBGrid;
    PnlRodape: TPanel;
    LblConciliacao: TLabel;
    LblSituacao: TLabel;
    BtnAtualizar: TButton;
    BtnFechar: TButton;
    Qry: TFDQuery;
    Ds: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
  private
    procedure Atualizar;
  public
    class procedure Executar;
  end;

var
  FrmSaldoEstoque: TFrmSaldoEstoque;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uConsultaService, uTelaUtil;

class procedure TFrmSaldoEstoque.Executar;
var
  Form: TFrmSaldoEstoque;
begin
  Sessao.Exigir('EST_CONSULTAR');
  Form := TFrmSaldoEstoque.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmSaldoEstoque.FormCreate(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmSaldoEstoque.Atualizar;
var
  Consulta: TConsultaService;
  Conciliacao: TConciliacaoEstoque;
begin
  Consulta := TConsultaService.Create(DM.Conexao);
  try
    Consulta.AbrirSaldoEstoque(Qry);
    Conciliacao := Consulta.ConciliacaoEstoque;
  finally
    Consulta.Free;
  end;

  Qry.FieldByName('codigo').DisplayLabel := 'Código';
  Qry.FieldByName('codigo').DisplayWidth := 11;
  Qry.FieldByName('descricao').DisplayLabel := 'Item';
  Qry.FieldByName('descricao').DisplayWidth := 26;
  Qry.FieldByName('unidade').DisplayLabel := 'Un.';
  Qry.FieldByName('unidade').DisplayWidth := 4;
  Qry.FieldByName('local_codigo').DisplayLabel := 'Local';
  Qry.FieldByName('local_codigo').DisplayWidth := 9;
  Qry.FieldByName('local_nome').DisplayLabel := 'Nome do local';
  Qry.FieldByName('local_nome').DisplayWidth := 18;
  Qry.FieldByName('quantidade').DisplayLabel := 'Quantidade';
  (Qry.FieldByName('quantidade') as TNumericField).DisplayFormat := '#,##0.###';
  Qry.FieldByName('custo_medio_centavos').DisplayLabel := 'Custo médio';
  Qry.FieldByName('valor_total_c').DisplayLabel := 'Valor em estoque';
  FormatarCentavos(Qry.FieldByName('custo_medio_centavos'));
  FormatarCentavos(Qry.FieldByName('valor_total_c'));

  LblConciliacao.Caption := Format('Estoque físico (quantidade × custo médio): %s     ' +
    'Saldo contábil das contas de estoque: %s',
    [FormatarMoeda(Conciliacao.Fisico), FormatarMoeda(Conciliacao.Contabil)]);

  if Conciliacao.Diferenca = 0 then
  begin
    LblSituacao.Caption := '✓ Estoque físico e contabilidade conciliados';
    LblSituacao.Font.Color := clGreen;
  end
  else
  begin
    LblSituacao.Caption := '✗ Diferença de ' + FormatarMoeda(Conciliacao.Diferenca) +
      ' (lançamento manual em conta de estoque ou arredondamento do custo médio)';
    LblSituacao.Font.Color := clRed;
  end;
end;

procedure TFrmSaldoEstoque.BtnAtualizarClick(Sender: TObject);
begin
  Atualizar;
end;

end.
