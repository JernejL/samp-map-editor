unit FileTypes;

// file types used by GTA Map Viewer
// © 2005 by Steve M.

interface

uses
  Windows, OpenGL12, Geometry, Misc, RequiredTypes, TextureStuff;

const
  VERT_SCALE = 1/128;
  VERT_SCALE_CAR = 1/1024;
  UV_SCALE   = 1/4096;
  NORM_SCALE = 1/8192;

type

  TArchive = class
    private
    public
      ArchiveFile: PArchiveFile;
      numStreamFiles, numLoadedStreamFiles: cardinal;
      Entries: array[TFileExt] of PStreamFile;
      function AttachArchive(fname: string): PArchiveFile;
      function AddExternal(const fname: string): PStreamFile;
      function Find(const name: string): PStreamFile; overload;
      function Find(const name: string; const ext: TFileExt): PStreamFile; overload;
      constructor Create(fname: string);
      destructor Destroy; override;
  end;

  //////////////////////////////////////////////////////////////////////////////

  PTexture = ^TTexture;
  TTexture = record
    Name: string;
    HasAlpha: boolean;
    ID: integer;
  end;

  PTexDict = ^TTexDict;
  TTexDict = class(TStreamFileClass)
    private
    public
      Texture: array of TTexture;
      function FindTexture(const name: string): PTexture;
      //procedure LoadFromFile(FileName: string); override;
      function LoadFromStream(var f: file; offset, size: Cardinal; LoadFlag: boolean = false): boolean; override;
      destructor Destroy; override;
    end;

  //////////////////////////////////////////////////////////////////////////////

  {PVertex = ^TVertex;
  TVertex = record
    p, p_,
    n, n_   : TVector3f;
    c1, c2  : TVector4f;
    //numBones: 0..4;
    bones   : TVector4b;
    weights : TVector4f;
  end;}
  {TFace = record
    b, a, d, c: Word;
  end;}
  TVector2F = array[0..1] of single;

  TMaterial = record
    Color: TVector4F; //TVector4B;
    Settings: TVector3F;
    TexName: string;
    Texture: PTexture;
  end;

  TMeshSplit = record
    MatID, Count: integer;
    index: array of integer;
    ps2_vertex: array of TVector4F;
    ps2_uv: array of TVector2F;
  end;

  PGeometry = ^TGeometry;
  TGeometry = record
    Index,
    TriStrip: Integer;
    IsPS2, HasNormals, HasUVs, HasMultiUVs, HasColors, HasSecondColors, HasSkin: Boolean;
    Vertex,
    Normal  : array of TVector3F;
    UV      : array of TVector2F;
    Color,
    Color2  : array of TVector4B;
    //face  : array of TFace;
    Material: array of TMaterial;
    Split   : array of TMeshSplit;
  end;

  PFrame = ^TFrame;
  TFrame = packed record
    Index   : Integer;
    Name    : string;     // Frame Name
    Matrix,               // Relative Transformation Matrix
    LTM     : TMatrix4f;  // Local Transformation Matrix (absolute)
    Pos0    : TVector3f;  // Translation Part of LTM in Base Pose
    Parent  : PFrame;     // Parent Frame in Hierarchy
    Geometry: PGeometry;  // Accompanying Mesh (if available)
    //Anim  : PAnimObject;
    BoneID  : Integer;
    BoneNo  : Smallint;
    Damaged : boolean;
  end;

  {PBone = ^TBone;
  TBone = packed record
    State: integer;
    Frame: PFrame;
  end;}

  PDFFClump = ^TDFFClump;
  TDFFClump = class(TStreamFileClass)
    private
    public
      HasBones: boolean;
      Geometry: array of TGeometry;
      Frame: array of TFrame;
      Bone: array of PFrame;
      procedure SetBasePose;
      procedure Draw(do_opaque, do_transp, do_texture, UseNightColors: boolean);
      //procedure AttachTXD(txd: TTexDict; var a: boolean; var error: string);
      procedure AttachTXD(sf: PStreamFile; out a: boolean);
      //procedure CalcVertexColors(BoneNo: byte);
      //procedure LoadFromFile(FileName: string); override;
      function LoadFromStream(var f: file; offset, size: Cardinal; LoadFlag: boolean = false): boolean; override;
      destructor Destroy; override;
  end;

  //////////////////////////////////////////////////////////////////////////////

  (*
  PAnimFrame = ^TAnimFrame;
  TAnimFrame = record
    HasPos: boolean;
    TimeKey: single;
    Pos: TVector3f;
    Rot: TQuaternion;
  end;

  PAnimObject = ^TAnimObject;
  TAnimObject = record
    Name: string;
    Enabled: boolean;
    ObjFrame, BoneID: integer;
    NumFrames, CurrentFrame: cardinal;
    Duration: single;
    AnimFrame: array of TAnimFrame;
  end;

  PAnimation = ^TAnimation;
  TAnimation = record
    Name: string;
    TotalDuration: single;
    AnimObject: array of TAnimObject;
  end;

  TtmpFrameMat = record
    used: boolean;
    mat: TMatrix4f;
  end;

  TIFPAnim = class
    private
    public
      Ready: boolean;
      DFF: PDFFClump;
      Playback: 0..2;
      PlayFWD: boolean;
      Speed, Time: single;
      CurrentAnim: integer;
      Animation: array of TAnimation;
      tmpFrameMat: array of TtmpFrameMat;
      procedure Clear;
      procedure LoadFromFile(FileName: string; ADFFClump: PDFFClump);
      procedure SwitchAnim(Ind: integer);
      procedure UpdateAnim(ForceUpdate: boolean);
      destructor Destroy; override;
  end;
  *)

  //////////////////////////////////////////////////////////////////////////////

  //function getWeight(Vert: PVertex; Bone: byte): single;


implementation

const
  X = 0; Y = 1; Z = 2; W = 3;


////////////////////////////////////////////////////////////////////////////////
// General functions                                                              //
////////////////////////////////////////////////////////////////////////////////

function GetFaceNormal(P1, P2, P3: TVector3f): TVector3f;
// calculate a face's normal
var a, b: TVector3f;
begin
  a:=VectorAffineSubtract(P2, P1);
  b:=VectorAffineSubtract(P3, P1);
  result:=VectorCrossProduct(a, b);
  VectorNormalize(result);
end;

{function getWeight(Vert: PVertex; Bone: byte): single;
// get the vertex weight for the given bone
var
  i: integer;
  stop: boolean;
begin
  i:=0;
  stop:=false;
  result:=0;
  repeat
    if Vert.bones[i]=Bone then begin
      result:=Vert.weights[i];
      stop:=true;
    end;
    if Vert.weights[i]=0 then stop:=true;
    inc(i);
  until (i>=4) or stop;
end; }

{function QuaternionToMatrix2(Q: TQuaternion): TMatrix4f;
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2: single;
  m: TMatrix4f;
begin
  x2 := 2*q.Vector[X];
  y2 := 2*q.Vector[Y];
  z2 := 2*q.Vector[Z];
  xx := q.Vector[X] * x2; xy := q.Vector[X] * y2; xz := q.Vector[X] * z2;
  yy := q.Vector[Y] * y2; yz := q.Vector[Y] * z2; zz := q.Vector[Z] * z2;
  wx := q.Vector[W] * x2; wy := q.Vector[W] * y2; wz := q.Vector[W] * z2;

  m[0][0] := 1.0 - (yy + zz); m[0][1] := xy - wz;         m[0][2] := xz + wy;         m[0][3] := 0.0;
  m[1][0] := xy + wz;         m[1][1] := 1.0 - (xx + zz); m[1][2] := yz - wx;         m[1][3] := 0.0;
  m[2][0] := xz - wy;         m[2][1] := yz + wx;         m[2][2] := 1.0 - (xx + yy); m[2][3] := 0.0;
  m[3][0] := 0;               m[3][1] := 0;               m[3][2] := 0;               m[3][3] := 1;

  Result := m;
end;}

function VectorTransform2(V: TVector3f; M: TMatrix): TVector3f;
// transforms an affine vector by multiplying it with a (homogeneous) matrix
var
  TV: TVector3f;
  //TM: TMatrix;
begin
  {if Form1.Test1.Checked then begin
    M:=MatrixMultiply(CreateRotationMatrixZ(sin(-pi/2), cos(-pi/2)), M);
    M:=MatrixMultiply(CreateRotationMatrixY(sin(-pi/2), cos(-pi/2)), M);
  end;}
  //M:=MatrixMultiply(CreateRotationMatrix(MakeAffineVector([1,0,0]),90), M);


  TV[X] := V[X] * M[X, X] + V[Y] * M[Y, X] + V[Z] * M[Z, X] + M[W, X];
  TV[Y] := V[X] * M[X, Y] + V[Y] * M[Y, Y] + V[Z] * M[Z, Y] + M[W, Y];
  TV[Z] := V[X] * M[X, Z] + V[Y] * M[Y, Z] + V[Z] * M[Z, Z] + M[W, Z];

  {TM:=IdentityMatrix;
  Move(V, TM[3], 12);
  TM:=MatrixMultiply(TM, M);
  Move(TM[3], TV, 12);}

  Result := TV;
end;

function MatrixTranslationOnly(Mat: TMatrix4f): TMatrix4f;
begin
  result:=IdentityMatrix;
  move(Mat[3], result[3], 12);
end;

function MatrixRotationOnly(Mat: TMatrix4f): TMatrix4f;
begin
  result:=IdentityMatrix;
  move(Mat[0], result[0], 12);
  move(Mat[1], result[0], 12);
  move(Mat[2], result[0], 12);
end;

function QuaternionSlerp2(QStart, QEnd: TQuaternion; t: single): TQuaternion;
var
  omega, cosom, sinom, scale0, scale1: Double;
begin;
    // calc cosine
    cosom:=VectorDotProduct(QStart.Vector, QEnd.Vector);

    // adjust signs (if necessary)
    if cosom < 0.0 then begin
      cosom:=-cosom;
      VectorNegate(QEnd.Vector);
    end;

    // calculate coefficients
    if 1-cosom > 1e-12 then begin
      // standard case (slerp)
      omega := arccos(cosom);
      sinom := sin(omega);
      scale0 := sin((1 - t) * omega) / sinom;
      scale1 := sin(t * omega) / sinom;
    end else begin
      // lerp
      scale0 := 1 - t;
      scale1 := t;
    end;

    result.Vector:=VectorCombine(QStart.Vector, QEnd.Vector, scale0, scale1);
end;

function GetRWVersion(ver: cardinal): cardinal;
var b: byte;
begin
  b:=ver shr 24;
  result:=(3 + b shr 6) shl 16
        + ((b shr 2) and $0F) shl 12
        + (b and $03) shl 8
        + byte(ver shr 16);
end;


////////////////////////////////////////////////////////////////////////////////
// TDFFClump - dff loading and processing functions                           //
////////////////////////////////////////////////////////////////////////////////

procedure TDFFClump.SetBasePose;
var i: integer;
begin
  for i:=0 to length(Frame)-1 do with Frame[i] do begin
    if not Assigned(Parent) then
      LTM:=Matrix
    else
      // Calculate Local Transformation Matrix:
      LTM:=MatrixMultiply(Matrix, Parent.LTM);

    {if Assigned(Geometry) and Geometry.HasSkin then with Geometry^ do // Restore Mesh
      for j:=0 to length(Vertex)-1 do begin
        Vertex[j].p:=Vertex[j].p_;
        if HasNormals then Vertex[j].n:=Vertex[j].n_;
      end;}
  end;
end;

procedure TDFFClump.Draw(do_opaque, do_transp, do_texture, UseNightColors: boolean);
var
  i, j, f: integer;
begin
  //Draw Geometry Polys
  if true then begin

    for f:=0 to length(Frame)-1 do if not Frame[f].Damaged and Assigned(Frame[f].Geometry) then begin
      glPushMatrix;
        glMultMatrixf(@Frame[f].LTM[0]);
        glColor3f(1, 1, 1);

        with Frame[f].Geometry^ do begin

          if not IsPS2 then begin

            {$REGION 'PC meshes'}

            glEnableClientState(GL_VERTEX_ARRAY);
            glVertexPointer(3, GL_FLOAT, 0, @Vertex[0]);

            if HasUVs and do_texture then begin
              glEnableClientState(GL_TEXTURE_COORD_ARRAY);
              glTexCoordPointer(2, GL_FLOAT, 0, @UV[0]);
            end else glDisableClientState(GL_TEXTURE_COORD_ARRAY);

            if HasNormals then begin
              glEnableClientState(GL_NORMAL_ARRAY);
              glNormalPointer(GL_FLOAT, 0, @Normal[0]);
            end else glDisableClientState(GL_NORMAL_ARRAY);

            if HasColors then begin
              glEnableClientState(GL_COLOR_ARRAY);
              if HasSecondColors and UseNightColors then
                glColorPointer(4, GL_UNSIGNED_BYTE, 0, @Color2[0])
              else
                glColorPointer(4, GL_UNSIGNED_BYTE, 0, @Color[0]);
            end else glDisableClientState(GL_COLOR_ARRAY);

            if do_opaque then begin
              // draw non-alpha/untextured splits
              glDisable(GL_BLEND);
              for i:=0 to length(Split)-1 do
                with Material[Split[i].MatID] do if not do_texture or not (Assigned(Texture) and Texture.HasAlpha) then begin
                  //glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @Color[0]);
                  if do_texture and Assigned(Texture) then
                    glBindTexture(GL_TEXTURE_2D, Texture.ID)
                  else
                    glBindTexture(GL_TEXTURE_2D, 0);
                  glDrawElements(GL_TRIANGLES + TriStrip, length(Split[i].index), GL_UNSIGNED_INT, @Split[i].index[0]);
                end;
            end;

            if do_transp and do_texture then begin
              // draw alpha splits
              glEnable(GL_BLEND);
              for i:=0 to length(Split)-1 do
                with Material[Split[i].MatID] do if Assigned(Texture) and Texture.HasAlpha then begin
                  //glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @Color[0]);
                  //glMaterialfv(GL_FRONT, GL_DIFFUSE, @Color[0]);
                  glBindTexture(GL_TEXTURE_2D, Texture.ID);
                  glDrawElements(GL_TRIANGLES + TriStrip, length(Split[i].index), GL_UNSIGNED_INT, @Split[i].index[0]);
                end;
            end;

            {$ENDREGION}

          end else begin

            {$REGION 'PS2 meshes'}

            if do_opaque  or do_transp  then begin
              // draw non-alpha/untextured splits
              glDisable(GL_BLEND);
              for i:=0 to length(Split)-1 do
                with Split[i], Material[Split[i].MatID] do if true {not (Assigned(Texture) and Texture.HasAlpha)} then begin
                  if do_texture and Assigned(Texture) then
                    glBindTexture(GL_TEXTURE_2D, Texture.ID)
                  else
                    glBindTexture(GL_TEXTURE_2D, 0);

                  glColor3F(0.9, 0.9, 0.9);
                  {glPolygonMode(GL_FRONT, GL_FILL);
                  glPolygonMode(GL_BACK, GL_LINE);}

                  glEnableClientState(GL_VERTEX_ARRAY);
                  glVertexPointer(3, GL_FLOAT, 16, @ps2_vertex[0]);
                  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                  glTexCoordPointer(2, GL_FLOAT, 0, @ps2_uv[0]);

                  glDisableClientState(GL_NORMAL_ARRAY);
                  glDisableClientState(GL_COLOR_ARRAY);

                  glBegin(GL_TRIANGLE_STRIP);
                    for j:=0 to length(ps2_vertex)-1 do begin
                      if (ps2_vertex[j][3]<>0) and (ps2_vertex[j-1][3]=0) and (ps2_vertex[j+1][3]<>0) then begin
                        glEnd; glBegin(GL_TRIANGLE_STRIP);
                        if odd(j) then glArrayElement(j);
                      end;
                      glArrayElement(j);
                    end;
                  glEnd;
                end;
            end;

            {if do_transp then begin
              // draw alpha splits
              glEnable(GL_BLEND);
              for i:=0 to length(Split)-1 do
                with Split[i], Material[Split[i].MatID] do if Assigned(Texture) and Texture.HasAlpha then begin
                  glBindTexture(GL_TEXTURE_2D, Texture.ID);
                  glColor3F(0.9, 0.9, 0.9);

                  glEnableClientState(GL_VERTEX_ARRAY);
                  glVertexPointer(3, GL_FLOAT, 16, @ps2_vertex[0]);
                  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                  glTexCoordPointer(2, GL_FLOAT, 0, @ps2_uv[0]);

                  glDisableClientState(GL_NORMAL_ARRAY);
                  glDisableClientState(GL_COLOR_ARRAY);

                  glBegin(GL_TRIANGLE_STRIP);
                    for j:=0 to length(ps2_vertex)-1 do begin
                      if (ps2_vertex[j][3]<>0) and (ps2_vertex[j-1][3]=0) and (ps2_vertex[j+1][3]<>0) then begin
                        glEnd; glBegin(GL_TRIANGLE_STRIP);
                        if odd(j) then glArrayElement(j);
                      end;
                      glArrayElement(j);
                    end;
                  glEnd;
                end;
            end;}

            {
            // wireframe
            glDisable(GL_TEXTURE_2D);
            glColor3F(0.5, 0.5, 0.5);
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glEnable(GL_POLYGON_OFFSET_LINE);
            glPolygonOffset(-1, -1);
            for i:=0 to length(Split)-1 do with Split[i], Material[Split[i].MatID] do begin
              glBegin(GL_TRIANGLES);
                for j:=2 to length(ps2_vertex)-1 do if (ps2_vertex[j][3]=0) then begin
                  //glTexCoord2fv(@ps2_uv[j-2]);
                  glVertex3fv  (@ps2_vertex[j-2]);
                  //glTexCoord2fv(@ps2_uv[j-1]);
                  glVertex3fv  (@ps2_vertex[j-1]);
                  //glTexCoord2fv(@ps2_uv[j]);
                  glVertex3fv  (@ps2_vertex[j]);
                end;
              glEnd;
            end;
            glDisable(GL_POLYGON_OFFSET_LINE);
            glEnable(GL_TEXTURE_2D);
            }

            {$ENDREGION}

          end;
        end;

      glPopMatrix;
    end;
    //glEnable(GL_DEPTH_TEST);
  end;

end; //Draw


destructor TDFFClump.Destroy;
var i, j: integer;
begin
  HasBones:=false;
  for i:=0 to length(Geometry)-1 do begin
    setLength(Geometry[i].vertex, 0);
    setLength(Geometry[i].Normal, 0);
    setLength(Geometry[i].UV, 0);
    setLength(Geometry[i].Color, 0);
    for j:=0 to length(Geometry[i].Split)-1 do begin
      setLength(Geometry[i].Split[j].index, 0);
      setLength(Geometry[i].Split[j].ps2_vertex, 0);
    end;
    //setLength(Geometry[i].face, 0);
    setLength(Geometry[i].Split, 0);
    setLength(Geometry[i].Material, 0);
  end;
  setlength(Geometry, 0);
  for i:=0 to length(Frame)-1 do Frame[i].Name:='';
  setlength(Frame, 0);
  setlength(Bone, 0);
  inherited Destroy;
end;

procedure TDFFClump.AttachTXD(sf: PStreamFile; out a: boolean);
var
  i, j: integer;
  a_, nf: boolean;
  error: string;
begin
  if not Assigned(sf) or (sf.ext<>feTXD) or not sf.isLoaded then exit;

  a:=false;
  nf:=false;
  error:='';

  for i:=0 to length(Geometry)-1 do
    for j:=0 to length(Geometry[i].Material)-1 do
      with Geometry[i].Material[j] do
        if not Assigned(Texture) and (TexName<>'') then begin
          Texture:=(sf.Data as TTexDict).FindTexture(TexName);
          if Assigned(Texture) then begin
            a := a or Texture.HasAlpha;
            //OutputDebugString(PChar('Found: '+Texture.name));
          end else begin
            nf:=true; // not found
            error:=error+' "'+TexName+'"';
          end;
        end;

  if nf then begin
    // look for missing textures in parent txd (if available)

    if OPT.Verbose then
      if Assigned(sf.Parent) then
        OutputDebugString(PChar('> '+sf.Name+' searches in '+sf.Parent.Name+' for missing textures:'+error))
      else
        OutputDebugString(PChar('> not found in '+sf.Name+':'+error));

    AttachTXD(sf.Parent, a_);
    a := a or a_;
  end;
end;

function TDFFClump.LoadFromStream(var f: file; offset, size: Cardinal; LoadFlag: boolean = false): boolean;
const MAX_LEVEL=7;
type
  TCharString = array[0..255] of char;
  TSecHeader = record
    ID, Size, Ver: cardinal;
  end;
  TDFFFrame = packed record
    RotMat: TMatrix3f;
    Pos: TVector3f;
    Parent: integer;
    Unk: cardinal;
  end;
  TDFFBone = record
    ID, No, BoneType: integer;
  end;
  TDFFGeometryHeader = packed record
    Flags: word;
    numUV, unk: byte;
    numFace, numVert, numFrame: integer;
  end;
var
  Sec: array[0..MAX_LEVEL-1] of TSecHeader;
  NextPos: array[0..MAX_LEVEL-1] of cardinal;
  FileVer, RWVer: cardinal;
  error: boolean;

  nFrame, nGeometry, nMaterial, nBone: integer;
  dffframe: TDFFFrame;
  dffgeometryheader: TDFFGeometryHeader;
  dffbone: packed array of TDFFBone;
  comp_vert: array [0..3] of smallint;

  procedure ReadSec(lvl: integer);
  var
    //sec2: TSecHeader;
    HasChildSecs: boolean;
    i, j, k, l: integer;
    s: TCharString;
    col: TVector4B;
    //skinheader: TVector4b;
  begin
    if lvl>=MAX_LEVEL then begin
      //error:=true;
      //OutputDebugString('WARNING - sub sec level too high');
      Seek(f, NextPos[lvl-1]);
      exit;
    end;
    if error then exit;

    BlockRead(f, sec[lvl], 12);
    if (lvl=0) and (FileVer=0) then begin
      FileVer:=sec[0].ver;
      RWVer:=getRWVersion(FileVer);
    end else if Sec[lvl].Ver<>FileVer then begin
      error:=true;
      OutputDebugString(PChar('ERROR - invalid section @ '+inttostr(FilePos(f)-12)));
      exit;
    end;

    // Backup offset of next sibling
    NextPos[lvl]:=cardinal(FilePos(f))+sec[lvl].size;

    // Check for a valid child section
    {if (FilePos(f)<=Offset+Size-12) and (sec[lvl].Size>=12) then begin
      BlockRead(f, sec2, 12);
      Seek(f, FilePos(f)-12);
      HasChildSecs:=(sec2.Ver=FileVer);
    end else HasChildSecs:=false;}
    HasChildSecs := (sec[lvl].ID in [$10, $0E, $1A, $0F, $08, $07, $06, $14])
                 or ((sec[lvl].ID=$03) and (lvl>0) and (sec[lvl-1].ID in [$0E, $0F]));

    // Bugfix: Increment current frame ID for each Frame List/Extension section,
    // since the frame name could be missing
    if (sec[lvl].ID=$03) and (lvl>0) and (sec[lvl-1].ID=$0E) then inc(nFrame);

    if not HasChildSecs and (sec[lvl].Size>0) and ((Cardinal(FilePos(f))+sec[lvl].Size)<=Offset+Size) then begin
      // parse section data
      // ------------------

      case sec[lvl].ID of
        $00: error:=true;
        $01: if lvl>0 then case sec[lvl-1].ID of // Struct
               $07: begin // Material
                      inc(nMaterial);
                      BlockRead(f, i, 4); // unknown
                      //BlockRead(f, Geometry[nGeometry].Material[nMaterial].Color, 4); // color
                      BlockRead(f, col, 4); // color
                      Geometry[nGeometry].Material[nMaterial].Color:=MakeVector([col[0]/255, col[1]/255, col[2]/255, col[3]/255]);
                      BlockRead(f, i, 4); // unknown
                      BlockRead(f, i, 4); // texture count (1)
                      BlockRead(f, Geometry[nGeometry].Material[nMaterial].Settings, 12); // material settings
                      Geometry[nGeometry].Material[nMaterial].TexName:='';
                      Geometry[nGeometry].Material[nMaterial].Texture:=nil;
                    end;
               $08: begin // Material List
                      BlockRead(f, i, 4);
                      nMaterial:=-1;
                      SetLength(Geometry[nGeometry].Material, i);
                    end;
               $0E: begin // Frame List
                      BlockRead(f, i, 4); // Frame Count
                      setLength(Frame, i);
                      nFrame:=-1;
                      nBone:=0;

                      for j:=0 to i-1 do with Frame[j] do begin
                        BlockRead(f, dffframe, 56);
                        //fillchar(Matrix, 48, 0);
                        Matrix:=IdentityMatrix;

                        if j>0 then begin //bugfix: identity matrix for wrong exported first frame
                          move(dffframe.RotMat[0], Matrix[0], 12);
                          move(dffframe.RotMat[1], Matrix[1], 12);
                          move(dffframe.RotMat[2], Matrix[2], 12);
                          move(dffframe.Pos,       Matrix[3], 12);
                          //Matrix[3][3]:=1;
                        end;

                        Index:=j;
                        BoneNo:=-1;

                        if dffframe.Parent<0 then begin
                          Parent:=nil;
                          LTM:=Matrix;
                        end else begin
                          Parent:=@Frame[dffframe.Parent];
                          LTM:=MatrixMultiply(Matrix, Parent.LTM);
                        end;
                        Move(LTM[3], Pos0, 12);
                      end;
                    end;
               $0F: begin // Geometry
                      BlockRead(f, dffgeometryheader, 16);
                      inc(nGeometry);

                      with Geometry[nGeometry], dffgeometryheader do begin
                        Index        := nGeometry;
                        HasNormals   := (Flags and 16)<>0;
                        HasColors    := (Flags and 8)<>0;
                        HasMultiUVs := (Flags and 128)<>0;
                        HasUVs       := ((Flags and 4)<>0) or HasMultiUVs;
                        //TriStrip   := (Flags and 1)<>0;
                        IsPS2:=false;

                        setLength(color,  0);
                        setLength(uv,     0);
                        //setLength(face,   0);
                        setLength(vertex, 0);
                        setLength(normal, 0);

                        if sec[lvl].Size < ( 24 + 12 * ord(RWVer<$34000) + 8 * numface + ( ord(HasColors)*4 + ord(HasUVs)*8 + 12 + ord(HasNormals)*12 ) * numvert) then begin
                          //OutputDebugString('> Geometry Section too small!');
                          IsPS2:=(unk=$FF)
                        end else begin

                          // Scene colors only for RW versions before 3.4
                          if RWVer<$34000 then Seek(f, FilePos(f)+12);

                          // Read vertex colors
                          if HasColors then begin
                            setLength(color, numVert);
                            BlockRead(f, Pointer(color)^, 4*numVert);
                          end;

                          // Read UV coords
                          if HasUVs then begin
                            SetLength(uv, numVert);
                            BlockRead(f, Pointer(UV)^, 8*numVert);
                            if HasMultiUVs and (numUV>1) then Seek(f, FilePos(f)+8*numVert*(numUV-1));
                          end;

                          // Read faces
                          //setLength(face, numFace);
                          //BlockRead(f, Pointer(face)^, 8*numFace);
                          Seek(f, FilePos(f)+numFace*8);

                          // Skip misc stuff
                          Seek(f, FilePos(f)+24);

                          // Read vertices
                          setLength(vertex, numVert);
                          BlockRead(f, Pointer(vertex)^, 12*numVert);

                          // Read normals
                          if HasNormals then begin
                            setLength(normal, numVert);
                            BlockRead(f, Pointer(normal)^, 12*numVert);
                          end;

                        end; // else
                      end; // with 

                    end;

               $14: begin //Atomic
                      BlockRead(f, i, 4); // Frame Index
                      BlockRead(f, j, 4); // Geometry Index
                      Frame[i].Geometry:=@Geometry[j];
                    end;
               $1A: begin // Geometry List
                      BlockRead(f, i, 4);
                      nGeometry:=-1;
                      setlength(Geometry, i);
                    end;
             end;
        $02: if lvl>0 then case sec[lvl-1].ID of // String
               $06: begin // Texture
                      fillchar(s, 256, #00);
                      BlockRead(f, s, sec[lvl].Size);
                      if Geometry[nGeometry].Material[nMaterial].TexName='' then
                        Geometry[nGeometry].Material[nMaterial].TexName:=trim(s);
                    end;
               end;
        $253F2F9: if (lvl>1) and (sec[lvl-1].ID=$03) and (sec[lvl-2].ID=$0F) then with Geometry[nGeometry] do begin // SA second vertex colors
               setLength(color2, length(Vertex));
               Seek(f, filepos(f)+4);
               BlockRead(f, Pointer(color2)^, 4*length(Vertex));
               HasSecondColors:=true;
             end;
        $253F2FE: begin // Frame
               fillchar(s, 256, #00);
               BlockRead(f, s, sec[lvl].Size);
               Frame[nFrame].Name := trim(s);
               Frame[nFrame].Damaged := LoadFlag and ((pos2('_dam', Frame[nFrame].Name)>0) or (pos2('_vlo', Frame[nFrame].Name)>0)) or (pos2('_l1', Frame[nFrame].Name)>0) or (pos2('_l2', Frame[nFrame].Name)>0);
               //inc(nFrame);
             end;
        { $116: begin // Skin
               BlockRead(f, skinheader, 4); // Read Header
               Seek(f, FilePos(f)+skinheader[1]); // Skip Special Bone Indices (?)

               // RW version must be 3.3 or later
               if (RWVer>=$33000) and (skinheader[0]=length(dffbone)) then begin
                 Geometry[nGeometry].HasSkin:=true;
                 for i:=0 to length(Geometry[nGeometry].vertex)-1 do f.Read(Geometry[nGeometry].vertex[i].bones, 4);
                 for i:=0 to length(Geometry[nGeometry].vertex)-1 do f.Read(Geometry[nGeometry].vertex[i].weights, 16);
               end else msg('  Can''t read skin section!');
             end;}
        $11E: begin // Bone
               Seek(f, FilePos(f)+4);
               BlockRead(f, i, 4); // BoneID
               Frame[nBone].BoneID:=i;
               inc(nBone);
               BlockRead(f, j, 4); // Bone Count
               if j>0 then begin
                 Seek(f, FilePos(f)+8);
                 setLength(dffbone, j);
                 for i:=0 to j-1 do BlockRead(f, dffbone[i], 12);
               end;
             end;
        $50E: begin // Bin Mesh PLG
               BlockRead(f, Geometry[nGeometry].TriStrip, 4); // Face Type
               BlockRead(f, k, 4); // Split Count
               Seek(f, FilePos(f)+4); // Index Count
               setlength(Geometry[nGeometry].Split, k);
               for i:=0 to k-1 do with Geometry[nGeometry].Split[i] do begin
                 BlockRead(f, Count, 4); // Index Count
                 BlockRead(f, MatID, 4); // Material ID
                 if Geometry[nGeometry].IsPS2 then
                   setLength(Index, 0)
                 else begin
                   setLength(Index, Count);
                   BlockRead(f, Pointer(Index)^, 4*Count); // Indices
                 end;
               end;
             end;
        $510: if RWVer>=$36000 then begin // Native Data PLG (SA PS2, RW 3.5+)
               if not Geometry[nGeometry].IsPS2 then begin
                 error:=true;
                 OutputDebugString(('ERROR - File not marked as PS2!'));
                 exit;
               end;

               Seek(f, FilePos(f)+16); // skip broken header and const 4

               for i:=0 to length(Geometry[nGeometry].Split)-1 do with Geometry[nGeometry].Split[i] do begin

                 BlockRead(f, l, 4); // block size
                 l:=FilePos(f)+l+4; // offset of next block
                 Seek(f, FilePos(f)+8); // skip unknown
                 BlockRead(f, k, 4); // unknown data size multiplier
                 Seek(f, FilePos(f)+16*k-8); // skip unknown data

                 // read vertices
                 SetLength(PS2_Vertex, Count);
                 for j:=0 to Count-1 do begin
                   BlockRead(f, comp_vert, 8); // read compressed vertex
                   if LoadFlag then
                     PS2_Vertex[j]:=MakeVector([comp_vert[0]*VERT_SCALE_CAR, comp_vert[1]*VERT_SCALE_CAR, comp_vert[2]*VERT_SCALE_CAR, comp_vert[3]*VERT_SCALE_CAR])
                   else
                     PS2_Vertex[j]:=MakeVector([comp_vert[0]*VERT_SCALE, comp_vert[1]*VERT_SCALE, comp_vert[2]*VERT_SCALE, comp_vert[3]*VERT_SCALE]);
                 end;

                 if Odd(count) then Seek(f, FilePos(f)+8); // skip padding

                 // read UV coords
                 SetLength(PS2_UV, Count);
                 for j:=0 to Count-1 do begin
                   BlockRead(f, comp_vert, 4 + 4*ord(Geometry[nGeometry].HasMultiUVs)); // read compressed uv coords
                   {if LoadFlag then begin
                     PS2_UV[j, 0]:=comp_vert[0]*UV_SCALE_CAR;
                     PS2_UV[j, 1]:=comp_vert[1]*UV_SCALE_CAR;
                   end else begin}
                     PS2_UV[j, 0]:=comp_vert[0]*UV_SCALE;
                     PS2_UV[j, 1]:=comp_vert[1]*UV_SCALE;
                   //end;
                 end;

                 // jump to next block
                 Seek(f, l);

               end;
             end;
      end;

    end;

    // Continue recursive reading
    if HasChildSecs then while not error and (Cardinal(FilePos(f))<=NextPos[lvl]-12) and (Cardinal(FilePos(f))<=Offset+Size-12) do ReadSec(lvl+1);
    // Jump to next sibling
    if not error then Seek(f, NextPos[lvl]);
  end; // ReadSec

var
  i, j: integer;

begin
  try
    Error:=false;
    Result:=false;
    HasBones:=false;
    FileVer:=0;
    Seek(f, offset);

    // Start reading dff ///////////////////
    if Size>12 then readsec(0) else exit; //
    ////////////////////////////////////////

    if error then exit;

    if length(dffbone)>0 then begin
      HasBones:=true;
      setLength(bone, length(dffbone));
      for i:=0 to length(dffbone)-1 do
       for j:=0 to length(Frame)-1 do begin
         if dffbone[i].ID=Frame[j].BoneID then begin
           Bone[i]:=@Frame[j];
           Frame[j].BoneNo:=i;
         end;
       end;
    end;

    Result:=not error;
  finally
  end;
end;


////////////////////////////////////////////////////////////////////////////////
// TTexDict - txd loading and processing functions                            //
////////////////////////////////////////////////////////////////////////////////

destructor TTexDict.Destroy;
var i: integer;
begin
  for i:=0 to length(Texture)-1 do if Texture[i].ID>0 then glDeleteTextures(1, @Texture[i].ID);
  SetLength(Texture, 0);

  inherited Destroy;
end;

function TTexDict.FindTexture(const name: string): PTexture;
var i: integer;
begin
  result:=nil;
  i:=0;
  while not Assigned(result) and (i<length(Texture)) do begin
    if EqualStr(name, Texture[i].Name) then result:=@Texture[i];
    inc(i);
  end;
end;

function TTexDict.LoadFromStream(var f: file; offset, size: Cardinal; LoadFlag: boolean = false): boolean;
const MAX_LEVEL=4;
type
  TCharString = array[0..255] of char;
  TSecHeader = record
    ID, Size, Ver: cardinal;
  end;
var
  Sec: array[0..MAX_LEVEL-1] of TSecHeader;
  NextPos: array[0..MAX_LEVEL-1] of cardinal;
  FileVer, RWVer: cardinal;
  error, stop: boolean;

  TexInfo: record
    AlphaFlags,
    HasAlpha: cardinal;
    Width, Height: word;
    Bits, MipMaps, unk, Compression: byte;
  end;
  TexInfoPS2: record
    width, height, bit: cardinal;
  end;
  Data: Pointer;
  DataSize: cardinal;
  palette: array[0..1023] of byte;

  nTexture, nPS2Struct: integer;
  isPS2, isFirstStruct: boolean;


  procedure ReadSec(lvl: integer);
  var
    //sec2: TSecHeader;
    HasChildSecs: boolean;
    {i, j, k,} l: integer;
    w: word;
    s: TCharString;
  begin
    if lvl>=MAX_LEVEL then begin
      //error:=true;
      //OutputDebugString('WARNING - sub sec level too high');
      Seek(f, NextPos[lvl-1]);
      exit;
    end;
    if error or stop then exit;

    BlockRead(f, sec[lvl], 12);
    if (lvl=0) and (FileVer=0) then begin
      FileVer:=sec[0].ver;
      RWVer:=getRWVersion(FileVer);
    end else if Sec[lvl].Ver<>FileVer then begin
      error:=true;
      OutputDebugString(PChar('ERROR - invalid section @ '+inttostr(FilePos(f)-12)));
      exit;
    end;

    // Backup offset of next sibling
    NextPos[lvl]:=Cardinal(FilePos(f))+sec[lvl].size;

    // Increment current texture ID for each Texture Native section
    if (sec[lvl].ID=$15) and (lvl>0) and (sec[lvl-1].ID=$16) then begin
      inc(nTexture);
      nPS2Struct:=0;
    end;
    if sec[lvl].ID=$01 then inc(nPS2Struct);

    HasChildSecs := (sec[lvl].ID in [$15, $16])
                 or (isPS2 and (sec[lvl].ID=$01) and (nPS2Struct=2) and (lvl>0) and (sec[lvl-1].ID=$15));



    if not HasChildSecs and (sec[lvl].Size>0) and ((Cardinal(FilePos(f))+sec[lvl].Size)<=Offset+Size) then begin
      // parse section data
      // ------------------

      case sec[lvl].ID of
        $00:
          error:=true;
        $01:
          if lvl>0 then case sec[lvl-1].ID of // Struct
            $16: // Texture Dictionary Struct
              begin
                BlockRead(f, w, 2); // Texture Count
                setLength(Texture, w);
                ZeroMemory(@Texture[0], w*sizeof(TTexture));
                nTexture:=-1;
              end;
            $15: // Texture Native Struct
              begin
                BlockRead(f, l, 4); // format identifier

                if l=$325350 then begin
                  // PS2 texture
                  Texture[nTexture].Name:='';
                  isPS2:=true;
                  isFirstStruct:=true;

                end else if l in [8,9] then begin

                  {$REGION 'PC texture'}

                  isPS2:=false;

                  Seek(f, FilePos(f)+4); // skip filter flags
                  ZeroMemory(@s[0], 256);
                  BlockRead(f, s, 32); // texture name
                  Texture[nTexture].Name := Trim(s);
                  Seek(f, FilePos(f)+32); // skip alpha name
                  BlockRead(f, TexInfo, 16);

                  // SA PC Fix
                  if l=9 then with TexInfo do case (AlphaFlags and $0F00) of
                    $100: begin Compression:=1; HasAlpha:=1; end; // DXT1 / A
                    $200: begin Compression:=1; HasAlpha:=0; end; // DXT1
                    $300: begin Compression:=3; HasAlpha:=1; end; // DXT3 / A
                    //$400: begin Compression:=3; HasAlpha:=0; end; // DXT3
                    $500: begin Compression:=0; HasAlpha:=1; end; // 32b  / A
                    $600: begin Compression:=0; HasAlpha:=0; end; // 32b
                  else
                    OutputDebugString(PChar(Texture[nTexture].Name+' - '+inttostr(TexInfo.AlphaFlags)));
                  end;


                  Texture[nTexture].HasAlpha := TexInfo.HasAlpha<>0;

                  //OutputDebugString(PChar(Texture[nTexture].Name+' - '+inttostr(TexInfo.Width)+'x'+inttostr(TexInfo.Height)+' '+inttostr(TexInfo.Bits)+'bpp  ['+inttostr(TexInfo.Compression)+']'));

                  if TexInfo.Bits=8 then begin
                    //Seek(f, FilePos(f)+1024); //skip palette
                    BlockRead(f, palette, 1024);
                  end;
                  BlockRead(f, DataSize, 4);
                  GetMem(Data, DataSize);
                  BlockRead(f, Data^, DataSize);

                  if (TexInfo.Bits=8) and not GL_EXT_texture_color_table then begin
                    // palette not supported, so convert to 32 bit
                    Image8to32(Data, @Palette[0], DataSize);
                    TexInfo.Bits:=32;
                  end else if (TexInfo.Bits=32) then
                    // swap BGRA to RGBA
                    SwapRGBA(Data, DataSize div 4);

                  glGenTextures(1, @Texture[nTexture].ID);
                  glBindTexture(GL_TEXTURE_2D, Texture[nTexture].ID);
                  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
                  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

                  with TexInfo do
                  if Compression=0 then case Bits of
                    8:
                      if Assigned(glColorTableEXT) then begin
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_COLOR_INDEX8_EXT, Width, Height, 0, GL_COLOR_INDEX, GL_UNSIGNED_BYTE, Data);
                        glColorTableEXT(GL_TEXTURE_2D, GL_RGBA8, 256, GL_RGBA, GL_UNSIGNED_BYTE, @Palette[0]);
                      end;
                    16:;
                    32:
                      begin
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
                        //WriteTGA(Texture[nTexture].name, data, width, height);
                      end;
                  end else if Assigned(glCompressedTexImage2DARB) then case Compression of
                    1: // DXT1
                      if HasAlpha=0 then
                        glCompressedTexImage2DARB(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_S3TC_DXT1_EXT, Width, Height, 0, DataSize, Data)
                      else
                        glCompressedTexImage2DARB(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_S3TC_DXT1_EXT, Width, Height, 0, DataSize, Data);
                    3: // DXT3
                      glCompressedTexImage2DARB(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_S3TC_DXT3_EXT, Width, Height, 0, DataSize, Data);
                    5: // DXT5
                      glCompressedTexImage2DARB(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_S3TC_DXT5_EXT, Width, Height, 0, DataSize, Data);
                  end;

                  FreeMem(Data, DataSize);

                  {$ENDREGION}

                end;

                if nTexture>=length(Texture) then stop:=true;
              end;
            $01: // Texture Native > Struct > Struct (PS2)
              if isPS2 and (lvl>1) and (sec[lvl-2].ID=$15) then
                if isFirstStruct then begin
                  // texture header
                  BlockRead(f, TexInfoPS2, 12);
                  isFirstStruct:=false;
                end else begin
                  // image data

                  //OutputDebugString(PChar(Texture[nTexture].Name+' - '+inttostr(TexInfoPS2.Width)+'x'+inttostr(TexInfoPS2.Height)+' '+inttostr(TexInfoPS2.Bit)+'bpp'));

                  Seek(f, FilePos(f)+80); // skip unknown header
                  case TexInfoPS2.bit of
                    4 : DataSize := TexInfoPS2.width * TexInfoPS2.height shr 1;
                    8 : DataSize := TexInfoPS2.width * TexInfoPS2.height;
                    32: DataSize := TexInfoPS2.width * TexInfoPS2.height shl 2;
                  end;
                  GetMem(Data, DataSize);
                  BlockRead(f, Data^, DataSize); // read pixels
                  if TexInfoPS2.bit in [4, 8] then begin
                    Seek(f, FilePos(f)+80); // skip unknown header
                    BlockRead(f, palette, 1 shl TexInfoPS2.bit shl 2); // read palette
                  end;

                  glGenTextures(1, @Texture[nTexture].ID);
                  glBindTexture(GL_TEXTURE_2D, Texture[nTexture].ID);
                  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
                  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

                  with TexInfoPS2 do case bit of
                    4:
                      begin
                        SwizzledImage4to32(Data, @Palette[0], width, height, DataSize);
                        //WriteTGA(Texture[nTexture].name, data, width, height);
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
                      end;
                    8:
                      begin
                        SwizzledImage8to32(Data, @Palette[0], width, height, DataSize);
                        //WriteTGA(Texture[nTexture].name, data, width, height);
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
                      end;
                    32:
                      begin
                        //WriteTGA(Texture[nTexture].name, data, width, height);
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
                      end;
                  else
                    OutputDebugString(PChar('### '+Texture[nTexture].Name+' - '+inttostr(Width)+'x'+inttostr(Height)+' '+inttostr(Bit)+'bpp'));
                  end;

                  FreeMem(Data, DataSize);
                end;
          end;
        $02:
          if lvl>0 then case sec[lvl-1].ID of // String
            $15: // Texture Native
              if isPS2 then begin
                fillchar(s, 256, #00);
                BlockRead(f, s, sec[lvl].Size);
                if Texture[nTexture].Name='' then
                  Texture[nTexture].Name:=trim(s)
                else
                  // have to detect alphas by non-empty alpha strings, since there's no flag :s
                  Texture[nTexture].HasAlpha := (trim(s)<>'');
              end;
            end;

      end;

    end;

    // Continue recursive reading
    if HasChildSecs then while not error and not stop and (Cardinal(FilePos(f))<=NextPos[lvl]-12) and (Cardinal(FilePos(f))<=Offset+Size-12) do ReadSec(lvl+1);
    // Jump to next sibling
    if not error and not stop then Seek(f, NextPos[lvl]);
  end; // ReadSec

begin
  try
    Error:=false;
    Stop:=false;
    isPS2:=false;
    Result:=false;
    FileVer:=0;
    Seek(f, offset);

    // Start reading txd ///////////////////
    if Size>12 then readsec(0) else exit; //
    ////////////////////////////////////////

    Result:=not error;
  finally
  end;
end;




////////////////////////////////////////////////////////////////////////////////
// TIFPAnim - ifp loading and processing functions                            //
////////////////////////////////////////////////////////////////////////////////

(*
procedure TIFPAnim.Clear;
var i1, i2: integer;
begin
  Ready:=false;
  DFF:=nil;
  Playback:=0;
  PlayFWD:=true;
  Speed:=1;
  Time:=0;
  Form1.AnimTree.Clear;
  Form1.barAnimPlayback.Enabled:=false;
  Form1.barAnimPlayback.Buttons[0].Down:=true;
  Form1.tbAnimSpeed.Enabled:=false;
  Form1.tbAnimTime.Enabled:=false;
  Form1.UpdateAnimInfo;
  setLength(tmpFrameMat, 0);
  for i1:=0 to length(Animation)-1 do begin
    Animation[i1].Name:='';
    for i2:=0 to length(Animation[i1].AnimObject)-1 do
      SetLength(Animation[i1].AnimObject[i2].AnimFrame, 0);
    SetLength(Animation[i1].AnimObject, 0);
  end;
  SetLength(Animation, 0);
end;

destructor TIFPAnim.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TIFPAnim.LoadFromFile(Filename: String; ADFFClump: PDFFClump);
const
  ANPK = 'ANPK'; ANP3 = 'ANP3';
  DGAN = 'DGAN';
  CPAN = 'CPAN';
  INFO = 'INFO';
  ANIM = 'ANIM';
  NAME = 'NAME';

type
  TSecHeader = record
    ID: array[0..3] of char;
    Size: cardinal;
  end;
  TCharString = array[0..255] of char;

var
  f: TFileStream;
  i1, i2, i3, j: integer;
  s: TCharString;
  Sec: array[0..3] of TSecHeader;
  NextPos: array[0..3] of cardinal;
  AnimCount, AnimObjCount, AnimObjSize, AnimObjUnk, AnimObjFrameType,
  StartTime: Cardinal;
  NewVer, AssignByBoneID: boolean;
  si: smallint;
  w: word;

  Node1, Node2: PVirtualNode;
  NodeData: PTreeData;

begin
  if not ADFFClump.Ready or not FileExists(FileName) then exit;

  msg(#13#10'Loading "'+FileName+'" ...');
  StartTime:=getTickCount;
  f:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Clear;

    DFF:=ADFFClump;
    setLength(tmpFrameMat, length(dff.Frame));

    Form1.AnimTree.BeginUpdate;

    f.Read(Sec, 16); // ANP3 or ANPK & INFO

    if (Sec[0].ID<>ANP3) and not ((Sec[0].ID=ANPK) and (Sec[1].ID=INFO)) then begin
      msg('  Error reading animation package!');
      exit;
    end else NewVer:=(Sec[0].ID=ANP3);

    AssignByBoneID:=Form1.ByBoneID1.Checked and not Form1.ByFrameName1.Checked;

    NextPos[0]:=f.Position-8+Sec[0].Size;
    if NewVer then f.Position:=32 else NextPos[1]:=f.Position+ceil(sec[1].size/4)*4;

    f.Read(AnimCount, 4);
    msg('  Animations: '+inttostr(AnimCount));
    if not NewVer then f.Position:=NextPos[1];

    SetLength(Animation, AnimCount);

    for i1:=0 to AnimCount-1 do begin

      if NewVer then
        f.Read(s, 24)
      else begin
        f.Read(Sec[1], 8); // NAME
        if Sec[1].ID<>NAME then begin msg('  Error: NAME'); exit; end;
        NextPos[1]:=f.Position+ceil(sec[1].size/4)*4;
        f.Read(s, Sec[1].Size);
        f.Position:=NextPos[1];
      end;

      Animation[i1].Name:=trim(s);
      //OutputDebugString(PChar(Animation[i1].Name));
      Animation[i1].TotalDuration:=0;

      Node1:=Form1.AnimTree.AddChild(nil);
      NodeData:=Form1.AnimTree.GetNodeData(Node1);
      NodeData.AnimInd:=i1;
      NodeData.AnimObjInd:=-1;

      if not NewVer then begin
        f.Read(Sec[1], 16); // DGAN & INFO
        if Sec[1].ID<>DGAN then begin msg('  Error: DGAN'); exit; end;
        if Sec[2].ID<>INFO then begin msg('  Error: INFO'); exit; end;
        NextPos[1]:=f.Position-8+Sec[1].Size;
        NextPos[2]:=f.Position + Sec[2].Size;
      end;

      f.Read(AnimObjCount, 4);
      if NewVer then begin
        f.Read(AnimObjSize, 4);
        f.Read(AnimObjUnk, 4);
        NextPos[1]:=f.Position + AnimObjCount*36 + AnimObjSize;
      end else
        f.Position:=NextPos[2];

      SetLength(Animation[i1].AnimObject, AnimObjCount);

      for i2:=0 to AnimObjCount-1 do begin

        if NewVer then begin
          f.Read(s, 24);
          f.Read(AnimObjFrameType, 4);
        end else begin
          f.Read(Sec[2], 16); // CPAN & ANIM
          if Sec[2].ID<>CPAN then begin msg('  Error: CPAN'); exit; end;
          if Sec[3].ID<>ANIM then begin msg('  Error: ANIM'); exit; end;
          NextPos[2]:=f.Position-8+Sec[2].Size;
          NextPos[3]:=f.Position + Sec[3].Size;

          f.Read(s, 28);
        end;
        Animation[i1].AnimObject[i2].Name:=trim(s);

        f.Read(Animation[i1].AnimObject[i2].NumFrames, 4);
        Animation[i1].AnimObject[i2].CurrentFrame:=0;
        if not NewVer then f.Seek(8, soFromCurrent);
        f.Read(Animation[i1].AnimObject[i2].BoneID, 4);

        // Check, which of the animations can be applied to the loaded model
        // must do in reverse order, because VC models have 2x "root"!
        Animation[i1].AnimObject[i2].ObjFrame:=-1;
        j:=length(DFF.Frame)-1;
        while (Animation[i1].AnimObject[i2].ObjFrame=-1) and (j>=0) do begin
          //case Form1.AssignAnimsbyBoneID1.Checked of
          //  false: if CompareText(Animation[i1].AnimObject[i2].Name, DFF.Frame[j].Name)=0 then Animation[i1].AnimObject[i2].ObjFrame:=j;
          //  true:  if Animation[i1].AnimObject[i2].BoneID=DFF.Frame[j].BoneID then Animation[i1].AnimObject[i2].ObjFrame:=j;
          //end;
          //if (Animation[i1].AnimObject[i2].BoneID=DFF.Frame[j].BoneID) or (CompareText(Animation[i1].AnimObject[i2].Name, DFF.Frame[j].Name)=0) then Animation[i1].AnimObject[i2].ObjFrame:=j;

          if (AssignByBoneID and (Animation[i1].AnimObject[i2].BoneID=DFF.Frame[j].BoneID))
          or (not AssignByBoneID and (CompareText(Animation[i1].AnimObject[i2].Name, DFF.Frame[j].Name)=0))
          then Animation[i1].AnimObject[i2].ObjFrame:=j;
          
          dec(j);
        end;

        Node2:=Form1.AnimTree.AddChild(Node1);
        NodeData:=Form1.AnimTree.GetNodeData(Node2);
        NodeData.AnimInd:=i1;
        NodeData.AnimObjInd:=i2;
        Node2.CheckType:=ctCheckBox;
        if Animation[i1].AnimObject[i2].ObjFrame>=0 then begin
          Node2.CheckState:=csCheckedNormal;
          Animation[i1].AnimObject[i2].Enabled:=true;
        end else begin
          Node2.States:=Node2.States+[vsDisabled];
          Animation[i1].AnimObject[i2].Enabled:=false;
        end;

        if not NewVer then f.Position:=NextPos[3];

        if Animation[i1].AnimObject[i2].NumFrames>0 then begin

          if not NewVer then begin
            f.Read(Sec[3], 8); // Kxxx (KRTS)
            if Sec[3].ID[0]<>'K' then begin msg('  Error: Kxxx @ 0x'+inttohex(f.Position-8, 2)); exit; end;
          end;
  
          if Animation[i1].AnimObject[i2].ObjFrame>=0 then begin
            // Object exists in dff hierarchy, so load it's anims
  
            SetLength(Animation[i1].AnimObject[i2].AnimFrame, Animation[i1].AnimObject[i2].NumFrames);
  
            for i3:=0 to Animation[i1].AnimObject[i2].NumFrames-1 do begin
              FillChar(Animation[i1].AnimObject[i2].AnimFrame[i3], SizeOf(TAnimFrame), 0);

              with Animation[i1].AnimObject[i2].AnimFrame[i3] do
              if NewVer then begin
                // quaternion
                for j:=0 to 2 do begin
                  f.Read(si, 2); rot.Vector[j]:=-si/4096;
                end;
                f.Read(si, 2); rot.Vector[3]:=si/4096;

                // time key
                f.Read(w, 2); TimeKey:=w/60;

                // vector
                if AnimObjFrameType=4 then begin
                  HasPos:=true;
                  for j:=0 to 2 do begin
                    f.Read(si, 2); pos[j]:=si/1024;
                  end;
                end;

              end else begin
                if Sec[3].ID[1]='R' then // read Rotation Quaternion
                  f.Read(Rot, 16);

                if Sec[3].ID[2]='T' then begin // read Translation Vector
                  HasPos:=true;
                  f.Read(Pos, 12);
                end;

                if Sec[3].ID[3]='S' then // skip Scale Vector
                  f.Seek(12, soFromCurrent);

                // read Time Key
                f.Read(TimeKey, 4);
              end;

            end;
  
            with Animation[i1].AnimObject[i2] do Duration:=AnimFrame[NumFrames-1].TimeKey;
  
          end else begin
            // Object doesn't exist, so skip the anim data

            // calculate frame size
            if NewVer then
              j:=10 + ord(AnimObjFrameType=4)*6
            else
              j:=4 + ord(Sec[3].ID[1]='R')*16 + ord(Sec[3].ID[2]='T')*12 + ord(Sec[3].ID[3]='S')*12;

            f.Seek(j*integer(Animation[i1].AnimObject[i2].NumFrames), soFromCurrent);
            if Animation[i1].AnimObject[i2].NumFrames>0 then begin
              if NewVer then begin
                f.Seek(-2 - ord(AnimObjFrameType=4)*6, soFromCurrent);
                f.Read(w, 2); Animation[i1].AnimObject[i2].Duration:=w/60;
                if AnimObjFrameType=4 then f.Seek(6, soFromCurrent);
              end else begin
                f.Seek(-4, soFromCurrent);
                f.Read(Animation[i1].AnimObject[i2].Duration, 4);
              end
            end;
          end;
          
        end;

        if Animation[i1].AnimObject[i2].Duration>Animation[i1].TotalDuration then
          Animation[i1].TotalDuration:=Animation[i1].AnimObject[i2].Duration;

        if not NewVer then f.Position:=NextPos[2];
      end;

      f.Position:=NextPos[1];
    end;


    Ready:=true;
    SwitchAnim(0);
    Form1.barAnimPlayback.Enabled:=true;
    Form1.tbAnimSpeed.Enabled:=true;
    Form1.tbAnimTime.Enabled:=true;
    Speed:=Speeds[4-Form1.tbAnimSpeed.Position];
    msg('Finished successfully ('+inttostr(getTickCount-StartTime)+' ms).');
  finally
    f.Free;
    if not Ready then begin
      msg('Loading not successful!');
      Clear;
    end else Form1.UpdateAnimInfo;
    Form1.AnimTree.EndUpdate;
  end;
end;

procedure TIFPAnim.SwitchAnim(Ind: integer);
var
  //i: integer;
  Node: PVirtualNode;
  NodeData: PTreeData;
begin
  if not ready then exit;
  ready:=false;
  
  //if (ind>=0) and (ind<length(Animation)) then CurrentAnim:=ind;
  if ind<0 then CurrentAnim:=length(Animation)-1 else
   if ind>=length(Animation) then CurrentAnim:=0 else
    CurrentAnim:=ind;

  if PlayFWD then Time:=0 else Time:=Animation[CurrentAnim].TotalDuration;
  //with Animation[CurrentAnim] do for i:=0 to length(AnimObject)-1 do AnimObject[i].CurrentFrame:=0;
  ready:=true;
  if Playback>0 then UpdateAnim(true) else dff.SetBasePose;

  with Form1.AnimTree do begin //Set focus on current anim
    Node:=GetFirst;
    while Assigned(Node) do begin
      NodeData:=GetNodeData(Node);
      if NodeData.AnimInd=CurrentAnim then begin
        FocusedNode:=Node;
        Node:=nil;
      end else
        Node:=GetNext(Node);
    end;
  end;
  Form1.UpdateAnimInfo;
end;

procedure TIFPAnim.UpdateAnim(ForceUpdate: boolean);
var
  i, j, num: integer;
  b: byte;
  t: single;
  v: TVector3f;
  q: TQuaternion;
begin
  if not ready then exit;

  with Animation[CurrentAnim] do begin

    //find current frame
    if (Playback=2) or ForceUpdate then for i:=0 to length(AnimObject)-1 do with AnimObject[i] do begin
      if Enabled and (NumFrames>1) then case PlayFWD of
        true : begin // forward
                 if AnimFrame[CurrentFrame].TimeKey>Time then CurrentFrame:=0;
                 while (CurrentFrame<NumFrames-2) and (AnimFrame[CurrentFrame+1].TimeKey<Time) do inc(CurrentFrame);
               end;
        false: begin // backward
                 if AnimFrame[CurrentFrame+1].TimeKey<Time then CurrentFrame:=NumFrames-2;
                 while (CurrentFrame>0) and (AnimFrame[CurrentFrame].TimeKey>Time) do dec(CurrentFrame);
               end;
      end;
    end;

    // Prepare temporary matrices
    num:=length(tmpFrameMat);
    for i:=0 to num-1 do begin
      tmpFrameMat[i].used:=false;
      tmpFrameMat[i].mat:=IdentityMatrix;
    end;

    // Calculate and store current frame animations
    for i:=0 to length(AnimObject)-1 do with AnimObject[i] do
     if enabled and (ObjFrame>=0) and (NumFrames>0) then begin
       // Calculate interpolation value
       if NumFrames>1 then begin
         t:=EnsureRange((time-AnimFrame[CurrentFrame].TimeKey) / (AnimFrame[CurrentFrame+1].TimeKey-AnimFrame[CurrentFrame].TimeKey), 0, 1);
         //if (t<0) or (t>1) then msg(format('%s | %d/%d | %.3f | %.3f; %.3f; %.3f | %.3f %.3f', [name, CurrentFrame, NumFrames-1, t, AnimFrame[CurrentFrame].TimeKey, time, AnimFrame[CurrentFrame+1].TimeKey,  AnimFrame[0].TimeKey, Animframe[0].Rot.ImagPart[0]]));
       end else t:=0;

       if Form1.Interpolation1.Checked then
         //q:=QuaternionSlerp(AnimFrame[CurrentFrame].Rot, AnimFrame[CurrentFrame+1].Rot, 0, t)
         q:=QuaternionSlerp2(AnimFrame[CurrentFrame].Rot, AnimFrame[CurrentFrame+1].Rot, t)
       else
         q:=AnimFrame[CurrentFrame].Rot;

       //VectorNormalize(q.Vector);
       tmpFrameMat[ObjFrame].mat:=QuaternionToMatrix2(q);

       if AnimFrame[CurrentFrame].HasPos then begin
         if Form1.Interpolation1.Checked then
           v:=VectorAffineLerp(AnimFrame[CurrentFrame].Pos, AnimFrame[CurrentFrame+1].Pos, t)
         else
           v:=AnimFrame[CurrentFrame].Pos;
         tmpFrameMat[ObjFrame].mat[3,X]:=v[X];
         tmpFrameMat[ObjFrame].mat[3,Y]:=v[Y];
         tmpFrameMat[ObjFrame].mat[3,Z]:=v[Z];
       end;
       tmpFrameMat[ObjFrame].used:=true;
     end;
     { else
       // animation disabled, so use the basic rotation (but not translation!)
       move(dff.Frame[ObjFrame].Matrix, tmpFrameMat[ObjFrame], 48);}

  end;

  // Update all frames (also skinning)

  for i:=0 to num-1 do with dff.Frame[i], tmpFrameMat[i] do
    // Frame Transformations
    if not Assigned(Parent) then
      LTM:=Matrix
    else begin
      if not used then move(Matrix, mat, 48); // use basic rotation
      LTM:=MatrixMultiply(mat, MatrixMultiply(MatrixTranslationOnly(Matrix), Parent.LTM));
    end;

  for i:=0 to num-1 do with dff.Frame[i] do
    // Skinning
    if Assigned(Geometry) and Geometry.HasSkin and
       Form1.cbxGeometry.Checked and (Form1.cbxPoints.Checked or Form1.cbxLines.Checked or Form1.cbxPolys.Checked)
    then
      {todo: skinning calculation}
      for j:=0 to length(Geometry.vertex)-1 do with Geometry.vertex[j] do begin
        b:=0;
        p:=NullVector;
        //while (b<=3) and (weights[b]>0) do begin
        if weights[b]>0 then begin
          v:=VectorAffineSubtract(p_, dff.bone[bones[b]].Pos0);
          v:=VectorTransform2(v, dff.bone[bones[b]].LTM);
          //v:=VectorTransform(v, MatrixTranslationOnly(dff.bone[bones[b]].LTM));
          //VectorScale(v, weights[b]);
          p:=VectorAffineAdd(p, v);
          inc(b);
        end;


        {pre.x = meshdata[loop].x - rootBone->children[boneloop].trans.x;
				pre.y = meshdata[loop].y - rootBone->children[boneloop].trans.y;
				pre.z = meshdata[loop].z - rootBone->children[boneloop].trans.z;
				// PUT IT THROUGH THE ROTATION
				MultVectorByMatrix(&rootBone->children[boneloop].matrix, &pre, &post);
				// ADD IN THE WEIGHTED DELTA OF THIS POSITION
				defdata[loop].x += ((post.x - meshdata[loop].x) * weight);
				defdata[loop].y += ((post.y - meshdata[loop].y) * weight);
				defdata[loop].z += ((post.z - meshdata[loop].z) * weight);}

      end;

end;
*)

////////////////////////////////////////////////////////////////////////////////
// TArchive - img loading and processing functions                            //
////////////////////////////////////////////////////////////////////////////////

constructor TArchive.Create(fname: string);
begin
  inherited Create;

  // set all to nil
  ZeroMemory(@Entries[low(Entries)], length(Entries));
  ArchiveFile:=nil;
  numStreamFiles:=0;
  numLoadedStreamFiles:=0;

  AttachArchive(fname);
end;

function TArchive.AttachArchive(fname: string): PArchiveFile;
const
  VER2='VER2';
  BS=2048;
var
  i, num, val: integer;
  archive: PArchiveFile;
  p: array[TFileExt] of PStreamFile;
  p_new: PStreamFile;
  fourcc: array[0..3] of char;
  dirname: string;
  dir: file;
  ok: boolean;
begin
  OutputDebugString(PChar('IMG - '+fname));

  ok:=false;

  ZeroMemory(@p[low(p)], length(p));

  new(archive);
  archive.next:=nil;
  archive.name:=fname;
  Assign(archive.f, fname);

  with archive^ do try
    Reset(f, 1);

    BlockRead(f, fourcc, 4);
    if fourcc=VER2 then begin // SanAn IMG V2
      BlockRead(f, Num, 4);
      for i:=1 to Num do begin
        New(p_new);
        ZeroMemory(p_new, SizeOf(TStreamFile));
        BlockRead(f, val, 4); p_new.Offset:=val*BS;
        BlockRead(f, val, 4); p_new.Size:=val*BS;
        BlockRead(f, p_new.Name, 24);
        p_new.Archive:=archive;

        p_new.ext:=ClassifyFileExt(ExtractFileExt(p_new.Name));
        if Assigned(p[p_new.ext]) then
          p[p_new.ext].next:=p_new
        else if Assigned(Entries[p_new.ext]) then begin
          p[p_new.ext]:=Entries[p_new.ext];
          while Assigned(p[p_new.ext].next) do p[p_new.ext]:=p[p_new.ext].next;
          p[p_new.ext].next:=p_new;
        end else
          Entries[p_new.ext]:=p_new;
        inc(numStreamFiles);
        p[p_new.ext]:=p_new;
      end;
      ok:=true;
    end else begin // Old IMG V1
      Seek(f, 0);
      dirname:=ChangeFileExt(fname, '.dir');
      if not FileExists(dirname) then begin
        OutputDebugString(PChar('Error loading archive: '+dirname+' not found!'));
        exit;
      end;
      Assign(dir, dirname);
      Try
        OutputDebugString(PChar('DIR - '+dirname));
        Reset(dir, 1);
        Num:=FileSize(dir) div 32;

        for i:=1 to Num do begin
          New(p_new);
          ZeroMemory(p_new, SizeOf(TStreamFile));
          BlockRead(dir, val, 4); p_new.Offset:=val*BS;
          BlockRead(dir, val, 4); p_new.Size:=val*BS;
          BlockRead(dir, p_new.Name, 24);
          p_new.Archive:=archive;

          {p_new.ext:=ClassifyFileExt(ExtractFileExt(p_new.Name));
          if Assigned(p[p_new.ext]) then
            p[p_new.ext].next:=p_new
          else
            Entries[p_new.ext]:=p_new;
          inc(numStreamFiles);
          p[p_new.ext]:=p_new;}
          p_new.ext:=ClassifyFileExt(ExtractFileExt(p_new.Name));
          if Assigned(p[p_new.ext]) then
            p[p_new.ext].next:=p_new
          else if Assigned(Entries[p_new.ext]) then begin
            p[p_new.ext]:=Entries[p_new.ext];
            while Assigned(p[p_new.ext].next) do p[p_new.ext]:=p[p_new.ext].next;
            p[p_new.ext].next:=p_new;
          end else
            Entries[p_new.ext]:=p_new;
          inc(numStreamFiles);
          p[p_new.ext]:=p_new;
        end;
        ok:=true;
      finally
        Close(dir);
      end;
    end;

  finally
    if not ok then begin
      OutputDebugString(PChar('Can''t load archive "'+fname+'" due to errors! (Offset '+inttostr(filepos(f))+')'));
      Close(archive.f);
      archive:=nil;
    end else begin
      if Assigned(ArchiveFile) then archive.next:=ArchiveFile;
      ArchiveFile:=archive;
    end;
  end;

end;

function TArchive.AddExternal(const fname: string): PStreamFile;
var
  f: file;
  p: PStreamFile;
  s: string;
begin
  result:=nil;
  if not FileExists(fname) then exit;

  Assign(f, fname);
  Try
    reset(f, 1);

    New(p);
    ZeroMemory(p, SizeOf(TStreamFile));
    s:=ExtractFileName(fname);
    Move(s[1], p.Name, 24);
    p.ext:=ClassifyFileExt(ExtractFileExt(fname));
    case p.ext of
      feTXD:
        begin
          OutputDebugString(PChar('TXD - '+fname));
          p.data:=TTexDict.Create;
        end;
      {feDFF:
        begin
          OutputDebugString(PChar('DFF - '+fname));
          p.data:=TDFFClump.Create;
        end;}
    else
      exit;
    end;

    if p.data.LoadFromStream(f, 0, FileSize(f)) then begin
      p.isLoaded:=true;
      p.isNeeded:=true;
      p.KeepInMem:=true;

      // add entry before all others
      if Assigned(Entries[p.ext]) then begin
        p.Next:=Entries[p.ext];
        Entries[p.ext]:=p;
      end else
        Entries[p.ext]:=p;

      result:=p;
      inc(numLoadedStreamFiles);
      inc(numStreamFiles);
    end else begin
      p.isFaulty:=true;
      FreeAndNil(p.data);
      OutputDebugString(PChar('Can''t load "'+fname+'" due to errors!'));
    end;
  finally
    close(f);
  end;
end;

destructor TArchive.Destroy;
var
  p, pn: PStreamFile;
  a, an: PArchiveFile;
  ext: TFileExt;
begin
  //Close(f);
  a:=ArchiveFile;
  ArchiveFile:=nil;
  while Assigned(a) do begin
    Close(a.f);
    an:=a.next;
    Dispose(a);
    a:=an;
  end;

  for ext:=low(TFileExt) to high(TFileExt) do begin
    p:=Entries[ext];
    Entries[ext]:=nil;
    while Assigned(p) do begin
      if p.isLoaded then begin
        FreeAndNil(p.data);
        dec(numLoadedStreamFiles);
      end;
      pn:=p.Next;
      Dispose(p);
      dec(numStreamFiles);
      p:=pn;
    end;
  end;

  OutputDebugString(PChar(inttostr(numLoadedStreamFiles)+' loaded archive files remaining'));
  OutputDebugString(PChar(inttostr(numStreamFiles)+' archive file entries remaining'));

  inherited Destroy;
end;

function TArchive.Find(const name: string): PStreamFile;
begin
  result:=Find(name, ClassifyFileExt(ExtractFileExt(name)));
end;

function TArchive.Find(const name: string; const ext: TFileExt): PStreamFile;
// that's quite slow for SanAn :(
var p: PStreamFile;
begin
  result:=nil;
  p:=Entries[ext];
  while Assigned(p) do begin
    if Equalstr(name, p.Name) then begin
      result:=p;
      //p:=nil;
      exit;
    end else
      p:=p.Next;
  end;
end;

end.
