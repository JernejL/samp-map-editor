unit U_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, jpeg;

type
  Twnd_about = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel5: TPanel;
    Image4: TImage;
    btn_clear: TSpeedButton;
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Label6: TLabel;
    procedure btn_clearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wnd_about: Twnd_about;

implementation

{$R *.dfm}

procedure Twnd_about.btn_clearClick(Sender: TObject);
begin
modalresult:= mrok;
end;

end.
