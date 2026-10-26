object DM: TDM
  Height = 240
  Width = 320
  object Conexao: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'LockingMode=Normal'
      'StringFormat=Unicode')
    LoginPrompt = False
    Left = 56
    Top = 40
  end
  object SQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 56
    Top = 112
  end
end
