unit ColObject; // © 2004-05 by Steve M.

interface

{.$DEFINE dbg}
{.$DEFINE dbg2}

{.$Q-}

uses
  Windows, Classes, SysUtils, Dialogs, OpenGL1x, VectorTypes, VectorGeometry;

type
  TColVersion = (cvCOLL, cvCOL2, cvCOL3);

  PBounds = ^TBounds;
  TBounds = packed record
    min, max: TVector3F;
    center  : TVector3F;
    radius  : single;
  end;

  PSurface = ^TSurface;
  TSurface = packed record
    mat, flag, unk, light: byte;
  end;

  PSphere = ^TSphere;
  TSphere = packed record
    pos : TVector3F;
    r   : single;
    surf: TSurface;

    sel, hidden: boolean;
  end;

  PBox = ^TBox;
  TBox = packed record
    min,
    max : TVector3F;
    surf: TSurface;

    sel, hidden: boolean;
  end;

  PFaceGroup = ^TFaceGroup;
  TFaceGroup = packed record
    min, max: TVector3F;
    StartFace, EndFace: word;
  end;

  PVertex = ^TVertex;
  TVertex = packed record
    v  : TVector3F;

    sel, hidden: boolean;
  end;

  PFace = ^TFace;
  TFace = packed record
    a, b, c: word;
    surf: TSurface;

    n, center: TVector3F;
    //color: TVector4b;
    sel, hidden: boolean;
  end;

  PColObject = ^TColObject;
  TColObject = class(TComponent)
    private
      FModify   : procedure;
    public
      Ready,
      Modified,
      SAMode    : boolean;
      Ver       : TColVersion;
      Name      : string;
      id        : array[0..3] of char;
      Bounds    : TBounds;
      Sphere    : array of TSphere;
      Box       : array of TBox;
      Vertex    : array[0..1] of array of TVertex;
      Face      : array[0..1] of array of TFace;
      FaceGroup : array of TFaceGroup;

      procedure Modify;
      procedure SetVersion(v: TColVersion);

      procedure Init;
      function LoadFromStream(s: TStream): boolean;
      function SaveToStream(Handle: HWND; s: TStream; doOptimize: boolean): boolean;
      procedure CopyTo(dest: PColObject; merge: boolean; LOD: boolean = false);

      function GetInfo: string;
      function GetCount(SubObj, Mesh: integer): integer;
      function GetSelCount(SubObj, Mesh: integer; ind: PInteger): integer;
      function GetVisibleCount(SubObj, Mesh: integer): integer;

      function  GetSelCenter(SubObj, Mesh: integer; var center: TVector3f): boolean;
      procedure GetSelSurf(SubObj, Mesh: integer; var Mat, Flag, Unk, Light: integer);
      procedure SetSelSurfMat(Mat, SubObj, Mesh: integer);
      procedure SetSelSurfFlag(Flag, SubObj, Mesh: integer);
      procedure SetSelSurfUnk(Unk, SubObj, Mesh: integer);
      procedure SetSelSurfLight(Light, SubObj, Mesh: integer);
      procedure UpdateFace(Mesh, Index: integer; Flip: boolean = false);
      procedure DeleteSel(SubObj, Mesh: integer);
      procedure FlipSelFaces(Mesh: integer);
      procedure ReplaceByBox(SubObj, Mesh: integer);
      procedure MoveSel(SubObj, Mesh: integer; const Diff: TVector3f);

      procedure CreateSubObj(SubObj: integer);
      procedure DeleteSubObj(Mesh, Groups, Spheres, Boxes, ShadMesh: boolean);
      procedure CopyMesh(source, target: integer; SelOnly: boolean);
      procedure WeldVertices(Mesh: integer; Threshold: single);
      procedure DeleteDegenerateFaces(Mesh: integer);
      procedure DeleteIsolatedVerts(Mesh: integer);
      procedure GenerateFaceGroups;
//      procedure GenerateLighting(Lighting: TLighting);
      procedure GenerateBounds(minimize: boolean);
      procedure Mirror(x, y, z: boolean);

      procedure Optimize(complete, min_bounds: boolean);
      function  CheckMeshDimensions(Mesh: integer): boolean;

      procedure SelNone(SubObj, Mesh: integer);
      procedure SelAll(SubObj, Mesh: integer);
      procedure SelInvert(SubObj, Mesh: integer);
      procedure SelByMat(Mat, SubObj, Mesh: integer);

      procedure HideSel(SubObj, Mesh: integer);
      procedure UnhideAll(SubObj, Mesh: integer);

//      constructor Create(const ModifyFunc: Pointer);
      destructor Destroy; override;
  end;

  function GetFaceNormal(P1, P2, P3: TVector3f): TVector3f;
  function GetFaceCenter(P1, P2, P3: TVector3f): TVector3f;
  function GetMin(Min, V: TVector3f): TVector3f;
  function GetMax(Max, V: TVector3f): TVector3f;
  procedure GetMinMax(var Min, Max: TVector3f);
  procedure GetBoundingSphere(col: PColObject; out pos: TVector3f; out radius: single; SelectedOnly: boolean = false; SelMesh: integer = 0);
  procedure GetBoundingBox(col: PColObject; out min, max: TVector3f; SelectedOnly: boolean = false; SelMesh: integer = 0);

const
  COLVER: array[TColVersion] of array[0..3] of char = ('COLL', 'COL2', 'COL3');
  VERTXT: array[TColVersion] of string = ('Col 1', 'Col 2', 'Col 3');
  MY_ID = 'CED2';

  GROUPING_THRESHOLD = 80;
  GROUP_MAX_FACES    = 50;

  AUTO_MIN_BOUNDS = false;

var
  DefaultWeldingTreshold: single = 0.01;


implementation

{
constructor TColObject.Create(const ModifyFunc: Pointer);
begin
	inherited Create;
	FModify := ModifyFunc;
	Modified := true;
end;
}

destructor TColObject.Destroy;
begin
  Ready:=false;
  Name:='';
  SetLength(Sphere,    0);
  SetLength(Box,       0);
  SetLength(Vertex[0], 0);
  SetLength(Vertex[1], 0);
  SetLength(Face[0],   0);
  SetLength(Face[1],   0);
  SetLength(FaceGroup, 0);
  inherited Destroy;
end;

procedure TColObject.Modify;
begin
  Modified:=true;
  if Assigned(FModify) then FModify;
end;

procedure TColObject.SetVersion(v: TColVersion);
begin
  if Ver <> v then begin
    Ver := v;
    Modify;
  end;
end;


procedure TColObject.Init;
begin
  Ready  := false;

  Ver    := cvCOL3;
  SAMode := true;
  Name   := 'Unnamed';
  id     := MY_ID;
  fillchar(Bounds, sizeof(TBounds), 0);

  setLength(Sphere,    0);
  setLength(Box,       0);
  setLength(Vertex[0], 0);
  setLength(Face[0],   0);
  setLength(Vertex[1], 0);
  setLength(Face[1],   0);
  setLength(FaceGroup, 0);

  Ready := true;
  Modify;
end;

function TColObject.LoadFromStream(s: TStream): boolean;

  function ReadBounds: TBounds;
  begin
    FillChar(result, SizeOf(TBounds), 0);
    if Ver >= cvCOL2 then
      s.Read(result, 40)
    else begin
      s.Read(result.radius, 4);
      s.Read(result.center, 12);
      s.Read(result.min, 12);
      s.Read(result.max, 12);
    end;
  end;

  function ReadSphere: TSphere;
  begin
    FillChar(result, SizeOf(TSphere), 0);
    if Ver >= cvCOL2 then
      s.Read(result, 20)
    else begin
      s.Read(result.r, 4);
      s.Read(result.pos, 12);
      s.Read(result.surf, 4);
    end;
  end;

  function ReadBox: TBox;
  begin
    FillChar(result, SizeOf(TBox), 0);
    s.Read(result, 28);
  end;

  function ReadVertex: TVertex;
  var tmp: array[0..2] of smallint;
  begin
    FillChar(result, SizeOf(TVertex), 0);
    if Ver >= cvCOL2 then begin
      s.Read(tmp, 6);
      result.v[0]:=tmp[0]/128;
      result.v[1]:=tmp[1]/128;
      result.v[2]:=tmp[2]/128;
    end else
      s.Read(result, 12);
  end;

  function ReadFace: TFace;
  begin
    FillChar(result, SizeOf(TFace), 0);
    if Ver >= cvCOL2 then begin
      s.Read(result, 6);
      s.Read(result.surf.mat, 1);
      s.Read(result.surf.light, 1);
    end else begin
      s.Read(result.a, 2); s.Seek(2, soFromCurrent);
      s.Read(result.b, 2); s.Seek(2, soFromCurrent);
      s.Read(result.c, 2); s.Seek(2, soFromCurrent);
      s.Read(result.surf, 4);
    end;
  end;

  function ReadFaceGroup: TFaceGroup;
  begin
    s.Read(result, 28);
  end;

var
  i, m  : integer;
  offset,
  size  : cardinal;
  cname : array[0..19] of char;
  fourcc: array[0..3] of char;
  numSphere, numUnknown, numBox, numFaceGroup,
  Flags, SphereOffset, BoxOffset, UnkOffset, UnkOffset2: integer;

  numVertex, numFace, VertOffset, FaceOffset: array[0..1] of integer;

  //log: textfile;

begin
  result:=false;
  ready:=false;

  if (s.Read(fourcc, 4)<4) or (PCardinal(@fourcc)^=0) then exit
  else if (fourcc = COLVER[cvCOLL]) then ver := cvCOLL
  else if (fourcc = COLVER[cvCOL2]) then ver := cvCOL2
  else if (fourcc = COLVER[cvCOL3]) then ver := cvCOL3
  else begin
    //MessageDlg('Can''t parse data at 0x'+inttohex(s.Position-4, 8), mtError, [mbOk], 0);
    exit;
  end;

  SAMode := ver > cvCOLL;

  offset := s.Position;

  s.Read(size, 4);
  s.Read(cname, 20);
  s.Read(id, 4);

  name:=trim(cname);

  Bounds:=ReadBounds;

  if Ver >= cvCOL2 then begin

    numSphere:=0; s.Read(numSphere, 2);
    numBox:=0;    s.Read(numBox, 2);
    s.Read(numFace[0], 4);
    s.Read(Flags, 4);
    s.Read(SphereOffset, 4);
    s.Read(BoxOffset, 4);
    s.Read(UnkOffset, 4);
    s.Read(VertOffset[0], 4);
    s.Read(FaceOffset[0], 4);
    s.Read(UnkOffset2, 4);

    if Ver = cvCOL3 then begin
      s.Read(numFace[1], 4);
      s.Read(VertOffset[1], 4);
      s.Read(FaceOffset[1], 4);
    end else begin
      numFace[1]:=0;
      VertOffset[1]:=0;
      FaceOffset[1]:=0;
    end;

    SetLength(Sphere, numSphere);
    s.Position:=offset+SphereOffset;

    for i:=0 to numSphere-1 do Sphere[i]:=ReadSphere;

    SetLength(Box, numBox);
    s.Position:=offset+BoxOffset;

    for i:=0 to numBox-1 do Box[i]:=ReadBox;

    for m := 0 to 1 do begin

      numVertex[m]:=0;

      SetLength(Face[m], numFace[m]);
      s.Position:=offset+FaceOffset[m];
      for i:=0 to numFace[m]-1 do begin
        Face[m][i]:=ReadFace;
        if Face[m][i].a>=numVertex[m] then numVertex[m]:=Face[m][i].a+1;
        if Face[m][i].b>=numVertex[m] then numVertex[m]:=Face[m][i].b+1;
        if Face[m][i].c>=numVertex[m] then numVertex[m]:=Face[m][i].c+1;
      end;

      SetLength(Vertex[m], numVertex[m]);
      s.Position:=offset+VertOffset[m];
      for i:=0 to numVertex[m]-1 do Vertex[m][i]:=ReadVertex;

      for i:=0 to numFace[m]-1 do UpdateFace(m, i);
    end;

    // read face groups
    if (Flags and 8) > 0 then begin
      s.Position := offset + FaceOffset[0] - 4;
      s.Read(numFaceGroup, 4);
      SetLength(FaceGroup, numFaceGroup);
      s.Position := offset + FaceOffset[0] - 4 - numFaceGroup*28;

      for i:=0 to numFaceGroup-1 do
        FaceGroup[i]:=ReadFaceGroup;

    end else
      SetLength(FaceGroup, 0);

    ready:=true;

  end else begin

    s.Read(numSphere, 4);
    SetLength(Sphere, numSphere);
    for i:=0 to numSphere-1 do Sphere[i]:=ReadSphere;

    s.Read(numUnknown, 4);

    s.Read(numBox, 4);
    SetLength(Box, numBox);
    for i:=0 to numBox-1 do Box[i]:=ReadBox;

    s.Read(numVertex[0], 4); numVertex[1]:=0;
    SetLength(Vertex[0], numVertex[0]);
    for i:=0 to numVertex[0]-1 do Vertex[0][i]:=ReadVertex;

    s.Read(numFace[0], 4); numFace[1]:=0;
    SetLength(Face[0], numFace[0]);
    for i:=0 to numFace[0]-1 do Face[0][i]:=ReadFace;

    for i:=0 to numFace[0]-1 do UpdateFace(0, i);

    ready:=true;

  end;

  {$IFDEF dbg2}
    if ready then begin
      Assign(log, 'col.log');
      {$I-}
        Append(log);
      {$I+}
      if ioresult>0 then begin
        Rewrite(log);
        writeln(log, 'Name,              Flag, Vert, Face, FGrp, Sph.,  Box, ShdV, ShdF, Unk.'#13#10);
      end;
      writeln(log, name, ',', ' ':(20-length(name)), Flags:2, ', ', NumVertex[0]:4, ', ', NumFace[0]:4, ', ', length(FaceGroup):4, ', ', NumSphere:4, ', ', NumBox:4, ', ', NumVertex[1]:4, ', ', NumFace[1]:4, ', ', UnkOffset, ', ', UnkOffset2, ' - ', ((Flags in [0, 2, 10, 16, 18, 26]) and (UnkOffset=0) and (UnkOffset=0)));

      for i:=0 to length(FaceGroup)-1 do with FaceGroup[i] do
        writeln(log, '    ', EndFace - StartFace + 1 :4, ', ', max[0]-min[0]:6:2, ', ', max[1]-min[1]:6:2, ', ', max[2]-min[2]:6:2);

      Close(log);
    end;
  {$ENDIF}

  modified := false;

  s.Position := offset + 4 + size;
  result := true;
end; // LoadFromStream


function TColObject.SaveToStream(Handle: HWND; s: TStream; doOptimize: boolean): boolean;

  procedure WriteBounds(Bounds: PBounds);
  begin
    if Ver >= cvCOL2 then
      s.Write(Bounds^, 40)
    else begin
      s.Write(Bounds^.radius, 4);
      s.Write(Bounds^.center, 12);
      s.Write(Bounds^.min, 12);
      s.Write(Bounds^.max, 12);
    end;
  end;

  procedure WriteSphere(Sphere: PSphere);
  begin
    if Ver >= cvCOL2 then
      s.Write(Sphere^, 20)
    else begin
      s.Write(Sphere^.r, 4);
      s.Write(Sphere^.pos, 12);
      s.Write(Sphere^.surf, 4);
    end;
  end;

  procedure WriteBox(Box: PBox);
  begin
    s.Write(Box^, 28);
  end;

  procedure WriteVertex(Vertex: PVertex);
  var tmp: array[0..2] of smallint;
  begin
    if Ver >= cvCOL2 then begin
      tmp[0]:=round(Vertex^.v[0]*128);
      tmp[1]:=round(Vertex^.v[1]*128);
      tmp[2]:=round(Vertex^.v[2]*128);
      s.Write(tmp, 6);
    end else
      s.Write(Vertex^, 12);
  end;

  procedure WriteFace(Face: PFace);
  begin
    if Ver >= cvCOL2 then begin
      s.Write(Face^, 6);
      s.Write(Face^.surf.mat, 1);
      s.Write(Face^.surf.light, 1);
    end else begin
      s.Write(Face^.a, 2); s.Write(#0#0, 2);
      s.Write(Face^.b, 2); s.Write(#0#0, 2);
      s.Write(Face^.c, 2); s.Write(#0#0, 2);
      s.Write(Face^.surf, 4);
    end;
  end;

  procedure WriteFaceGroup(FaceGroup: PFaceGroup);
  begin
    s.Write(FaceGroup^, 28);
  end;

var
  cname : array[0..19] of char;

  i, Offset, Pos, Flags,
  numSphere,   SphereSize,
  numBox,      BoxSize,
  numVert,     VertSize,
  numGroup,    GroupSize,
  numFace,     FaceSize,
  numShadVert, ShadVertSize,
  numShadFace, ShadFaceSize,
  TotalSize: integer;

begin
  result:=false;

  if (ver >= cvCOL2) and not CheckMeshDimensions(0) then begin
    if MessageBox(Handle, PChar('The collision mesh for "'+name+'"'#13#10'exceeds the dimension limits of +/- 255.99 per axis.'#13#10#13#10'Do you still want to export it? (in Col 1 format)'), 'Exporting Problem', MB_ICONQUESTION + MB_YESNO) = ID_YES then
      SetVersion(cvColl)
    else
      exit;
  end else if (ver = cvCOL3) and not CheckMeshDimensions(1) then begin
    if MessageBox(Handle, PChar('The shadow mesh for "'+name+'"'#13#10'exceeds the dimension limits of +/- 255.99 per axis.'#13#10#13#10'Do you still want to export the model? (without shadow mesh)'), 'Exporting Problem', MB_ICONQUESTION + MB_YESNO) = ID_YES then
      SetVersion(cvColl)
    else
      exit;
  end;

  if modified then Optimize(doOptimize, AUTO_MIN_BOUNDS);

  // calculate sizes
  numSphere    := Length(Sphere);
  SphereSize   := numSphere * 20 + 4*ord(ver=cvCOLL);
  numBox       := Length(Box);
  BoxSize      := numBox * 28 + 4*ord(ver=cvCOLL);
  numVert      := length(Vertex[0]);
  VertSize     := numVert * 6 * (1+ord(ver=cvCOLL)) + 4*ord(ver=cvCOLL) + 2*ord((ver>=cvCOL2) and ((numVert*6) mod 4 > 0)); // padding
  numGroup     := length(FaceGroup) * ord(ver>=cvCOL2);
  GroupSize    := numGroup * 28 + 4*ord(numGroup>0);
  numFace      := length(Face[0]);
  FaceSize     := numFace * 8 * (1+ord(ver=cvCOLL)) + 4*ord(ver=cvCOLL);
  numShadVert  := length(Vertex[1]) * ord(ver=cvCOL3);
  ShadVertSize := numShadVert * 6 + 2*ord((numShadVert*6) mod 4 > 0); // padding
  numShadFace  := length(Face[1]) * ord(ver=cvCOL3);
  ShadFaceSize := numShadFace * 8;

  TotalSize := 20 + 4 + 40 + 36*ord(ver>=cvCOL2) + 12*ord(ver>=cvCOL3)
             + SphereSize + 4*ord(ver=cvCOLL) + BoxSize
             + VertSize + GroupSize + FaceSize + ShadVertSize + ShadFaceSize;

  FillChar(cname, 20, 0);
  Move(name[1], cname, MinInteger(length(name), 19));

  Pos := s.Position;       // backup position for later test
  s.Write(COLVER[ver], 4); // fourCC
  s.Write(TotalSize, 4);   // size
  s.Write(cname, 20);      // name
  s.Write(MY_ID, 4);       // ID

  WriteBounds(@Bounds);    // bounding objects

  if Ver >= cvCOL2 then begin

    // numbers
    s.Write(numSphere, 2);
    s.Write(numBox, 2);
    s.Write(numFace, 4);

    // flags
    Flags := 2 * ord((numVert>0) and (numFace>0) or (numSphere>0) or (numBox>0));
    Flags := Flags + 8 * ord((Flags=2) and (numGroup>0)) + 16 * ord((numShadVert>0) and (numShadFace>0));
    s.Write(Flags, 4);

    // offsets
    offset := 104 + 12*ord(ver>=cvCOL3);

    i := offset*ord(numSphere>0);
    s.Write(i, 4); // Spheres
    inc(offset, SphereSize);

    i := offset*ord(numBox>0);
    s.Write(i, 4); // Boxes
    inc(offset, BoxSize);

    s.Write(#0#0#0#0, 4); // Unk. Offset 1

    i := offset*ord(numVert>0);
    s.Write(i, 4); // Verts
    inc(offset, VertSize);

    inc(offset, GroupSize); // Face Groups

    i := offset*ord(numFace>0);
    s.Write(i, 4); // Faces
    inc(offset, FaceSize);

    s.Write(#0#0#0#0, 4); // Unk. Offset 2

    if Ver = cvCOL3 then begin
      s.Write(numShadFace, 4);

      i := offset*ord(numShadVert>0);
      s.Write(i, 4); // Shadow Verts
      inc(offset, ShadVertSize);

      i := offset*ord(numShadFace>0);
      s.Write(i, 4); // Shadow Faces
      inc(offset, ShadFaceSize);
    end;

    // write data

    for i:=0 to numSphere-1 do WriteSphere(@Sphere[i]);
    for i:=0 to numBox-1 do WriteBox(@Box[i]);
    for i:=0 to numVert-1 do WriteVertex(@Vertex[0][i]);
    if (numVert*6) mod 4 > 0 then s.Write(#0#0, 2); // padding

    if numGroup > 0 then begin
      for i:=0 to numGroup-1 do WriteFaceGroup(@FaceGroup[i]);
      s.Write(numGroup, 4);
    end;

    for i:=0 to numFace-1 do WriteFace(@Face[0][i]);

    for i:=0 to numShadVert-1 do WriteVertex(@Vertex[1][i]);
    if (numShadVert*6) mod 4 > 0 then s.Write(#0#0, 2); // padding
    for i:=0 to numShadFace-1 do WriteFace(@Face[1][i]);

    if s.Position <> pos + 4 + offset then showmessage('problem');

  end else begin

    // write data

    s.Write(numSphere, 4);
    for i:=0 to numSphere-1 do WriteSphere(@Sphere[i]);

    s.Write(#0#0#0#0, 4);

    s.Write(numBox, 4);
    for i:=0 to numBox-1 do WriteBox(@Box[i]);

    s.Write(numVert, 4);
    for i:=0 to numVert-1 do WriteVertex(@Vertex[0][i]);

    s.Write(numFace, 4);
    for i:=0 to numFace-1 do WriteFace(@Face[0][i]);

  end;

  //modified := false;
  result := true;
end; //SaveToStream

procedure TColObject.CopyTo(dest: PColObject; merge: boolean; LOD: boolean = false);
const
  COPYSTR = 'Copy of';
var
  i, j, len, mesh: integer;
begin
  if not Assigned(dest) then exit;

  dest.ready := false;

  if merge then begin // copy (add)

    dest.SAMode := SAMode;
    dest.Ver    := Ver;

    for mesh := 0 to 1 do begin

      len := length(dest.Vertex[mesh]);
      SetLength(dest.Vertex[mesh], len + length(Vertex[mesh]));
      Move(Vertex[Mesh, 0], dest.Vertex[Mesh, len], length(Vertex[mesh]) * sizeof(TVertex));

      j := length(dest.Face[mesh]);
      SetLength(dest.Face[mesh], j + length(Face[mesh]));
      Move(Face[Mesh, 0], dest.Face[Mesh, j], length(Face[mesh]) * sizeof(TFace));
      for i := j to length(dest.Face[Mesh])-1 do with dest.Face[Mesh, i] do begin
        a := a + len;
        b := b + len;
        c := c + len;
      end;

    end;

    setLength(dest.FaceGroup, 0);

    j := length(dest.Sphere);
    SetLength(dest.Sphere, j + length(Sphere));
    Move(Sphere[0], dest.Sphere[j], length(Sphere) * sizeof(TSphere));

    j := length(dest.Box);
    SetLength(dest.Box, j + length(Box));
    Move(Box[0], dest.Box[j], length(Box) * sizeof(TBox));

  end else begin // copy (overwrite)

    dest.SAMode := SAMode;
    dest.Ver    := Ver;
    dest.id     := id;
    dest.Bounds := Bounds;

    if LOD then begin

      dest.Name    := Name;
      dest.Name[1] := 'L';
      dest.Name[2] := 'O';
      dest.Name[3] := 'D';

      setLength(dest.Sphere,    0);
      setLength(dest.Box,       0);
      setLength(dest.Vertex[0], 0);
      setLength(dest.Face[0],   0);
      setLength(dest.Vertex[1], 0);
      setLength(dest.Face[1],   0);
      setLength(dest.FaceGroup, 0);

    end else begin

      if lowercase(copy(Name, 1, length(COPYSTR))) = lowercase(COPYSTR) then
        dest.Name := Name
      else
        dest.Name := COPYSTR+' '+Name;

      setLength(dest.Sphere, length(Sphere));
      move(Sphere[0], dest.Sphere[0], length(Sphere) * sizeof(TSphere));

      setLength(dest.Box, length(Box));
      move(Box[0], dest.Box[0], length(Box) * sizeof(TBox));

      setLength(dest.Face[0], length(Face[0]));
      move(Face[0][0], dest.Face[0][0], length(Face[0]) * sizeof(TFace));

      setLength(dest.FaceGroup, length(FaceGroup));
      move(FaceGroup[0], dest.FaceGroup[0], length(FaceGroup) * sizeof(TFaceGroup));

      setLength(dest.Vertex[0], length(Vertex[0]));
      move(Vertex[0][0], dest.Vertex[0][0], length(Vertex[0]) * sizeof(TVertex));

      setLength(dest.Face[1], length(Face[1]));
      move(Face[1][0], dest.Face[1][0], length(Face[1]) * sizeof(TFace));

      setLength(dest.Vertex[1], length(Vertex[1]));
      move(Vertex[1][0], dest.Vertex[1][0], length(Vertex[1]) * sizeof(TVertex));

    end;

  end;

  Dest.Ready := true;
  Dest.Modify;
end;


function TColObject.GetInfo: string;
const
  yesno: array[boolean] of string = ('No', 'Yes');
var
  s, tool: string;
  i: integer;
begin
  if ID=MY_ID then
    tool:='CollEditor II'
  else if ID='STMU' then
    tool:='CollMaker/CollEditor'
  else if ID='DCOL' then
    tool:='Col-IO'
  else
    tool:='Unknown';

  s:='Name: "'+Name+'" ('+VERTXT[Ver]+')'#13#10#13#10+
     'Created by: '+tool+#13#10#13#10+
     'Modified:   '+yesno[Modified]+#13#10#13#10+
     'Dimensions:'#13#10+
     '  Length:   '+formatfloat('0.0##', abs(Bounds.min[0]-Bounds.max[0]))+#13#10+
     '  Width:    '+formatfloat('0.0##', abs(Bounds.min[1]-Bounds.max[1]))+#13#10+
     '  Height:   '+formatfloat('0.0##', abs(Bounds.min[2]-Bounds.max[2]))+#13#10#13#10+
     'Collision Mesh:'#13#10+
     '  Vertices: '+inttostr(length(Vertex[0]))+#13#10+
     '  Faces:    '+inttostr(length(Face[0]))+#13#10+
     '  Groups:   '+inttostr(length(FaceGroup))+#13#10+
     '  Spheres:  '+inttostr(length(Sphere))+#13#10+
     '  Boxes:    '+inttostr(length(Box))+#13#10#13#10+
     'Shadow Mesh:'+#13#10+
     '  Vertices: '+inttostr(length(Vertex[1]))+#13#10+
     '  Faces:    '+inttostr(length(Face[1]));

  {$IFDEF dbg}
  s:=s+#13#10;
  for i:=0 to length(Face[0])-1 do
    s:=s+format(#13#10'%d %d %d', [Face[0, i].a, Face[0, i].b, Face[0, i].c]);
  {$ENDIF}

  result:=s;
end;

function TColObject.GetCount(SubObj, Mesh: integer): integer;
begin
  case SubObj of
    0: result:=length(Vertex[Mesh]);
    1: result:=length(Face[Mesh]);
    2: result:=length(Sphere);
    3: result:=length(Box);
  else
    result:=0;
  end;
end;

function TColObject.GetSelCount(SubObj, Mesh: integer; ind: PInteger): integer;
var i: integer;
begin
  result:=0;
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do
      if Vertex[Mesh][i].sel and not Vertex[Mesh][i].hidden then begin
        inc(result);
        if Assigned(ind) then ind^:=i;
      end;
    1: for i:=0 to length(Face[Mesh])-1 do
      if Face[Mesh][i].sel and not Face[Mesh][i].hidden then begin
        inc(result);
        if Assigned(ind) then ind^:=i;
      end;
    2: for i:=0 to length(Sphere)-1 do
      if Sphere[i].sel and not Sphere[i].hidden then begin
        inc(result);
        if Assigned(ind) then ind^:=i;
      end;
    3: for i:=0 to length(Box)-1 do
      if Box[i].sel and not Box[i].hidden then begin
        inc(result);
        if Assigned(ind) then ind^:=i;
      end;
  end;
end;

function TColObject.GetVisibleCount(SubObj, Mesh: integer): integer;
var i: integer;
begin
  result:=0;
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do if not Vertex[Mesh][i].hidden then inc(result);
    1: for i:=0 to length(Face[Mesh])-1   do if not Face[Mesh][i].hidden   then inc(result);
    2: for i:=0 to length(Sphere)-1 do if not Sphere[i].hidden then inc(result);
    3: for i:=0 to length(Box)-1    do if not Box[i].hidden    then inc(result);
  end;
end;

function TColObject.GetSelCenter(SubObj, Mesh: integer; var center: TVector3f): boolean;
var i, num: integer;
begin
  center := NullVector;
  num := 0;

  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do with Vertex[Mesh][i] do
      if sel and not hidden then begin
        AddVector(center, v);
        inc(num);
      end;
    1: for i:=0 to length(Face[Mesh])-1 do
      if Face[Mesh][i].sel and not Face[Mesh][i].hidden then begin
        AddVector(center, Face[Mesh][i].center);
        inc(num);
      end;
    2: for i:=0 to length(Sphere)-1 do with Sphere[i] do
      if sel and not hidden then begin
        AddVector(center, Pos);
        inc(num);
      end;
    3: for i:=0 to length(Box)-1 do
      if Box[i].sel and not Box[i].hidden then with Box[i] do begin
        AddVector(center, VectorScale(VectorAdd(min, max), 0.5));
        inc(num);
      end;
  end;

  if num > 1 then ScaleVector(center, 1/num);
  result := num > 0;
end;

procedure TColObject.GetSelSurf(SubObj, Mesh: integer; var Mat, Flag, Unk, Light: integer);
var
  i, numLight: integer;
  noMat, noFlag, noUnk: boolean;
begin
  Mat:=-1; Flag:=-1; Unk:=-1; Light:=0; numLight:=0;
  noMat:=false; noFlag:=false; noUnk:=false;

  case SubObj of
    1: begin
         for i:=0 to length(Face[Mesh])-1 do
           {if not (noMat and noFlag and noUnk) then} with Face[Mesh][i] do
             if sel and not hidden then begin
               if not noMat then begin if Mat<0 then Mat:=Surf.Mat else if Mat<>Surf.Mat then begin noMat:=true; Mat:=-1; end; end;
               if not noFlag then begin if Flag<0 then Flag:=Surf.Flag else if Flag<>Surf.Flag then begin noFlag:=true; Flag:=-1; end; end;
               if not noUnk then begin if Unk<0 then Unk:=Surf.Unk else if Unk<>Surf.Unk then begin noUnk:=true; Unk:=-1; end; end;
               inc(Light, Surf.Light); inc(numLight);
             end;
       end;
    2: begin
         for i:=0 to length(Sphere)-1 do
           {if not (noMat and noFlag and noUnk) then} with Sphere[i] do
             if sel and not hidden then begin
               if not noMat then begin if Mat<0 then Mat:=Surf.Mat else if Mat<>Surf.Mat then begin noMat:=true; Mat:=-1; end; end;
               if not noFlag then begin if Flag<0 then Flag:=Surf.Flag else if Flag<>Surf.Flag then begin noFlag:=true; Flag:=-1; end; end;
               if not noUnk then begin if Unk<0 then Unk:=Surf.Unk else if Unk<>Surf.Unk then begin noUnk:=true; Unk:=-1; end; end;
               inc(Light, Surf.Light); inc(numLight);
             end;
       end;
    3: begin
         for i:=0 to length(Box)-1 do
           {if not (noMat and noFlag and noUnk) then} with Box[i] do
             if sel and not hidden then begin
               if not noMat then begin if Mat<0 then Mat:=Surf.Mat else if Mat<>Surf.Mat then begin noMat:=true; Mat:=-1; end; end;
               if not noFlag then begin if Flag<0 then Flag:=Surf.Flag else if Flag<>Surf.Flag then begin noFlag:=true; Flag:=-1; end; end;
               if not noUnk then begin if Unk<0 then Unk:=Surf.Unk else if Unk<>Surf.Unk then begin noUnk:=true; Unk:=-1; end; end;
               inc(Light, Surf.Light); inc(numLight);
             end;
       end;
  end;

  if numLight>0 then Light := round(Light/numLight);
end;

procedure TColObject.SetSelSurfMat(Mat, SubObj, Mesh: integer);
var i, j: integer;
begin
  j:=0;

  case SubObj of
    1: for i:=0 to length(Face[Mesh])-1 do with Face[Mesh][i] do if not hidden and sel then begin surf.Mat:=Mat; inc(j); end;
    2: for i:=0 to length(Sphere)-1 do with Sphere[i] do if not hidden and sel then begin surf.Mat:=Mat; inc(j); end;
    3: for i:=0 to length(Box)-1 do with Box[i] do if not hidden and sel then begin surf.Mat:=Mat; inc(j); end;
  end;

  if j>0 then Modify;
end;

procedure TColObject.SetSelSurfFlag(Flag, SubObj, Mesh: integer);
var i, j: integer;
begin
  j:=0;

  case SubObj of
    1: for i:=0 to length(Face[Mesh])-1 do with Face[Mesh][i] do if not hidden and sel then begin surf.Flag:=Flag; inc(j); end;
    2: for i:=0 to length(Sphere)-1 do with Sphere[i] do if not hidden and sel then begin surf.Flag:=Flag; inc(j); end;
    3: for i:=0 to length(Box)-1 do with Box[i] do if not hidden and sel then begin surf.Flag:=Flag; inc(j); end;
  end;

  if j>0 then Modify;
end;

procedure TColObject.SetSelSurfUnk(Unk, SubObj, Mesh: integer);
var i, j: integer;
begin
  j:=0;

  case SubObj of
    1: for i:=0 to length(Face[Mesh])-1 do with Face[Mesh][i] do if not hidden and sel then begin surf.Unk:=Unk; inc(j); end;
    2: for i:=0 to length(Sphere)-1 do with Sphere[i] do if not hidden and sel then begin surf.Unk:=Unk; inc(j); end;
    3: for i:=0 to length(Box)-1 do with Box[i] do if not hidden and sel then begin surf.Unk:=Unk; inc(j); end;
  end;

  if j>0 then Modify;
end;

procedure TColObject.SetSelSurfLight(Light, SubObj, Mesh: integer);
var i, j: integer;
begin
  j:=0;

  case SubObj of
    1: for i:=0 to length(Face[Mesh])-1 do with Face[Mesh][i] do if not hidden and sel then begin surf.Light:=Light; inc(j); end;
    2: for i:=0 to length(Sphere)-1 do with Sphere[i] do if not hidden and sel then begin surf.Light:=Light; inc(j); end;
    3: for i:=0 to length(Box)-1 do with Box[i] do if not hidden and sel then begin surf.Light:=Light; inc(j); end;
  end;

  if j>0 then Modify;
end; 

procedure TColObject.UpdateFace(Mesh, Index: integer; Flip: boolean = false);
var tmp: word;
begin
  with Face[Mesh, Index] do begin
    if Flip then begin
      tmp:=a; a:=b; b:=tmp;
    end;
    n := GetFaceNormal(vertex[Mesh][a].v, vertex[Mesh][c].v, vertex[Mesh][b].v);
    center := GetFaceCenter(vertex[Mesh][a].v, vertex[Mesh][b].v, vertex[Mesh][c].v);
  end;
end;

procedure TColObject.DeleteSel(SubObj, Mesh: integer);
var i, j: integer;
begin
  i:=0; j:=0;

  case SubObj of
    0: ; //todo: Delete Selection - Verts
    1: begin
         j:=0;
         for i:=0 to length(Face[Mesh])-1 do if Face[Mesh][i].hidden or not Face[Mesh][i].sel then begin
           if j<i then Face[Mesh][j]:=Face[Mesh][i];
           inc(j);
         end;
         i:=length(Face[Mesh]);
         setlength(Face[Mesh], j);
         if (j<i) and (Mesh=0) then DeleteSubObj(false, true, false, false, false);
       end;
    2: begin
         j:=0;
         for i:=0 to length(Sphere)-1 do if Sphere[i].hidden or not Sphere[i].sel then begin
           if j<i then Sphere[j]:=Sphere[i];
           inc(j);
         end;
         i:=length(Sphere);
         setlength(Sphere, j);
       end;
    3: begin
         j:=0;
         for i:=0 to length(Box)-1 do if Box[i].hidden or not Box[i].sel then begin
           if j<i then Box[j]:=Box[i];
           inc(j);
         end;
         i:=length(Box);
         setlength(Box, j);
       end;
  end;

  if j<i then Modify;
end;

procedure TColObject.FlipSelFaces(Mesh: integer);
var i: integer;
begin
  for i:=0 to length(Face[Mesh])-1 do with Face[Mesh, i] do if sel and not hidden then UpdateFace(Mesh, i, true);
  Modify;
end;

procedure TColObject.ReplaceByBox(SubObj, Mesh: integer);
var
  i: integer;
  min, max: TVector3f;
  first: boolean;
  surf: TSurface;
begin
  if Mesh <> 0 then exit;

  first := true;

  case SubObj of

    1: begin
         for i:=0 to length(Face[Mesh])-1 do if Face[Mesh, i].sel and not Face[Mesh, i].hidden then begin
           if first then begin
             min := Vertex[Mesh, Face[Mesh, i].a].v;
             max := min;
             surf := Face[Mesh, i].surf;
             first := false;
           end;

           min := GetMin(min, Vertex[Mesh, Face[Mesh, i].a].v);
           min := GetMin(min, Vertex[Mesh, Face[Mesh, i].b].v);
           min := GetMin(min, Vertex[Mesh, Face[Mesh, i].c].v);
           max := GetMax(max, Vertex[Mesh, Face[Mesh, i].a].v);
           max := GetMax(max, Vertex[Mesh, Face[Mesh, i].b].v);
           max := GetMax(max, Vertex[Mesh, Face[Mesh, i].c].v);
         end;

         if not first then begin
           i := length(Box);
           setLength(Box, i+1);
           FillChar(Box[i], SizeOf(TBox), 0);
           Box[i].Surf := surf;
           Box[i].Min := min;
           Box[i].Max := max;
           DeleteSel(SubObj, Mesh);
         end;
       end;

  end;

end;

procedure TColObject.MoveSel(SubObj, Mesh: integer; const Diff: TVector3f);
var i: integer;
begin
  if VectorLength(Diff) < EPSILON2 then exit;

  case SubObj of
    0:
      begin
        for i:=0 to length(Vertex[Mesh])-1 do with Vertex[Mesh][i] do
          if sel and not hidden then AddVector(v, diff);
        for i:=0 to length(Face[Mesh])-1 do UpdateFace(Mesh, i);
      end;
    1:; //todo: Move Selection - faces
    2:
      for i:=0 to length(Sphere)-1 do with Sphere[i] do
        if sel and not hidden then AddVector(pos, diff);
    3:
      for i:=0 to length(Box)-1 do with Box[i] do
        if sel and not hidden then begin
          AddVector(min, diff);
          AddVector(max, diff);
        end;
  end;

  //Modify;
  GenerateBounds(false);
end;

procedure TColObject.CreateSubObj(SubObj: integer);
var l: integer;
begin
  SelNone(SubObj, 0);

  case SubObj of
    2: // Sphere
      begin
        l := length(Sphere);
        SetLength(Sphere, l+1);
        with Sphere[l] do begin
          FillChar(Sphere[l], SizeOf(TSphere), 0);
          Pos := AffineVectorMake(0, 0, 1);
          r := 1;
          sel := true;
        end;
      end;
    3: // Box
      begin
        l := length(Box);
        SetLength(Box, l+1);
        with Box[l] do begin
          FillChar(Box[l], SizeOf(TBox), 0);
          Min := AffineVectorMake(-1, -1, 0);
          Max := AffineVectorMake(1, 1, 2);
          sel := true;
        end;
      end;
  end;

  GenerateBounds(false);
end;

procedure TColObject.DeleteSubObj(Mesh, Groups, Spheres, Boxes, ShadMesh: boolean);
begin
  Ready := false;

  if Mesh then begin
    setLength(Face[0], 0);
    setLength(Vertex[0], 0);
  end;

  if Mesh or Groups then
    setLength(FaceGroup, 0);

  if Spheres then
    setLength(Sphere, 0);

  if Boxes then
    setLength(Box, 0);

  if ShadMesh then begin
    setLength(Face[1], 0);
    setLength(Vertex[1], 0);
  end;

  Ready := true;

  Modify;
end;

procedure TColObject.CopyMesh(source, target: integer; SelOnly: boolean);
var i, num: integer;
begin
  if source = target then exit;

  ready := false;

  SetLength(Vertex[target], length(Vertex[source]));
  Move(Vertex[source][0], Vertex[target][0], length(Vertex[source])*SizeOf(TVertex));

  SetLength(Face[target], length(Face[source]));
  if SelOnly then begin
    num := 0;
    for i:=0 to length(Face[source])-1 do if Face[source, i].sel and not Face[source, i].hidden then begin
      Face[target, num] := Face[source, i];
      inc(num);
    end;
    setLength(Face[target], num);
    DeleteIsolatedVerts(target);
  end else
    Move(Face[source][0], Face[target][0], length(Face[source])*SizeOf(TFace));

  if target = 0 then
    DeleteSubObj(false, true, false, false, false)
  else if target = 1 then
    for i:=0 to length(Face[1])-1 do FillChar(Face[1, i].surf, 3, 0);

  ready := true;

  Modify;
end;

procedure TColObject.WeldVertices(Mesh: integer; Threshold: single);
var
  i, j, k, n, vertcount: integer;
  pivot: PAffineVector;
  sum: TVector3f;
  //vertdata: array of packed record new_ind, num_pos: integer; end;
  IndexMap: array of integer;
  Mark: packed array of boolean;

begin

  vertcount := length(Vertex[Mesh]);

  SetLength(IndexMap, vertcount);
  SetLength(Mark, vertcount);
  FillChar(Mark[0], vertcount, 0);

  Threshold := sqr(Threshold);

  // mark duplicates, compute barycenters and IndexMap
  i:=0; k:=0;
  while i < vertcount do begin
    if not mark[i] then begin
      pivot := @Vertex[Mesh, i].v;
      IndexMap[i] := k;
      n := 0;
      j := vertcount-1;
      while j > i do begin
        if not mark[j] then begin
          if VectorDistance2(pivot^, Vertex[Mesh, j].v) <= Threshold then begin
            if n = 0 then begin
              sum := VectorAdd(pivot^, Vertex[Mesh, j].v);
              n := 2;
            end else begin
              AddVector(sum, Vertex[Mesh, j].v);
              Inc(n);
            end;
            IndexMap[j] := k;
            mark[j] := True;
          end;
        end;
        Dec(j);
      end;
      if n > 0 then Vertex[Mesh, i].v := VectorScale(sum, 1/n);
      Inc(k);
    end;
    Inc(i);
  end;

  // pack vertex list
  k:=0;
  for i:=0 to vertcount-1 do if not mark[i] then begin
    Vertex[Mesh, k].v := Vertex[Mesh, i].v;
    Inc(k);
  end;
  SetLength(Vertex[Mesh], k);

  //showmessage('verts: '+inttostr(vertcount)+' -> '+inttostr(k));

  // remap indices
  for i:=0 to length(Face[Mesh])-1 do with Face[Mesh, i] do begin
    a := IndexMap[a];
    b := IndexMap[b];
    c := IndexMap[c];
    UpdateFace(Mesh, i);
  end;

  (* num := length(Vertex[Mesh]);

  if num < 2 then exit;

  SetLength(vertdata, num);
  for i:=0 to num-1 do with vertdata[i] do begin
    new_ind := -1; num_pos := 1;
  end;

  Threshold := sqr(Threshold);

  repeat
    k:=0;
    for i:=0 to num-1 do if vertdata[i].new_ind = -1 then begin
      for j:=i+1 to num-1 do if vertdata[j].new_ind = -1 then begin
        v := VectorAffineSubtract(Vertex[Mesh, i].v, Vertex[Mesh, j].v);
        if VectorNorm(v) <= Threshold then begin
          Vertex[Mesh, i].v := VectorAffineAdd(Vertex[Mesh, i].v, Vertex[Mesh, j].v);
          inc(vertdata[i].num_pos);
          vertdata[j].new_ind := i;
          inc(k);
        end;
      end;
      //vertdata[i].new_ind := i;
      if vertdata[i].num_pos > 1 then begin
        ScaleVector(Vertex[Mesh, i].v, 1/vertdata[i].num_pos);
        vertdata[i].num_pos:=1;
        //inc(k);
      end;
    end;
    showmessage(inttostr(k));
  until k = 0;

  showmessage('done1');

  for i:=0 to length(Face[Mesh])-1 do with Face[Mesh, i] do begin
    while vertdata[a].new_ind > -1 do a := vertdata[a].new_ind;
    while vertdata[b].new_ind > -1 do b := vertdata[b].new_ind;
    while vertdata[c].new_ind > -1 do c := vertdata[c].new_ind;
    UpdateFace(Mesh, i);
  end;

  showmessage('done2');  *)

  Modify;
end;

procedure TColObject.DeleteDegenerateFaces(Mesh: integer);
var i, j: integer;
begin
  j:=0;
  for i:=0 to length(Face[Mesh])-1 do with Face[Mesh][i] do
    if (a <> b) and (a <> c) and (b <> c) then begin
      if j<i then Face[Mesh][j]:=Face[Mesh][i];
      inc(j);
    end;

  i:=length(Face[Mesh]);
  setlength(Face[Mesh], j);

  //showmessage('faces: '+inttostr(i)+' -> '+inttostr(j));

  if j < i then begin
    if Mesh = 0 then DeleteSubObj(false, true, false, false, false);
    Modify;
  end;
end;


procedure TColObject.DeleteIsolatedVerts(Mesh: integer);
var
  i, j, num: integer;
  vertdata: array of packed record used: boolean; new: integer; end;
begin
  num := length(vertex[Mesh]);

  if num = 0 then exit;

  ready := false;

  setLength(vertdata, num);
  fillchar(vertdata[0], num*5, 0);

  for i:=0 to length(face[Mesh])-1 do begin
    vertdata[face[Mesh][i].a].used := true;
    vertdata[face[Mesh][i].b].used := true;
    vertdata[face[Mesh][i].c].used := true;
  end;

  j:=0;
  for i:=0 to num-1 do if vertdata[i].used then begin
    if j<i then vertex[Mesh][j] := vertex[Mesh][i];
    vertdata[i].new := j;
    inc(j);
  end;
  setLength(vertex[Mesh], j);

  for i:=0 to length(face[Mesh])-1 do begin
    face[Mesh][i].a := vertdata[face[Mesh][i].a].new;
    face[Mesh][i].b := vertdata[face[Mesh][i].b].new;
    face[Mesh][i].c := vertdata[face[Mesh][i].c].new;
  end;

  ready := true;

  Modify;
end;

procedure TColObject.GenerateFaceGroups;
type
  PGroupNode = ^TGroupNode;
  TGroupNode = record
    Min, Max: TVector3F;
    Num, Axis: integer;
    lo, hi: PGroupNode;
  end;

var
  nodelink: array of PGroupNode;
  tmpface:  array of TFace;
  numGroup, numFace: integer;

  procedure CalcNodeBox(n: PGroupNode);
  var
    i: integer;
    first: boolean;
  begin
    first:=true;
    for i:=0 to length(nodelink)-1 do if nodelink[i]=n then begin
      if first then begin
        n.Min := face[0, i].center;
        n.Max := face[0, i].center;
        first := false;
      end else begin
        n.Min := GetMin(n.Min, face[0, i].center);
        n.Max := GetMax(n.Max, face[0, i].center);
      end;
    end;
  end;

  procedure FindSplitAxis(n: PGroupNode);
  var
    i: integer;
    dist: single;
  begin
    dist:=0;
    for i:=0 to 2 do if n.Max[i]-n.Min[i] > dist then begin
      dist := n.Max[i]-n.Min[i];
      n.Axis := i;
    end;
  end;

  procedure SplitNode(n: PGroupNode);
  var
    halfaxis: single;
    i: integer;
  begin
    CalcNodeBox(n);
    FindSplitAxis(n);

    with n^ do if n.Num > GROUP_MAX_FACES then begin
      // we have to split our box

      halfaxis := (Min[Axis]+Max[Axis]) / 2;
      num := 0;
      inc(numGroup);

      hi := new(PGroupNode);
      hi.num := 0;
      hi.Min := n.Min;
      hi.Max := n.Max;
      hi.Min[Axis] := halfaxis;

      lo := new(PGroupNode);
      lo.num := 0;
      lo.Min := n.Min;
      lo.Max := n.Max;
      lo.Max[Axis] := halfaxis;

      for i:=0 to length(nodelink)-1 do if nodelink[i]=n then begin
        if face[0, i].center[Axis] < halfaxis then begin
          nodelink[i] := lo;
          inc(lo.num);
        end else begin
          nodelink[i] := hi;
          inc(hi.num);
        end;
      end;

      SplitNode(lo);
      SplitNode(hi);
    end else begin
      lo := nil;
      hi := nil;
    end;
  end; 

  procedure TraverseTree(n: PGroupNode);
  var
    i: integer;
  begin
    if Assigned(n) then begin
      if n.Num > 0 then begin
        FaceGroup[numGroup].min := n.Min;
        FaceGroup[numGroup].max := n.Max;
        FaceGroup[numGroup].StartFace := numFace;

        for i:=0 to length(Face[0])-1 do if nodelink[i] = n then begin
          tmpface[numFace] := Face[0, i];
          inc(numFace);
        end;

        FaceGroup[numGroup].EndFace := numFace-1;

        inc(numGroup);
      end;
      TraverseTree(n.lo);
      TraverseTree(n.hi);
      Dispose(n);
    end;
  end;

var
  root: PGroupNode;
  i{, oldnum}: integer;

begin
  //todo: generate face groups - improve algo

  //oldnum := length(FaceGroup);
  SetLength(FaceGroup, 0);
  SetLength(nodelink, length(Face[0]));

  if length(Face[0]) > GROUPING_THRESHOLD then begin

    // init binary group tree root
    numGroup := 1;
    root := New(PGroupNode);
    root.Num := length(nodelink);
    for i:=0 to root.Num-1 do nodelink[i] := root;

    // build tree
    SplitNode(root);

    // extend bounding boxes
    for i:=0 to length(Face[0])-1 do begin
      nodelink[i].Min := GetMin(nodelink[i].Min, Vertex[0, Face[0, i].a].v);
      nodelink[i].Min := GetMin(nodelink[i].Min, Vertex[0, Face[0, i].b].v);
      nodelink[i].Min := GetMin(nodelink[i].Min, Vertex[0, Face[0, i].c].v);
      nodelink[i].Max := GetMax(nodelink[i].Max, Vertex[0, Face[0, i].a].v);
      nodelink[i].Max := GetMax(nodelink[i].Max, Vertex[0, Face[0, i].b].v);
      nodelink[i].Max := GetMax(nodelink[i].Max, Vertex[0, Face[0, i].c].v);
    end;

    // build group box array and sort faces
    setLength(FaceGroup, numGroup);
    setLength(tmpface, length(Face[0]));
    numGroup := 0;
    numFace  := 0;
    TraverseTree(root);
    Move(tmpface[0], Face[0, 0], length(tmpface)*sizeof(TFace));
    setLength(tmpface, 0);

    {if numGroup>oldnum then
      showmessage(inttostr(numGroup-oldnum)+' groups more')
    else if numGroup<oldnum then
      showmessage(inttostr(oldnum-numGroup)+' groups less');}

  end;

  Modify;
end;

{procedure TColObject.GenerateLighting(Lighting: TLighting);
var
  i: integer;
  lv: TVector3f;
  dp: single;
begin

  if Lighting.Directional then begin
    lv[0] := cos(Lighting.Azimuth-pi/2) * cos(Lighting.Altitude);
    lv[1] := sin(Lighting.Azimuth-pi/2) * cos(Lighting.Altitude);
    lv[2] := sin(Lighting.Altitude);

    for i:=0 to length(Face[0])-1 do with Face[0, i] do begin
      dp := VectorDotProduct(lv, n);
      if dp <= 0 then
        surf.Light := Lighting.Ambient
      else
        surf.light := round(Lighting.Ambient + (Lighting.Intensity-Lighting.Ambient) * dp);
    end;

  end else
    for i:=0 to length(Face[0])-1 do Face[0, i].surf.light := Lighting.Intensity;

  Modify;
end;}

procedure TColObject.GenerateBounds(minimize: boolean);
var
  new_min, new_max: TVector3f;
begin
  // todo: better bounds algo

  // Make sure min and max are correct
  GetMinMax(Bounds.min, Bounds.max);

  GetBoundingBox(@self, new_min, new_max);

  if minimize then begin
    Bounds.min := new_min;
    Bounds.max := new_max;
  end else begin
    Bounds.min := GetMin(Bounds.min, new_min);
    Bounds.max := GetMax(Bounds.max, new_max);
  end;

  Bounds.center := VectorAdd(Bounds.min, Bounds.max);
  ScaleVector(Bounds.center, 1/2);
  new_min := VectorSubtract(Bounds.max, Bounds.center); // tmp
  Bounds.radius := VectorLength(new_min);

  //GetBoundingSphere(@self, Bounds.center, Bounds.radius);

  Modify;

end;

procedure TColObject.Mirror(x, y, z: boolean);

  procedure MirrorVector(var v: TVector3f; const axis: array of boolean);
  var i: integer;
  begin
    for i:=0 to 2 do if axis[i] then v[i] := -v[i];
  end;

var
  i: integer;
  flip: boolean;
begin
  if not (x or y or z) then exit;

  flip := odd( ord(x) + ord(y) + ord(z) );

  for i:=0 to length(Vertex[0])-1 do MirrorVector(Vertex[0, i].v, [x, y, z]);
  for i:=0 to length(Face[0])-1 do UpdateFace(0, i, flip);
  for i:=0 to length(Vertex[1])-1 do MirrorVector(Vertex[1, i].v, [x, y, z]);
  for i:=0 to length(Face[1])-1 do UpdateFace(1, i, flip);
  for i:=0 to length(Sphere)-1 do MirrorVector(Sphere[i].pos, [x, y, z]);
  for i:=0 to length(Box)-1 do begin
    MirrorVector(Box[i].min, [x, y, z]);
    MirrorVector(Box[i].max, [x, y, z]);
  end;

  MirrorVector(Bounds.min,    [x, y, z]);
  MirrorVector(Bounds.max,    [x, y, z]);
  MirrorVector(Bounds.center, [x, y, z]);

  setLength(FaceGroup, 0);
  Modify;
end;


procedure TColObject.Optimize(complete, min_bounds: boolean);
var Mesh: integer;
begin
  //todo: optimize
  if complete then for Mesh := 0 to 1 do begin
    WeldVertices(Mesh, DefaultWeldingTreshold);
    DeleteDegenerateFaces(Mesh);
    DeleteIsolatedVerts(Mesh);
  end;
  GenerateFaceGroups;
  GenerateBounds(min_bounds);
end;

function TColObject.CheckMeshDimensions(Mesh: integer): boolean;
var i, j: integer;
begin
  result:=true;
  i:=0;
  while result and (i<length(Vertex[Mesh])) do with Vertex[Mesh, i] do begin
    for j:=0 to 2 do
      if (v[j] < -255.99) or (v[j] > 255.99) then result := false;
    inc(i);
  end;
end;


procedure TColObject.SelNone(SubObj, Mesh: integer);
var i: integer;
begin
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do if not Vertex[Mesh][i].hidden then Vertex[Mesh][i].sel:=false;
    1: for i:=0 to length(Face[Mesh])-1   do if not Face[Mesh][i].hidden   then Face[Mesh][i].sel:=false;
    2: for i:=0 to length(Sphere)-1 do if not Sphere[i].hidden then Sphere[i].sel:=false;
    3: for i:=0 to length(Box)-1    do if not Box[i].hidden    then Box[i].sel:=false;
  end;
end;

procedure TColObject.SelAll(SubObj, Mesh: integer);
var i: integer;
begin
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do if not Vertex[Mesh][i].hidden then Vertex[Mesh][i].sel:=true;
    1: for i:=0 to length(Face[Mesh])-1   do if not Face[Mesh][i].hidden   then Face[Mesh][i].sel:=true;
    2: for i:=0 to length(Sphere)-1 do if not Sphere[i].hidden then Sphere[i].sel:=true;
    3: for i:=0 to length(Box)-1    do if not Box[i].hidden    then Box[i].sel:=true;
  end;
end;

procedure TColObject.SelInvert(SubObj, Mesh: integer);
var i: integer;
begin
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do if not Vertex[Mesh][i].hidden then Vertex[Mesh][i].sel:=not Vertex[Mesh][i].sel;
    1: for i:=0 to length(Face[Mesh])-1   do if not Face[Mesh][i].hidden   then Face[Mesh][i].sel:=not Face[Mesh][i].sel;
    2: for i:=0 to length(Sphere)-1 do if not Sphere[i].hidden then Sphere[i].sel:=not Sphere[i].sel;
    3: for i:=0 to length(Box)-1    do if not Box[i].hidden    then Box[i].sel:=not Box[i].sel;
  end;
end;

procedure TColObject.SelByMat(Mat, SubObj, Mesh: integer);
var i: integer;
begin
  case SubObj of
    1: for i:=0 to length(Face[Mesh])-1   do if not Face[Mesh][i].hidden   then Face[Mesh][i].sel := (Face[Mesh][i].Surf.Mat = Mat);
    2: for i:=0 to length(Sphere)-1 do if not Sphere[i].hidden then Sphere[i].sel := (Sphere[i].Surf.Mat = Mat);
    3: for i:=0 to length(Box)-1    do if not Box[i].hidden    then Box[i].sel := (Box[i].Surf.Mat = Mat);
  end;
end;

procedure TColObject.HideSel(SubObj, Mesh: integer);
var i: integer;
begin
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do Vertex[Mesh][i].hidden:=Vertex[Mesh][i].sel;
    1: for i:=0 to length(Face[Mesh])-1   do Face[Mesh][i].hidden  :=Face[Mesh][i].sel;
    2: for i:=0 to length(Sphere)-1 do Sphere[i].hidden:=Sphere[i].sel;
    3: for i:=0 to length(Box)-1    do Box[i].hidden   :=Box[i].sel;
  end;
end;

procedure TColObject.UnhideAll(SubObj, Mesh: integer);
var i: integer;
begin
  case SubObj of
    0: for i:=0 to length(Vertex[Mesh])-1 do Vertex[Mesh][i].hidden:=false;
    1: for i:=0 to length(Face[Mesh])-1   do Face[Mesh][i].hidden:=false;
    2: for i:=0 to length(Sphere)-1 do Sphere[i].hidden:=false;
    3: for i:=0 to length(Box)-1    do Box[i].hidden:=false;
  end;
end;


function GetFaceNormal(P1, P2, P3: TVector3f): TVector3f;
// calculate a face's normal
begin
  result:=VectorCrossProduct(VectorSubtract(P2, P1), VectorSubtract(P3, P1));
  NormalizeVector(result);
end;

function GetFaceCenter(P1, P2, P3: TVector3f): TVector3f;
// calculate a face's center point
begin
  result[0] := (P1[0] + P2[0] + P3[0]) / 3;
  result[1] := (P1[1] + P2[1] + P3[1]) / 3;
  result[2] := (P1[2] + P2[2] + P3[2]) / 3;
end;

function GetMin(Min, V: TVector3f): TVector3f;
begin
  if v[0] < Min[0] then result[0] := v[0] else result[0] := Min[0];
  if v[1] < Min[1] then result[1] := v[1] else result[1] := Min[1];
  if v[2] < Min[2] then result[2] := v[2] else result[2] := Min[2];
end;

function GetMax(Max, V: TVector3f): TVector3f;
begin
  if v[0] > Max[0] then result[0] := v[0] else result[0] := Max[0];
  if v[1] > Max[1] then result[1] := v[1] else result[1] := Max[1];
  if v[2] > Max[2] then result[2] := v[2] else result[2] := Max[2];
end;

procedure GetMinMax(var Min, Max: TVector3f);
var
  i: integer;
  tmp: single;
begin
  for i:=0 to 2 do if Min[i] > Max[i] then begin
    tmp := Min[i];
    Min[i] := Max[i];
    Max[i] := tmp;
  end;
end;

procedure GetBoundingSphere(col: PColObject; out pos: TVector3f; out radius: single; SelectedOnly: boolean = false; SelMesh: integer = 0);
// todo: GetBoundingSphere

// based on:
// http://www.csl.sony.co.jp/person/nielsen/PT/seb/sebdisk.html

// void sebdisk(disk2d *P, int n, Real e,  disk2d &seb)
(*
var
  e, r, rs, l, x, ym, y_M, zm, z_M common, xmin, xmax, xm, x_M, a, b, dist, adist, d, maxd: single;
  i, n, d1, d2: integer;
  ebpierceable, qdisjoint: boolean;
*)
begin
(*
	n := length(col.sphere);
	if n=0 then exit;

  // Initialization
	//

  e := 0.01;

  with col.Sphere[0] do begin
    xmin := Pos[0] - r;
    xmax := Pos[0] + r;
    maxd := r;
  end;

	for i:=1 to n-1 do with col.Sphere[i] do begin
	  xmin := MinFloat(xmin, Pos[0] - r);
    xmax := MaxFloat(xmax, Pos[0] + r);
    d := VectorDistance(col.Sphere[0].Pos, Pos) + r;
	  maxd := MaxFloat(maxd, d);
  end;

  // optimal radius lies in range [a,b] always greater than (xmax-xmin)/2
	b := maxd;
  a := MaxFloat(b/2, col.Sphere[0].r);
	e := e * (b/2); // Convert to absolute epsilon precision.

	while b-a > e do begin

		r := (a+b)/2;
    rs := sqr(r);

		// candidate strip

    // band intersection all disks
		x_M := xmin + r;
    xm := xmax-r;

		ebpierceable := false;
    qdisjoint := false;

		// dichotomy for the decision problem
		while ((x_M > xm) and (x_M-xm > e) and not ebpierceable and not qdisjoint) do begin
			l := (xm+x_M)/2;
      d1 := 0; d2 := 0;

			common := sqrt(sqr(r-col.Sphere[0].r) - sqr(l-col.Sphere[0].Pos[0]));
			ym := col.Sphere[0].Pos[1] - common;
      y_M := col.Sphere[0].Pos[1] + common;
      zm := col.Sphere[0].Pos[2] - common; // *new*
      z_M := col.Sphere[0].Pos[2] + common; // *new*

      i := 1;
			while ((i < n) and (ym <= y_M)) do begin
				common := sqrt(sqr(r-col.Sphere[i].r) - sqr(l-col.Sphere[i].Pos[0]));

				// those tests are of degree 4
				if (ym < col.Sphere[i].Pos[1] - common) then begin
          d1 := i;
          ym := col.Sphere[i].Pos[1] - common;
        end;
				if (y_M > col.Sphere[i].Pos[1] + common) then begin
          d2 := i;
          y_M := col.Sphere[i].Pos[1] + common;
        end;
				inc(i);
      end;

      {i := 1;
			while ((i < n) and (zm <= z_M)) do begin
				common := sqrt(sqr(r-col.Sphere[i].r) - sqr(l-col.Sphere[i].Pos[0]));

				// those tests are of degree 4
				if (zm < col.Sphere[i].Pos[2] - common) then begin
          d1 := i;
          zm := col.Sphere[i].Pos[2] - common;
        end;
				if (z_M > col.Sphere[i].Pos[2] + common) then begin
          d2 := i;
          z_M := col.Sphere[i].Pos[2] + common;
        end;
				inc(i);
      end;}


			if (y_M >= ym) then begin
				Pos[0] := l; Pos[1] := ym;
				ebpierceable := true;
			end else begin // choose on which side to recurse
				dist := VectorDistance(col.Sphere[d1].Pos, col.Sphere[d2].Pos);
				adist := (sqr(col.Sphere[d1].r) - sqr(col.Sphere[d2].r) + sqr(dist)) / (2*dist);
				x := col.Sphere[d1].Pos[0] + (adist/dist) * (col.Sphere[d2].Pos[0] - col.Sphere[d1].Pos[0]);
				if (x > l) then xm := l else x_M := l;
      end;
    end;

		if ebpierceable then begin
      b := r;
      radius := r;
    end else
      a := r;

  end;
*)
end;

procedure GetBoundingBox(col: PColObject; out min, max: TVector3f; SelectedOnly: boolean = false; SelMesh: integer = 0);
var i: integer;
begin
  // todo: GetBoundingBox

  // Get initial boundaries
  if length(col.Vertex[0])>0 then
    min := col.Vertex[0, 0].v
  else if length(col.Vertex[1])>0 then
    min := col.Vertex[1, 0].v
  else if length(col.Sphere)>0 then
    min := col.Sphere[0].pos
  else if length(col.Box)>0 then
    min := col.Box[0].min
  else begin
    {if minimize then begin
      FillChar(Bounds, sizeof(TBounds), 0);
      Modify;
    end;}
    min := NullVector;
    max := NullVector;
    exit;
  end;
  max := min;

  for i:=0 to length(col.Vertex[0])-1 do with col.Vertex[0, i] do begin
    min := GetMin(min, v);
    max := GetMax(max, v);
  end;

  for i:=0 to length(col.Vertex[1])-1 do with col.Vertex[1, i] do begin
    min := GetMin(min, v);
    max := GetMax(max, v);
  end;

  for i:=0 to length(col.Sphere)-1 do with col.Sphere[i] do begin
    min := GetMin(min, AffineVectorMake(pos[0]-r, pos[1]-r, pos[2]-r));
    max := GetMax(max, AffineVectorMake(pos[0]+r, pos[1]+r, pos[2]+r));
  end;

  for i:=0 to length(col.Box)-1 do with col^ do begin
    GetMinMax(Box[i].min, Box[i].max);
    min := GetMin(min, Box[i].min);
    max := GetMax(max, Box[i].max);
  end;
end;

end.
