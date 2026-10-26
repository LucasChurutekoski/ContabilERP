object FrmResumo: TFrmResumo
  Left = 0
  Top = 0
  Caption = 'Resumo patrimonial'
  ClientHeight = 480
  ClientWidth = 620
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object MemoResumo: TMemo
    Left = 0
    Top = 0
    Width = 620
    Height = 410
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object PnlRodape: TPanel
    Left = 0
    Top = 410
    Width = 620
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object LblProva: TLabel
      Left = 16
      Top = 24
      Width = 3
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnAtualizar: TButton
      Left = 412
      Top = 22
      Width = 96
      Height = 27
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = BtnAtualizarClick
    end
    object BtnFechar: TButton
      Left = 516
      Top = 22
      Width = 88
      Height = 27
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
