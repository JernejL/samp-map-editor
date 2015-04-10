unit DNK_edit;

interface

uses
  Windows, Graphics, Classes, Controls, Forms, SysUtils, StdCtrls, Menus, messages;

type
  TDNK_edit = class(TEdit)
  private
    FAlignment : TAlignment;
    Bmp: TBitmap;
    fflat:boolean;
    fnumbersonly:boolean;
    procedure verticalcenter;
    procedure SetBmp(Value: TBitmap);
    procedure Setflat(Value: boolean);
    procedure Setnumbersonly(Value: boolean);
    procedure CMEnter(var message:TCMGotFocus);message CM_ENTER;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WM_SETFOCUS(var message:TWMSetFocus);message WM_SETFOCUS;
    procedure WM_KILLFOCUS(var message:TWMKillFocus);message WM_KILLFOCUS;
    procedure caret;
  protected
    procedure CreateParams(var Params:TCreateParams); override;
    procedure SetAlignment(NewValue:TAlignment);
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    procedure Loaded; override;
    constructor Create(AOwner:TComponent); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Align;
    property Input_caret: TBitmap read Bmp write SetBmp;
    property Flat: boolean read fflat write Setflat;
    property Numbersonly: boolean read fnumbersonly write Setnumbersonly;
    property OnKeydown;
    property OnKeyUp;
    property OnKeypress;
    property OnMouseDown;
    property OnMouseUp;
    property Anchors;
  end;

procedure Register;

implementation

procedure TDNK_edit.verticalcenter;
var
loc: Trect;
begin
// this was supposed to center text verticaly
// doesn't work because a strange bug
// probably in Tedit or Tcustomedit vcl code?
SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
Loc.Top := clientheight div 2 - font.Height div 2;
Loc.Bottom := clientheight div 2 + font.Height div 2;
SendMessage(Handle, EM_SETRECT, 0, LongInt(@Loc));
end;

procedure tDNK_edit.SetBmp(Value: TBitmap);
begin
Bmp.Assign(value);
caret;
RecreateWnd;
end;

procedure tDNK_edit.Setflat(Value: boolean);
begin
fflat:=value;
RecreateWnd;
end;

procedure tDNK_edit.Setnumbersonly(Value: boolean);
begin
fnumbersonly:=value;
end;

procedure tDNK_edit.caret;
begin
if bmp.empty = false then begin
CreateCaret(self.Handle, Bmp.Handle, 0, 0);
ShowCaret(self.Handle);
end;
invalidate;
end;

procedure tDNK_edit.KeyDown(var Key: Word; Shift: TShiftState);
begin
inherited;
end;

procedure tDNK_edit.KeyUp(var Key: Word; Shift: TShiftState);
begin
try
if fnumbersonly = true then if text = '' then begin
text := '0';
selectall;
end;
except end;
inherited;
end;

procedure tDNK_edit.KeyPress(var Key: char);
begin
inherited;
if fnumbersonly = true then begin
if Key <> '-' then begin
if Key <> '' then begin // backspace
if ((UpCase(Key) < '0') or (UpCase(Key) > '9')) then Key := #0;
end;
end;
end;
end;

procedure tDNK_edit.WM_SETFOCUS(var message:TWMSetFocus);
begin
inherited;
caret;
end;

procedure tDNK_edit.WM_KILLFOCUS(var message:TWMKillFocus);
begin
inherited;
HideCaret(self.handle);
DestroyCaret;
end;

procedure tDNK_edit.CMEnter(var message:TCMGotFocus);
begin
inherited;
end;

procedure tDNK_edit.MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
inherited;
end;

procedure tDNK_edit.MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
inherited;
end;

procedure TDNK_edit.Loaded;
begin
inherited;
end;

Constructor TDNK_edit.Create(AOwner:TComponent);
begin
inherited Create(AOwner);
bmp:=tbitmap.Create;
end;

procedure TDNK_edit.WMSize(var Message: TWMSize);
begin
inherited;
verticalcenter;
end;

procedure TDNK_edit.CreateParams(var Params: TCreateParams);
begin
inherited CreateParams(Params);
case Alignment of
taLeftJustify  : Params.Style := Params.Style or ES_LEFT;
taRightJustify : Params.Style := Params.Style or ES_RIGHT;
taCenter       : Params.Style := Params.Style or ES_CENTER;
end;
if fflat=true then params.ExStyle:=params.ExStyle OR ws_ex_staticedge;
if fflat=false then params.ExStyle:=params.ExStyle and not ws_ex_staticedge;
end;

procedure TDNK_edit.SetAlignment(NewValue:TAlignment);
begin
if FAlignment<>NewValue then begin
FAlignment:=NewValue;
RecreateWnd;
verticalcenter;
end;
end;

procedure Register;
begin
RegisterComponents('DNK components', [TDNK_edit]);
end;

end.
