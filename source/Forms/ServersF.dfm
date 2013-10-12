object frmServers: TfrmServers
  Left = 256
  Top = 157
  Width = 523
  Height = 334
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
    Width = 507
    Height = 296
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    object lvServers: TListView
      Left = 1
      Top = 1
      Width = 505
      Height = 294
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
        end
        item
          Caption = 'MAC'
          Width = 140
        end>
      ColumnClick = False
      HideSelection = False
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
