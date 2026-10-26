object FrmRazonete: TFrmRazonete
  Left = 0
  Top = 0
  Caption = 'Razonete (conta em T)'
  ClientHeight = 540
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 15
  object PnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LblConta: TLabel
      Left = 16
      Top = 16
      Width = 33
      Height = 15
      Caption = 'Conta'
    end
    object CbConta: TDBLookupComboBox
      Left = 64
      Top = 12
      Width = 400
      Height = 23
      KeyField = 'id'
      ListField = 'codigo;nome'
      ListFieldIndex = 1
      ListSource = DsContas
      TabOrder = 0
      OnClick = CbContaClick
    end
  end
  object PnlT: TPanel
    Left = 0
    Top = 48
    Width = 900
    Height = 444
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object LblTitulo: TLabel
      Left = 0
      Top = 0
      Width = 900
      Height = 30
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Conta'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object PnlDebito: TPanel
      Left = 0
      Top = 30
      Width = 448
      Height = 414
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object LblDebito: TLabel
        Left = 0
        Top = 0
        Width = 448
        Height = 24
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'D'#201'BITO'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
      object LblTotalDebito: TLabel
        Left = 0
        Top = 390
        Width = 448
        Height = 24
        Align = alBottom
        Alignment = taRightJustify
        AutoSize = False
        Layout = tlCenter
      end
      object GradeDebito: TDBGrid
        Left = 0
        Top = 24
        Width = 448
        Height = 366
        Align = alClient
        DataSource = DsDebitos
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object PnlLinha: TPanel
      Left = 448
      Top = 30
      Width = 4
      Height = 414
      Align = alLeft
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 1
    end
    object PnlCredito: TPanel
      Left = 452
      Top = 30
      Width = 448
      Height = 414
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object LblCredito: TLabel
        Left = 0
        Top = 0
        Width = 448
        Height = 24
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'CR'#201'DITO'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
      object LblTotalCredito: TLabel
        Left = 0
        Top = 390
        Width = 448
        Height = 24
        Align = alBottom
        Alignment = taRightJustify
        AutoSize = False
        Layout = tlCenter
      end
      object GradeCredito: TDBGrid
        Left = 0
        Top = 24
        Width = 448
        Height = 366
        Align = alClient
        DataSource = DsCreditos
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object PnlSaldo: TPanel
    Left = 0
    Top = 492
    Width = 900
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblSaldo: TLabel
      Left = 16
      Top = 14
      Width = 37
      Height = 20
      Caption = 'Saldo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object QryContas: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome, natureza FROM conta'
      'WHERE tipo = '#39'A'#39
      'ORDER BY codigo')
    Left = 760
    Top = 8
  end
  object DsContas: TDataSource
    DataSet = QryContas
    Left = 816
    Top = 8
  end
  object QryDebitos: TFDQuery
    Left = 120
    Top = 200
  end
  object DsDebitos: TDataSource
    DataSet = QryDebitos
    Left = 120
    Top = 256
  end
  object QryCreditos: TFDQuery
    Left = 600
    Top = 200
  end
  object DsCreditos: TDataSource
    DataSet = QryCreditos
    Left = 600
    Top = 256
  end
end
