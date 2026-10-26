unit uAutenticacaoService;

{ Login: confere usuario e senha e monta a sessao com as permissoes do perfil.
  A senha nunca e gravada: guardamos SHA-256(salt + senha) e comparamos hashes. }

interface

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Param, FireDAC.Comp.Client, uSessao;

type
  EAutenticacao = class(Exception);

  TAutenticacaoService = class
  private
    FConexao: TFDConnection;
    function CarregarPermissoes(AIdPerfil: Integer): TArray<string>;
  public
    constructor Create(AConexao: TFDConnection);

    class function HashSenha(const ASalt, ASenha: string): string;
    // Salt aleatorio novo (16 caracteres hexadecimais), um por usuario
    class function GerarSalt: string;

    { Devolve a sessao do usuario ou levanta EAutenticacao.
      Quem chama passa a ser dono do objeto devolvido. }
    function Autenticar(const ALogin, ASenha: string): TSessao;
  end;

implementation

uses
  System.Hash, System.Generics.Collections;

constructor TAutenticacaoService.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
end;

class function TAutenticacaoService.HashSenha(const ASalt, ASenha: string): string;
begin
  // O salt (aleatorio, um por usuario) faz senhas iguais gerarem hashes diferentes
  Result := THashSHA2.GetHashString(ASalt + ASenha);
end;

class function TAutenticacaoService.GerarSalt: string;
var
  Guid: string;
begin
  // Um GUID novo e aleatorio; tira chaves e tracos e usa os 16 primeiros caracteres
  Guid := TGUID.NewGuid.ToString;
  Guid := StringReplace(Guid, '{', '', []);
  Guid := StringReplace(Guid, '}', '', []);
  Guid := StringReplace(Guid, '-', '', [rfReplaceAll]);
  Result := LowerCase(Copy(Guid, 1, 16));
end;

function TAutenticacaoService.Autenticar(const ALogin, ASenha: string): TSessao;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text :=
      'SELECT u.id, u.login, u.nome, u.senha_hash, u.salt, u.ativo, u.id_perfil, p.nome AS perfil ' +
      'FROM usuario u JOIN perfil p ON p.id = u.id_perfil ' +
      'WHERE u.login = :login';
    Query.ParamByName('login').AsString := Trim(ALogin);
    Query.Open;

    // Mesma mensagem para "usuario nao existe" e "senha errada":
    // nao revelamos qual dos dois estava certo
    if Query.IsEmpty or
       not SameText(HashSenha(Query.FieldByName('salt').AsString, ASenha),
                    Query.FieldByName('senha_hash').AsString) then
      raise EAutenticacao.Create('Usuário ou senha inválidos.');

    if Query.FieldByName('ativo').AsInteger <> 1 then
      raise EAutenticacao.Create('Usuário inativo. Procure o administrador.');

    Result := TSessao.Create(
      Query.FieldByName('id').AsInteger,
      Query.FieldByName('login').AsString,
      Query.FieldByName('nome').AsString,
      Query.FieldByName('perfil').AsString,
      CarregarPermissoes(Query.FieldByName('id_perfil').AsInteger));
  finally
    Query.Free;
  end;
end;

function TAutenticacaoService.CarregarPermissoes(AIdPerfil: Integer): TArray<string>;
var
  Query: TFDQuery;
  Lista: TList<string>;
begin
  Lista := TList<string>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT codigo_permissao FROM perfil_permissao WHERE id_perfil = :id_perfil';
    Query.ParamByName('id_perfil').AsInteger := AIdPerfil;
    Query.Open;
    while not Query.Eof do
    begin
      Lista.Add(Query.FieldByName('codigo_permissao').AsString);
      Query.Next;
    end;
    Result := Lista.ToArray;
  finally
    Query.Free;
    Lista.Free;
  end;
end;

end.
