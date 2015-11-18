program editor;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  u_edit in 'u_edit.pas' {GtaEditor},
  gtadll in 'Struct\GTADLL.PAS',
  textparser in 'Struct\textparser.pas',
  u_Objects in 'u_Objects.pas',
  FrustumCulling in 'FrustumCulling.pas',
  Geometry in 'Geometry.pas',
  VectorTypes in 'VectorTypes.pas',
  RenderWareDFF in 'Struct\RenderWareDFF.pas',
  CameraClass in 'CameraClass.pas',
  rwtxd in 'Struct\rwtxd.pas',
  u_txdrecords in 'Struct\u_txdrecords.pas',
  OpenGL12 in 'OpenGL12.pas',
  ThdTimer in 'ThdTimer.pas',
  U_main in 'U_main.pas' {wnd_about},
  ColObject in 'ColObject.pas',
  Newton in 'Newton.pas',
  u_sowcode in 'u_sowcode.pas' {wnd_showcode},
  uHashedStringList in 'uHashedStringList.pas',
  BitUnit in 'BitUnit.pas',
  u_carcolors in 'u_carcolors.pas' {wnd_carcolorpicker},
  u_report in 'u_report.pas' {wnd_report};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Map Construction';
  Application.CreateForm(TGtaEditor, GtaEditor);
  Application.CreateForm(Twnd_about, wnd_about);
  Application.CreateForm(Twnd_showcode, wnd_showcode);
  Application.CreateForm(Twnd_carcolorpicker, wnd_carcolorpicker);
  Application.CreateForm(Twnd_report, wnd_report);
  Application.Run;
end.
