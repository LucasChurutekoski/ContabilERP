object FrmEntidades: TFrmEntidades
  Left = 0
  Top = 0
  Caption = 'Clientes e fornecedores'
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
    Height = 340
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
        FieldName = 'id'
        Title.Caption = 'C'#243'd.'
        Width = 50
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
        FieldName = 'documento'
        Title.Caption = 'CPF/CNPJ'
        Width = 160
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'eh_cliente'
        Title.Caption = 'Cliente'
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'eh_fornecedor'
        Title.Caption = 'Fornecedor'
        Width = 75
        Visible = True
      end>
  end
  object PnlEdicao: TPanel
    Left = 0
    Top = 370
    Width = 760
    Height = 110
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LblNome: TLabel
      Left = 16
      Top = 12
      Width = 33
      Height = 15
      Caption = 'Nome'
    end
    object LblDocumento: TLabel
      Left = 400
      Top = 12
      Width = 55
      Height = 15
      Caption = 'CPF/CNPJ'
    end
    object EdtNome: TDBEdit
      Left = 16
      Top = 32
      Width = 368
      Height = 23
      DataField = 'nome'
      DataSource = Ds
      TabOrder = 0
    end
    object EdtDocumento: TDBEdit
      Left = 400
      Top = 32
      Width = 200
      Height = 23
      DataField = 'documento'
      DataSource = Ds
      MaxLength = 18
      TabOrder = 1
      OnChange = EdtDocumentoChange
    end
    object ChkCliente: TDBCheckBox
      Left = 16
      Top = 72
      Width = 97
      Height = 17
      Caption = 'Cliente'
      DataField = 'eh_cliente'
      DataSource = Ds
      TabOrder = 2
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object ChkFornecedor: TDBCheckBox
      Left = 128
      Top = 72
      Width = 97
      Height = 17
      Caption = 'Fornecedor'
      DataField = 'eh_fornecedor'
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
      'SELECT * FROM entidade ORDER BY nome')
    Left = 680
    Top = 64
  end
  object Ds: TDataSource
    DataSet = Qry
    Left = 680
    Top = 120
  end
end
