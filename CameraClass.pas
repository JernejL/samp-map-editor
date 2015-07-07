unit CameraClass;

interface

  Uses OpenGL, vectortypes, Windows, math;

  type TCamera = Object
    Position : TVector3f;      // The camera's position
    View     : TVector3f;      // The camera's View
	UpVector : TVector3f;      // The camera's UpVector

	fovy, aspect, zNear, zFar: double;
	
	public
	Constructor Create;
	
    procedure PositionCamera(positionX, positionY, positionZ : glFloat;
			     viewX, viewY, viewZ : glFloat;
			     upVectorX, upVectorY, upVectorZ : glFloat);
    procedure RotateView(const X, Y, Z : glFloat);
    procedure MoveCameraByMouse();
    procedure RotateAroundPoint(const Center : TVector3f; const X, Y, Z : glFloat);
    procedure StrafeCamera(speed : glFloat);
    procedure MoveCamera(speed : glFloat);
    function getheading(): single;
  end;

var
  thispanel: hwnd;

  const
    Fradtodeg = 57.29577951308232286465; // Radians to Degrees

implementation


{ TCamera }


{------------------------------------------------------------------------}
{--- This function sets the camera's position and view and up vVector ---}
{------------------------------------------------------------------------}
procedure TCamera.PositionCamera(positionX, positionY, positionZ, viewX,
  viewY, viewZ, upVectorX, upVectorY, upVectorZ: glFloat);
begin
  Position[0] := PositionX;
  Position[2] := PositionY;
  Position[1] := PositionZ;

  View[0]     := ViewX;
  View[2]     := ViewY;
  View[1]     := ViewZ;

  UpVector[0] := UpVectorX;
  UpVector[2] := UpVectorY;
  UpVector[1] := UpVectorZ;
end;


{-----------------------------------------------------------------------------}
{--- This will move the camera forward or backward depending on the speed  ---}
{-----------------------------------------------------------------------------}
procedure TCamera.MoveCamera(speed: glFloat);
var V : TVector3f;
begin
  // Get our view vVector (The direciton we are facing)
  V[0] := View[0] - Position[0];              // This gets the direction of the X
  V[2] := View[2] - Position[2];              // This gets the direction of the Y
  V[1] := View[1] - Position[1];              // This gets the direction of the Z

  Position[0] := Position[0] + V[0] * speed;  // Add our acceleration to our position's X
  Position[2] := Position[2] + V[2] * speed;  // Add our acceleration to our position's Y
  Position[1] := Position[1] + V[1] * speed;  // Add our acceleration to our position's Z
  View[0] := View[0] + V[0] * speed;          // Add our acceleration to our view's X
  View[2] := View[2] + V[2] * speed;          // Add our acceleration to our view's Y
  View[1] := View[1] + V[1] * speed;          // Add our acceleration to our view's Z
end;

{-----------------------------------------------------------}
{--- The mouse look function. Use mouse to look around   ---}
{-----------------------------------------------------------}
procedure TCamera.MoveCameraByMouse;
var mousePos : TPoint;
    middleX, middleY : Integer;
    deltaY, rotateY : glFloat;
    rect: Trect;
begin
  GetWindowRect(thispanel, rect);

  middleX := rect.Left + ((rect.right - rect.left) div 2);
  middleY := rect.top + ((rect.bottom - rect.top) div 2);

  // Get the mouse's current X,Y position
  GetCursorPos(mousePos);

  // If our cursor is still in the middle, we never moved... so don't update the screen
  if (mousePos.x = middleX) AND (mousePos.y = middleY) then
    exit;

  // Set the mouse position to the middle of our window
  SetCursorPos(middleX, middleY);

  // Get the direction the mouse moved in, but bring the number down to a reasonable amount
  rotateY := (middleX - mousePos.x)/500;
  deltaY  := (middleY - mousePos.y)/1000;

  // Multiply the direction vVector for Y by an acceleration (The higher the faster is goes).
  View[2] := View[2] + deltaY*5;

  // Check if the distance of our view exceeds 60 from our position, if so, stop it. (UP)
  if View[2] - Position[2] > 10 then
     View[2] := Position[2] + 10;

  // Check if the distance of our view exceeds -60 from our position, if so, stop it. (DOWN)
  if View[2] - Position[2] < -10 then
     View[2] := Position[2] - 10;

  // Here we rotate the view along the X avis depending on the direction (Left of Right)
  RotateView(0, rotateY, 0);
end;




{---------------------------------------------------------------------}
{--- This strafes the camera left and right depending on the speed ---}
{---------------------------------------------------------------------}
procedure TCamera.StrafeCamera(speed: glFloat);
var Cross, ViewVector : TVector3f;
begin
  // Initialize a variable for the cross product result
  Cross[0] :=0;
  Cross[2] :=0;
  Cross[1] :=0;

  // Get the view vVector of our camera and store it in a local variable
  ViewVector[0] := View[0] - Position[0];
  ViewVector[2] := View[2] - Position[2];
  ViewVector[1] := View[1] - Position[1];

  // Calculate the cross product of our up vVector and view vVector
  Cross[0] := (UpVector[2] * ViewVector[1]) - (UpVector[1] * ViewVector[2]);   // (V1[2] * V2[1]) - (V1[1] * V2[2])
  Cross[2] := (UpVector[1] * ViewVector[0]) - (UpVector[0] * ViewVector[1]);   // (V1[1] * V2[0]) - (V1[0] * V2[1])
  Cross[1] := (UpVector[0] * ViewVector[2]) - (UpVector[2] * ViewVector[0]);   // (V1[0] * V2[2]) - (V1[2] * V2[0])

  // Add the resultant vVector to our position
  Position[0] := Position[0] + Cross[0] * speed;
  Position[1] := Position[1] + Cross[1] * speed;

  // Add the resultant vVector to our view
  View[0] := View[0] + Cross[0] * speed;
  View[1] := View[1] + Cross[1] * speed;
end;


{-----------------------------------------------------------}
{--- This rotates the view around the position           ---}
{-----------------------------------------------------------}
procedure TCamera.RotateView(const X, Y, Z: glFloat);
var vVector : TVector3f;
begin
  // Get our view vVector (The direction we are facing)
  vVector[0] := View[0] - Position[0];          // This gets the direction of the X
  vVector[2] := View[2] - Position[2];          // This gets the direction of the Y
  vVector[1] := View[1] - Position[1];          // This gets the direction of the Z

  // If we pass in a negative X Y or Z, it will rotate the opposite way,
  // so we only need one function for a left and right, up or down rotation.
  if X <> 0 then
  begin
    View[1] := Position[1] + sin(X)*vVector[2] + cos(X)*vVector[1];
    View[2] := Position[2] + cos(X)*vVector[2] - sin(X)*vVector[1];
  end;

  if Y <> 0 then
  begin
    View[1] := Position[1] + sin(Y)*vVector[0] + cos(Y)*vVector[1];
    View[0] := Position[0] + cos(Y)*vVector[0] - sin(Y)*vVector[1];
  end;

  if Z <> 0 then
  begin
    View[0] := Position[0] + sin(Z)*vVector[2] + cos(Z)*vVector[0];
    View[2] := Position[2] + cos(Z)*vVector[2] - sin(Z)*vVector[0]
  end;
end;


{-------------------------------------------------------------}
{--- This rotates the camera position around a given point ---}
{-------------------------------------------------------------}
procedure TCamera.RotateAroundPoint(const Center: TVector3f; const X, Y, Z: glFloat);
var viewVector : TVector3f;
begin
  // Get the viewVector from our position to the center we are rotating around
  viewVector[0] := Position[0] - Center[0];          // This gets the direction of the X
  viewVector[2] := Position[2] - Center[2];          // This gets the direction of the Y
  viewVector[1] := Position[1] - Center[1];          // This gets the direction of the Z

  // Rotate the position up or down, then add it to the center point
  if X <> 0 then
  begin
    Position[1] := Center[1] + sin(X)*viewVector[2] + cos(X)*viewVector[1];
    Position[2] := Center[2] + cos(X)*viewVector[2] - sin(X)*viewVector[1];
  end;

  if Y <> 0 then
  begin
    Position[1] := Center[1] + sin(Y)*viewVector[0] + cos(Y)*viewVector[1];
    Position[0] := Center[0] + cos(Y)*viewVector[0] - sin(Y)*viewVector[1];
  end;

  if Z <> 0 then
  begin
    Position[0] := Center[0] + sin(Z)*viewVector[2] + cos(Z)*viewVector[0];
    Position[2] := Center[2] + cos(Z)*viewVector[2] - sin(Z)*viewVector[0]
  end;
end;

function vectordirection(const v1: TVector3f): single;
begin
  if ((v1[0] = 0) and (v1[1] < 0)) then
    Result := 270
  else
  if ((v1[0] = 0) and (v1[1] > 0)) then
    Result := 90
  else
  if ((v1[0] > 0) and (v1[1] >= 0)) then
    Result := (ArcTan(v1[1] / v1[0]) * fradtodeg)
  else
  if ((v1[0] < 0) and (v1[1] > 0)) then
    Result := 180 - (ArcTan(v1[1] / Abs(v1[0])) * fradtodeg)
  else
  if ((v1[0] < 0) and (v1[1] <= 0)) then
    Result := 180 + (ArcTan(v1[1] / v1[0]) * fradtodeg)
  else
  if ((v1[0] > 0) and (v1[1] < 0)) then
    Result := 360 - (ArcTan(Abs(v1[1]) / v1[0]) * fradtodeg)
  else
    Result := 0;
end;

function TCamera.getheading: single;
var
  tmp: TVector3f;
begin
  tmp[0] := view[0] - position[0];
  tmp[1] := view[1] - position[1];
  tmp[2] := view[2] - position[2];

  Result := degtorad(vectordirection(tmp));
  
{if ((tmp.x = 0) and (tmp.y <  0)) then Result:= 270 else
if ((tmp.x = 0) and (tmp.y >  0)) then Result:= 90 else
if ((tmp.x > 0) and (tmp.y >= 0)) then Result:=       (ArcTan(tmp.y      / tmp.x)      * fradtodeg) else
if ((tmp.x < 0) And (tmp.y >  0)) then Result:= 180 - (ArcTan(tmp.y      / Abs(tmp.x)) * fradtodeg) else
if ((tmp.x < 0) And (tmp.y <= 0)) then Result:= 180 + (ArcTan(tmp.y      / tmp.x)      * fradtodeg) else
if ((tmp.x > 0) and (tmp.y <  0)) then Result:= 360 - (ArcTan(Abs(tmp.y) / tmp.x)      * fradtodeg) else
Result:=0; }
end;
					
constructor TCamera.Create();
begin

fovy:= 45.0;
//aspect:=
zNear:= 0.2;
zFar:= 10000.0;

end;

end.
