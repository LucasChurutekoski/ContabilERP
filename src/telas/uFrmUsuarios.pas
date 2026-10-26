unit uFrmUsuarios;

{ Gerenciamento de usuarios e permissoes (so o Administrador).
  Modelo RBAC: o usuario tem UM perfil; o perfil tem VARIAS permissoes.
  Ex.: perfil "Comprador" = MOV_COMPRA + EST_CONSULTAR, e o usuario X recebe esse perfil. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Mask,
  Vcl.DBCtrls, Vcl.CheckLst, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmUsuarios = class(TForm)
    PageControl: TPageControl;
    TabUsuarios: TTabSheet;
    NavUsuarios: TDBNavigator;
    GradeUsuarios: TDBGrid;
    PnlUsuario: TPanel;
    LblLogin: TLabel;
    EdtLogin: TDBEdit;
    LblNome: TLabel;
    EdtNome: TDBEdit;
    LblPerfil: TLabel;
    CbPerfil: TDBLookupComboBox;
    ChkAtivo: TDBCheckBox;
    LblSenha: TLabel;
    EdtSenha: TEdit;
    LblDicaSenha: TLabel;
    TabPerfis: TTabSheet;
    NavPerfis: TDBNavigator;
    GradePerfis: TDBGrid;
    PnlPermissoes: TPanel;
    LblNomePerfil: TLabel;
    EdtNomePerfil: TDBEdit;
    LblPermissoes: TLabel;
    ChkPermissoes: TCheckListBox;
    PnlBotoesPermissoes: TPanel;
    BtnSalvarPermissoes: TButton;
    LblAviso: TLabel;
    PnlRodape: TPanel;
    BtnFechar: TButton;
    QryUsuarios: TFDQuery;
    DsUsuarios: TDataSource;
    QryPerfis: TFDQuery;
    DsPerfis: TDataSource;
    QryPerfisLista: TFDQuery;
    DsPerfisLista: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DsUsuariosStateChange(Sender: TObject);
    procedure QryUsuariosNewRecord(DataSet: TDataSet);
    procedure QryUsuariosBeforePost(DataSet: TDataSet);
    procedure QryUsuariosAfterPost(DataSet: TDataSet);
    procedure QryUsuariosBeforeDelete(DataSet: TDataSet);
    procedure QryPerfisBeforePost(DataSet: TDataSet);
    procedure QryPerfisAfterPost(DataSet: TDataSet);
    procedure QryPerfisAfterScroll(DataSet: TDataSet);
    procedure QryPerfisBeforeDelete(DataSet: TDataSet);
    procedure QryPerfisAfterDelete(DataSet: TDataSet);
    procedure QryPerfisDeleteError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure BtnSalvarPermissoesClick(Sender: TObject);
  private
    FCodigos: TStringList; // codigo da permissao de cada linha do ChkPermissoes
    procedure CarregarListaPermissoes;
    procedure CarregarPermissoesDoPerfil;
  public
    class procedure Executar;
  end;

var
  FrmUsuarios: TFrmUsuarios;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil, uAutenticacaoService;

const
  TAMANHO_MINIMO_SENHA = 4;

class procedure TFrmUsuarios.Executar;
var
  Form: TFrmUsuarios;
begin
  Sessao.Exigir('USU_GERENCIAR');
  Form := TFrmUsuarios.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmUsuarios.FormCreate(Sender: TObject);
begin
  FCodigos := TStringList.Create;
  CarregarListaPermissoes;

  QryPerfisLista.Connection := DM.Conexao;
  QryPerfisLista.Open;
  QryUsuarios.Connection := DM.Conexao;
  QryUsuarios.Open;
  QryPerfis.Connection := DM.Conexao;
  QryPerfis.Open; // o AfterScroll ja marca as permissoes do primeiro perfil

  ConfigurarCadastro(DsUsuarios, GradeUsuarios, EdtLogin);
  ConfigurarCadastro(DsPerfis, GradePerfis, EdtNomePerfil);
  EdtSenha.Enabled := False;
  PageControl.ActivePage := TabUsuarios;
end;

procedure TFrmUsuarios.FormDestroy(Sender: TObject);
begin
  FCodigos.Free;
end;

procedure TFrmUsuarios.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(QryUsuarios) and ConfirmarAlteracoesPendentes(QryPerfis);
end;

{ ---------------- Usuarios ---------------- }

procedure TFrmUsuarios.DsUsuariosStateChange(Sender: TObject);
begin
  // A senha so pode ser digitada durante inclusao/edicao do usuario
  EdtSenha.Enabled := QryUsuarios.State in dsEditModes;
  if not EdtSenha.Enabled then
    EdtSenha.Clear;
end;

procedure TFrmUsuarios.QryUsuariosNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ativo').AsInteger := 1;
end;

procedure TFrmUsuarios.QryUsuariosBeforePost(DataSet: TDataSet);
var
  Salt: string;
begin
  DataSet.FieldByName('login').AsString := LowerCase(Trim(DataSet.FieldByName('login').AsString));
  if DataSet.FieldByName('login').AsString = '' then
    raise Exception.Create('Informe o login.');
  if Trim(DataSet.FieldByName('nome').AsString) = '' then
    raise Exception.Create('Informe o nome do usuário.');
  if DataSet.FieldByName('id_perfil').IsNull then
    raise Exception.Create('Escolha o perfil (ele define as permissões).');

  if EdtSenha.Text <> '' then
  begin
    if Length(EdtSenha.Text) < TAMANHO_MINIMO_SENHA then
      raise Exception.CreateFmt('A senha deve ter pelo menos %d caracteres.', [TAMANHO_MINIMO_SENHA]);
    // Nunca gravamos a senha: so o salt novo e o hash de salt + senha
    Salt := TAutenticacaoService.GerarSalt;
    DataSet.FieldByName('salt').AsString := Salt;
    DataSet.FieldByName('senha_hash').AsString := TAutenticacaoService.HashSenha(Salt, EdtSenha.Text);
  end
  else if DataSet.State = dsInsert then
    raise Exception.Create('Informe a senha do novo usuário.');

  if (DataSet.FieldByName('id').AsInteger = Sessao.IdUsuario) and
     (DataSet.FieldByName('ativo').AsInteger = 0) then
    raise Exception.Create('Você não pode inativar o seu próprio usuário.');
end;

procedure TFrmUsuarios.QryUsuariosAfterPost(DataSet: TDataSet);
begin
  EdtSenha.Clear;
end;

procedure TFrmUsuarios.QryUsuariosBeforeDelete(DataSet: TDataSet);
begin
  if DataSet.FieldByName('id').AsInteger = Sessao.IdUsuario then
    raise Exception.Create('Você não pode excluir o seu próprio usuário.');
  ConfirmarExclusao;
end;

procedure TFrmUsuarios.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E) + sLineBreak +
    'Dica: um usuário que já fez lançamentos não pode ser excluído; desmarque "Ativo".');
end;

{ ---------------- Perfis e permissoes ---------------- }

procedure TFrmUsuarios.CarregarListaPermissoes;
var
  Query: TFDQuery;
begin
  ChkPermissoes.Items.Clear;
  FCodigos.Clear;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DM.Conexao;
    Query.Open('SELECT codigo, descricao FROM permissao ORDER BY codigo');
    while not Query.Eof do
    begin
      FCodigos.Add(Query.FieldByName('codigo').AsString);
      ChkPermissoes.Items.Add(Query.FieldByName('descricao').AsString +
        '   (' + Query.FieldByName('codigo').AsString + ')');
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TFrmUsuarios.CarregarPermissoesDoPerfil;
var
  Query: TFDQuery;
  I: Integer;
begin
  for I := 0 to ChkPermissoes.Items.Count - 1 do
    ChkPermissoes.Checked[I] := False;
  if QryPerfis.IsEmpty or QryPerfis.FieldByName('id').IsNull then
    Exit; // perfil novo, ainda sem id

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DM.Conexao;
    Query.SQL.Text := 'SELECT codigo_permissao FROM perfil_permissao WHERE id_perfil = :id_perfil';
    Query.ParamByName('id_perfil').AsInteger := QryPerfis.FieldByName('id').AsInteger;
    Query.Open;
    while not Query.Eof do
    begin
      I := FCodigos.IndexOf(Query.FieldByName('codigo_permissao').AsString);
      if I >= 0 then
        ChkPermissoes.Checked[I] := True;
      Query.Next;
    end;
  finally
    Query.Free;
  end;
  LblNomePerfil.Caption := 'Nome do perfil';
end;

procedure TFrmUsuarios.QryPerfisAfterScroll(DataSet: TDataSet);
begin
  // Mudou o perfil selecionado: mostra as permissoes dele
  if Assigned(FCodigos) then
    CarregarPermissoesDoPerfil;
end;

procedure TFrmUsuarios.QryPerfisBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('nome').AsString := Trim(DataSet.FieldByName('nome').AsString);
  if DataSet.FieldByName('nome').AsString = '' then
    raise Exception.Create('Informe o nome do perfil (ex.: Comprador).');
end;

procedure TFrmUsuarios.QryPerfisAfterPost(DataSet: TDataSet);
begin
  QryPerfisLista.Refresh; // o perfil novo aparece no combo da aba Usuarios
  CarregarPermissoesDoPerfil;
end;

procedure TFrmUsuarios.QryPerfisBeforeDelete(DataSet: TDataSet);
var
  IdPerfil: Integer;
begin
  IdPerfil := DataSet.FieldByName('id').AsInteger;
  if SameText(DataSet.FieldByName('nome').AsString, Sessao.Perfil) then
    raise Exception.Create('Você não pode excluir o seu próprio perfil.');
  if DM.Conexao.ExecSQLScalar('SELECT COUNT(*) FROM usuario WHERE id_perfil = :id', [IdPerfil]) > 0 then
    raise Exception.Create('Há usuários neste perfil: troque o perfil deles antes de excluir.');
  ConfirmarExclusao;
  // Apaga as permissoes e o perfil juntos: a transacao fecha no AfterDelete
  DM.Conexao.StartTransaction;
  DM.Conexao.ExecSQL('DELETE FROM perfil_permissao WHERE id_perfil = :id', [IdPerfil]);
end;

procedure TFrmUsuarios.QryPerfisAfterDelete(DataSet: TDataSet);
begin
  if DM.Conexao.InTransaction then
    DM.Conexao.Commit;
  QryPerfisLista.Refresh;
end;

procedure TFrmUsuarios.QryPerfisDeleteError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  if DM.Conexao.InTransaction then
    DM.Conexao.Rollback;
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E));
end;

procedure TFrmUsuarios.BtnSalvarPermissoesClick(Sender: TObject);
var
  IdPerfil, I: Integer;
begin
  if QryPerfis.State in dsEditModes then
    QryPerfis.Post;
  if QryPerfis.IsEmpty then
    raise Exception.Create('Cadastre um perfil primeiro (botão + acima).');

  // Protecao contra "se trancar para fora": o admin nao tira de si mesmo o acesso a esta tela
  if SameText(QryPerfis.FieldByName('nome').AsString, Sessao.Perfil) and
     not ChkPermissoes.Checked[FCodigos.IndexOf('USU_GERENCIAR')] then
    raise Exception.Create('Você não pode remover do seu próprio perfil a permissão de gerenciar usuários.');

  IdPerfil := QryPerfis.FieldByName('id').AsInteger;
  DM.Conexao.StartTransaction;
  try
    DM.Conexao.ExecSQL('DELETE FROM perfil_permissao WHERE id_perfil = :id', [IdPerfil]);
    for I := 0 to ChkPermissoes.Items.Count - 1 do
      if ChkPermissoes.Checked[I] then
        DM.Conexao.ExecSQL('INSERT INTO perfil_permissao (id_perfil, codigo_permissao) VALUES (:id, :codigo)',
          [IdPerfil, FCodigos[I]]);
    DM.Conexao.Commit;
  except
    DM.Conexao.Rollback;
    raise;
  end;
  ShowMessage(Format('Permissões do perfil "%s" salvas.' + sLineBreak +
    'Elas valem a partir do próximo login (ou de "Trocar usuário").', [QryPerfis.FieldByName('nome').AsString]));
end;

end.
