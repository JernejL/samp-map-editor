unit RequiredTypes;

// misc type declarations and helper functions for GTA Map Viewer
// © 2005 by Steve M.

interface

uses
  Windows,
  OpenGL12,
  Geometry,
  Misc;

type
  TFileExt = (feDFF, feTXD, feCOL, feIFP, feIPL, feOther);
  TObjectType = (otStatic, otCar);
  TGameType = (GTA_NONE, GTA_3_PS2, GTA_3_PC, GTA_VC_PS2, GTA_VC_PC, GTA_SA_PS2, GTA_SA_PC);

  TStreamFileClass = class
    private
    public
      //Ready: boolean;
      function LoadFromStream(var f: file; offset, size: Cardinal; LoadFlag: boolean = false): boolean; virtual; abstract;
  end;

  PArchiveFile = ^TArchiveFile;
  TArchiveFile = record
    next: PArchiveFile;
    name: string;
    f: file;
  end;

  PStreamFile = ^TStreamFile;
  TStreamFile = packed record
    Offset, Size: Cardinal;
    Name: array[0..23] of Char;

    Next, Parent: PStreamFile;
    Archive: PArchiveFile;
    LastRequest: cardinal;
    data: TStreamFileClass;
    ext: TFileExt;
    isNeeded, isLoaded, isFaulty, KeepInMem, isSpecial: boolean;
  end;

  TBox = record
    p1, p2: TVector3f;
  end;
  TSphere = record
    p: TVector3f;
    r: Single;
  end;

  PItemDefinition = ^TItemDefinition;
  TItemDefinition = packed record
    next   : PItemDefinition;
    ID     : Cardinal;
    ObjType: TObjectType;
    ModelName, TexDictName, AnimName: string;
    Model,     TexDict,     Anim    : PStreamFile;
    Dist,
    Flags  : integer;
    Box    : TBox;
    Sphere : TSphere;
    HasBounds, HasAlpha, isLOD, isChecked, isUsed,
    Timed  : boolean;
    t_on,
    t_off  : byte;
  end;

  PItemInstance = ^TItemInstance;
  TItemInstance = packed record
    next, nextVisible: PItemInstance;
    def     : PItemDefinition;
    Interior: integer;
    Pos     : TVector3F;
    RotAxis : TVector3F;
    RotAngle: Single;
    //Mat: TMatrix;
    Flags   : integer;
    ParentLOD: PItemInstance;
    CurrDist: single;
    LastFrame: cardinal;
  end;

  PEnex = ^TEnex;
  TEnex = record
    next    : PEnex;

    Entrance: TVector3F;
    Rotation,
    OffsetX,
    OffsetY : single;
    Eight   : integer;
    Target  : TVector3F;
    UnkF    : single;
    Interior,
    Flag1   : integer;
    Name    : string;
    Flag2,
    Flag3   : integer;
    t_on,
    t_off   : byte;
  end;

  TCamera = class
    private
      FPos, FDir,
      FEnexReturn: TVector3F;
      FInterior: integer;
      FTarget: PAffineFltVector;
      Frustum: array[0..5] of TVector4F;
      FChanged, FChangedNext: boolean;
      procedure CalcFrustum;
    public
      DoFollow,
      StreamingEnabled, FrustCullEnabled, DistCullEnabled: boolean;
      FollowSpeed,
      DistFact,
      FOV: single;
      EnexTime: cardinal;
      FocusInst: PItemInstance;
      PosArray: array[0..9] of record
        pos, dir: TVector3F;
      end;
      property  Position: TVector3F read FPos;
      property  Interior: integer read FInterior;
      property  hasChanged: boolean read FChanged;
      procedure Update(dt: single);
      procedure Reset;
      procedure Change(next: boolean = false);
      procedure Continue;
      procedure LoadPos(i: integer);
      procedure SavePos(i: integer);
      procedure SetCam(Position: TVector3F); overload;
      procedure SetCam(Position, Target: TVector3F); overload;
      procedure SetCam(Position: TVector3F; Angle, Height: Single); overload;
      procedure SetCam(Angle, Height: Single); overload;
      procedure Move(dPosition: TVector3F); overload;
      procedure Move(dist: single; strafe: boolean = false); overload;
      procedure Rotate(dAngle, dHeight: Single); overload;
      //procedure Rotate(dDirection: TVector3F); overload;
      procedure Follow(Target: PAffineFltVector; Speed: single = 1.0);
      procedure FollowEnex(enex: PEnex);
      procedure LeaveInterior;
      function  GetDist(p: TVector3F): single;
      function  isSphereInFrustum(p: TVector3F; r: single): boolean;
      function  isSphereInFrustumExt(p: TVector3F; r: single): integer;
      function  isVisible(inst: PItemInstance; CheckFocus: boolean; GameType: TGameType): PItemInstance;
      constructor Create;
  end;

  //function  RotateVector(v: TVector3F; angle: single; axis: TVector3F): TVector3F;
  procedure QuatToAxisRot(q: TQuaternion; var angle: single; var axis: TVector3F);
  //function  QuatToMat(q: TQuaternion): TMatrix4F;
  function  ClassifyFileExt(const ext: string): TFileExt;

  procedure InitEngineTime;
  procedure UpdateEngineTime;
  function  CheckGameTime(t_on, t_off: byte): boolean;
  function  FormatGameTime: string;


const
  GameTypeString: array[TGameType] of string =
    ('Unknown Game Type',
     'GTA III (PS2)',          'GTA III (PC)',
     'GTA: Vice City (PS2)',   'GTA: Vice City (PC)',
     'GTA: San Andreas (PS2)', 'GTA: San Andreas (PC)');

var
  EngineTime: record
    StartTicks,          // system time when renderer was started in milliseconds
    CurrentTicks,        // current system time minus StartTicks in ms
    LastTicks,           // last CurrentTicks value in ms
    numFrames: Cardinal; // number of rendered frames since start
    Diff: Single;        // seconds elapsed between two frames ((CurrentTicks-LastTicks)/1000)
    Running: boolean;    // if false, simulation time remains unchanged (paused)
    SimTicks: cardinal;  // simulation time in ms
    SimFact,             // simulation time factor
    SimDiff,             // simulated time difference (in sec)
    GameTime: Single;    // game time in h*min
    LastHour: byte;      // h of last update
    FullHour,            // true if hour since last update changed
    isNight : boolean;   // true if not day :p
  end;

  Opt: record // Options
    Test,
    Verbose,
    //DrawSpheres,
    DrawLODs,
    QuickLoad,
    DoFullScreen,
    DoWindowBorders,
    VSync,
    VehicleTest,
    EnexTest,
    ShowTextures,
    ShowInterior: Boolean;
    MaxFilesPerFrame: integer;
    StreamWaitTime: cardinal;
    Screen: array[boolean] of record
      w, h: integer;
    end;
    Game: array[0..3] of string;
    MapFilter: string;
  end;


implementation

const
  MAX_HEIGHT_ANGLE = pi/2 - 1e-5;

(*function RotateVector(v: TVector3F; angle: single; axis: TVector3F): TVector3F;
var
  RotMat: TMatrix4f;
  cosine, sine, Len, one_minus_cosine: Extended;
begin
  if angle=0 then
    result:=v
  else begin
    //RotMat := CreateRotationMatrix(Axis, Angle);

    SinCos(Angle, Sine, Cosine);
    one_minus_cosine := 1 - cosine;
    Len := VectorNormalize(Axis);

    if Len = 0 then RotMat := IdentityMatrix
               else
    begin
      RotMat[0, 0] := (one_minus_cosine * Sqr(Axis[0]))      + Cosine;
      RotMat[0, 1] := (one_minus_cosine * Axis[0] * Axis[1]) - (Axis[2] * Sine);
      RotMat[0, 2] := (one_minus_cosine * Axis[2] * Axis[0]) + (Axis[1] * Sine);
      RotMat[0, 3] := 0;

      RotMat[1, 0] := (one_minus_cosine * Axis[0] * Axis[1]) + (Axis[2] * Sine);
      RotMat[1, 1] := (one_minus_cosine * Sqr(Axis[1]))      + Cosine;
      RotMat[1, 2] := (one_minus_cosine * Axis[1] * Axis[2]) - (Axis[0] * Sine);
      RotMat[1, 3] := 0;

      RotMat[2, 0] := (one_minus_cosine * Axis[2] * Axis[0]) - (Axis[1] * Sine);
      RotMat[2, 1] := (one_minus_cosine * Axis[1] * Axis[2]) + (Axis[0] * Sine);
      RotMat[2, 2] := (one_minus_cosine * Sqr(Axis[2]))      + Cosine;
      RotMat[2, 3] := 0;

      RotMat[3, 0] := 0;
      RotMat[3, 1] := 0;
      RotMat[3, 2] := 0;
      RotMat[3, 3] := 1;
    end;



    {

    



float c = cos( rotAngle );

float s = sin( rotAngle );

float t = 1.0f - c;



float t01 = t * rotAxis[0] * rotAxis[1];

float t02 = t * rotAxis[0] * rotAxis[2];

float t12 = t * rotAxis[1] * rotAxis[2];



float s0 = s * rotAxis[0];

float s1 = s * rotAxis[1];

float s2 = s * rotAxis[2];



// pos is the point to be rotated - becomes rotPos

float rotPosX = (t * rotAxis[0] * rotAxis[0] + c) * posX + (t01 - s2)                        * posY + (t02 + s1)                        * posZ;

float rotPosY = (t01 + s2)                        * posX + (t * rotAxis[1] * rotAxis[1] + c) * posY + (t12 - s0)                        * posZ;

float rotPosZ = (t02 - s1)                        * posX + (t12 + s0)                        * posY + (t * rotAxis[2] * rotAxis[2] + c) * posZ;






}




    Result := VectorTransform(v, RotMat);
  end;
end; *)

procedure QuatToAxisRot(q: TQuaternion; var angle: single; var axis: TVector3F);
// source: MooMapper by KCow
var s: single;
begin
  S := Sqrt(1.0 - Sqr(q.RealPart));

  // divide by zero
  if not (S = 0) then begin
    axis[0] := ArcSin(q.ImagPart[0]) / S;
    axis[1] := ArcSin(q.ImagPart[1]) / S;
    axis[2] := ArcSin(q.ImagPart[2]) / S;
    angle   := 2 * ArcCos(-q.RealPart) * 180 / Pi;
  end else angle:=0;
end;

{function QuatToMat(q: TQuaternion): TMatrix4F;
var xx, xy, xz, xw, yy, yz, yw, zz, zw: single;
begin
  xx := q.Vector[0] * q.Vector[0];
  xy := q.Vector[0] * q.Vector[1];
  xz := q.Vector[0] * q.Vector[2];
  xw := q.Vector[0] * q.Vector[3];
  yy := q.Vector[1] * q.Vector[1];
  yz := q.Vector[1] * q.Vector[2];
  yw := q.Vector[1] * q.Vector[3];
  zz := q.Vector[2] * q.Vector[2];
  zw := q.Vector[2] * q.Vector[3];

  result:=IdentityMatrix;

  result[0, 0] := 1 - 2 * ( yy + zz );
  result[0, 1] :=     2 * ( xy - zw );
  result[0, 2] :=     2 * ( xz + yw );

  result[1, 0] :=     2 * ( xy + zw );
  result[1, 1] := 1 - 2 * ( xx + zz );
  result[1, 2] :=     2 * ( yz - xw );

  result[2, 0] :=     2 * ( xz - yw );
  result[2, 1] :=     2 * ( yz + xw );
  result[2, 2] := 1 - 2 * ( xx + yy );
end;}

function ClassifyFileExt(const ext: string): TFileExt;
begin
  if EqualStr(ext, '.dff') then result:=feDFF else
  if EqualStr(ext, '.txd') then result:=feTXD else
  if EqualStr(ext, '.col') then result:=feCOL else
  if EqualStr(ext, '.ifp') then result:=feIFP else
  if EqualStr(ext, '.ipl') then result:=feIPL else
   result:=feOther;
end;

function CheckGameTime(t_on, t_off: byte): boolean;
begin
  if t_on<=t_off then
    result := (t_on*60<=EngineTime.GameTime) and (EngineTime.GameTime<t_off*60)
  else
    result := (t_on*60<=EngineTime.GameTime) or (EngineTime.GameTime<t_off*60)
end;

procedure InitEngineTime;
begin
  ZeroMemory(@EngineTime, SizeOf(EngineTime));
  EngineTime.StartTicks:=getTickCount;
  EngineTime.SimFact:=1.0;
  EngineTime.Running:=true;
  EngineTime.GameTime:=12*60; // 12:00 am
  EngineTime.isNight:=false;
end;

procedure UpdateEngineTime;
begin
  with EngineTime do begin
    LastTicks:=CurrentTicks;
    CurrentTicks:=getTickCount-StartTicks;
    Diff:=(CurrentTicks-LastTicks)/1000;

    inc(numFrames);

    FullHour:=False;

    if Running then begin
      SimDiff:=Diff*SimFact;
      SimTicks:=SimTicks+round(SimDiff*1000);
      GameTime:=GameTime+SimDiff;
      while GameTime>=1440 do GameTime:=GameTime-1440;
      if Trunc(GameTime/60)<>LastHour then begin
        FullHour:=True;
        LastHour:=Trunc(GameTime/60);
        isNight:=CheckGameTime(20, 6);
      end;
    end else
      SimDiff:=0;
  end;
end;

function FormatGameTime: string;
var h, min: byte;
begin
  h:=Trunc(EngineTime.GameTime/60);
  min:=Trunc(EngineTime.GameTime-h*60);
  if h<10 then result:='0'+inttostr(h) else result:=inttostr(h);
  if min<10 then result:=result+':0'+inttostr(min) else result:=result+':'+inttostr(min);
end;

{------------------------------------------------------------------------------}
{ TCamera - set, move and rotate the cam and calculate the frustum             }
{------------------------------------------------------------------------------}

constructor TCamera.Create;
// create and set default values (looking north)
begin
  inherited Create;

  Change;
  DoFollow:=false;
  FollowSpeed:=1.0;
  //DistFact:=2.0;
  FInterior:=0;

  StreamingEnabled:=true;
  FrustCullEnabled:=true;
  DistCullEnabled :=true;

  Reset;
  FTarget:=nil;
end;

procedure TCamera.Reset;
begin
  FPos := MakeAffineVector([0, -2000, 100]);
  FDir := MakeAffineVector([0,1,0]);
  DistFact := 2.0;
  FOV := 45.0;
  FocusInst := nil;

  Change;
end;

procedure TCamera.Change(next: boolean = false);
begin
  FChanged:=true;
  FChangedNext:=next;
end;

procedure TCamera.Continue;
begin
  FChanged:=FChangedNext;
  FChangedNext:=false;
end;

procedure TCamera.LoadPos(i: integer);
begin
  if (i<0) or (i>9) then exit;
  if not (CompareMem(@PosArray[i].pos, @NullVector, 12) or CompareMem(@PosArray[i].dir, @NullVector, 12)) then begin
    FPos:=PosArray[i].pos;
    FDir:=PosArray[i].dir;
    VectorNormalize(FDir);
    Change;
  end;
end;

procedure TCamera.SavePos(i: integer);
begin
  if (i<0) or (i>9) then exit;
  PosArray[i].pos:=FPos;
  PosArray[i].dir:=FDir;
end;

procedure TCamera.Update(dt: single);
// update & apply camera and calculate frustum
begin
  DoFollow:=DoFollow and Assigned(FTarget);
  if DoFollow then begin
    FDir:=VectorAffineSubtract(FTarget^, FPos);
    //FDir:=VectorAffineLerp(FDir, VectorAffineSubtract(FTarget^, FPos), 0.5);
    VectorNormalize(FDir);
    Move(dt*FollowSpeed);
  end;

  gluLookAt(FPos[0], FPos[1], FPos[2], FPos[0]+FDir[0], FPos[1]+FDir[1], FPos[2]+FDir[2], 0,0,1);

  if FChanged then CalcFrustum;
end;

procedure TCamera.SetCam(Position: TVector3F);
// sets position, direction remains unchanged
begin
  FPos:=Position;
  Change;
end;

procedure TCamera.SetCam(Position, Target: TVector3F);
// sets position and calculates direction from target pos
begin
  FPos:=Position;
  FDir:=VectorAffineSubtract(Target, Position);
  VectorNormalize(FDir);
  Change;
end;

procedure TCamera.SetCam(Position: TVector3F; Angle, Height: Single);
// sets position and calculates direction from given angles
begin
  FPos:=Position;
  SetCam(Angle, Height);
end;

procedure TCamera.SetCam(Angle, Height: Single);
// calculates direction from given angles
var sin_a, cos_a, sin_h, cos_h: extended;
begin
  if Height>MAX_HEIGHT_ANGLE then Height:=MAX_HEIGHT_ANGLE else
    if Height<-MAX_HEIGHT_ANGLE then Height:=-MAX_HEIGHT_ANGLE;

  sincos(Angle, sin_a, cos_a);
  sincos(Height, sin_h, cos_h);

  FDir[0] := cos_a * cos_h;
  FDir[1] := sin_a * cos_h;
  FDir[2] := sin_h;

  Change;
end;

procedure TCamera.Move(dPosition: TVector3F);
// moves position, direction remains unchanged
begin
  FPos:=VectorAffineAdd(FPos, dPosition);
  Change;
end;

procedure TCamera.Move(dist: single; strafe: boolean = false);
// moves the camera in current direction (or orthogonal) from the given distance
var v: TVector3F;
begin
  if strafe then begin
    v[0] := FDir[1];
    v[1] := -FDir[0];
    v[2] := 0;
    VectorNormalize(v);
    FPos[0] := FPos[0] + dist*v[0];
    FPos[1] := FPos[1] + dist*v[1];
  end else begin
    FPos[0] := FPos[0] + dist*FDir[0];
    FPos[1] := FPos[1] + dist*FDir[1];
    FPos[2] := FPos[2] + dist*FDir[2];
  end;

  Change;
end;

procedure TCamera.Rotate(dAngle, dHeight: Single);
// rotates direction from given angles
var Angle, Height, len: extended;
begin
  if (dAngle=0) and (dHeight=0) then exit;

  len := sqrt(FDir[0]*FDir[0] + FDir[1]*FDir[1]);

  Height := arccos(len) * (2*ord(FDir[2]>=0)-1) + dHeight; // height angle
  Angle := arctan2(FDir[1]/len, FDir[0]/len) - dAngle; // angle on xy plane

  SetCam(Angle, Height);
end;

{procedure TCamera.Rotate(dDirection: TVector3F);
// rotates the direction vector
begin
  //...
  Changed:=true;
end;}

procedure TCamera.Follow(Target: PAffineFltVector; Speed: single = 1.0);
// sets up a target to follow
begin
  if Assigned(Target) then begin
    FTarget:=Target;
    FollowSpeed:=Speed;
    DoFollow:=true;
  end else DoFollow:=false;

  Change;
end;

procedure TCamera.FollowEnex(enex: PEnex);
begin
  EnexTime:=EngineTime.CurrentTicks;
  if FInterior=0 then FEnexReturn:=FPos;
  FInterior:=enex.Interior;
  SetCam(enex.Target);
end;

procedure TCamera.LeaveInterior;
begin
  if FInterior<>0 then begin
    EnexTime:=EngineTime.CurrentTicks;
    FInterior:=0;
    SetCam(FEnexReturn);
  end;
end;


procedure TCamera.CalcFrustum;

  procedure NormalizePlane(var p: TVector4F);
  var mag: Single;
  begin
    mag := Sqrt(p[0]*p[0] + p[1]*p[1] + p[2]*p[2]);
    p[0] := p[0]/mag;
    p[1] := p[1]/mag;
    p[2] := p[2]/mag;
    p[3] := p[3]/mag;
  end;

var
  ProjMat, ModMat, ClipMat: TMatrix4F;
begin
  glGetFloatv(GL_PROJECTION_MATRIX, @ProjMat);     //  00 01 02 03
  glGetFloatv(GL_MODELVIEW_MATRIX, @ModMat);       //  04 05 06 07
                                                   //  08 09 10 11
  ClipMat:=MatrixMultiply(ModMat, ProjMat);        //  12 13 14 15

  // right plane
  frustum[0][0] := ClipMat[0,3] - ClipMat[0,0];
	frustum[0][1] := ClipMat[1,3] - ClipMat[1,0];
	frustum[0][2] := ClipMat[2,3] - ClipMat[2,0];
	frustum[0][3] := ClipMat[3,3] - ClipMat[3,0];
  NormalizePlane(frustum[0]);

  // left plane
  frustum[1][0] := ClipMat[0,3] + ClipMat[0,0];
	frustum[1][1] := ClipMat[1,3] + ClipMat[1,0];
	frustum[1][2] := ClipMat[2,3] + ClipMat[2,0];
	frustum[1][3] := ClipMat[3,3] + ClipMat[3,0];
  NormalizePlane(frustum[1]);

  // bottom plane
  frustum[2][0] := ClipMat[0,3] + ClipMat[0,1];
	frustum[2][1] := ClipMat[1,3] + ClipMat[1,1];
	frustum[2][2] := ClipMat[2,3] + ClipMat[2,1];
	frustum[2][3] := ClipMat[3,3] + ClipMat[3,1];
  NormalizePlane(frustum[2]);

  // top plane
  frustum[3][0] := ClipMat[0,3] - ClipMat[0,1];
	frustum[3][1] := ClipMat[1,3] - ClipMat[1,1];
	frustum[3][2] := ClipMat[2,3] - ClipMat[2,1];
	frustum[3][3] := ClipMat[3,3] - ClipMat[3,1];
  NormalizePlane(frustum[3]);

  // far plane
  frustum[4][0] := ClipMat[0,3] - ClipMat[0,2];
	frustum[4][1] := ClipMat[1,3] - ClipMat[1,2];
	frustum[4][2] := ClipMat[2,3] - ClipMat[2,2];
	frustum[4][3] := ClipMat[3,3] - ClipMat[3,2];
  NormalizePlane(frustum[4]);

  // near plane
  frustum[5][0] := ClipMat[0,3] + ClipMat[0,2];
	frustum[5][1] := ClipMat[1,3] + ClipMat[1,2];
	frustum[5][2] := ClipMat[2,3] + ClipMat[2,2];
	frustum[5][3] := ClipMat[3,3] + ClipMat[3,2];
  NormalizePlane(frustum[5]);
end;

function TCamera.GetDist(p: TVector3F): single;
begin
  p:=VectorAffineSubtract(p, FPos);
  result:=VectorLength(p);
end;

function TCamera.isSphereInFrustum(p: TVector3F; r: single): boolean;
// true if inside or intersecting, false if outside
var
  i: integer;
  dist: single;
begin
  result:=false;
  for i:=0 to 5 do begin
    dist := p[0]*frustum[i,0] + p[1]*frustum[i,1] + p[2]*frustum[i,2] + frustum[i,3];
    if dist < -r then exit; // outside
  end;
  result:=true; // inside
end;

function TCamera.isSphereInFrustumExt(p: TVector3F; r: single): integer;
// -1 if outside, 0 if intersecting, 1 if inside
var
  i: integer;
  dist: single;
begin
  result:=-1;
  for i:=0 to 5 do begin
    dist := p[0]*frustum[i,0] + p[1]*frustum[i,1] + p[2]*frustum[i,2] + frustum[i,3];
    if dist < -r then exit else // outside
    if abs(dist) < r then begin result:=0; exit; end; // intersecting
  end;
  result:=1; // inside
end;

function TCamera.isVisible(inst: PItemInstance; CheckFocus: boolean; GameType: TGameType): PItemInstance;
// calculates, if the instance (or its LOD) is visible and/or must be loaded

  procedure RequestItem(def: PItemDefinition);
  begin
    def.isUsed:=true;
    if Assigned(def.Model)   then def.Model.isNeeded:=true;
    if Assigned(def.TexDict) then def.TexDict.isNeeded:=true;
    if Assigned(def.Anim)    then def.Anim.isNeeded:=true;
  end;

  function isItemAvailable(def: PItemDefinition): boolean;
  begin
    result := def.isChecked
      and (not Assigned(def.Model)   or def.Model.isLoaded)
      and (not Assigned(def.TexDict) or def.TexDict.isLoaded)
      and (not Assigned(def.Anim)    or def.Anim.isLoaded);
    if not result then begin
      RequestItem(def);
      Change(true);
    end;
  end;

var
  sphere_pos, v: TVector3F;
  need, vis: boolean;
  dist, f: single;
begin
  result:=nil;
  vis := false;

  if inst.def.isLOD or not inst.def.HasBounds
  //or (inst.def.ID<>17384)
  or (inst.def.Timed and not CheckGameTime(inst.def.t_on, inst.def.t_off))
  or (not Opt.ShowInterior xor ((byte(inst.Interior)=FInterior) or (FInterior = 0) and (byte(inst.Interior) = 13)))
  then exit;


  {if Opt.Test then
    sphere_pos:=VectorAffineAdd(inst.Pos, RotateVector(inst.def.Sphere.p, inst.RotAngle, inst.RotAxis))
  else}
    sphere_pos:=VectorAffineAdd(inst.Pos, inst.def.Sphere.p);
  inst.CurrDist:=GetDist(Sphere_Pos);
  dist:=inst.CurrDist-inst.def.Sphere.r;

  // objects to be rendered
  if isSphereInFrustum(sphere_pos, inst.def.Sphere.r) then begin
    f:=inst.CurrDist;
    result := inst;
    if DistCullEnabled then begin
      if Opt.DrawLODs then
        while Assigned(result) and ((dist>result.def.Dist*DistFact) or (Assigned(result.ParentLOD) and not isItemAvailable(result.def))) do result:=result.ParentLOD
      else if (dist>result.def.Dist*DistFact) then
        result:=nil;
      if Assigned(result) then begin
        result.CurrDist:=f;
        vis:=true;
      end;
    end else vis:=true;
    if vis then begin
      if result.LastFrame=EngineTime.numFrames then begin
        //OutputDebugString(PChar('Shared: #'+inttostr(result.def.ID)+' '+result.def.modelname));
        result:=nil;
        vis:=false;
      end else
        result.LastFrame:=EngineTime.numFrames;
    end;
  end;

  // objects to be loaded
  need := {not StreamingEnabled or} vis or (dist<=100);

  if CheckFocus then begin
    if vis then begin
      f:=VectorAffineDotProduct(FDir, VectorAffineSubtract(sphere_pos, FPos));
      v:=FDir;
      VectorScale(v, f);
      v:=VectorAffineSubtract(VectorAffineAdd(FPos, v), sphere_pos);
      f:=VectorLength(v)-inst.def.Sphere.r;

      //if (dist>0) and (f<0) then
        if not Assigned(FocusInst) or (dist>0) and (f<0) and (FocusInst.CurrDist>Result.CurrDist) then
          FocusInst:=result;
    end;
  end else FocusInst:=nil;

  //result:=vis;

  if need then begin
    if Assigned(result) then inst:=result;
    RequestItem(inst.def);
  end;
end;


end.
 