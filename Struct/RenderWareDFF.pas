// Written by KCow (Alastair Burr) as part of moomapper.

unit RenderWareDFF;

interface

uses
  Classes, Controls, Dialogs,
  ExtCtrls, Forms, Graphics, Messages, OpenGL12, rwtxd, StdCtrls, SysUtils, vectortypes, Windows;

const
  // sections
  rwDATA      = 1;
  rwSTRING    = 2;
  rwEXTENSION = 3;
  rwTEXTURE   = 6;
  rwMATERIALLIST = 8;
  rwMATERIAL  = 7;
  rwFRAMELIST = 14;
  rwGEOMETRY  = 15;
  rwCLUMP     = 16;
  rwATOMIC    = 20;
  rwGEOMETRYLIST = 26;
  rwAnimPlugin = 286;
  rwMATERIALEFFECTS = 288; // xvehicleenv128
  rwMATERIALSPLIT = 1294; // bin mesh plg
  rwFRAME     = $253F2FE;
  nvcolors    = $253F2F9;

  // constants for geometry data
  rwOBJECT_VERTEX_TRISTRIP = $1;
  rwOBJECT_VERTEX_POSITIONS = $2;
  rwOBJECT_VERTEX_UV     = $4;
  rwOBJECT_VERTEX_COLOR  = $8;
  rwOBJECT_VERTEX_NORMAL = $10;
  rwOBJECT_VERTEX_LIGHT  = $20;
  rwOBJECT_VERTEX_MODULATE = $40;
  rwOBJECT_VERTEX_TEXTURED = $80;

  // rockstar north extensions
  rnmultitexturespeca = $253F2F6;
  col3                = $253F2FA;
  particles           = $253F2F8;


type
  TVector3i = array [0..2] of longint;
  //  TVector3f = array [0..2] of Single;
  //TMatrix3f = array [0..2] of TVector3f;
  TMatrix3f = array [0..2, 0..2] of single;//TVector3f;

  TMatrix4f = array [0..3, 0..3] of single;//TVector4f;

  // big part collision info here is based on research of Steve M and Kam.
  TVector3W = array [0..2] of word; // float:= vector[n] / 128;

  Tcollbox = packed record
    box_min, box_max: TVector3f;
  end;

  Tcollsphere = packed record
    sphere_center:      TVector3f;
    sphere_radius:      single;
    SurfaceA, SurfaceB: word;
  end; // 40 bytes needed

  Tcolface = packed record
    A, B, C: word;
    SurfaceA, SurfaceB: word;
	end;

	Tcollisionmodel = packed record
    col3: array[0..3] of char;
    size: longword;
    Name: array[0..23] of char;
    box_min, box_max, sphere_center: TVector3f;
    sphere_radius: single;
		Spherec: byte;
		a: array[0..3] of byte; // wtf.
    ColFacec,
    LW12,
    OFSspheres,
    LW0_0,
    LW0_1,
    OFS_VERT,
    OFS_Faces,
    LW0_2,
    ShadowFacec,
    OFSShadowvert,
    OFSShadowFace: longword;

    Dspheres: array of Tcollsphere;

    // collision mesh
    ColVerts: array of TVector3W;
    ColFaces: array of Tcolface;

    ColShadeVerts: array of TVector3W;
    ColShadeFaces: array of Tcolface;

  end; // 120 bytes

  TDFFFace = record
    V2: word;
    V1: word;
    material: word;
    V3: word;
  end;

  TDFFUV = record
    U, V: single;
  end;

  TDFFUVMAP = array of TDFFUV;

  TDFFFrame = record
    Name: string;

    matrix4: TMatrix4f;

    Matrix: TMatrix3f;
    Coord:  TVector3f;

    Parent: longint;
    Other1, Other2: word;
    internaldata: pointer; // used by GGMM
  end;

  // data parts

  TDFFDataClump = record
    ObjectCount: longword;
  end;

  TDFFDataFrameList = record
    FrameCount: longword;
    Frame:      array of TDFFFrame;
  end;

  TDFFDataGeometryList = record
    GeometryCount: longword;
  end;

  TDFFDataAtomic = record
    FrameNum:    longword;
    GeometryNum: longword;
    Other1:      longword; //D: 5
    Other2:      longword; //D: 0
  end;

  TDFFHeaderDataGeometry = record
    Flags: word;
    UVmaps, unknown: byte;

    TriangleCount: longword;
    VertexCount:   longword;
    MorphCount:    longword; // was OtherCount
  end;

  TDFFLightHeaderDataGeometry = record
    Ambient:  single;
    Diffuse:  single;
    Specular: single;
  end;

  TDFFDataGeometryBoundingSphere = record
    boundingsphere: TVector3f;
    BoundingRadius: single;
    Other1, Other2: longword; //D: 1
  end;

  TDFFDataGeometry = record
    Header: TDFFHeaderDataGeometry;

    LightHeader: TDFFLightHeaderDataGeometry;

    VertexColors: array of longword;
    NightColors: array of longword;

    UVmaps: array of TDFFUVMAP;

    Face: array of TDFFFace;

    BoundingSphere: TDFFDataGeometryBoundingSphere;

    Vertex: array of TVector3f;

    Normal: array of TVector3f;
  end;

  TDFFDataMaterialList = record
    MaterialCount: longword;
    Other: longword; //D: FF
  end;

  TDFFColor = packed array[0..4] of byte;

  TDFFDataMaterial = packed record
    Other1: longword; //D: 0 // alpha params?
    Color:  TDFFColor;
    Other3: longword;
    TextureCount: longword; //D: 1

    Other5: single; //D: 1.0 // shine?
    Other6: single;          // size?
    Other7: single; //D: 1.0 // opacity?
  end;

  TDFFDataTexture = record
  end;

  // level 5

  TDFFExtensionTexture = record
    Data: array[0..59] of byte;
    x:    array[0..47] of char;
  end;

  TDFFTextureMatPlugin = packed record
    lw2a:  longword;
    lw2b:  longword;
    flags: longword;
    lw0a:  longword;

    stuff:      array[0..31] of byte;
    maptype:    longword; // 16 = san andreas xvehicleenv (second uv map thing), 20 = sphere mapping (like chrome)
    FFFFthing:  longword;
    vehicleenv: array[0..15] of char;
    morestuff:  array[0..300] of byte;

    // no speca:
    //    2
    //    2
    //    0
    //    0
    //    0
    //    0

    // with speca:
    //    2
    //    2
    //    bit flags? (1065353216) (-------- -------- *------- --******)
    //    0
    //    1
    //    6
    //    72           -> some kind of section size indicator, add to position 4 bytes (data seem to belong to this header) and the data size will be at this number + 8
    //    FF FF 03 18
    //    1
    //    4
    //    FF FF 03 18
    //    flags (69894)
    //    2
    //    1
    //    FF FF 03 18
    //    26 bytes text padded with zeroes to 4 byte alignment (xvehicleenv128)
    //    2
    //    4
    //    FF FF 03 18
    //    0
    //    3
    //    0
    //    FF FF 03 18
    //    0

    // ..up to 288 bytes of garbage..
  end;

  TDFFTexture = record
    Data:    TDFFDataTexture;
    Name:    string;
    Desc:    string;
    GotName: boolean;

    // delfi's hack for san andreas reflections
    speca: array[0..255] of char;

    matpluginsize: integer;

    matplugin: TDFFTextureMatPlugin;

    //    Extension: TDFFExtensionTexture;
  end;

  // level 4

  TDFFMaterial = record
    Data:    TDFFDataMaterial;
    _test_Offset: integer;
    Texture: TDFFTexture;
    //Extension: TDFFExtensionMaterial;
  end;

  // level 3

  TDFFHeaderMaterialSplit = record
    TriagleFormat: longword; // 0 = triangles, 1= trianglestrip
    SplitCount:    longword;
    FaceCount:     longword;
  end;

  TDFFSplit = record
    FaceIndex:     longword;
    MaterialIndex: longword;

    Index: array of longword;
  end;

  TDFFMaterialSplit = record
    Header: TDFFHeaderMaterialSplit;
    Split:  array of TDFFSplit;
  end;

  TDFFMaterialList = record
    Data:     TDFFDataMaterialList;
    Material: array of TDFFMaterial;
    MaterialCount: word;
  end;

  // level 2

  Tparticleemitter = packed record
    entrytype: longword;
    Position: TVector3f;
    fuckknows: longword;
    particlenamebufflen: longword;
    particlename: string[24];
  end;


  TDFFGeometry = record
    Data: TDFFDataGeometry;
    MaterialList: TDFFMaterialList;
    MaterialSplit: TDFFMaterialSplit;
    pems: array of Tparticleemitter;
  end;

  // level 1

  TDFFFrameList = record
    Data: TDFFDataFrameList;
  end;

  TDFFGeometryList = record
    Data:     TDFFDataGeometryList;
    Geometry: array of TDFFGeometry;
    GeometryCount: longword;
  end;

  TDFFAtomic = record
    Data: TDFFDataAtomic;
    //Extension: TDFFExtensionAtomic;
  end;

  // level 0
  TDFFClump = record
    Data:      TDFFDataClump;
    FrameList: TDFFFrameList;
    GeometryList: TDFFGeometryList;
    Atomic:    array of TDFFAtomic;
	AtomicCount: word;
	col3: TMemorystream;
//    col3:      Tcollisionmodel;
    RadiusSphere: single;
  end;

  // header

  TDFFHeader = record
    Start: longword;
    Back:  longword;

    Tag:  longword;
    Size: longword;
    renderversion: longword;
    //    Data: Word; //D: 784
    //    Version: Word;
  end;

  TDffLoader = class
  private
    function GetNextHeader(Stream: TStream; Level, Parent: longint): TDFFHeader;
    procedure ParseData(Stream: TStream; ParseHeader: TDFFHeader; Parent: longint);
    procedure ParseMaterialSplit(Stream: TStream; ParseHeader: TDFFHeader; Parent: longint);
    procedure ParseHeaders(Stream: TStream; ParseHeader: TDFFHeader; Level, Parent: longint);
    procedure ParseString(Stream: TStream; ParseHeader: TDFFHeader; Level, Parent: longint);
  public
    Clump:     array of TDFFClump;
    FrameUpTo: longint;
    lastofs:   integer;
    loaded:    boolean;
    filenint:  string;
    DLID:      longword;
    wheelrenders: boolean;
    used: boolean;
    primcolor: Tcolor;
    seccolor: Tcolor;
    procedure ResetClump;
    procedure LoadFromFile(FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure DropDL;
    procedure Unload;

    procedure glDraw(texture: Ttxdloader; sectexture: Ttxdloader; texreportonly: boolean; highlight: integer; nightcolors: boolean; plzdontinstance: boolean);
    procedure glDrawRecurse(in_clump: longword; in_frame: longint; texture: Ttxdloader; sectexture: Ttxdloader; TheParent: boolean; texreportonly: boolean; highlight: integer; nightcolors: boolean; plzdontinstance: boolean);
    procedure renderawheel(parent: string; texture: Ttxdloader; sectexture: Ttxdloader; plzdontinstance: boolean);
  end;

var
  GTA_TEXTURE_MODE: boolean = False;

implementation

{$IFDEF map_editor}
uses u_edit;
{$ENDIF}

function min(a, b: single): single;
begin
result:= a;
if b < a then result:= b;
end;

function max(a, b: single): single;
begin
result:= a;
if b > a then result:= b;
end;

function isprim(col: TDFFColor): boolean;
begin
  Result := False;
  if col[0] = 60 then
    if col[1] = 255 then
      if col[2] = 0 then
        if col[3] = 255 then
          Result := True;
end;

function isterc(col: TDFFColor): boolean;
begin
  Result := False;
  if col[0] = 0 then
    if col[1] = 255 then
      if col[2] = 255 then
        Result := True;
end;

function islightcolor(col: TDFFColor): boolean;
begin
  Result := False;
  // for lights alpha is not important at all, just a RGB match is enough
  if col[0] = 255 then
    if col[1] = 175 then
      if col[2] = 0 then
        Result := True; // left front
  if col[0] = 0 then
    if col[1] = 255 then
      if col[2] = 200 then
        Result := True; // right front
  if col[0] = 185 then
    if col[1] = 255 then
      if col[2] = 200 then
        Result := True; // right front (COPCARRU BUG?)
  if col[0] = 255 then
    if col[1] = 0 then
      if col[2] = 175 then
        Result := True; // ?
  if col[0] = 255 then
    if col[1] = 0 then
      if col[2] = 175 then
        if col[3] = 255 then
          Result := True; // ?
end;

function issec(col: TDFFColor): boolean;
begin
  Result := False;
  if col[0] = 255 then
    if col[1] = 0 then
      if col[2] = 175 then
        if col[3] = 255 then
          Result := True;
end;

function GetRWVersion(ver: cardinal): cardinal; // Steve M.
var
  b: byte;
begin
  b      := ver shr 24;
  Result := (3 + b shr 6) shl 16 + ((b shr 2) and $0F) shl 12 + (b and $03) shl 8 + byte(ver shr 16);
end;

function DecompressVector(v: TVector3W): TVector3F; // Steve M.
begin
  Result[0] := (smallint(v[0]) / 128);
  Result[1] := (smallint(v[1]) / 128);
  Result[2] := (smallint(v[2]) / 128);
end;

procedure TDffLoader.ResetClump;
var
  i: integer;
begin
  for i := 0 to High(Clump) do
  begin
    SetLength(Clump[i].Atomic, 0);
    SetLength(Clump[i].GeometryList.Geometry, 0);
    SetLength(Clump[i].FrameList.Data.Frame, 0);
  end;
  Clump := nil;
end;

procedure TDffLoader.LoadFromStream(Stream: TStream);
var
  MainHeader: TDFFHeader;
begin
  ResetClump;
  MainHeader.Start := 16;
  MainHeader.Tag := 0;
  MainHeader.Size := Stream.Size;
  MainHeader.renderversion := 0;//Data := 0;
  //  MainHeader.Version := 0;
  MainHeader.Back := 0;
  loaded := False;
  wheelrenders:= false;

  ParseHeaders(Stream, MainHeader, 0, 16);
  loaded := True;

  //  lastofs:= stream.position;
end;

procedure TDffLoader.LoadFromFile(FileName: string);
var
  Stream: Tmemorystream;
begin
  DLID     := 0;
  Stream   := Tmemorystream.Create;
  filenint := filename;
  stream.loadfromfile(FileName);
  //  application.processmessages;
  LoadFromStream(Stream);
  //  application.processmessages;
  Stream.Free;
end;

procedure TDffLoader.ParseMaterialSplit(Stream: TStream; ParseHeader: TDFFHeader; Parent: longint);
var
  I: longint;
begin
  with Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].MaterialSplit do
  begin
    // ShowMessage(IntToStr(Stream.Position));
    Stream.Read(Header, SizeOf(Header));

    SetLength(Split, Header.SplitCount);

    for I := 0 to Header.SplitCount - 1 do
    begin
      Stream.Read(Split[I].FaceIndex, 4);
      Stream.Read(Split[I].MaterialIndex, 4);

      SetLength(Split[I].Index, Split[I].FaceIndex);
      Stream.Read(Split[I].Index[0], 4 * Split[I].FaceIndex);
    end;
  end;
end;

procedure TDffLoader.ParseData(Stream: TStream; ParseHeader: TDFFHeader; Parent: longint);
var
  I, J, fix: longword;
  f: file;
  c: integer;
begin

  case Parent of

    rwCLUMP:
    begin
      Stream.Read(Clump[High(Clump)].Data.ObjectCount, 4);
    end;

    rwMATERIALLIST:
    begin
      with Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].MaterialList.Data do
      begin
        Stream.Read(MaterialCount, 4);
        Stream.Read(Other, 4);
      end;
    end;

    rwMATERIAL:
    begin
      with Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].MaterialList.Material[Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].MaterialList.MaterialCount - 1] do
      begin
        Texture.GotName := False;
        _test_Offset    := Stream.Position;
        //showmessage(inttostr(Stream.Position));
        Stream.Read(Data, SizeOf(Data));

        // output colors
{// outputdebugstring(
pchar(
format('color: %d %d %d %d', [Data.Color[0], Data.Color[1], Data.Color[2], Data.Color[3]
])
)
);}
      end;
    end;

    rwGEOMETRYLIST:
    begin
      Stream.Read(Clump[High(Clump)].GeometryList.Data.GeometryCount, 4);
    end;

    rwATOMIC:
    begin
      with Clump[High(Clump)].Atomic[Clump[High(Clump)].AtomicCount - 1].Data do
      begin
        Stream.Read(FrameNum, 4);
        Stream.Read(GeometryNum, 4);
        Stream.Read(Other1, 4);
        Stream.Read(Other2, 4);
      end;
    end;

    rwFRAMELIST:
    begin
      with Clump[High(Clump)].FrameList.Data do
      begin
        Stream.Read(FrameCount, 4);
        SetLength(Frame, FrameCount);
        FrameUpTo := 0;

        for I := 0 to FrameCount - 1 do
        begin

          for J := 0 to 2 do
          begin
            Stream.Read(Frame[I].Matrix[J], 12);
          end;
          begin
            Stream.Read(Frame[I].Coord, 12);
          end;

          fillchar(Frame[I].Matrix4, sizeof(Frame[I].Matrix4), 0);

          Frame[I].Matrix4[0, 0] := 1;
          Frame[I].Matrix4[1, 1] := 1;
          Frame[I].Matrix4[2, 2] := 1;

          Frame[I].Matrix4[0, 0] := Frame[I].Matrix[0, 0];
          Frame[I].Matrix4[0, 1] := Frame[I].Matrix[0, 1];
          Frame[I].Matrix4[0, 2] := Frame[I].Matrix[0, 2];

          Frame[I].Matrix4[1, 0] := Frame[I].Matrix[1, 0];
          Frame[I].Matrix4[1, 1] := Frame[I].Matrix[1, 1];
          Frame[I].Matrix4[1, 2] := Frame[I].Matrix[1, 2];

          Frame[I].Matrix4[2, 0] := Frame[I].Matrix[2, 0];
          Frame[I].Matrix4[2, 1] := Frame[I].Matrix[2, 1];
          Frame[I].Matrix4[2, 2] := Frame[I].Matrix[2, 2];

          Frame[I].Matrix4[3, 0] := frame[I].Coord[0];
          Frame[I].Matrix4[3, 1] := frame[I].Coord[1];
          Frame[I].Matrix4[3, 2] := frame[I].Coord[2];

          Frame[I].Matrix4[3, 3] := 1;

          Stream.Read(Frame[I].Parent, 4);
          Stream.Read(Frame[I].Other1, 2);
          Stream.Read(Frame[I].Other2, 2);
        end;
      end;
    end;

    rwGEOMETRY:
    begin
      with Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].Data do
      begin

        fix := stream.position;

        Stream.Read(Header, SizeOf(Header));

        // Scene colors only for RW versions before 3.4 (GTA3)
        if GetRWVersion(ParseHeader.renderversion) < $34000 then
          Stream.Read(LightHeader, SizeOf(LightHeader))
        else
          FillChar(LightHeader, SizeOf(LightHeader), 0);

        // outputdebugstring(pchar('Start: ' + inttostr(fix)));
        // outputdebugstring(pchar('Flags: ' + inttostr(Header.Flags)));
        // outputdebugstring(pchar('UVmaps: ' + inttostr(Header.UVmaps)));
        // outputdebugstring(pchar('unknown: ' + inttostr(Header.unknown)));
        // outputdebugstring(pchar('TriangleCount: ' + inttostr(Header.TriangleCount)));
        // outputdebugstring(pchar('VertexCount: ' + inttostr(Header.VertexCount)));
        // outputdebugstring(pchar('MorphCount: ' + inttostr(Header.MorphCount)));

{
  rwOBJECT_VERTEX_TRISTRIP = $1;
  rwOBJECT_VERTEX_POSITIONS = $2;
  rwOBJECT_VERTEX_UV = $4;
  rwOBJECT_VERTEX_COLOR = $8;
  rwOBJECT_VERTEX_NORMAL = $10; // 16
  rwOBJECT_VERTEX_LIGHT = $20;
  rwOBJECT_VERTEX_MODULATE = $40;
  rwOBJECT_VERTEX_TEXTURED = $80;
}

        // read vertex colors
        if (rwOBJECT_VERTEX_COLOR and Header.Flags) = rwOBJECT_VERTEX_COLOR then
        begin
          // outputdebugstring('READING: VERTEX COLORS');
          SetLength(VertexColors, Header.VertexCount);
          Stream.Read(Pointer(VertexColors)^, 4 * Header.VertexCount);
        end
        else
          SetLength(VertexColors, 0);

        // zmodeler2 compatibility - zmodeler2 doesn't set the flags properly.
        // we can aniway find if uv channels are present from uv channel count (as gta seem to do this as well)

        //        if (rwOBJECT_VERTEX_UV and Header.Flags) = rwOBJECT_VERTEX_UV then
        //        If ((Header.Flags and rwOBJECT_VERTEX_UV) <> 0) or ((Header.Flags and 128) <> 0) then
        //        begin

        if header.UVmaps <> 0 then
        begin
          setlength(uvmaps, header.UVmaps);
          // outputdebugstring('READING: UV data');

          for i := 0 to header.UVmaps - 1 do
          begin
            setlength(uvmaps[i], Header.VertexCount);
            Stream.Read(UVmaps[i][0], 8 * Header.VertexCount);
          end;
        end
        else
          SetLength(UVmaps, 0);

{        If ((Header.Flags and rwOBJECT_VERTEX_UV) <> 0) or ((Header.Flags and 128) <> 0) then
        begin
          SetLength(UV, Header.VertexCount);
          Stream.Read(UV[0], 8 * Header.VertexCount); // read first uv map

          if header.UVmaps = 2 then // read second uv map
          Stream.Read(UV2[0], 8 * Header.VertexCount);

          stream.Seek((8 * Header.VertexCount) * (header.UVmaps - 1), sofromcurrent);
        end else
          SetLength(UV, 0);}

        // outputdebugstring('READING: FACE INDICES');
        SetLength(Face, Header.TriangleCount);
        Stream.Read(Pointer(Face)^, 8 * Header.TriangleCount);

        // outputdebugstring('READING: Bounding Sphere');
        Stream.Read(BoundingSphere, SizeOf(BoundingSphere));

        // outputdebugstring('READING: VERTICES');
        SetLength(Vertex, Header.VertexCount);
        Stream.Read(Pointer(Vertex)^, 12 * Header.VertexCount);

				Clump[High(Clump)].RadiusSphere := 0;

				for c := 0 to high(Vertex) do
				begin
					if vertex[c][0] > Clump[High(Clump)].RadiusSphere then
						Clump[High(Clump)].RadiusSphere := vertex[c][0];
					if vertex[c][1] > Clump[High(Clump)].RadiusSphere then
						Clump[High(Clump)].RadiusSphere := vertex[c][1];
					if vertex[c][2] > Clump[High(Clump)].RadiusSphere then
						Clump[High(Clump)].RadiusSphere := vertex[c][2];
				end;

//				Clump[High(Clump)].FrameList.Data.Frame[0].matrix4

        if (rwOBJECT_VERTEX_NORMAL and Header.Flags) = rwOBJECT_VERTEX_NORMAL then
        begin
          // outputdebugstring('READING: Normals');
          SetLength(Normal, Header.VertexCount);
          Stream.Read(Pointer(Normal)^, 12 * Header.VertexCount);
        end
        else
          SetLength(Normal, 0);

        stream.position := fix + parseheader.Size;

        // outputdebugstring(pchar('Color: ' + inttostr(high(Color))));
        // outputdebugstring(pchar('UVmaps: ' + inttostr(high(UVmaps))));
        // outputdebugstring(pchar('Face: ' + inttostr(high(Face))));
        // outputdebugstring(pchar('Vertex: ' + inttostr(high(Vertex))));
        // outputdebugstring(pchar('Normal: ' + inttostr(high(Normal))));

      end;
    end;
  end;
end;

procedure TDffLoader.ParseString(Stream: TStream; ParseHeader: TDFFHeader; Level, Parent: longint);
var
  Buf: PChar;
  PreString: string;
  I:   integer;
begin
  PreString := '';
  for I := 0 to Level do
    PreString := PreString + '      ';

  GetMem(Buf, ParseHeader.Size + 1);
  Buf[ParseHeader.Size] := #0;
  Stream.Read(Pointer(Buf)^, ParseHeader.Size);

  case Parent of

    rwTEXTURE:
    begin
      with Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].MaterialList.Material[Clump[High(Clump)].GeometryList.Geometry[Clump[High(Clump)].GeometryList.GeometryCount - 1].MaterialList.MaterialCount - 1].Texture do
      begin
        if GotName then
          Desc := Trim(Buf)
        else
          Name := Trim(Buf);
        GotName := True;
      end;
    end;

    rwFRAMELIST:
    begin
      Clump[High(Clump)].FrameList.Data.Frame[FrameUpTo].Name := Trim(Buf);
      Inc(FrameUpTo);
    end;
  end;

  FreeMem(Buf);
end;

procedure TDffLoader.ParseHeaders(Stream: TStream; ParseHeader: TDFFHeader; Level, Parent: longint);
var
  InHeader: TDFFHeader;
  MoreData: boolean;
  pre:      integer;
	i, j: integer;
	thisclump: integer;
	buffer: pchar;
begin
	MoreData := True;
	thisclump:= High(Clump);

  while MoreData do
  begin
    InHeader := GetNextHeader(Stream, Level, Parent);

	//    if length(Clump) = 1 then exit;

	if (InHeader.Tag = rwClump) then
    begin
      SetLength(Clump, Length(Clump) + 1);
      Level := 0;
    end;

    case InHeader.Tag of
      rwATOMIC:
      begin
        Inc(Clump[thisclump].AtomicCount);
        SetLength(Clump[thisclump].Atomic, Clump[thisclump].AtomicCount);
        FillChar(Clump[thisclump].Atomic[High(Clump[thisclump].Atomic)], SizeOf(TDFFAtomic), 0);
      end;
      rwGEOMETRY:
      begin
        Inc(Clump[thisclump].GeometryList.GeometryCount);
        SetLength(Clump[thisclump].GeometryList.Geometry, Clump[thisclump].GeometryList.GeometryCount);
        FillChar(Clump[thisclump].GeometryList.Geometry[High(Clump[thisclump].GeometryList.Geometry)], SizeOf(TDFFGeometry), 0);

      end;
      rwMATERIAL:
      begin
        Inc(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.MaterialCount);
        SetLength(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.Material, Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.MaterialCount);
        // read speca?

        //        showmessage('found material extension at ' + inttostr(stream.position));
      end;
			col3:
	  begin

				pre := stream.position;

				Clump[thisclump].col3:= TMemoryStream.create;
				Clump[thisclump].col3.Size:= 0;
				Clump[thisclump].col3.CopyFrom(Stream, inheader.size);

				stream.position := pre;

      end;

      rnmultitexturespeca:
      begin
        pre := stream.position;
        stream.seek(4, sofromcurrent); // skip 4 bytes
        stream.Read(

          Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.Material[
          Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.MaterialCount - 1
          ].Texture.speca

          , InHeader.Size - 4);
        stream.position := pre;
      end;
      rwMATERIALEFFECTS:
      begin

        pre := stream.position;
        stream.seek(4, sofromcurrent); // skip 4 bytes

        fillchar(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.Material[
          Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.MaterialCount - 1
          ].Texture.matplugin, inheader.Size, 0);

        Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.Material[
          Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.MaterialCount - 1
          ].Texture.matpluginsize := InHeader.Size;

        stream.Read(
          Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.Material[
          Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].MaterialList.MaterialCount - 1
          ].Texture.matplugin
          , InHeader.Size);

        stream.position := pre;
      end;

      rwCLUMP:
      begin

      end;

    end;

    case InHeader.Tag of
      rwTEXTURE,
      rwMATERIALLIST,
      rwMATERIAL,
      rwCLUMP,
      rwFRAMELIST,
      rwGEOMETRYLIST,
      rwGEOMETRY,
      rwATOMIC:
        ParseHeaders(Stream, InHeader, Level + 1, InHeader.Tag);
      rwMATERIALSPLIT:
        ParseMaterialSplit(Stream, InHeader, Parent);

      particles: begin
        pre := stream.position;

        setlength(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].pems, InHeader.Size div 48);

        if length(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].pems) > 0 then
          for i:= 0 to high(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].pems) do begin
            stream.read(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].pems[i].entrytype, 48);
            //showmessage(Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].pems[i].particlename);
          end;

        stream.position := pre;
      end;
      rwDATA:
      begin
				//        // outputdebugstring(pchar(inttostr(InHeader.Start)));
        try
          ParseData(Stream, InHeader, Parent);
        except
        end;
      end;
      rwEXTENSION:
        if (InHeader.Size > 0) then
          ParseHeaders(Stream, InHeader, Level + 1, Parent);
      rwFRAME,rwSTRING:
        ParseString(Stream, InHeader, Level + 1, Parent);
        //      rwAnimPlugin:

      nvcolors:
      begin

      if length(Clump[thisclump].GeometryList.Geometry) > 0 then begin

      with Clump[thisclump].GeometryList.Geometry[Clump[thisclump].GeometryList.GeometryCount - 1].Data do
      begin
          SetLength(NightColors, Header.VertexCount);
          stream.seek(4, sofromcurrent); // skip 4
          Stream.Read(Pointer(NightColors)^, 4 * Header.VertexCount);
      end;

      end;

      end;
      else
      begin
        //        showmessage(Self.filenint + #13 + inttostr(inheader.Tag) + #13 + ' @ ' + inttostr(stream.position) + ' size ' + inttostr(InHeader.Size));
        stream.seek(4, sofromcurrent);
        stream.seek(InHeader.Size, sofromcurrent);
      end;

    end;




      {
        $253F2F9: if (lvl>1) and (sec[lvl-1].ID=$03) and (sec[lvl-2].ID=$0F) then with Geometry[nGeometry] do begin // SA second vertex colors
        $253F2FE: begin // Frame
        $11E: begin // Bone
        $50E: begin // Bin Mesh PLG
        $510: if RWVer>=$36000 then begin // Native Data PLG (SA PS2, RW 3.5+)
      }

    Stream.Seek(InHeader.Back + InHeader.Size, soFromBeginning);

    if (Stream.Position >= (ParseHeader.Back + ParseHeader.Size)) or (InHeader.Tag = 0) then
      MoreData := False;

  end;
end;

function TDffLoader.GetNextHeader(Stream: TStream; Level, Parent: longint): TDFFHeader;
var
  OutHeader: TDFFHeader;
begin
  with OutHeader do
  begin
    Start := Stream.position;

    Stream.Read(Tag, 4);
    Stream.Read(Size, 4);
    Stream.Read(renderversion, 4); //(Data, 2);
    //    Stream.Read(Version, 2);
    Back := Stream.position;
  end;
  Result := OutHeader;
end;

procedure Tdffloader.glDraw(texture: Ttxdloader; sectexture: Ttxdloader; texreportonly: boolean; highlight: integer; nightcolors: boolean; plzdontinstance: boolean);
var
  J: longword;

procedure makeinstance(highlight: integer);
var
  I: longword;
begin
  dlid := glGenLists(1);
  glNewList(dlid, GL_COMPILE);

  if Clump <> nil then
	if (Clump[0].FrameList.Data.FrameCount > 0) then
	  for I := 0 to Clump[0].FrameList.Data.FrameCount - 1 do
		if (Clump[0].FrameList.Data.Frame[I].Parent = -1) then
					glDrawRecurse(0, I, texture, sectexture, True, false, highlight, nightcolors, plzdontinstance);

  glEndList;
end;

begin

  used:= true;

  {$IFDEF map_editor}

  if (DLID = 0) and (texreportonly = false) and (highlight <> hl_selected) then
  begin
		makeinstance(highlight);
	end;

	if ((highlight = hl_normal) or (highlight = hl_novertexl)) and (texreportonly = false) and (plzdontinstance = false) then
	begin

		if DLID <> 0 then
			glCallList(dlid);

	end
	else
	begin

		if Clump <> nil then
			if (Clump[0].FrameList.Data.FrameCount > 0) then
				for J := 0 to Clump[0].FrameList.Data.FrameCount - 1 do
		  if (Clump[0].FrameList.Data.Frame[J].Parent = -1) then
			glDrawRecurse(0, J, texture, sectexture, True, texreportonly, highlight, nightcolors, plzdontinstance);

  end;

  {$ENDIF}

  used:= false;

end;

procedure Tdffloader.glDrawRecurse(in_clump: longword; in_frame: longint; texture: Ttxdloader; sectexture: Ttxdloader; TheParent: boolean; texreportonly: boolean; highlight: integer; nightcolors: boolean; plzdontinstance: boolean);
var
  I:    integer;
  Gn, OnC: longint;
  N:    array[0..15] of single;
  UV, Alp: boolean;
  ttex: gluint;
  Normals: byte;
begin

{$IFDEF map_editor}

// filter out car lods.
if (lowercase(Clump[in_clump].FrameList.Data.Frame[in_frame].Name) <> '') then begin
  if pos('_dam', lowercase(Clump[in_clump].FrameList.Data.Frame[in_frame].Name)) > 0 then exit;
  if pos('_vlo', lowercase(Clump[in_clump].FrameList.Data.Frame[in_frame].Name)) > 0 then exit;
end;

  glPushMatrix;

  glColor4f(1.0, 1.0, 1.0, 1.0);

  Gn := -1;
  if (Clump[in_clump].AtomicCount > 0) then
    for I := 0 to Clump[in_clump].AtomicCount - 1 do
    begin
      if Clump[in_clump].Atomic[i].Data.FrameNum = longword(in_frame) then
        Gn := Clump[in_clump].Atomic[i].Data.GeometryNum;
    end;

  if wheelrenders = false then begin

    // multiply matrix if not root object
    glMultMatrixf(@Clump[in_clump].FrameList.Data.Frame[in_frame].matrix4);

    if ((Clump[in_clump].FrameList.Data.Frame[in_frame].Name = 'wheel') or (Clump[in_clump].FrameList.Data.Frame[in_frame].Name = 'wheel2'))
    and (Clump[in_clump].FrameList.Data.FrameCount > 5) // hack so we dont break modding wheels
    then exit;

    if (pos('wheel_', Clump[in_clump].FrameList.Data.Frame[in_frame].Name) > 0) and (Clump[in_clump].FrameList.Data.FrameCount > 5) and ((Clump[in_clump].FrameList.Data.Frame[in_frame].Name <> 'wheel_front') and (Clump[in_clump].FrameList.Data.Frame[in_frame].Name <> 'wheel_rear')) then
    begin

      // todo.. DON'T DO THIS ON BIKES!!!!!!!!!!!!!

      renderawheel(Clump[in_clump].FrameList.Data.Frame[in_frame].Name, texture, sectexture, plzdontinstance);
      glpopmatrix;
      exit;
    end;
  end else begin

  end;

  if (Gn < longint(Clump[in_clump].FrameList.Data.FrameCount)) and not (Gn = -1) then
  begin

    // draw all frames
    if True then
    begin

      // draw object in local coordinate system
      with Clump[in_clump].GeometryList.Geometry[Gn] do
      begin

        UV := Length(Data.UVmaps) > 0;
        for i := 0 to MaterialSplit.Header.SplitCount - 1 do
        begin

          //u_edit.GtaEditor.Memo1.Lines.add(inttostr(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Other1));
          //u_edit.GtaEditor.Memo1.Lines.add(inttostr(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Other3));

          if texreportonly = True then
		  begin
		  {$IFDEF map_editor}
//						if MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Name <> '' then
							gtaeditor.list_dfftextures.Lines.add(format('Material: %d split: %d Tex: %s', [ MaterialSplit.Split[i].MaterialIndex, i, MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Name ]) );
//						if MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Desc <> '' then
							gtaeditor.list_dfftextures.Lines.add(format('Material: %d split: %d Alp: %s', [ MaterialSplit.Split[i].MaterialIndex, i, MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Name ]) );
          {$ENDIF}
		  end
          else
          begin

            gldisable(GL_TEXTURE_2D);
            gldisable(GL_ALPHA_TEST);

            if MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Name <> '' then
            begin

              glenable(gl_texture_2d); // got texture!

              if MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Desc <> '' then
              begin
                // got alpha!
                glEnable(GL_BLEND);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                glenable(GL_ALPHA_TEST);
                glAlphaFunc(GL_GREATER, 0);
              end;
            end;

            if texture <> nil then
            begin
              glenable(GL_TEXTURE_2D);
              ttex := texture.findglid(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Name);

              if ttex = 0 then // haven't found it.. look for more.
                ttex := sectexture.findglid(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Texture.Name);

              glBindTexture(GL_TEXTURE_2D, ttex);
            end;

            if isprim(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color) or isterc(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color) or islightcolor(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color) or issec(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color)
            then begin

              if isprim(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color) = True then
                glcolor3ubv(@primcolor)
              else if issec(MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color) = True then
                glcolor3ubv(@seccolor)
              else
                glColor4f(1,1,1,1)

            end else
              glColor3ubv(@MaterialList.Material[MaterialSplit.Split[i].MaterialIndex].Data.Color);

            glEnableClientState(GL_VERTEX_ARRAY);
            glVertexPointer(3, GL_FLOAT, 0, @Data.Vertex[0]);

{
            if Normals <> 0 then
            begin
              glEnableClientState(GL_NORMAL_ARRAY);
              glNormalPointer(GL_FLOAT, 0, @Data.Normal[0]);
            end else
              glDisableClientState(GL_NORMAL_ARRAY);
}
            if length(Data.UVmaps) > 0 then
            begin
              glEnableClientState(GL_TEXTURE_COORD_ARRAY);
              glTexCoordPointer(2, GL_FLOAT, 0, @Data.UVmaps[0][0]);
            end
            else
              glDisableClientState(GL_TEXTURE_COORD_ARRAY);

			if (highlight = hl_normal) then
			begin
              if length(Data.VertexColors) > 0 then
              begin
                glEnableClientState(GL_COLOR_ARRAY);

                if (length(Data.NightColors) <> length(Data.VertexColors)) then
                  nightcolors:= false; // precaution.

                if nightcolors = false then
                  glColorPointer(4, GL_UNSIGNED_BYTE, 0, @Data.VertexColors[0])
                else
                  glColorPointer(4, GL_UNSIGNED_BYTE, 0, @Data.NightColors[0]);

              end
              else
                glDisableClientState(GL_COLOR_ARRAY);
			end
            else
            begin
              glDisableClientState(GL_COLOR_ARRAY);

			  if highlight = hl_selected then
                glColor4f(1.0 - (sin(application.Tag * 0.1) * 0.1)  , 0.0, 0.0, 1.0);

              if highlight = hl_novertexl then
                glColor4f(1.0, 1.0, 1.0, 1.0);
            end;



            if (MaterialSplit.Header.TriagleFormat = 0) then
              glDrawElements(GL_TRIANGLES, High(MaterialSplit.Split[i].Index) + 1, GL_UNSIGNED_INT, @MaterialSplit.Split[i].Index[0])
            else
              glDrawElements(GL_TRIANGLE_STRIP, High(MaterialSplit.Split[i].Index) + 1, GL_UNSIGNED_INT, @MaterialSplit.Split[i].Index[0]);

          end;
        end;

        // experimental - particle emitters

        if length(Clump[in_clump].GeometryList.Geometry[Gn].pems) > 0 then

        for i:= 0 to high(Clump[in_clump].GeometryList.Geometry[Gn].pems) do begin

          if (Clump[in_clump].GeometryList.Geometry[Gn].pems[i].entrytype = 1) then begin
            {
            glDisable(GL_DEPTH_TEST);
            gldisable(gl_texture_2d);
            glpointsize(20);
            glcolor4f(0, 0.5, 0.5, 1);

            glBegin(GL_POINTS);
            glvertex3fv(@Clump[in_clump].GeometryList.Geometry[Gn].pems[i].Position);
            glend;
            glEnable(GL_DEPTH_TEST);
            }
          end;
        end;

      end;

    end;

  end;

  // Draw all frames that has the current frame as parent..
  if (Clump[in_clump].FrameList.Data.FrameCount > 0) then
    for Onc := 0 to Clump[in_clump].FrameList.Data.FrameCount - 1 do
    begin
      if (Clump[in_clump].FrameList.Data.Frame[Onc].Parent = in_frame) then
      begin
        I := Length(Clump[in_clump].FrameList.Data.Frame[Onc].Name);
        if (I >= 3) then
        begin
          if (Clump[in_clump].FrameList.Data.Frame[Onc].Name[I - 2] = '_') and ((Clump[in_clump].FrameList.Data.Frame[Onc].Name[I - 1] = 'L') or (Clump[in_clump].FrameList.Data.Frame[Onc].Name[I - 1] = 'l')) then
          begin
            if (StrToIntDef(Clump[in_clump].FrameList.Data.Frame[Onc].Name[I], -1) <= 0) then
							glDrawRecurse(in_clump, OnC, texture, sectexture, True, texreportonly, highlight, nightcolors, plzdontinstance);
					end
          else if not ((Clump[in_clump].FrameList.Data.Frame[Onc].Name[1] = 'C') and (Clump[in_clump].FrameList.Data.Frame[Onc].Name[2] = 'o') and (Clump[in_clump].FrameList.Data.Frame[Onc].Name[3] = 'l')) then
            glDrawRecurse(in_clump, OnC, texture, sectexture, False, texreportonly, highlight, nightcolors, plzdontinstance);
        end
        else
          glDrawRecurse(in_clump, OnC, texture, sectexture, False, texreportonly, highlight, nightcolors, plzdontinstance);
      end;
    end;

  // now pop the matrix, so we don't affect siblings
  glPopMatrix;
{$ENDIF}
end;


procedure Tdffloader.Unload;
begin
  DropDL();
  ResetClump;
end;

procedure TDffLoader.DropDL;
begin

  if DLID <> 0 then
    glDeleteLists(DLID, 1);

end;

procedure TDffLoader.renderawheel(parent: string; texture: Ttxdloader; sectexture: Ttxdloader; plzdontinstance: boolean);
var
  i, y: integer;
  wheelparent: integer;
  wheelmodel: integer;
  wantedmodel: string;
  fi:   boolean;
begin
{$IFDEF map_editor}

// the IDE vehicle tire size or something?
//  glTranslatef(0, 0, wheelzchange / 2); // -> looks bad (not really)

  if pos('dummy', parent) = 0 then
    exit; // not a wheel dummy

  // workaround for san andreas tractor
{
  if carclass = 531 then
    if (pos('b', parent) <> 0) then
      glscalef(2, 2, 2);
  // and combine harvester
  if carclass = 532 then
    if (pos('m_', parent) <> 0) then
      glscalef(2, 2, 2);
}
{
  if (pos('_lf_', parent) <> 0) or (pos('_rf_', parent) <> 0) then
  begin
    glrotatef(180 + wnd_info.fronttireheading.position, 0, 0, 1); // i think that this the way game renders wheels, it doesn't work correctly for monster truck wheel grips
  end;
}
  if pos('wheel_l', parent) <> 0 then
  begin // left wheels should be rotated / mirrored
    glrotatef(180, 0, 0, 1); // i think that this the way game renders wheels, it doesn't work correctly for monster truck wheel grips
//    if (animate = True) or (showanimate = True) then
//      glrotatef(gettickcount div 5, 1, 0, 0); // rotate forward
  end;
//  else
//  if (animate = True) or (showanimate = True) then
//    glrotatef(gettickcount div 5, -1, 0, 0); // rotate into other direction


  if (pos('steer', parent) = 0) then
  begin // check for steeringwheel dummy in sa cars too, some ported cars may still have it...

    wheelrenders := True;

    // the wheel to render is object that its parent is 'wheel_rf_dummy'

    for i := 0 to clump[0].FrameList.Data.FrameCount - 1 do
      for y := 0 to clump[0].FrameList.Data.FrameCount - 1 do
        if lowercase(clump[0].FrameList.Data.Frame[i].Name) = 'wheel_rf_dummy' then
          if clump[0].FrameList.Data.Frame[y].Parent = i then
          begin
              gldrawrecurse(0, i, texture, sectexture, True, false, hl_normal, false, plzdontinstance);
              break; // we rendered it already, don't render yosemite / feltzer odd wheels
          end;

    wheelrenders := False;

  end;

{$ENDIF}
end;

end.

