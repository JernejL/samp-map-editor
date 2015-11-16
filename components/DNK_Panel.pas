// uses some code from forms.pas

// there are problems with components that use mouse events like Tedit or memo if you place them on this component ...

unit DNK_Panel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  Tbordericons_ = (smsystem_menu, smMaximize, smMinimize);
  Tbordericons = set of Tbordericons_;
  TDNK_Panel = class(Tpanel)
  private
    { Private declarations }
    Fsizable:boolean;
    FTitleBar:boolean;
    Ftoolwindow:boolean;
    Fbordericons: Tbordericons;
    fIcon : TIcon;
    fonclosequery : TNotifyEvent;
    procedure Setsizable(value:boolean);
    procedure SetTitleBar(value:boolean);
    procedure Settoolwindow(value:boolean);
    procedure Setbordericons(value:Tbordericons);
    procedure SetIcon(Value : TIcon);
    procedure IconChanged(Sender: TObject);
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;
    procedure WMIconEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ICONERASEBKGND;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property sizable:boolean read fsizable write Setsizable;
    property TitleBar:boolean read fTitleBar write SetTitleBar;
    property toolwindow:boolean read ftoolwindow write Settoolwindow;
    property Bordericons: Tbordericons read Fbordericons write Setbordericons;
    property Icon : TIcon read fIcon write SetIcon;
    property onclosequery : TNotifyEvent read Fonclosequery write Fonclosequery;
    property ShowHint;
    property OnMouseMove;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnExit;
    property OnEnter;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property TabOrder;
    property TabStop;
    property OnstartDock;
    property OnstartDrag;
    property Visible;
    property Popupmenu;
    property helpcontext;
    property cursor;
    property dragkind;
    property dragmode;
    property dragcursor;

  end;

procedure Register;

implementation

// WM_ERASEBKGND:
// WM_ICONERASEBKGND;

procedure TDNK_Panel.WMIconEraseBkgnd(var Message: TWMEraseBkgnd);
begin
SendMessage(Handle, WM_SETICON, 1, ficon.Handle);
end;

{procedure TCustomForm.WMIconEraseBkgnd(var Message: TWMIconEraseBkgnd);
begin
FillRect(Message.DC, ClientRect, Application.MainForm.Brush.Handle)
end; }

procedure TDNK_Panel.IconChanged(Sender: TObject);
begin
SendMessage(Handle, WM_SETICON, 1, ficon.Handle);
end;

procedure TDNK_Panel.SetIcon(Value : Ticon);
begin
if Value <> fIcon then
begin
fIcon.Assign(value);
end;
end;

procedure TDNK_Panel.WMClose(var Message: TWMClose);
begin
if assigned(Fonclosequery)then Fonclosequery(self);
visible:=false;
end;

procedure TDNK_Panel.CreateParams(var Params: TCreateParams);
begin
inherited;
Params.Style := Params.Style and not (WS_GROUP or WS_TABSTOP);

if fsizable = true then Params.Style:=Params.Style or WS_THICKFRAME;
if fsizable = false then Params.Style:=Params.Style AND NOT WS_THICKFRAME;

if fTitleBar = true then Params.Style:=Params.Style or WS_CAPTION;
if fTitleBar = false then Params.Style:=Params.Style and not WS_CAPTION;

if (smsystem_menu in Fbordericons) then
Params.Style:=Params.Style or WS_SYSMENU
else begin
Params.Style:=Params.Style AND NOT WS_SYSMENU;

end;
if (smMaximize in Fbordericons) then
Params.Style:=Params.Style or WS_MAXIMIZEBOX
else
Params.Style:=Params.Style AND NOT WS_MAXIMIZEBOX;

if (smMinimize in Fbordericons) then
Params.Style:=Params.Style or WS_GROUP
else
Params.Style:=Params.Style AND NOT WS_GROUP;

if ftoolwindow = true then Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW;
if ftoolwindow = false then Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW;

//SendMessage(Handle, WM_SETICON, 1, ficon.Handle);
end;

constructor TDNK_Panel.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
controlStyle:=ControlStyle+[csOpaque, csReplicatable, csCaptureMouse, csAcceptsControls];
TitleBar:=true;
bordericons:=bordericons+[smsystem_menu]+[smMaximize]+[smMinimize];
sizable:=true;
width:=188;
height:=130;
fIcon:= ticon.create;
FIcon.OnChange := IconChanged;
end;

destructor TDNK_Panel.Destroy;
begin
fIcon.free;
inherited Destroy;
end;

procedure TDNK_Panel.Setsizable(Value: boolean);
begin
Fsizable:=Value;
RecreateWnd;
end;

procedure TDNK_Panel.setTitleBar(Value: boolean);
begin
FTitleBar:=Value;
RecreateWnd;
end;

procedure TDNK_Panel.settoolwindow(Value: boolean);
begin
Ftoolwindow:=Value;
RecreateWnd;
SendMessage(Handle, WM_SETICON, 1, ficon.Handle);
end;

procedure TDNK_Panel.Setbordericons(value:Tbordericons);
begin
Fbordericons:=value;
RecreateWnd;
end;

procedure Register;
begin
  RegisterComponents('DNK components', [TDNK_Panel]);
end;

end.
