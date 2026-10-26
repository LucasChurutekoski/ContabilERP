unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus;

type
  TFrmPrincipal = class(TForm)
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    MnuCadastros: TMenuItem;
    MnuPlanoContas: TMenuItem;
    MnuEntidades: TMenuItem;
    MnuItens: TMenuItem;
    MnuLocais: TMenuItem;
    MnuVeiculos: TMenuItem;
    MnuMovimentos: TMenuItem;
    MnuLancamento: TMenuItem;
    N1: TMenuItem;
    MnuCompra: TMenuItem;
    MnuConsumo: TMenuItem;
    MnuTransferencia: TMenuItem;
    MnuServico: TMenuItem;
    MnuManutencao: TMenuItem;
    MnuConsultas: TMenuItem;
    MnuSaldoEstoque: TMenuItem;
    MnuCustoVeiculo: TMenuItem;
    MnuHistoricoMovimentos: TMenuItem;
    N2: TMenuItem;
    MnuDiario: TMenuItem;
    MnuRazonete: TMenuItem;
    MnuBalancete: TMenuItem;
    MnuResumo: TMenuItem;
    MnuSistema: TMenuItem;
    MnuUsuarios: TMenuItem;
    N4: TMenuItem;
    MnuDemonstracao: TMenuItem;
    MnuZerarMovimentos: TMenuItem;
    N3: TMenuItem;
    MnuTrocarUsuario: TMenuItem;
    MnuSair: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure MnuTrocarUsuarioClick(Sender: TObject);
    procedure MnuSairClick(Sender: TObject);
    procedure MnuPlanoContasClick(Sender: TObject);
    procedure MnuEntidadesClick(Sender: TObject);
    procedure MnuItensClick(Sender: TObject);
    procedure MnuLocaisClick(Sender: TObject);
    procedure MnuLancamentoClick(Sender: TObject);
    procedure MnuCompraClick(Sender: TObject);
    procedure MnuConsumoClick(Sender: TObject);
    procedure MnuTransferenciaClick(Sender: TObject);
    procedure MnuServicoClick(Sender: TObject);
    procedure MnuSaldoEstoqueClick(Sender: TObject);
    procedure MnuRazoneteClick(Sender: TObject);
    procedure MnuBalanceteClick(Sender: TObject);
    procedure MnuResumoClick(Sender: TObject);
    procedure MnuZerarMovimentosClick(Sender: TObject);
    procedure MnuVeiculosClick(Sender: TObject);
    procedure MnuManutencaoClick(Sender: TObject);
    procedure MnuCustoVeiculoClick(Sender: TObject);
    procedure MnuDiarioClick(Sender: TObject);
    procedure MnuUsuariosClick(Sender: TObject);
    procedure MnuHistoricoMovimentosClick(Sender: TObject);
  private
    procedure EncerrarSemMostrar;
    procedure AplicarPermissoes;
    procedure AtualizarStatus;
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses
  System.UITypes, uDM, uSessao, uMovimentoService, uCenariosDemo,
  uFrmLogin, uFrmEntidades, uFrmItens, uFrmLocais, uFrmContas,
  uFrmLancamento, uFrmMovimento, uFrmRazonete, uFrmBalancete, uFrmResumo, uFrmSaldoEstoque,
  uFrmVeiculos, uFrmDiario, uFrmCustoVeiculo, uFrmUsuarios, uFrmHistoricoMovimentos;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  // 1) Abre (ou cria) o banco. O DM ja existe: e o primeiro CreateForm do .dpr
  try
    DM.Conectar(TDM.CaminhoBancoPadrao);
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      EncerrarSemMostrar;
      Exit;
    end;
  end;

  // 2) A tela principal so aparece depois de um login valido
  if not TFrmLogin.Executar(DM.Conexao) then
  begin
    EncerrarSemMostrar;
    Exit;
  end;
  AplicarPermissoes;
end;

procedure TFrmPrincipal.EncerrarSemMostrar;
begin
  Application.ShowMainForm := False;
  Application.Terminate;
end;

procedure TFrmPrincipal.AplicarPermissoes;
begin
  // Desabilitar (e nao esconder) mostra ao usuario que a funcao existe.
  // A seguranca de verdade esta nos servicos (Sessao.Exigir).
  MnuPlanoContas.Enabled     := Sessao.Pode('CAD_CONTAS');
  MnuEntidades.Enabled       := Sessao.Pode('CAD_ENTIDADES');
  MnuItens.Enabled           := Sessao.Pode('CAD_ITENS');
  MnuLocais.Enabled          := Sessao.Pode('CAD_LOCAIS');
  MnuVeiculos.Enabled        := Sessao.Pode('CAD_VEICULOS');

  // Uma permissao por operacao (mesma regra que o servico usa)
  MnuLancamento.Enabled      := Sessao.Pode('LANC_INCLUIR');
  MnuCompra.Enabled          := Sessao.Pode(TMovimentoService.PermissaoOperacao(opCompra));
  MnuConsumo.Enabled         := Sessao.Pode(TMovimentoService.PermissaoOperacao(opConsumo));
  MnuTransferencia.Enabled   := Sessao.Pode(TMovimentoService.PermissaoOperacao(opTransferencia));
  MnuServico.Enabled         := Sessao.Pode(TMovimentoService.PermissaoOperacao(opServico));
  MnuManutencao.Enabled      := Sessao.Pode(TMovimentoService.PermissaoOperacao(opManutencao));

  MnuSaldoEstoque.Enabled    := Sessao.Pode('EST_CONSULTAR');
  MnuCustoVeiculo.Enabled    := Sessao.Pode('EST_CONSULTAR');
  MnuHistoricoMovimentos.Enabled := Sessao.Pode('EST_CONSULTAR');
  MnuDiario.Enabled          := Sessao.Pode('REL_CONTABEIS') or Sessao.Pode('LANC_INCLUIR');
  MnuRazonete.Enabled        := Sessao.Pode('REL_CONTABEIS');
  MnuBalancete.Enabled       := Sessao.Pode('REL_CONTABEIS');
  MnuResumo.Enabled          := Sessao.Pode('REL_CONTABEIS');

  MnuUsuarios.Enabled        := Sessao.Pode('USU_GERENCIAR');
  MnuDemonstracao.Enabled    := Sessao.Pode('USU_GERENCIAR');

  AtualizarStatus;
end;

procedure TFrmPrincipal.AtualizarStatus;
begin
  StatusBar.SimpleText := Format('Usuário: %s (%s)   |   Banco: %s',
    [Sessao.Nome, Sessao.Perfil, DM.Conexao.Params.Database]);
end;

procedure TFrmPrincipal.MnuTrocarUsuarioClick(Sender: TObject);
begin
  // Se cancelar, continua com o usuario atual
  if TFrmLogin.Executar(DM.Conexao) then
    AplicarPermissoes;
end;

procedure TFrmPrincipal.MnuSairClick(Sender: TObject);
begin
  Close;
end;

{ Cadastros }

procedure TFrmPrincipal.MnuPlanoContasClick(Sender: TObject);
begin
  TFrmContas.Executar;
end;

procedure TFrmPrincipal.MnuEntidadesClick(Sender: TObject);
begin
  TFrmEntidades.Executar;
end;

procedure TFrmPrincipal.MnuItensClick(Sender: TObject);
begin
  TFrmItens.Executar;
end;

procedure TFrmPrincipal.MnuLocaisClick(Sender: TObject);
begin
  TFrmLocais.Executar;
end;

{ Movimentos }

procedure TFrmPrincipal.MnuLancamentoClick(Sender: TObject);
begin
  TFrmLancamento.Executar;
end;

procedure TFrmPrincipal.MnuCompraClick(Sender: TObject);
begin
  TFrmMovimento.Executar(opCompra);
end;

procedure TFrmPrincipal.MnuConsumoClick(Sender: TObject);
begin
  TFrmMovimento.Executar(opConsumo);
end;

procedure TFrmPrincipal.MnuTransferenciaClick(Sender: TObject);
begin
  TFrmMovimento.Executar(opTransferencia);
end;

procedure TFrmPrincipal.MnuServicoClick(Sender: TObject);
begin
  TFrmMovimento.Executar(opServico);
end;

{ Consultas }

procedure TFrmPrincipal.MnuSaldoEstoqueClick(Sender: TObject);
begin
  TFrmSaldoEstoque.Executar;
end;

procedure TFrmPrincipal.MnuRazoneteClick(Sender: TObject);
begin
  TFrmRazonete.Executar;
end;

procedure TFrmPrincipal.MnuBalanceteClick(Sender: TObject);
begin
  TFrmBalancete.Executar;
end;

procedure TFrmPrincipal.MnuResumoClick(Sender: TObject);
begin
  TFrmResumo.Executar;
end;

{ Novos: frota, Diario e usuarios }

procedure TFrmPrincipal.MnuVeiculosClick(Sender: TObject);
begin
  TFrmVeiculos.Executar;
end;

procedure TFrmPrincipal.MnuManutencaoClick(Sender: TObject);
begin
  TFrmMovimento.Executar(opManutencao);
end;

procedure TFrmPrincipal.MnuCustoVeiculoClick(Sender: TObject);
begin
  TFrmCustoVeiculo.Executar;
end;

procedure TFrmPrincipal.MnuDiarioClick(Sender: TObject);
begin
  TFrmDiario.Executar;
end;

procedure TFrmPrincipal.MnuUsuariosClick(Sender: TObject);
begin
  TFrmUsuarios.Executar;
end;

procedure TFrmPrincipal.MnuHistoricoMovimentosClick(Sender: TObject);
begin
  TFrmHistoricoMovimentos.Executar;
end;

{ Demonstracao }


procedure TFrmPrincipal.MnuZerarMovimentosClick(Sender: TObject);
begin
  if MessageDlg('Apagar TODOS os lançamentos, movimentos e saldos de estoque?' + sLineBreak +
       'Os cadastros (contas, itens, locais, usuários) são mantidos.',
       mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ZerarMovimentos(DM.Conexao, Sessao);
  ShowMessage('Movimentos zerados. A numeração recomeça em 1.');
end;


end.
