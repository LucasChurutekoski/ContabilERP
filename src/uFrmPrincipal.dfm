object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Cont'#225'bil ERP'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Position = poDesigned
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 15
  object StatusBar: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 414
    ExplicitWidth = 622
  end
  object MainMenu: TMainMenu
    Left = 40
    Top = 24
    object MnuCadastros: TMenuItem
      Caption = '&Cadastros'
      object MnuPlanoContas: TMenuItem
        Caption = 'Plano de contas'
        OnClick = MnuPlanoContasClick
      end
      object MnuEntidades: TMenuItem
        Caption = 'Clientes e fornecedores'
        OnClick = MnuEntidadesClick
      end
      object MnuItens: TMenuItem
        Caption = 'Itens e servi'#231'os'
        OnClick = MnuItensClick
      end
      object MnuLocais: TMenuItem
        Caption = 'Locais de estoque'
        OnClick = MnuLocaisClick
      end
      object MnuVeiculos: TMenuItem
        Caption = 'Ve'#237'culos da frota'
        OnClick = MnuVeiculosClick
      end
    end
    object MnuMovimentos: TMenuItem
      Caption = '&Movimentos'
      object MnuLancamento: TMenuItem
        Caption = 'Lan'#231'amento cont'#225'bil'
        OnClick = MnuLancamentoClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object MnuCompra: TMenuItem
        Caption = 'Compra'
        OnClick = MnuCompraClick
      end
      object MnuConsumo: TMenuItem
        Caption = 'Consumo'
        OnClick = MnuConsumoClick
      end
      object MnuTransferencia: TMenuItem
        Caption = 'Transfer'#234'ncia entre locais'
        OnClick = MnuTransferenciaClick
      end
      object MnuServico: TMenuItem
        Caption = 'Presta'#231#227'o de servi'#231'o'
        OnClick = MnuServicoClick
      end
      object MnuManutencao: TMenuItem
        Caption = 'Manuten'#231#227'o de ve'#237'culo'
        OnClick = MnuManutencaoClick
      end
    end
    object MnuConsultas: TMenuItem
      Caption = 'C&onsultas'
      object MnuSaldoEstoque: TMenuItem
        Caption = 'Saldo de estoque'
        OnClick = MnuSaldoEstoqueClick
      end
      object MnuCustoVeiculo: TMenuItem
        Caption = 'Custo de manuten'#231#227'o por ve'#237'culo'
        OnClick = MnuCustoVeiculoClick
      end
      object MnuHistoricoMovimentos: TMenuItem
        Caption = 'Hist'#243'rico de movimentos (kardex)'
        OnClick = MnuHistoricoMovimentosClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MnuDiario: TMenuItem
        Caption = 'Di'#225'rio (lan'#231'amentos por per'#237'odo)'
        OnClick = MnuDiarioClick
      end
      object MnuRazonete: TMenuItem
        Caption = 'Razonete'
        OnClick = MnuRazoneteClick
      end
      object MnuBalancete: TMenuItem
        Caption = 'Balancete de verifica'#231#227'o'
        OnClick = MnuBalanceteClick
      end
      object MnuResumo: TMenuItem
        Caption = 'Resumo patrimonial'
        OnClick = MnuResumoClick
      end
    end
    object MnuSistema: TMenuItem
      Caption = '&Sistema'
      object MnuUsuarios: TMenuItem
        Caption = 'Usu'#225'rios e permiss'#245'es'
        OnClick = MnuUsuariosClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object MnuDemonstracao: TMenuItem
        Caption = 'Demonstra'#231#227'o'
        object MnuZerarMovimentos: TMenuItem
          Caption = 'Zerar movimentos'
          OnClick = MnuZerarMovimentosClick
        end
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object MnuTrocarUsuario: TMenuItem
        Caption = 'Trocar usu'#225'rio'
        OnClick = MnuTrocarUsuarioClick
      end
      object MnuSair: TMenuItem
        Caption = 'Sair'
        OnClick = MnuSairClick
      end
    end
  end
end
