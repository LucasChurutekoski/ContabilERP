object FrmHistoricoMovimentos: TFrmHistoricoMovimentos
  Left = 0
  Top = 0
  Caption = 'Hist'#243'rico de movimentos (kardex)'
  ClientHeight = 580
  ClientWidth = 1040
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
    Width = 1040
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LblDe: TLabel
      Left = 16
      Top = 8
      Width = 15
      Height = 15
      Caption = 'De'
    end
    object LblAte: TLabel
      Left = 152
      Top = 8
      Width = 18
      Height = 15
      Caption = 'At'#233
    end
    object LblItem: TLabel
      Left = 288
      Top = 8
      Width = 170
      Height = 15
      Caption = 'Item (vazio = todos; Del limpa)'
    end
    object LblOperacao: TLabel
      Left = 600
      Top = 8
      Width = 51
      Height = 15
      Caption = 'Opera'#231#227'o'
    end
    object DtpDe: TDateTimePicker
      Left = 16
      Top = 28
      Width = 120
      Height = 23
      Date = 46310.000000000000000000
      Time = 46310.000000000000000000
      TabOrder = 0
    end
    object DtpAte: TDateTimePicker
      Left = 152
      Top = 28
      Width = 120
      Height = 23
      Date = 46310.000000000000000000
      Time = 46310.000000000000000000
      TabOrder = 1
    end
    object CbItem: TDBLookupComboBox
      Left = 288
      Top = 28
      Width = 296
      Height = 23
      DropDownWidth = 420
      KeyField = 'id'
      ListField = 'codigo;descricao'
      ListFieldIndex = 1
      ListSource = DsItens
      NullValueKey = 46
      TabOrder = 2
    end
    object CbOperacao: TComboBox
      Left = 600
      Top = 28
      Width = 200
      Height = 23
      Style = csDropDownList
      TabOrder = 3
      Items.Strings = (
        'Todas'
        'Compra'
        'Consumo'
        'Transfer'#234'ncia entre locais'
        'Presta'#231#227'o de servi'#231'o'
        'Manuten'#231#227'o de ve'#237'culo')
    end
    object BtnFiltrar: TButton
      Left = 816
      Top = 27
      Width = 88
      Height = 25
      Caption = 'Filtrar'
      Default = True
      TabOrder = 4
      OnClick = BtnFiltrarClick
    end
  end
  object Grade: TDBGrid
    Left = 0
    Top = 64
    Width = 1040
    Height = 460
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
    Top = 524
    Width = 1040
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblResumo: TLabel
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
      Left = 936
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
    Left = 936
    Top = 96
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 936
    Top = 152
  end
  object QryItens: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, descricao FROM item ORDER BY codigo')
    Left = 856
    Top = 96
  end
  object DsItens: TDataSource
    DataSet = QryItens
    Left = 856
    Top = 152
  end
end
