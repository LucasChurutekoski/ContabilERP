object FrmItens: TFrmItens
  Left = 0
  Top = 0
  Caption = 'Itens e servi'#231'os'
  ClientHeight = 480
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 15
  object Navegador: TDBNavigator
    Left = 0
    Top = 0
    Width = 760
    Height = 30
    DataSource = Ds
    Align = alTop
    ConfirmDelete = False
    Hints.Strings = (
      'Primeiro'
      'Anterior'
      'Pr'#243'ximo'
      #218'ltimo'
      'Novo'
      'Excluir'
      'Editar'
      'Salvar'
      'Cancelar'
      'Atualizar')
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object Grade: TDBGrid
    Left = 0
    Top = 30
    Width = 760
    Height = 310
    Align = alClient
    DataSource = Ds
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'codigo'
        Title.Caption = 'C'#243'digo'
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'descricao'
        Title.Caption = 'Descri'#231#227'o'
        Width = 330
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'tipo'
        Title.Caption = 'Tipo (P/S)'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'unidade'
        Title.Caption = 'Unidade'
        Width = 60
        Visible = True
      end>
  end
  object PnlEdicao: TPanel
    Left = 0
    Top = 340
    Width = 760
    Height = 140
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblCodigo: TLabel
      Left = 16
      Top = 12
      Width = 39
      Height = 15
      Caption = 'C'#243'digo'
    end
    object LblDescricao: TLabel
      Left = 152
      Top = 12
      Width = 51
      Height = 15
      Caption = 'Descri'#231#227'o'
    end
    object LblUnidade: TLabel
      Left = 512
      Top = 12
      Width = 46
      Height = 15
      Caption = 'Unidade'
    end
    object LblConta: TLabel
      Left = 248
      Top = 72
      Width = 82
      Height = 15
      Caption = 'Conta cont'#225'bil'
    end
    object EdtCodigo: TDBEdit
      Left = 16
      Top = 32
      Width = 120
      Height = 23
      DataField = 'codigo'
      DataSource = Ds
      TabOrder = 0
    end
    object EdtDescricao: TDBEdit
      Left = 152
      Top = 32
      Width = 344
      Height = 23
      DataField = 'descricao'
      DataSource = Ds
      TabOrder = 1
    end
    object CbUnidade: TDBLookupComboBox
      Left = 512
      Top = 32
      Width = 120
      Height = 23
      DataField = 'unidade'
      DataSource = Ds
      KeyField = 'sigla'
      ListField = 'sigla;descricao'
      ListSource = DsUnidades
      TabOrder = 2
    end
    object BtnUnidades: TButton
      Left = 636
      Top = 31
      Width = 28
      Height = 25
      Hint = 'Cadastrar ou editar unidades'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = BtnUnidadesClick
    end
    object RgTipo: TDBRadioGroup
      Left = 16
      Top = 66
      Width = 216
      Height = 56
      Caption = 'Tipo'
      Columns = 2
      DataField = 'tipo'
      DataSource = Ds
      Items.Strings = (
        'Produto'
        'Servi'#231'o')
      TabOrder = 3
      Values.Strings = (
        'P'
        'S')
    end
    object CbConta: TDBLookupComboBox
      Left = 248
      Top = 92
      Width = 328
      Height = 23
      DataField = 'id_conta'
      DataSource = Ds
      KeyField = 'id'
      ListField = 'codigo;nome'
      ListFieldIndex = 1
      ListSource = DsContas
      TabOrder = 4
    end
    object BtnContas: TButton
      Left = 580
      Top = 91
      Width = 28
      Height = 25
      Hint = 'Cadastrar ou editar contas do plano de contas'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = BtnContasClick
    end
  end
  object Qry: TFDQuery
    BeforePost = QryBeforePost
    BeforeDelete = QryBeforeDelete
    OnDeleteError = QryErroBanco
    OnNewRecord = QryNewRecord
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM item ORDER BY codigo')
    Left = 680
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 680
    Top = 120
  end
  object QryContas: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome, grupo'
      'FROM conta'
      'WHERE tipo = '#39'A'#39' AND grupo IN ('#39'A'#39', '#39'D'#39', '#39'R'#39')'
      'ORDER BY codigo')
    Left = 600
    Top = 64
  end
  object DsContas: TDataSource
    DataSet = QryContas
    Left = 600
    Top = 120
  end
  object QryUnidades: TFDQuery
    SQL.Strings = (
      'SELECT sigla, descricao FROM unidade ORDER BY sigla')
    Left = 520
    Top = 64
  end
  object DsUnidades: TDataSource
    DataSet = QryUnidades
    Left = 520
    Top = 120
  end
end
