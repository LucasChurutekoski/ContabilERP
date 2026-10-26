object FrmMovimento: TFrmMovimento
  Left = 0
  Top = 0
  Caption = 'Movimento'
  ClientHeight = 580
  ClientWidth = 880
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
    Width = 880
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LblData: TLabel
      Left = 16
      Top = 8
      Width = 24
      Height = 15
      Caption = 'Data'
    end
    object LblEntidade: TLabel
      Left = 152
      Top = 8
      Width = 59
      Height = 15
      Caption = 'Fornecedor'
    end
    object LblObservacao: TLabel
      Left = 648
      Top = 8
      Width = 65
      Height = 15
      Caption = 'Observa'#231#227'o'
    end
    object LblVeiculo: TLabel
      Left = 16
      Top = 66
      Width = 41
      Height = 15
      Caption = 'Ve'#237'culo'
    end
    object LblContaDestino: TLabel
      Left = 448
      Top = 66
      Width = 224
      Height = 15
      Caption = 'Conta de despesa que recebe o valor'
    end
    object DtpData: TDateTimePicker
      Left = 16
      Top = 28
      Width = 120
      Height = 23
      Date = 46310.000000000000000000
      Time = 46310.000000000000000000
      TabOrder = 0
    end
    object CbEntidade: TDBLookupComboBox
      Left = 152
      Top = 28
      Width = 280
      Height = 23
      DropDownWidth = 320
      KeyField = 'id'
      ListField = 'nome'
      ListSource = DsEntidades
      TabOrder = 1
    end
    object RgPagamento: TRadioGroup
      Left = 448
      Top = 8
      Width = 184
      Height = 52
      Caption = 'Pagamento'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        #192' vista'
        'A prazo')
      TabOrder = 2
    end
    object EdtObservacao: TEdit
      Left = 648
      Top = 28
      Width = 216
      Height = 23
      MaxLength = 100
      TabOrder = 3
    end
    object CbVeiculo: TDBLookupComboBox
      Left = 16
      Top = 86
      Width = 416
      Height = 23
      KeyField = 'id'
      ListField = 'placa;descricao'
      ListFieldIndex = 1
      ListSource = DsVeiculos
      TabOrder = 4
    end
    object CbContaDestino: TDBLookupComboBox
      Left = 448
      Top = 86
      Width = 416
      Height = 23
      KeyField = 'id'
      ListField = 'codigo;nome'
      ListFieldIndex = 1
      ListSource = DsDespesas
      TabOrder = 5
    end
  end
  object PnlItem: TPanel
    Left = 0
    Top = 120
    Width = 880
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object LblItem: TLabel
      Left = 16
      Top = 8
      Width = 24
      Height = 15
      Caption = 'Item'
    end
    object LblOrigem: TLabel
      Left = 262
      Top = 8
      Width = 85
      Height = 15
      Caption = 'Local de origem'
    end
    object LblDestino: TLabel
      Left = 446
      Top = 8
      Width = 88
      Height = 15
      Caption = 'Local de destino'
    end
    object LblQuantidade: TLabel
      Left = 630
      Top = 8
      Width = 62
      Height = 15
      Caption = 'Quantidade'
    end
    object LblValor: TLabel
      Left = 706
      Top = 8
      Width = 58
      Height = 15
      Caption = 'Valor unit.'
    end
    object LblDisponivel: TLabel
      Left = 262
      Top = 56
      Width = 3
      Height = 15
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CbItem: TDBLookupComboBox
      Left = 16
      Top = 28
      Width = 232
      Height = 23
      DropDownWidth = 420
      KeyField = 'id'
      ListField = 'codigo;descricao'
      ListFieldIndex = 1
      ListSource = DsItens
      TabOrder = 0
      OnClick = CbItemClick
    end
    object CbOrigem: TDBLookupComboBox
      Left = 262
      Top = 28
      Width = 170
      Height = 23
      DropDownWidth = 260
      KeyField = 'id'
      ListField = 'nome;quantidade'
      ListSource = DsOrigens
      TabOrder = 1
      OnClick = CbOrigemClick
    end
    object CbDestino: TDBLookupComboBox
      Left = 446
      Top = 28
      Width = 170
      Height = 23
      DropDownWidth = 220
      KeyField = 'id'
      ListField = 'nome'
      ListSource = DsLocais
      TabOrder = 2
    end
    object EdtQuantidade: TEdit
      Left = 630
      Top = 28
      Width = 64
      Height = 23
      TabOrder = 3
    end
    object EdtValor: TEdit
      Left = 706
      Top = 28
      Width = 80
      Height = 23
      TabOrder = 4
    end
    object BtnAdicionar: TButton
      Left = 796
      Top = 27
      Width = 72
      Height = 25
      Caption = 'Adicionar'
      Default = True
      TabOrder = 5
      OnClick = BtnAdicionarClick
    end
  end
  object Grade: TDBGrid
    Left = 0
    Top = 200
    Width = 880
    Height = 324
    Align = alClient
    DataSource = DsMemItens
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
    Top = 524
    Width = 880
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object LblTotal: TLabel
      Left = 144
      Top = 18
      Width = 3
      Height = 17
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnRemover: TButton
      Left = 16
      Top = 14
      Width = 112
      Height = 27
      Caption = 'Remover item'
      TabOrder = 0
      OnClick = BtnRemoverClick
    end
    object BtnGravar: TButton
      Left = 660
      Top = 14
      Width = 110
      Height = 27
      Caption = 'Gravar'
      Enabled = False
      TabOrder = 1
      OnClick = BtnGravarClick
    end
    object BtnFechar: TButton
      Left = 778
      Top = 14
      Width = 88
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object QryEntidades: TFDQuery
    Left = 560
    Top = 232
  end
  object DsEntidades: TDataSource
    DataSet = QryEntidades
    Left = 560
    Top = 288
  end
  object QryItens: TFDQuery
    Left = 640
    Top = 232
  end
  object DsItens: TDataSource
    DataSet = QryItens
    Left = 640
    Top = 288
  end
  object QryLocais: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome FROM local'
      'WHERE aceita_estoque = 1'
      'ORDER BY codigo')
    Left = 720
    Top = 232
  end
  object DsLocais: TDataSource
    DataSet = QryLocais
    Left = 720
    Top = 288
  end
  object QryOrigens: TFDQuery
    Left = 400
    Top = 232
  end
  object DsOrigens: TDataSource
    DataSet = QryOrigens
    Left = 400
    Top = 288
  end
  object QryDespesas: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome FROM conta'
      'WHERE tipo = '#39'A'#39' AND grupo = '#39'D'#39
      'ORDER BY codigo')
    Left = 800
    Top = 232
  end
  object DsDespesas: TDataSource
    DataSet = QryDespesas
    Left = 800
    Top = 288
  end
  object QryVeiculos: TFDQuery
    SQL.Strings = (
      'SELECT id, placa, descricao FROM veiculo'
      'WHERE ativo = 1'
      'ORDER BY placa')
    Left = 320
    Top = 232
  end
  object DsVeiculos: TDataSource
    DataSet = QryVeiculos
    Left = 320
    Top = 288
  end
  object MemItens: TFDMemTable
    Left = 480
    Top = 232
  end
  object DsMemItens: TDataSource
    DataSet = MemItens
    Left = 480
    Top = 288
  end
end
