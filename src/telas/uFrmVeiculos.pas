unit uFrmVeiculos;

{ Cadastro de veiculos da frota (centros de custo das manutencoes). }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmVeiculos = class(TForm)
    Navegador: TDBNavigator;
    Grade: TDBGrid;
    PnlEdicao: TPanel;
    LblPlaca: TLabel;
    EdtPlaca: TDBEdit;
    LblDescricao: TLabel;
    EdtDescricao: TDBEdit;
    LblAno: TLabel;
    EdtAno: TDBEdit;
    ChkAtivo: TDBCheckBox;
    Qry: TFDQuery;
    Ds: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure QryNewRecord(DataSet: TDataSet);
    procedure QryBeforePost(DataSet: TDataSet);
    procedure QryBeforeDelete(DataSet: TDataSet);
    procedure QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
  public
    class procedure Executar;
  end;

var
  FrmVeiculos: TFrmVeiculos;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil;

class procedure TFrmVeiculos.Executar;
var
  Form: TFrmVeiculos;
begin
  Sessao.Exigir('CAD_VEICULOS');
  Form := TFrmVeiculos.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmVeiculos.FormCreate(Sender: TObject);
begin
  Qry.Connection := DM.Conexao;
  Qry.Open;
  ConfigurarCadastro(Ds, Grade, EdtPlaca);
end;

procedure TFrmVeiculos.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(Qry);
end;

procedure TFrmVeiculos.QryNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ativo').AsInteger := 1;
end;

procedure TFrmVeiculos.QryBeforePost(DataSet: TDataSet);
var
  Placa: string;
begin
  // Placa sem traco e em maiusculas: ABC-1234 e ABC1234 sao a mesma placa
  Placa := UpperCase(StringReplace(Trim(DataSet.FieldByName('placa').AsString), '-', '', [rfReplaceAll]));
  if Length(Placa) <> 7 then
    raise Exception.Create('A placa deve ter 7 caracteres (ex.: ABC1D23 ou ABC1234).');
  DataSet.FieldByName('placa').AsString := Placa;
  if Trim(DataSet.FieldByName('descricao').AsString) = '' then
    raise Exception.Create('Informe a descrição do veículo (ex.: Caminhão Volvo FH 540).');
end;

procedure TFrmVeiculos.QryBeforeDelete(DataSet: TDataSet);
begin
  ConfirmarExclusao;
end;

procedure TFrmVeiculos.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E) + sLineBreak + 'Dica: para tirar um veículo de uso, desmarque "Ativo".');
end;

end.
