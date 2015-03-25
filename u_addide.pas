unit u_addide;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  Twnd_addide = class(TForm)
    Panel5: TPanel;
    Image4: TImage;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Image1: TImage;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit3: TEdit;
    Edit4: TEdit;
    Label3: TLabel;
    procedure btn_clearClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure updatepic;
    procedure Edit1Change(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wnd_addide: Twnd_addide;
  
  cameradrag: boolean = false;
  lastmouse: Tpoint;
  cammouse: Tpoint;

implementation

uses u_edit;

{$R *.dfm}

procedure Twnd_addide.btn_clearClick(Sender: TObject);
begin
modalresult:= mrok;
end;

procedure Twnd_addide.SpeedButton1Click(Sender: TObject);
begin
modalresult:= mrcancel;
end;

procedure Twnd_addide.FormShow(Sender: TObject);
begin
updatepic();
end;

procedure Twnd_addide.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
if cameradrag = false then exit;
cammouse.x:= x;
cammouse.y:= y;

updatepic();
end;

procedure Twnd_addide.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
cameradrag:= false;
end;

procedure Twnd_addide.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
if ssCtrl	in Shift then zoomadd:= zoomadd + (wheeldelta)
else zoomadd:= zoomadd + (wheeldelta / 80);

updatepic();
end;

procedure Twnd_addide.updatepic;
begin
//try
  rota:= lastmouse.x - cammouse.x;
  rotb:= lastmouse.y - cammouse.y;

  u_edit.prefabrenderid:= inttostr(strtointdef(Edit1.text, 500));

  GtaEditor.BitBtn1Click(GtaEditor.BitBtn1);

  if fileexists(extractfiledir(application.exename)+'\PrefabPics\' + u_edit.prefabrenderid + '.bmp') then
    Image1.picture.LoadFromFile((extractfiledir(application.exename)+'\PrefabPics\' + u_edit.prefabrenderid + '.bmp'));

  application.processmessages;
//except end;
end;

procedure Twnd_addide.Edit1Change(Sender: TObject);
begin
updatepic();
end;

procedure Twnd_addide.BitBtn10Click(Sender: TObject);
begin
Edit1.Text:= inttostr(strtoint(Edit1.text) + 1);
updatepic();
end;

procedure Twnd_addide.BitBtn9Click(Sender: TObject);
begin
Edit1.Text:= inttostr(strtoint(Edit1.text) - 1);
if (strtoint(Edit1.Text) < 0) then
  Edit1.Text:= '0';
updatepic();
end;

end.
