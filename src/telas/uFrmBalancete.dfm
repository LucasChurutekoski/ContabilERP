object FrmBalancete: TFrmBalancete
  Left = 0
  Top = 0
  Caption = 'Balancete de verifica'#231#227'o'
  ClientHeight = 520
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
  object Grade: TDBGrid
    Left = 0
    Top = 0
    Width = 860
    Height = 440
    Align = alClient
    DataSource = Ds
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object PnlRodape: TPanel
    Left = 0
    Top = 440
    Width = 860
    Height = 80
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object LblTotais: TLabel
      Left = 16
      Top = 12
      Width = 3
      Height = 17
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblSituacao: TLabel
      Left = 16
      Top = 44
      Width = 3
      Height = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnAtualizar: TButton
      Left = 508
      Top = 40
      Width = 96
      Height = 27
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = BtnAtualizarClick
    end
    object BtnImprimir: TButton
      Left = 612
      Top = 40
      Width = 140
      Height = 27
      Caption = 'Imprimir (FastReport)'
      TabOrder = 1
      OnClick = BtnImprimirClick
    end
    object BtnFechar: TButton
      Left = 760
      Top = 40
      Width = 84
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object Qry: TFDQuery
    Left = 760
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 760
    Top = 120
  end
end
