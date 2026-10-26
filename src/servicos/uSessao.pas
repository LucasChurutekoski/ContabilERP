unit uSessao;

{ Usuario logado e suas permissoes.
  Criada pelo servico de autenticacao no login e consultada por telas
  (habilitar menus) e servicos (barrar operacoes sem permissao). }

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  EAcessoNegado = class(Exception);

  TSessao = class
  private
    FIdUsuario: Integer;
    FLogin: string;
    FNome: string;
    FPerfil: string;
    FPermissoes: TList<string>;
  public
    constructor Create(AIdUsuario: Integer; const ALogin, ANome, APerfil: string;
      const APermissoes: TArray<string>);
    destructor Destroy; override;

    function Pode(const APermissao: string): Boolean;
    procedure Exigir(const APermissao: string);

    property IdUsuario: Integer read FIdUsuario;
    property Login: string read FLogin;
    property Nome: string read FNome;
    property Perfil: string read FPerfil;
  end;

var
  // Sessao atual do aplicativo (nil enquanto ninguem fez login)
  Sessao: TSessao;

implementation

constructor TSessao.Create(AIdUsuario: Integer; const ALogin, ANome, APerfil: string;
  const APermissoes: TArray<string>);
begin
  inherited Create;
  FIdUsuario := AIdUsuario;
  FLogin := ALogin;
  FNome := ANome;
  FPerfil := APerfil;
  FPermissoes := TList<string>.Create;
  FPermissoes.AddRange(APermissoes);
end;

destructor TSessao.Destroy;
begin
  FPermissoes.Free;
  inherited;
end;

function TSessao.Pode(const APermissao: string): Boolean;
begin
  Result := FPermissoes.Contains(APermissao);
end;

procedure TSessao.Exigir(const APermissao: string);
begin
  if not Pode(APermissao) then
    raise EAcessoNegado.CreateFmt('O perfil %s não tem a permissão %s.', [FPerfil, APermissao]);
end;

initialization

finalization
  Sessao.Free;

end.
