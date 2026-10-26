unit uFrmResumo;

{ Resumo patrimonial: Ativo, Passivo, PL, Receitas, Despesas, Lucro e a
  prova da equacao patrimonial Ativo = Passivo + PL. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFrmResumo = class(TForm)
    MemoResumo: TMemo;
    PnlRodape: TPanel;
    LblProva: TLabel;
    BtnAtualizar: TButton;
    BtnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
  private
    procedure Atualizar;
  public
    class procedure Executar;
  end;

var
  FrmResumo: TFrmResumo;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uConsultaService, uTelaUtil;

class procedure TFrmResumo.Executar;
var
  Form: TFrmResumo;
begin
  Sessao.Exigir('REL_CONTABEIS');
  Form := TFrmResumo.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmResumo.FormCreate(Sender: TObject);
begin
  Atualizar;
end;

function Linha(const ARotulo: string; const AValor: Currency): string;
begin
  // Fonte monoespacada (Consolas): o Format alinha as colunas
  Result := Format('%-40s %15s', [ARotulo, FormatarMoeda(AValor)]);
end;

procedure TFrmResumo.Atualizar;
var
  Consulta: TConsultaService;
  Resumo: TResumoPatrimonial;
  TextoResultado: string;
begin
  Consulta := TConsultaService.Create(DM.Conexao);
  try
    Resumo := Consulta.Resumo;
  finally
    Consulta.Free;
  end;

  if Resumo.Lucro >= 0 then
    TextoResultado := '  (=) Lucro do período'
  else
    TextoResultado := '  (=) Prejuízo do período';

  MemoResumo.Lines.BeginUpdate;
  try
    MemoResumo.Lines.Clear;
    MemoResumo.Lines.Add('BALANÇO');
    MemoResumo.Lines.Add(StringOfChar('-', 56));
    MemoResumo.Lines.Add(Linha('ATIVO', Resumo.Ativo));
    MemoResumo.Lines.Add(Linha('PASSIVO', Resumo.Passivo));
    MemoResumo.Lines.Add(Linha('PATRIMÔNIO LÍQUIDO (capital e reservas)', Resumo.PatrimonioLiquido));
    MemoResumo.Lines.Add(Linha('  (+) Resultado do período', Resumo.Lucro));
    MemoResumo.Lines.Add(Linha('  (=) PL com o resultado', Resumo.PLComResultado));
    MemoResumo.Lines.Add('');
    MemoResumo.Lines.Add('RESULTADO (o lucro vai para o PL)');
    MemoResumo.Lines.Add(StringOfChar('-', 56));
    MemoResumo.Lines.Add(Linha('  Receitas', Resumo.Receitas));
    MemoResumo.Lines.Add(Linha('  (-) Despesas', Resumo.Despesas));
    MemoResumo.Lines.Add(Linha(TextoResultado, Resumo.Lucro));
    MemoResumo.Lines.Add('');
    MemoResumo.Lines.Add('PROVA DA EQUAÇÃO PATRIMONIAL');
    MemoResumo.Lines.Add(StringOfChar('-', 56));
    MemoResumo.Lines.Add(Format('Ativo %s  =  Passivo %s  +  PL %s',
      [FormatarMoeda(Resumo.Ativo), FormatarMoeda(Resumo.Passivo), FormatarMoeda(Resumo.PLComResultado)]));
  finally
    MemoResumo.Lines.EndUpdate;
  end;

  if Resumo.Fecha then
  begin
    LblProva.Caption := '✓ Ativo = Passivo + PL';
    LblProva.Font.Color := clGreen;
  end
  else
  begin
    LblProva.Caption := '✗ A equação patrimonial não fechou';
    LblProva.Font.Color := clRed;
  end;
end;

procedure TFrmResumo.BtnAtualizarClick(Sender: TObject);
begin
  Atualizar;
end;

end.
