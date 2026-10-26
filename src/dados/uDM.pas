unit uDM;

{ DataModule de dados: concentra a conexao com o banco.
  Formularios e servicos usam DM.Conexao; nenhum deles abre conexao propria.
  O "cursor de espera" do FireDAC NAO fica aqui: cada programa escolhe o seu
  (FireDAC.VCLUI.Wait no app, FireDAC.ConsoleUI.Wait no projeto de testes). }

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.ExprFuncs,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.DApt, FireDAC.Comp.Client, FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands;

type
  TDM = class(TDataModule)
    Conexao: TFDConnection;
    SQLiteDriverLink: TFDPhysSQLiteDriverLink;
  private
    procedure ExecutarScript(const AArquivo: string);
    function BancoVazio: Boolean;
    procedure CriarBanco;
  public
    { Abre o banco. Se ele estiver vazio, cria as tabelas e carrega o seed.
      Use ':memory:' para um banco temporario em memoria (testes). }
    procedure Conectar(const ACaminhoBanco: string);

    class function PastaRaiz: string;
    class function CaminhoBancoPadrao: string;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.Conectar(const ACaminhoBanco: string);
begin
  Conexao.Close;
  Conexao.Params.Database := ACaminhoBanco;
  Conexao.Open;

  // No SQLite as chaves estrangeiras vem DESLIGADAS por padrao
  Conexao.ExecSQL('PRAGMA foreign_keys = ON');

  if BancoVazio then
    CriarBanco;
end;

function TDM.BancoVazio: Boolean;
begin
  // sqlite_master e o "catalogo" do SQLite: lista as tabelas existentes
  Result := Conexao.ExecSQLScalar(
    'SELECT COUNT(*) FROM sqlite_master WHERE type = ''table'' AND name = ''conta''') = 0;
end;

procedure TDM.CriarBanco;
begin
  // Estrutura + dados iniciais numa unica transacao: ou cria tudo, ou nada
  Conexao.StartTransaction;
  try
    ExecutarScript(TPath.Combine(PastaRaiz, 'sql\schema.sql'));
    ExecutarScript(TPath.Combine(PastaRaiz, 'sql\seed.sql'));
    Conexao.Commit;
  except
    Conexao.Rollback;
    raise;
  end;
end;

procedure TDM.ExecutarScript(const AArquivo: string);
var
  Script: TFDScript;
begin
  if not TFile.Exists(AArquivo) then
    raise Exception.CreateFmt('Script não encontrado: %s', [AArquivo]);

  Script := TFDScript.Create(nil);
  try
    Script.Connection := Conexao;
    Script.ScriptOptions.BreakOnError := True;
    Script.ScriptOptions.FileEncoding := ecUTF8;
    Script.SQLScriptFileName := AArquivo;
    if (not Script.ExecuteAll) or (Script.TotalErrors > 0) then
      raise Exception.CreateFmt('Erro ao executar o script %s', [ExtractFileName(AArquivo)]);
  finally
    Script.Free;
  end;
end;

class function TDM.PastaRaiz: string;
var
  Pasta: string;
  Nivel: Integer;
begin
  // O .exe fica em Win32\Debug (ou testes\Win32\Debug): sobe ate achar a pasta "sql"
  Pasta := ExtractFilePath(ParamStr(0));
  for Nivel := 0 to 3 do
  begin
    if TDirectory.Exists(TPath.Combine(Pasta, 'sql')) then
      Exit(IncludeTrailingPathDelimiter(Pasta));
    Pasta := ExtractFilePath(ExcludeTrailingPathDelimiter(Pasta));
  end;
  raise Exception.Create('Pasta "sql" não encontrada perto do executável.');
end;

class function TDM.CaminhoBancoPadrao: string;
var
  Pasta: string;
begin
  Pasta := TPath.Combine(PastaRaiz, 'banco');
  TDirectory.CreateDirectory(Pasta);
  Result := TPath.Combine(Pasta, 'contabil.db');
end;

end.
