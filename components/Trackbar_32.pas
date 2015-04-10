unit Trackbar_32;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, CommCtrl;

type
  T___drawstyle = (Normal, Special, Flat, unknown);
  TTrackbar_32 = class(TTrackBar)
  private
    { Private declarations }
    _thumbcolor : TColor;
    _trackcolor : TColor;
    _color_light : TColor;
    _color_shadow : TColor;
    _bordercolor : TColor;
    FEnableselrange:boolean;
    Fdrawfocusrect:boolean;
    Fautohint:boolean;
    _drawstyle:T___drawstyle;
    Bmp: TBitmap;
    FCanvas: TCanvas;
    procedure set_thumbcolor(Value: TColor);
    procedure set_trackcolor(Value: TColor);
    procedure set_color_light(Value: TColor);
    procedure set_color_shadow(Value: TColor);
    procedure set_bordercolor(Value: TColor);
    procedure set_drawstyle(Value: T___drawstyle);
    procedure SetEnableselrange(value:boolean);
    procedure Setdrawfocusrect(value:boolean);
    procedure Setautohint(value:boolean);
    procedure SetBmp(Value: TBitmap);
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    { Protected declarations }
    procedure drawbitmap;
    procedure drawthumb;
    procedure drawtrack;
    procedure drawflatthumb;
    procedure drawflattrack;
    procedure drawunknowntrack;
    procedure Paint;
    procedure PaintWindow(DC: HDC); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove (Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    { Published declarations }
    property Enableselrange:boolean read fEnableselrange write SetEnableselrange;
    property DrawFocusRect:boolean read Fdrawfocusrect write Setdrawfocusrect;
    property Autohint:boolean read fautohint write Setautohint;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property Color;
    property thumbcolor : TColor read _thumbcolor write set_thumbcolor;
    property trackcolor : TColor read _trackcolor write set_trackcolor;
    property color_light : TColor read _color_light write set_color_light;
    property color_shadow : TColor read _color_shadow write set_color_shadow;
    property bordercolor : TColor read _bordercolor write set_bordercolor;
    property Drawstyle : T___drawstyle read _drawstyle write set_drawstyle;
    property Glyph: TBitmap read Bmp write SetBmp;
  end;

procedure Register;

implementation

// DRAW SPECIAL TRACKBAR //

procedure TTrackbar_32.SetBmp(Value: TBitmap);
begin
Bmp.Assign(value);
invalidate;
end;

procedure TTrackbar_32.drawbitmap;
var
thumbrect : TRect;
begin
if bmp.Empty = false then begin
SendMessage(self.Handle, TBM_GETTHUMBRECT, 0, Integer(@thumbrect));

fCanvas.BrushCopy(thumbrect,bmp,
Rect(0,0,bmp.width,bmp.height),bmp.Canvas.pixels[0,0]);

end;
end;

procedure TTrackbar_32.drawthumb;
var channelrect, thumbrect : TRect;
var left_,top_,width_,height_:integer;
begin
SendMessage(self.Handle, TBM_GETTHUMBRECT, 0, Integer(@thumbrect));
SendMessage(self.Handle, TBM_GETCHANNELRECT, 0, Integer(@channelrect));

left_:=thumbrect.left;
top_:=thumbrect.top;
width_:=thumbrect.left+thumbrect.right-thumbrect.left;
height_:=thumbrect.top+thumbrect.bottom-thumbrect.top;

// vertical //

if orientation = trVertical then begin
if tickmarks = tmBoth then begin
Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_bordercolor;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_color_light;
Fcanvas.Rectangle(left_+1,top_+1,width_-1,height_-1);
Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Rectangle(left_+2,top_+2,width_-1,height_-1);
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.Rectangle(left_+2,top_+2,width_-2,height_-2);
end;

if tickmarks = tmBottomRight then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.pen.Style:=psSolid;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_bordercolor;

Fcanvas.Polyline([
Point(thumbrect.left,thumbrect.bottom),
Point(thumbrect.left,thumbrect.top),
Point(thumbrect.left+width_ div 2 + width_ div 4,thumbrect.top),
Point(thumbrect.right,(thumbrect.top + thumbrect.bottom-1) div 2),
Point(thumbrect.left+width_ div 2 + width_ div 4,thumbrect.bottom),
Point(thumbrect.left,thumbrect.bottom)
]);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(1+thumbrect.left,thumbrect.bottom-2),
Point(1+thumbrect.left,1+thumbrect.top),
Point(1+thumbrect.left+width_ div 2 + width_ div 4 -1,1+thumbrect.top),
Point(1+thumbrect.right -1,1+(thumbrect.top + thumbrect.bottom-1) div 2 )
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.right-1,(thumbrect.top + thumbrect.bottom-1) div 2),
Point(thumbrect.left+width_ div 2 + width_ div 4 ,thumbrect.bottom -1),
Point(thumbrect.left,thumbrect.bottom-1)
]);
   
end;

if tickmarks = tmTopLeft then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.pen.Style:=psSolid;
Fcanvas.Rectangle(left_,top_,width_,height_);

Fcanvas.pen.Color:=_bordercolor;

Fcanvas.Polyline([
Point(thumbrect.right,thumbrect.bottom),
Point(thumbrect.right,thumbrect.top),
Point(thumbrect.left+width_ div 2 - width_ div 4,thumbrect.top),   
Point(thumbrect.left,(thumbrect.top + thumbrect.bottom-1) div 2),
Point(thumbrect.left+width_ div 2 - width_ div 4,thumbrect.bottom),
Point(thumbrect.right,thumbrect.bottom)
]);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(1+thumbrect.right -2,1+thumbrect.top),
Point(thumbrect.left+width_ div 2 - width_ div 4 ,1+thumbrect.top),
Point(1+thumbrect.left -1,1+(thumbrect.top + thumbrect.bottom-1) div 2 )
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.left+1,(thumbrect.top + thumbrect.bottom-1) div 2),
Point(thumbrect.left+width_ div 2 - width_ div 4 ,thumbrect.bottom -1),
Point(thumbrect.right-1,thumbrect.bottom-1),
Point(thumbrect.right-1,thumbrect.top+1)
]);
end;
end;

// horizontal //

if orientation = trHorizontal then begin
if tickmarks = tmBoth then begin
Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_bordercolor;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_color_light;
Fcanvas.Rectangle(left_+1,top_+1,width_-1,height_-1);
Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Rectangle(left_+2,top_+2,width_-1,height_-1);
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.Rectangle(left_+2,top_+2,width_-2,height_-2);
end;

if tickmarks = tmBottomRight then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.Rectangle(left_,top_,width_,height_);

Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_bordercolor;

Fcanvas.Polyline([
Point(thumbrect.left,thumbrect.top),
Point(thumbrect.right-1,thumbrect.top),
Point(thumbrect.right-1,thumbrect.top + thumbrect.bottom div 2),
Point((thumbrect.left + thumbrect.right-1) div 2,thumbrect.bottom-height_ div 8),//
Point(thumbrect.left,thumbrect.top + thumbrect.bottom div 2),
Point(thumbrect.left,thumbrect.top)
]);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(thumbrect.right-2,thumbrect.top+1),
Point(thumbrect.left+1,thumbrect.top+1),
Point(thumbrect.left+1,(thumbrect.top+1 + thumbrect.bottom div 2 ) -1 ),
Point((thumbrect.left + thumbrect.right-1) div 2 +1 ,thumbrect.bottom-height_ div 8 )//,
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.right-2,thumbrect.top+2),
Point(thumbrect.right-2,(thumbrect.top-2 + thumbrect.bottom div 2 ) +2 ),
Point((thumbrect.right + thumbrect.left+2) div 2 -2 ,thumbrect.bottom-height_ div 8 )//,
]);

end;

if tickmarks = tmTopLeft then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.Rectangle(left_,top_,width_,height_);

Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_bordercolor;

Fcanvas.Polyline([
Point(thumbrect.right,thumbrect.bottom),
Point(thumbrect.left,thumbrect.bottom),
Point(thumbrect.left,thumbrect.top + thumbrect.bottom div 4),
Point((thumbrect.left + thumbrect.right-1) div 2,thumbrect.top-height_ div 8),
Point(thumbrect.right,thumbrect.top + thumbrect.bottom div 4),
Point(thumbrect.right,thumbrect.bottom)
]);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(thumbrect.left+1,thumbrect.bottom-1),
Point(thumbrect.left+1,thumbrect.top + thumbrect.bottom div 4),
Point((thumbrect.left+1 + thumbrect.right) div 2,thumbrect.top-height_ div 8)
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.left+1,thumbrect.bottom-1),
Point(thumbrect.right-1,thumbrect.bottom-1),
Point(thumbrect.right-1,thumbrect.top + thumbrect.bottom div 4 ),
Point((thumbrect.left + thumbrect.right) div 2,thumbrect.top-height_ div 8 +1)
]);
end;
end;

end;

procedure TTrackbar_32.drawtrack;
var channelrect, thumbrect : TRect;
var left_,top_,width_,height_:integer;
begin

SendMessage(self.Handle, TBM_GETTHUMBRECT, 0, Integer(@thumbrect));
SendMessage(self.Handle, TBM_GETCHANNELRECT, 0, Integer(@channelrect));

left_:=channelrect.left;
top_:=channelrect.top;
width_:=channelrect.left+channelrect.right-channelrect.left;
height_:=channelrect.top+channelrect.bottom-channelrect.top;

// in case if we have vertical trackbar
if orientation = trVertical then begin
left_:=channelrect.left + 8;
top_:=channelrect.top-8;
height_:=(channelrect.left+channelrect.right-1-channelrect.left) -3;
width_:=channelrect.top+channelrect.bottom-channelrect.top;
end;

Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_bordercolor;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Rectangle(left_+1,top_+1,width_-1,height_-1);
Fcanvas.pen.Color:=_color_light;
Fcanvas.Rectangle(left_+2,top_+2,width_-1,height_-1);
Fcanvas.pen.Color:=_trackcolor;
Fcanvas.brush.Color:=_trackcolor;
Fcanvas.Rectangle(left_+2,top_+2,width_-2,height_-2);
end;

// DRAW FLAT TRACKBAR //

procedure TTrackbar_32.drawflatthumb;
var channelrect, thumbrect : TRect;
var left_,top_,width_,height_:integer;
begin
SendMessage(self.Handle, TBM_GETTHUMBRECT, 0, Integer(@thumbrect));
SendMessage(self.Handle, TBM_GETCHANNELRECT, 0, Integer(@channelrect));

left_:=thumbrect.left;
top_:=thumbrect.top;
width_:=thumbrect.left+thumbrect.right-1-thumbrect.left;
height_:=thumbrect.top+thumbrect.bottom-thumbrect.top;

// vertical //

if orientation = trVertical then begin
if tickmarks = tmBoth then begin
Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_color_light;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Rectangle(left_+1,top_+1,width_,height_);
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.Rectangle(left_+1,top_+1,width_-1,height_-1);
end;

if tickmarks = tmBottomright then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.pen.Style:=psSolid;
Fcanvas.Rectangle(left_,top_,width_,height_);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(thumbrect.left,thumbrect.bottom-1),
Point(thumbrect.left,thumbrect.top),
Point(thumbrect.left+width_ div 2 + width_ div 4 ,thumbrect.top),
Point(thumbrect.right-1 ,(thumbrect.top + thumbrect.bottom-1) div 2 )
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.right-1,(thumbrect.top + thumbrect.bottom-1) div 2),
Point(thumbrect.left+width_ div 2 + width_ div 4 ,thumbrect.bottom-1 ),
Point(thumbrect.left,thumbrect.bottom-1)
]);
   
end;

if tickmarks = tmTopLeft then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.pen.Style:=psSolid;
Fcanvas.Rectangle(left_,top_,width_,height_);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(thumbrect.right-1 ,thumbrect.top),
Point(thumbrect.left+width_ div 2 - width_ div 4 ,thumbrect.top),
Point(thumbrect.left ,(thumbrect.top + thumbrect.bottom-1) div 2 )
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.left,(thumbrect.top + thumbrect.bottom-1) div 2),
Point(thumbrect.left+width_ div 2 - width_ div 4 ,thumbrect.bottom-1 ),
Point(thumbrect.right-1,thumbrect.bottom-1),
Point(thumbrect.right-1,thumbrect.top)
]);
end;
end;

// horizontal //

if orientation = trHorizontal then begin
if tickmarks = tmBoth then begin
Fcanvas.pen.Style:=psSolid;
Fcanvas.pen.Color:=_color_light;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Rectangle(left_+1,top_+1,width_,height_);
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.Rectangle(left_+1,top_+1,width_-1,height_-1);
end;

if tickmarks = tmBottomright then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.Rectangle(left_,top_,width_,height_);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(thumbrect.right-1-1,thumbrect.top),
Point(thumbrect.left,thumbrect.top),
Point(thumbrect.left,(thumbrect.top + thumbrect.bottom div 2 -1) -1 ),
Point((thumbrect.left + thumbrect.right-1) div 2 +1,thumbrect.bottom-height_ div 8 )//,
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.right-1,thumbrect.top),
Point(thumbrect.right-1,(thumbrect.top + thumbrect.bottom div 2 -1)  ),
Point((thumbrect.right-1 + thumbrect.left) div 2  ,thumbrect.bottom-height_ div 8 -1)//,
]);

end;

if tickmarks = tmTopLeft then begin
Fcanvas.brush.Color:=_thumbcolor;
Fcanvas.pen.Color:=_thumbcolor;
Fcanvas.Rectangle(left_,top_,width_,height_);

fcanvas.pen.Color:=_color_light;
Fcanvas.Polyline([
Point(thumbrect.left,thumbrect.bottom-1),
Point(thumbrect.left,thumbrect.top + thumbrect.bottom div 4 -1),
Point((thumbrect.left + thumbrect.right-1) div 2,thumbrect.top-height_ div 8)
]);

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Polyline([
Point(thumbrect.left,thumbrect.bottom -1),
Point(thumbrect.right-1,thumbrect.bottom -1),
Point(thumbrect.right-1,thumbrect.top + thumbrect.bottom div 4 -1),
Point((thumbrect.left + thumbrect.right-1) div 2,thumbrect.top-height_ div 8 )
]);
end;
end;
end;

procedure TTrackbar_32.drawflattrack;
var channelrect, thumbrect : TRect;
var left_,top_,width_,height_:integer;
begin

SendMessage(self.Handle, TBM_GETTHUMBRECT, 0, Integer(@thumbrect));
SendMessage(self.Handle, TBM_GETCHANNELRECT, 0, Integer(@channelrect));

left_:=channelrect.left;
top_:=channelrect.top;
width_:=channelrect.left+channelrect.right-1-channelrect.left;
height_:=channelrect.top+channelrect.bottom-channelrect.top;

// in case if we have vertical trackbar
if orientation = trVertical then begin
left_:=channelrect.left + 8;
top_:=channelrect.top;
height_:=(channelrect.left+channelrect.right-1-channelrect.left) ;
width_:=channelrect.top+channelrect.bottom-channelrect.top;
end;

Fcanvas.pen.Color:=_color_shadow;
Fcanvas.Rectangle(left_,top_,width_,height_);
Fcanvas.pen.Color:=_color_light;
Fcanvas.Rectangle(left_+1,top_+1,width_,height_);
Fcanvas.pen.Color:=_trackcolor;
Fcanvas.brush.Color:=_trackcolor;
Fcanvas.Rectangle(left_+1,top_+1,width_-1,height_-1);
end;

procedure TTrackbar_32.drawunknowntrack;
var
channelrect, thumbrect : TRect;
left_,top_,width_,height_:integer;
begin

SendMessage(self.Handle, TBM_GETTHUMBRECT, 0, Integer(@thumbrect));
SendMessage(self.Handle, TBM_GETCHANNELRECT, 0, Integer(@channelrect));

left_:=channelrect.left;
top_:=channelrect.top;
width_:=channelrect.left+channelrect.right-1-channelrect.left;
height_:=channelrect.top+channelrect.bottom-channelrect.top;

Fcanvas.pen.Color:=_color_shadow;

Fcanvas.moveto(left_, height_-1);
Fcanvas.lineto(width_-1, top_);

Fcanvas.pen.Color:=_color_light;
Fcanvas.moveto(width_-1, top_);
Fcanvas.lineto(width_-1, height_);

Fcanvas.moveto(width_-1, height_);
Fcanvas.lineto(left_, height_);

end;

procedure TTrackbar_32.set_drawstyle(Value: T___drawstyle);
begin
_drawstyle := Value;
recreatewnd;
end;

procedure TTrackbar_32.set_thumbcolor(Value: TColor);
begin
_thumbcolor := Value;
Paint;
end;

procedure TTrackbar_32.set_trackcolor(Value: TColor);
begin
_trackcolor := Value;
Paint;
end;

procedure TTrackbar_32.set_color_light(Value: TColor);
begin
_color_light := Value;
Paint;
end;

procedure TTrackbar_32.set_color_shadow(Value: TColor);
begin
_color_shadow := Value;
Paint;
end;

procedure TTrackbar_32.set_bordercolor(Value: TColor);
begin
_bordercolor := Value;
Paint;
end;

procedure TTrackbar_32.WMPaint(var Message: TWMPaint);
begin
PaintHandler(Message);
inherited;
end;

procedure TTrackbar_32.PaintWindow(DC: HDC);
begin
inherited PaintWindow(DC);
FCanvas.Lock;
try
FCanvas.Handle := DC;
try
Paint;
finally
FCanvas.Handle := 0;
end;
finally
FCanvas.Unlock;
end;
end;

procedure TTrackbar_32.Paint;
var Frame:trect;
begin
// no need for painting anythink, leave original trackbar
if _drawstyle = Normal then exit;

// draw trackbar special style
if _drawstyle = Special then begin;
// clear canvas first
Fcanvas.pen.Color:=color;
Fcanvas.brush.Color:=color;
Fcanvas.Rectangle(0,0,width,height);
// draw trackbar
drawtrack;
drawthumb;
end;

// draw trackbar unknown style
if _drawstyle = unknown then begin;
// clear canvas first
Fcanvas.pen.Color:=color;
Fcanvas.brush.Color:=color;
Fcanvas.Rectangle(0,0,width,height);
// draw trackbar
drawunknowntrack;
drawflatthumb;
end;

// draw trackbar flat style
if _drawstyle = Flat then begin;
// clear canvas first
Fcanvas.pen.Color:=color;
Fcanvas.brush.Color:=color;
Fcanvas.Rectangle(0,0,width,height);
// draw trackbar
drawflattrack;
drawflatthumb;
if Fdrawfocusrect = true then begin
Frame := GetClientRect;
if focused then begin
Frame := Rect(Frame.Left,Frame.Top,Frame.Right,Frame.Bottom);
fCanvas.DrawFocusRect(Frame);
end;
end;
end;

// draw bitmap (if there is one ... )
drawbitmap;

end;

procedure TTrackbar_32.Setdrawfocusrect(value:boolean);
begin
inherited;
Fdrawfocusrect:=value;
recreatewnd;
end;

procedure TTrackbar_32.SetEnableselrange(value:boolean);
begin
inherited;
FEnableselrange:=value;
recreatewnd;
end;

procedure TTrackbar_32.Setautohint(value:boolean);
begin
inherited;
Fautohint:=value;
recreatewnd;
end;

procedure TTrackbar_32.MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
try
inherited MouseDown (Button, Shift, X, Y);
except end;
end;

procedure TTrackbar_32.MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
try
inherited MouseUp (Button, Shift, X, Y);
except end;
end;

procedure TTrackbar_32.MouseMove (Shift: TShiftState; X, Y: Integer);
begin
inherited MouseMove (shift, X, Y);
end;

constructor TTrackbar_32.Create(AOwner: TComponent);
begin
inherited;
FEnableselrange:=false;
Color:=clbtnface;
FCanvas := TControlCanvas.Create;
TControlCanvas(FCanvas).Control := Self;
Bmp := TBitmap.Create;
_thumbcolor:=clbtnface;
_trackcolor:=clbtnface;
_color_light:=clbtnhighlight;
_color_shadow:=clbtnshadow;
_bordercolor:=clblack;
Fdrawfocusrect:=true;
end;

destructor TTrackbar_32.destroy;
begin
FCanvas.Free;
Bmp.FreeImage;
inherited;
end;

procedure TTrackbar_32.CreateParams(var Params: TCreateParams);
begin
inherited CreateParams(params);
if fEnableselrange = true then params.style:=params.style OR TBS_ENABLESELRANGE;
if fEnableselrange = false then params.style:=params.style AND NOT TBS_ENABLESELRANGE;
if fautohint = true then params.style:=params.style OR TBS_TOOLTIPS;
if fautohint = false then params.style:=params.style AND NOT TBS_TOOLTIPS;
end;

procedure Register;
begin
  RegisterComponents('DNK components', [TTrackbar_32]);
end;

end.
