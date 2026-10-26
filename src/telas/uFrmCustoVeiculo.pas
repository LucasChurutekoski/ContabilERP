unit uFrmCustoVeiculo;

{ Custo de manutencao por veiculo, em MESTRE-DETALHE:
  a grade de cima lista os veiculos com os totais; a de baixo mostra as
  pecas e a mao de obra do veiculo selecionado. A ligacao e do FireDAC:
  QryItens.MasterSource = DsVeiculos e MasterFields = 'id', entao o
  parametro :id da query de detalhe acompanha a linha do mestre sozinho. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmCustoVeiculo = class(TForm)
    LblVeiculos: TLabel;
    GradeVeiculos: TDBGrid;
    LblItens: TLabel;
    GradeItens: TDBGrid;
    PnlRodape: TPanel;
    BtnAtualizar: TButton;
    BtnFechar: TButton;
    QryVeiculos: TFDQuery;
    DsVeiculos: TDataSource;
    QryItens: TFDQuery;
    DsItens: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
  private
    procedure Atualizar;
  public
    class procedure Executar;
  end;

var
  FrmCustoVeiculo: TFrmCustoVeiculo;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uConsultaService, uTelaUtil;

class procedure TFrmCustoVeiculo.Executar;
var
  Form: TFrmCustoVeiculo;
begin
  Sessao.Exigir('EST_CONSULTAR');
  Form := TFrmCustoVeiculo.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmCustoVeiculo.FormCreate(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmCustoVeiculo.BtnAtualizarClick(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmCustoVeiculo.Atualizar;
var
  Consulta: TConsultaService;
begin
  QryItens.Close;
  Consulta := TConsultaService.Create(DM.Conexao);
  try
    Consulta.AbrirCustoPorVeiculo(QryVeiculos);
  finally
    Consulta.Free;
  end;
  QryVeiculos.FieldByName('id').Visible := False;
  QryVeiculos.FieldByName('placa').DisplayLabel := 'Placa';
  QryVeiculos.FieldByName('descricao').DisplayLabel := 'Veículo';
  QryVeiculos.FieldByName('descricao').DisplayWidth := 30;
  QryVeiculos.FieldByName('manutencoes').DisplayLabel := 'Manutenções';
  QryVeiculos.FieldByName('pecas_c').DisplayLabel := 'Peças';
  QryVeiculos.FieldByName('mao_de_obra_c').DisplayLabel := 'Mão de obra';
  QryVeiculos.FieldByName('total_c').DisplayLabel := 'Total';
  FormatarCentavos(QryVeiculos.FieldByName('pecas_c'));
  FormatarCentavos(QryVeiculos.FieldByName('mao_de_obra_c'));
  FormatarCentavos(QryVeiculos.FieldByName('total_c'));

  // Detalhe: o SQL tem o parametro :id, preenchido pelo campo "id" do mestre
  QryItens.Connection := DM.Conexao;
  QryItens.SQL.Text := SQL_ITENS_MANUTENCAO;
  QryItens.MasterSource := DsVeiculos;
  QryItens.MasterFields := 'id';
  QryItens.Open;
  QryItens.FieldByName('numero').DisplayLabel := 'Nº mov.';
  QryItens.FieldByName('data').DisplayLabel := 'Data';
  QryItens.FieldByName('codigo').DisplayLabel := 'Código';
  QryItens.FieldByName('descricao').DisplayLabel := 'Peça / mão de obra';
  QryItens.FieldByName('descricao').DisplayWidth := 34;
  QryItens.FieldByName('quantidade').DisplayLabel := 'Qtd';
  (QryItens.FieldByName('quantidade') as TNumericField).DisplayFormat := '#,##0.###';
  QryItens.FieldByName('valor_c').DisplayLabel := 'Valor';
  FormatarCentavos(QryItens.FieldByName('valor_c'));
end;

end.
