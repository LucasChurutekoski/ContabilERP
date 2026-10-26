object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Entrar - Cont'#225'bil ERP'
  ClientHeight = 196
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object LblUsuario: TLabel
    Left = 24
    Top = 16
    Width = 40
    Height = 15
    Caption = 'Usu'#225'rio'
  end
  object LblSenha: TLabel
    Left = 24
    Top = 72
    Width = 32
    Height = 15
    Caption = 'Senha'
  end
  object LblErro: TLabel
    Left = 24
    Top = 128
    Width = 3
    Height = 15
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EdtUsuario: TEdit
    Left = 24
    Top = 37
    Width = 272
    Height = 23
    TabOrder = 0
  end
  object EdtSenha: TEdit
    Left = 24
    Top = 93
    Width = 272
    Height = 23
    PasswordChar = '*'
    TabOrder = 1
  end
  object BtnEntrar: TButton
    Left = 128
    Top = 156
    Width = 80
    Height = 25
    Caption = 'Entrar'
    Default = True
    TabOrder = 2
    OnClick = BtnEntrarClick
  end
  object BtnCancelar: TButton
    Left = 216
    Top = 156
    Width = 80
    Height = 25
    Cancel = True
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 3
  end
end
