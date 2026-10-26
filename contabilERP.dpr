program contabilERP;

uses
  Vcl.Forms,
  FireDAC.VCLUI.Wait,
  uDM in 'src\dados\uDM.pas' {DM: TDataModule},
  uFrmPrincipal in 'src\uFrmPrincipal.pas' {FrmPrincipal},
  uAutenticacaoService in 'src\servicos\uAutenticacaoService.pas',
  uLancamentoService in 'src\servicos\uLancamentoService.pas',
  uSessao in 'src\servicos\uSessao.pas',
  uSaldo in 'src\dominio\uSaldo.pas',
  uFrmContas in 'src\telas\uFrmContas.pas' {FrmContas},
  uFrmEntidades in 'src\telas\uFrmEntidades.pas' {FrmEntidades},
  uFrmItens in 'src\telas\uFrmItens.pas' {FrmItens},
  uFrmLocais in 'src\telas\uFrmLocais.pas' {FrmLocais},
  uFrmLogin in 'src\telas\uFrmLogin.pas' {FrmLogin},
  uFrmUnidades in 'src\telas\uFrmUnidades.pas' {FrmUnidades},
  uTelaUtil in 'src\telas\uTelaUtil.pas',
  uContasPadrao in 'src\dominio\uContasPadrao.pas',
  uMovimentoService in 'src\servicos\uMovimentoService.pas',
  uConsultaService in 'src\servicos\uConsultaService.pas',
  uCenariosDemo in 'src\servicos\uCenariosDemo.pas',
  uRelBalancete in 'src\relatorios\uRelBalancete.pas',
  uFrmLancamento in 'src\telas\uFrmLancamento.pas' {FrmLancamento},
  uFrmMovimento in 'src\telas\uFrmMovimento.pas' {FrmMovimento},
  uFrmRazonete in 'src\telas\uFrmRazonete.pas' {FrmRazonete},
  uFrmBalancete in 'src\telas\uFrmBalancete.pas' {FrmBalancete},
  uFrmResumo in 'src\telas\uFrmResumo.pas' {FrmResumo},
  uFrmSaldoEstoque in 'src\telas\uFrmSaldoEstoque.pas' {FrmSaldoEstoque},
  uDocumento in 'src\dominio\uDocumento.pas',
  uFrmVeiculos in 'src\telas\uFrmVeiculos.pas' {FrmVeiculos},
  uFrmDiario in 'src\telas\uFrmDiario.pas' {FrmDiario},
  uFrmCustoVeiculo in 'src\telas\uFrmCustoVeiculo.pas' {FrmCustoVeiculo},
  uFrmUsuarios in 'src\telas\uFrmUsuarios.pas' {FrmUsuarios},
  uFrmHistoricoMovimentos in 'src\telas\uFrmHistoricoMovimentos.pas' {FrmHistoricoMovimentos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  // So o DataModule e a tela principal nascem com o programa.
  // As demais telas sao criadas sob demanda (TFrmXxx.Executar).
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
