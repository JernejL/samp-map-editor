object wnd_carcolorpicker: Twnd_carcolorpicker
  Left = 2016
  Top = 63
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Car Colors'
  ClientHeight = 449
  ClientWidth = 202
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object DrawGrid1: TDrawGrid
    Left = 3
    Top = 30
    Width = 196
    Height = 196
    ColCount = 16
    Ctl3D = False
    DefaultColWidth = 12
    DefaultRowHeight = 12
    FixedCols = 0
    RowCount = 16
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goThumbTracking]
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 0
    OnClick = DrawGrid1Click
    OnDrawCell = DrawGrid1DrawCell
  end
  object CheckBox1: TCheckBox
    Left = 3
    Top = 9
    Width = 196
    Height = 17
    Caption = 'Use Random Primary Color'
    TabOrder = 1
    OnClick = DrawGrid1Click
  end
  object DrawGrid2: TDrawGrid
    Left = 3
    Top = 250
    Width = 196
    Height = 196
    ColCount = 16
    Ctl3D = False
    DefaultColWidth = 12
    DefaultRowHeight = 12
    FixedCols = 0
    RowCount = 16
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goThumbTracking]
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 2
    OnClick = DrawGrid1Click
    OnDrawCell = DrawGrid1DrawCell
  end
  object CheckBox2: TCheckBox
    Left = 3
    Top = 229
    Width = 196
    Height = 17
    Caption = 'Use Random Secondary Color'
    TabOrder = 3
    OnClick = DrawGrid1Click
  end
end
