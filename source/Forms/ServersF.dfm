object frmServers: TfrmServers
  Left = 256
  Top = 127
  Width = 435
  Height = 260
  BorderIcons = [biSystemMenu]
  Caption = 'Locate Servers'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PopupMode = pmAuto
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object imgServer: TImage
    Left = 304
    Top = 200
    Width = 32
    Height = 32
    AutoSize = True
    Visible = False
  end
  object pnlPages: TPanel
    Left = 0
    Top = 0
    Width = 427
    Height = 232
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    object lvServers: TListView
      Left = 1
      Top = 1
      Width = 425
      Height = 230
      Hint = 'list of servers'
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsNone
      Checkboxes = True
      Columns = <
        item
          AutoSize = True
          Caption = 'Server Name'
        end
        item
          AutoSize = True
          Caption = 'Comment'
        end>
      ColumnClick = False
      HideSelection = False
      Items.ItemData = {
        014D0000000100000000000000FFFFFFFFFFFFFFFF0100000000000000096C00
        6F00630061006C0068006F0073007400116C006F00630061006C0068006F0073
        007400200063006F006D006D0065006E007400FF00}
      ReadOnly = True
      RowSelect = True
      SmallImages = dmResource.imlServers
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object tmrLocate: TTimer
    OnTimer = tmrLocateTimer
    Left = 232
    Top = 65520
  end
end
