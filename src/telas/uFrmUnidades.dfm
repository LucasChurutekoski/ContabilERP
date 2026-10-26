object FrmUnidades: TFrmUnidades
  Left = 0
  Top = 0
  Caption = 'Unidades de medida'
  ClientHeight = 400
  ClientWidth = 460
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
    Width = 460
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
    Width = 460
    Height = 290
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
        FieldName = 'sigla'
        Title.Caption = 'Sigla'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'descricao'
        Title.Caption = 'Descri'#231#227'o'
        Width = 300
        Visible = True
      end>
  end
  object PnlEdicao: TPanel
    Left = 0
    Top = 320
    Width = 460
    Height = 80
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblSigla: TLabel
      Left = 16
      Top = 12
      Width = 26
      Height = 15
      Caption = 'Sigla'
    end
    object LblDescricao: TLabel
      Left = 112
      Top = 12
      Width = 51
      Height = 15
      Caption = 'Descri'#231#227'o'
    end
    object EdtSigla: TDBEdit
      Left = 16
      Top = 32
      Width = 80
      Height = 23
      CharCase = ecUpperCase
      DataField = 'sigla'
      DataSource = Ds
      TabOrder = 0
    end
    object EdtDescricao: TDBEdit
      Left = 112
      Top = 32
      Width = 328
      Height = 23
      DataField = 'descricao'
      DataSource = Ds
      TabOrder = 1
    end
  end
  object Qry: TFDQuery
    BeforePost = QryBeforePost
    BeforeDelete = QryBeforeDelete
    OnDeleteError = QryErroBanco
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM unidade ORDER BY sigla')
    Left = 376
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 376
    Top = 120
  end
end
