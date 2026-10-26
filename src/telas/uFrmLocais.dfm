object FrmLocais: TFrmLocais
  Left = 0
  Top = 0
  Caption = 'Locais de estoque'
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
    Height = 330
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
        FieldName = 'nome'
        Title.Caption = 'Nome'
        Width = 330
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'aceita_estoque'
        Title.Caption = 'Aceita estoque'
        Width = 95
        Visible = True
      end>
  end
  object PnlEdicao: TPanel
    Left = 0
    Top = 360
    Width = 760
    Height = 120
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
    object LblNome: TLabel
      Left = 152
      Top = 12
      Width = 33
      Height = 15
      Caption = 'Nome'
    end
    object LblPai: TLabel
      Left = 448
      Top = 12
      Width = 214
      Height = 15
      Caption = 'Local pai (Del limpa = local raiz)'
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
    object EdtNome: TDBEdit
      Left = 152
      Top = 32
      Width = 280
      Height = 23
      DataField = 'nome'
      DataSource = Ds
      TabOrder = 1
    end
    object CbPai: TDBLookupComboBox
      Left = 448
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
      TabOrder = 2
    end
    object ChkAceitaEstoque: TDBCheckBox
      Left = 16
      Top = 76
      Width = 360
      Height = 17
      Caption = 'Aceita estoque (local final, ex.: prateleira)'
      DataField = 'aceita_estoque'
      DataSource = Ds
      TabOrder = 3
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
  end
  object Qry: TFDQuery
    AfterPost = QryAfterPost
    BeforePost = QryBeforePost
    BeforeDelete = QryBeforeDelete
    OnDeleteError = QryErroBanco
    OnNewRecord = QryNewRecord
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM local ORDER BY codigo')
    Left = 680
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 680
    Top = 120
  end
  object QryPais: TFDQuery
    SQL.Strings = (
      'SELECT id, codigo, nome'
      'FROM local'
      'WHERE aceita_estoque = 0'
      'ORDER BY codigo')
    Left = 600
    Top = 64
  end
  object DsPais: TDataSource
    DataSet = QryPais
    Left = 600
    Top = 120
  end
end
