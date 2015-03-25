unit u_advedit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, CheckLst, SynEdit, SynMemo;

type
  Twnd_advinfo = class(TForm)
    Edit1: TEdit;
    list_dfftextures: TSynMemo;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txdtextures: TSynMemo;
    Edit3: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    BitBtn1: TBitBtn;
    Label6: TLabel;
    Edit4: TEdit;
    labelother: TLabel;
    ideflags: TCheckListBox;
    Label7: TLabel;
    extras: TSynMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure list_dfftexturesClick(Sender: TObject);
    procedure list_dfftexturesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wnd_advinfo: Twnd_advinfo;

implementation

{$R *.dfm}

procedure Twnd_advinfo.BitBtn1Click(Sender: TObject);
begin
hide;
end;

procedure Twnd_advinfo.list_dfftexturesClick(Sender: TObject);
var
	line: integer;
begin
	Line := Perform(EM_LINEFROMCHAR, 0, 0) ;
end;

procedure Twnd_advinfo.list_dfftexturesChange(Sender: TObject);
begin
//list_dfftextures.Lines[list_dfftextures.CaretY]
end;

end.
