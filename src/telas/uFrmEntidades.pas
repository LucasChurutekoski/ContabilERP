unit uFrmEntidades;

{ Cadastro de clientes e fornecedores.
  A grade e os campos estao ligados ao mesmo TDataSource: o FireDAC gera
  sozinho o INSERT/UPDATE/DELETE a partir do SELECT. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmEntidades = class(TForm)
    Navegador: TDBNavigator;
    Grade: TDBGrid;
    PnlEdicao: TPanel;
    LblNome: TLabel;
    EdtNome: TDBEdit;
    LblDocumento: TLabel;
    EdtDocumento: TDBEdit;
    ChkCliente: TDBCheckBox;
    ChkFornecedor: TDBCheckBox;
    Qry: TFDQuery;
    Ds: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure QryNewRecord(DataSet: TDataSet);
    procedure QryBeforePost(DataSet: TDataSet);
    procedure QryBeforeDelete(DataSet: TDataSet);
    procedure QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure EdtDocumentoChange(Sender: TObject);
  private
    FFormatando: Boolean;
  public
    class procedure Executar;
  end;

var
  FrmEntidades: TFrmEntidades;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil, uDocumento;

class procedure TFrmEntidades.Executar;
var
  Form: TFrmEntidades;
begin
  Sessao.Exigir('CAD_ENTIDADES');
  Form := TFrmEntidades.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmEntidades.FormCreate(Sender: TObject);
begin
  Qry.Connection := DM.Conexao;
  Qry.Open;
  ConfigurarCadastro(Ds, Grade, EdtNome);
end;

procedure TFrmEntidades.EdtDocumentoChange(Sender: TObject);
begin
  // Mascara enquanto digita. So reage a digitacao (campo focado e em edicao);
  // a flag evita recursao, porque mudar o Text dispara o OnChange de novo.
  if FFormatando or not EdtDocumento.Focused or not (Qry.State in dsEditModes) then
    Exit;
  FFormatando := True;
  try
    EdtDocumento.Text := FormatarDocumento(Copy(SomenteDigitos(EdtDocumento.Text), 1, 14));
    EdtDocumento.SelStart := Length(EdtDocumento.Text);
  finally
    FFormatando := False;
  end;
end;

procedure TFrmEntidades.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(Qry);
end;

procedure TFrmEntidades.QryNewRecord(DataSet: TDataSet);
begin
  // Valores iniciais de um registro novo
  DataSet.FieldByName('eh_cliente').AsInteger := 0;
  DataSet.FieldByName('eh_fornecedor').AsInteger := 0;
end;

procedure TFrmEntidades.QryBeforePost(DataSet: TDataSet);
var
  Digitos: string;
begin
  if Trim(DataSet.FieldByName('nome').AsString) = '' then
    raise Exception.Create('Informe o nome.');

  if (DataSet.FieldByName('eh_cliente').AsInteger = 0) and
     (DataSet.FieldByName('eh_fornecedor').AsInteger = 0) then
    raise Exception.Create('Marque se é cliente, fornecedor ou os dois.');

  // Documento vazio vira NULL, senao dois registros sem documento violariam o UNIQUE
  Digitos := SomenteDigitos(DataSet.FieldByName('documento').AsString);
  if Digitos = '' then
    DataSet.FieldByName('documento').Clear
  else
  begin
    if (Length(Digitos) <> 11) and (Length(Digitos) <> 14) then
      raise Exception.Create('O CPF tem 11 dígitos e o CNPJ, 14.');
    if not DocumentoValido(Digitos) then
      raise Exception.Create('CPF/CNPJ inválido: os dígitos verificadores não conferem.');
    DataSet.FieldByName('documento').AsString := FormatarDocumento(Digitos);
  end;
end;

procedure TFrmEntidades.QryBeforeDelete(DataSet: TDataSet);
begin
  ConfirmarExclusao;
end;

procedure TFrmEntidades.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort; // mantem a edicao aberta para o usuario corrigir
  ShowMessage(MensagemErroBanco(E));
end;

end.
