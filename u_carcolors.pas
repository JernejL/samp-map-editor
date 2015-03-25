unit u_carcolors;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls;

type
  Twnd_carcolorpicker = class(TForm)
    DrawGrid1: TDrawGrid;
    CheckBox1: TCheckBox;
    DrawGrid2: TDrawGrid;
    CheckBox2: TCheckBox;
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wnd_carcolorpicker: Twnd_carcolorpicker;

implementation

uses u_edit;

{$R *.dfm}

procedure Twnd_carcolorpicker.DrawGrid1DrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
if u_edit.city = nil then exit;

(sender as TDrawGrid).canvas.Brush.color:= city.colors.colors[arow * 16 + acol];
(sender as TDrawGrid).Canvas.FillRect(rect);
end;

procedure Twnd_carcolorpicker.DrawGrid1Click(Sender: TObject);
begin
  u_edit.gtaeditor.inp_coordseditchange(u_edit.gtaeditor.inp_coordsedit);
end;

end.
