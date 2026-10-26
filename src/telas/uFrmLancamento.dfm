object FrmLancamento: TFrmLancamento
  Left = 0
  Top = 0
  Caption = 'Lan'#231'amento cont'#225'bil'
  ClientHeight = 520
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PnlCabecalho: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LblData: TLabel
      Left = 16
      Top = 10
      Width = 24
      Height = 15
      Caption = 'Data'
    end
    object LblHistorico: TLabel
      Left = 160
      Top = 10
      Width = 49
      Height = 15
      Caption = 'Hist'#243'rico'
    end
    object DtpData: TDateTimePicker
      Left = 16
      Top = 30
      Width = 128
      Height = 23
      Date = 46310.000000000000000000
      Time = 46310.000000000000000000
      TabOrder = 0
    end
    object EdtHistorico: TEdit
      Left = 160
      Top = 30
      Width = 480
      Height = 23
      MaxLength = 200
      TabOrder = 1
      TextHint = 'Descreva o fato. Ex.: Pagamento da NF 1234 '#224' Distribuidora Rodas'
    end
    object BtnDiario: TButton
      Left = 656
      Top = 29
      Width = 128
      Height = 25
      Hint = 'Abre o Di'#225'rio: lan'#231'amentos entre duas datas'
      Caption = 'Ver lan'#231'amentos...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = BtnDiarioClick
    end
  end
  object PnlPartida: TPanel
    Left = 0
    Top = 64
    Width = 800
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object LblConta: TLabel
      Left = 16
      Top = 8
      Width = 103
      Height = 15
      Caption = 'Conta (anal'#237'ticas)'
    end
    object LblValor: TLabel
      Left = 560
      Top = 8
      Width = 26
      Height = 15
      Caption = 'Valor'
    end
    object CbConta: TDBLookupComboBox
      Left = 16
      Top = 28
      Width = 360
      Height = 23
      KeyField = 'id'
      ListField = 'codigo;nome'
      ListFieldIndex = 1
      ListSource = DsContas
      TabOrder = 0
    end
    object RgDC: TRadioGroup
      Left = 392
      Top = 12
      Width = 152
      Height = 48
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'D'#233'bito'
        'Cr'#233'dito')
      TabOrder = 1
    end
    object EdtValor: TEdit
      Left = 560
      Top = 28
      Width = 112
      Height = 23
      TabOrder = 2
    end
    object BtnAdicionar: TButton
      Left = 688
      Top = 27
      Width = 92
      Height = 25
      Caption = 'Adicionar'
      Default = True
      TabOrder = 3
      OnClick = BtnAdicionarClick
    end
  end
  object Grade: TDBGrid
    Left = 0
    Top = 136
    Width = 800
    Height = 324
    Align = alClient
    DataSource = DsPartidas
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object PnlRodape: TPanel
    Left = 0
    Top = 460
    Width = 800
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object LblTotais: TLabel
      Left = 144
      Top = 20
      Width = 3
      Height = 17
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnRemover: TButton
      Left = 16
      Top = 16
      Width = 112
      Height = 27
      Caption = 'Remover partida'
      TabOrder = 0
      OnClick = BtnRemoverClick
    end
    object BtnGravar: TButton
      Left = 568
      Top = 16
      Width = 112
      Height = 27
      Caption = 'Gravar'
      Enabled = False
      TabOrder = 1
      OnClick = BtnGravarClick
    end
    object BtnFechar: TButton
      Left = 688
      Top = 16
      Width = 92
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object QryContas: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome FROM conta'
      'WHERE tipo = '#39'A'#39
      'ORDER BY codigo')
    Left = 696
    Top = 168
  end
  object DsContas: TDataSource
    DataSet = QryContas
    Left = 696
    Top = 224
  end
  object MemPartidas: TFDMemTable
    Left = 600
    Top = 168
  end
  object DsPartidas: TDataSource
    DataSet = MemPartidas
    Left = 600
    Top = 224
  end
end
