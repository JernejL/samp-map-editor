// unit DNK_RoundSlider
//
// round slider with 3d and flat appearace
// it is almost fully customizable, except you can't specify background bitmap.
//
// !WARNING! the control is subclassed from Timage, because drawing on Timage's canvas
// is 'FLICKER FREE', because of that there are 2 problems and 2 advantages:
// - the control won't repaint if resized at design or runtime excpt if you manualy call paint procedure
// - the control has additional peoperties and events
//   from Timage (like center and stretch) please LEAVE those peoperties set to default
//   it will cause strange behaviour...
// - the transparent property can be used as with normal Timage component
// - the control is flicker free

unit DNK_RoundSlider;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, math,
  extctrls;

type
  TDNK_Roundslider = class(Timage)
  private
    { Private declarations }
    fcolor : TColor;
    fcolor_light : TColor;
    fcolor_shadow : TColor;
    fbordercolor : TColor;
    MDown: TMouseEvent;
    MUp: TMouseEvent;
    Enab: Boolean;
    fflat:boolean;
    Fspacer: integer;
    Flinesize: integer;
    Fbordersize: integer;
    fposition: integer;
    fmax: integer;
    fmin: integer;
    fbarcolor: tcolor;
    fonchange : TNotifyEvent;
    procedure Setposition(Value: integer);
    procedure Setmax(Value: integer);
    procedure Setmin(Value: integer);
    procedure Setbarcolor(Value: tcolor);
    procedure setspacer(Value: integer);
    procedure setbordersize(Value: integer);
    procedure setlinesize(Value: integer);
    procedure SetCol(Value: TColor);
    procedure set_color_light(Value: TColor);
    procedure set_color_shadow(Value: TColor);
    procedure set_bordercolor(Value: TColor);
    procedure setflat(Value: boolean);
    procedure setEnab(value:boolean);
  protected
    { Protected declarations }
    updating: boolean;
    procedure translatecoordinates(x, y: integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint;// override;
    procedure Resize;// override;
  published
    { Published declarations }
    property OnChange : TNotifyEvent index 0 read fonchange write fonchange;
    property Spacer : integer read Fspacer write setspacer;
    property BorderSize : integer read Fbordersize write setbordersize; //[ doesn't work yet! ]
    property LineSize : integer read flinesize write setlinesize;
    property Color : TColor read fColor write SetCol;
    property Color_light : TColor read fcolor_light write set_color_light default clwhite ;
    property Color_shadow : TColor read fcolor_shadow write set_color_shadow default clgray ;
    property Bordercolor : TColor read fbordercolor write set_bordercolor default clgray ;
    property Enabled : Boolean read Enab write setEnab;
    property Flat : Boolean read fflat write setflat;
    property OnMouseDown: TMouseEvent read MDown write MDown;
    property OnMouseUp: TMouseEvent read MUp write MUp;
    property barcolor: tcolor read fbarcolor write Setbarcolor;
    property position: integer read fposition write Setposition;
    property max: integer read fmax write Setmax;
    property min: integer read fmin write Setmin;
    property ShowHint;
    property OnMouseMove;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property Visible;
    property Popupmenu;
    property Cursor;
    property Dragkind;
    property Dragmode;
    property Dragcursor;

{   property Autosize index -1;
    property Center index -1;
    property Incrementaldisplay index -1;
    property Stretch index -1;}
  end;

procedure Register;

implementation

procedure TDNK_Roundslider.Resize;
begin
paint;
end;

procedure TDNK_Roundslider.translatecoordinates(x, y: integer);
var
angle: integer;
xcoord: integer;
ycoord: integer;
radius: integer;
begin
radius:= height div 2;
xcoord:= x- radius;
ycoord:= y- radius;

angle:= round(max + (max div 2)* arctan2(- ycoord, xcoord)/ pi);

if angle < min then angle:= angle+ max else if angle > max then angle:= angle- max;

position:= angle;
if Assigned (fonchange) then Onchange (self);
paint;
end;

procedure TDNK_Roundslider.setspacer(Value: integer);
begin
Fspacer:= value;
Paint;
end;

procedure TDNK_Roundslider.setlinesize(Value: integer);
begin
Flinesize:= value;
Paint;
end;

procedure TDNK_Roundslider.setbordersize(Value: integer);
begin
//showmessage(inttostr(value mod 2)); 
Fbordersize:= value;
Paint;
end;

constructor TDNK_Roundslider.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
Width := 100;
Height := 100;

fposition:= 0;
fmax:= 100;
fmin:= 0;
fColor := clbtnface;
fcolor_light := $00E8E8E8;
fcolor_shadow := $008C8C8C;
fbordercolor:=clblack;
fbarcolor:= clblue;
fspacer:= 3;
fbordersize:= 2;

Enab := true;
paint;
end;

destructor TDNK_Roundslider.Destroy;
begin
inherited Destroy;
end;

procedure TDNK_Roundslider.Paint;
var
b: Tbitmap;
angle: real;
radius: integer;

procedure paintbmptransparent(from: Tbitmap; drawonthis: Tcanvas; transpcolor: Tcolor);
begin
drawonthis.brush.Style:= bsclear;
drawonthis.BrushCopy(rect(0,0, from.width, from.height), from, rect(0,0, from.width, from.height), transpcolor);
end;

begin
try

picture.bitmap.Width:= width;
picture.bitmap.height:= height;

with canvas do begin
pen.color:= color_light;
brush.color:= color_light;
Canvas.Polygon([
Point(width, 0),
Point(0,0),
Point(0, height)
]);

pen.color:= color_shadow;
brush.color:= color_shadow;
Canvas.Polygon([
Point(width, 0),
Point(width, height),
Point(0, height)
]);

b:= Tbitmap.create;
b.width:= width;
b.height:= height;

b.canvas.Pen.Color:= color;
b.canvas.Brush.Color:= color;

b.canvas.FillRect(b.Canvas.ClipRect);

b.canvas.Pen.Color:= clFuchsia;
b.canvas.Brush.Color:= color;

b.canvas.pen.Width:= BorderSize;
b.canvas.Ellipse(1+ BorderSize div 2, 1+ BorderSize div 2, width-BorderSize div 2, height-BorderSize div 2);

paintbmptransparent(b, canvas, clfuchsia);

b.canvas.copyrect(rect(0,0, width, height), canvas, rect(0,0, width, height));

b.canvas.Pen.Color:= clFuchsia;
b.canvas.Brush.Color:= clFuchsia;
b.canvas.Ellipse(spacer+1, spacer+1, width-spacer-1, height-spacer-1);



radius:= width div 2;
angle:= -position * pi / (max div 2);

Canvas.Pen.Width:= linesize;
canvas.pen.color:= barcolor;
canvas.moveto(radius, radius);
canvas.lineto(radius + round(radius *sin(angle)), radius + round(radius *cos(angle)));

paintbmptransparent(b, canvas, clfuchsia);

b.free;

if flat= false then begin
Pen.Color:= bordercolor;
pen.Width:= 1;
Brush.style:= bsclear;
Ellipse(0, 0, width, height);
end;

end;
except end;
end; // paint

procedure TDNK_Roundslider.SetCol(Value: TColor);
begin
fColor := Value;
Paint;
end;

procedure TDNK_Roundslider.set_color_light(Value: TColor);
begin
fcolor_light := Value;
Paint;
end;

procedure TDNK_Roundslider.set_color_shadow(Value: TColor);
begin
fcolor_shadow := Value;
Paint;
end;

procedure TDNK_Roundslider.set_bordercolor(Value: TColor);
begin
fbordercolor := Value;
Paint;
end;

procedure TDNK_Roundslider.Setflat(Value: boolean);
begin
fflat := value;
Paint;
end;

procedure TDNK_Roundslider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
inherited;
updating:= true;
translatecoordinates(y, x);
end;

procedure TDNK_Roundslider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
inherited;
updating:= false
end;

procedure TDNK_Roundslider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
inherited;
if enabled then if updating then translatecoordinates(y, x)
end;

procedure TDNK_Roundslider.Setposition(Value: integer);
begin
if value < min then value:=min;
if value > max then value:=max;

if value <> fposition then begin
fposition:=value;
if Assigned (fonchange) then Onchange (self);
paint;
end;
end;

procedure TDNK_Roundslider.Setbarcolor(value : tcolor);
begin
fbarcolor:=value;
Paint;
end;

procedure TDNK_Roundslider.Setmax(Value: integer);
begin
fmax:=value;
paint;
end;

procedure TDNK_Roundslider.Setmin(Value: integer);
begin
fmin:=value;
paint;
end;


procedure TDNK_Roundslider.setEnab(value:boolean);
begin
Enab:=value;
Paint;
end;

procedure Register;
begin
  RegisterComponents('DNK Components', [TDNK_Roundslider]);
end;

end.
