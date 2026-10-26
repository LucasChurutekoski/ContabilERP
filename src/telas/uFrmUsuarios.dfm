object FrmUsuarios: TFrmUsuarios
  Left = 0
  Top = 0
  Caption = 'Usu'#225'rios e permiss'#245'es'
  ClientHeight = 560
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 820
    Height = 508
    ActivePage = TabUsuarios
    Align = alClient
    TabOrder = 0
    object TabUsuarios: TTabSheet
      Caption = 'Usu'#225'rios'
      object NavUsuarios: TDBNavigator
        Left = 0
        Top = 0
        Width = 812
        Height = 30
        DataSource = DsUsuarios
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
      object GradeUsuarios: TDBGrid
        Left = 0
        Top = 30
        Width = 812
        Height = 302
        Align = alClient
        DataSource = DsUsuarios
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
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
            FieldName = 'login'
            Title.Caption = 'Login'
            Width = 130
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'nome'
            Title.Caption = 'Nome'
            Width = 300
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
      object PnlUsuario: TPanel
        Left = 0
        Top = 332
        Width = 812
        Height = 146
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object LblLogin: TLabel
          Left = 16
          Top = 10
          Width = 30
          Height = 15
          Caption = 'Login'
        end
        object LblNome: TLabel
          Left = 176
          Top = 10
          Width = 33
          Height = 15
          Caption = 'Nome'
        end
        object LblPerfil: TLabel
          Left = 496
          Top = 10
          Width = 26
          Height = 15
          Caption = 'Perfil'
        end
        object LblSenha: TLabel
          Left = 16
          Top = 66
          Width = 64
          Height = 15
          Caption = 'Nova senha'
        end
        object LblDicaSenha: TLabel
          Left = 176
          Top = 90
          Width = 420
          Height = 15
          Caption =
            'Ao editar, deixe em branco para manter a senha atual. Para trocar' +
            ': digite e salve.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGrayText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object EdtLogin: TDBEdit
          Left = 16
          Top = 30
          Width = 144
          Height = 23
          CharCase = ecLowerCase
          DataField = 'login'
          DataSource = DsUsuarios
          TabOrder = 0
        end
        object EdtNome: TDBEdit
          Left = 176
          Top = 30
          Width = 304
          Height = 23
          DataField = 'nome'
          DataSource = DsUsuarios
          TabOrder = 1
        end
        object CbPerfil: TDBLookupComboBox
          Left = 496
          Top = 30
          Width = 200
          Height = 23
          DataField = 'id_perfil'
          DataSource = DsUsuarios
          KeyField = 'id'
          ListField = 'nome'
          ListSource = DsPerfisLista
          TabOrder = 2
        end
        object ChkAtivo: TDBCheckBox
          Left = 712
          Top = 33
          Width = 80
          Height = 17
          Caption = 'Ativo'
          DataField = 'ativo'
          DataSource = DsUsuarios
          TabOrder = 3
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
        object EdtSenha: TEdit
          Left = 16
          Top = 86
          Width = 144
          Height = 23
          PasswordChar = '*'
          TabOrder = 4
        end
      end
    end
    object TabPerfis: TTabSheet
      Caption = 'Perfis e permiss'#245'es'
      ImageIndex = 1
      object NavPerfis: TDBNavigator
        Left = 0
        Top = 0
        Width = 812
        Height = 30
        DataSource = DsPerfis
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
      object GradePerfis: TDBGrid
        Left = 0
        Top = 30
        Width = 240
        Height = 448
        Align = alLeft
        DataSource = DsPerfis
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
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
            FieldName = 'nome'
            Title.Caption = 'Perfil'
            Width = 200
            Visible = True
          end>
      end
      object PnlPermissoes: TPanel
        Left = 240
        Top = 30
        Width = 572
        Height = 448
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        object LblNomePerfil: TLabel
          Left = 0
          Top = 0
          Width = 572
          Height = 22
          Align = alTop
          AutoSize = False
          Caption = 'Nome do perfil'
          Layout = tlBottom
        end
        object EdtNomePerfil: TDBEdit
          Left = 0
          Top = 22
          Width = 572
          Height = 23
          Align = alTop
          DataField = 'nome'
          DataSource = DsPerfis
          TabOrder = 0
        end
        object LblPermissoes: TLabel
          Left = 0
          Top = 45
          Width = 572
          Height = 26
          Align = alTop
          AutoSize = False
          Caption = 'Permiss'#245'es deste perfil (marque e clique em "Salvar permiss'#245'es")'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
        object ChkPermissoes: TCheckListBox
          Left = 0
          Top = 71
          Width = 572
          Height = 333
          Align = alClient
          ItemHeight = 17
          TabOrder = 1
        end
        object PnlBotoesPermissoes: TPanel
          Left = 0
          Top = 404
          Width = 572
          Height = 44
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 2
          object LblAviso: TLabel
            Left = 168
            Top = 14
            Width = 300
            Height = 15
            Caption = 'Valem a partir do pr'#243'ximo login dos usu'#225'rios.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGrayText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object BtnSalvarPermissoes: TButton
            Left = 8
            Top = 8
            Width = 148
            Height = 27
            Caption = 'Salvar permiss'#245'es'
            TabOrder = 0
            OnClick = BtnSalvarPermissoesClick
          end
        end
      end
    end
  end
  object PnlRodape: TPanel
    Left = 0
    Top = 508
    Width = 820
    Height = 52
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BtnFechar: TButton
      Left = 716
      Top = 12
      Width = 88
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 0
    end
  end
  object QryUsuarios: TFDQuery
    AfterPost = QryUsuariosAfterPost
    BeforePost = QryUsuariosBeforePost
    BeforeDelete = QryUsuariosBeforeDelete
    OnDeleteError = QryErroBanco
    OnNewRecord = QryUsuariosNewRecord
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM usuario ORDER BY login')
    Left = 720
    Top = 96
  end
  object DsUsuarios: TDataSource
    DataSet = QryUsuarios
    OnStateChange = DsUsuariosStateChange
    Left = 720
    Top = 152
  end
  object QryPerfis: TFDQuery
    AfterPost = QryPerfisAfterPost
    AfterDelete = QryPerfisAfterDelete
    AfterScroll = QryPerfisAfterScroll
    BeforePost = QryPerfisBeforePost
    BeforeDelete = QryPerfisBeforeDelete
    OnDeleteError = QryPerfisDeleteError
    OnPostError = QryErroBanco
    SQL.Strings = (
      'SELECT * FROM perfil ORDER BY nome')
    Left = 640
    Top = 96
  end
  object DsPerfis: TDataSource
    DataSet = QryPerfis
    Left = 640
    Top = 152
  end
  object QryPerfisLista: TFDQuery
    SQL.Strings = (
      'SELECT id, nome FROM perfil ORDER BY nome')
    Left = 560
    Top = 96
  end
  object DsPerfisLista: TDataSource
    DataSet = QryPerfisLista
    Left = 560
    Top = 152
  end
end
