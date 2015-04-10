unit checkbox_32;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tcheckbox_32 = class(TCheckBox)
  private
    { Private declarations }
    Fwordwrap:boolean;
    Fbutton:boolean;
    Fflat:boolean;
    procedure Setwordwrap(value:boolean);
    procedure Setflat(value:boolean);
    procedure Setbutton(value:boolean);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property wordwrap:boolean read fwordwrap write Setwordwrap;
    property button:boolean read fbutton write Setbutton;
    property Flat:boolean read fflat write Setflat;
    property Align;
end;

procedure Register;

implementation

constructor Tcheckbox_32.Create(AOwner: TComponent);
begin
FWordWrap:=true;
inherited;
end;


procedure Tcheckbox_32.CreateParams(var Params: TCreateParams);
begin
inherited;
if fWordWrap = true then Params.Style:=Params.Style or BS_MULTILINE;
if fWordWrap = false then Params.Style:=Params.Style AND NOT BS_MULTILINE;

if Fbutton=true then Params.Style:=Params.Style or BS_PUSHLIKE;
if Fbutton=false then Params.Style:=Params.Style AND NOT BS_PUSHLIKE;

if fflat = true then Params.Style:=Params.Style or BS_FLAT;
if fflat = false then Params.Style:=Params.Style AND NOT BS_FLAT;
end;

procedure Tcheckbox_32.SetWordWrap(Value: boolean);
begin
FWordWrap:=Value;
RecreateWnd;
end;

procedure Tcheckbox_32.setbutton(Value: boolean);
begin
Fbutton:=Value;
RecreateWnd;
end;

procedure Tcheckbox_32.setflat(Value: boolean);
begin
Fflat:=Value;
RecreateWnd;
end;

procedure Register;
begin
RegisterComponents('DNK components', [Tcheckbox_32]);
end;

end.
