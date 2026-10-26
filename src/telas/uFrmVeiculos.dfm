object FrmVeiculos: TFrmVeiculos
  Left = 0
  Top = 0
  Caption = 'Ve'#237'culos da frota'
  ClientHeight = 440
  ClientWidth = 640
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
    Width = 640
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
    Width = 640
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
        FieldName = 'placa'
        Title.Caption = 'Placa'
        Width = 90
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'descricao'
        Title.Caption = 'Descri'#231#227'o'
        Width = 320
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ano'
        Title.Caption = 'Ano'
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ativo'
        Title.Caption = 'Ativo'
        Width = 50
        Visible = True
      end>
  end
  object PnlEdicao: TPanel
    Left = 0
    Top = 340
    Width = 640
    Height = 100
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblPlaca: TLabel
      Left = 16
      Top = 12
      Width = 29
      Height = 15
      Caption = 'Placa'
    end
    object LblDescricao: TLabel
      Left = 136
      Top = 12
      Width = 51
      Height = 15
      Caption = 'Descri'#231#227'o'
    end
    object LblAno: TLabel
      Left = 512
      Top = 12
      Width = 22
      Height = 15
      Caption = 'Ano'
    end
    object EdtPlaca: TDBEdit
      Left = 16
      Top = 32
      Width = 104
      Height = 23
      CharCase = ecUpperCase
      DataField = 'placa'
      DataSource = Ds
      MaxLength = 8
      TabOrder = 0
    end
    object EdtDescricao: TDBEdit
      Left = 136
      Top = 32
      Width = 360
      Height = 23
      DataField = 'descricao'
      DataSource = Ds
      TabOrder = 1
    end
    object EdtAno: TDBEdit
      Left = 512
      Top = 32
      Width = 80
      Height = 23
      DataField = 'ano'
      DataSource = Ds
      TabOrder = 2
    end
    object ChkAtivo: TDBCheckBox
      Left = 16
      Top = 68
      Width = 200
      Height = 17
      Caption = 'Ativo (em uso na frota)'
      DataField = 'ativo'
      DataSource = Ds
      TabOrder = 3
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
  end
  object Qry: TFDQuery
    BeforePost = QryBeforePost
    BeforeDelete = QryBeforeDelete
    OnDeleteError = QryErroBanco
    OnNewRecord = QryNewRecord
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM veiculo ORDER BY placa')
    Left = 560
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 560
    Top = 120
  end
end
