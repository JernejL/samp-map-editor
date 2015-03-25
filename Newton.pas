{ ******************************************************************** }
{ Newton Game dynamics                                                 }
{ copyright 2000-2004                                                  }
{ By Julio Jerez                                                       }
{ VC: 6.0                                                              }
{ One and only header file.                                            }
{ ******************************************************************** }

{ ******************************************************************** }
{ Newton Pascal Header translation                                     }
{ Copyright 2005-2009 Jernej L.                                        }
{ Portions are based on original newton header by S.Spasov(Sury)       }
{ ******************************************************************** }

// Define double to use newton in double precision

{$undef double}
{$i compiler.inc}

unit Newton;

interface

const
  newtondll = 'Newton.dll';
  NEWTON_MAJOR_VERSION = 2;
  NEWTON_MINOR_VERSION = 12;

type

{$ifndef double}
  float = Single;
{$else}
  float = Double;
{$endif}
  Pfloat = ^float;

  Pinteger = ^integer;
  Psmallint = ^smallint;
  size_t = cardinal; // no longer used in Beta 15
  unsigned = longword;

{ Newton objects }
  PNewtonMesh = ^Pointer;
  PNewtonBody = ^Pointer;
	PNewtonWorld = ^Pointer;
  PNewtonJoint = ^Pointer;
// DP 2.0 PNewtonContact = ^Pointer;
  PNewtonMaterial = ^Pointer;
  PNewtonCollision = ^Pointer;
  PNewtonSceneProxy = ^Pointer; // 2.0
// DP 2.0 PNewtonRagDoll = ^Pointer;
// DP 2.0 PNewtonRagDollBone = ^Pointer;

	const SERIALIZE_ID_BOX					    = 0;
	const SERIALIZE_ID_CONE					    = 1;
	const SERIALIZE_ID_SPHERE					  = 2;
	const SERIALIZE_ID_CAPSULE				  = 3;
	const SERIALIZE_ID_CYLINDER				  = 4;
	const SERIALIZE_ID_COMPOUND				  = 5;
	const SERIALIZE_ID_CONVEXHULL				= 6;
	const SERIALIZE_ID_CONVEXMODIFIER		= 7;
	const SERIALIZE_ID_CHAMFERCYLINDER	= 8;
	const SERIALIZE_ID_TREE					    = 9;
	const SERIALIZE_ID_NULL					    = 10;
	const SERIALIZE_ID_HEIGHTFIELD 			= 11;
	const SERIALIZE_ID_USERMESH					= 12;
	const SERIALIZE_ID_SCENE					  = 13;

  type

	NewtonJointRecord = packed record
	  m_attachmenMatrix_0: array[0..3, 0..3] of float;
    m_attachmenMatrix_1: array[0..3, 0..3] of float;
		m_minLinearDof: array[0..2] of float;
		m_minAngularDof: array[0..2] of float;
		m_maxAngularDof: array[0..2] of float;
		m_attachBody_0: Pnewtonbody;
    m_attachBody_1: Pnewtonbody;
		m_extraParameters: array[0..15] of float;
		m_bodiesCollisionOn: integer;
		m_descriptionType: array[0..31] of char;
	end;
  PNewtonJointRecord = ^NewtonJointRecord;

{ Newton records }                            
	NewtonUserMeshCollisionCollideDesc = packed record
		m_boxP0: array[0..3] of float;						// lower bounding box of intersection query in local space
		m_boxP1: array[0..3] of float;						// upper bounding box of intersection query in local space
		m_userData: Pointer;                      // user data passed to the collision geometry at creation time
		m_faceCount: integer;                     // set how many polygons intersect the query box
		m_vertex: Pfloat;                         // the pointer to the vertex array.
		m_vertexStrideInBytes: integer;           // set the size of each vertex
	 	m_userAttribute: Pinteger;                // set the Pointer to the user data, one for each face
		m_faceIndexCount: Pinteger;               // set the Pointer to the vertex count of each face.
		m_faceVertexIndex: Pinteger;              // set the Pointer index array for each vertex on a face.
		m_objBody: PNewtonBody;                   // Pointer to the colliding body
		m_polySoupBody: PNewtonBody;              // Pointer to the rigid body owner of this collision tree
  end;
  PNewtonUserMeshCollisionCollideDesc = ^NewtonUserMeshCollisionCollideDesc;

	NewtonWorldConvexCastReturnInfo = packed record
    m_point: array[0..3] of float;    // collision point in global space
    m_normal: array[0..3] of float;   // surface normal at collision point in global space

		m_normalOnHitPoint: array[0..3] of single; // surface normal at the surface of the hit body,
                                               // is the same as the normal calculated by a ray cast hitting the body at the hit point

		m_penetration: float;             // contact penetration at collision point
		m_contactID: integer;	            // collision ID at contact point
		m_hitBody: PNewtonBody;			      // body hit at contact point
	end;
  PNewtonWorldConvexCastReturnInfo = ^NewtonWorldConvexCastReturnInfo;

	NewtonUserMeshCollisionRayHitDesc = packed record
		m_p0: array[0..3] of float;					   		// ray origin in collision local space
		m_p1: array[0..3] of float;               // ray destination in collision local space
		m_normalOut: array[0..3] of float;	   		// copy here the normal at the rat integerersection
		m_userIdOut: integer;                     // copy here a user defined id for further feedback
		m_userData: Pointer;                      // user data passed to the collision geometry at creation time
	end;
  PNewtonUserMeshCollisionRayHitDesc = ^NewtonUserMeshCollisionRayHitDesc;

	NewtonHingeSliderUpdateDesc = packed record
		m_accel: float;
		m_minFriction: float;
		m_maxFriction: float;
		m_timestep: float;
	end;
  PNewtonHingeSliderUpdateDesc = ^NewtonHingeSliderUpdateDesc;

  // NewtonCollisionInfoRecord

  TNewtonBoxParam = packed record
			m_x,
			m_y,
			m_z: float;
  end;

	TNewtonSphereParam = packed record
			m_r0,
			m_r1,
			m_r2: single;
  end;

  TNewtonCylinderParam = packed record
		m_r0,
		m_r1,
    m_height: single;
  end;

  TNewtonCapsuleParam = packed record
		m_r0,
		m_r1,
    m_height: single;
  end;

  TNewtonConeParam = packed record
		m_r,
		m_height: single;
  end;

	TNewtonChamferCylinderParam = packed record
			m_r,
			m_height: single;
  end;

  TNewtonCollisionTreeParam = packed record
    m_vertexCount,
    m_indexCount: integer;
    // if you want trimesh geometry data, use NewtonTreeCollisionGetVertexListIndexListInAABB.
  end;

  TNewtonCollisionNullParam = packed record
    // nothing.
  end;

  TNewtonConvexHullModifierParam = packed record
	  m_chidren: PNewtonCollision;
  end;

  TNewtonCompoundCollisionParam = packed record
	  m_chidrenCount: integer;
    m_chidren: pointer; // pointer to array of pnewtoncollisions
  end;

  TNewtonConvexHullParam = packed record
     m_vertexCount,
     m_vertexStrideInBytes,
     m_faceCount: integer;
     m_vertex: Pfloat;
  end;

  TNewtonHeightFieldCollisionParam = packed record
			m_width,
			m_height,
			m_gridsDiagonals: integer;
			m_horizonalScale,
			m_verticalScale: single;
			m_elevation: pointer; //unsigned short *m_elevation;
			m_atributes: pchar;
  end;

  TNewtonSceneCollisionParam = packed record
      m_childrenProxyCount: integer;
  end;

	TNewtonCollisionInfoRecord = packed record
    m_offsetMatrix: array[0..3,0..3] of single;
		m_collisionType,                 // tag id to identify the collision primitive
		m_referenceCount: integer;       // the current reference count for this collision
    m_collisionUserID: integer;
  Case integer of
       SERIALIZE_ID_BOX :
         (shapedatabox: TNewtonBoxParam );
       SERIALIZE_ID_CONE :
         (shapedata: TNewtonConeParam );
	     SERIALIZE_ID_SPHERE :
         (shapedatasphere: TNewtonSphereParam );
	     SERIALIZE_ID_CAPSULE :
         (shapedatacapsule: TNewtonCapsuleParam );
	     SERIALIZE_ID_CYLINDER :
         (shapedatacylinder: TNewtonCylinderParam );
       SERIALIZE_ID_COMPOUND :
         (shapedatacompound: TNewtonCompoundCollisionParam );
	     SERIALIZE_ID_CONVEXHULL :
         (shapedataconvexhull: TNewtonConvexHullParam);
	     SERIALIZE_ID_CONVEXMODIFIER :
         (shapedataxonvexhull: TNewtonConvexHullModifierParam );
	     SERIALIZE_ID_CHAMFERCYLINDER :
         (shapedatachamfercylinder: TNewtonChamferCylinderParam );
	     SERIALIZE_ID_TREE :
         (shapedatatree: TNewtonCollisionTreeParam );
	     SERIALIZE_ID_NULL :
         (shapedatanull: TNewtonCollisionNullParam );
	     SERIALIZE_ID_HEIGHTFIELD :
         (shapedataheightfield: TNewtonHeightFieldCollisionParam );
       SERIALIZE_ID_USERMESH :
         (m_paramArray: array[0..63] of float);
	     SERIALIZE_ID_SCENE :
         (shapedatascenecollision: TNewtonSceneCollisionParam);
  end;

  PNewtonCollisionInfoRecord = ^TNewtonCollisionInfoRecord;

	// Newton callback functions
  NewtonAllocMemory = procedure (sizeInBytes: integer ); cdecl;
  PNewtonAllocMemory = ^NewtonAllocMemory;
  PNewtonDestroyWorld = procedure (const NewtonWorld: PnewtonWorld); cdecl; // new 2.04

  NewtonFreeMemory = procedure (const ptr: Pointer; sizeInBytes: integer ); cdecl;
  PNewtonFreeMemory = ^NewtonFreeMemory;

  PNewtonGetTicksCountCallback = function: longword; cdecl;

	PNewtonSerialize = procedure(serializeHandle: Pointer; const buffer: Pointer; size: integer); cdecl;
	PNewtonDeserialize = procedure(serializeHandle: Pointer; buffer: Pointer; size: integer); cdecl;

	PNewtonUserMeshCollisionCollideCallback = procedure(collideDescData: NewtonUserMeshCollisionCollideDesc); cdecl;
	PNewtonUserMeshCollisionRayHitCallback = function(lineDescData: NewtonUserMeshCollisionRayHitDesc): float; cdecl;
	PNewtonUserMeshCollisionDestroyCallback = procedure(descData: Pointer); cdecl;

	PNewtonUserMeshCollisionGetCollisionInfo = procedure(userData: pointer; infoRecord: PNewtonCollisionInfoRecord);
	PNewtonUserMeshCollisionGetFacesInAABB = function(userData: pointer; const p0: Pfloat; p1: Pfloat;
														   const vertexArray: Pfloat; vertexCount: integer; VertexStrideInBytes: integer;
		                                                   const indexList: integer; maxIndexCount: integer; const userDataList: Pinteger): integer;

	PNewtonCollisionTreeRayCastCallback = function (const body: PNewtonBody; const treeCollision: PNewtonCollision; interception: float; normal: Pfloat; faceId: integer; usedData: pointer): float;
	NewtonHeightFieldRayCastCallback = function (const body: PNewtonBody; const heightFieldCollision: PNewtonCollision; interception: single; row, col: integer; normal: Pfloat; faceId: integer; usedData: pointer): float;


  // changed in 2.0
	// collision tree call back (obsoleted no recommended)
	PNewtonTreeCollisionCallback = procedure(const bodyWithTreeCollision: PNewtonBody; const body: PNewtonBody; faceID: integer;
    vertexCount: integer; const vertex: Pfloat; VertexStrideInBytes: integer); cdecl;

	PNewtonBodyDestructor = procedure(const body: PNewtonBody); cdecl;
	PNewtonApplyForceAndTorque = procedure (const body: PNewtonBody; timestep: float; threadindex: integer); cdecl;
	PNewtonSetTransform = procedure (const body: PNewtonBody ; const bmatrix: Pfloat; threadindex: integer); cdecl;

	PNewtonBodyActivationState = procedure (const body: PNewtonBody; state: unsigned); cdecl;

	pNewtonCollisionDestructor = procedure (const NewtonWorld: PnewtonWorld; const collision: PNewtonCollision);
  PNewtonIslandUpdate = function(const NewtonWorld: PnewtonWorld; const islandHandle: pointer; bodyCount: integer): integer;
	PNewtonBodyLeaveWorld = procedure(const body: PNewtonBody; threadindex: integer); cdecl;
  pNewtonDestroyBodyByExeciveForce = procedure(const body: PNewtonBody; const contact: pNewtonJoint );

{
// DP 2.0
	PNewtonSetRagDollTransform = procedure (const bone: PNewtonRagDollBone); cdecl;
}
	PNewtonGetBuoyancyPlane = function(const collisionID: integer; context: Pointer; const globalSpaceMatrix: Pfloat; globalSpacePlane: Pfloat): integer; cdecl;
{
	PNewtonVehicleTireUpdate = procedure(const vehicle: PNewtonJoint; timestep: float); cdecl;
}
	PNewtonWorldRayPrefilterCallback = function (const body: PNewtonBody; const collision: PNewtonCollision; userData: Pointer): longword; cdecl;
	PNewtonWorldRayFilterCallback = function(const body: PNewtonBody; const hitNormal: Pfloat; collisionID: integer; userData: Pointer; integerersetParam: float): float; cdecl;

  // changed in 2.0
  // PNewtonContactBegin -> NewtonOnAABBOverlap
	PNewtonOnAABBOverlap = function (const material: PNewtonMaterial; const body0: PNewtonBody; const body1: PNewtonBody; threadindex: integer): integer; cdecl;
//	typedef int  ( *NewtonOnAABBOverlap) (const NewtonMaterial* material, const NewtonBody* body0, const NewtonBody* body1, int threadIndex);
  // changed in 2.0
	PNewtonContactsProcess = function (const contact: PNewtonJoint; timestep: float; threadindex: integer): integer; cdecl;
  // removed in 2.0
//	PNewtonContactEnd = procedure (const material: PNewtonMaterial; const body0: PNewtonBody; const body1: PNewtonBody; threadindex: integer); cdecl;

  PNewtonBodyIterator = procedure( const body: PNewtonBody; userData: pointer); cdecl;
  PNewtonJointIterator = procedure( const joint: PNewtonJoint; userData: pointer); cdecl;

	PNewtonCollisionIterator = procedure( const userdata: Pointer; vertexCount: integer; const FaceArray: Pfloat; faceId: integer); cdecl;

	PNewtonBallCallBack = procedure (const ball: PNewtonJoint; timestep: float); cdecl;
	PNewtonHingeCallBack = function (const hinge: PNewtonJoint; desc: PNewtonHingeSliderUpdateDesc): unsigned; cdecl;
	PNewtonSliderCallBack = function (const slider: PNewtonJoint; desc: PNewtonHingeSliderUpdateDesc): unsigned; cdecl;
	PNewtonUniversalCallBack = function (const universal: PNewtonJoint; desc: PNewtonHingeSliderUpdateDesc): unsigned; cdecl;
	PNewtonCorkscrewCallBack = function (const corkscrew: PNewtonJoint; desc: PNewtonHingeSliderUpdateDesc): unsigned; cdecl;

	PNewtonUserBilateralCallBack = procedure (const userJoint: PNewtonJoint; timestep: float; threadindex: integer); cdecl;
  PNewtonUserBilateralGetInfoCallBack = procedure (const userJoint: PNewtonJoint; info: PNewtonJointRecord); cdecl;

  PNewtonConstraintDestructor = procedure (const me: PNewtonJoint); cdecl;

	// **********************************************************************************************
	//
	// world control functions
	//
	// **********************************************************************************************

  function NewtonWorldGetVersion(): integer; cdecl; external newtondll;
	function NewtonWorldFloatSize(): integer; cdecl; external newtondll;

	function NewtonGetMemoryUsed (): integer; cdecl; external newtondll;
	procedure NewtonSetMemorySystem (malloc: PNewtonAllocMemory; mfree: PNewtonFreeMemory); cdecl; external newtondll;
	function NewtonCreate (): PNewtonWorld; cdecl; external newtondll;
	procedure NewtonDestroy (const newtonWorld: PNewtonWorld); cdecl; external newtondll;
	procedure NewtonDestroyAllBodies (const newtonWorld: PNewtonWorld); cdecl; external newtondll;

	procedure NewtonUpdate (const newtonWorld: PNewtonWorld; timestep: float); cdecl; external newtondll;
		procedure NewtonInvalidateCache (const newtonWorld: PNewtonWorld); cdecl; external newtondll;
	procedure NewtonCollisionUpdate (const newtonWorld: PNewtonWorld); cdecl; external newtondll;

	procedure NewtonSetSolverModel (const newtonWorld: PNewtonWorld; model: integer); cdecl; external newtondll;
	procedure NewtonSetPlatformArchitecture (const newtonWorld: PNewtonWorld; mode: integer); cdecl; external newtondll;

	function NewtonGetPlatformArchitecture(const newtonWorld: PNewtonWorld; description: pchar): integer; cdecl; external newtondll;
	procedure NewtonSetMultiThreadSolverOnSingleIsland (const newtonWorld: PNewtonWorld; mode: integer); cdecl; external newtondll;
	function NewtonGetMultiThreadSolverOnSingleIsland (const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;
	procedure NewtonSetPerformanceClock (const newtonWorld: PNewtonWorld; callback: PNewtonGetTicksCountCallback); cdecl; external newtondll;
	{
	NEWTON_API void NewtonSetPerformanceClock (const NewtonWorld* newtonWorld, NewtonGetTicksCountCallback callback);
	NEWTON_API unsigned NewtonReadPerformanceTicks (const NewtonWorld* newtonWorld, unsigned performanceEntry);
	NEWTON_API unsigned NewtonReadThreadPerformanceTicks (const NewtonWorld* newtonWorld, unsigned threadIndex);
	}
	procedure NewtonWorldCriticalSectionLock (const newtonWorld: PNewtonWorld); cdecl; external newtondll;
	procedure NewtonWorldCriticalSectionUnlock (const newtonWorld: PNewtonWorld); cdecl; external newtondll;

	function NewtonReadPerformaceTicks (const newtonWorld: PNewtonWorld; performanceEntry: longword): longword; cdecl; external newtondll;
	procedure NewtonSetThreadsCount (const newtonWorld: PNewtonWorld; threads: integer); cdecl; external newtondll;
	function NewtonGetThreadsCount(const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;
	function NewtonGetMaxThreadsCount(const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;

	procedure NewtonSetFrictionModel (const newtonWorld: PNewtonWorld; model: integer); cdecl; external newtondll;
	procedure NewtonSetMinimumFrameRate (const newtonWorld: PNewtonWorld; frameRate: float); cdecl; external newtondll;
	procedure NewtonSetBodyLeaveWorldEvent (const newtonWorld: PNewtonWorld; callback: PNewtonBodyLeaveWorld); cdecl; external newtondll;
	procedure NewtonSetWorldSize (const newtonWorld: PNewtonWorld; const minPoint: Pfloat; const maxPoint: Pfloat); cdecl; external newtondll;

	procedure NewtonSetIslandUpdateEvent (const newtonWorld: PNewtonWorld; islandUpdate: PNewtonIslandUpdate); cdecl; external newtondll;
	procedure NewtonSetCollisionDestructor (const newtonWorld: PNewtonWorld; callback: pNewtonCollisionDestructor); cdecl; external newtondll;
	procedure NewtonSetDestroyBodyByExeciveForce (const newtonWorld: PNewtonWorld; callback: pNewtonDestroyBodyByExeciveForce); cdecl; external newtondll;

// 	DP2.0 procedure NewtonWorldFreezeBody (const newtonWorld: PNewtonWorld; const body: PNewtonBody); cdecl; external newtondll;
//	DP2.0 procedure NewtonWorldUnfreezeBody (const newtonWorld: PNewtonWorld; const body: PNewtonBody); cdecl; external newtondll;

// removed in 2.0 beta 16
//	procedure NewtonWorldForEachBodyDo (const newtonWorld: PNewtonWorld; callback: PNewtonBodyIterator); cdecl; external newtondll;
// new 2.0
	procedure NewtonWorldForEachJointDo (const newtonWorld: PNewtonWorld; callback: PNewtonJointIterator; userdata: pointer); cdecl; external newtondll;

// added in 1.53?
	procedure NewtonWorldForEachBodyInAABBDo (const newtonWorld: PNewtonWorld; const p0: Pfloat; const p1: Pfloat; callback: PNewtonBodyIterator; userdata: pointer); cdecl; external newtondll;

	procedure NewtonWorldSetUserData (const newtonWorld: PNewtonWorld; userData: Pointer); cdecl; external newtondll;
	function NewtonWorldGetUserData (const newtonWorld: PNewtonWorld): pointer; cdecl; external newtondll;
	procedure NewtonWorldSetDestructorCallBack (const newtonWorld: PNewtonWorld; NewtonDestroyWorld: PNewtonDestroyWorld); cdecl; external newtondll; // 2.04
	function NewtonWorldGetDestructorCallBack (const newtonWorld: PNewtonWorld): PNewtonDestroyWorld; cdecl; external newtondll; // 2.04

	procedure NewtonWorldRayCast (const newtonWorld: PNewtonWorld; const p0: Pfloat; const p1: Pfloat; filter: PNewtonWorldRayFilterCallback; userData: Pointer; prefilter: PNewtonBodyIterator); cdecl; external newtondll;
// new 2.0
	function NewtonWorldConvexCast (const newtonWorld: PNewtonWorld; const matrix: PFloat; const target: PFloat; const shape: PNewtonCollision; hitParam: PFloat; userData: Pointer;
                      prefilter: PNewtonWorldRayPrefilterCallback; info: PNewtonWorldConvexCastReturnInfo; maxContactsCount: integer; threadIndex: integer): integer; cdecl; external newtondll;

	// world utility functions
// new 2.0
function NewtonWorldGetBodyCount(const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;
function NewtonWorldGetConstraintCount(const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;

// deprecated in 1.53 or 2.0?
	// NEWTON_API int NewtonGetActiveBodiesCount();
	// NEWTON_API int NewtonGetActiveConstraintsCount();
	// NEWTON_API dFloat NewtonGetGlobalScale (const newtonWorld: PNewtonWorld);



	// **********************************************************************************************
	//
	// Simulation islands
	//
	// **********************************************************************************************
// new 2.0
	function NewtonIslandGetBody (const island: pointer; bodyIndex: integer): PNewtonBody; cdecl; external newtondll;
	procedure NewtonIslandGetBodyAABB (const island: pointer; bodyIndex: integer; const p0: Pfloat; const p1: Pfloat); cdecl; external newtondll;

	// **********************************************************************************************
	//
	// Physics Material Section
	//
	// **********************************************************************************************

	function NewtonMaterialCreateGroupID(const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;
	function NewtonMaterialGetDefaultGroupID(const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;
	procedure NewtonMaterialDestroyAllGroupID(const newtonWorld: PNewtonWorld); cdecl; external newtondll;

	// material definitions that can not be overwritten in function callback
	function NewtonMaterialGetUserData (const newtonWorld: PNewtonWorld; id0: integer; id1: integer): Pointer; cdecl; external newtondll;
// new 2.0
	procedure NewtonMaterialSetSurfaceThickness (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; thickness: Float); cdecl; external newtondll;
// 1.30
	procedure NewtonMaterialSetContinuousCollisionMode (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; state: integer); cdecl; external newtondll;

  // changed in 2.0
	procedure NewtonMaterialSetCollisionCallback (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; userData: Pointer;
		begin_: PNewtonOnAABBOverlap; process: PNewtonContactsProcess{; end_: PNewtonContactEnd}); cdecl; external newtondll;

	// material definitions that can be overwritten in function callback
	procedure NewtonMaterialSetDefaultSoftness (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; value: float); cdecl; external newtondll;
	procedure NewtonMaterialSetDefaultElasticity (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; elasticCoef: float); cdecl; external newtondll;
	procedure NewtonMaterialSetDefaultCollidable (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; state: integer); cdecl; external newtondll;
	procedure NewtonMaterialSetDefaultFriction (const newtonWorld: PNewtonWorld; id0: integer; id1: integer; staticFriction: float; kineticFriction: float); cdecl; external newtondll;
  
	function NewtonWorldGetFirstMaterial (const newtonWorld: PNewtonWorld): PNewtonMaterial; cdecl; external newtondll;
	function NewtonWorldGetNextMaterial (const newtonWorld: PNewtonWorld; const material: PNewtonMaterial): PNewtonMaterial; cdecl; external newtondll;

	function NewtonWorldGetFirstBody (const newtonWorld: PNewtonWorld): PNewtonBody; cdecl; external newtondll;
	function NewtonWorldGetNextBody (const newtonWorld: PNewtonWorld; const curBody: PNewtonBody): PNewtonBody; cdecl; external newtondll;

	// **********************************************************************************************
	//
	// Physics Contact control functions
	//
	// **********************************************************************************************
// dp 2.0 beta 13		procedure NewtonMaterialDisableContact (const material: PNewtonMaterial); cdecl; external newtondll;
// dp 2.0 beta 13		Function NewtonMaterialGetCurrentTimestep (const material: PNewtonMaterial): float ; cdecl; external newtondll;
	Function NewtonMaterialGetMaterialPairUserData (const material: PNewtonMaterial): Pointer; cdecl; external newtondll;
	Function NewtonMaterialGetBodyCollisionID (const material: PNewtonMaterial; const body: PNewtonBody): unsigned ; cdecl; external newtondll;

	Function NewtonMaterialGetContactFaceAttribute (const material: PNewtonMaterial): unsigned ; cdecl; external newtondll;
  // changed in 2.0
	Function NewtonMaterialGetContactNormalSpeed (const material: PNewtonMaterial): float ; cdecl; external newtondll;
	procedure NewtonMaterialGetContactForce (const material: PNewtonMaterial; const body: PNewtonBody; const force: Pfloat); cdecl; external newtondll;
	procedure NewtonMaterialGetContactPositionAndNormal (const material: PNewtonMaterial; const body: PNewtonBody; const posit: Pfloat; const normal: Pfloat); cdecl; external newtondll;
	procedure NewtonMaterialGetContactTangentDirections (const material: PNewtonMaterial; const body: PNewtonBody; const dir0: Pfloat; const dir1: Pfloat); cdecl; external newtondll;
  // changed in 2.0
	Function NewtonMaterialGetContactTangentSpeed (const material: PNewtonMaterial; index: integer): float ; cdecl; external newtondll;

	procedure NewtonMaterialSetContactSoftness (const material: PNewtonMaterial; softness: float); cdecl; external newtondll;
	procedure NewtonMaterialSetContactElasticity (const material: PNewtonMaterial; restitution: float); cdecl; external newtondll;
	procedure NewtonMaterialSetContactFrictionState (const material: PNewtonMaterial; state: integer; index: integer); cdecl; external newtondll;
	procedure NewtonMaterialSetContactFrictionCoef (const material: PNewtonMaterial; coef: float; index: integer); cdecl; external newtondll;
// dp 2.0 beta 13	procedure NewtonMaterialSetContactKineticFrictionCoef (const material: PNewtonMaterial; coef: float; index: integer); cdecl; external newtondll;

  // 1.30
	procedure NewtonMaterialSetContactNormalAcceleration (const material: PNewtonMaterial; accel: float); cdecl; external newtondll;
  // 1.30
	procedure NewtonMaterialSetContactNormalDirection (const material: PNewtonMaterial; const directionVector: Pfloat); cdecl; external newtondll;

	procedure NewtonMaterialSetContactTangentAcceleration (const material: PNewtonMaterial; accel: float; index: integer); cdecl; external newtondll;
	procedure NewtonMaterialContactRotateTangentDirections (const material: PNewtonMaterial; const directionVector: Pfloat); cdecl; external newtondll;


	// **********************************************************************************************
	//
	// convex collision primitives creation functions
	//
	// **********************************************************************************************
	Function NewtonCreateNull (const newtonWorld: PNewtonWorld): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateSphere (const newtonWorld: PNewtonWorld; radiusX: float; radiusY: float; radiusZ: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateBox (const newtonWorld: PNewtonWorld; dx: float; dy: float; dz: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateCone (const newtonWorld: PNewtonWorld; radius: float; height: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateCapsule (const newtonWorld: PNewtonWorld; radius: float; height: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateCylinder (const newtonWorld: PNewtonWorld; radius: float; height: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateChamferCylinder (const newtonWorld: PNewtonWorld; radius: float; height: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonCreateConvexHull (const newtonWorld: PNewtonWorld; count: integer; vertexCloud: Pfloat; StrideInBytes: integer; tolerance: float; shapeid: integer; const offsetMatrix: Pfloat): PNewtonCollision ; cdecl; external newtondll;
 	function NewtonCreateConvexHullFromMesh (const newtonWorld: PNewtonWorld; const mesh: PNewtonMesh; tolerance: float; shapeid: integer): PNewtonCollision ; cdecl; external newtondll;

	Function NewtonCreateConvexHullModifier (const newtonWorld: PNewtonWorld; const convexHullCollision: PNewtonCollision): PNewtonCollision ; cdecl; external newtondll;
	procedure NewtonConvexHullModifierGetMatrix (const convexHullCollision: PNewtonCollision; matrix: Pfloat); cdecl; external newtondll;
	procedure NewtonConvexHullModifierSetMatrix (const convexHullCollision: PNewtonCollision; const matrix: Pfloat); cdecl; external newtondll;

	function NewtonCollisionIsTriggerVolume(const convexCollision: PNewtonCollision): integer; cdecl; external newtondll;
	procedure NewtonCollisionSetAsTriggerVolume(const convexCollision: PNewtonCollision; trigger: integer); cdecl; external newtondll;

	procedure NewtonCollisionSetMaxBreakImpactImpulse(const convexHullCollision: PNewtonCollision; maxImpactImpulse: Float); cdecl; external newtondll;
	function NewtonCollisionGetMaxBreakImpactImpulse(const convexHullCollision: PNewtonCollision): single; cdecl; external newtondll;

	procedure NewtonCollisionSetUserID (const convexCollision: PNewtonCollision; id: unsigned); cdecl; external newtondll; // gone with 2.04, back with 2.06
	Function NewtonCollisionGetUserID (const convexCollision: PNewtonCollision): unsigned; cdecl; external newtondll;

	function NewtonConvexHullGetFaceIndices (const convexHullCollision: PNewtonCollision; face: integer; faceIndices: pointer): integer; cdecl; external newtondll;

  // 1.30
	Function NewtonConvexCollisionCalculateVolume (const convexCollision: PNewtonCollision): float ; cdecl; external newtondll;
  // 1.30
	procedure NewtonConvexCollisionCalculateInertialMatrix (const convexCollision: PNewtonCollision; inertia: Pfloat; origin: Pfloat); cdecl; external newtondll;

  // 1.30
	procedure NewtonCollisionMakeUnique (const newtonWorld: PNewtonWorld; const collision: PNewtonCollision); cdecl; external newtondll;
	procedure NewtonReleaseCollision (const newtonWorld: PNewtonWorld; const collision: PNewtonCollision); cdecl; external newtondll;
  // new 2.0
	function NewtonAddCollisionReference (const newtonWorld: PNewtonWorld): integer; cdecl; external newtondll;

	
	// **********************************************************************************************
	//
	// mass/spring/damper collision shape
	//
	// **********************************************************************************************

//	NEWTON_API NewtonCollision* NewtonCreateSoftShape (const NewtonWorld* newtonWorld);
//	NEWTON_API void NewtonSoftBodySetMassCount (const NewtonCollision* convexCollision, int count);
//	NEWTON_API void NewtonSoftBodySetSpringCount (const NewtonCollision* convexCollision, int count);

//	NEWTON_API void NewtonSoftBodySetMass (const NewtonCollision* convexCollision, int index, dFloat mass, dFloat* position);
//	NEWTON_API int NewtonSoftBodySetSpring (const NewtonCollision* convexCollision, int index, int mass0, int mass1, dFloat stiffness, dFloat damper);
//	NEWTON_API int NewtonSoftBodyGetMassArray (const NewtonCollision* convexCollision, dFloat* masses, dFloat** positions);	


	// **********************************************************************************************
	//
	// complex collision primitives creation functions
	//
	// **********************************************************************************************

 	function  NewtonCreateCompoundCollision (const newtonWorld: PNewtonWorld; count: integer;
	         	const collisionPrimitiveArray: array of PNewtonCollision; shapeid: integer): PNewtonCollision; cdecl; external newtondll;
  // new 2.0
  //function NewtonCreateCompoundCollisionFromMesh (const newtonWorld: PNewtonWorld; const mesh: PNewtonMesh; concavity: float; maxShapeCount: integer; shapeid: integer): PNewtonCollision; cdecl; external newtondll;
	function NewtonCreateCompoundCollisionFromMesh(const newtonWorld: PNewtonWorld; const mesh: PNewtonMesh; maxSubShapesCount: integer; shapeID: integer; subShapeID: integer): PNewtonCollision; cdecl; external newtondll;


{
	// **********************************************************************************************
	//
	// complex breakable collision primitives interface
	//
	// **********************************************************************************************
//	NEWTON_API NewtonCollision* NewtonCreateCompoundBreakable (const NewtonWorld* newtonWorld, int meshCount,
//															   NewtonMesh* const solids[], NewtonMesh* const splitePlanes[],
//															   dFloat* const matrixPallete, int* const shapeIDArray, dFloat* const densities,
//															   int shapeID, int debriID, NewtonCollisionCompoundBreakableCallback callback, void* buildUsedData);

	NEWTON_API NewtonCollision* NewtonCreateCompoundBreakable (const NewtonWorld* newtonWorld, int meshCount,
															   const NewtonMesh* const solids[], const int* const shapeIDArray,
															   const dFloat* const densities, const int* const internalFaceMaterial,
															   int shapeID, int debriID, dFloat debriSeparationGap);


	NEWTON_API void NewtonCompoundBreakableResetAnchoredPieces (const NewtonCollision* compoundBreakable);
	NEWTON_API void NewtonCompoundBreakableSetAnchoredPieces (const NewtonCollision* compoundBreakable, int fixShapesCount, dFloat* const matrixPallete, NewtonCollision** fixedShapesArray);

	NEWTON_API int NewtonCompoundBreakableGetVertexCount (const NewtonCollision* compoundBreakable);
	NEWTON_API void NewtonCompoundBreakableGetVertexStreams (const NewtonCollision* compoundBreakable, int vertexStrideInByte, dFloat* vertex,
																int normalStrideInByte, dFloat* normal,	int uvStrideInByte, dFloat* uv);


	NEWTON_API NewtonbreakableComponentMesh* NewtonBreakableGetMainMesh (const NewtonCollision* compoundBreakable);
	NEWTON_API NewtonbreakableComponentMesh* NewtonBreakableGetFirstComponent (const NewtonCollision* compoundBreakable);
	NEWTON_API NewtonbreakableComponentMesh* NewtonBreakableGetNextComponent (const NewtonbreakableComponentMesh* component);

	NEWTON_API void NewtonBreakableBeginDelete (const NewtonCollision* compoundBreakable);
	NEWTON_API NewtonBody* NewtonBreakableCreateDebrieBody (const NewtonCollision* compoundBreakable, const NewtonbreakableComponentMesh* component);
	NEWTON_API void NewtonBreakableDeleteComponent (const NewtonCollision* compoundBreakable, const NewtonbreakableComponentMesh* component);
	NEWTON_API void NewtonBreakableEndDelete (const NewtonCollision* compoundBreakable);


	NEWTON_API int NewtonBreakableGetComponentsInRadius (const NewtonCollision* compoundBreakable, const dFloat* position, dFloat radius, NewtonbreakableComponentMesh** segments, int maxCount);

	NEWTON_API void* NewtonBreakableGetFirstSegment (const NewtonbreakableComponentMesh* breakableComponent);
	NEWTON_API void* NewtonBreakableGetNextSegment (const void* segment);

	NEWTON_API int NewtonBreakableSegmentGetMaterial (const void* segment);
	NEWTON_API int NewtonBreakableSegmentGetIndexCount (const void* segment);
	NEWTON_API int NewtonBreakableSegmentGetIndexStream (const NewtonCollision* compoundBreakable, const NewtonbreakableComponentMesh* meshOwner, const void* segment, int* index);
	NEWTON_API int NewtonBreakableSegmentGetIndexStreamShort (const NewtonCollision* compoundBreakable, const NewtonbreakableComponentMesh* meshOwner, const void* segment, short int* index);
}




// updated in 2.0
	function  NewtonCreateUserMeshCollision (const newtonWorld: PNewtonWorld; const minBox: Pfloat;
	        	const maxBox: Pfloat; userData: Pointer; collideCallback: PNewtonUserMeshCollisionCollideCallback;
		        rayHitCallback: PNewtonUserMeshCollisionRayHitCallback; destroyCallback: PNewtonUserMeshCollisionDestroyCallback;
            getInfoCallback: PNewtonUserMeshCollisionGetCollisionInfo; facesInAABBCallback: PNewtonUserMeshCollisionGetFacesInAABB;
            shapeid: integer
            ): PNewtonCollision; cdecl; external newtondll;

{
	NEWTON_API NewtonCollision* NewtonCreateSceneCollision (const NewtonWorld* const newtonWorld, int shapeID);
	NEWTON_API NewtonSceneProxy* NewtonSceneCollisionCreateProxy (NewtonCollision* const scene, NewtonCollision* collision, const dFloat* const matrix);

	NEWTON_API void NewtonSceneCollisionDestroyProxy (NewtonCollision* const scene, NewtonSceneProxy* Proxy);
	NEWTON_API void NewtonSceneProxySetMatrix (NewtonSceneProxy* const proxy, const dFloat* matrix);
	NEWTON_API void NewtonSceneProxyGetMatrix (NewtonSceneProxy* const proxy, dFloat* matrix);

	NEWTON_API void* NewtonSceneGetFirstProxy (NewtonCollision* const scene);
	NEWTON_API void* NewtonSceneGetNextProxy (NewtonCollision* const scene, void* const proxy);
}
	function NewtonCreateSceneCollision (const newtonWorld: PNewtonWorld; size: Float; shapeid: integer): PNewtonCollision; cdecl; external newtondll;
	function NewtonSceneCollisionCreateProxy (scene: PNewtonCollision; collision: PNewtonCollision): PNewtonSceneProxy; cdecl; external newtondll;
  
	procedure NewtonSceneCollisionDestroyProxy (scene: PNewtonCollision; Proxy: PNewtonSceneProxy); cdecl; external newtondll;
	procedure NewtonSceneProxySetMatrix (Proxy: PNewtonSceneProxy; const matrix: PFloat); cdecl; external newtondll;
	procedure NewtonSceneProxyGetMatrix (Proxy: PNewtonSceneProxy; matrix: PFloat); cdecl; external newtondll;

	procedure NewtonSceneCollisionOptimize (scene: PNewtonCollision); cdecl; external newtondll;

	//  ***********************************************************************************************************
	//
	//	Collision serialization functions
	//
	// ***********************************************************************************************************

	function NewtonCreateCollisionFromSerialization (const newtonWorld: PNewtonWorld; deserializeFunction: PNewtonSerialize; serializeHandle: pointer): PNewtonCollision; cdecl; external newtondll;
	procedure NewtonCollisionSerialize (const newtonWorld: PNewtonWorld; const collision: PNewtonCollision; serializeFunction: PNewtonSerialize; serializeHandle: pointer); cdecl; external newtondll;
	procedure NewtonCollisionGetInfo (const collision: PNewtonCollision; collisionInfo: PNewtonCollisionInfoRecord); cdecl; external newtondll;
// deprecated in 2.0	procedure NewtonTreeCollisionSerialize (const treeCollision: PNewtonCollision; serializeFunction: PNewtonSerialize; serializeHandle: Pointer); cdecl; external newtondll;
// deprecated in 2.0	Function NewtonCreateTreeCollisionFromSerialization (const newtonWorld: PNewtonWorld; userCallback: PNewtonTreeCollisionCallback; deserializeFunction: PNewtonDeserialize; serializeHandle: Pointer): PNewtonCollision; cdecl; external newtondll;

	// **********************************************************************************************
	//
	//  Static collision shapes functions
	//
	// **********************************************************************************************

  // new 2.0
	function NewtonCreateHeightFieldCollision (const newtonWorld: PNewtonWorld; width, height, gridsDiagonals: integer;
																  elevationMap: word; atributeMap: pointer;
																  horizontalScale, verticalScale: float; shapeid: integer): PNewtonCollision; cdecl; external newtondll;
  // new 2.0, DP 2.0 beta 11
//	function NewtonHeightFieldCollisionGetVertexListIndexListInAABB (const hightField: PNewtonCollision; const p0, p1: Pfloat; const vertexArrayOut: Pfloat; vertexCount: Pinteger; vertexStrideInBytes: Pinteger; const indexList: Pinteger; maxIndexCount: integer; const faceAttribute: Pinteger): integer; cdecl; external newtondll;

	Function NewtonCreateTreeCollision (const newtonWorld: PNewtonWorld; shapeid: integer): PNewtonCollision; cdecl; external newtondll;
// new 2.0
	procedure NewtonTreeCollisionSetUserCallback (const treeCollision: PNewtonCollision; userCallback: PNewtonTreeCollisionCallback); cdecl; external newtondll;
// new 2.0
	procedure NewtonTreeCollisionSetUserRayCastCallback (const treeCollision: PNewtonCollision; rayHitCallback: PNewtonCollisionTreeRayCastCallback); cdecl; external newtondll;

	procedure NewtonTreeCollisionBeginBuild (const treeCollision: PNewtonCollision); cdecl; external newtondll;
	procedure NewtonTreeCollisionAddFace (const treeCollision: PNewtonCollision; vertexCount: integer; const vertexPtr: Pfloat; StrideInBytes: integer; faceAttribute: integer); cdecl; external newtondll;
	procedure NewtonTreeCollisionEndBuild (const treeCollision: PNewtonCollision; optimize: integer); cdecl; external newtondll;

	Function NewtonTreeCollisionGetFaceAtribute (const treeCollision: PNewtonCollision; const faceIndexArray: Pinteger): integer; cdecl; external newtondll;
	procedure NewtonTreeCollisionSetFaceAtribute (const treeCollision: PNewtonCollision; const faceIndexArray: Pinteger;
		attribute: integer); cdecl; external newtondll;

// new 2.0
	function NewtonTreeCollisionGetVertexListIndexListInAABB (const treeCollision: PNewtonCollision; const p0: Pfloat; const p1: Pfloat; const vertexArray: PFloat; vertexCount: Pinteger; VertexStrideInBytes: Pinteger; const indexList: Pinteger; maxIndexCount: integer; const faceAttribute: Pinteger): integer; cdecl; external newtondll;

 	procedure NewtonStaticCollisionSetDebugCallback (const treeCollision: PNewtonCollision; userCallback: PNewtonTreeCollisionCallback); cdecl; external newtondll;
	
	// **********************************************************************************************
	//
	// General purpose collision library functions
	//
	// **********************************************************************************************
  
  // 1.30
	function NewtonCollisionPointDistance (const newtonWorld: PNewtonWorld; const Point: Pfloat;
		const collision: PNewtonCollision; const matrix: Pfloat; contact: Pfloat; normal: Pfloat; threadindex: integer): integer; cdecl; external newtondll;
  // 1.30
	function NewtonCollisionClosestPoint (const newtonWorld: PNewtonWorld;
		const collisionA: PNewtonCollision; const matrixA: Pfloat; const collisionB: PNewtonCollision; const matrixB: Pfloat;
		contactA: Pfloat; contactB: Pfloat; normalAB: Pfloat; threadindex: integer): integer; cdecl; external newtondll;

  // 1.30
	function NewtonCollisionCollide (const newtonWorld: PNewtonWorld; maxSize: integer;
		const collisionA: PNewtonCollision; const matrixA: Pfloat;
    const collisionB: PNewtonCollision; const matrixB: Pfloat;
		contacts: Pfloat; normals: Pfloat; penetration: Pfloat; threadindex: integer): integer; cdecl; external newtondll;

  // 1.30
	function NewtonCollisionCollideContinue (const newtonWorld: PNewtonWorld; maxSize: integer; const timestep: float;
		const collisionA: PNewtonCollision; const matrixA: Pfloat; const velocA: Pfloat; const omegaA: Pfloat;
		const collisionB: PNewtonCollision; const matrixB: Pfloat; const velocB: Pfloat; const omegaB: Pfloat;
		timeOfImpact: Pfloat; contacts: Pfloat; normals: Pfloat; penetration: Pfloat; threadindex: integer): integer; cdecl; external newtondll;

  // new 2.0
	procedure NewtonCollisionSupportVertex (const collision: PNewtonCollision; const dir, vertex: Pfloat); cdecl; external newtondll;

	Function NewtonCollisionRayCast (const collision: PNewtonCollision; const p0: Pfloat; const p1: Pfloat; normals: Pfloat; attribute: Pinteger): float ; cdecl; external newtondll;
	procedure NewtonCollisionCalculateAABB (const collision: PNewtonCollision; const matrix: Pfloat; p0: Pfloat; p1: Pfloat); cdecl; external newtondll;
  procedure NewtonCollisionForEachPolygonDo (const collision: PNewtonCollision; matrix: Pfloat; callback: PNewtonCollisionIterator; userData: pointer); cdecl; external newtondll; // new 2.0

	// **********************************************************************************************
	//
	// transforms utility functions
	//
	// **********************************************************************************************
	procedure NewtonGetEulerAngle (const matrix: Pfloat; const eulersAngles: Pfloat); cdecl; external newtondll;
	procedure NewtonSetEulerAngle (const eulersAngles: Pfloat; const matrix: Pfloat); cdecl; external newtondll;
  // new 2.0
  function NewtonCalculateSpringDamperAcceleration (dt, ks, x, kd, s: float): float; cdecl; external newtondll;

	// **********************************************************************************************
	//
	// body manipulation functions
	//
	// **********************************************************************************************
	function NewtonCreateBody (const newtonWorld: PNewtonWorld; const collision: PNewtonCollision; const matrix: Pfloat): PNewtonBody; cdecl; external newtondll;
	procedure  NewtonDestroyBody(const newtonWorld: PNewtonWorld; const body: PNewtonBody); cdecl; external newtondll;

	procedure  NewtonBodyAddForce (const body: PNewtonBody; const force: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyAddTorque (const body: PNewtonBody; const torque: Pfloat); cdecl; external newtondll;
  // new 2.0
	procedure NewtonBodyCalculateInverseDynamicsForce (const body: PNewtonBody; timestep: float; const desiredVeloc, forceOut: Pfloat); cdecl; external newtondll;

	procedure  NewtonBodySetMatrix (const body: PNewtonBody; const matrix: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetMatrixRecursive (const body: PNewtonBody; const matrix: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetMassMatrix (const body: PNewtonBody; mass: float; Ixx: float; Iyy: float; Izz: float); cdecl; external newtondll;
	procedure  NewtonBodySetMaterialGroupID (const body: PNewtonBody; id: integer); cdecl; external newtondll;
	procedure  NewtonBodySetContinuousCollisionMode (const body: PNewtonBody; state: unsigned); cdecl; external newtondll;
	procedure  NewtonBodySetJointRecursiveCollision (const body: PNewtonBody; state: unsigned); cdecl; external newtondll;
	procedure  NewtonBodySetOmega (const body: PNewtonBody; const omega: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetVelocity (const body: PNewtonBody; const velocity: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetForce (const body: PNewtonBody; const force: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetTorque (const body: PNewtonBody; const torque: Pfloat); cdecl; external newtondll;

  // 1.3
	procedure  NewtonBodySetCentreOfMass  (const body: PNewtonBody; const com: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetLinearDamping (const body: PNewtonBody; linearDamp: float); cdecl; external newtondll;
	procedure  NewtonBodySetAngularDamping (const body: PNewtonBody; const angularDamp: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodySetUserData (const body: PNewtonBody; userData: Pointer); cdecl; external newtondll;
	procedure  NewtonBodySetCollision (const body: PNewtonBody; const collision: PNewtonCollision); cdecl; external newtondll;

  // changed 2.0 NewtonBodyGetAutoFreeze -> NewtonBodyGetAutoSleep
  // changed 2.0 NewtonBodyGetSleepingState -> NewtonBodyGetFreezeState

	function  NewtonBodyGetSleepState (const body: PNewtonBody): integer; cdecl; external newtondll;
	function  NewtonBodyGetAutoSleep (const body: PNewtonBody): integer; cdecl; external newtondll;
	procedure NewtonBodySetAutoSleep (const body: PNewtonBody; state: integer); cdecl; external newtondll;

	function  NewtonBodyGetFreezeState(const body: PNewtonBody): integer; cdecl; external newtondll;
	procedure NewtonBodySetFreezeState (const body: PNewtonBody; state: integer); cdecl; external newtondll;

// deprecated in 2.0 procedure  NewtonBodySetAutoFreeze (const body: PNewtonBody; state: integer); cdecl; external newtondll;
// deprecated in 2.0	procedure  NewtonBodyCoriolisForcesMode (const body: PNewtonBody; mode: integer); cdecl; external newtondll;
// deprecated in 1.53?	NEWTON_API void  NewtonBodySetGyroscopicForcesMode (const NewtonBody* body, int mode);
// deprecated in 1.53?	NEWTON_API int   NewtonBodyGetGyroscopicForcesMode (const NewtonBody* body);
// deprecated in 1.53?	NEWTON_API int   NewtonBodyGetFreezeState (const NewtonBody* body);
// deprecated in 1.53?	NEWTON_API void  NewtonBodySetFreezeState  (const NewtonBody* body, int state);
// deprecated in 2.0	procedure  NewtonBodyGetFreezeTreshold (const body: PNewtonBody; freezeSpeed2: Pfloat; freezeOmega2: Pfloat); cdecl; external newtondll;
// deprecated in 2.0	procedure  ??????????????? (const body: PNewtonBody; freezeSpeed2: float; freezeOmega2: float; framesCount: integer); cdecl; external newtondll;
// deprecated in 2.0 procedure  NewtonBodySetAutoactiveCallback (const body: PNewtonBody; callback: PNewtonBodyActivationState); cdecl; external newtondll;

	procedure NewtonBodySetDestructorCallback (const body: PNewtonBody; callback: PNewtonBodyDestructor); cdecl; external newtondll;

	procedure NewtonBodySetTransformCallback (const body: PNewtonBody; callback: PNewtonSetTransform); cdecl; external newtondll;
	function  NewtonBodyGetTransformCallback (const body: PNewtonBody): PNewtonSetTransform; cdecl; external newtondll;

	procedure  NewtonBodySetForceAndTorqueCallback (const body: PNewtonBody; callback: PNewtonApplyForceAndTorque); cdecl; external newtondll;
  // 1.3
  function NewtonBodyGetForceAndTorqueCallback (const body: PNewtonBody): PNewtonApplyForceAndTorque; cdecl; external newtondll;
	function NewtonBodyGetUserData (const body: PNewtonBody): Pointer; cdecl; external newtondll;
	function NewtonBodyGetWorld (const body: PNewtonBody): PNewtonWorld; cdecl; external newtondll;
	Function NewtonBodyGetCollision (const body: PNewtonBody): PNewtonCollision ; cdecl; external newtondll;
	Function NewtonBodyGetMaterialGroupID (const body: PNewtonBody): integer; cdecl; external newtondll;

  // added 1.3
	Function NewtonBodyGetContinuousCollisionMode (const body: PNewtonBody): integer; cdecl; external newtondll;
	Function NewtonBodyGetJointRecursiveCollision (const body: PNewtonBody): integer; cdecl; external newtondll;

	procedure  NewtonBodyGetMatrix(const body: PNewtonBody; matrix: Pfloat); cdecl; external newtondll;
 // new 2.0
  procedure  NewtonBodyGetRotation(const body: PNewtonBody; matrix: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetMassMatrix (const body: PNewtonBody; mass: Pfloat; Ixx: Pfloat; Iyy: Pfloat; Izz: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetInvMass(const body: PNewtonBody; invMass: Pfloat; invIxx: Pfloat; invIyy: Pfloat; invIzz: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetOmega(const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetVelocity(const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetForce(const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetTorque(const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
// added 2.0
	procedure NewtonBodyGetForceAcc(const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
	procedure NewtonBodyGetTorqueAcc(const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
// added 1.3
	procedure  NewtonBodyGetCentreOfMass (const body: PNewtonBody; com: Pfloat); cdecl; external newtondll;
	Function NewtonBodyGetLinearDamping (const body: PNewtonBody): float ; cdecl; external newtondll;
  // new 2.0
	procedure  NewtonBodyGetAngularDamping (const body: PNewtonBody; vector: Pfloat); cdecl; external newtondll;
	procedure  NewtonBodyGetAABB (const body: PNewtonBody; p0: Pfloat; p1: Pfloat); cdecl; external newtondll;
  // new 2.0
	function NewtonBodyGetFirstJoint (const body: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
  // new 2.0
	function NewtonBodyGetNextJoint (const body: PNewtonBody; const joint: PNewtonJoint): PNewtonJoint; cdecl; external newtondll;
  // new 2.0
	function NewtonBodyGetFirstContactJoint (const body: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
  // new 2.0
 	function NewtonBodyGetNextContactJoint (const body: PNewtonBody; const contactJoint: PNewtonJoint): PNewtonJoint; cdecl; external newtondll;
  // new 2.0
	function NewtonContactJointGetFirstContact (const contactJoint: PNewtonJoint): PNewtonJoint; cdecl; external newtondll;
	function NewtonContactJointGetNextContact (const contactJoint: PNewtonJoint; contact: PNewtonJoint): PNewtonJoint; cdecl; external newtondll;
  // new 2.0
	function NewtonContactJointGetContactCount(const contactJoint: PNewtonJoint): integer; cdecl; external newtondll;
	procedure NewtonContactJointRemoveContact(const contactJoint: PNewtonJoint; contact: pointer); cdecl; external newtondll;
  // new 2.0
	function NewtonContactGetMaterial (const contactJoint: PnewtonJoint): PNewtonMaterial; cdecl; external newtondll;

 	procedure NewtonBodyAddBuoyancyForce (const body: PNewtonBody; fluidDensity: float;
	         	fluidLinearViscosity: float; fluidAngularViscosity: float;
	         	const gravityVector: Pfloat; Plane: PNewtonGetBuoyancyPlane; context: Pointer); cdecl; external newtondll;

// deprecated in 2.0	procedure NewtonBodyForEachPolygonDo (const body: PNewtonBody; callback: PNewtonCollisionIterator); cdecl; external newtondll;
// new 2.0: renamed NewtonAddBodyImpulse to NewtonBodyAddImpulse
	procedure NewtonBodyAddImpulse (const body: PNewtonBody; const PointDeltaVeloc: Pfloat; const PointPosit: Pfloat); cdecl; external newtondll;

	// **********************************************************************************************
	//
	// Common Joint functions
	//
	// **********************************************************************************************
	function NewtonJointGetUserData (const Joint: PNewtonJoint): Pointer; cdecl; external newtondll;
	procedure NewtonJointSetUserData (const Joint: PNewtonJoint; userData: Pointer); cdecl; external newtondll;

  // new 2.0
	function NewtonJointGetBody0 (const Joint: PNewtonJoint): PNewtonBody; cdecl; external newtondll;
	function NewtonJointGetBody1 (const Joint: PNewtonJoint): PNewtonBody; cdecl; external newtondll;

// new 2.0
	procedure NewtonJointGetInfo  (const joint: PNewtonJoint; info: PNewtonJointRecord); cdecl; external newtondll; // new 2.0
	function NewtonJointGetCollisionState (const Joint: PNewtonJoint): integer; cdecl; external newtondll;
	procedure NewtonJointSetCollisionState (const Joint: PNewtonJoint; state: integer); cdecl; external newtondll;

	Function NewtonJointGetStiffness (const Joint: PNewtonJoint): float ; cdecl; external newtondll;
	procedure NewtonJointSetStiffness (const Joint: PNewtonJoint; state: float); cdecl; external newtondll;

	procedure NewtonDestroyJoint(const newtonWorld: PNewtonWorld; const Joint: PNewtonJoint); cdecl; external newtondll;
	procedure NewtonJointSetDestructor (const Joint: PNewtonJoint; destructor_: PNewtonConstraintDestructor); cdecl; external newtondll;


	// **********************************************************************************************
	//
	// Ball and Socket Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateBall (const newtonWorld: PNewtonWorld; const pivotPoint: Pfloat;
		const childBody: PNewtonBody; const parentBody: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
	procedure NewtonBallSetUserCallback (const ball: PNewtonJoint; callback: PNewtonBallCallBack); cdecl; external newtondll;
	procedure NewtonBallGetJointAngle (const ball: PNewtonJoint; angle: Pfloat); cdecl; external newtondll;
	procedure NewtonBallGetJointOmega (const ball: PNewtonJoint; omega: Pfloat); cdecl; external newtondll;
	procedure NewtonBallGetJointForce (const ball: PNewtonJoint; force: Pfloat); cdecl; external newtondll;
	procedure NewtonBallSetConeLimits (const ball: PNewtonJoint; const pin: Pfloat; maxConeAngle: float; maxTwistAngle: float); cdecl; external newtondll;

	// **********************************************************************************************
	//
	// Hinge Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateHinge (const newtonWorld: PNewtonWorld;
		const pivotPoint: Pfloat; const pinDir: Pfloat; 
		const childBody: PNewtonBody; const parentBody: PNewtonBody): PNewtonJoint; cdecl; external newtondll;

	procedure NewtonHingeSetUserCallback (const hinge: PNewtonJoint; callback: PNewtonHingeCallBack); cdecl; external newtondll;
	Function NewtonHingeGetJointAngle (const hinge: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonHingeGetJointOmega (const hinge: PNewtonJoint): float ; cdecl; external newtondll;
	procedure NewtonHingeGetJointForce (const hinge: PNewtonJoint; force: Pfloat); cdecl; external newtondll;
	Function NewtonHingeCalculateStopAlpha (const hinge: PNewtonJoint; const desc: PNewtonHingeSliderUpdateDesc; angle: float): float ; cdecl; external newtondll;

	// **********************************************************************************************
	//
	// Slider Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateSlider (const newtonWorld: PNewtonWorld;
		const pivotPoint: Pfloat; const pinDir: Pfloat; 
		const childBody: PNewtonBody; const parentBody: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
	procedure NewtonSliderSetUserCallback (const slider: PNewtonJoint; callback: PNewtonSliderCallBack); cdecl; external newtondll;
	Function NewtonSliderGetJointPosit (const slider: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonSliderGetJointVeloc (const slider: PNewtonJoint): float ; cdecl; external newtondll;
	procedure NewtonSliderGetJointForce (const slider: PNewtonJoint; force: Pfloat); cdecl; external newtondll;
	Function NewtonSliderCalculateStopAccel (const slider: PNewtonJoint; const desc: PNewtonHingeSliderUpdateDesc; position: float): float ; cdecl; external newtondll;


	// **********************************************************************************************
	//
	// Corkscrew Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateCorkscrew (const newtonWorld: PNewtonWorld;
		const pivotPoint: Pfloat; const pinDir: Pfloat; 
		const childBody: PNewtonBody; const parentBody: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
	procedure NewtonCorkscrewSetUserCallback (const corkscrew: PNewtonJoint; callback: PNewtonCorkscrewCallBack); cdecl; external newtondll;
	Function NewtonCorkscrewGetJointPosit (const corkscrew: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonCorkscrewGetJointAngle (const corkscrew: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonCorkscrewGetJointVeloc (const corkscrew: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonCorkscrewGetJointOmega (const corkscrew: PNewtonJoint): float ; cdecl; external newtondll;
	procedure NewtonCorkscrewGetJointForce (const corkscrew: PNewtonJoint; force: Pfloat); cdecl; external newtondll;
	Function NewtonCorkscrewCalculateStopAlpha (const corkscrew: PNewtonJoint; const desc: PNewtonHingeSliderUpdateDesc; angle: float): float ; cdecl; external newtondll;
	Function NewtonCorkscrewCalculateStopAccel (const corkscrew: PNewtonJoint; const desc: PNewtonHingeSliderUpdateDesc; position: float): float ; cdecl; external newtondll;


	// **********************************************************************************************
	//
	// Universal Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateUniversal (const newtonWorld: PNewtonWorld;
		const pivotPoint: Pfloat; const pinDir0: Pfloat; const pinDir1: Pfloat; 
		const childBody: PNewtonBody; const parentBody: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
	procedure NewtonUniversalSetUserCallback (const universal: PNewtonJoint; callback: PNewtonUniversalCallBack); cdecl; external newtondll;
	Function NewtonUniversalGetJointAngle0 (const universal: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonUniversalGetJointAngle1 (const universal: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonUniversalGetJointOmega0 (const universal: PNewtonJoint): float ; cdecl; external newtondll;
	Function NewtonUniversalGetJointOmega1 (const universal: PNewtonJoint): float ; cdecl; external newtondll;
	procedure NewtonUniversalGetJointForce (const universal: PNewtonJoint; force: Pfloat); cdecl; external newtondll;
	Function NewtonUniversalCalculateStopAlpha0 (const universal: PNewtonJoint; const desc: PNewtonHingeSliderUpdateDesc; angle: float): float ; cdecl; external newtondll;
	Function NewtonUniversalCalculateStopAlpha1 (const universal: PNewtonJoint; const desc: PNewtonHingeSliderUpdateDesc; angle: float): float ; cdecl; external newtondll;


	// **********************************************************************************************
	//
	// Up vector Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateUpVector (const newtonWorld: PNewtonWorld; const pinDir: Pfloat; const body: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
	procedure NewtonUpVectorGetPin (const upVector: PNewtonJoint; pin: Pfloat); cdecl; external newtondll;
	procedure NewtonUpVectorSetPin (const upVector: PNewtonJoint; const pin: Pfloat); cdecl; external newtondll;


	// **********************************************************************************************
	//
	// User defined bilateral Joint
	//
	// **********************************************************************************************

  // ALL USER JOINT ADDED IN 1.30

  // changed in 2.0
	Function NewtonConstraintCreateUserJoint (const newtonWorld: PNewtonWorld; maxDOF: integer; callback: PNewtonUserBilateralCallBack;
                               const getInfo: PNewtonUserBilateralGetInfoCallBack;
															 const childBody: PNewtonBody; const parentBody: PNewtonBody): PNewtonJoint; cdecl; external newtondll;

  // new 2.0
	procedure NewtonUserJointSetFeedbackCollectorCallback (const Joint: PNewtonJoint; getFeedback: PNewtonUserBilateralCallBack); cdecl; external newtondll;
	procedure NewtonUserJointAddLinearRow (const Joint: PNewtonJoint; const pivot0: Pfloat; const pivot1: Pfloat; const dir: Pfloat); cdecl; external newtondll;
	procedure NewtonUserJointAddAngularRow (const Joint: PNewtonJoint; relativeAngle: float; const dir: Pfloat); cdecl; external newtondll;
	procedure NewtonUserJointAddGeneralRow (const Joint: PNewtonJoint; const jacobian0: Pfloat; const jacobian1: Pfloat); cdecl; external newtondll;
	procedure NewtonUserJointSetRowMinimumFriction (const Joint: PNewtonJoint; friction: float); cdecl; external newtondll;
	procedure NewtonUserJointSetRowMaximumFriction (const Joint: PNewtonJoint; friction: float); cdecl; external newtondll;
	procedure NewtonUserJointSetRowAcceleration (const Joint: PNewtonJoint; acceleration: float); cdecl; external newtondll;
	procedure NewtonUserJointSetRowSpringDamperAcceleration (const Joint: PNewtonJoint; springK: float; springD: float); cdecl; external newtondll;
	procedure NewtonUserJointSetRowStiffness (const Joint: PNewtonJoint; stiffness: float); cdecl; external newtondll;
	Function NewtonUserJointGetRowForce (const Joint: PNewtonJoint; row: integer): float ; cdecl; external newtondll;

	// **********************************************************************************************
	//
	// Mesh joint functions
	//
	// **********************************************************************************************


	function NewtonMeshCreate(const newtonWorld: PNewtonWorld): PNewtonMesh; cdecl; external newtondll;
  function NewtonMeshCreateFromMesh(const mesh: PNewtonMesh): PNewtonMesh; cdecl; external newtondll;
	function NewtonMeshCreateFromCollision(const collision: PNewtonCollision): PNewtonMesh; cdecl; external newtondll;
  function NewtonMeshConvexHull (const world: PNewtonWorld; count: integer; const vertexCloud: PFloat; strideInBytes: integer; tolerance: single): PNewtonMesh; cdecl; external newtondll;
	function NewtonMeshCreatePlane (const newtonWorld: PNewtonWorld; const locationMatrix: pfloat; witdth, breadth: float; material: integer; const textureMatrix: pFloat): pNewtonMesh; cdecl; external newtondll;
	procedure NewtonMeshDestroy(const PNewtonMeshmesh); cdecl; external newtondll;

	procedure NewtonMeshCalculateOOBB(const mesh: pNewtonMesh; matrix: pFloat; x, y, z: pfloat); cdecl; external newtondll;

	procedure NewtonMeshCalculateVertexNormals(const mesh: PNewtonMesh; angleInRadians: Float); cdecl; external newtondll;
	procedure NewtonMeshApplySphericalMapping(const mesh: PNewtonMesh; material: integer); cdecl; external newtondll;
	procedure NewtonMeshApplyBoxMapping(const mesh: PNewtonMesh; front: integer ; side: integer; top: integer); cdecl; external newtondll;
	procedure NewtonMeshApplyCylindricalMapping(const mesh: PNewtonMesh; cylinderMaterial: integer; capMaterial: integer); cdecl; external newtondll;

	function NewtonMeshIsOpenMesh (const mesh: PNewtonMesh): integer; cdecl; external newtondll;
	procedure NewtonMeshFixTJoints (const mesh: PNewtonMesh); cdecl; external newtondll;

	procedure NewtonMeshPolygonize (const mesh: pNewtonMesh); cdecl; external newtondll;
	procedure NewtonMeshTriangulate (const mesh: pNewtonMesh); cdecl; external newtondll;

	function NewtonMeshUnion (const mesh: pNewtonMesh; const clipper: pNewtonMesh; const clipperMatrix: pFloat): pNewtonMesh; cdecl; external newtondll;
	function NewtonMeshDifference (const mesh: pNewtonMesh; const clipper: pNewtonMesh; const clipperMatrix: pFloat): pNewtonMesh; cdecl; external newtondll;
	function NewtonMeshIntersection (const mesh: pNewtonMesh; const clipper: pNewtonMesh; const clipperMatrix: pFloat): pNewtonMesh; cdecl; external newtondll;
	procedure NewtonMeshClip (const mesh: pNewtonMesh; const clipper: pNewtonMesh; const clipperMatrix: pFloat; topMesh: pNewtonMesh; bottomMesh: pNewtonMesh); cdecl; external newtondll;

	procedure NewtonRemoveUnusedVertices(const mesh: PNewtonMesh; vertexRemapTable: pointer); cdecl; external newtondll;

{
	NEWTON_API void NewtonMeshBeginFace(const NewtonMesh *mesh);
	NEWTON_API void NewtonMeshAddFace(const NewtonMesh *mesh, int vertexCount, const dFloat* vertex, int strideInBytes, int materialIndex);
	NEWTON_API void NewtonMeshEndFace(const NewtonMesh *mesh);

	NEWTON_API void NewtonMeshBuildFromVertexListIndexList(const NewtonMesh *mesh,
		int faceCount, const int* const faceIndexCount, const int* const faceMaterialIndex, 
		const dFloat* const vertex, int vertexStrideInBytes, const int* const vertexIndex,
		const dFloat* const normal, int normalStrideInBytes, const int* const normalIndex,
		const dFloat* const uv0, int uv0StrideInBytes, const int* const uv0Index,
		const dFloat* const uv1, int uv1StrideInBytes, const int* const uv1Index);



	NEWTON_API void NewtonMeshGetVertexStreams (const NewtonMesh *mesh, 
												int vertexStrideInByte, dFloat* vertex,
												int normalStrideInByte, dFloat* normal,
												int uvStrideInByte0, dFloat* uv0,
												int uvStrideInByte1, dFloat* uv1);
	NEWTON_API void NewtonMeshGetIndirectVertexStreams(const NewtonMesh *mesh, 
													   int vertexStrideInByte, dFloat* vertex, int* vertexIndices, int* vertexCount,
													   int normalStrideInByte, dFloat* normal, int* normalIndices, int* normalCount,
													   int uvStrideInByte0, dFloat* uv0, int* uvIndices0, int* uvCount0,
													   int uvStrideInByte1, dFloat* uv1, int* uvIndices1, int* uvCount1);
	NEWTON_API void* NewtonMeshBeginHandle (const NewtonMesh *mesh); 
	NEWTON_API void NewtonMeshEndHandle (const NewtonMesh *mesh, void* Handle); 
	NEWTON_API int NewtonMeshFirstMaterial (const NewtonMesh *mesh, void* Handle); 
	NEWTON_API int NewtonMeshNextMaterial (const NewtonMesh *mesh, void* Handle, int materialId); 
	NEWTON_API int NewtonMeshMaterialGetMaterial (const NewtonMesh *mesh, void* Handle, int materialId); 
	NEWTON_API int NewtonMeshMaterialGetIndexCount (const NewtonMesh *mesh, void* Handle, int materialId); 
	NEWTON_API void NewtonMeshMaterialGetIndexStream (const NewtonMesh *mesh, void* Handle, int materialId, int* index); 
	NEWTON_API void NewtonMeshMaterialGetIndexStreamShort (const NewtonMesh *mesh, void* Handle, int materialId, short int* index); 

	NEWTON_API NewtonMesh* NewtonMeshCreateFirstSingleSegment (const NewtonMesh *mesh); 
	NEWTON_API NewtonMesh* NewtonMeshCreateNextSingleSegment (const NewtonMesh *mesh, const NewtonMesh *segment); 

	NEWTON_API int NewtonMeshGetTotalFaceCount (const NewtonMesh *mesh); 
	NEWTON_API int NewtonMeshGetTotalIndexCount (const NewtonMesh *mesh); 
	NEWTON_API void NewtonMeshGetFaces (const NewtonMesh *mesh, int* const faceIndexCount, int* const faceMaterial, void** const faceIndices); 


	NEWTON_API int NewtonMeshGetPointCount (const NewtonMesh *mesh); 
	NEWTON_API int NewtonMeshGetPointStrideInByte (const NewtonMesh *mesh); 
	NEWTON_API dFloat* NewtonMeshGetPointArray (const NewtonMesh *mesh); 
	NEWTON_API dFloat* NewtonMeshGetNormalArray (const NewtonMesh *mesh); 
	NEWTON_API dFloat* NewtonMeshGetUV0Array (const NewtonMesh *mesh); 
	NEWTON_API dFloat* NewtonMeshGetUV1Array (const NewtonMesh *mesh); 

	NEWTON_API int NewtonMeshGetVertexCount (const NewtonMesh *mesh); 
	NEWTON_API int NewtonMeshGetVertexStrideInByte (const NewtonMesh *mesh); 
	NEWTON_API dFloat* NewtonMeshGetVertexArray (const NewtonMesh *mesh); 


	NEWTON_API void* NewtonMeshGetFirstVertex (const NewtonMesh *mesh);
	NEWTON_API void* NewtonMeshGetNextVertex (const NewtonMesh *mesh, const void* vertex);
	NEWTON_API int NewtonMeshGetVertexIndex (const NewtonMesh *mesh, const void* vertex);

	NEWTON_API void* NewtonMeshGetFirstPoint (const NewtonMesh *mesh);
	NEWTON_API void* NewtonMeshGetNextPoint (const NewtonMesh *mesh, const void* point);
	NEWTON_API int NewtonMeshGetPointIndex (const NewtonMesh *mesh, const void* point);
	NEWTON_API int NewtonMeshGetVertexIndexFromPoint (const NewtonMesh *mesh, const void* point);
	

	NEWTON_API void* NewtonMeshGetFirstEdge (const NewtonMesh *mesh);
	NEWTON_API void* NewtonMeshGetNextEdge (const NewtonMesh *mesh, const void* edge);
	NEWTON_API void NewtonMeshGetEdgeIndices (const NewtonMesh *mesh, const void* edge, int* v0, int* v1);
	//NEWTON_API void NewtonMeshGetEdgePointIndices (const NewtonMesh *mesh, const void* edge, int* v0, int* v1);

	NEWTON_API void* NewtonMeshGetFirstFace (const NewtonMesh *mesh);
	NEWTON_API void* NewtonMeshGetNextFace (const NewtonMesh *mesh, const void* face);
	NEWTON_API int NewtonMeshIsFaceOpen (const NewtonMesh *mesh, const void* face);
	NEWTON_API int NewtonMeshGetFaceMaterial (const NewtonMesh *mesh, const void* face);
	NEWTON_API int NewtonMeshGetFaceIndexCount (const NewtonMesh *mesh, const void* face);
	NEWTON_API void NewtonMeshGetFaceIndices (const NewtonMesh *mesh, const void* face, int* indices);
	NEWTON_API void NewtonMeshGetFacePointIndices (const NewtonMesh *mesh, const void* face, int* indices);
	
}

	procedure NewtonMeshGetVertexStreams (const mesh: PNewtonMesh;
												VertexStrideInByte: integer; vertex: PFloat;
												NormalStrideInByte: integer; normal: PFloat;
												uvStrideInByte0: integer; uv0: PFloat;
                        uvStrideInByte1: integer; uv1: PFloat); cdecl; external newtondll;

	procedure NewtonMeshGetIndirectVertexStreams(const mesh: PNewtonMesh;
													   vetexStrideInByte: integer; vertex: PFloat ; vertexIndices: Pinteger; vertexCount: Pinteger;
													   normalStrideInByte: integer; normal: PFloat; normalIndices: Pinteger; normalCount: Pinteger;
													   uvStrideInByte0: integer; uv0: PFloat; uvIndices0: Pinteger; uvCount0: Pinteger;
                             uvStrideInByte1: integer; uv1: PFloat; uvIndices1: Pinteger; uvCount1: Pinteger); cdecl; external newtondll;



	function NewtonMeshFirstMaterial (const mesh: PNewtonMesh): integer; cdecl; external newtondll;
	function NewtonMeshNextMaterial (const mesh: PNewtonMesh; materialHandle: integer): integer; cdecl; external newtondll;
	function NewtonMeshMaterialGetMaterial (const mesh: PNewtonMesh; materialHandle: integer ): integer; cdecl; external newtondll;
	function NewtonMeshMaterialGetIndexCount (const mesh: PNewtonMesh; materialHandle: integer ): integer; cdecl; external newtondll;
	procedure NewtonMeshMaterialGetIndexStream (const mesh: PNewtonMesh; materialHandle: integer ; index: Pinteger); cdecl; external newtondll;
	procedure NewtonMeshMaterialGetIndexStreamShort (const mesh: PNewtonMesh; materialHandle: integer ; index: Psmallint); cdecl; external newtondll;

  // SHITLOAD MORE OF NEWTON MESH FUNCTIONS GO HERE.

(*
	// **********************************************************************************************
	//
	// Rag doll Joint container functions
	//
	// **********************************************************************************************

	function NewtonCreateRagDoll (const newtonWorld: PNewtonWorld): PNewtonRagDoll; cdecl; external newtondll;
	procedure NewtonDestroyRagDoll (const newtonWorld: PNewtonWorld; const ragDoll: PNewtonRagDoll); cdecl; external newtondll;

	procedure NewtonRagDollBegin (const ragDoll: PNewtonRagDoll); cdecl; external newtondll;
	procedure NewtonRagDollEnd (const ragDoll: PNewtonRagDoll); cdecl; external newtondll;


// deprecated in 1.53?	procedure NewtonRagDollSetFriction (const PNewtonRagDoll ragDoll, float friction);

	function NewtonRagDollFindBone (const ragDoll: PNewtonRagDoll; id: integer): PNewtonRagDollBone; cdecl; external newtondll;
// deprecated in 1.53?	NEWTON_API PNewtonRagDollBone NewtonRagDollGetRootBone (const PNewtonRagDoll ragDoll);

	procedure NewtonRagDollSetForceAndTorqueCallback (const ragDoll: PNewtonRagDoll; callback: PNewtonApplyForceAndTorque); cdecl; external newtondll;
	procedure NewtonRagDollSetTransformCallback (const ragDoll: PNewtonRagDoll; callback: PNewtonSetRagDollTransform); cdecl; external newtondll;
	function NewtonRagDollAddBone (const ragDoll: PNewtonRagDoll; const parent: PNewtonRagDollBone;
		                                                userData: pointer; mass: float; const matrix: Pfloat;
						const boneCollision: PNewtonCollision; const size: Pfloat): PNewtonRagDollBone; cdecl; external newtondll;

	function NewtonRagDollBoneGetUserData (const bone: PNewtonRagDollBone): Pointer; cdecl; external newtondll;
	function NewtonRagDollBoneGetBody (const bone: PNewtonRagDollBone): PNewtonBody; cdecl; external newtondll;
	procedure NewtonRagDollBoneSetID (const bone: PNewtonRagDollBone; id: integer); cdecl; external newtondll;


	procedure NewtonRagDollBoneSetLimits (const bone: PNewtonRagDollBone;
		                                        const coneDir: Pfloat; minConeAngle: float; maxConeAngle: float; maxTwistAngle: float;
					const bilateralConeDir: Pfloat; negativeBilateralConeAngle: float; positiveBilateralConeAngle: float); cdecl; external newtondll;

// deprecated in 1.53?	NEWTON_API PNewtonRagDollBone NewtonRagDollBoneGetChild (const PNewtonRagDollBone bone);
// deprecated in 1.53?	NEWTON_API PNewtonRagDollBone NewtonRagDollBoneGetSibling (const PNewtonRagDollBone bone);
// deprecated in 1.53?	NEWTON_API PNewtonRagDollBone NewtonRagDollBoneGetParent (const PNewtonRagDollBone bone);
// deprecated in 1.53?	procedure NewtonRagDollBoneSetLocalMatrix (const PNewtonRagDollBone bone, Pfloat matrix);
// deprecated in 1.53?	procedure NewtonRagDollBoneSetGlobalMatrix (const PNewtonRagDollBone bone, Pfloat matrix);

	procedure NewtonRagDollBoneGetLocalMatrix (const bone: PNewtonRagDollBone; matrix: Pfloat); cdecl; external newtondll;
	procedure NewtonRagDollBoneGetGlobalMatrix (const bone: PNewtonRagDollBone; matrix: Pfloat); cdecl; external newtondll;



	// **********************************************************************************************
	//
	// Vehicle Joint functions
	//
	// **********************************************************************************************
	function NewtonConstraintCreateVehicle (const newtonWorld: PNewtonWorld; const upDir: Pfloat; const body: PNewtonBody): PNewtonJoint; cdecl; external newtondll;
	procedure NewtonVehicleReset (const vehicle: PNewtonJoint); cdecl; external newtondll;
	procedure NewtonVehicleSetTireCallback (const vehicle: PNewtonJoint; update: PNewtonVehicleTireUpdate); cdecl; external newtondll;
	function NewtonVehicleAddTire (const vehicle: PNewtonJoint; const localMatrix: Pfloat; const pin: Pfloat; mass: float; width: float; radius: float;
		       suspesionShock: float; suspesionSpring: float; suspesionLength: float; userData: Pointer; collisionID: integer): Pointer; cdecl; external newtondll;
	procedure NewtonVehicleRemoveTire (const vehicle: PNewtonJoint; tireId: Pointer); cdecl; external newtondll;

	function NewtonVehicleGetFirstTireID (const vehicle: PNewtonJoint): Pointer; cdecl; external newtondll;
	function NewtonVehicleGetNextTireID (const vehicle: PNewtonJoint; tireId: Pointer): Pointer; cdecl; external newtondll;

	function NewtonVehicleTireIsAirBorne (const vehicle: PNewtonJoint; tireId: Pointer): integer; cdecl; external newtondll;
	function NewtonVehicleTireLostSideGrip (const vehicle: PNewtonJoint; tireId: Pointer): integer; cdecl; external newtondll;
	function NewtonVehicleTireLostTraction (const vehicle: PNewtonJoint; tireId: Pointer): integer; cdecl; external newtondll;

	function NewtonVehicleGetTireUserData (const vehicle: PNewtonJoint; tireId: Pointer): Pointer; cdecl; external newtondll;
	Function NewtonVehicleGetTireOmega (const vehicle: PNewtonJoint; tireId: Pointer): float ; cdecl; external newtondll;
	Function NewtonVehicleGetTireNormalLoad (const vehicle: PNewtonJoint; tireId: Pointer): float ; cdecl; external newtondll;
	Function NewtonVehicleGetTireSteerAngle (const vehicle: PNewtonJoint; tireId: Pointer): float ; cdecl; external newtondll;
	Function NewtonVehicleGetTireLateralSpeed (const vehicle: PNewtonJoint; tireId: Pointer): float ; cdecl; external newtondll;
	Function NewtonVehicleGetTireLongitudinalSpeed (const vehicle: PNewtonJoint; tireId: Pointer): float ; cdecl; external newtondll;
	procedure NewtonVehicleGetTireMatrix (const vehicle: PNewtonJoint; tireId: Pointer; matrix: Pfloat); cdecl; external newtondll;


	procedure NewtonVehicleSetTireTorque (const vehicle: PNewtonJoint; tireId: Pointer; torque: float); cdecl; external newtondll;
	procedure NewtonVehicleSetTireSteerAngle (const vehicle: PNewtonJoint; tireId: Pointer; angle: float); cdecl; external newtondll;
	
	procedure NewtonVehicleSetTireMaxSideSleepSpeed (const vehicle: PNewtonJoint; tireId: Pointer; speed: float); cdecl; external newtondll;
	procedure NewtonVehicleSetTireSideSleepCoeficient (const vehicle: PNewtonJoint; tireId: Pointer; coeficient: float); cdecl; external newtondll;
	procedure NewtonVehicleSetTireMaxLongitudinalSlideSpeed (const vehicle: PNewtonJoint; tireId: Pointer; speed: float); cdecl; external newtondll;
	procedure NewtonVehicleSetTireLongitudinalSlideCoeficient (const vehicle: PNewtonJoint; tireId: Pointer; coeficient: float); cdecl; external newtondll;

	Function NewtonVehicleTireCalculateMaxBrakeAcceleration (const vehicle: PNewtonJoint; tireId: Pointer): float ; cdecl; external newtondll;
	procedure NewtonVehicleTireSetBrakeAcceleration (const vehicle: PNewtonJoint; tireId: Pointer; accelaration: float; torqueLimit: float); cdecl; external newtondll;
*)

implementation

end.


