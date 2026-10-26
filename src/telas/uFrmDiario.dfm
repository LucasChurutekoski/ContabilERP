object FrmDiario: TFrmDiario
  Left = 0
  Top = 0
  Caption = 'Di'#225'rio - lan'#231'amentos por per'#237'odo'
  ClientHeight = 560
  ClientWidth = 960
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PnlFiltro: TPanel
    Left = 0
    Top = 0
    Width = 960
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LblDe: TLabel
      Left = 16
      Top = 18
      Width = 15
      Height = 15
      Caption = 'De'
    end
    object LblAte: TLabel
      Left = 180
      Top = 18
      Width = 18
      Height = 15
      Caption = 'At'#233
    end
    object DtpDe: TDateTimePicker
      Left = 40
      Top = 14
      Width = 120
      Height = 23
      Date = 46310.000000000000000000
      Time = 46310.000000000000000000
      TabOrder = 0
    end
    object DtpAte: TDateTimePicker
      Left = 208
      Top = 14
      Width = 120
      Height = 23
      Date = 46310.000000000000000000
      Time = 46310.000000000000000000
      TabOrder = 1
    end
    object BtnFiltrar: TButton
      Left = 344
      Top = 13
      Width = 88
      Height = 25
      Caption = 'Filtrar'
      Default = True
      TabOrder = 2
      OnClick = BtnFiltrarClick
    end
  end
  object Grade: TDBGrid
    Left = 0
    Top = 52
    Width = 960
    Height = 452
    Align = alClient
    DataSource = Ds
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
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
    Width = 960
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblTotais: TLabel
      Left = 16
      Top = 20
      Width = 3
      Height = 15
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnFechar: TButton
      Left = 856
      Top = 14
      Width = 88
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 0
    end
  end
  object Qry: TFDQuery
    Left = 856
    Top = 80
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 856
    Top = 136
  end
end
