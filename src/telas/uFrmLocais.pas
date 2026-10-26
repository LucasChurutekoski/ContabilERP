unit uFrmLocais;

{ Cadastro de locais de estoque em arvore (almoxarifado > prateleiras).
  Mesma ideia do plano de contas: local "agrupador" so soma os filhos,
  e so o local final (aceita_estoque = 1) guarda itens. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmLocais = class(TForm)
    Navegador: TDBNavigator;
    Grade: TDBGrid;
    PnlEdicao: TPanel;
    LblCodigo: TLabel;
    EdtCodigo: TDBEdit;
    LblNome: TLabel;
    EdtNome: TDBEdit;
    LblPai: TLabel;
    CbPai: TDBLookupComboBox;
    ChkAceitaEstoque: TDBCheckBox;
    Qry: TFDQuery;
    Ds: TDataSource;
    QryPais: TFDQuery;
    DsPais: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure QryNewRecord(DataSet: TDataSet);
    procedure QryBeforePost(DataSet: TDataSet);
    procedure QryAfterPost(DataSet: TDataSet);
    procedure QryBeforeDelete(DataSet: TDataSet);
    procedure QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
  public
    class procedure Executar;
  end;

var
  FrmLocais: TFrmLocais;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil;

class procedure TFrmLocais.Executar;
var
  Form: TFrmLocais;
begin
  Sessao.Exigir('CAD_LOCAIS');
  Form := TFrmLocais.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmLocais.FormCreate(Sender: TObject);
begin
  QryPais.Connection := DM.Conexao;
  QryPais.Open;
  Qry.Connection := DM.Conexao;
  Qry.Open;
  ConfigurarCadastro(Ds, Grade, EdtCodigo);
end;

procedure TFrmLocais.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(Qry);
end;

procedure TFrmLocais.QryNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('aceita_estoque').AsInteger := 1;
end;

procedure TFrmLocais.QryBeforePost(DataSet: TDataSet);
var
  QtdFilhos: Integer;
begin
  if Trim(DataSet.FieldByName('codigo').AsString) = '' then
    raise Exception.Create('Informe o código do local.');
  if Trim(DataSet.FieldByName('nome').AsString) = '' then
    raise Exception.Create('Informe o nome do local.');

  if (not DataSet.FieldByName('id').IsNull) and
     (DataSet.FieldByName('id_pai').AsInteger = DataSet.FieldByName('id').AsInteger) then
    raise Exception.Create('Um local não pode ser pai dele mesmo.');

  // Local com sub-locais e agrupador: nao pode guardar estoque diretamente
  if (DataSet.FieldByName('aceita_estoque').AsInteger = 1) and
     (not DataSet.FieldByName('id').IsNull) then
  begin
    QtdFilhos := DM.Conexao.ExecSQLScalar(
      'SELECT COUNT(*) FROM local WHERE id_pai = :id', [DataSet.FieldByName('id').AsInteger]);
    if QtdFilhos > 0 then
      raise Exception.Create('Este local tem sub-locais: só locais finais (ex.: prateleiras) aceitam estoque.');
  end;
end;

procedure TFrmLocais.QryAfterPost(DataSet: TDataSet);
begin
  // Um novo agrupador precisa aparecer na lista de "local pai"
  QryPais.Refresh;
end;

procedure TFrmLocais.QryBeforeDelete(DataSet: TDataSet);
begin
  ConfirmarExclusao;
end;

procedure TFrmLocais.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E));
end;

end.
