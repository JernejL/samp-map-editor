object wnd_report: Twnd_report
  Left = 405
  Top = 140
  Width = 577
  Height = 517
  Caption = 'wnd_report'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  DesignSize = (
    569
    490)
  PixelsPerInch = 96
  TextHeight = 13
  object Label43: TLabel
    Left = 3
    Top = 291
    Width = 563
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = ' Describe the problem:'
    Color = clInactiveCaption
    Font.Charset = ANSI_CHARSET
    Font.Color = clInactiveCaptionText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object Label1: TLabel
    Left = 317
    Top = 462
    Width = 211
    Height = 13
    Caption = '^ First write a report into field above.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object reports: TMemo
    Left = 3
    Top = 4
    Width = 563
    Height = 283
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'reports')
    ReadOnly = True
    TabOrder = 0
    WordWrap = False
  end
  object reportuser: TMemo
    Left = 3
    Top = 313
    Width = 563
    Height = 142
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 7012351
    Lines.Strings = (
      
        'Please write your email address and describe the problem you hav' +
        'e with the program.')
    TabOrder = 1
    WordWrap = False
    OnChange = reportuserChange
  end
  object btn_send: TBitBtn
    Left = 237
    Top = 462
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Send report!'
    Enabled = False
    TabOrder = 2
    OnClick = btn_sendClick
  end
end
