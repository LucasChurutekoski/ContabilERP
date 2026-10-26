unit uFrmLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Comp.Client;

type
  TFrmLogin = class(TForm)
    LblUsuario: TLabel;
    EdtUsuario: TEdit;
    LblSenha: TLabel;
    EdtSenha: TEdit;
    LblErro: TLabel;
    BtnEntrar: TButton;
    BtnCancelar: TButton;
    procedure BtnEntrarClick(Sender: TObject);
  private
    FConexao: TFDConnection;
    FTentativas: Integer;
  public
    { Mostra o login. Devolve True se alguem entrou (uSessao.Sessao preenchida). }
    class function Executar(AConexao: TFDConnection): Boolean;
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

uses
  uSessao, uAutenticacaoService;

const
  MAX_TENTATIVAS = 3;

class function TFrmLogin.Executar(AConexao: TFDConnection): Boolean;
var
  Form: TFrmLogin;
begin
  Form := TFrmLogin.Create(nil);
  try
    Form.FConexao := AConexao;
    Result := Form.ShowModal = mrOk;
  finally
    Form.Free;
  end;
end;

procedure TFrmLogin.BtnEntrarClick(Sender: TObject);
var
  Servico: TAutenticacaoService;
  NovaSessao: TSessao;
begin
  Servico := TAutenticacaoService.Create(FConexao);
  try
    try
      NovaSessao := Servico.Autenticar(EdtUsuario.Text, EdtSenha.Text);
      Sessao.Free;          // troca de usuario: descarta a sessao anterior
      Sessao := NovaSessao;
      ModalResult := mrOk;  // fecha o ShowModal devolvendo mrOk
    except
      on E: EAutenticacao do
      begin
        Inc(FTentativas);
        LblErro.Caption := E.Message;
        EdtSenha.Clear;
        EdtSenha.SetFocus;
        if FTentativas >= MAX_TENTATIVAS then
        begin
          ShowMessage('Número máximo de tentativas atingido.');
          ModalResult := mrCancel;
        end;
      end;
    end;
  finally
    Servico.Free;
  end;
end;

end.
