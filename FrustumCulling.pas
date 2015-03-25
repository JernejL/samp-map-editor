unit FrustumCulling;

// © 2004 by Steve M.

interface

uses
 SysUtils, OpenGL12, Geometry, VectorTypes;

type
  TFrustum = class
  private
    Planes: array[0..5] of TVector4f;
    procedure NormalizePlane(Plane: Integer);
  public
    function IsPointWithin(const p: TVector3f): Boolean;
    function IsSphereWithin(const p: TVector3f; const r: Single): Boolean;
    function IsBoxWithin(const p, dim: TVector3f): Boolean;
    procedure Calculate;
  end;

var
  Frustum: TFrustum;

implementation

const
  Right  = 0;
  Left   = 1;
  Bottom = 2;
  Top    = 3;
  Back   = 4;
  Front  = 5;
  A      = 0;
  B      = 1;
  C      = 2;
  D      = 3;

procedure TFrustum.NormalizePlane(Plane: Integer);
var
  Magnitude: Single;
begin
  Magnitude := Sqrt(Sqr(Planes[Plane][A])+Sqr(Planes[Plane][B])+Sqr(Planes[Plane][C]));
  Planes[Plane][A] := Planes[Plane][A]/Magnitude;
  Planes[Plane][B] := Planes[Plane][B]/Magnitude;
  Planes[Plane][C] := Planes[Plane][C]/Magnitude;
  Planes[Plane][D] := Planes[Plane][D]/Magnitude;
end;

procedure TFrustum.Calculate;
var
 ProjM, ModM, Clip: array[0..15] of Single;
begin
  glGetFloatv(GL_PROJECTION_MATRIX, @ProjM);
  glGetFloatv(GL_MODELVIEW_MATRIX, @ModM);
  // multiply projection and modelview matrix
  Clip[ 0] := ModM[ 0]*ProjM[ 0] + ModM[ 1]*ProjM[ 4] + ModM[ 2]*ProjM[ 8] + ModM[ 3]*ProjM[12];
  Clip[ 1] := ModM[ 0]*ProjM[ 1] + ModM[ 1]*ProjM[ 5] + ModM[ 2]*ProjM[ 9] + ModM[ 3]*ProjM[13];
  Clip[ 2] := ModM[ 0]*ProjM[ 2] + ModM[ 1]*ProjM[ 6] + ModM[ 2]*ProjM[10] + ModM[ 3]*ProjM[14];
  Clip[ 3] := ModM[ 0]*ProjM[ 3] + ModM[ 1]*ProjM[ 7] + ModM[ 2]*ProjM[11] + ModM[ 3]*ProjM[15];
  Clip[ 4] := ModM[ 4]*ProjM[ 0] + ModM[ 5]*ProjM[ 4] + ModM[ 6]*ProjM[ 8] + ModM[ 7]*ProjM[12];
  Clip[ 5] := ModM[ 4]*ProjM[ 1] + ModM[ 5]*ProjM[ 5] + ModM[ 6]*ProjM[ 9] + ModM[ 7]*ProjM[13];
  Clip[ 6] := ModM[ 4]*ProjM[ 2] + ModM[ 5]*ProjM[ 6] + ModM[ 6]*ProjM[10] + ModM[ 7]*ProjM[14];
  Clip[ 7] := ModM[ 4]*ProjM[ 3] + ModM[ 5]*ProjM[ 7] + ModM[ 6]*ProjM[11] + ModM[ 7]*ProjM[15];
  Clip[ 8] := ModM[ 8]*ProjM[ 0] + ModM[ 9]*ProjM[ 4] + ModM[10]*ProjM[ 8] + ModM[11]*ProjM[12];
  Clip[ 9] := ModM[ 8]*ProjM[ 1] + ModM[ 9]*ProjM[ 5] + ModM[10]*ProjM[ 9] + ModM[11]*ProjM[13];
  Clip[10] := ModM[ 8]*ProjM[ 2] + ModM[ 9]*ProjM[ 6] + ModM[10]*ProjM[10] + ModM[11]*ProjM[14];
  Clip[11] := ModM[ 8]*ProjM[ 3] + ModM[ 9]*ProjM[ 7] + ModM[10]*ProjM[11] + ModM[11]*ProjM[15];
  Clip[12] := ModM[12]*ProjM[ 0] + ModM[13]*ProjM[ 4] + ModM[14]*ProjM[ 8] + ModM[15]*ProjM[12];
  Clip[13] := ModM[12]*ProjM[ 1] + ModM[13]*ProjM[ 5] + ModM[14]*ProjM[ 9] + ModM[15]*ProjM[13];
  Clip[14] := ModM[12]*ProjM[ 2] + ModM[13]*ProjM[ 6] + ModM[14]*ProjM[10] + ModM[15]*ProjM[14];
  Clip[15] := ModM[12]*ProjM[ 3] + ModM[13]*ProjM[ 7] + ModM[14]*ProjM[11] + ModM[15]*ProjM[15];
  //Clip:=MatrixMultiply(ModM, ProjM);

  // extract frustum planes from clipping matrix
  Planes[Right][A] := clip[ 3] - clip[ 0];
  Planes[Right][B] := clip[ 7] - clip[ 4];
  Planes[Right][C] := clip[11] - clip[ 8];
  Planes[Right][D] := clip[15] - clip[12];
  NormalizePlane(Right);

  Planes[Left][A] := clip[ 3] + clip[ 0];
  Planes[Left][B] := clip[ 7] + clip[ 4];
  Planes[Left][C] := clip[11] + clip[ 8];
  Planes[Left][D] := clip[15] + clip[12];
  NormalizePlane(Left);

  Planes[Bottom][A] := clip[ 3] + clip[ 1];
  Planes[Bottom][B] := clip[ 7] + clip[ 5];
  Planes[Bottom][C] := clip[11] + clip[ 9];
  Planes[Bottom][D] := clip[15] + clip[13];
  NormalizePlane(Bottom);

  Planes[Top][A] := clip[ 3] - clip[ 1];
  Planes[Top][B] := clip[ 7] - clip[ 5];
  Planes[Top][C] := clip[11] - clip[ 9];
  Planes[Top][D] := clip[15] - clip[13];
  NormalizePlane(Top);

  Planes[Back][A] := clip[ 3] - clip[ 2];
  Planes[Back][B] := clip[ 7] - clip[ 6];
  Planes[Back][C] := clip[11] - clip[10];
  Planes[Back][D] := clip[15] - clip[14];
  NormalizePlane(Back);

  Planes[Front][A] := clip[ 3] + clip[ 2];
  Planes[Front][B] := clip[ 7] + clip[ 6];
  Planes[Front][C] := clip[11] + clip[10];
  Planes[Front][D] := clip[15] + clip[14];
  NormalizePlane(Front);
end;

function TFrustum.IsPointWithin(const p: TVector3f): Boolean;
var
  i : Integer;
begin
  Result:=true;
  for i:=0 to 5 do
    if (Planes[i][A]*p[A] + Planes[i][B]*p[B] + Planes[i][C]*p[C] + Planes[i][D]) <= 0 then begin
      Result:=False;
      exit;
    end;
end;

function TFrustum.IsSphereWithin(const p: TVector3f; const r: Single): Boolean;
var
  i : Integer;
begin
  Result:=true;
  for i:=0 to 5 do
    if (Planes[i][A]*p[A] + Planes[i][B]*p[B] + Planes[i][C]*p[C] + Planes[i][D]) <= -r then begin
      Result:=False;
      exit;
    end;
end;

function TFrustum.IsBoxWithin(const p, dim: TVector3f): Boolean;
// p: box position - NOTE: z is at bottom!
// dim: box dimensions
var
  i : Integer;
begin
  Result:=true;
  for i:=0 to 5 do begin
    if (Planes[i][A]*(p[A]-dim[A]/2) + Planes[i][B]*(p[B]-dim[B]/2) + Planes[i][C]*(p[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]-dim[A]/2) + Planes[i][B]*(p[B]+dim[B]/2) + Planes[i][C]*(p[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]-dim[A]/2) + Planes[i][B]*(p[B]+dim[B]/2) + Planes[i][C]*(p[C]+dim[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]-dim[A]/2) + Planes[i][B]*(p[B]-dim[B]/2) + Planes[i][C]*(p[C]+dim[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]+dim[A]/2) + Planes[i][B]*(p[B]-dim[B]/2) + Planes[i][C]*(p[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]+dim[A]/2) + Planes[i][B]*(p[B]+dim[B]/2) + Planes[i][C]*(p[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]+dim[A]/2) + Planes[i][B]*(p[B]+dim[B]/2) + Planes[i][C]*(p[C]+dim[C]) + Planes[i][D]) > 0 then continue;
    if (Planes[i][A]*(p[A]+dim[A]/2) + Planes[i][B]*(p[B]-dim[B]/2) + Planes[i][C]*(p[C]+dim[C]) + Planes[i][D]) > 0 then continue;
    Result := False;
  end;
end;

initialization

  Frustum:=TFrustum.Create;

finalization

  Frustum.Free;

end.
