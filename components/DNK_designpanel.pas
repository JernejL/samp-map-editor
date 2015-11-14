unit DNK_designpanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TDNK_designpanel = class(TPanel)
  private
    { Private declarations }
    onchangeevent: TNotifyEvent;
    FBordersize: integer;
    allowevent: boolean;
    procedure setBordersize(Value: integer);
    procedure WMMOVE(var message: TWMMove); message  WM_MOVE;
    procedure WMSIZE(var message: TWMSize); message  WM_SIZE;
  protected
    { Protected declarations }
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove (Shift: TShiftState; X, Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property Onchange: TNotifyEvent read onchangeevent write onchangeevent;
    property Bordersize : integer read FBordersize write setBordersize;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure TDNK_designpanel.WMMOVE(var message: TWMMove);
begin
if allowevent= true then if Assigned(onchangeevent) then onchangeevent(Self);
end;

procedure TDNK_designpanel.WMSIZE(var message: TWMSize);
begin
if allowevent= true then if Assigned(onchangeevent) then onchangeevent(Self);
end;

constructor TDNK_designpanel.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
Width := 180;
Height := 80;
Font.Name := 'Tahoma';
Font.Color := clblack;
Font.Size := 8;
setBordersize(3);
end;

procedure TDNK_designpanel.setBordersize(Value: integer);
begin
FBordersize:= value;
invalidate;
end;

procedure TDNK_designpanel.MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
ptrect: Trect;

procedure sendmsg(msg: integer);
begin
ReleaseCapture; // important!
SendMessage(Handle, WM_NCLBUTTONDOWN, msg, 0);
end;

begin
inherited MouseDown (Button, Shift, X, Y);
try
allowevent:= true;

// send message that convinces windows that user clicked somewhere on
// control's border but panel doesn't have a border, this is cheating :)

// center
ptrect:= rect(FBordersize, FBordersize, width-FBordersize, height-FBordersize);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTCAPTION);

// left top
ptrect:= rect(0,0,FBordersize,FBordersize);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTTOPLEFT);
// right top
ptrect:= rect(width-FBordersize,0, width, FBordersize);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTTOPRIGHT);
// left bottom
ptrect:= rect(0,height-FBordersize,FBordersize,height);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTBOTTOMLEFT);
// right bottom
ptrect:= rect(width-FBordersize, height-FBordersize, width, height);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTBOTTOMRIGHT);

// top
ptrect:= rect(FBordersize,0, width-FBordersize, FBordersize);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTTOP);
// bottom
ptrect:= rect(FBordersize,height-FBordersize, width-FBordersize, height);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTBOTTOM);
// left
ptrect:= rect(0, FBordersize, FBordersize, height-FBordersize);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTLEFT);
// right
ptrect:= rect(width-FBordersize, FBordersize, width, height-FBordersize);
if ptinrect(ptrect,point(x,y)) then sendmsg(HTRIGHT);

finally
allowevent:= false;
end;
end;

procedure TDNK_designpanel.MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
try
inherited MouseUp (Button, Shift, X, Y);
except end;
end;

procedure TDNK_designpanel.MouseMove (Shift: TShiftState; X, Y: Integer);
var
ptrect: Trect;
begin
inherited MouseMove (shift, X, Y);
// change the cursor depending on where it is

// center
ptrect:= rect(FBordersize, FBordersize, width-FBordersize, height-FBordersize);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeAll;

// left top
ptrect:= rect(0,0,FBordersize,FBordersize);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeNWSE;
// right top
ptrect:= rect(width-FBordersize,0, width, FBordersize);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeNESW;
// left bottom
ptrect:= rect(0,height-FBordersize,FBordersize,height);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeNESW;
// right bottom
ptrect:= rect(width-FBordersize, height-FBordersize, width, height); 
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeNWSE;

// top
ptrect:= rect(FBordersize,0, width-FBordersize, FBordersize);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeNS;
// bottom
ptrect:= rect(FBordersize,height-FBordersize, width-FBordersize, height);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeNS;
// left
ptrect:= rect(0, FBordersize, FBordersize, height-FBordersize);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeWE;
// right
ptrect:= rect(width-FBordersize, FBordersize, width, height-FBordersize);
if ptinrect(ptrect,point(x,y)) then cursor:=crSizeWE;
end;

procedure Register;
begin
  RegisterComponents('DNK Components', [TDNK_designpanel]);
end;

end.
