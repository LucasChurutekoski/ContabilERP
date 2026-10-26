object FrmCustoVeiculo: TFrmCustoVeiculo
  Left = 0
  Top = 0
  Caption = 'Custo de manuten'#231#227'o por ve'#237'culo'
  ClientHeight = 560
  ClientWidth = 860
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object LblVeiculos: TLabel
    Left = 0
    Top = 0
    Width = 860
    Height = 24
    Align = alTop
    AutoSize = False
    Caption = '  Ve'#237'culos (clique num ve'#237'culo para ver as manuten'#231#245'es)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object LblItens: TLabel
    Left = 0
    Top = 224
    Width = 860
    Height = 24
    Align = alTop
    AutoSize = False
    Caption = '  Pe'#231'as e m'#227'o de obra do ve'#237'culo selecionado'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object GradeVeiculos: TDBGrid
    Left = 0
    Top = 24
    Width = 860
    Height = 200
    Align = alTop
    DataSource = DsVeiculos
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object GradeItens: TDBGrid
    Left = 0
    Top = 248
    Width = 860
    Height = 256
    Align = alClient
    DataSource = DsItens
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object PnlRodape: TPanel
    Left = 0
    Top = 504
    Width = 860
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object BtnAtualizar: TButton
      Left = 660
      Top = 14
      Width = 96
      Height = 27
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = BtnAtualizarClick
    end
    object BtnFechar: TButton
      Left = 764
      Top = 14
      Width = 84
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object QryVeiculos: TFDQuery
    Left = 760
    Top = 64
  end
  object DsVeiculos: TDataSource
    DataSet = QryVeiculos
    Left = 760
    Top = 120
  end
  object QryItens: TFDQuery
    Left = 760
    Top = 296
  end
  object DsItens: TDataSource
    DataSet = QryItens
    Left = 760
    Top = 352
  end
end
