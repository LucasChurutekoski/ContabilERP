unit uFrmUnidades;

{ Cadastro de unidades de medida. Tambem serve de "seletor" para a tela de itens. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmUnidades = class(TForm)
    Navegador: TDBNavigator;
    Grade: TDBGrid;
    PnlEdicao: TPanel;
    LblSigla: TLabel;
    EdtSigla: TDBEdit;
    LblDescricao: TLabel;
    EdtDescricao: TDBEdit;
    Qry: TFDQuery;
    Ds: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure QryBeforePost(DataSet: TDataSet);
    procedure QryBeforeDelete(DataSet: TDataSet);
    procedure QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
  public
    { Abre posicionado em ASigla e devolve a sigla selecionada ao fechar. }
    class function Executar(const ASigla: string = ''): string;
  end;

var
  FrmUnidades: TFrmUnidades;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil;

class function TFrmUnidades.Executar(const ASigla: string): string;
var
  Form: TFrmUnidades;
begin
  Sessao.Exigir('CAD_ITENS');
  Form := TFrmUnidades.Create(nil);
  try
    if ASigla <> '' then
      Form.Qry.Locate('sigla', ASigla, []);
    Form.ShowModal;
    Result := Form.Qry.FieldByName('sigla').AsString;
  finally
    Form.Free;
  end;
end;

procedure TFrmUnidades.FormCreate(Sender: TObject);
begin
  Qry.Connection := DM.Conexao;
  Qry.Open;
  ConfigurarCadastro(Ds, Grade, EdtSigla);
end;

procedure TFrmUnidades.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(Qry);
end;

procedure TFrmUnidades.QryBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('sigla').AsString := UpperCase(Trim(DataSet.FieldByName('sigla').AsString));
  if DataSet.FieldByName('sigla').AsString = '' then
    raise Exception.Create('Informe a sigla (ex.: UN, KG, L).');
  if Trim(DataSet.FieldByName('descricao').AsString) = '' then
    raise Exception.Create('Informe a descrição da unidade.');
end;

procedure TFrmUnidades.QryBeforeDelete(DataSet: TDataSet);
begin
  ConfirmarExclusao;
end;

procedure TFrmUnidades.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E));
end;

end.
