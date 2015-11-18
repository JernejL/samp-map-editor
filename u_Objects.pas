unit u_Objects;

interface

uses classes, graphics, dialogs, filectrl, geometry, gtadll, sysutils, textparser, vectortypes, windows, uHashedStringList, inifiles, math, vectorgeometry;

type

  // single structures

  TBounds = packed record
    min, max: TVector3F;
    center  : TVector3F;
    radius  : single;
  end;

  TIDEinforecord = class
  public
    idefile, ideitem: longword;
    ideidx: longword;

		// coll info
		collectionname: string;
		collectionfileindex: integer;
		imgindex: integer;
		collname: string;
		collmodelindex: integer;
		colloffset: integer;

		gotcollbounds: boolean;
    collbounds: TBounds;
  end;

  Tcarcolor = array[0..3] of integer; // 4 color indexes

  Tcarcolored = class(TObject)
  public
    carname: string;
    colorcount: integer;
    car4:   boolean;
    colors: array[0..2048] of Tcarcolor;
  end;

  Tcarcolsfile = class(TObject)
  public
    colors:   array[0..2048] of Tcolor;
    colorcount: integer;
    cars:     array[0..2048] of Tcarcolored;
    carcount: integer;
  end;

  TTXDP = class
    fromtxd, totxd: string;
  end;

  TOBJS = class // and TOBJ
    ID: longword;

    ModelName, TextureName: string; // should even use this? could go faster with img indices
    Modelidx, Textureidx: integer; // img indices
    modelinimg, txdinimg: integer;

    ObjectCount: longword;
    DrawDist: single;
    Flags: longword;
    TimeOn, TimeOff: longword;

    exportRC: boolean;
  end;
  Pobjs = ^Tobjs;

  TINST = class
    id:   integer;
	LoadedModelIndex: integer;
	draw_distance: single;
    Name: string; // ignore - unused, don't load, use ID
    int_id: integer;
    Location: Tvector3F;
    rx, ry, rz, rw: single;
    lod:  integer;
    haslod: boolean;
    rootlod: boolean;
    added, deleted: boolean;
    lodobject: boolean;
    rux, ruy, ruz: single;

    carcolor1,carcolor2: integer;

    visibility: boolean;

    constructor create;
    procedure SetGTARotation(x, y, z: single);

  end;

  TCULL = class
    startorigin: Tvector3F;
    dimensions: Tvector3F;
    rotation: single;
    flags: longword;
  end;

  RCARS = class
    Location: Tvector3F;
    angle:    single;
    car_id:   longword;
    primary, secondary: longword;
    bool:     boolean;
    alarm_probability, door_lock_probability: single;
    radio:    single;
    appear_delay: single;
  end;

  // file classes

  TIDEFILE = class
    Objects:    array of TOBJS;
    TexReplace: array of TTXDP;
    procedure loadfromfile(filen: string; imglist: Tstrings);
  end;

  TIPLFILE = class
    filename: string;
    InstObjects: array of TINST;
    CullZones: array of TCULL;
    Bounds: array[0..1] of TVector3f;
    Cars: array of RCARS;
    procedure loadfromfile(filen: string);
    procedure loadfrombinfile(filen: string);
    procedure processlodinfo;
  end;

Tiplinst = packed record
x, y, z: single;
qx, qy, qz, qw: single;
ObjectID, InteriorID, lod: integer;
end;

Tiplcars = packed record
x, y, z: single;
angle: single;
ObjectID, u1, u2, u3, u4, u5, u6, u7: integer;
end;

Tiplstruct = packed record
bninary: array[0..3] of char; // bnry

instcount,
cullcount,
pathcount,
grgecount,
carscount,
jumpcount: longword;

instptr,
cullptr,
pathptr,
grgeptr,
enexptr,
pickptr,
jumpptr,
U1,
carsptr,
tcycptr,
auzoptr,
multptr
: longword;
end;

Twatervertex = packed record
pos: Tvector3f;
F1, F2, F3, F4: single;
end;

TWaterGeom = packed record
vertices: array[0..3] of Twatervertex;
param: integer;
end;

  // map class

  TGTAMAP = class(TObject)
  public

  	imgfile: array[0..5] of string;
	imglist: array[0..5] of THashedStringList;

    Water: array of TWaterGeom;

    IDE:     array of TIDEFILE;
    IPL:     array of TIPLFILE;
    loaded: boolean;
    idetable: TurboHashedStringList;
    idemapping: array of Tobject;
    colors: Tcarcolsfile;

    procedure loadcolldata(collfileidx: integer; inimg: integer);
    procedure loadfile(typ, filen: string; secondarybinipl: boolean);
    procedure loadimg(filen, filen2, filen3, filen4, filen5, filen6: string);
    procedure loadcolors(colorfile: string);
    procedure loadwater(filen: string);
  end;

// http://www.delphipages.com/tips/thread.cfm?ID=208

function gtarot2matrix3x3(x, y, z: single): TMatrix3f;
procedure matrix3f2quaternion(m: TMatrix3f; var rx, ry, rz, rw: single);


var
totalones: integer = 0;
mainidelist: array[0..19999] of TOBJS;

implementation

uses u_edit;


function gtarot2matrix3x3(x, y, z: single): TMatrix3f;

var
  v5,
  v6,
  v7,
  v8,
  v9,
  v10: double;

  v11,
  v12,
  v13: single;

begin

  v5 := cos(x);
//  LODWORD(this->pos.X) = 0;
//  LODWORD(this->pos.Y) = 0;
//  LODWORD(this->pos.Z) = 0;
  v6 := sin(x);
  v11 := cos(y);
  v7 := sin(y);
  v8 := cos(z);
  v9 := sin(z);
  v12 := v9;
  v10 := v9 * v6;
  v13 := v8 * v6;

  result[0,0] := v8 * v11 - v10 * v7;
  result[0,1] := v13 * v7 + v12 * v11;
  result[0,2] := -(v7 * v5);
  result[1,0] := -(v12 * v5);
  result[1,1] := v8 * v5;
  result[1,2] := v6;
  result[2,0] := v8 * v7 + v10 * v11;
  result[2,1] := v12 * v7 - v13 * v11;
  result[2,2] := v11 * v5;

  {
  this->right.X = v8 * v11 - v10 * v7;
  this->right.Y = v13 * v7 + v12 * v11;
  this->right.Z = -(v7 * v5);
  this->up.X = -(v12 * v5);
  this->up.Y = v8 * v5;
  this->up.Z = v6;
  this->at.X = v8 * v7 + v10 * v11;
  this->at.Y = v12 * v7 - v13 * v11;
  this->at.Z = v11 * v5;
  }

end;









(*
function gtarot2matrix3x3(x, y, z: single): TMatrix3f;
var
v4,
sinx,
siny,
cosz,
sinz,
v9,
cosy,
v11,
v12: single;
a, b, c, d, e, f, ad, bd: single;
begin

x:= x * (PI / 180);
y:= y * (PI / 180);
z:= z * (PI / 180);

  A      := cos(x);
  B      := sin(x);
  C      := cos(y);
  D      := sin(y);
  E      := cos(z);
  F      := sin(z);

  AD     :=   A * D;
  BD     :=   B * D;

  result[0,0]  :=   C * E;
  result[1,0]  :=  -C * F;
  result[2,0]  :=  -D;

  result[0,1]  := -BD * E + A * F;
  result[1,1]  :=  BD * F + A * E;
  result[2,1]  :=  -B * C;

  result[0,2]  :=  AD * E + B * F;
  result[1,2]  := -AD * F + B * E;
  result[2,2]  :=   A * C;

{exit;

x:= x * (PI / 180);
y:= y * (PI / 180);
z:= z * (PI / 180);

  fillchar(Result, sizeof(result), 0);

  v4:= cos(x);
  sinx:= sin(x);
  cosy:= cos(y);
  siny:= sin(y);
  cosz:= cos(z);
  sinz:= sin(z);
  v11:= sinz;
  v9:= sinz * sinx;
  v12:= cosz * sinx;
  
  result[0,0]:= cosz * cosy - v9 * siny; // ERROR
  result[1,0]:= v12 * siny + v11 * cosy; // ERROR
  result[2,0]:= -(siny * v4);            // CHECK

  result[0,1]:= -(v11 * v4);             // ERROR
  result[1,1]:= cosz * v4;               // ERROR
  result[2,1]:= sinx;                    // CHECK

  result[0,2]:= cosz * siny + v9 * cosy; // CHECK
  result[1,2]:= v11 * siny - v12 * cosy; // CHECK
  result[2,2]:= cosy * v4;               // CHECK
}

{
[ecx] <- cos z * cos y - sin z * sin x * sin y
[ecx+4] <- cos z  * sin y + sin x * sin y + sin z * cos y
[ecx+8] <- -(sin y * cos x)
[ecx+10h] <- -(sin z * cos x)
[ecx+14h] <- cos z * cos x
[ecx+18h] <- sin x
[ecx+20h] <- cos y * sin z * sin x + cos z * sin y
[ecx+24h] <- sin z * sin y - cos z * sin x * cos y
}

end;
*)

{
procedure matrix3f2quaternion(m: TMatrix3f; var rx, ry, rz, rw: single);
var
  trace, s: single;
  i, j, k: integer;
  q: array[0..3] of single;
begin
  trace:= m[0][0]+m[1][1]+m[2][2];

  if ( trace > 0.0 ) then begin
    s:= 0.5 / Sqrt( trace + 1 );
    rx:= ( m[2][1] - m[1][2] ) * s;
    ry:= ( m[0][2] - m[2][0] ) * s;
    rz:= ( m[1][0] - m[0][1] ) * s;
    rw:= 0.25 / s;
  end else begin

    i:= 0;
    if (m[1][1] > m[0][0]) then i:= 1;

    if (m[2][2] > m[i][i]) then i:= 2;

    j:= nxt[i];
    k:= nxt[j];
    s:= ((m[i][i] - (m[j][j] + m[k][k])) + 1.0);
    q[i]:= s * 0.5;

    if (s <> 0.0) then s:= 0.5 / s;

    q[3]:= (m[k][j] - m[j][k]) * s;
    q[j]:= (m[i][j] + m[j][i]) * s;
    q[k]:= (m[i][k] + m[k][i]) * s;

    rx:= q[0];
    ry:= q[1];
    rz:= q[2];
    rw:= q[3];
  end;

end;
}

procedure matrix3f2quaternion(m: TMatrix3f; var rx, ry, rz, rw: single);
var
  tr: single;
  S: single;
begin

tr:= m[0,0] + m[1,1] + m[2,2];

if (tr > 0) then begin
  S := sqrt(tr+1.0) * 2; // S=4*rw
  rw := 0.25 * S;
  rx := (m[2,1] - m[1,2]) / S;
  ry := (m[0,2] - m[2,0]) / S;
  rz := (m[1,0] - m[0,1]) / S;
end else if ((m[0,0] > m[1,1]) and (m[0,0] > m[2,2])) then begin
  S := sqrt(1.0 + m[0,0] - m[1,1] - m[2,2]) * 2; // S:=4*rx
  rw := (m[2,1] - m[1,2]) / S;
  rx := 0.25 * S;
  ry := (m[0,1] + m[1,0]) / S;
  rz := (m[0,2] + m[2,0]) / S;
end else if (m[1,1] > m[2,2]) then begin
  S := sqrt(1.0 + m[1,1] - m[0,0] - m[2,2]) * 2; // S:=4*ry
  rw := (m[0,2] - m[2,0]) / S;
  rx := (m[0,1] + m[1,0]) / S;
  ry := 0.25 * S;
  rz := (m[1,2] + m[2,1]) / S;
end else begin
  S := sqrt(1.0 + m[2,2] - m[0,0] - m[1,1]) * 2; // S:=4*rz
  rw := (m[1,0] - m[0,1]) / S;
  rx := (m[0,2] + m[2,0]) / S;
  ry := (m[1,2] + m[2,1]) / S;
  rz := 0.25 * S;
end;
end;

function GetTempDir: string;
var
  n: dword;
  p: PChar;
begin
  n := MAX_PATH;
  p := stralloc(n);
  gettemppath(n, p);
  Result := strpas(p);
  strdispose(p);
end;

{ TGTAMAP }

procedure TGTAMAP.loadcolldata(collfileidx: integer; inimg: integer);
var
  i, j: integer;
  filebuff: Tmemorystream;
  lws: longword;
  name: array[0..23] of char; // srsly steve :S
  namelc: string;
  fcc: array [0..3] of char;
  bounds: TBounds;
	opos: integer;
	lastofs: integer;
begin
	filebuff:= Tmemorystream.create;
	filebuff.size:= IMGGetThisFile( collfileidx ).sizeblocks * 2048;
	IMGExportBuffer(collfileidx, filebuff.Memory);

	repeat
		lastofs:= filebuff.Position;
    filebuff.Read(fcc, 4);
    filebuff.Read(lws, 4);
    opos:= filebuff.Position;
    filebuff.Read(name, sizeof(name));

    namelc:= lowercase(trim(name));

    if ((fcc = 'COL3') or (fcc = 'COL2') or (fcc = 'COLL')) then
      filebuff.Read(bounds, sizeof(bounds))
    else begin
      if trim(fcc) = '' then break;
			showmessage(trim(fcc) + ' -> ' +  namelc + ' -> ' +  IMGGetFileName(collfileidx));
    end;

    i:= idetable.IndexOfname(namelc, true);
    if i <> -1 then begin
			with idetable.items[i].ObjectRef as TIDEinforecord do begin

//				outputdebugstring(pchar(format('ide %d name %s (%0.4f,%0.4f,%0.4f) radius %0.4f', [ideidx, namelc, bounds.center[0], bounds.center[1], bounds.center[2], bounds.radius ])));

				collbounds:= bounds;

				collectionname:= IMGGetThisFile( collfileidx ).Name;
				collectionfileindex:= collfileidx;

				imgindex:= inimg;

				collname:= namelc;
				collmodelindex:= i;

				colloffset:= lastofs;

        gotcollbounds:= true;
      end;
    end;

    filebuff.Position:= opos;
    filebuff.Seek(lws, soFromCurrent);

  until filebuff.Position >= filebuff.Size;

  filebuff.Free;
end;


procedure TGTAMAP.loadcolors(colorfile: string);
var
  ls: Tstrings;
  i, ii: integer;
  insection: string;

  function transf(i: integer): integer;
  begin
    Result := i - 1;
    if Result = -1 then
      Result := 3;
  end;

begin

  ls:= Tstringlist.create;

  ls.loadfromfile(colorfile);

  colors := Tcarcolsfile.Create;
  colors.colorcount := 0;
  colors.carcount := 0;

  insection := 'NULL';

  for i := 0 to ls.Count - 1 do
  begin
    if ls[i] = 'col' then
      insection := 'col'
    else
    if ls[i] = 'car' then
      insection := 'car'
    else
    if ls[i] = 'car4' then
      insection := 'car4'
    else
    if ls[i] = 'end' then
      continue
    else // skip these
    begin
      textparser.setworkspace(textparser.
        stripcomments('#', ls[i]));

      if textparser.foo.Count <> 0 then // if nothing was left of the text after stripping comments don't do this code
        with colors do
        begin

          if insection = 'col' then
          begin // colors are being parsed
            colors[colorcount] := rgb(textparser.intindex(0), textparser.intindex(1), textparser.intindex(2));
            colorcount := colorcount + 1;
          end;

          if insection = 'car' then
          begin // colors are being parsed
            cars[carcount]      := Tcarcolored.Create;
            cars[carcount].carname := textparser.indexed(0);
            cars[carcount].colorcount := 0; // no colors yet
            cars[carcount].car4 := False;

            for ii := 1 to textparser.foo.Count do
              cars[carcount].colors[(ii - 1) div 2][integer(not boolean((ii mod 2)))] := textparser.intindex(ii);

            cars[carcount].colorcount := (textparser.foo.Count - 1); // set color count

            carcount := carcount + 1;

          end;

          // car4
          if insection = 'car4' then
          begin // colors are being parsed
            cars[carcount]      := Tcarcolored.Create;
            cars[carcount].carname := textparser.indexed(0);
            cars[carcount].colorcount := 0; // no colors yet
            cars[carcount].car4 := True;

            for ii := 1 to textparser.foo.Count do
              cars[carcount].colors[(ii - 1) div 4][transf(ii mod 4)] := textparser.intindex(ii);

            cars[carcount].colorcount := (textparser.foo.Count div 2); // set color count

            carcount := carcount + 1;

          end;
          // end car4

        end;

    end;
  end;

  ls.free;

end;

procedure TGTAMAP.loadfile(typ, filen: string; secondarybinipl: boolean);
var
binipl: integer;
z: integer;
streamname: string;
begin
  if typ = 'IPL' then
  begin
    setlength(ipl, length(ipl) + 1);
    ipl[high(ipl)] := TIPLFILE.Create;

    if secondarybinipl = false then begin
      ipl[high(ipl)].loadfromfile(filen);

    // check img #1
      for z:= 0 to 30 do begin
				streamname:= lowercase(extractfilename(changefileext(filen, '')) + '_stream' + inttostr(z) + '.ipl');

//				outputdebugstring(pchar(streamname));

        binipl:= imglist[0].IndexOf(streamname);

        if binipl <> -1 then begin

        u_edit.GtaEditor.imgipls.lines.add(streamname);

        IMGLoadImg(pchar(city.imgfile[0]));
        // todo: should IMGExportBuffer() for speed..
        IMGExportFile(binipl, PChar(GetTempDir + '\' + streamname));

		// failures here? maybe you are out of drive space in temp.
		
        ipl[high(ipl)].loadfrombinfile(PChar(GetTempDir + '\' + streamname));

        deletefile(PChar(GetTempDir + '\' + streamname));
        end;// else break;
      end;

    // check img #2
      for z:= 0 to 20 do begin
        streamname:= lowercase(extractfilename(changefileext(filen, '')) + '_stream' + inttostr(z) + '.ipl');

        if imglist[1] = nil then continue; // wtf?

        binipl:= imglist[1].IndexOf(streamname);

        if binipl <> -1 then begin

        u_edit.GtaEditor.imgipls.lines.add(streamname);

        IMGLoadImg(pchar(city.imgfile[1]));
        IMGExportFile(binipl, PChar(GetTempDir + '\' + streamname));

        ipl[high(ipl)].loadfrombinfile(PChar(GetTempDir + '\' + streamname));

        deletefile(PChar(GetTempDir + '\' + streamname));
        end else break;
      end;

    end else begin
      ipl[high(ipl)].loadfrombinfile(filen);

    end;

  end
  else
  if typ = 'IDE' then
  begin
    setlength(ide, length(ide) + 1);
    ide[high(ide)] := TIDEFILE.Create;
    ide[high(ide)].loadfromfile(filen, imglist[0]);
  end
  else
  begin
    // skip this line
  end;

end;


procedure TGTAMAP.loadimg(filen, filen2, filen3, filen4, filen5, filen6: string);
{
var
  i: integer;}

  procedure globimg(index: integer; filename: string);
  var
    i: integer;
  begin

    if fileexists(changefileext(filename, '.img')) = true then begin
//      SetFileAttributes(PChar(changefileext(filename, '.img')), FILE_ATTRIBUTE_ARCHIVE);

      IMGLoadImg(PChar(filename));

      outputdebugstring(pchar('GLOBBING img: ' + filename));

      imglist[index] := Thashedstringlist.Create;
      ImgList[index].Clear;
      ImgList[index].CaseSensitive:= false;

      for i := 0 to IMGFileCount - 1 do
        ImgList[index].add(lowercase(IMGGetThisFile(i).Name));

      outputdebugstring(pchar('GLOBBING img: ' + filename + ' ADDED: total files: ' + inttostr(ImgList[index].Count)));

      imgfile[index]:= filename;
    end else begin
      outputdebugstring(pchar('GLOBBING img FAILURE (MISERABLE): ' + changefileext(filename, '.img')));
    end;

  end;

begin

  globimg(5, filen6);
  globimg(4, filen5);
	globimg(3, filen4);
	globimg(2, filen3);
	globimg(1, filen2);
	globimg(0, filen);

{
  // img 3

  if fileexists(changefileext(filen4, '.img')) = true then begin
    SetFileAttributes(PChar(changefileext(filen4, '.img')), FILE_ATTRIBUTE_ARCHIVE);

    IMGLoadImg(PChar(filen4));

    if imglist[3] = nil then imglist[3] := Thashedstringlist.Create;
    ImgList[3].Clear;
    ImgList[3].CaseSensitive:= false;


    for i := 0 to IMGFileCount - 1 do
      ImgList[3].add(lowercase(IMGGetThisFile(i).Name));

    imgfile[3]:= filen4;
  end;


  // img 3

  if fileexists(changefileext(filen3, '.img')) = true then begin
    SetFileAttributes(PChar(changefileext(filen3, '.img')), FILE_ATTRIBUTE_ARCHIVE);

    IMGLoadImg(PChar(filen3));

    if imglist[2] = nil then imglist[2] := Thashedstringlist.Create;
    ImgList[2].Clear;
    ImgList[2].CaseSensitive:= false;


    for i := 0 to IMGFileCount - 1 do
      ImgList[2].add(lowercase(IMGGetThisFile(i).Name));

    imgfile[2]:= filen3;
  end;



  // img 2

  SetFileAttributes(PChar(changefileext(filen2, '.img')), FILE_ATTRIBUTE_ARCHIVE);

  IMGLoadImg(PChar(filen2));

  if imglist[1] = nil then imglist[1] := Thashedstringlist.Create;
  ImgList[1].Clear;
  ImgList[1].CaseSensitive:= false;

  for i := 0 to IMGFileCount - 1 do
    ImgList[1].add(lowercase(IMGGetThisFile(i).Name));

  imgfile[1]:= filen2;

  // img 1
  
  SetFileAttributes(PChar(changefileext(filen, '.img')), FILE_ATTRIBUTE_ARCHIVE);

  IMGLoadImg(PChar(Filen));

  if imglist[0] = nil then imglist[0] := Thashedstringlist.Create;
  ImgList[0].Clear;
  ImgList[0].CaseSensitive:= false;

  for i := 0 to IMGFileCount - 1 do
    ImgList[0].add(lowercase(IMGGetThisFile(i).Name));

  imgfile[0]:= filen;
  }
end;

procedure TGTAMAP.loadwater(filen: string);
var
  waterlist: TStrings;
  i: integer;
begin
  waterlist := TStringList.Create;
  waterlist.LoadFromFile(filen);

  for i:= 1 to waterlist.Count-1 do begin
    textparser.setworkspace(stripcomments('#', waterlist[i]));
      setlength(Water, length(Water) + 1);
      with Water[high(Water)] do begin
        vertices[0].pos[0]:= textparser.fltindex(0);
        vertices[0].pos[1]:= textparser.fltindex(1);
        vertices[0].pos[2]:= textparser.fltindex(2);

        vertices[1].pos[0]:= textparser.fltindex(7*1 + 0);
        vertices[1].pos[1]:= textparser.fltindex(7*1 + 1);
        vertices[1].pos[2]:= textparser.fltindex(7*1 + 2);

        vertices[2].pos[0]:= textparser.fltindex(7*2 + 0);
        vertices[2].pos[1]:= textparser.fltindex(7*2 + 1);
        vertices[2].pos[2]:= textparser.fltindex(7*2 + 2);

        if textparser.foo.Count = 29 then begin
        vertices[3].pos[0]:= textparser.fltindex(7*3 + 0);
        vertices[3].pos[1]:= textparser.fltindex(7*3 + 1);
        vertices[3].pos[2]:= textparser.fltindex(7*3 + 2);
        param:= textparser.intindex(29);
        end else begin
        vertices[3].pos[0]:= textparser.fltindex(7*1 + 0);
        vertices[3].pos[1]:= textparser.fltindex(7*1 + 1);
        vertices[3].pos[2]:= textparser.fltindex(7*1 + 2);
        param:= textparser.intindex(22);
        end;
      end;
  end;

  waterlist.free;
end;

{ TIPLFILE }

procedure TIPLFILE.loadfromfile(filen: string);
var
  ipllist: TStrings;
  i: integer;
  insection: string;
begin

  Bounds[0] := NullVector;
  Bounds[1] := NullVector;

  filename := filen;

  if pos('path', filen) > 0 then
  begin
    // we ignore paths to speed up loading.
     exit;
  end;

  ipllist := TStringList.Create;
  ipllist.LoadFromFile(filen);

  insection := '';

  for i := 0 to ipllist.Count - 1 do
  begin

    textparser.setworkspace(stripcomments('#', ipllist[i]));

    if trim(textparser.indexed(0)) <> '' then
    begin

      if (length(textparser.indexed(0)) <= 4) and (textparser.foo.Count = 1) then
      begin
        insection := textparser.indexed(0);
        Continue; // continue with next line
      end;

      if insection = 'inst' then
      begin

        setlength(InstObjects, length(InstObjects) + 1);
        InstObjects[high(InstObjects)] := TINST.Create;

        with InstObjects[high(InstObjects)] do
        begin

		  LoadedModelIndex := -1;
		  draw_distance:= 0.0;

          added:= false;
          deleted:= false;

          id := textparser.intindex(0);

          {
          if id = 1412 then begin
          showmessage(textparser.foo.GetText);
          end;
          }
          //name     := textparser.intindex(1);

          int_id := textparser.intindex(2);
          if int_id > 17 then int_id:= 0;

          totalones:= totalones + 1;

          Location[0] := textparser.fltindex(3);
          Location[1] := textparser.fltindex(4);
          Location[2] := textparser.fltindex(5);

          // calculate bounding box

          // lowest coords
          if Location[0] < Bounds[0][0] then
            Bounds[0][0] := Location[0];
          if Location[1] < Bounds[0][1] then
            Bounds[0][1] := Location[1];
          if Location[2] < Bounds[0][2] then
            Bounds[0][2] := Location[2];

          // highiest coords
          if Location[0] > Bounds[1][0] then
            Bounds[1][0] := Location[0];
          if Location[1] > Bounds[1][1] then
            Bounds[1][1] := Location[1];
          if Location[2] > Bounds[1][2] then
            Bounds[1][2] := Location[2];

          rx  := textparser.fltindex(6);
          ry  := textparser.fltindex(7);
          rz  := textparser.fltindex(8);
          rw  := textparser.fltindex(9);
          lod := textparser.intindex(10);
          lodobject:= false;

        end;

      end

      else if insection = 'cull' then
      begin
        setlength(CullZones, length(CullZones) + 1);
        CullZones[high(CullZones)] := TCULL.Create;
        CullZones[high(CullZones)].startorigin[0]:= textparser.fltindex(0);
        CullZones[high(CullZones)].startorigin[1]:= textparser.fltindex(1);
        CullZones[high(CullZones)].startorigin[2]:= textparser.fltindex(2);


        CullZones[high(CullZones)].dimensions[0]:= textparser.fltindex(6);
        CullZones[high(CullZones)].dimensions[1]:= textparser.fltindex(4);
        CullZones[high(CullZones)].dimensions[2]:= textparser.fltindex(5);

        CullZones[high(CullZones)].rotation:= textparser.fltindex(3);

        CullZones[high(CullZones)].flags:= textparser.intindex(8);

      end

      else if insection = 'cars' then
      begin

      end
      else
      begin

      end;

    end;

  end;

end;

procedure ConvertNonNormaQuatToEuler(qw, qx, qy, qz: single; var heading, attitude, bank: single);
var
		sqw,
		sqx,
		sqy,
		sqz,
		unt, diagonal: single;
begin
		sqw := qw*qw;
		sqx := qx*qx;
		sqy := qy*qy;
		sqz := qz*qz;
		unt := sqx + sqy + sqz + sqw;

		diagonal := qx*qy + qz*qw;

		if (diagonal > 0.499 * unt) then begin
				heading := 2 * ArcTan2(qx,qw);
				attitude := 3.141592653/2;
				bank := 0;
				exit;
		end;

		if (diagonal < -0.499 * unt) then begin
				heading := -2*ArcTan2(qx,qw);
				attitude := -3.141592653/2;
				bank := 0;
				exit;
		end;

		heading := ArcTan2(2*qy*qw - 2*qx*qz, sqx - sqy - sqz + sqw);

		if (heading < 0) then
			heading := 0 - heading
		else heading := 360 - heading;
			attitude := ArcSin(2*diagonal / unt);
			bank := ArcTan2(2*qx*qw - 2*qy*qz, -sqx + sqy - sqz + sqw);

end;



procedure TIPLFILE.loadfrombinfile(filen: string);
var
  ipllist: TStrings;
  i: integer;
  insection: string;
  f: Tmemorystream;
  iplstruct: Tiplstruct;
  iplinst: Tiplinst;
  iplcars: Tiplcars;
begin

  f:= Tmemorystream.create;
  f.loadfromfile(filen);
  f.read(iplstruct, sizeof(iplstruct));

  if iplstruct.instptr <> 0 then begin
  f.position:= iplstruct.instptr;
  
  for i:= 0 to iplstruct.instcount-1 do begin
    f.read(iplinst, sizeof(iplinst));

    setlength(InstObjects, length(InstObjects) + 1);
    InstObjects[high(InstObjects)] := TINST.Create;

    with InstObjects[high(InstObjects)] do
    begin

	 LoadedModelIndex := -1;
	 draw_distance:= 0.0;

     added:= false;
     deleted:= false;

//     OutputDebugString(pchar(inttostr(iplinst.objectid)));

     id := iplinst.objectid;

     {
     if id = 1412 then begin
     showmessage(inttostr(iplinst.lod));
     end;
     }
     int_id := iplinst.interiorid;
     if int_id > 17 then int_id:= 0;

     Location[0] := iplinst.x;
     Location[1] := iplinst.y;
		 Location[2] := iplinst.z;
		 totalones:= totalones + 1;

//     if id = 9698 then showmessage(format('%f %f %f', [Location[0], Location[1], Location[2]]));

     // calculate bounding box

     // lowest coords
     if Location[0] < Bounds[0][0] then
       Bounds[0][0] := Location[0];
     if Location[1] < Bounds[0][1] then
       Bounds[0][1] := Location[1];
     if Location[2] < Bounds[0][2] then
       Bounds[0][2] := Location[2];

     // highiest coords
     if Location[0] > Bounds[1][0] then
       Bounds[1][0] := Location[0];
     if Location[1] > Bounds[1][1] then
       Bounds[1][1] := Location[1];
     if Location[2] > Bounds[1][2] then
       Bounds[1][2] := Location[2];

     rx  := iplinst.qx;
     ry  := iplinst.qy;
     rz  := iplinst.qz;
		 rw  := iplinst.qw;

		 ConvertNonNormaQuatToEuler(rx, ry, rz, rw, rux, ruy, ruz);

     lod := iplinst.lod;
     lodobject:= false;


   end;

//ipltext.lines.add(format( '%d, %s, %d, %f, %f, %f, %f, %f, %f, %f, %d', [iplinst.objectid, 'object' + inttostr(iplinst.objectid), iplinst.interiorid, iplinst.x, iplinst.y, iplinst.z, iplinst.qx, iplinst.qy, iplinst.qz, iplinst.qw, iplinst.flags] ));
end;
end;

{   
if iplstruct.carsptr <> 0 then begin
f.position:= iplstruct.carsptr;
for i:= 0 to iplstruct.carscount-1 do begin
f.read(iplcars, sizeof(iplcars));
//ipltext.lines.add(format( '%d, %f, %f, %f, %f', [iplcars.objectid, iplcars.x, iplcars.y, iplcars.z, iplcars.angle ] ));
end;
end;
}
{
if iplstruct.cullptr <> 0 then ipltext.lines.add('cull found but don''t know how to handle it');
if iplstruct.pathptr <> 0 then ipltext.lines.add('path found but don''t know how to handle it');
if iplstruct.grgeptr <> 0 then ipltext.lines.add('grge found but don''t know how to handle it');
if iplstruct.enexptr <> 0 then ipltext.lines.add('enex found but don''t know how to handle it');
if iplstruct.pickptr <> 0 then ipltext.lines.add('pick found but don''t know how to handle it');
if iplstruct.jumpptr <> 0 then ipltext.lines.add('jump found but don''t know how to handle it');
if iplstruct.tcycptr <> 0 then ipltext.lines.add('tcyc found but don''t know how to handle it');
if iplstruct.auzoptr <> 0 then ipltext.lines.add('auzo found but don''t know how to handle it');
if iplstruct.multptr <> 0 then ipltext.lines.add('mult found but don''t know how to handle it');
if iplstruct.U1 <> 0 then ipltext.lines.add('additionally this file contains unknown data.');
}

f.free;

end;

procedure TIPLFILE.processlodinfo;
var
  i:   integer;

  function anylods(cid: integer): boolean;
  var j: integer;
  begin
  result:= false;

    for j:= 0 to high(InstObjects) do begin
    if InstObjects[j].lod = cid then begin result:= true; break; end;
    end;
  end;

begin

for i:= 0 to high(InstObjects) do begin
InstObjects[i].haslod:= anylods(i); // this object is a sub-lod
InstObjects[i].rootlod:= not InstObjects[i].haslod; // this object has no sub-lods and is alone

if InstObjects[i].lod <> -1 then
InstObjects[InstObjects[i].lod].lodobject:= True;

end;

end;

{ TIDEFILE }

procedure TIDEFILE.loadfromfile(filen: string; imglist: tstrings);
var
  idelist:   TStrings;
  i, j, o:   integer;
  insection: string;
begin

  idelist := TStringList.Create;
  idelist.LoadFromFile(filen);

  insection := '';

  for i := 0 to idelist.Count - 1 do
  begin

    textparser.setworkspace(stripcomments('#', idelist[i]));

    //outputdebugstring(pchar(textparser.foo.GetText));

    if trim(textparser.indexed(0)) <> '' then
    begin

      if (length(textparser.indexed(0)) <= 4) and (textparser.foo.Count = 1) then
      begin
        insection := textparser.indexed(0);
        Continue; // continue with next line
      end;

      if

      (insection = 'peds') or (insection = 'cars') or (insection = 'hier') or (insection = 'weap') or

      (insection = 'objs') or (insection = 'tobj') or (insection = 'anim') then
      begin // threat both as one type of data, no need to make things harder..

        setlength(Objects, length(Objects) + 1);
        Objects[high(Objects)] := TOBJS.Create;

				with Objects[high(Objects)] do
        begin

        for o:= 0 to textparser.foo.Count-1 do begin
          textparser.foo[o]:= StringReplace(textparser.foo[o], ',', '', [rfReplaceAll]);
        end;

					ID := textparser.intindex(0);

					mainidelist[ID] := Objects[high(Objects)];

          //ID:= 1411;
          //if ID >= 1411 then if id <= 1413 then GtaEditor.Memo1.lines.add('IDE fence: ' + textparser.indexed(1));
          {
          ModelName :=  'DYN_MESH_2'; //textparser.indexed(1);
          TextureName := 'BREAK_FEN_mesh'; //textparser.indexed(2);
          }

          ModelName :=  lowercase(textparser.indexed(1));
          TextureName := lowercase(textparser.indexed(2));

          //u_edit.GtaEditor.Memo1.lines.add(TextureName);

          if insection = 'objs' then begin
          DrawDist := textparser.intindex(3);
          Flags := textparser.intindex(4);
          end;

          if insection = 'anim' then begin
          DrawDist := textparser.intindex(4);
          Flags := textparser.intindex(5);
          //TextureName := lowercase(textparser.indexed(3));
          end;

          if insection = 'tobj' then begin
          TimeOn  := textparser.intindex(5);
          TimeOff := textparser.intindex(6);
          end;
        end;

      end
      else if insection = 'txdp' then
      begin
        setlength(TexReplace, length(TexReplace) + 1);
        TexReplace[high(TexReplace)] := TTXDP.Create;
        TexReplace[high(TexReplace)].fromtxd := textparser.indexed(0);
        TexReplace[high(TexReplace)].totxd := textparser.indexed(1);

//        u_edit.GtaEditor.Memo1.lines.add('TXDP: ' + TexReplace[high(TexReplace)].fromtxd + ' - ' + TexReplace[high(TexReplace)].totxd);

      end

      else
      begin

      end;

    end;

  end;

end;

{ TINST }

constructor TINST.create;
begin
rux:= 0;
ruy:= 0;
ruz:= 0;
end;

procedure TINST.SetGTARotation(x, y, z: single);
var
  tma, tmn: TMatrix3f;
  a, b: integer;
  ms: Tmemorystream;
begin

rux:= x;
ruy:= y;
ruz:= z;

tma:= gtarot2matrix3x3(degtorad(x), degtorad(y), degtorad(z));

  for a := 0 to 2 do
    for b := 0 to 2 do
      tmn[a, b] := tma[a, b]; // transpose!

{      ms:= Tmemorystream.create;
      ms.Write(tmn, sizeof(tmn));
      ms.SaveToFile('c:\tadaa.dmp');}

matrix3f2quaternion(tmn, rx, ry, rz, rw);
end;

var i: integer;

initialization

for i:= 0 to high(mainidelist) do
	mainidelist[i]:= nil;

end.

