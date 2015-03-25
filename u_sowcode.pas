unit u_sowcode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  Twnd_showcode = class(TForm)
    readwriter: TMemo;
    SaveDialog1: TSaveDialog;
    Panel5: TPanel;
    Image4: TImage;
    btn_export: TSpeedButton;
    CheckBox1: TRadioButton;
    RadioButton1: TRadioButton;
    CDO: TRadioButton;
    lin_cars: TMemo;
    Splitter1: TSplitter;
    CheckBox2: TCheckBox;
    brn_rgen: TSpeedButton;
    procedure btn_exportClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure brn_rgenClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wnd_showcode: Twnd_showcode;

implementation

uses u_edit;

{$R *.dfm}

procedure Twnd_showcode.btn_exportClick(Sender: TObject);
begin
if SaveDialog1.execute = false then exit;
readwriter.lines.AddStrings(lin_cars.Lines);
readwriter.lines.SaveToFile(changefileext(SaveDialog1.filename, '.pwn'));
gtaeditor.gencode()
end;

procedure Twnd_showcode.CheckBox1Click(Sender: TObject);
begin
wnd_showcode.readwriter.lines.clear;
gtaeditor.gencode()
end;

procedure Twnd_showcode.brn_rgenClick(Sender: TObject);
begin
gtaeditor.gencode()
end;

procedure Twnd_showcode.CheckBox2Click(Sender: TObject);
begin
gtaeditor.gencode()
end;

end.
