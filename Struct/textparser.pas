unit textparser;

interface

uses dialogs, classes, sysutils;

procedure setworkspace(str: string);
procedure setworkspacesafe(str: string);
function indexed(n: integer): string;
function intindex(n: integer): integer;
function fltindex(n: integer): single;
function stripcomments(const commenttxt, fulltext: string): string;
function reformat(sep: string): string;

var
  foo: Tstringlist;

implementation

function textreplace(asource, afind, areplace: string): string;
var p :integer;
begin
 result:='';
 p:=pos(lowercase(AFind),lowercase(ASource));
  while p > 0 do begin
   result:= result+Copy(ASource, 1, p - 1) + AReplace;
   Delete(ASource, 1, p + Length(AFind) - 1);
   p:= pos(lowercase(AFind),lowercase(ASource));
  end;
 Result:=Result + ASource;
end;

procedure setworkspacesafe(str: string);
var i: integer;
begin
if foo = nil then foo:= Tstringlist.create;
foo.clear;
foo.settext(pchar(textreplace(textreplace(str,'<', #13), '&', #13)));
end;

procedure setworkspace(str: string);
var
  i: integer;
  facts: integer;
  isspacer: boolean;
begin
if foo = nil then foo:= Tstringlist.create;
foo.clear;

facts:= -1;
isspacer:= true;

for i:= 1 to length(str) do begin

  isspacer:= ((str[i] = ',') or (str[i] = ' ') or (str[i] = '	'));

  if (facts = -1) then begin
    if isspacer = false then facts:= i; // found beginning
  end else begin
    if (facts <> -1) and (isspacer = true) then begin

      foo.Add(copy(str, facts, i - facts));

      facts:= -1;

    end;

  end;

end;

if (isspacer = false) then // it ended with a character, add last item.
  foo.Add(copy(str, facts, i - facts));

end;

function indexed(n: integer): string;
begin
if n < foo.count then
result:= foo[n] else result:= '';
end;

function intindex(n: integer): integer;
var
c: integer;
begin
val(indexed(n), result, c);
end;

function fltindex(n: integer): single;
begin
if foo <> nil then
if n <= foo.Count then
result:= strtofloat(foo[n]);
end;

function stripcomments(const commenttxt, fulltext: string): string;
var
  p: integer;
begin
p:= pos(commenttxt, fulltext);

if p <> 0 then
  result:= copy(fulltext, 0, p-1)
else
  result:= fulltext;

end;

function reformat(sep: string): string;
var
i: integer;
begin
  for i:= 0 to foo.Count-1 do
  if i = 0 then result:= foo[i]
  else result:= result + sep + foo[i]
end;

end.
