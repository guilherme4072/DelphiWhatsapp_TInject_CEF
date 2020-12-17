object BDados: TBDados
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 303
  Width = 380
  object NovoCodigo: TFDQuery
    Connection = BDados
    Left = 136
    Top = 16
  end
  object Outros: TFDQuery
    Connection = BDados
    Left = 224
    Top = 16
  end
  object Pesquisa: TFDQuery
    Connection = BDados
    Left = 128
    Top = 80
  end
  object HoraBanco: TFDQuery
    Connection = BDados
    Left = 224
    Top = 80
  end
  object Parametro: TFDQuery
    Connection = BDados
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDefault
    SQL.Strings = (
      'SELECT * FROM NFEPARAMETRO WHERE PARAMETRO = :wParametro')
    Left = 40
    Top = 80
    ParamData = <
      item
        Name = 'WPARAMETRO'
        ParamType = ptInput
      end>
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrNone
    Left = 40
    Top = 152
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 40
    Top = 216
  end
  object BDados: TFDConnection
    Params.Strings = (
      'Password=masterkey'
      'User_Name=sysdba'
      'DriverID=FB')
    LoginPrompt = False
    Left = 40
    Top = 20
  end
end
