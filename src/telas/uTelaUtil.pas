unit uTelaUtil;

{ Rotinas reaproveitadas pelas telas de cadastro. }

interface

uses
  System.SysUtils, System.Classes, Data.DB, Vcl.Controls, Vcl.DBGrids;

{ Padrao das telas de cadastro:
  - AutoEdit desligado: so edita depois de clicar em "+" (incluir) ou no triangulo (editar);
  - a grade fica bloqueada durante a inclusao/edicao (clicar nela descartaria o registro novo);
  - ao incluir/editar, o cursor vai direto para o primeiro campo. }
procedure ConfigurarCadastro(ADataSource: TDataSource; AGrade: TDBGrid; APrimeiroCampo: TWinControl);

// Traduz erros do banco (UNIQUE, FOREIGN KEY, CHECK) para mensagens amigaveis
function MensagemErroBanco(E: Exception): string;

// Ao fechar a tela com edicao pendente: pergunta se salva. False = nao fechar.
function ConfirmarAlteracoesPendentes(ADataSet: TDataSet): Boolean;

// Pergunta antes de excluir; se o usuario disser nao, cancela com Abort
procedure ConfirmarExclusao;

// Le um valor digitado como "1.234,56", "1234,56" ou "1234.56"
function LerValor(const ATexto: string; out AValor: Currency): Boolean;
function LerQuantidade(const ATexto: string; out AQuantidade: Double): Boolean;

// Mostra um campo em centavos (inteiro) como reais, sem mudar o dado
procedure FormatarCentavos(ACampo: TField);

function FormatarMoeda(const AValor: Currency): string;

implementation

uses
  System.UITypes, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Error;

type
  // Componente "invisivel" pendurado no form: e liberado junto com ele (Owner)
  TControleCadastro = class(TComponent)
  private
    FDataSource: TDataSource;
    FGrade: TDBGrid;
    FPrimeiroCampo: TWinControl;
    FStateChangeOriginal: TNotifyEvent;
    procedure StateChange(Sender: TObject);
  end;

procedure TControleCadastro.StateChange(Sender: TObject);
var
  Editando: Boolean;
  Campo: TWinControl;
begin
  if Assigned(FStateChangeOriginal) then
    FStateChangeOriginal(Sender);
  if FDataSource.DataSet = nil then
    Exit;
  Editando := FDataSource.DataSet.State in dsEditModes;
  FGrade.Enabled := not Editando;

  // O foco so muda DEPOIS que o Insert/Edit terminar (ForceQueue agenda para
  // o proximo ciclo de mensagens). Mudar o foco no meio do Insert dispara
  // eventos de saida de outros controles enquanto o registro ainda esta nascendo.
  if Editando and Assigned(FPrimeiroCampo) then
  begin
    Campo := FPrimeiroCampo;
    TThread.ForceQueue(nil,
      procedure
      begin
        if Campo.CanFocus then
          Campo.SetFocus;
      end);
  end;
end;

procedure ConfigurarCadastro(ADataSource: TDataSource; AGrade: TDBGrid; APrimeiroCampo: TWinControl);
var
  Controle: TControleCadastro;
begin
  Controle := TControleCadastro.Create(ADataSource.Owner);
  Controle.FDataSource := ADataSource;
  Controle.FGrade := AGrade;
  Controle.FPrimeiroCampo := APrimeiroCampo;
  Controle.FStateChangeOriginal := ADataSource.OnStateChange;
  ADataSource.AutoEdit := False;
  ADataSource.OnStateChange := Controle.StateChange;
end;

function MensagemErroBanco(E: Exception): string;
begin
  if E is EFDDBEngineException then
    case EFDDBEngineException(E).Kind of
      ekUKViolated:
        Exit('Já existe um registro com este código ou documento.');
      ekFKViolated:
        Exit('Este registro é usado em outro cadastro ou movimento e não pode ser excluído.');
    end;

  // Alguns erros do SQLite chegam como "ekOther": identifica pelo texto
  if Pos('UNIQUE constraint', E.Message) > 0 then
    Result := 'Já existe um registro com este código ou documento.'
  else if Pos('FOREIGN KEY constraint', E.Message) > 0 then
    Result := 'Este registro é usado em outro cadastro ou movimento e não pode ser excluído.'
  else if Pos('CHECK constraint', E.Message) > 0 then
    Result := 'Dados inválidos: ' + Copy(E.Message, Pos('CHECK constraint', E.Message), MaxInt)
  else
    Result := E.Message;
end;

function ConfirmarAlteracoesPendentes(ADataSet: TDataSet): Boolean;
begin
  Result := True;
  if not (ADataSet.State in dsEditModes) then
    Exit;

  case MessageDlg('Há alterações não salvas. Deseja salvar antes de fechar?',
         mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: ADataSet.Post;   // se falhar, a excecao impede o fechamento
    mrNo:  ADataSet.Cancel;
  else
    Result := False;
  end;
end;

procedure ConfirmarExclusao;
begin
  if MessageDlg('Excluir o registro selecionado?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Abort; // excecao "silenciosa": interrompe o Delete sem mostrar erro
end;

function NormalizarNumero(const ATexto: string): string;
var
  Config: TFormatSettings;
begin
  Config := TFormatSettings.Create;
  Result := Trim(ATexto);
  if Pos(',', Result) > 0 then
    Result := StringReplace(Result, '.', '', [rfReplaceAll])   // "1.234,56": ponto e milhar
  else
    Result := StringReplace(Result, '.', ',', [rfReplaceAll]); // "1234.56": ponto e decimal
  Result := StringReplace(Result, ',', Config.DecimalSeparator, [rfReplaceAll]);
end;

function LerValor(const ATexto: string; out AValor: Currency): Boolean;
begin
  Result := TryStrToCurr(NormalizarNumero(ATexto), AValor);
end;

function LerQuantidade(const ATexto: string; out AQuantidade: Double): Boolean;
begin
  Result := TryStrToFloat(NormalizarNumero(ATexto), AQuantidade);
end;

function FormatarMoeda(const AValor: Currency): string;
begin
  Result := FormatFloat('#,##0.00', AValor);
end;

type
  // Metodo de classe pode ser ligado a eventos "of object" (como o OnGetText)
  TFormatador = class
    class procedure CentavosGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  end;

class procedure TFormatador.CentavosGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := FormatarMoeda(Sender.AsFloat / 100);
end;

procedure FormatarCentavos(ACampo: TField);
begin
  ACampo.OnGetText := TFormatador.CentavosGetText;
  ACampo.Alignment := taRightJustify;
end;

end.
