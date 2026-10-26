object DM: TDM
  Height = 300
  Width = 400
  PixelsPerInch = 120
  object Conexao: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'LockingMode=Normal'
      'StringFormat=Unicode')
    LoginPrompt = False
    Left = 70
    Top = 50
  end
  object SQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 70
    Top = 140
  end
end
