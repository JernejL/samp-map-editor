{: VectorTypes unit.<p>

   Defines base vector types for use in Geometry.pas and OpenGL12.pas.<p>

   The sole aim of this unit is to limit dependency between the Geometry
   and OpenGL12 units by introducing the base compatibility types
   (and only the *base* types).<p>

   Conventions:<ul>
      <li><b>i</b> is used for 32 bits signed integers
      <li><b>f</b> is used for Single precision floating points values (32 bits)
      <li><b>d</b> is used for Double precision floating points values (64 bits)
   </ul>

   Note : D3D types untested.<p>

	<b>Historique : </b><font size=-1><ul>
      <li>04/07/01 - EG - Creation
   </ul>
}
unit VectorTypes;

interface

type

   TVector3i = array [0..2] of Longint;
   TVector3f = array [0..2] of Single;
   TVector3d = array [0..2] of Double;

   TVector4i = array [0..3] of Longint;
   TVector4f = array [0..3] of Single;
   TVector4d = array [0..3] of Double;

   TMatrix3i = array [0..2] of TVector3i;
   TMatrix3f = array [0..2] of TVector3f;
   TMatrix3d = array [0..2] of TVector3d;

   TMatrix4i = array [0..3] of TVector4i;
   TMatrix4f = array [0..3] of TVector4f;
   TMatrix4d = array [0..3] of TVector4d;

   TD3DVector = packed record
      case Integer of
         0 : ( x : Single;
               y : Single;
               z : Single);
         1 : ( v : TVector3f);
   end;

   TD3DMatrix = packed record
      case Integer of
         0 : (_11, _12, _13, _14: Single;
              _21, _22, _23, _24: Single;
              _31, _32, _33, _34: Single;
              _41, _42, _43, _44: Single);
         1 : (m : TMatrix4f);
   end;

implementation

   // nothing implemented in this unit

end.
 
