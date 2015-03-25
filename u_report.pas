unit u_report;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, WinInet;

type
  Twnd_report = class(TForm)
    reports: TMemo;
    reportuser: TMemo;
    Label43: TLabel;
    btn_send: TBitBtn;
    Label1: TLabel;
    procedure btn_sendClick(Sender: TObject);
    procedure reportuserChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wnd_report: Twnd_report;

implementation

uses U_main;

{$R *.dfm}

function GetUrlContent(const Url: string): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of Char;
  BytesRead: dWord;
begin
  Result := '';
  NetHandle := InternetOpen('MapEditor', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if Assigned(NetHandle) then 
  begin
    UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);

    if Assigned(UrlHandle) then
      { UrlHandle valid? Proceed with download }
    begin
      FillChar(Buffer, SizeOf(Buffer), 0);
      repeat
        Result := Result + Buffer;
        FillChar(Buffer, SizeOf(Buffer), 0);
        InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
      until BytesRead = 0;
      InternetCloseHandle(UrlHandle);
    end
    else
      { UrlHandle is not valid. Raise an exception. }
      raise Exception.CreateFmt('Cannot open URL %s', [Url]);

    InternetCloseHandle(NetHandle);
  end
  else
    { NetHandle is not valid. Raise an exception }
    raise Exception.Create('Unable to initialize Wininet');
end;

function GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

Function GetUserFromWindows: string;
Var
   UserName : string;
   UserNameLen : Dword;
Begin
   UserNameLen := 255;
   SetLength(userName, UserNameLen) ;
   If GetUserName(PChar(UserName), UserNameLen) Then
     Result := Copy(UserName,1,UserNameLen - 1)
   Else
     Result := 'Unknown';
End;

procedure Twnd_report.btn_sendClick(Sender: TObject);
var
	send: string;
	CanonicalURL: pchar;
	CanonicalURL2: pchar;
	CanonicalURL3: pchar;
	size: integer;
	fullurl: string;
begin
send:= reports.lines.GetText;
send:= StringReplace(send, #13, '%0d', [rfReplaceAll, rfIgnoreCase] );
Size := 3 * Length(send);
getmem(CanonicalURL, size);
InternetCanonicalizeUrl(PChar(send), PChar(CanonicalURL), cardinal(Size), 0 );

send:= reportuser.lines.GetText;
send:= StringReplace(send, #13, '%0d', [rfReplaceAll, rfIgnoreCase] );
Size := 3 * Length(send);
getmem(CanonicalURL2, size);
InternetCanonicalizeUrl(PChar(send), PChar(CanonicalURL2), cardinal(Size), 0 );

send:= wnd_about.Label1.caption;
send:= StringReplace(send, #13, '%0d', [rfReplaceAll, rfIgnoreCase] );
Size := 3 * Length(send);
getmem(CanonicalURL3, size);
InternetCanonicalizeUrl(PChar(send), PChar(CanonicalURL3), cardinal(Size), 0 );


fullurl := 'http://mathpudding.com/editor.php?user=' + GetUserFromWindows() + '&pc=' + GetComputerNetName() + '&version=' + CanonicalURL3 + '&info=' + CanonicalURL + '&describe=' + CanonicalURL2;

showmessage(GetUrlContent(fullurl));

hide;
end;

procedure Twnd_report.reportuserChange(Sender: TObject);
begin
btn_send.enabled:= true;
end;

end.
