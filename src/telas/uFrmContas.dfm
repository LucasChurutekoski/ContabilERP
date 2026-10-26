object FrmContas: TFrmContas
  Left = 0
  Top = 0
  Caption = 'Plano de contas'
  ClientHeight = 540
  ClientWidth = 780
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
    Width = 780
    Height = 30
    DataSource = Ds
    Align = alTop
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
    ConfirmDelete = False
    ShowHint = True
    TabOrder = 0
    ExplicitWidth = 778
  end
  object Grade: TDBGrid
    Left = 0
    Top = 30
    Width = 780
    Height = 345
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
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nome'
        Title.Caption = 'Nome'
        Width = 320
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'grupo'
        Title.Caption = 'Grupo'
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'tipo'
        Title.Caption = 'Tipo (S/A)'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'natureza'
        Title.Caption = 'Natureza (D/C)'
        Width = 95
        Visible = True
      end>
  end
  object PnlEdicao: TPanel
    Left = 0
    Top = 375
    Width = 780
    Height = 165
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 367
    ExplicitWidth = 778
    object LblCodigo: TLabel
      Left = 16
      Top = 12
      Width = 39
      Height = 15
      Caption = 'C'#243'digo'
    end
    object LblNome: TLabel
      Left = 152
      Top = 12
      Width = 33
      Height = 15
      Caption = 'Nome'
    end
    object LblPai: TLabel
      Left = 480
      Top = 12
      Width = 177
      Height = 15
      Caption = 'Conta pai (Del limpa = conta raiz)'
    end
    object EdtCodigo: TDBEdit
      Left = 16
      Top = 32
      Width = 120
      Height = 23
      DataField = 'codigo'
      DataSource = Ds
      TabOrder = 1
    end
    object EdtNome: TDBEdit
      Left = 152
      Top = 32
      Width = 312
      Height = 23
      DataField = 'nome'
      DataSource = Ds
      TabOrder = 2
    end
    object CbPai: TDBLookupComboBox
      Left = 480
      Top = 32
      Width = 280
      Height = 23
      DataField = 'id_pai'
      DataSource = Ds
      KeyField = 'id'
      ListField = 'codigo;nome'
      ListFieldIndex = 1
      ListSource = DsPais
      NullValueKey = 46
      TabOrder = 0
    end
    object RgGrupo: TDBRadioGroup
      Left = 16
      Top = 72
      Width = 400
      Height = 72
      Caption = 'Grupo'
      Columns = 3
      DataField = 'grupo'
      DataSource = Ds
      Items.Strings = (
        'Ativo'
        'Passivo'
        'Patrim'#244'nio L'#237'quido'
        'Receita'
        'Despesa')
      TabOrder = 3
      Values.Strings = (
        'A'
        'P'
        'PL'
        'R'
        'D')
    end
    object RgTipo: TDBRadioGroup
      Left = 432
      Top = 72
      Width = 160
      Height = 72
      Caption = 'Tipo'
      DataField = 'tipo'
      DataSource = Ds
      Items.Strings = (
        'Sint'#233'tica'
        'Anal'#237'tica')
      TabOrder = 4
      Values.Strings = (
        'S'
        'A')
    end
    object RgNatureza: TDBRadioGroup
      Left = 608
      Top = 72
      Width = 152
      Height = 72
      Caption = 'Natureza'
      DataField = 'natureza'
      DataSource = Ds
      Items.Strings = (
        'Devedora'
        'Credora')
      TabOrder = 5
      Values.Strings = (
        'D'
        'C')
    end
  end
  object Qry: TFDQuery
    BeforePost = QryBeforePost
    AfterPost = QryAfterPost
    BeforeDelete = QryBeforeDelete
    OnDeleteError = QryErroBanco
    OnNewRecord = QryNewRecord
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM conta ORDER BY codigo')
    Left = 696
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 696
    Top = 120
  end
  object QryPais: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome, grupo'
      'FROM conta'
      'WHERE tipo = '#39'S'#39
      'ORDER BY codigo')
    Left = 616
    Top = 64
  end
  object DsPais: TDataSource
    DataSet = QryPais
    Left = 616
    Top = 120
  end
end
