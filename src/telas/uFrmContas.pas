unit uFrmContas;

{ Cadastro do plano de contas.
  Regras: conta filha herda o grupo do pai e tem codigo comecando pelo codigo
  do pai; sintetica com subcontas nao vira analitica e analitica com
  lancamentos nao vira sintetica. Tambem serve de "seletor" para outras telas. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Buttons;

type
  TFrmContas = class(TForm)
    Navegador: TDBNavigator;
    Grade: TDBGrid;
    PnlEdicao: TPanel;
    LblCodigo: TLabel;
    EdtCodigo: TDBEdit;
    LblNome: TLabel;
    EdtNome: TDBEdit;
    LblPai: TLabel;
    CbPai: TDBLookupComboBox;
    RgGrupo: TDBRadioGroup;
    RgTipo: TDBRadioGroup;
    RgNatureza: TDBRadioGroup;
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
  private
    procedure IdPaiChange(Sender: TField);
    procedure GrupoChange(Sender: TField);
    function Contar(const ASQL: string; AId: Integer): Integer;
  public
    { Abre posicionado em AIdConta e devolve o id da conta selecionada ao fechar. }
    class function Executar(AIdConta: Integer = 0): Integer;
  end;

var
  FrmContas: TFrmContas;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil;

function NaturezaPadrao(const AGrupo: string): string;
begin
  // Regra A-D-E: Ativo e Despesa sao devedoras; Passivo, PL e Receita, credoras
  if (AGrupo = 'A') or (AGrupo = 'D') then
    Result := 'D'
  else
    Result := 'C';
end;

class function TFrmContas.Executar(AIdConta: Integer): Integer;
var
  Form: TFrmContas;
begin
  Sessao.Exigir('CAD_CONTAS');
  Form := TFrmContas.Create(nil);
  try
    if AIdConta > 0 then
      Form.Qry.Locate('id', AIdConta, []);
    Form.ShowModal;
    Result := Form.Qry.FieldByName('id').AsInteger;
  finally
    Form.Free;
  end;
end;

procedure TFrmContas.FormCreate(Sender: TObject);
begin
  QryPais.Connection := DM.Conexao;
  QryPais.Open;
  Qry.Connection := DM.Conexao;
  Qry.Open;
  // Eventos de campo: reagem quando o usuario muda o pai ou o grupo
  Qry.FieldByName('id_pai').OnChange := IdPaiChange;
  Qry.FieldByName('grupo').OnChange := GrupoChange;
  ConfigurarCadastro(Ds, Grade, CbPai);
end;

procedure TFrmContas.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(Qry);
end;

procedure TFrmContas.QryNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('tipo').AsString := 'A';
end;

procedure TFrmContas.IdPaiChange(Sender: TField);
var
  CodigoPai: string;
begin
  if Sender.IsNull then
    Exit;
  // Filha herda o grupo do pai e, se o codigo estiver vazio, ganha o prefixo dele
  Qry.FieldByName('grupo').AsString := VarToStr(QryPais.Lookup('id', Sender.Value, 'grupo'));
  CodigoPai := VarToStr(QryPais.Lookup('id', Sender.Value, 'codigo'));
  if Trim(Qry.FieldByName('codigo').AsString) = '' then
    Qry.FieldByName('codigo').AsString := CodigoPai + '.';
end;

procedure TFrmContas.GrupoChange(Sender: TField);
begin
  // Sugere a natureza so em conta nova: em retificadoras o usuario pode inverter
  if Qry.State = dsInsert then
    Qry.FieldByName('natureza').AsString := NaturezaPadrao(Sender.AsString);
end;

function TFrmContas.Contar(const ASQL: string; AId: Integer): Integer;
begin
  Result := DM.Conexao.ExecSQLScalar(ASQL, [AId]);
end;

procedure TFrmContas.QryBeforePost(DataSet: TDataSet);
var
  Codigo, CodigoPai, GrupoPai: string;
  Id: Integer;
begin
  Codigo := Trim(DataSet.FieldByName('codigo').AsString);
  DataSet.FieldByName('codigo').AsString := Codigo;

  if Codigo = '' then
    raise Exception.Create('Informe o código da conta.');
  if Trim(DataSet.FieldByName('nome').AsString) = '' then
    raise Exception.Create('Informe o nome da conta.');
  if DataSet.FieldByName('grupo').AsString = '' then
    raise Exception.Create('Escolha o grupo da conta.');
  if DataSet.FieldByName('natureza').AsString = '' then
    raise Exception.Create('Escolha a natureza da conta.');

  if DataSet.FieldByName('id_pai').IsNull then
  begin
    if Pos('.', Codigo) > 0 then
      raise Exception.Create('Conta sem pai é uma conta raiz: o código não pode ter ponto (ex.: 1, 2, 3).');
  end
  else
  begin
    CodigoPai := VarToStr(QryPais.Lookup('id', DataSet.FieldByName('id_pai').Value, 'codigo'));
    GrupoPai := VarToStr(QryPais.Lookup('id', DataSet.FieldByName('id_pai').Value, 'grupo'));
    if (Codigo = CodigoPai + '.') or (Copy(Codigo, 1, Length(CodigoPai) + 1) <> CodigoPai + '.') then
      raise Exception.CreateFmt('O código deve começar por "%s." (código do pai) e ter um complemento.', [CodigoPai]);
    if DataSet.FieldByName('grupo').AsString <> GrupoPai then
      raise Exception.Create('A conta deve ser do mesmo grupo da conta pai.');
  end;

  // Mudancas de tipo em conta ja existente
  if not DataSet.FieldByName('id').IsNull then
  begin
    Id := DataSet.FieldByName('id').AsInteger;
    if DataSet.FieldByName('tipo').AsString = 'S' then
    begin
      if Contar('SELECT COUNT(*) FROM partida WHERE id_conta = :id', Id) > 0 then
        raise Exception.Create('Esta conta tem lançamentos: não pode virar sintética.');
      if Contar('SELECT COUNT(*) FROM item WHERE id_conta = :id', Id) > 0 then
        raise Exception.Create('Esta conta é usada por itens: não pode virar sintética.');
    end
    else if Contar('SELECT COUNT(*) FROM conta WHERE id_pai = :id', Id) > 0 then
      raise Exception.Create('Esta conta tem subcontas: só pode ser sintética.');
  end;
end;

procedure TFrmContas.QryAfterPost(DataSet: TDataSet);
begin
  // Uma nova sintetica precisa aparecer na lista de "conta pai"
  QryPais.Refresh;
end;

procedure TFrmContas.QryBeforeDelete(DataSet: TDataSet);
begin
  ConfirmarExclusao;
end;

procedure TFrmContas.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E));
end;

end.
