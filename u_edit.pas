{

<Zamaroht> your editor shouldn't let letters to be pressed in the coordinates or rotation boxes :p
<Zamaroht> if you touch something there, and then move the camera around with wasd, the keys get written there
<Zamaroht> or maybe remove focus from the box when right click is pressed in the 3d view

<Zamaroht> when using your editor Jernej , and trying to add an object, sometimes it will just show a small red square. I can't drag it around, but if I try to move it with the arrow keys, the object I had selected by the time I created this new object will spawn itself again

<Kalcor_> first thing people want to do is add lots of prefabs
<Kalcor_> find all the models they'll need to decorate the floor
<Kalcor_> that should be easy.. but when you scroll through the models, press Okay to add it to your prefabs
<Kalcor_> if you click Add again the selected prefap is not the last one you added
<Kalcor_> so it takes ages to scroll through and you end up having to type in the IDEs manually

<Kalcor_> but they really need to translate relative to the rotation, not purely on the X/Y
<Kalcor_> some strange things can happen with the mouse
<Kalcor_> you can select something and it'll move by itself
<Kalcor_> like there needs to be some pause between selecting and being able to move
<Kalcor_> when you duplicate the duplicated object needs to be slightly offset from the original
<Kalcor_> otherwise the 2 objects perfectly cover the other


- If GTA is running, the map won't be rendered. Maybe search for proccess and show a message if GTA is started?
- After right clicking in the 3D part, the text boxes do not lose focus. That is, WASD get printed in the boxes.
- More often than not, when clicking the "No vertex lighting" checkbox, the objects will stop rendering (they will show as red dots).
- Sometimes, after inserting a new object, a red square will appear instead of the object itself. If the square is clicked and the arrow keys pressed, the object will spawn out of it, but the square will remain. More objects can be spawned out of it by clicking and pressing arrow keys.

Badger: Hm. When I click on an object, and press any button with ctrl, it makes a copy of it
  JernejL: only ctrl+c should do that
  Badger: It's all the letters
  Badger: Like, I hold control and tap a twice and I have 2 new copies



}

unit u_edit;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, CheckLst, ExtCtrls, ThdTimer,
  ComCtrls, Buttons, clipbrd, tlhelp32, Math, jpeg,
  gtadll,
  textparser,
  u_Objects,
  FrustumCulling,
  Geometry,
  VectorTypes,
  RenderWareDFF,
  CameraClass,
  rwtxd,
  u_txdrecords,
  OpenGL12, SynEdit, Menus, ImgList,
  colobject, newton, FileCtrl
  , vectorgeometry, DNK_edit, uHashedStringList, Trackbar_32, inifiles,
  checkbox_32, DNK_RoundSlider, bitunit, Grids, registry, DNK_Panel,
  SynMemo;

{$L EliRT.obj}

function RT_GetVersion(pReserved: Pointer): longword; stdcall; external;
function xVirtualAllocEx(hProcess: longword; lpAddress: Pointer; dwSize: longword; flAllocationType: longword; flProtect: longword): Pointer;
  stdcall; external;
function xCreateRemoteThread(hProcess: longword; lpThreadAttributes: Pointer; dwStackSize: longword; lpStartAddress: Pointer; lpParameter: Pointer; dwCreationFlags: longword; var lpThreadId: cardinal): longword; stdcall; external;

const

  ScreenINFOF_PRIMARY = $1;

  hl_normal    = 0;
  hl_selected  = 1;
	hl_novertexl = 2;

	editor_regkey = 'SOFTWARE\JernejL\SAMP-MAPED\';

type

tagScreenINFOEXA = record
		cbSize:   DWORD;
		rcScreen: TRect;
		rcWork:   TRect;
		dwFlags:  DWORD;
		szDevice: array[0..CCHDEVICENAME] of AnsiChar;
	end;

	PScreenINFOEXA = ^tagScreenINFOEXA;

	HScreen = type integer;

	TScreenEnumProc = function(hm: HScreen; dc: HDC; r: PRect; l: LPARAM): boolean;
		stdcall;

	// engine records

	TScreen = packed record
		Rect: Trect;
		Name: array[0..127] of AnsiChar;
		def:  boolean;
		depth: integer;
	end;

  t3drect = array[0..1] of TVector3f;

  THit = packed record
    NCount: gluint;
    DNear,
    DFar:   gluint;
		Name:   gluint; //array[0..31] of GLuint; - one geom shouldn't be drawn twice, if this gets changed fix this.
  end;
	PHit = ^THit;

  TGtaEditor = class(TForm)
    Panel5:    TPanel;
    Image4:    TImage;
    Panel_imageoptionpanel: TPanel;
    Image3:    TImage;
		Image5:    TImage;
    Splitter1: TSplitter;
    ProgressBar1: TProgressBar;
		statuslabel: TLabel;
    ThreadedTimer1: TThreadedTimer;
    GlPanel:   TPanel;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    ThreadedTimer2: TThreadedTimer;
    TabSheet3: TTabSheet;
    Panel2:    TPanel;
    Image2:    TImage;
    btn_addtoprefabs: TSpeedButton;
    btn_deleteprefab: TSpeedButton;
    label_exstatus: TLabel;
    Panel1:    TPanel;
    Image1:    TImage;
    btn_addcameraview: TSpeedButton;
    btn_delcameraview: TSpeedButton;
    imgipls:   TMemo;
    Memo2:     TMemo;
    readwriter: TMemo;
    pnl_cam:   TPanel;
    Label1:    TLabel;
    Label3:    TLabel;
    Label2:    TLabel;
    view_interiors: TCheckBox;
    box_tex:   TCheckBox;
    pnl_favcap: TPanel;
    Imageo:    TImage;
		Label11:   TLabel;
    Panel3:    TPanel;
		Image6:    TImage;
		Label12:   TLabel;
		btn_inp:   TSpeedButton;
    OpenDialog1: TOpenDialog;
    btn_clear: TSpeedButton;
    btn_about: TSpeedButton;
    Panel6:    TPanel;
    Image8:    TImage;
    Label14:   TLabel;
    PopupMenu2: TPopupMenu;
    Copy1:     TMenuItem;
    btn_renobj: TSpeedButton;
    cb_cullzones: TCheckBox;
    cb_mode_nolighting: TCheckBox;
    btn_ipl:   TSpeedButton;
    SaveDialog2: TSaveDialog;
    Memo3:     TMemo;
    ProgressBar2: TProgressBar;
    btn_impipl: TSpeedButton;
    OpenDialog2: TOpenDialog;
    Panel8:    TPanel;
    btn_camerahere: TBitBtn;
    Edit4:     TDNK_edit;
    btn_showcode: TSpeedButton;
    pnlhelp:   TPanel;
    btn_sos:   TSpeedButton;
    ThreadedTimer3: TThreadedTimer;
    cb_nvc:    TCheckBox;
		lodaggresivity: TTrackbar_32;
    drawdistance: TTrackbar_32;
    streamlimit: TTrackbar_32;
		Bevel1:    TBevel;
    Bevel2:    TBevel;
    Panel9:    TPanel;
    Image10:   TImage;
    Label17:   TLabel;
    labelinstructions2: TLabel;
    cloneobj:  TSpeedButton;
    delobj:    TSpeedButton;
    ASDASDS1:  TMenuItem;
    renderpredabbtn: TBitBtn;
		btn_copyview: TBitBtn;
    btn_addnewobj: TSpeedButton;
		Bevel5:    TBevel;
    cameraviews: TListBox;
    SpeedButton1: TSpeedButton;
    NewPrefabs: TListBox;
    Panel11:   TPanel;
    ObjFilter: TDNK_edit;
    PFListFiltered: TListBox;
    lblfilterindiactor: TLabel;
    btnclearfilter: TSpeedButton;
    Splitter2: TSplitter;
    pnl_addide: TPanel;
    Label9:    TLabel;
    Label18:   TLabel;
    addidetext: TDNK_edit;
    addidedesc: TDNK_edit;
		btndec:    TBitBtn;
    btninc:    TBitBtn;
    Label19:   TLabel;
		renderone: TBitBtn;
    btn_renderranges: TBitBtn;
    Edit5: TDNK_edit;
    Edit6: TDNK_edit;
    Panel12:   TPanel;
    Panel13:   TPanel;
    Label20:   TLabel;
    Label21:   TLabel;
    waterr:    TTrackbar_32;
    waterg:    TTrackbar_32;
    watera:    TTrackbar_32;
    waterb:    TTrackbar_32;
    Panel14:   TPanel;
    Trackbar_321: TTrackbar_32;
    btn_animatewater: Tcheckbox_32;
    Label22:   TLabel;
    logger:    TSynEdit;
    Panel15:   TPanel;
    Image11:   TImage;
    btn_addprefabok: TSpeedButton;
		cb_fixup_addprefab: TCheckBox;
    Panel16:   TPanel;
		Label23:   TLabel;
    Panel17:   TPanel;
    Label24:   TLabel;
    Label25:   TLabel;
		Panel18:   TPanel;
    Panel19:   TPanel;
    Label26:   TLabel;
		Label27:   TLabel;
    Panel20:   TPanel;
    Label28:   TLabel;
    Label29:   TLabel;
    Panel21:   TPanel;
    Label30:   TLabel;
    Panel22:   TPanel;
    Label31:   TLabel;
    Panel23:   TPanel;
    Label16:   TLabel;
    Label32:   TLabel;
    Panel24:   TPanel;
    Label33:   TLabel;
    Label34:   TLabel;
    Panel25:   TPanel;
    Label35:   TLabel;
    Label36:   TLabel;
    Panel26:   TPanel;
    Label15:   TLabel;
    Label37:   TLabel;
    Label38:   TLabel;
    Panel27:   TPanel;
    Panel28:   TPanel;
    Label39:   TLabel;
    Label40:   TLabel;
    Label41:   TLabel;
    Panel29:   TPanel;
		Label42:   TLabel;
    Label43:   TLabel;
    Label44:   TLabel;
		Label45:   TLabel;
    btn_load:  TSpeedButton;
		cb_ambient: TCheckBox;
    Trackbar_322: TTrackbar_32;
		cb_realrendering: TCheckBox;
    btn_testmap: TSpeedButton;
    Bevel6:    TBevel;
    Label46:   TLabel;
    Panel30:   TPanel;
    btn_prefabresetzoom: TBitBtn;
    list_ideall: TListBox;
    Label48:   TLabel;
    inp_searchide: TDNK_edit;
    Label49:   TLabel;
    inp_bysizer: TDNK_edit;
    rb_bigger: TRadioButton;
    RadioButton2: TRadioButton;
    cb_bysize: TCheckBox;
    SpeedButton2: TSpeedButton;
    tab_newton: TTabSheet;
    btn_newton_a: TBitBtn;
    btn_buildworld: TBitBtn;
    CheckBox1: TCheckBox;
    Edit1: TDNK_edit;
    Edit2: TDNK_edit;
    Edit3: TDNK_edit;
    Memo1:     TMemo;
		oyea:      TMemo;
    TabSheet1: TTabSheet;
		cb_showlod: TCheckBox;
    brn_importpaste: TSpeedButton;
    Bevel3:    TBevel;
    Panel31:   TPanel;
    Image9:    TImage;
    Label47:   TLabel;
    cb_wire: TCheckBox;
		cb_showcoll: TCheckBox;
    dassaddsa: TBitBtn;
    fuckbutton: TBitBtn;
    btn_wantcols: TCheckBox;
		btn_loadwithcols: TSpeedButton;
    btn_cyclecolumns: TSpeedButton;
    btn_undo: TSpeedButton;
    Bevel4: TBevel;
    Panel37: TPanel;
    Image14: TImage;
    Memo4: TMemo;
    btn_report: TSpeedButton;
    wnd_advinfo: TPanel;
    Label60: TLabel;
    Label61: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    iadv_iden: TEdit;
    list_dfftextures: TSynMemo;
    mdl_name: TEdit;
    txdtextures: TSynMemo;
    inp_txdname: TEdit;
    ainp_interior: TEdit;
    ideflags: TCheckListBox;
    extras: TSynMemo;
    Panel38: TPanel;
    Image15: TImage;
    lbl_advinfocaption: TLabel;
    btn_closematerial: TSpeedButton;
    CheckBox2: TCheckBox;
    Panel39: TPanel;
    Image16: TImage;
    btn_gtfoaddide: TSpeedButton;
    ScrollBox1: TScrollBox;
    Label50: TLabel;
    lb_mmode: TListBox;
    Panel7: TPanel;
	Label5: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    inp_coordsedit: TDNK_edit;
    Panel10: TPanel;
    Label10: TLabel;
    inp_ide: TDNK_edit;
    btn_previouside: TBitBtn;
    btn_nextide: TBitBtn;
    inp_rotations: TDNK_edit;
    BitBtn1: TBitBtn;
    btn_rstangles: TBitBtn;
    Panel4: TPanel;
    Image7: TImage;
    Label13: TLabel;
    cb_autopick: Tcheckbox_32;
    lb_selection: TListBox;
    Panel32: TPanel;
    Image12: TImage;
    Label51: TLabel;
    Panel33: TPanel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    nudge_power: TTrackBar;
    inp_ax: TDNK_edit;
    inp_ay: TDNK_edit;
    inp_az: TDNK_edit;
    inp_rz: TDNK_edit;
    BitBtn2: TBitBtn;
    btn_thingsgodown: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    btn_rotatel: TBitBtn;
    btn_arrr: TBitBtn;
    inp_rx: TDNK_edit;
    btn_rxd: TBitBtn;
    btn_rxu: TBitBtn;
    inp_ry: TDNK_edit;
    btn_ryd: TBitBtn;
    btn_ryu: TBitBtn;
    Panel34: TPanel;
    inp_transformer: TDNK_edit;
    btn_transformall: TBitBtn;
    Panel35: TPanel;
    Image13: TImage;
    Label57: TLabel;
    Panel36: TPanel;
    nudgeup: TBitBtn;
    nudgedown: TBitBtn;
    nudgeleft: TBitBtn;
    nudgeright: TBitBtn;
    undostack: TListBox;
    convert_some_colls: TBitBtn;
    btn_exportmap: TBitBtn;
    fobj_frawdistance: TDNK_edit;
    Label67: TLabel;
    nudgepowerrot: TTrackBar;
    Label68: TLabel;

		function calculatecenterofmapping: t3drect;

		procedure switch2img(imgidx: integer);

    function ScreenVectorIntersectWithPlaneXY(const aScreenPoint: TVector; const z: single; var intersectPoint: TVector): boolean;

    function MouseWorldPos(x, y: integer): TVector;
    function ScreenVectorIntersectWithPlane(const aScreenPoint: TVector; const planePoint, planeNormal: TVector; var intersectPoint: TVector): boolean;
    function ScreenToVector(const aPoint: TVector): TVector;
    function ScreenToWorld(const aPoint: TVector): TVector;

    procedure performmousemoving(X, Y: integer);
    procedure CloneSelection(switchnewobj: boolean);

		procedure importreadwriter();

		procedure makeundogroup();
		procedure makeundo(iplf, ipli: integer; typ: integer; reason:string);

		procedure QuickSort(iLo, iHi: Integer) ;

		procedure updatenudgeedtors();
    procedure btn_loadClick(Sender: TObject);
    procedure Image5MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
		procedure GlPanelResize(Sender: TObject);
    procedure ThreadedTimer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
		procedure GlPanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure ThreadedTimer2Timer(Sender: TObject);
    procedure oldListView1DblClick(Sender: TObject);
    procedure btn_addcameraviewClick(Sender: TObject);
		procedure saveeditorinfo();
    procedure FormShow(Sender: TObject);
    procedure btn_delcameraviewClick(Sender: TObject);
    procedure btn_addtoprefabsClick(Sender: TObject);
    procedure insertobject(ide: integer; px, py, pz: single);
    procedure Deleteobject1Click(Sender: TObject);
    procedure btn_deleteprefabClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure inp_coordseditChange(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure GlPanelDblClick(Sender: TObject);
    procedure btn_inpClick(Sender: TObject);
    procedure btn_clearClick(Sender: TObject);
    procedure btn_aboutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure Copy1Click(Sender: TObject);
    procedure GlPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure renderpredabbtnClick(Sender: TObject);
    procedure btn_renobjClick(Sender: TObject);
    procedure GlPanelClick(Sender: TObject);
    procedure GlPanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure updateeditorfromipl;
    procedure Cloneobject1Click(Sender: TObject);
		procedure btn_iplClick(Sender: TObject);
    procedure btn_buildRCserverClick(Sender: TObject);
    procedure randomfunc2Click(Sender: TObject);
		procedure BitBtn3Click(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure btn_impiplClick(Sender: TObject);
		procedure btn_oldtestgtarClick(Sender: TObject);
    procedure btn_camerahereClick(Sender: TObject);
    procedure btn_previousideClick(Sender: TObject);
    procedure btn_nextideClick(Sender: TObject);
		procedure gencode();
    procedure btn_showcodeClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure refreshselectedobjectineditors();
    function cursorinview(): boolean;
    procedure mapedited();
    procedure renderbackground();
    procedure a2mp;
    procedure a2macc;
    procedure btn_sosClick(Sender: TObject);
    procedure ThreadedTimer3Timer(Sender: TObject);
    procedure btn_randomthingsClick(Sender: TObject);
    procedure cb_nvcClick(Sender: TObject);
    procedure Edit4Click(Sender: TObject);
		procedure btn_copyviewClick(Sender: TObject);
		function getcameracmds(): string;
    procedure btn_addnewobjClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cameraviewsDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
    procedure ObjFilterChange(Sender: TObject);
    procedure PFListFilteredDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
    procedure btnclearfilterClick(Sender: TObject);
		procedure renderoneClick(Sender: TObject);
    procedure btn_renderrangesClick(Sender: TObject);
    procedure btn_addprefabokClick(Sender: TObject);
    procedure btn_gtfoaddideClick(Sender: TObject);
		procedure addidetextChange(Sender: TObject);
    procedure btndecClick(Sender: TObject);
    procedure btnincClick(Sender: TObject);
    procedure cb_mode_nolightingClick(Sender: TObject);
		procedure SpeedButton2Click(Sender: TObject);
    procedure RunDebug(gta_sa_exe: string; txtfile: string);
    procedure btn_testmapClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btn_prefabresetzoomClick(Sender: TObject);
    procedure inp_searchideChange(Sender: TObject);
    procedure list_ideallClick(Sender: TObject);
	procedure pleaseloadmethis(ide: integer);
    procedure btn_newton_aClick(Sender: TObject);
    procedure btn_buildworldClick(Sender: TObject);
    procedure DebugShowCollision_POLY;
		procedure lb_mmodeDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
    procedure brn_importpasteClick(Sender: TObject);
    procedure btn_transformallClick(Sender: TObject);
    procedure btn_rstanglesClick(Sender: TObject);
    procedure dassaddsaClick(Sender: TObject);
    procedure fuckbuttonClick(Sender: TObject);
    procedure nudgeleftClick(Sender: TObject);
    procedure nudgerightClick(Sender: TObject);
    procedure nudgeupClick(Sender: TObject);
    procedure nudgedownClick(Sender: TObject);
    procedure nudge_powerChange(Sender: TObject);
		procedure nudgeraiseClick(Sender: TObject);
    procedure nudgelowClick(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
		procedure btn_thingsgodownClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure btn_rotatelClick(Sender: TObject);
    procedure btn_arrrClick(Sender: TObject);
    procedure inp_axChange(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure btn_loadwithcolsClick(Sender: TObject);
    procedure btn_rxdClick(Sender: TObject);
    procedure btn_rxuClick(Sender: TObject);
    procedure btn_rydClick(Sender: TObject);
    procedure btn_ryuClick(Sender: TObject);
    procedure TabSheet2Resize(Sender: TObject);
    procedure btn_cyclecolumnsClick(Sender: TObject);
    procedure btn_undoClick(Sender: TObject);
    procedure btn_reportClick(Sender: TObject);
    procedure btn_closematerialClick(Sender: TObject);
	procedure Image15MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure convert_some_collsClick(Sender: TObject);
    procedure btn_exportmapClick(Sender: TObject);
    procedure nudgepowerrotChange(Sender: TObject);
	private
		{ Private declarations }
		 procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest; 
  public
    { Public declarations }
    DC: hdc;
    rc: HGLRC;
    procedure Idle(Sender: TObject; var Done: boolean);
	procedure glDraw();
	procedure StreamView;
	function loadcoll(fobj: Pobjs): integer;
	procedure coll2newton(fname: string; coll: TColObject);

  end;

  TTxdUnit = class(TComponent)
  public
    filename: string;
		texture:  Ttxdloader;
    refcount: integer;
  end;

  TDFFUnit = class(TComponent)
  public
    IDE:      integer;
		model:    TDffLoader;
    markclear: boolean;
    lastframe: longword;
    lastdrawn: longword;
    copyflags: longword;
    lastrendercoords: TVector3f;
    txdref:   integer;
    collref:  TColObject;
    colllist: integer;
  end;

  Tmediastoreparent = class(TComponent)
  public

	end;

  Tlodinfo = packed record
    idenum:   integer;
    distance: single;
	end;

	Tlodarray = array[0..32] of Tlodinfo;

const
	SCREEN_NONE    = 0;
	SCREEN_XYPLANE = 1;
	SCREEN_XZPLANE = 2;
	SCREEN_YZPLANE = 3;
	SCREEN_XAXIS   = 4;
	SCREEN_YAXIS   = 5;
	SCREEN_ZAXIS   = 6;
	SCREEN_SCREEN  = 7;

	default_move_speed = 0.5;

	X = 0.525731112119133606;
	Z = 0.850650808352039932;


var

		MaxScreens: integer;
		Screens: array of TScreen;

	undogroup: integer = 0;

	blobs: single = 0.02;
	nudgemp: single = 0.02;
	nudgerotmp: single = 0.02;

  materialcolors: array[0..12] of longword = ($505000, $909000, $535E64, $32C092, $405F77, $7EE1E7, $FCE9A7, $446993, $D5C8BF, $A0AAAF, $63A52E, $E19364, $07ABF1

{
$005050,
$009090,
$645E53,
$92C032,
$775F40,
$E7E17E,
$A7E9FC,
$936944,
$BFC8D5,
$AFAAA0,
$2EA563,
$6493E1,
$F1AB07
});

  matmappers: array[0..178] of longword = (0, // Default
    0, // Tarmac
    0, // Tarmac (fucked)
    0, // Tarmac (really fucked)
	1, // Pavement
    1, // Pavement (fucked)
    2, // Gravel
    1, // Concrete (fucked)
    1, // Painted Ground
    3, // Grass (short, lush)
    3, // Grass (medium, lush)
    3, // Grass (long, lush)
    3, // Grass (short, dry)
    3, // Grass (medium, dry)
    3, // Grass (long, dry)
		3, // Golf Grass (rough)
		3, // Golf Grass (smooth)
    3, // Steep Slidy Grass
		9, // Steep Cliff
    4, // Flower Bed
    3, // Meadow
    4, // Waste Ground
    4, // Woodland Ground
    10, // Vegetation
    4, // Mud (wet)
    4, // Mud (dry)
    4, // Dirt
    4, // Dirt Track
    5, // Sand (deep)
    5, // Sand (medium)
    5, // Sand (compact)
    5, // Sand (arid)
    5, // Sand (more)
    5, // Sand (beach)
    1, // Concrete (beach)
    9, // Rock (dry)
    9, // Rock (wet)
    9, // Rock (cliff)
    11, // Water (riverbed)
    11, // Water (shallow)
    4, // Corn Field
    10, // Hedge
    7, // Wood (crates)
    7, // Wood (solid)
    7, // Wood (thin)
		6, // Glass
		6, // Glass Windows (large)
    6, // Glass Windows (small)
    12, // Empty1
    12, // Empty2
    8, // Garage Door
    8, // Thick Metal Plate
    8, // Scaffold Pole
    8, // Lamp Post
    8, // Metal Gate
    8, // Metal Chain fence
    8, // Girder
    8, // Fire Hydrant
    8, // Container
		8, // News Vendor
    12, // Wheelbase
    12, // Cardboard Box
    12, // Ped
    8, // Car
    8, // Car (panel)
    8, // Car (moving component)
    12, // Transparent Cloth
    12, // Rubber
    12, // Plastic
    9, // Transparent Stone
    7, // Wood (bench)
    12, // Carpet
    7, // Floorboard
    7, // Stairs (wood)
    5, // P Sand
		5, // P Sand (dense)
		5, // P Sand (arid)
    5, // P Sand (compact)
    5, // P Sand (rocky)
    5, // P Sand (beach)
    3, // P Grass (short)
    3, // P Grass (meadow)
    3, // P Grass (dry)
    4, // P Woodland
    4, // P Wood Dense
    2, // P Roadside
    5, // P Roadside Des
    4, // P Flowerbed
    4, // P Waste Ground
    1, // P Concrete
    12, // P Office Desk
    12, // P 711 Shelf 1
    12, // P 711 Shelf 2
    12, // P 711 Shelf 3
    12, // P Restuarant Table
    12, // P Bar Table
    5, // P Underwater (lush)
    5, // P Underwater (barren)
    5, // P Underwater (coral)
    5, // P Underwater (deep)
		4, // P Riverbed
    2, // P Rubble
    12, // P Bedroom Floor
    12, // P Kitchen Floor
    12, // P Livingroom Floor
		12, // P corridor Floor
		12, // P 711 Floor
    12, // P Fast Food Floor
    12, // P Skanky Floor
    9, // P Mountain
    4, // P Marsh
    10, // P Bushy
    10, // P Bushy (mix)
    10, // P Bushy (dry)
	10, // P Bushy (mid)
    3, // P Grass (wee flowers)
    3, // P Grass (dry, tall)
    3, // P Grass (lush, tall)
    3, // P Grass (green, mix)
    3, // P Grass (brown, mix)
    3, // P Grass (low)
    3, // P Grass (rocky)
    3, // P Grass (small trees)
    4, // P Dirt (rocky)
    4, // P Dirt (weeds)
    3, // P Grass (weeds)
    4, // P River Edge
    1, // P Poolside
    4, // P Forest (stumps)
    4, // P Forest (sticks)
    4, // P Forest (leaves)
    5, // P Desert Rocks
    4, // Forest (dry)
    4, // P Sparse Flowers
    2, // P Building Site
		1, // P Docklands
		1, // P Industrial
    1, // P Industrial Jetty
    1, // P Concrete (litter)
    1, // P Alley Rubbish
    2, // P Junkyard Piles
		4, // P Junkyard Ground
    4, // P Dump
    5, // P Cactus Dense
    1, // P Airport Ground
    4, // P Cornfield
    3, // P Grass (light)
    3, // P Grass (lighter)
    3, // P Grass (lighter 2)
    3, // P Grass (mid 1)
    3, // P Grass (mid 2)
    3, // P Grass (dark)
    3, // P Grass (dark 2)
    3, // P Grass (dirt mix)
    9, // P Riverbed (stone)
    4, // P Riverbed (shallow)
    4, // P Riverbed (weeds)
    5, // P Seaweed
    12, // Door
    12, // Plastic Barrier
    3, // Park Grass
    9, // Stairs (stone)
    8, // Stairs (metal)
    12, // Stairs (carpet)
    8, // Floor (metal)
		1, // Floor (concrete)
		12, // Bin Bag
    8, // Thin Metal Sheet
    8, // Metal Barrel
	12, // Plastic Cone
    12, // Plastic Dumpster
    8, // Metal Dumpster
    7, // Wood Picket Fence
    7, // Wood Slatted Fence
    7, // Wood Ranch Fence
    6, // Unbreakable Glass
    12, // Hay Bale
    12, // Gore
    12 // Rail Track
    );


	vdata: array [0..11] of Tvector3f = ((-X, 0.0, Z), (X, 0.0, Z), (-X, 0.0, -Z), (X, 0.0, -Z), (0.0, Z, X), (0.0, Z, -X), (0.0, -Z, X), (0.0, -Z, -X), (Z, X, 0.0), (-Z, X, 0.0), (Z, -X, 0.0), (-Z, -X, 0.0));

  tindices: array [0..19] of array [0..2] of GLint = ((0, 4, 1), (0, 9, 4), (9, 5, 4), (4, 5, 8), (4, 8, 1), (8, 10, 1), (8, 3, 10), (5, 3, 8), (5, 2, 3), (2, 7, 3), (7, 10, 3), (7, 6, 10), (7, 11, 6), (11, 0, 6), (0, 1, 6), (6, 1, 10), (9, 0, 11), (9, 11, 2), (9, 2, 5), (7, 2, 11));

  cursorseen: boolean = True;

  GtaEditor: TGtaEditor;
  GtaObject: Tmediastoreparent;

  nworld: PNewtonWorld = nil;

  newtonshapes: array[0..60000,0..1] of PNewtonCollision;
  newtonvehicles: array[0..2000] of PNewtonBody;

  mousecontrol: boolean = False;

  mousemovemodifier: single = default_move_speed;

  working_gta_dir: string;

  gcp:   boolean = False;
  oldcp: Tpoint;

  keys: TKeyboardState;

  mmp:    single = 1.0; // timed multiplier thing
  movacc: single = 1.0;
  hadtf:  boolean = False;

  fpsclock:  integer;
  LastTime, ElapsedTime, AppStart: longword;
  fpsframes: longword = 0;

  nw: Tvector3f = (-2048, 2048, 100.0);
  SE: Tvector3f = (2048, -2048, 0.0);

  identity: TMatrix4f = ((1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1));

  lastimg:   integer;
  maploaded: boolean = False;

  city:   TGTAMAP;
	Camera: TCamera;

  is_picking: boolean = False;
	buffer:   array[1..1400] of longword;  // Selection Buffer
  hits:     integer;                     // Number of hits
  viewport: tvector4i;

  selipl:  longword = 0;
  selitem: longword = 0;

  sel_ide: integer;

  Selection: gluint;

  cx, cy:  integer;
  mouse3d: Tvector3f = (0, 0, 0);

  loadnext: TStrings;

  codeupdating: boolean = False;

  tx, ty:    integer;
  nightmode: boolean = False;

  // both -90 = topdown
  rotation_x_axis: single = -90.0;
  rotation_y_axis: single = 350.0;
  zoom:    single = 50;
  zoomadd: single = 0;

  StartV:      TVector3d;
  MouseButton: integer;
  MouseXVal, MouseYVal: integer;
	Speed, MoveMode, AxisMode: byte;

  CenX, CenY, CenZ: glFloat;

  prefabrenderid: string;
  prefabextrastr: string = '';

  cameradrag: boolean = False;
	lastmouse:  Tpoint;

  vehicletxd, particletxd, backgroundtxd: integer;

  map_water_edge:    single = 3000;
  water_extreme_end: single = 15500;

  light_position: array[0..3] of GLfloat = (0, 0, 1000, 1);
  light_ambient:  array[0..3] of GLfloat = (1, 1, 1, 1);

  MatDiffuse:  array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  MatSpecular: array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  MatShine:    GLfloat = 30.0;

  lastMouseWorldPos: Tvector;

const
  CAMERA_SPEED = 0.005;

  nxt: array[0..2] of integer = (1, 2, 0);

function GetMonitorInfoA(hScreen: HScreen; lpScreenInfo: PScreenInfoEXA): boolean; stdcall; external user32;
function EnumDisplayMonitors(hdc: HDC; lprcIntersect: PRect; lpfnEnumProc: TScreenEnumProc; lData: pointer): boolean; stdcall; external user32;

implementation

uses U_main, u_sowcode, u_carcolors, u_report;

{$R *.DFM}

function CreateGlRotateMatrix(angle, x, y, z: single): TMatrix;
var
  axis:   TVector3f;
  b, c, ac, s: single;
  invLen: single;
begin

  angle := vectorgeometry.degtorad(angle);

  invLen := RSqrt(x * x + y * y + z * z);
  x      := x * invLen;
  y      := y * invLen;
  z      := z * invLen;

	Result := IdentityHmgMatrix;

  c := cos(angle);
  s := sin(angle);

  Result[0, 0] := (x * x) * (1 - c) + c;
  Result[1, 0] := x * y * (1 - c) - z * s;
  Result[2, 0] := x * z * (1 - c) + y * s;

  Result[0, 1] := y * x * (1 - c) + z * s;
  Result[1, 1] := (y * y) * (1 - c) + c;
	Result[2, 1] := y * z * (1 - c) - x * s;

  Result[0, 2] := x * z * (1 - c) - y * s;
  Result[1, 2] := y * z * (1 - c) + x * s;
  Result[2, 2] := (z * z) * (1 - c) + c;

end;

function GetDebugPrivs: boolean;
var
  hToken: THandle;
  xTokenPriv: TTokenPrivileges;
  oTokenPriv: TTokenPrivileges;
  iRetLen: DWord;
  la: longword;
begin
  Result := True;

  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    if LookupPrivilegeValue(nil, 'SeDebugPrivilege', xTokenPriv.Privileges[0].Luid) = False then
      ShowMessage('a problem.');
    xTokenPriv.PrivilegeCount := 1;
    xTokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    if AdjustTokenPrivileges(hToken, False, xTokenPriv, sizeof(xTokenPriv), oTokenPriv, iRetLen) = False then
    begin
      la := GetLastError();
      ShowMessage('permissions are fucked (' + IntToStr(la) + ') ' + SysErrorMessage(la));
      Result := False;
    end;
	end;
end;

function clamp360(angle: single): single;
begin
  Result := angle;

  if Result >= 360 then
    Result := Result - (system.trunc(Result) div 360 * 360);
  if Result < 0 then
    Result := 360 + Result - (system.trunc(Result) div 360 * 360);

  Assert((Result >= 0) and (Result <= 360), format('clamp360 failed for angle %f, produced %f!', [angle, Result]));

{
  while Result < 0 do
    Result := Result + 360;

  while Result > 360 do
    Result := Result - 360;
}
end;

procedure FindAll(const Path: string; Attr: integer; List: TStrings);
var
  Res:     TSearchRec;
  EOFound: boolean;
begin
  EOFound := False;
  if FindFirst(Path, Attr, Res) < 0 then
    exit
  else
    while not EOFound do
    begin
      List.Add(Res.Name);
      EOFound := FindNext(Res) <> 0;
	end;
  FindClose(Res);
end;

procedure cachewrite(serializeHandle: Pointer; const buffer: Pointer; size: integer); cdecl;
begin
  Tmemorystream(serializeHandle).Write(buffer^, size);
end;

procedure cacheread(serializeHandle: Pointer; const buffer: Pointer; size: integer); cdecl;
begin
  Tmemorystream(serializeHandle).Read(buffer^, size);
end;

function KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop:    BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle,
    FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := integer(TerminateProcess(OpenProcess(
        PROCESS_TERMINATE, BOOL(0),
        FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle,
      FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure Tgtaeditor.updateeditorfromipl;
begin
  // fill in the editor controls
  with city.IPL[selipl].InstObjects[selitem] do
  begin
		codeupdating := True;
		inp_ide.Text := IntToStr(id);
		fobj_frawdistance.text:= Format('%1.4f', [draw_distance]);

		inp_coordsedit.Text := Format('%1.4f, %1.4f, %1.4f', [Location[0], Location[1], Location[2]]);

		updatenudgeedtors();

    inp_rotations.Text := Format('%1.4f, %1.4f, %1.4f', [rux, ruy, ruz]);

    TrackBar1.Position := geometry.round(rux);
    TrackBar2.Position := geometry.round(ruy);
    TrackBar3.Position := geometry.round(ruz);

    if carcolor1 <> -1 then
    begin
      wnd_carcolorpicker.DrawGrid1.Row := carcolor1 div wnd_carcolorpicker.DrawGrid1.colCount;
	  wnd_carcolorpicker.DrawGrid1.Col := carcolor1 - wnd_carcolorpicker.DrawGrid1.Row * wnd_carcolorpicker.DrawGrid1.colcount;
    end
    else
    begin
      wnd_carcolorpicker.CheckBox1.Checked := carcolor1 = -1;
      wnd_carcolorpicker.DrawGrid1.Row     := 0;
      wnd_carcolorpicker.DrawGrid1.col     := 1;
    end;

    if carcolor2 <> -1 then
    begin
      wnd_carcolorpicker.DrawGrid2.Row := carcolor2 div wnd_carcolorpicker.DrawGrid2.colCount;
      wnd_carcolorpicker.DrawGrid2.Col := carcolor2 - wnd_carcolorpicker.DrawGrid2.Row * wnd_carcolorpicker.DrawGrid2.colcount;
    end
    else
    begin
      wnd_carcolorpicker.CheckBox2.Checked := carcolor2 = -1;
      wnd_carcolorpicker.DrawGrid2.Row     := 0;
      wnd_carcolorpicker.DrawGrid2.col     := 1;
    end;

    codeupdating := False;
  end;
end;

procedure ScreenToWorldCoordsDrag(X, Y: double; var OutV: TVector3d);
var
  Proj:     TMatrix4d;
  Modl:     TMatrix4d;
  ViewPort: TVector4i;
  FindV, NearV, DiffV: TVector3d;
begin
  //  wglMakeCurrent(dc, rc);

  glGetDoublev(GL_PROJECTION_MATRIX, @Proj);
  glGetDoublev(GL_MODELVIEW_MATRIX, @Modl);
  glGetIntegerv(GL_VIEWPORT, @ViewPort);
  Modl[3][0] := 0;
  Modl[3][1] := 0;
  Modl[3][2] := 0;
  Y := Viewport[3] - Y - 1;

  gluUnProject(X, Y, 0, Modl, Proj, ViewPort, @NearV[0], @NearV[1], @NearV[2]);
  gluUnProject(X, Y, 1, Modl, Proj, ViewPort, @DiffV[0], @DiffV[1], @DiffV[2]);

  DiffV[0] := DiffV[0] - NearV[0];
  DiffV[1] := DiffV[1] - NearV[1];
  DiffV[2] := DiffV[2] - NearV[2];

  FindV[2] := CenZ - NearV[2];
  FindV[0] := NearV[0] + (FindV[2] / DiffV[2]) * DiffV[0];
  FindV[1] := NearV[1] + (FindV[2] / DiffV[2]) * DiffV[1];

  OutV[0] := NearV[0] + FindV[0];
  OutV[1] := NearV[1] + FindV[1];
  OutV[2] := NearV[2] + FindV[2];
end;

procedure ScreenToWorldCoords(X, Y: double; ObjV: TVector3d; inMode: byte; var OutV: TVector3d);
var
  Proj:     TMatrix4d;
  Modl:     TMatrix4d;
  ViewPort: TVector4i;
  FindV, NearV, DiffV: TVector3d;
begin
  //  wglMakeCurrent(dc, rc);

  glGetDoublev(GL_PROJECTION_MATRIX, @Proj);
  glGetDoublev(GL_MODELVIEW_MATRIX, @Modl);
  glGetIntegerv(GL_VIEWPORT, @ViewPort);
  Y := Viewport[3] - Y - 1;

  gluUnProject(X, Y, 0, Modl, Proj, ViewPort, @NearV[0], @NearV[1], @NearV[2]);
  gluUnProject(X, Y, 1, Modl, Proj, ViewPort, @DiffV[0], @DiffV[1], @DiffV[2]);

  DiffV[0] := DiffV[0] - NearV[0];
  DiffV[1] := DiffV[1] - NearV[1];
  DiffV[2] := DiffV[2] - NearV[2];

  case inMode of
    SCREEN_XYPLANE:
    begin
      FindV[2] := ObjV[2] - NearV[2];
      FindV[0] := NearV[0] + (FindV[2] / DiffV[2]) * DiffV[0];
      FindV[1] := NearV[1] + (FindV[2] / DiffV[2]) * DiffV[1];

      OutV[0] := NearV[0] + FindV[0];
      OutV[1] := NearV[1] + FindV[1];
      OutV[2] := NearV[2] + FindV[2];
    end;
    SCREEN_XZPLANE:
    begin
      FindV[1] := ObjV[1] - NearV[1];
      FindV[0] := NearV[0] + (FindV[1] / DiffV[1]) * DiffV[0];
      FindV[2] := NearV[2] + (FindV[1] / DiffV[1]) * DiffV[2];

      OutV[0] := NearV[0] + FindV[0];
      OutV[1] := NearV[1] + FindV[1];
      OutV[2] := NearV[2] + FindV[2];
    end;
    SCREEN_YZPLANE:
    begin
      FindV[0] := ObjV[0] - NearV[0];
      FindV[1] := NearV[1] + (FindV[0] / DiffV[0]) * DiffV[1];
      FindV[2] := NearV[2] + (FindV[0] / DiffV[0]) * DiffV[2];

      OutV[0] := NearV[0] + FindV[0];
      OutV[1] := NearV[1] + FindV[1];
      OutV[2] := NearV[2] + FindV[2];
    end;
	SCREEN_XAXIS:
    begin
      FindV[1] := ObjV[1] - NearV[1];
      FindV[2] := ObjV[2] - NearV[2];
      FindV[0] := NearV[0] + (FindV[2] / DiffV[2]) * DiffV[0];

      OutV[0] := NearV[0] + FindV[0];
      OutV[1] := NearV[1] + FindV[1];
      OutV[2] := NearV[2] + FindV[2];
    end;
    SCREEN_YAXIS:
    begin
      FindV[0] := ObjV[0] - NearV[0];
      FindV[2] := ObjV[2] - NearV[2];
      FindV[1] := NearV[1] + (FindV[2] / DiffV[2]) * DiffV[1];

      OutV[0] := NearV[0] + FindV[0];
      OutV[1] := NearV[1] + FindV[1];
      OutV[2] := NearV[2] + FindV[2];
    end;
    SCREEN_ZAXIS:
    begin
      FindV[0] := ObjV[0] - NearV[0];
      FindV[1] := ObjV[1] - NearV[1];
      FindV[2] := NearV[2] + (FindV[1] / DiffV[1]) * DiffV[2];

      OutV[0] := NearV[0] + FindV[0];
      OutV[1] := NearV[1] + FindV[1];
      OutV[2] := NearV[2] + FindV[2];
    end;
  end;
end;


procedure ScanLinesFromRaw(stream: Tstream; Bitmap: TBitmap; linebytes: integer);
var
  y: longint;
begin
  for y := bitmap.Height - 1 downto 0 do
    stream.Read(Bitmap.ScanLine[y]^, linebytes);
end;

function GetOpenGLPos(X, Y: integer): Tvector3f;
var
  viewport:   Tvector4i;
  modelview:  tmatrix4d;
  projection: tmatrix4d;
  winZ, winY: single;
  rx, ry, rz: double;
  worldok:    longword;
begin
  glGetDoublev(GL_MODELVIEW_MATRIX, @modelview);                          // Get the Current Modelview matrix
  glGetDoublev(GL_PROJECTION_MATRIX, @projection);                        // Get the Current Projection Matrix
  glGetIntegerv(GL_VIEWPORT, @viewport);                                  // Get the Current Viewport

  winY := viewport[3] - y;                                                 //Change from Win32 to OpenGL coordinate system

  glReadPixels(X, geometry.Round(winY), 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @winZ);//Read the Depth value at the current X and Y position
  worldok := gluUnProject(X, winY, winZ,
    modelview, projection, viewport,                             // Get the vector for the current mouse position
    @rx, @ry, @rz);                         // And Return it from the function

  rz := rz;

  //  ry:= - ry;

  worldok := integer((rz > 0) and (rz < 8));

  Result[0] := rx;
  Result[1] := ry;
  Result[2] := rz;
end;

procedure GlEnable2D;
var
  vport: array[0..3] of integer;
begin
  glGetIntegerv(GL_VIEWPORT, @vPort);

  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  glOrtho(0, vPort[2], 0, vPort[3], -1, 1);

  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
end;

procedure GlDisable2D;
begin
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix;
end;

procedure startpicking;
begin
  fillchar(buffer, sizeof(buffer), #0);

  glSelectBuffer(high(buffer), @buffer);               // Tell OpenGL To Use Our Array For Selection

  // Puts OpenGL In Selection Mode. Nothing Will Be Drawn.  Object ID's and Extents Are Stored In The Buffer.
  glRenderMode(GL_SELECT);

  glInitNames;                   // Initializes The Name Stack

  // This Sets The 'viewport' Array To The Size And Location Of The Screen Relative To The Window
  glGetIntegerv(GL_VIEWPORT, @viewport);
  glMatrixMode(GL_PROJECTION);   // Selects The Projection Matrix
  glPushMatrix;                   // Push The Projection Matrix
  glLoadIdentity;                 // Resets The Matrix

  gluPickMatrix(cx, (viewport[3] - cy), 1.0, 1.0, viewport);  // Zoom into a small area where the mouse is
  gluPerspective(45.0, (viewport[2] - viewport[0]) / (viewport[3] - viewport[1]), 0.2, 10000.0);  // Do the perspective calculations. Last value = max clipping depth
  //  gluPerspective(45.0, (viewport[2]-viewport[0])/(viewport[3]-viewport[1]), 0.1, 10000.0); // Apply The Perspective Matrix

  //  glPushName(1337);               // Push At Least One Entry Onto The Stack

  glMatrixMode(GL_MODELVIEW);      // Select The Modelview Matrix
end;

procedure endpicking;

var
  //  tst:   string;
  i: longword;
  //  xfar, xnear: single;
  //  hit:   PHit;
  //  xyz:   tvector3f;

  //  idx: integer;
  //  ids: string;

  fof, fnf: single;

  column: array[0..127] of THit;

begin

  glMatrixMode(GL_PROJECTION);     // Select The Projection Matrix
  glPopMatrix;                     // Pop The Projection Matrix
  glMatrixMode(GL_MODELVIEW);      // Select The Modelview Matrix
  hits := glRenderMode(GL_RENDER); // Switch To Render Mode, Find Out How Many

  if (hits > 0) then
  begin

    fillchar(column, sizeof(column), 0);
    CopyMemory(@column[0], @buffer, hits * 16);

    selection := hits - 1;

    for i := 0 to hits - 1 do
    begin

      fof := column[i].DNear * (1 / MaxInt);
      fnf := column[selection].DNear * (1 / MaxInt);

      if fof <= fnf then
        Selection := i;
    end;

    selection := column[selection].Name;

  end;

end;

function IsTextureLoaded(Texname: string): integer;
var
  i: integer;
begin

  Result := -1;

  for i := 0 to GtaObject.ComponentCount - 1 do
    if GtaObject.Components[i] <> nil then
      if GtaObject.Components[i] is TTxdUnit then
        if (GtaObject.Components[i] as TTxdUnit).filename = Texname then
          if (GtaObject.Components[i] as TTxdUnit).texture <> nil then
          begin
            Result := i;
            exit;
          end;

end;

function IsCollLoaded(ColName: string): integer;
var
  i: integer;
begin

  Result := -1;

  for i := 0 to GtaObject.ComponentCount - 1 do
    if GtaObject.Components[i] <> nil then
      if GtaObject.Components[i] is TColObject then
        if (GtaObject.Components[i] as TColObject).Name = ColName then
          //          if (GtaObject.Components[i] as TColObject). <> nil then
        begin
          Result := i;
          exit;
        end;

end;

function rendermodel(idenum: integer): integer;
var
  i:   integer;
  dff: TDFFUnit;
begin
  Result := -1;
  if idenum = -1 then
    exit;

  for i := 0 to GtaObject.ComponentCount - 1 do
    if GtaObject.Components[i] <> nil then
      if GtaObject.Components[i] is TDFFUnit then
		if (GtaObject.Components[i] as TDFFUnit).IDE = idenum then
          if (GtaObject.Components[i] as TDFFUnit).model <> nil then
          begin

            //            dff:= GtaObject.Components[i] as TDFFUnit;
            //            outputdebugstring(pchar(dff.model));

            Result := i;
            exit;
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

function findIDE(ide: longword; wantindex: boolean): Pobjs;
var
	iide, ii, i: longword;
  needdff:  string;
  needtxd:  string;

  procedure lookupfile(findthis: string; imgidx: integer; var outidx: integer; var outimg: integer);
	begin

		outidx:= -1;
		outimg:= -1;

		outidx := city.imglist[imgidx].Indexof(findthis);

		if outidx <> -1 then
			outimg := imgidx;
  end;

begin
  Result := nil;

  for iide := 0 to high(city.IDE) do
  begin
    if city.IDE[iide].Objects <> nil then
      for ii := 0 to high(city.IDE[iide].Objects) do
      begin
        if city.IDE[iide].Objects[ii].ID = ide then
        begin

          if wantindex = True then
		  begin
{
						city.IDE[iide].Objects[ii].ModelName:= 'electromagnet1';
						city.IDE[iide].Objects[ii].TextureName:= 'electromagnet1';
}
            city.IDE[iide].Objects[ii].modelinimg := -1;
            city.IDE[iide].Objects[ii].txdinimg   := -1;

            needdff := lowercase(city.IDE[iide].Objects[ii].ModelName + '.dff');
						needtxd := lowercase(city.IDE[iide].Objects[ii].TextureName + '.txd');

						for i:= 4 downto 0 do begin
							if city.imglist[i] <> nil then
							begin
								if city.IDE[iide].Objects[ii].modelinimg = -1 then
									lookupfile(needdff, i, city.IDE[iide].Objects[ii].Modelidx, city.IDE[iide].Objects[ii].modelinimg);
								if city.IDE[iide].Objects[ii].TXDInIMG = -1 then
									lookupfile(needtxd, i, city.IDE[iide].Objects[ii].Textureidx, city.IDE[iide].Objects[ii].TXDInIMG);
							end;
						end;

						if city.IDE[iide].Objects[ii].Modelidx = -1 then
							gtaeditor.logger.Lines.Add('CANNOT FIND DFF: ' + needdff);

            if city.IDE[iide].Objects[ii].Textureidx = -1 then
              gtaeditor.logger.Lines.Add('CANNOT FIND TXD: ' + needtxd);

          end;

          Result := @city.IDE[iide].Objects[ii];
          exit;
        end;
      end;
  end;

end;

procedure UnloadUnneededTextures;
var
  i: integer;
  //  removedtexs: TStrings;
begin

  //  removedtexs:= TStringList.Create;

  if GtaObject = nil then
    exit;

  for i := GtaObject.ComponentCount - 1 downto 0 do
    if GtaObject.Components[i] <> nil then
      if GtaObject.Components[i] is TTxdUnit then
        if (GtaObject.Components[i] as TTxdUnit).texture <> nil then
          if (GtaObject.Components[i] as TTxdUnit).refcount < 1 then
          begin
            //         if ft > 10 then exit; // only 10 at a time!
			//GtaEditor.logger.lines.add('Unloading texture: ' + (GtaObject.Components[i] as TTxdUnit).filename + '.txd');
            (GtaObject.Components[i] as TTxdUnit).texture.unload;
            (GtaObject.Components[i] as TTxdUnit).texture := nil;
            (GtaObject.Components[i] as TTxdUnit).filename := '';

            // don't delete it - improper referencing by INDEX from tdffunit will make a rather nice crash, this might be connected to threading'n stuff..
            //            (GtaObject.Components[i] as TTxdUnit).Free;
            //            removedtexs.Add(inttostr(i))
          end;

  // remove all txdrefs - (GtaObject.Components[i] as TDFFUnit).txdref
{
  for i := GtaObject.ComponentCount - 1 downto 0 do
    if GtaObject.Components[i] <> nil then
      if GtaObject.Components[i] is TDFFUnit then
        if (GtaObject.Components[i] as TDFFUnit).model <> nil then with (GtaObject.Components[i] as TDFFUnit) do begin

          if removedtexs.IndexOf(inttostr(txdref)) <> -1 then begin
            txdref:= -1;
          end;

        end;
}
end;

procedure UnloadUnneededModels(forceunloadall: boolean);
var
  i:    integer;
  fobj: Pobjs;
  temp: tvector3f;
begin

  if GtaObject = nil then
    exit;

  for i := GtaObject.ComponentCount - 1 downto 0 do
    if GtaObject.Components[i] <> nil then
      if GtaObject.Components[i] is TDFFUnit then
        if (GtaObject.Components[i] as TDFFUnit).model <> nil then
          if ((GtaObject.Components[i] as TDFFUnit).lastframe < fpsframes) or (forceunloadall = True) then
          begin // wasn't drawn the last frame
            if ((GtaObject.Components[i] as TDFFUnit).lastdrawn + 5000 < gettickcount) or (forceunloadall = True) then
            begin // wasn't drawn in last 5 seconds

              // TODO: do not unload if within streaming range - if distance < drawdistance.position then

              temp := geometry.VectorSubtract(Camera.Position, (GtaObject.Components[i] as TDFFUnit).lastrendercoords);

              if (geometry.VectorLength(temp) < gtaeditor.drawdistance.Position) and (forceunloadall = False) then
                continue;

              if (GtaObject.Components[i] as TDFFUnit).model.used = True then
                continue; // can't unload it now, ffs.

              if (GtaObject.Components[i] as TDFFUnit).txdref <> -1 then
			  begin // decrese reference count
                (GtaObject.Components[(GtaObject.Components[i] as TDFFUnit).txdref] as TTxdUnit).refcount :=
                  (GtaObject.Components[(GtaObject.Components[i] as TDFFUnit).txdref] as TTxdUnit).refcount - 1;
              end;

              //fobj := findIDE(((GtaObject.Components[i] as TDFFUnit).IDE), False);
              //fobj.Model:= -1;

              //GtaEditor.logger.Lines.add('Unloading Model: ' + fobj.ModelName + '.dff');

              // free it up
              (GtaObject.Components[i] as TDFFUnit).model.Unload;
              (GtaObject.Components[i] as TDFFUnit).model.Free;
              (GtaObject.Components[i] as TDFFUnit).model := nil;
              (GtaObject.Components[i] as TDFFUnit).markclear := True;

              {

              city.IPL[iplfile].InstObjects[IplItem] LoadedModelIndex
              if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).IDE = id then begin

              }
            end;

          end;
end;

procedure glInit();
begin
  //glClearColor(0.0, 0.0, 0.0, 0.0);

  glClearColor(32 / 255, 39 / 255, 29 / 255, 0.0); // ugly green

  glShadeModel(GL_SMOOTH);

  glClearDepth(1.0);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LESS);

  gldisable(gl_dither);

  glenable(gl_texture_2d);
  gldisable(GL_BLEND);

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

{
  Camera.PositionCamera(
    80, 288 + 100, 16 - 100,
    80, 288, 17,
    0, 1, 0);

  Camera.MoveCamera(0.98);
}

  //  Camera.PositionCamera(80, 288, 16, 80, 288, 17, 0, 1, 0);

  Camera.Position[0] := 366.15;
  Camera.Position[1] := 1762.83;
  Camera.Position[2] := 158.91;

  Camera.View[0] := 365.31;
  Camera.View[1] := 1763.38;
  Camera.View[2] := 158.06;

  Camera.UpVector[0] := 0;
  Camera.UpVector[1] := 0;
  Camera.UpVector[2] := 1;

end;

procedure TGtaEditor.Deleteobject1Click(Sender: TObject);
var
	i: integer;
	tipl, titem: integer;
begin

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	makeundogroup();
	makeundo(tipl, titem, 1, 'deleted object');

	city.IPL[tipl].InstObjects[titem].deleted := True;

	if city.IPL[tipl].InstObjects[titem].lod <> -1 then begin
		makeundo(tipl, city.IPL[tipl].InstObjects[titem].lod, 1, 'deleted object');
		city.IPL[tipl].InstObjects[city.IPL[tipl].InstObjects[titem].lod].deleted := True;
	end;

	mapedited();

	end;

end;

procedure TGtaEditor.Idle(Sender: TObject; var Done: boolean);
var
  i: integer;
	chead: single;
	tipl, titem: integer;
begin

  if pnl_addide.Visible = True then
  begin
    renderpredabbtnClick(renderpredabbtn);
	exit;
  end;

  if CheckBox1.Checked = False then
    if GetForegroundWindow <> Handle then
      exit;

  Done := False;

  if maploaded = False then
    exit;

  LastTime    := ElapsedTime;
  ElapsedTime := GetTickCount() - AppStart;      // Calculate Elapsed Time
  ElapsedTime := (LastTime + ElapsedTime) div 2; // Average it out for smoother movement

	ElapsedTime := 20000;

	// 1000

	GetKeyboardState(keys);

  for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if (tipl > 0) and (titem > 0) then
		if (cursorinview() = True) and city.IPL[tipl].InstObjects[titem].added = True then
		begin

			if keys[vk_control] > 13 then
			begin
				if keys[vk_left] > 13 then
				begin
					makeundo(tipl, titem, 1, 'edited');
					city.IPL[tipl].InstObjects[titem].ruz := clamp360(city.IPL[tipl].InstObjects[titem].ruz + 0.01 * mmp);
          updateeditorfromipl;
          city.IPL[tipl].InstObjects[titem].SetGTARotation(city.IPL[tipl].InstObjects[titem].rux, city.IPL[tipl].InstObjects[titem].ruy, city.IPL[tipl].InstObjects[titem].ruz);
          a2mp;
        end;

				if keys[vk_right] > 13 then
				begin
					makeundo(tipl, titem, 1, 'edited');
          city.IPL[tipl].InstObjects[titem].ruz := clamp360(city.IPL[tipl].InstObjects[titem].ruz - 0.01 * mmp);
          updateeditorfromipl;
          city.IPL[tipl].InstObjects[titem].SetGTARotation(city.IPL[tipl].InstObjects[titem].rux, city.IPL[tipl].InstObjects[titem].ruy, city.IPL[tipl].InstObjects[titem].ruz);
          a2mp;
        end;

        if keys[vk_up] > 13 then
				begin
					makeundo(tipl, titem, 1, 'edited');
          city.IPL[tipl].InstObjects[titem].Location[2] := city.IPL[tipl].InstObjects[titem].Location[2] + 0.01 * mmp;
          updateeditorfromipl;
          a2mp;
        end;
        if keys[vk_down] > 13 then
				begin
					makeundo(tipl, titem, 1, 'edited');
          city.IPL[tipl].InstObjects[titem].Location[2] := city.IPL[tipl].InstObjects[titem].Location[2] - 0.01 * mmp;
          updateeditorfromipl;
          a2mp;
        end;
      end
      else
      begin
        // NO CONTROL KEY ZOMG

        if keys[vk_left] > 13 then
				begin
					chead := camera.getheading;
					makeundo(tipl, titem, 1, 'edited');
					city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] + (cos(chead + 1.57079633) * 0.01 * mmp);
          city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] + (sin(chead + 1.57079633) * 0.01 * mmp);
          updateeditorfromipl;
          a2mp;
        end;
        if keys[vk_right] > 13 then
        begin
					chead := camera.getheading;
					makeundo(tipl, titem, 1, 'edited');
          city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] - (cos(chead + 1.57079633) * 0.01 * mmp);
          city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] - (sin(chead + 1.57079633) * 0.01 * mmp);
          updateeditorfromipl;
          a2mp;
        end;


        if keys[vk_up] > 13 then
        begin
					chead := camera.getheading;
					makeundo(tipl, titem, 1, 'edited');
          city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] + (cos(chead) * 0.01 * mmp);
          city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] + (sin(chead) * 0.01 * mmp);
          updateeditorfromipl;
          a2mp;
        end;
        if keys[vk_down] > 13 then
        begin
					chead := camera.getheading;
					makeundo(tipl, titem, 1, 'edited');
          city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] - (cos(chead) * 0.01 * mmp);
					city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] - (sin(chead) * 0.01 * mmp);
          updateeditorfromipl;
          a2mp;
        end;
	  end;

      if ((keys[vk_down] > 13) or (keys[vk_up] > 13) or (keys[vk_left] > 13) or (keys[vk_right] > 13)) = False then
        mmp := 10;

    end; // cursor in view

	end;

  application.Tag := application.Tag + 1;
  glDraw;
  Inc(fpsclock);
  SwapBuffers(DC);
end;

procedure TGtaEditor.glDraw();
var
  i, l:     integer;
  x, y, z, w, s: single;
  Axis, temp: Tvector3f;
  Angle:    single;
  //  tobj:     Tobjs;
  distance: single;

  lodinfo: Tlodarray;
  fobj:    Pobjs;
  realvis: integer;

  function lookuplods(iplfile, IplItem: integer; cameradistance: single; recursivedepth: integer; lodarray: Tlodarray): integer;
  var
    thislod:      integer;
    drawdistance: single;
  begin

    if recursivedepth <> 0 then
      Result := -1;

    Result := -1;

    if iplfile > high(city.IPL) then
      exit;
    if IplItem > high(city.IPL[iplfile].InstObjects) then
      exit;

    Result := IplItem; // draw the one

    //EXIT;

    if recursivedepth > 10 then
    begin
      logger.Lines.add(format('recursive lod info %d %d', [iplfile, IplItem]));
      Result := -1;
      exit; // so much for a infinite loop!
    end;

	thislod := city.IPL[iplfile].InstObjects[IplItem].lod;
    if thislod = -1 then
      exit; // no lods!

	fobj := FindIDE(city.IPL[iplfile].InstObjects[IplItem].id, False); // we need the ide info for this object
    if fobj <> nil then
    begin

      //    lodarray[recursivedepth].idenum:= fobj.ID;
      //    lodarray[recursivedepth].distance:= fobj.DrawDist;

      drawdistance := fobj.DrawDist * (lodaggresivity.position + 1);

      if cameradistance > drawdistance then // distance is close enough, and the object HAS lod (meaning it's not a lod or no-lod object)
        Result := lookuplods(iplfile, city.IPL[iplfile].InstObjects[IplItem].lod, cameradistance, recursivedepth + 1, lodarray);
    end;

  end;

  /////////////
  procedure rendercoll(coll: TColObject; selectionmode: boolean);
  var
    hilitemodel: integer;
    alphatrickery: boolean;
	rotang:  vectortypes.Tmatrix4f;
    i, j, k: integer;
    normal:  TVector3f;
    verts:   array[0..3] of TVector3f;
  begin

	with coll do
	begin

			glPushAttrib(GL_ALL_ATTRIB_BITS);

      glColor4f(1, 1, 1, 1);

      gldisable(gl_texture_2d);
      glDisable(gl_cull_face);

      glenable(gl_lighting);

      glBegin(GL_TRIANGLES);

      k := 0; // 0 = model, 1 = shadow

      if selectionmode then
        glcolor4f(0.5, 0.0, 0.0, 1.0)
      else
        glcolor4f(0.5, 0.5, 0.5, 1.0);


	  for i := 0 to length(Face[k]) - 1 do
      begin

		if not selectionmode then
          glcolor3ubv(@materialcolors[matmappers[face[k][i].surf.mat]]);

        normal := GetFaceNormal(
          Vertex[k][face[k][i].c].v,
		  Vertex[k][face[k][i].b].v,
		  Vertex[k][face[k][i].a].v
		  );

		glNormal3f(normal[0], normal[1], normal[2]);

						{
						glColor3f(  Vertex[k][ face[k][i].c  ].v[0],
									Vertex[k][ face[k][i].c  ].v[1],
									Vertex[k][ face[k][i].c  ].v[2]
						);
						}
		glVertex3f(Vertex[k][face[k][i].c].v[0],
		  Vertex[k][face[k][i].c].v[1],
          Vertex[k][face[k][i].c].v[2]);

		glVertex3f(Vertex[k][face[k][i].b].v[0],
		  Vertex[k][face[k][i].b].v[1],
		  Vertex[k][face[k][i].b].v[2]);

		glVertex3f(Vertex[k][face[k][i].a].v[0],
		  Vertex[k][face[k][i].a].v[1],
		  Vertex[k][face[k][i].a].v[2]);

	  end;

      glend;

	  for i := 0 to length(Box) - 1 do
	  begin

        glBegin(gl_quads);

        if not selectionmode then
          glcolor3ubv(@materialcolors[matmappers[box[i].surf.mat]]);

        verts[0] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].min[1], box[i].min[2]);
        verts[1] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].min[1], box[i].min[2]);
        verts[2] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].min[1], box[i].max[2]);
        verts[3] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].min[1], box[i].max[2]);

        normal := GetFaceNormal(verts[0], verts[1], verts[2]);
        glNormal3f(normal[0], normal[1], normal[2]);

        glvertex3fv(@verts[0][0]);
        glvertex3fv(@verts[1][0]);
        glvertex3fv(@verts[2][0]);
        glvertex3fv(@verts[3][0]);

        verts[0] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].min[1], box[i].max[2]);
		verts[1] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].min[1], box[i].max[2]);
        verts[2] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].max[1], box[i].max[2]);
        verts[3] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].max[1], box[i].max[2]);

        normal := GetFaceNormal(verts[0], verts[1], verts[2]);
        glNormal3f(normal[0], normal[1], normal[2]);

        glvertex3fv(@verts[0][0]);
        glvertex3fv(@verts[1][0]);
        glvertex3fv(@verts[2][0]);
        glvertex3fv(@verts[3][0]);

        verts[0] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].min[1], box[i].min[2]);
        verts[1] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].max[1], box[i].min[2]);
        verts[2] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].max[1], box[i].min[2]);
        verts[3] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].min[1], box[i].min[2]);

        normal := GetFaceNormal(verts[0], verts[1], verts[2]);
        glNormal3f(normal[0], normal[1], normal[2]);

        glvertex3fv(@verts[0][0]);
        glvertex3fv(@verts[1][0]);
        glvertex3fv(@verts[2][0]);
        glvertex3fv(@verts[3][0]);

        verts[0] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].min[1], box[i].min[2]);
        verts[1] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].max[1], box[i].min[2]);
        verts[2] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].max[1], box[i].max[2]);
        verts[3] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].min[1], box[i].max[2]);

        normal := GetFaceNormal(verts[0], verts[1], verts[2]);
        glNormal3f(normal[0], normal[1], normal[2]);

        glvertex3fv(@verts[0][0]);
        glvertex3fv(@verts[1][0]);
        glvertex3fv(@verts[2][0]);
        glvertex3fv(@verts[3][0]);

        verts[0] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].min[1], box[i].min[2]);
        verts[1] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].min[1], box[i].max[2]);
        verts[2] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].max[1], box[i].max[2]);
        verts[3] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].max[1], box[i].min[2]);

        normal := GetFaceNormal(verts[0], verts[1], verts[2]);
        glNormal3f(normal[0], normal[1], normal[2]);

        glvertex3fv(@verts[0][0]);
        glvertex3fv(@verts[1][0]);
        glvertex3fv(@verts[2][0]);
        glvertex3fv(@verts[3][0]);

        verts[0] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].max[1], box[i].min[2]);
        verts[1] := vectorgeometry.AffineVectorMake(box[i].min[0], box[i].max[1], box[i].max[2]);
        verts[2] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].max[1], box[i].max[2]);
        verts[3] := vectorgeometry.AffineVectorMake(box[i].max[0], box[i].max[1], box[i].min[2]);

        normal := GetFaceNormal(verts[0], verts[1], verts[2]);
        glNormal3f(normal[0], normal[1], normal[2]);

        glvertex3fv(@verts[0][0]);
        glvertex3fv(@verts[1][0]);
        glvertex3fv(@verts[2][0]);
        glvertex3fv(@verts[3][0]);

{
                          glvertex3f(box[i].min[0], box[i].min[1], box[i].min[2]);
                          glvertex3f(box[i].max[0], box[i].min[1], box[i].min[2]);
                          glvertex3f(box[i].max[0], box[i].min[1], box[i].max[2]);
                          glvertex3f(box[i].min[0], box[i].min[1], box[i].max[2]);

                          glvertex3f(box[i].min[0], box[i].min[1], box[i].max[2]);
                          glvertex3f(box[i].max[0], box[i].min[1], box[i].max[2]);
                          glvertex3f(box[i].max[0], box[i].max[1], box[i].max[2]);
                          glvertex3f(box[i].min[0], box[i].max[1], box[i].max[2]);

                          glvertex3f( box[i].min[0], box[i].min[1], box[i].min[2]);
                          glvertex3f( box[i].min[0], box[i].max[1], box[i].min[2]);
                          glvertex3f( box[i].max[0], box[i].max[1], box[i].min[2]);
                          glvertex3f( box[i].max[0], box[i].min[1], box[i].min[2]);

                          glvertex3f( box[i].max[0], box[i].min[1], box[i].min[2]);
                          glvertex3f( box[i].max[0], box[i].max[1], box[i].min[2]);
                          glvertex3f( box[i].max[0], box[i].max[1], box[i].max[2]);
                          glvertex3f( box[i].max[0], box[i].min[1], box[i].max[2]);

                          glvertex3f( box[i].min[0], box[i].min[1], box[i].min[2]);
                          glvertex3f( box[i].min[0], box[i].min[1], box[i].max[2]);
                          glvertex3f( box[i].min[0], box[i].max[1], box[i].max[2]);
                          glvertex3f( box[i].min[0], box[i].max[1], box[i].min[2]);

                          glvertex3f( box[i].min[0], box[i].max[1], box[i].min[2]);
                          glvertex3f( box[i].min[0], box[i].max[1], box[i].max[2]);
                          glvertex3f( box[i].max[0], box[i].max[1], box[i].max[2]);
                          glvertex3f( box[i].max[0], box[i].max[1], box[i].min[2]);
}
        glend;

      end;

	  for i := 0 to length(Sphere) - 1 do
      begin

        glPushMatrix;
        glTranslatef(Sphere[i].pos[0], Sphere[i].pos[1], Sphere[i].pos[2]);

        glScalef(Sphere[i].r, Sphere[i].r, Sphere[i].r);

        for j := 0 to 19 do
        begin
          glBegin(GL_TRIANGLES);

          if not selectionmode then
            glcolor3ubv(@materialcolors[matmappers[sphere[i].surf.mat]]);

          normal := GetFaceNormal(vdata[tindices[j][0]], vdata[tindices[j][1]], vdata[tindices[j][2]]);
          glNormal3f(normal[0], normal[1], normal[2]);

          glVertex3fv(@vdata[tindices[j][0]][0]);
          glVertex3fv(@vdata[tindices[j][1]][0]);
          glVertex3fv(@vdata[tindices[j][2]][0]);
		  glEnd();
        end;

        glPopMatrix;

	  end;

      gldisable(gl_lighting);

      glPopAttrib;

    end; // with coll do

  end;
  //////////

  procedure drawthisobject(iplfile, IplItem: integer; var distance: single; nightcolors: boolean; order: integer);
  var
    hilitemodel: integer;
    alphatrickery: boolean;
    rotang:  vectortypes.Tmatrix4f;
    i, j, k: integer;
    normal:  TVector3f;
    verts:   array[0..3] of TVector3f;
  begin

    if IplItem = -1 then
      exit;

    if iplfile > high(city.IPL) then
      exit; //showmessage('screwed #1');
    if IplItem > high(city.IPL[iplfile].InstObjects) then
      exit; //showmessage('screwed #2');

    with city.IPL[iplfile].InstObjects[IplItem] do
      if deleted = False then
      begin

        if LoadedModelIndex <> -1 then
        begin // if the model is loaded & ready

          if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).IDE = id then
			if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).markclear = False then
            begin

			  if (bitunit.IsBitSet((GtaObject.Components[LoadedModelIndex] as TDFFUnit).copyflags, 21) = True) or (bitunit.IsBitSet((GtaObject.Components[LoadedModelIndex] as TDFFUnit).copyflags, 2) = True) or (bitunit.IsBitSet((GtaObject.Components[LoadedModelIndex] as TDFFUnit).copyflags, 3) = True) then
                alphatrickery := True
              else
                alphatrickery := False;

              if cb_realrendering.Checked = True then
              begin
                if (alphatrickery = True) and (order = 0) then
                  exit;
                if (alphatrickery = False) and (order = 1) then
                  exit;
              end;

              if alphatrickery then
                GlDisable(GL_CULL_FACE)
              else
                Glenable(GL_CULL_FACE);

              {
              0000000000000000000000000000100 = ALPHA Transparency 1
              0000000000000000000000000001000 = ALPHA Transparency 2 *
              0000000001000000000000000000000 = Disable Backface Culling
              }

              glPushMatrix;
              glTranslatef(Location[0], Location[1], Location[2]);

              // preprocess quarternion rotations
              X := rx;
              Y := ry;
              Z := rz;
              W := -rw;
              S := Sqrt(1.0 - W * W);

              // divide by zero
              if not (S = 0) then
              begin
                Axis[0] := X / S;
                Axis[1] := Y / S;
                Axis[2] := Z / S;
                Angle   := 2 * geometry.ArcCos(W);

                if not (Angle = 0) then
                begin

                  rotang := CreateGlRotateMatrix(Angle * 180 / Pi, Axis[0], Axis[1], Axis[2]);
                  glMultMatrixf(@rotang[0, 0]);

                  //glRotatef(Angle * 180 / Pi, Axis[0], Axis[1], Axis[2]);

                end;
              end;

              if is_picking = True then
                glPushName(MakeLong(iplfile, IplItem));

			  if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model <> nil then
					hilitemodel := hl_normal;

			  if (lb_selection.Items.indexof(format('%d %d', [iplfile, iplitem])) <> -1) or ((selipl = iplfile) and (IplItem = selitem)) then
//			  if (selipl = iplfile) and (IplItem = selitem) then
					hilitemodel := hl_selected;

			  if (cb_mode_nolighting.Checked = True) and (hilitemodel <> 1) then
				hilitemodel := hl_novertexl;

              if carcolor1 = -1 then
                (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.primcolor := city.colors.colors[1]
              else
                (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.primcolor := city.colors.colors[carcolor1];

              if carcolor2 = -1 then
                (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.seccolor := city.colors.colors[1]
              else
                (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.seccolor := city.colors.colors[carcolor2];


			  if cb_showcoll.Checked = True then
              begin
				if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).collref <> nil then
				begin
				  // do it now

									glPushAttrib(GL_ALL_ATTRIB_BITS);

									if cb_wire.checked then
										glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
									else
										glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);


									if (hilitemodel > 0) then
									begin

										rendercoll((GtaObject.Components[LoadedModelIndex] as TDFFUnit).collref, True);

									end
									else
									begin

										if ((GtaObject.Components[LoadedModelIndex] as TDFFUnit).colllist = -1) then
										begin

											(GtaObject.Components[LoadedModelIndex] as TDFFUnit).colllist := glGenLists(1);
											glNewList((GtaObject.Components[LoadedModelIndex] as TDFFUnit).colllist, GL_COMPILE);

											rendercoll((GtaObject.Components[LoadedModelIndex] as TDFFUnit).collref, False);

											glEndList;

										end
										else
										begin
											glCallList((GtaObject.Components[LoadedModelIndex] as TDFFUnit).colllist);
										end;
									end;

                  glPopAttrib();

                end;
              end
              else
              begin
				if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).txdref <> -1 then
					(GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.glDraw((GtaObject.Components[(GtaObject.Components[LoadedModelIndex] as TDFFUnit).txdref] as TTxdUnit).texture, (GtaObject.Components[vehicletxd] as TTxdUnit).texture, False, hilitemodel, nightcolors, id <= 611)
				else
					(GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.glDraw(nil, nil, False, hilitemodel, nightcolors, false);
			   end;

              (GtaObject.Components[LoadedModelIndex] as TDFFUnit).lastdrawn := GetTickCount;
              (GtaObject.Components[LoadedModelIndex] as TDFFUnit).lastframe := fpsframes;

              (GtaObject.Components[LoadedModelIndex] as TDFFUnit).lastrendercoords := Location;


              if is_picking = True then
                glPopName;


              glpopmatrix;

            end
            else
              LoadedModelIndex := -1; // no longer valid, got streamed out?
        end
        else
        begin

          LoadedModelIndex := rendermodel(id); // finds model (if loaded)

          gldisable(gl_texture_2d);
          glpointsize(10);
          glcolor4f(0.5, 0, 0, 1);
          glbegin(gl_points);
          glvertex3fv(@location);
          glend;

          if ((distance < 0.0) or (distance < drawdistance.position) and (LoadedModelIndex = -1)) then
          begin
            if loadnext.Count < streamlimit.Position then
              if loadnext.indexof(IntToStr(id)) = -1 then
              begin
				// logger.lines.add('adding to streamer: ' + inttostr(id));
                pleaseloadmethis(id);
              end;
		  end;

        end;

      end;

  end;

begin

  if city = nil then
    exit;

  if city.loaded = False then
    exit;

  if pnl_addide.Visible = True then
    exit;

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);  // Clear The Screen And The Depth Buffer
  glLoadIdentity;                                       // Reset The View

  renderbackground();

  if cb_ambient.Checked = True then
  begin
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

    // Enable Lighting

    light_ambient[0] := Trackbar_322.position * 1 / 255;
    light_ambient[1] := Trackbar_322.position * 1 / 255;
    light_ambient[2] := Trackbar_322.position * 1 / 255;
{
  MatDiffuse[0]:= Trackbar_322.position * 1 / 255;
  MatDiffuse[1]:= Trackbar_322.position * 1 / 255;
  MatDiffuse[2]:= Trackbar_322.position * 1 / 255;
}
    glLightfv(GL_LIGHT0, GL_AMBIENT, @light_ambient);
    glLightfv(GL_LIGHT0, GL_POSITION, @light_position);

    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, @MatDiffuse);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @MatSpecular);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @MatShine);

    glenable(GL_COLOR_MATERIAL);
    glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
    glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 0);  //sets lighting to one-sided
    //  glColorMaterial(GL_FRONT,GL_DIFFUSE);
  end
  else
  begin
    gldisable(GL_LIGHTING);
    gldisable(GL_LIGHT0);
  end;

  glmatrixmode(GL_MODELVIEW);

  fpsframes := fpsframes + 1;


  if ((keys[vk_shift] > 13) or (keys[VK_RBUTTON] > 13)) and (gcp = True) then
    Camera.MoveCameraByMouse;

  // Give OpenGL our camera position, then camera view, then camera up vector
  gluLookAt(Camera.Position[0], Camera.Position[1], Camera.Position[2],
    Camera.View[0], Camera.View[1], Camera.View[2],
    Camera.UpVector[0], Camera.UpVector[1], Camera.UpVector[2]);

  CenX := Camera.Position[0];
  CenY := Camera.Position[1];
  CenZ := Camera.Position[2];

  glColor3f(1, 1, 1);
{
  // SEVER
  //  glColor4f(1, 0, 0, 1);
  glbegin(gl_quads);
  glTexCoord2f(0.25, 0);
  glVertex3f(NW[0], NW[1], SE[2]);
  glTexCoord2f(0, 0);
  glVertex3f(SE[0], NW[1], SE[2]);
  glTexCoord2f(0, 1);
  glVertex3f(SE[0], SE[1], SE[2]);
  glTexCoord2f(0.25, 1);
  glVertex3f(NW[0], SE[1], SE[2]);
  glend;

  // JUG
  //  glColor4f(0, 1, 0, 1);
  glbegin(gl_quads);
  glTexCoord2f(0.5, 0);
  glVertex3f(NW[0], NW[1], NW[2]);
  glTexCoord2f(0.75, 0);
  glVertex3f(SE[0], NW[1], NW[2]);
  glTexCoord2f(0.75, 1);
  glVertex3f(SE[0], SE[1], NW[2]);
  glTexCoord2f(0.5, 1);
  glVertex3f(NW[0], SE[1], NW[2]);
  glend;

  // VZHOD
  //  glColor4f(0, 0, 1, 1);
  glbegin(gl_quads);
  glTexCoord2f(0.5, 1);
  glVertex3f(NW[0], SE[1], NW[2]);
  glTexCoord2f(0.25, 1);
  glVertex3f(NW[0], SE[1], SE[2]);
  glTexCoord2f(0.25, 0);
  glVertex3f(NW[0], NW[1], SE[2]);
  glTexCoord2f(0.5, 0);
  glVertex3f(NW[0], NW[1], NW[2]);
  glend;

  // ZAHOD
  //  glColor4f(0, 0, 0, 1);
  glbegin(gl_quads);
  glTexCoord2f(0.75, 1);
  glVertex3f(SE[0], SE[1], NW[2]);
  glTexCoord2f(1, 1);
  glVertex3f(SE[0], SE[1], SE[2]);
  glTexCoord2f(1, 0);
  glVertex3f(SE[0], NW[1], SE[2]);
  glTexCoord2f(0.75, 0);
  glVertex3f(SE[0], NW[1], NW[2]);
  glend;
}

  glenable(GL_CULL_FACE);
  Frustum.Calculate;

  if is_picking = True then
    startpicking;




if is_picking = false then begin
  // draw water

	glPushAttrib(GL_ALL_ATTRIB_BITS);
	gldisable(gl_texture_2d);

	if particletxd <> -1 then
	begin
		glBindTexture(GL_TEXTURE_2D, (GtaObject.Components[particletxd] as TTxdUnit).texture.findglid('waterclear256'));
		glenable(gl_texture_2d);

		if CheckBox2.checked = true then
			gldisable(gl_texture_2d);

		glenable(GL_TEXTURE_GEN_S);
		glenable(GL_TEXTURE_GEN_T);
		glTexGend(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
		glTexGend(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);

		glMatrixMode(GL_TEXTURE);
		glPushMatrix();
		glScalef(0.05, 0.05, 0.05);

		if btn_animatewater.Checked = True then
		begin
			glTranslatef(application.tag * (1 / Trackbar_321.position), application.tag * (1 / Trackbar_321.position), 0.0);
		end;

		glMatrixMode(GL_MODELVIEW);

    glEnable(gl_blend);
		glcolor4ub(waterr.position, waterg.position, waterb.position, watera.position);

	end
	else
	begin

		glEnable(GL_BLEND);
		glPolygonMode(GL_FRONT, GL_FILL);
		glPolygonMode(GL_BACK, GL_FILL);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glcolor4f(0, 0, 1, 0.5);

	end;

	gldisable(gl_cull_face); // problem with triangular waters.

	if cb_cullzones.Checked = True then
	begin

		for L := 0 to high(city.IPL) do
		begin
			for i := 0 to high(city.IPL[L].CullZones) do
			begin

				if (city.IPL[L].CullZones[i].flags and 8 <> 8) and (city.IPL[L].CullZones[i].flags <> -1) then
					continue;

				glPushMatrix();

				glTranslatef(city.IPL[L].CullZones[i].startorigin[0], city.IPL[L].CullZones[i].startorigin[1], city.IPL[L].CullZones[i].startorigin[2]);

				glRotatef(Math.degtorad(city.IPL[L].CullZones[i].rotation), 0, 0, 1);

				glBegin(gl_quads);

				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);

				glcolor3f(1, 0, 0);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glcolor4ub(waterr.position, waterg.position, waterb.position, watera.position);

				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], 0);

				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);

				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], -city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], 0);

				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], 0);
				glvertex3f(-city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], +city.IPL[L].CullZones[i].dimensions[2]);
				glvertex3f(+city.IPL[L].CullZones[i].dimensions[0], +city.IPL[L].CullZones[i].dimensions[1], 0);
				glend;

				glPopMatrix();

			end;
		end;

	end;

{
glbegin(GL_POINTS);
glDisable(gl_cull_face);
glcolor4f(0, 1, 0, 1);
gldisable(gl_blend);
glPointSize(10);
	for L:= 0 to Memo4.lines.count-1 do begin

		textparser.setworkspace(Memo4.lines[L]);

		if textparser.foo.Count > 2 then begin
			glvertex3f(textparser.fltindex(0), textparser.fltindex(1), textparser.fltindex(2));
		end;

	end;
	glend;
}

	for i := 0 to high(city.Water) do
	begin
		glbegin(gl_quads);
		glVertex3fv(@city.Water[i].vertices[3].pos[0]);
		glVertex3fv(@city.Water[i].vertices[2].pos[0]);
		glVertex3fv(@city.Water[i].vertices[0].pos[0]);
		glVertex3fv(@city.Water[i].vertices[1].pos[0]);

		glend;
	end;

	// north fakewater
	glbegin(gl_quads);
	glVertex3f(-map_water_edge, map_water_edge, 0.0);
	glVertex3f(map_water_edge, map_water_edge, 0.0);
	glVertex3f(water_extreme_end, water_extreme_end, 0.0);
	glVertex3f(-water_extreme_end, water_extreme_end, 0.0);
	glend;

	// south fakewater
	glbegin(gl_quads);
	glVertex3f(map_water_edge, -map_water_edge, 0.0);
	glVertex3f(-map_water_edge, -map_water_edge, 0.0);
	glVertex3f(-water_extreme_end, -water_extreme_end, 0.0);
	glVertex3f(water_extreme_end, -water_extreme_end, 0.0);
	glend;

	// west
	glbegin(gl_quads);
	glVertex3f(-water_extreme_end, -water_extreme_end, 0.0);
	glVertex3f(-map_water_edge, -map_water_edge, 0.0);
	glVertex3f(-map_water_edge, map_water_edge, 0.0);
	glVertex3f(-water_extreme_end, water_extreme_end, 0.0);
	glend;

	// east
	glbegin(gl_quads);
	glVertex3f(water_extreme_end, water_extreme_end, 0.0);
	glVertex3f(map_water_edge, map_water_edge, 0.0);
	glVertex3f(map_water_edge, -map_water_edge, 0.0);
	glVertex3f(water_extreme_end, -water_extreme_end, 0.0);
	glend;

	glMatrixMode(GL_TEXTURE);
	glpopMatrix();

	glMatrixMode(GL_MODELVIEW);


		gldisable(GL_TEXTURE_GEN_S);
		gldisable(GL_TEXTURE_GEN_T);
		glTexGend(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
		glTexGend(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);

end; // not picking: water.








	//  glPolygonMode(GL_FRONT, GL_LINE);

	for L := 0 to high(city.IPL) do
	begin
		for i := 0 to high(city.IPL[L].instobjects) do
		begin

			with city.IPL[L].InstObjects[i] do
			begin
				visibility := False;

				temp     := geometry.VectorSubtract(Camera.Position, city.IPL[L].InstObjects[i].Location);
				distance := geometry.VectorLength(temp);

        if distance > drawdistance.Position then
          continue; // too far

        if LoadedModelIndex <> -1 then
          if (GtaObject.Components[LoadedModelIndex] is TDFFUnit) then
            if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model <> nil then
              if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.loaded = False then
              begin
                // logger.lines.add('broken dff');
                continue;
              end;

				if (LoadedModelIndex <> -1) then
					if GtaObject.Components[LoadedModelIndex] is TDFFUnit then
						if (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model = nil then
						begin
							LoadedModelIndex := -1;
	          end;

        if (LoadedModelIndex <> -1) then
          if GtaObject.Components[LoadedModelIndex] <> nil then
						if LoadedModelIndex <> -1 then
							if GtaObject.Components[LoadedModelIndex] is TDFFUnit then
								if (Frustum.IsSphereWithin(Location, (GtaObject.Components[LoadedModelIndex] as TDFFUnit).model.Clump[0].RadiusSphere * 2)) = True then
									visibility := True; // we have model, try it's bounding sphere

        if LoadedModelIndex = -1 then
          if (Frustum.IsPointWithin(Location)) = True then
            visibility := True;

        if (city.idemapping[city.IPL[L].InstObjects[i].id] <> nil) then
        begin
          visibility := Frustum.IsSphereWithin(Location, (city.idemapping[city.IPL[L].InstObjects[i].id] as TIDEinforecord).collbounds.radius +

            vectorgeometry.VectorLength((city.idemapping[city.IPL[L].InstObjects[i].id] as TIDEinforecord).collbounds.center)

            );
        end;

//		todo: draw distance for samp oobjects here.

        if visibility = True then
        begin
          if cb_showlod.Checked = True then
          begin

            distance := -1;
            drawthisobject(L, i, distance, nightmode, 0);

          end
          else
          begin
            // find lods AND STUFF

            fillchar(lodinfo, sizeof(lodinfo), 0);

            if (city.IPL[L].InstObjects[I].haslod = False) {or (city.IPL[L].InstObjects[I].lod = -1)} then
            begin

              if cb_showlod.Checked = False then
              begin
                realvis := lookuplods(L, i, distance, 0, lodinfo);

                if (realvis <> i) then
                begin
                  visibility := False; // we are rendering the lod, not this one.
                  city.IPL[L].InstObjects[I].visibility := True; // lod is visible.
                end;
              end
              else
              begin

                realvis := i;

                visibility := True; // we are rendering the lod, not this one.
                city.IPL[L].InstObjects[I].visibility := True; // lod is visible.
              end;

              drawthisobject(L, realvis, distance, nightmode, 0);
            end;

          end; // checker: has any lods
        end;

      end;
    end;

    // secondary/alpha render pass
    if cb_realrendering.Checked = True then
    begin
      for i := 0 to high(city.IPL[L].instobjects) do
      begin

        with city.IPL[L].InstObjects[i] do
        begin
          if visibility = True then
          begin

            temp     := geometry.VectorSubtract(Camera.Position, city.IPL[L].InstObjects[i].Location);
            distance := geometry.VectorLength(temp);

            drawthisobject(L, i, distance, nightmode, 1);
          end;
        end;
      end;
    end;

  end;


  DebugShowCollision_POLY();

  glenable(GL_CULL_FACE);
  glPopAttrib;

  if is_picking = True then
    endpicking;

end;

procedure TGtaEditor.btn_loadClick(Sender: TObject);
var
  i, j:     integer;
  iide, ii: longword;
  //  model:    TDffLoader;
  tmpname:  string;
  //  txd:      Ttxdloader;
  DataList: TStrings;
  //  tmpstr:   string;
  newtex:   Ttxdunit;
  canopen:  boolean;
  HFileRes: HFILE;

  Reg:    TRegistry;
  TmpStr: string;

  procedure buildidetable(idefile, ideitem: integer);
  var
    fobj: Pobjs;
  begin

    if idefile > high(city.IDE) then
      exit;
    if ideitem > high(city.IDE[idefile].objects) then
      exit;

    if fobj <> nil then
    begin

      if city.IDE[idefile].Objects[ideitem].ID > high(city.idemapping) then
        setlength(city.idemapping, city.IDE[idefile].Objects[ideitem].ID + 200); // alloc MORE

      city.idemapping[city.IDE[idefile].Objects[ideitem].ID] := TIDEinforecord.Create;
      (city.idemapping[city.IDE[idefile].Objects[ideitem].ID] as TIDEinforecord).idefile := idefile;
      (city.idemapping[city.IDE[idefile].Objects[ideitem].ID] as TIDEinforecord).ideitem := ideitem;
      (city.idemapping[city.IDE[idefile].Objects[ideitem].ID] as TIDEinforecord).ideidx := city.IDE[idefile].Objects[ideitem].ID;

      (city.idemapping[city.IDE[idefile].Objects[ideitem].ID] as TIDEinforecord).collmodelindex := -1;
      (city.idemapping[city.IDE[idefile].Objects[ideitem].ID] as TIDEinforecord).collectionfileindex := -1;


			city.idetable.Add(lowercase(city.IDE[idefile].Objects[ideItem].ModelName), city.idemapping[city.IDE[idefile].Objects[ideitem].ID]);
{
			if city.IDE[idefile].Objects[ideitem] = nil then
				logger.Lines.Add(city.IDE[idefile].Objects[ideItem].ModelName + ' DUNNO IDE')
			else
				logger.Lines.Add(city.IDE[idefile].Objects[ideItem].ModelName + ' ' + inttostr(city.IDE[idefile].Objects[ideitem].ID));
}
    end;

  end;

begin

  if fileexists(working_gta_dir + '\data\gta.dat') = False then
  begin

    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('SOFTWARE\Rockstar Games\GTA San Andreas\Installation', False);
    if Reg.ValueExists('ExePath') then
      TmpStr := Reg.ReadString('ExePath')
    else
    begin
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey('SOFTWARE\Rockstar Games\GTA San Andreas\Installation', False);
      if Reg.ValueExists('ExePath') then
        TmpStr := Reg.ReadString('ExePath');
    end;
    Reg.CloseKey;

    TmpStr := copy(TmpStr, 2, length(TmpStr) - 2);

    if FileExists(TmpStr) = True then
    begin
      working_gta_dir := extractfiledir(TmpStr);
    end;

    if fileexists(working_gta_dir + '\data\gta.dat') = False then
    begin
      labelinstructions2.Show;
			btn_load.hide;
			btn_loadwithcols.hide;
      exit;
    end;
  end;

  HFileRes := CreateFile(PChar(working_gta_dir + '\models\gta3.img'), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  canopen  := (HFileRes = INVALID_HANDLE_VALUE);
  if not canopen then
  begin
    CloseHandle(HFileRes);
  end
  else
  begin
    ShowMessage('You cannot use the editor while game is running - close gta-sa, and try again.');
    exit;
  end;

  pnlhelp.Visible := False;

  DataList := TStringList.Create;

  DataList.loadfromfile(working_gta_dir + '\data\gta.dat');

  City := TGTAMAP.Create;
  city.loaded := False;

  city.idetable := TurboHashedStringList.Create;

  city.loadimg(working_gta_dir + '\models\gta3.img',
    working_gta_dir + '\models\gta_int.img',
    working_gta_dir + '\samp\samp.img',
		working_gta_dir + '\samp\SAMPCOL.img',
		working_gta_dir + '\samp\custom.img',
		);

  city.loadwater(working_gta_dir + '\data\water.dat');
  city.loadcolors(working_gta_dir + '\data\carcols.dat');
  wnd_carcolorpicker.DrawGrid1.Refresh();
  wnd_carcolorpicker.DrawGrid2.Refresh();

{
  w:= City.imglist[0].IndexOf(lowercase('farmstuff.txd'));
  txd:= Ttxdloader.Create;
  IMGExportFile(w, PChar(GetTempDir + '\' + 'farmstuff.txd'));
  txd.loadfromfile(PChar(GetTempDir + '\' + 'farmstuff.txd'));

  w:= City.imglist[0].IndexOf(lowercase('tikitorch01_lvs.dff'));

  IMGExportFile(w, PChar(GetTempDir + '\' + 'tikitorch01_lvs.dff'));
}
{
  model:= TDffLoader.create;
  tmpstr:= PChar(GetTempDir + '\' + 'nomodelfile.dff');
  model.LoadFromFile('C:\Documents and Settings\Jernej\Desktop\nomodelfile.dff');
  if model.loaded = false then logger.lines.add('MOO!');
}

{
  exit;
}

	city.loadfile('IDE', working_gta_dir + '\data\peds.ide', False);
	city.loadfile('IDE', working_gta_dir + '\data\vehicles.ide', False);
	city.loadfile('IDE', working_gta_dir + '\data\default.ide', False);

	if fileexists(working_gta_dir + '\samp\samp.ide') = True then
		city.loadfile('IDE', working_gta_dir + '\samp\samp.ide', False);

  if fileexists(working_gta_dir + '\samp\custom.ide') = True then
    city.loadfile('IDE', working_gta_dir + '\samp\custom.ide', False);

  city.loadfile('IDE', working_gta_dir + '\data\maps\veh_mods\veh_mods.ide', False);

  // load generics
  city.loadfile('IDE', working_gta_dir + '\data\maps\txd.ide', False);

  ProgressBar1.max := DataList.Count;

  for i := 0 to DataList.Count - 1 do
  begin

    textparser.setworkspace(stripcomments('#', DataList[i]));

    if trim(textparser.indexed(0)) <> '' then
    begin
      statuslabel.Caption := 'Section: ' + textparser.indexed(0) + ' File: ' + textparser.indexed(1);
			application.ProcessMessages;
//      showmessage( textparser.indexed(1));

      city.loadfile(textparser.indexed(0), working_gta_dir + '\' + textparser.indexed(1), False);
    end;

    ProgressBar1.position := i;

  end;

  IMGLoadImg(PChar(city.imgfile[0]));
  lastimg := 0;

  for i := 0 to City.imglist[0].Count - 1 do
  begin

    if pos('.ipl', City.imglist[0][i]) <> 0 then
      if imgipls.Lines.IndexOf(City.imglist[0][i]) = -1 then
      begin

        statuslabel.Caption := 'BinIPL: ' + City.imglist[0][i];
        application.ProcessMessages;

        tmpname := GetTempDir + '\' + City.imglist[0][i];
        IMGExportFile(i, PChar(tmpname));
        city.loadfile('IPL', tmpname, True);
        deletefile(tmpname);
      end;
  end;

  statuslabel.Caption := 'Processing LOD hierarchy';
  application.ProcessMessages;

  for i := 0 to high(city.ipl) do
  begin
    city.IPL[i].processlodinfo;
  end;


  // create a ide index to more easily manage the ide to coll & other references

  statuslabel.Caption := 'Building IDE index...';
  application.ProcessMessages;

  for iide := 0 to high(city.IDE) do
    if city.IDE[iide].Objects <> nil then
      for ii := 0 to high(city.IDE[iide].Objects) do
        buildidetable(iide, ii);

  // load colls, ide index is used to know which model has which ipl file and obj index.
  // order is intentionally reversed, we want to first look inside sampcol.img, so overriding colls works properly.
  for j := high(City.imglist) downto 0 do
  begin

    if (City.imgfile[j] = '') then
      continue;

    statuslabel.Caption := 'Loading COLL info from: ' + extractfilename(City.imgfile[j]);
    application.ProcessMessages;

		switch2img(j);

    if (City.imglist[j].Count < 1) then
    begin
      logger.Lines.add(format('%s index %d has no data: %d', [City.imgfile[j], j, City.imglist[j].Count]));
      continue;
    end;

    ProgressBar1.max := City.imglist[j].Count - 1;

    for i := 0 to City.imglist[j].Count - 1 do
    begin

      if i mod 50 = 0 then
        ProgressBar1.Position := i;

      if lowercase(extractfileext(City.imglist[j].Strings[i])) = '.col' then
      begin
        statuslabel.Caption := 'Loading COLL info from: ' + extractfilename(City.imgfile[j]) + ', parsing collection: ' + City.imglist[j].Strings[i];
        logger.Lines.add(statuslabel.Caption);
        application.ProcessMessages;
        city.loadcolldata(i, j);
      end;

    end;
  end;

  newtex := Ttxdunit.Create(GtaObject);
  newtex.texture := Ttxdloader.Create;
  newtex.texture.loadfromfile(working_gta_dir + '\models\generic\vehicle.txd');
  newtex.filename := 'vehicle';
  newtex.refcount := 1;// always at least 1 so it doesnt get unloaded.

  newtex := Ttxdunit.Create(GtaObject);
  newtex.texture := Ttxdloader.Create;
  newtex.texture.loadfromfile(working_gta_dir + '\models\particle.txd');
  newtex.filename := 'particle';
  newtex.refcount := 1;// always at least 1 so it doesnt get unloaded.

  newtex := Ttxdunit.Create(GtaObject);
  newtex.texture := Ttxdloader.Create;
  newtex.texture.loadfromfile(extractfilepath(application.ExeName) + '\background.txd');
  newtex.filename := 'background';
  newtex.refcount := 1;// always at least 1 so it doesnt get unloaded.

  vehicletxd    := IsTextureLoaded('vehicle');
  particletxd   := IsTextureLoaded('particle');
  backgroundtxd := IsTextureLoaded('background');

  ProgressBar1.position := 0;
  statuslabel.Caption   := 'Loaded.';
	btn_load.hide;
	btn_loadwithcols.hide;

  DataList.Clear;

  statuslabel.left := ProgressBar1.left;
  ProgressBar1.Visible := False;
  maploaded := True;

  btn_inp.Enabled     := True;
  brn_importpaste.Enabled := True;
	btn_clear.Enabled   := True;
	btn_undo.Enabled   := True;
  btn_testmap.Enabled := True;
  btn_impipl.Enabled  := True;
  btn_addtoprefabs.Enabled := True;
  btn_addcameraview.Enabled := True;
	btn_addnewobj.Enabled := True;
	btn_wantcols.Enabled := false;

	if btn_wantcols.Checked = false then begin
		cb_wire.Checked:= false;
		cb_showcoll.Checked:= false;
		cb_wire.enabled:= false;
		cb_showcoll.enabled:= false;
		btn_wantcols.caption:= 'enable colls before loading the map';
	end;

  cloneobj.Enabled := True;
  delobj.Enabled   := True;

  city.loaded := True;

  DecimalSeparator := '.';

end;

procedure TGtaEditor.Image5MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  // go into resizing mode
  ReleaseCapture; // important!
  SendMessage(Handle, WM_NCLBUTTONDOWN, HTBOTTOMRIGHT, 0);
end;

procedure TGtaEditor.FormCreate(Sender: TObject);
var
  pfd: TPIXELFORMATDESCRIPTOR;
	pf:  integer;
	buffer: pchar;
begin

  working_gta_dir := extractfiledir(application.exename);

  nworld := NewtonCreate;
  NewtonSetWorldSize(nworld, @nw[0], @se[0]);

  DecimalSeparator := '.';
  opengl12.LoadOpenGL;

  // OpenGL initialize
  dc := GetDC(GlPanel.Handle);

  // PixelFormat
  pfd.nSize      := sizeof(pfd);
  pfd.nVersion   := 1;
  pfd.dwFlags    := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or 0;
  pfd.iPixelType := PFD_TYPE_RGBA;      // PFD_TYPE_RGBA or PFD_TYPEINDEX
  pfd.cColorBits := 32;

  pf := ChoosePixelFormat(dc, @pfd);   // Returns format that most closely matches above pixel format
  SetPixelFormat(dc, pf, @pfd);

  rc := wglCreateContext(dc);    // Rendering Context = window-glCreateContext
  wglMakeCurrent(dc, rc);        // Make the DC (Form1) the rendering Context

	Buffer:= glGetString(GL_RENDERER);

	if (Buffer = 'GDI Generic') then begin
		showmessage('Please install proper drivers for your graphics card. Google will help you in acvhieving this task.' + buffer);
		halt;
	end;

	Buffer:= glGetString(GL_Vendor);

	if (Buffer = 'Microsoft Corporation') then begin
		showmessage('Please install proper drivers for your graphics card. Google will help you in acvhieving this task.' + buffer);
		halt;
	end;

	// Initialist GL environment variables
  glInit;
  GlPanelResize(Sender);    // sets up the perspective
  AppStart := GetTickCount();

  opengl12.ReadExtensions;
	opengl12.ReadWGLExtensions;

  // when the app has spare time, render the GL scene
  Application.OnIdle := Idle;

  GtaObject := Tmediastoreparent.Create(application);
  loadnext  := TStringList.Create;

  Cameraclass.thispanel := GlPanel.handle;
end;

procedure TGtaEditor.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(rc);
  application.Terminate;
end;

procedure TGtaEditor.GlPanelResize(Sender: TObject);
begin
  glViewport(0, 0, GlPanel.Width, GlPanel.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, GlPanel.Width / GlPanel.Height, 0.2, 10000.0);  // Do the perspective calculations. Last value = max clipping depth

  //  gluPerspective( 10.0, GlPanel.Width / GlPanel.Height, 0.2, 10000.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
end;

procedure TGtaEditor.ThreadedTimer1Timer(Sender: TObject);
begin

  if CheckBox1.Checked = True then
    btn_buildworldClick(btn_buildworld);

  if maploaded = False then
    exit;

  statuslabel.Caption := format('%d FPS', [fpsclock]);
  fpsclock := 0;
end;

procedure TGtaEditor.StreamView;
var
  i:      integer;
  fobj:   Pobjs;
  newobj: TDFFUnit;
  newcoll: TColObject;
  newtex: Ttxdunit;
  filebuff: Tmemorystream;
  texbuff: Tmemorystream;
  stuff:  Tdirentry;
  collindex: integer;
begin

  if is_picking = True then
    exit;

  if loadnext = nil then
    exit;

  //  if (loadnext.Count > 0) then
  //    outputdebugstring( loadnext.GetText);

  for i := loadnext.Count - 1 downto 0 do
  begin

    try

      if loadnext.Count >= i then // if there's item availible at all.
        fobj := findIDE(StrToInt(loadnext[i]), True)
      else
        continue;

    except
      continue;
    end;
    if fobj = nil then
      continue;

    newobj     := TDFFUnit.Create(GtaObject);
    newobj.IDE := fobj.ID;
    newobj.txdref := -1;
    newobj.markclear := False;
    newobj.lastdrawn := gettickcount + 5000;
    newobj.lastframe := fpsframes + 5;
    newobj.model := TDffLoader.Create;

    //      if Pos('fence', lowercase(fobj.ModelName)) > 0 then logger.lines.add(fobj.ModelName);
    //      if fobj.ID >= 1411 then if fobj.id <= 1413 then logger.lines.add(fobj.ModelName + ' - ' + fobj.TextureName);

    statuslabel.Caption := fobj.ModelName + '.dff';
    application.ProcessMessages;

    if (fobj.Modelidx <> -1) and (fobj.modelinimg <> -1) then
    begin

			try

				switch2img(fobj.modelinimg);

				filebuff      := Tmemorystream.Create;
        filebuff.size := IMGGetThisFile(fobj.Modelidx).sizeblocks * 2048;
        newobj.copyflags := fobj.Flags;

        IMGExportBuffer(fobj.Modelidx, filebuff.Memory);
        newobj.model.filenint := GetTempDir + fobj.ModelName + '.dff';
        newobj.model.LoadFromStream(filebuff);
        newobj.colllist := -1;

        //        outputdebugstring(pchar(fobj.ModelName + ' ide ' + inttostr(fobj.ID) + ' size ' +  inttostr(IMGGetThisFile(fobj.Modelidx).sizeblocks * 2048) + ' txds ' + inttostr(IMGGetThisFile(fobj.Textureidx).sizeblocks * 2048  )));
        //        outputdebugstring(pchar(GetTempDir + fobj.ModelName + '.dff'));
        //        outputdebugstring(pchar(fobj.ModelName + ' is ' + inttostr(fobj.ID)));

        filebuff.Free;

        if btn_wantcols.Checked = True then
        begin

			collindex:= loadcoll(fobj);

          if collindex <> -1 then
            newobj.collref := TColObject(gtaobject.Components[collindex])
          else
          begin
			//            showmessage('could not load: ' + fobj.ModelName + ' in file: ' + (city.idemapping[ fobj.ID ] as TIDEinforecord).collectionname);
          end;

        end; // want colls loaded


      except
        ShowMessage('You probably tried to use the editor while game locked the files in background - this doesn''t work, it can''t work so don''t try it again.');
      end;

      //      if newobj.model.loaded = False then
      //        logger.Lines.add(fobj.ModelName + '.dff');

      //deletefile(PChar(GetTempDir + '\' + fobj.ModelName + '.dff'));
    end; // object

    // load texture
    if box_tex.Checked = True then
    begin
      newobj.txdref := IsTextureLoaded(fobj.TextureName); // try to find existing texture

      if (newobj.txdref = -1) then
      begin // load new texture

        if (fobj.Textureidx <> -1) then
        begin

          newtex := Ttxdunit.Create(GtaObject);
          newtex.texture := Ttxdloader.Create;

          statuslabel.Caption := fobj.TextureName + '.txd';
          application.ProcessMessages;

					switch2img(fobj.txdinimg);

					//        logger.Lines.add(fobj.TextureName + '.txd');
{
					if fobj.TextureName + '.txd' = 'balloon_texts.txd' then begin
						showmessage(format('lastimg is %s. file index %d. ofs %d size %d img %s', [lastimg, fobj.Textureidx, IMGGetThisFile(fobj.Textureidx).startblock * 2048, IMGGetThisFile(fobj.Textureidx).sizeblocks * 2048, city.imgfile[fobj.txdinimg]]));
					end;
}
					texbuff      := Tmemorystream.Create;
					texbuff.size := IMGGetThisFile(fobj.Textureidx).sizeblocks * 2048;

          IMGExportBuffer(fobj.Textureidx, texbuff.Memory);
          newtex.texture.loadfromstream(texbuff, fobj.TextureName + '.txd');

          //        if newtex.texture.is_loaded = False then
          //          logger.Lines.add(fobj.TextureName + '.txd');

          texbuff.Free;

          newtex.filename := fobj.TextureName;
          newtex.refcount := newtex.refcount + 1;
          newobj.txdref   := newtex.ComponentIndex;

        end;

      end
      else
      begin
        (GtaObject.Components[newobj.txdref] as TTxdUnit).refcount :=
          (GtaObject.Components[newobj.txdref] as TTxdUnit).refcount + 1;
      end;
    end; // texture loader

    //    loadnext.Delete(i);

  end; // for instreaming...

  loadnext.Clear;

end;

procedure TGtaEditor.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  rect: Trect;
  pt:   Tpoint;
begin

  if (key = vk_shift) or (key = VK_RBUTTON) then
  begin
    GetWindowRect(GlPanel.handle, rect);
    pt.x := rect.Left + ((rect.right - rect.left) div 2);
    pt.y := rect.top + ((rect.bottom - rect.top) div 2);

    if gcp = False then
    begin
      GetCursorPos(oldcp);

      if ((oldcp.x < rect.left) or (oldcp.x > rect.right)) or ((oldcp.y < rect.top) or (oldcp.y > rect.bottom)) then
        exit;

      gcp := True;
      GlPanel.Cursor := crNone;
    end;

    SetCursorPos(pt.x, pt.y);
    key := 0;
  end;

  if (key = VK_INSERT) then
  begin
    GlPanelMouseDown(GlPanel, mbleft, Shift, tx, ty);
    btn_addnewobjClick(btn_addnewobj);
  end;

  if (key = VK_DELETE) and (gtaeditor.ActiveControl = GlPanel) then
    Deleteobject1Click(delobj);

  if key = VK_F2 then
  begin

		CloneSelection(keys[vk_control] <= 13);

		if keys[vk_control] > 13 then
			Deleteobject1Click(delobj);

  end;

  if GtaEditor.ActiveControl <> nil then
  begin

    if (GtaEditor.ActiveControl.ClassType <> Tlistbox) and
      (GtaEditor.ActiveControl.ClassType <> Tdnk_edit) and
      (GtaEditor.ActiveControl.ClassType <> Tedit) then
    begin

      if key = 49 then
      begin
        lb_mmode.ItemIndex  := 0;
        cb_autopick.Checked := False;
        TabSheet1.Show;
      end;
      if key = 50 then
      begin
        lb_mmode.ItemIndex  := 1;
        cb_autopick.Checked := False;
        TabSheet1.Show;
      end;
      if key = 51 then
      begin
        lb_mmode.ItemIndex  := 2;
        cb_autopick.Checked := False;
        TabSheet1.Show;
      end;
      if key = 52 then
      begin
        lb_mmode.ItemIndex  := 3;
        cb_autopick.Checked := False;
        TabSheet1.Show;
      end;

      if key = 53 then
      begin
        lb_mmode.ItemIndex  := 0;
        cb_autopick.Checked := True;
        TabSheet1.Show;
      end;

    end;
  end;

end;

procedure TGtaEditor.GlPanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  i:    integer;
  ObjV: TVector3d;
  nkey: word;
  v:    TVector;
	pickres: Tvector;
	stupidtext: string;
begin

	makeundogroup();

  if pnl_addide.Visible = True then
  begin
    cameradrag     := True;
    lastmouse.x    := x;
    lastmouse.y    := y;
	GlPanel.Cursor := crNone;
    exit;
  end;

  if button = mbRight then
  begin
    nkey := VK_RBUTTON;
    FormKeyDown(Sender, nkey, Shift);
    GlPanel.Cursor := crNone;
    exit;
  end;

  mousecontrol := True;

  mouse3d := GetOpenGLPos(X, Y);

  if selipl <> 0 then
	begin

    MouseButton := 1;
    MouseXVal   := X;
    MouseYVal   := Y;

		ObjV[0] := city.IPL[selipl].InstObjects[selitem].Location[0];
    ObjV[1] := city.IPL[selipl].InstObjects[selitem].Location[1];
    ObjV[2] := city.IPL[selipl].InstObjects[selitem].Location[2];

    if Button = mbMiddle then
      MoveMode := SCREEN_ZAXIS
    else
      MoveMode := SCREEN_XYPLANE;

    ScreenToWorldCoords(X, Y, ObjV, MoveMode, StartV);

{    oyea.Lines.Add(format('(%0.4f %0.4f %0.4f)' + #10 + #13 + '(%0.4f, %0.4f, %0.4f)' + #10 + #13 + '(%0.4f, %0.4f, %0.4f) E', [

ObjV[0],
ObjV[1],
ObjV[2],

city.IPL[selipl].InstObjects[selitem].Location[0],
city.IPL[selipl].InstObjects[selitem].Location[1],
city.IPL[selipl].InstObjects[selitem].Location[2],

StartV[0],
StartV[1],
StartV[2]

]
));}

  end;

  label_exstatus.Caption := format('(%0.4f %0.4f %0.4f)', [mouse3d[0], mouse3d[1], mouse3d[2]]);

  cx := x;
  cy := y;

  is_picking := True;
  gldraw;
  is_picking := False;

  if Selection = 0 then
  begin
    exit;
  end
  else
  begin
{
		if (selipl > 0) and (selitem > 0) then begin
      lastMouseWorldPos:= MouseWorldPos(x,y);

        label_exstatus.Caption := format('(%f %f %f)', [lastMouseWorldPos[0], lastMouseWorldPos[1], lastMouseWorldPos[2]]);

    end;
}
	end;

  selipl  := loword(Selection);
	selitem := hiword(Selection);

		if not (ssCtrl in Shift) then
			lb_selection.items.clear;

		stupidtext:= format('%d %d', [selipl, selitem]);

		if lb_selection.Items.indexof(stupidtext) = -1 then
			lb_selection.items.add(stupidtext)
		else
			lb_selection.items.Delete(lb_selection.Items.indexof(stupidtext));


  refreshselectedobjectineditors();

end;

procedure TGtaEditor.ThreadedTimer2Timer(Sender: TObject);
begin
  if pnl_addide.Visible = True then
    exit;

  UnloadUnneededModels(False);
end;

procedure TGtaEditor.oldListView1DblClick(Sender: TObject);
var
  split2: integer;
begin

  if cameraviews.ItemIndex = -1 then
	exit;

  split2 := pos('%', cameraviews.Items[cameraviews.ItemIndex]);

  textparser.setworkspace(copy(cameraviews.Items[cameraviews.ItemIndex], split2 + 1, 500));

  Camera.Position[0] := textparser.fltindex(0);
  Camera.Position[1] := textparser.fltindex(1);
  Camera.Position[2] := textparser.fltindex(2);

  Camera.View[0] := textparser.fltindex(3);
  Camera.View[1] := textparser.fltindex(4);
  Camera.View[2] := textparser.fltindex(5);

  Camera.UpVector[0] := textparser.fltindex(6);
  Camera.UpVector[1] := textparser.fltindex(7);
  Camera.UpVector[2] := textparser.fltindex(8);

end;

procedure TGtaEditor.btn_addcameraviewClick(Sender: TObject);
begin

  cameraviews.items.add(
    format('Unnamed View%%%f %f %f %f %f %f %f %f %f ', [
    Camera.Position[0],
    Camera.Position[1],
    Camera.Position[2],

    Camera.View[0],
    Camera.View[1],
    Camera.View[2],

    Camera.UpVector[0],
    Camera.UpVector[1],
    Camera.UpVector[2]]));

	saveeditorinfo();

end;

procedure TGtaEditor.FormShow(Sender: TObject);
var
	i: integer;
	TempDC: HDC;
	boxmin, boxmax: Tvector;
	reg: Tregistry;
begin

	Reg := TRegistry.Create;
	Reg.RootKey := HKEY_CURRENT_USER;
	Reg.OpenKey(editor_regkey, False);
	if Reg.ValueExists('autokeys') then
		cb_autopick.checked:= Reg.readbool('autokeys');

	if Reg.ValueExists('nudge_power') then
		nudge_power.position:= Reg.readinteger('nudge_power');

	if Reg.ValueExists('nudge_power_rotation') then
		nudgepowerrot.position:= Reg.readinteger('nudge_power_rotation');

	if Reg.ValueExists('list_columns') then begin
		PFListFiltered.columns:= Reg.readinteger('list_columns');
		TabSheet2Resize(TabSheet2);
	end;

	Reg.CloseKey;

  DoubleBuffered := True;

	TempDC:= GetDC(GetDesktopWindow());
	i:= GetDeviceCaps(TempDC, BITSPIXEL);

	if i <> 32 then begin
		showmessage('Change desktop color depth to 32 bits. Your current settings are: ' + inttostr(i) + ' bits. (THAT IS NOT ENOUGH POWER FOR MAP EDITOR!)');
		halt;
	end;

  SetProcessAffinityMask(GetCurrentProcess(), 1); // use just the first core (workaround for amd desynced timers in different cores issue).

  wnd_advinfo.Top:= 335;

{
  nworld:= NewtonCreate(nil, nil);

  boxmin := geometry.VectorMake(-99999999, -99999999, -99999999);
  boxmax := geometry.VectorMake(99999999, 99999999, 99999999);
  NewtonSetWorldSize(nworld, @boxmin, @boxmax);
}

  // convert old formats.

  if fileexists(ChangeFileExt(application.exename, '_views')) = True then
  begin
    cameraviews.items.BeginUpdate();
    cameraviews.items.loadfromfile(ChangeFileExt(application.exename, '_views'));

    for i := cameraviews.items.Count - 1 downto 1 do
    begin
      if i mod 2 <> 1 then
        continue;
      cameraviews.items[i - 1] := cameraviews.items[i - 1] + '%' + cameraviews.items[i];
      cameraviews.Items.Delete(i);
    end;

    cameraviews.items.savetofile(ChangeFileExt(application.exename, '_cameras'));
    deletefile(ChangeFileExt(application.exename, '_views'));
    cameraviews.items.Clear;
    cameraviews.items.endUpdate();
  end;

  if fileexists(ChangeFileExt(application.exename, '_prefabs')) = True then
  begin
    cameraviews.items.BeginUpdate();
    cameraviews.items.loadfromfile(ChangeFileExt(application.exename, '_prefabs'));

    for i := cameraviews.items.Count - 1 downto 1 do
    begin
      if i mod 2 <> 1 then
        continue;
      cameraviews.items[i - 1] := cameraviews.items[i - 1] + '%' + cameraviews.items[i];
      cameraviews.Items.Delete(i);
    end;

    cameraviews.items.savetofile(ChangeFileExt(application.exename, '_objects'));
    deletefile(ChangeFileExt(application.exename, '_prefabs'));
    cameraviews.items.Clear;
    cameraviews.items.endUpdate();
  end;

  // load new cameras & prefab lists.

  if fileexists(ChangeFileExt(application.exename, '_cameras')) = True then
  begin
    cameraviews.items.loadfromfile(ChangeFileExt(application.exename, '_cameras'));
  end;

  if fileexists(ChangeFileExt(application.exename, '_objects')) = True then
  begin
    newprefabs.Items.loadfromfile(ChangeFileExt(application.exename, '_objects'));
  end;

  ObjFilterChange(ObjFilter);

end;

procedure TGtaEditor.btn_delcameraviewClick(Sender: TObject);
begin
  if cameraviews.ItemIndex = -1 then
    exit;

  cameraviews.items.Delete(cameraviews.ItemIndex);
  saveeditorinfo();
end;

procedure TGtaEditor.btn_addtoprefabsClick(Sender: TObject);
begin

  if sel_ide = 0 then
    addidetext.Text := '500'
  else
    addidetext.Text := IntToStr(sel_ide);
  addidedesc.Text := mdl_name.Text;

  pnl_addide.Show;
  GlPanel.Align  := alNone;
  GlPanel.Width  := 512;
  GlPanel.Height := 512;
  renderpredabbtnClick(renderpredabbtn);

end;

procedure TGtaEditor.btn_deleteprefabClick(Sender: TObject);
begin
  if pflistfiltered.ItemIndex = -1 then
    exit;

  newprefabs.items.Delete(StrToInt(pflistfiltered.items[pflistfiltered.ItemIndex]));

  ObjFilterChange(ObjFilter);
  saveeditorinfo();
end;

procedure TGtaEditor.PopupMenu1Popup(Sender: TObject);
begin
  wnd_advinfo.hide;
end;

procedure TGtaEditor.inp_coordseditChange(Sender: TObject);
var
  sinx, siny, sinz, cosx, cosy, cosz: single;
var
  tma, tmn: TMatrix3f;
  x, y:     integer;
begin
  try
    textparser.setworkspace(inp_coordsedit.Text);

    if codeupdating = True then
      exit;

	if city.IPL[selipl].InstObjects[selitem].added = False then
      exit;

		makeundogroup();
		makeundo(selipl, selitem, 1, 'edited parameters');

	if city.IPL[selipl].InstObjects[selitem].id <> strtointdef(inp_ide.Text, 0) then
    begin
	  city.IPL[selipl].InstObjects[selitem].id := strtointdef(inp_ide.Text, 0);
	  city.IPL[selipl].InstObjects[selitem].LoadedModelIndex := -1;
	end;

    city.IPL[selipl].InstObjects[selitem].draw_distance:= StrToFloatDef(fobj_frawdistance.Text, 500.0);

	city.IPL[selipl].InstObjects[selitem].Location[0] := textparser.fltindex(0);
	city.IPL[selipl].InstObjects[selitem].Location[1] := textparser.fltindex(1);
    city.IPL[selipl].InstObjects[selitem].Location[2] := textparser.fltindex(2);

    textparser.setworkspace(inp_rotations.Text);

    city.IPL[selipl].InstObjects[selitem].SetGTARotation(textparser.fltindex(0), textparser.fltindex(1), textparser.fltindex(2));

    if wnd_carcolorpicker.CheckBox1.Checked = True then
    begin
      city.IPL[selipl].InstObjects[selitem].carcolor1 := -1;
    end
    else
    begin
      city.IPL[selipl].InstObjects[selitem].carcolor1 := wnd_carcolorpicker.DrawGrid1.Row * wnd_carcolorpicker.DrawGrid1.ColCount + wnd_carcolorpicker.DrawGrid1.Col;
    end;

    if wnd_carcolorpicker.CheckBox2.Checked = True then
    begin
			city.IPL[selipl].InstObjects[selitem].carcolor2 := -1;
    end
    else
    begin
      city.IPL[selipl].InstObjects[selitem].carcolor2 := wnd_carcolorpicker.DrawGrid2.Row * wnd_carcolorpicker.DrawGrid2.ColCount + wnd_carcolorpicker.DrawGrid2.Col;
    end;

    codeupdating := True;
    TrackBar1.Position := geometry.round(textparser.fltindex(0));
    TrackBar2.Position := geometry.round(textparser.fltindex(1));
    TrackBar3.Position := geometry.round(textparser.fltindex(2));
  except
  end;
  codeupdating := False;

end;

procedure TGtaEditor.TrackBar1Change(Sender: TObject);
begin
  if codeupdating = True then
    exit;

  codeupdating := True;

  inp_rotations.Text := Format('%1.4f, %1.4f, %1.4f', [TrackBar1.Position + 0.00, TrackBar2.Position + 0.00, TrackBar3.Position + 0.00]);

  updatenudgeedtors();

  codeupdating := False;

  inp_coordseditChange(inp_coordsedit);
end;

procedure TGtaEditor.GlPanelDblClick(Sender: TObject);
begin
  wnd_advinfo.Show;
end;

procedure TGtaEditor.btn_inpClick(Sender: TObject);
begin
  if OpenDialog1.Execute = False then
	exit;

  readwriter.Lines.loadfromfile(OpenDialog1.filename);

  importreadwriter();

end;

procedure TGtaEditor.btn_clearClick(Sender: TObject);
var
  i, l: integer;
begin

  if MessageDlg('Do you really want your work so far cleared?', mtConfirmation, [mbYes, mbNo], 0) = mrno then exit;

  undostack.clear;

  for L := 0 to high(city.IPL) do
  begin
    for i := 0 to high(city.IPL[L].InstObjects) do
    begin

      with city.IPL[L].InstObjects[i] do
      begin

        if (added = False) and (deleted = True) then
        begin
          deleted := False;
        end;

        if (added = True) then
        begin
          deleted := True;
        end;

      end;

    end;
  end;

end;

procedure TGtaEditor.btn_aboutClick(Sender: TObject);
begin
  wnd_about.showmodal;
end;

procedure TGtaEditor.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  processHandle: longword;
  i: integer;
begin

  saveeditorinfo();

  processHandle := OpenProcess(PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION, False, processHandle);
  TerminateProcess(processHandle, 0);

  KillTask(extractfilename(application.exename));

  ShowMessage('bookmarks and views are saved! now please kill the program using task manager (this is beta, it fails to close properly unless you kill it).');
  canclose := False;
end;

procedure TGtaEditor.Copy1Click(Sender: TObject);
begin
  clipboard.AsText := label_exstatus.Caption;
end;

procedure TGtaEditor.GlPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
var
  OutV, ObjV: TVector3d;
  SendV:      Tvector3f;
  newPos:     Tvector;
begin

  // normal world mode
  tx := x;
  ty := y;

  // prefab mode
  if pnl_addide.Visible = True then
  begin

    if cameradrag = False then
      exit;

    rotation_x_axis := rotation_x_axis + (lastmouse.x - x);
    rotation_y_axis := rotation_y_axis + (lastmouse.y - y);

    lastmouse.x := x;
    lastmouse.y := y;

    renderpredabbtnClick(renderpredabbtn);

    exit;
  end;

  // normal world mode
  performmousemoving(X, Y);

{
  newPos:= MouseWorldPos(x, y);

//  if Assigned(currentPick) and (VectorNorm(lastMouseWorldPos)<>0) then
//  currentPick.Position.Translate(VectorSubtract(newPos, lastMouseWorldPos));

  SendV[0] := newPos[0] - lastMouseWorldPos[0];
  SendV[1] := newPos[1] - lastMouseWorldPos[1];
  SendV[2] := newPos[2] - lastMouseWorldPos[2];


	city.IPL[selipl].InstObjects[selitem].Location[0] := city.IPL[selipl].InstObjects[selitem].Location[0] + SendV[0];
  city.IPL[selipl].InstObjects[selitem].Location[1] := city.IPL[selipl].InstObjects[selitem].Location[1] + SendV[1];
  city.IPL[selipl].InstObjects[selitem].Location[2] := city.IPL[selipl].InstObjects[selitem].Location[2] + SendV[2];

  lastMouseWorldPos:= newPos;
}

end;

procedure TGtaEditor.renderpredabbtnClick(Sender: TObject);
var
  ps:   Tmemorystream;
  renderw, renderh: integer;
  bmp:  Tbitmap;
  jpg:  TJPEGImage;
  fobj: Pobjs;

  // finding optimal distance..
  obj, splits, vert, vart: integer;
  d, cd:     single;
  dffloader: TDffLoader;
  avail2render: integer;
begin

{$I-}
  try
    mkdir(working_gta_dir + '\PrefabPics\');
  except
  end;
{$I+}

  prefabrenderid := IntToStr(strtointdef(prefabrenderid, 300));

  // we load this later down the road.
  //  Addpleaseloadmethis(prefabrenderid);
  //  StreamView;

  fobj := findIDE(StrToInt(prefabrenderid), False);

  if fobj = nil then
		exit;
	
	renderw := GlPanel.width;
  renderh := GlPanel.height;

  //glClearColor(248/256, 214/256, 122/256, 1);

  glClearColor(1, 1, 1, 1);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);  // Clear The Screen And The Depth Buffer
  glLoadIdentity;                                       // Reset The View

  glClearColor(0, 0, 0, 1);
{
  showmessage(inttostr(rendermodel(fobj.ID)));
  showmessage(inttostr(GtaObject.ComponentCount));
}

  avail2render := rendermodel(fobj.ID);

  if avail2render = -1 then
  begin

	if loadnext.indexof(IntToStr(fobj.ID)) = -1 then
	  pleaseloadmethis(fobj.ID);

	StreamView(); // force loading of the object id we need.
	avail2render := rendermodel(fobj.ID);
  end;

  dffloader := (GtaObject.Components[avail2render] as TDFFUnit).model;

  if dffloader = nil then
  begin
	if loadnext.indexof(IntToStr(fobj.ID)) = -1 then
	  pleaseloadmethis(fobj.ID);

	StreamView(); // force loading of the object id we need.
  end
  else
  begin

    dffloader := (GtaObject.Components[rendermodel(fobj.ID)] as TDFFUnit).model;

    if length(dffloader.Clump) = 0 then
    begin
      exit;
    end;

    d := 0;

    for obj := 0 to dffloader.Clump[0].GeometryList.GeometryCount - 1 do
      for splits := 0 to high(dffloader.Clump[0].GeometryList.Geometry[obj].MaterialSplit.Split) do
        for vert := 0 to high(dffloader.Clump[0].GeometryList.Geometry[obj].MaterialSplit.Split[splits].Index) do
        begin

          vart := dffloader.Clump[0].GeometryList.Geometry[obj].MaterialSplit.Split[splits].Index[vert];

          //  for vert:= 0 to high(dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex) do begin

          cd := sqrt(
            dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex[vart][0] * dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex[vart][0] +
            dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex[vart][1] * dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex[vart][1] +
            dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex[vart][2] * dffloader.Clump[0].GeometryList.Geometry[obj].Data.Vertex[vart][2]
            );

          if cd < 100 then
            if cd > d then
			  d := cd;

        end;

    zoom := d / 0.05; //strtofloat(Edit2.text);//0.828427;

    glTranslatef(0, 0, -((zoom + zoomadd) / 8));

    glscalef(-1, 1, 1);

    glRotatef(-rotation_y_axis, 1, 0, 0);
    glRotatef(rotation_x_axis, 0, 1, 0);

    glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix

    glViewport(0, 0, renderw, renderh);    // Set the viewport for the OpenGL window

    glColor4f(1, 1, 1, 1);

    glScalef(-1, 1, 1);
    glRotatef(90, 0, 0, 1);
    glRotatef(90, 0, 1, 0);

    if cb_fixup_addprefab.Checked = True then
      glTranslatef(0, 0, -d * 0.5);

    glDisable(gl_cull_face);

    if (GtaObject.Components[rendermodel(fobj.ID)] as TDFFUnit).txdref <> -1 then
      (GtaObject.Components[rendermodel(fobj.ID)] as TDFFUnit).model.glDraw(
        (GtaObject.Components[(GtaObject.Components[rendermodel(fobj.ID)] as TDFFUnit).txdref] as TTxdUnit).texture,
        (GtaObject.Components[vehicletxd] as TTxdUnit).texture
        , False, 0, nightmode, false);

    SwapBuffers(DC);

    ps      := Tmemorystream.Create;
    ps.size := renderw * renderh * 4;
    glReadPixels(0, 0, renderw, renderh, GL_BGRA_EXT, GL_UNSIGNED_BYTE, ps.Memory);

    bmp := TBitmap.Create;
		bmp.Width := renderw;
    bmp.Height := renderh;
    bmp.pixelformat := pf32bit;
    ScanLinesFromRaw(ps, bmp, renderw * 4);
    ps.Free;
    bmp.Modified := True;

    jpg := TJPEGImage.Create;
    jpg.Assign(bmp);
    jpg.SaveToFile(working_gta_dir + '\PrefabPics\' + prefabrenderid + prefabextrastr + '.jpg');
    jpg.Free;
    //    bmp.SaveToFile(working_gta_dir + '\PrefabPics\' + prefabrenderid + prefabextrastr + '.bmp');
    bmp.Free;

	//sleep(1000);

    GlPanelResize(GlPanel); // restore viewport

  end;

end;

procedure TGtaEditor.btn_renobjClick(Sender: TObject);
var
  split2: integer;
  prompt: string;
begin
  if pflistfiltered.ItemIndex = -1 then
    exit;

  split2 := pos('%', newprefabs.Items[StrToInt(pflistfiltered.items[pflistfiltered.ItemIndex])]);

  prompt := copy(newprefabs.Items[StrToInt(pflistfiltered.items[pflistfiltered.ItemIndex])], 0, split2 - 1);

  if InputQuery('Rename camera view', 'New name', prompt) = True then
  begin
    newprefabs.Items[StrToInt(pflistfiltered.items[pflistfiltered.ItemIndex])] := prompt + copy(newprefabs.Items[StrToInt(pflistfiltered.items[pflistfiltered.ItemIndex])], split2, 500);
  end;

  ObjFilterChange(ObjFilter);
  saveeditorinfo();
end;

procedure TGtaEditor.GlPanelClick(Sender: TObject);
begin
  GlPanel.SetFocus;
  ActiveControl := GlPanel;
end;

procedure TGtaEditor.GlPanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  nkey: word;
begin

	makeundogroup();

  if cursorseen = False then
  begin
    ShowCursor(True);
    cursorseen := True;
  end;


  GlPanel.Cursor := crDefault;

  if pnl_addide.Visible = True then
  begin
    cameradrag := False;
    exit;
  end;

  if button = mbRight then
  begin
    nkey := VK_RBUTTON;
    FormKeyUp(Sender, nkey, Shift);
    exit;
  end;

  mousecontrol := False;
end;

procedure TGtaEditor.Cloneobject1Click(Sender: TObject);
begin
  CloneSelection(True);
end;


procedure TGtaEditor.btn_iplClick(Sender: TObject);
var
  i, l: integer;
  rotx, roty, rotz: string;
begin

  if SaveDialog2.Execute = False then
    exit;

  readwriter.Lines.Clear;

  readwriter.Lines.add('# IPL generated with Sa-mp map editor');
  readwriter.Lines.add('inst');

  for L := 0 to high(city.IPL) do
  begin
    for i := 0 to high(city.IPL[L].InstObjects) do
    begin

      with city.IPL[L].InstObjects[i] do
      begin

        //        if (id = 1775) or (id = 1776) or (id = 955) or (id = 956) or (id = 1209) or (id = 1302) or (id = 1206) then
        //        begin

        if (deleted = False) and (added = True) then
        begin

          readwriter.Lines.add(format('%d, %s, %d, %f, %f, %f, %f, %f, %f, %f, -1 ',
            [
            id,
            //Name,
            'sampobj',
            int_id,
            Location[0],
            Location[1],
            Location[2],
			rx,
            ry,
            rz,
            rw
            ]));
        end;

      end;

    end;
  end;

  readwriter.Lines.add('end');

  readwriter.Lines.add('cull');
  readwriter.Lines.add('end');
  readwriter.Lines.add('path');
  readwriter.Lines.add('end');
  readwriter.Lines.add('grge');
  readwriter.Lines.add('end');
  readwriter.Lines.add('enex');
  readwriter.Lines.add('end');
  readwriter.Lines.add('pick');
  readwriter.Lines.add('end');
  readwriter.Lines.add('jump');
  readwriter.Lines.add('end');
  readwriter.Lines.add('tcyc');
  readwriter.Lines.add('end');
  readwriter.Lines.add('auzo');
  readwriter.Lines.add('end');
  readwriter.Lines.add('mult');
  readwriter.Lines.add('end');


  readwriter.Lines.SaveToFile(changefileext(SaveDialog2.filename, '.ipl'));

end;

procedure TGtaEditor.btn_buildRCserverClick(Sender: TObject);
{var
i, l, iide: integer;
f: file;}
begin
{
if SaveDialog1.execute = false then exit;

assignfile(f, extractfiledir(SaveDialog1.filename) + '\BPL.ipl');
Rewrite(f, 1);

  for L := 0 to high(city.IPL) do
  begin

//  readwriter.lines.add('FIL: ' + city.IPL[L].filename);

    for i := 0 to high(city.IPL[L].InstObjects) do
	begin

      with city.IPL[L].InstObjects[i] do
      begin

      if (lodobject = false) then begin

        findIDE(id, false).exportRC:= true;

        BlockWrite(f, id, sizeof(id));
        BlockWrite(f, Location[0], sizeof(Location[0]));
        BlockWrite(f, Location[1], sizeof(Location[1]));
        BlockWrite(f, Location[2], sizeof(Location[2]));
        BlockWrite(f, rx, sizeof(rx));
        BlockWrite(f, ry, sizeof(ry));
        BlockWrite(f, rz, sizeof(rz));
        BlockWrite(f, rw, sizeof(rw));

      end;

      end;

    end;
  end;

closefile(f);

readwriter.lines.clear;

for iide := 0 to high(city.IDE) do
for i:= 0 to high(city.IDE[iide].Objects) do begin

with city.IDE[iide].Objects[i] do begin

if exportRC = true then
readwriter.lines.add(format('%s=%d', [ModelName, ID]));
end;
end;

readwriter.lines.SaveToFile(extractfiledir(SaveDialog1.filename) + '\IDE.ide');

IMGLoadImg(pchar(city.imgfile[0]));

for i:= 0 to city.imglist[0].Count-1 do begin
if extractfileext(city.imglist[0][i]) = '.col' then
IMGExportFile(i, pchar(extractfiledir(SaveDialog1.filename) + '\gtacol\' + city.imglist[0][i]));
end;

IMGLoadImg(pchar(city.imgfile[1]));

for i:= 0 to city.imglist[1].Count-1 do begin
if extractfileext(city.imglist[1][i]) = '.col' then
IMGExportFile(i, pchar(extractfiledir(SaveDialog1.filename) + '\gtacol\' + city.imglist[1][i]));
end;
}
end;

procedure TGtaEditor.randomfunc2Click(Sender: TObject);
{var

  mt: Tmatrix;
  ppx, ppy, ppz: single;

  tmpc: PNewtonCollision;
  tmpb: PNewtonBody;

  filelist: Tstrings;
  colholder: Tstrings;

  i, j: integer;

  cobj: TColObject;
  ms: Tmemorystream;
  load_succ: boolean;
  blargh: array [0..2] of TVector3F;

  newmesh: PNewtonCollision;
  cachefile: Tmemorystream;

  idelist: Tstrings;

  colfname: string;
}
begin
(*

  SaveDialog1.filename:= 'C:\Documents and Settings\Jernej\Desktop\raycastserver\bla.txt';

  idelist:= TStringList.create;
  idelist.NameValueSeparator:= '=';
  idelist.LoadFromFile('C:\Documents and Settings\Jernej\Desktop\raycastserver\ide.ide');

  filelist:= TStringlist.Create;
  FindAll(extractfiledir(SaveDialog1.filename) + '\gtacol\*.col', faAnyFile, filelist);

  colholder:= TStringList.create;

  ms:= Tmemorystream.Create;

  for i:= 0 to filelist.count-1 do
  if fileexists(extractfiledir(SaveDialog1.filename) + '\gtacol\' + filelist[i]) = true then
  begin

  ms.LoadFromFile(extractfiledir(SaveDialog1.filename) + '\gtacol\' + filelist[i]);
  ms.position:= 0;
  load_succ:= true;

  repeat
  cobj:= TColObject.create(nil);
  load_succ:= cobj.LoadFromStream(ms);

  if load_succ = true then begin
	colholder.AddObject(cobj.Name, cobj);

	colfname:= idelist.Values[cobj.Name];
	if colfname = '' then
	Memo3.lines.add('Unused: ' + cobj.Name);

	colfname:= extractfiledir(SaveDialog1.filename) + '\NTC\' + colfname + '.NTC';

	if fileexists(colfname) = false then begin

//    showmessage(filelist[i] + #13 + colfname);

	newmesh:= NewtonCreateTreeCollision(nworld, 0);
	NewtonTreeCollisionBeginBuild(newmesh);

	for j:= 0 to high(cobj.Face[0]) do begin

	  blargh[0]:= cobj.Vertex[0][  cobj.Face[0][j].a  ].v;
	  blargh[1]:= cobj.Vertex[0][  cobj.Face[0][j].b  ].v;
	  blargh[2]:= cobj.Vertex[0][  cobj.Face[0][j].c  ].v;

	  Memo3.lines.add(
	  format('%f %f %f   %f %f %f   %f %f %f   ', [
	  blargh[0][0],
	  blargh[0][1],
	  blargh[0][2],

	  blargh[1][0],
	  blargh[1][1],
	  blargh[1][2],

	  blargh[2][0],
	  blargh[2][1],
	  blargh[2][2]
	  ]));

	  NewtonTreeCollisionAddFace(newmesh, 3, @blargh[0][0], 12, 0);
    end;

    Memo3.lines.SaveToFile('c:\dump.txt');

    NewtonTreeCollisionEndBuild(newmesh, 1);

    cachefile := Tmemorystream.Create;
    NewtonCollisionSerialize(nworld, newmesh, cachewrite, cachefile);
    cachefile.SaveToFile(colfname);
    cachefile.Free;
    end; // old file already exists

    // please create a newton collision and dump it into a file named by IDE number, if there is a ide number, it it has no ide number put it in a list to investigate.

//    Memo3.Lines.add(cobj.Name);
  end;

  until load_succ = false;

  end;

  ms.free;
  idelist.free;
*)
end;

procedure TGtaEditor.BitBtn3Click(Sender: TObject);
{var
  filelist: Tstrings;
  colholder: Tstrings;
  ms: Tmemorystream;
  i, j: integer;
  nbody: PNewtonBody;
  newcoll: PNewtonCollision;

  q: TQuaternion;
  qa, qb, qc, qd: single;

  id: integer;
  location: TVertex;
  mt: TMatrix;
const
  root = 'C:\Documents and Settings\Jernej\Desktop\raycastserver\';       }
begin
(*

  filelist:= TStringlist.Create;
  FindAll(root + 'NTC\*.ntc', faAnyFile, filelist);

  colholder:= TStringList.create;

  for i:= 0 to filelist.Count-1 do begin
    ms:= Tmemorystream.Create;

    ms.LoadFromFile(root + 'NTC\' + filelist[i]);

    newcoll:= NewtonCreateCollisionFromSerialization(nworld, cacheread, ms);

    colholder.AddObject(extractfilename(changefileext(filelist[i], '')), Tobject(newcoll));

    ms.free;
  end;

  ms:= Tmemorystream.Create;
  ms.LoadFromFile(root + 'BPL.ipl');

  ProgressBar2.max:= ms.size;

  repeat

  ms.read(id, sizeof(id));

  j:= colholder.IndexOf(inttostr(id));

  if j = -1 then begin
    ms.Seek(7 * 4, sofromcurrent);
    showmessage('Missing: ' + inttostr(id));
    continue;
  end;
                                                                                                          // 3523 3343 3347 3338
  nbody:= NewtonCreateBody(nworld, Pnewtoncollision(
  pointer(colholder.Objects[j])
  ));

  ms.read(location, sizeof(location));

  ms.read(qa, sizeof(qa));
  ms.read(qb, sizeof(qb));
  ms.read(qc, sizeof(qc));
  ms.read(qd, sizeof(qd));

  q.ImagPart[0]:= qa;
  q.ImagPart[1]:= qb;
  q.ImagPart[2]:= qc;
  q.RealPart:= qd;

  mt:= QuaternionToMatrix(q);

  NewtonBodySetMatrix(nbody, @mt[0]);

  ProgressBar2.Position:= ms.position;
  application.processmessages;

  until ms.Position >= ms.Size;

  ms.free;
*)
end;

procedure TGtaEditor.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
var
  lp: Tpoint;
begin

  lp := GlPanel.ScreenToClient(MousePos);

  if lp.x < 0 then
    exit;
  if lp.y < 0 then
    exit;
  if lp.x > glpanel.Width then
    exit;
  if lp.y > glpanel.Height then
    exit;

  Handled := True;

  if pnl_addide.Visible = True then
  begin
    if ssCtrl in Shift then
      zoomadd := zoomadd + (wheeldelta)
    else
      zoomadd := zoomadd + (wheeldelta / 80);
    exit;
  end;

  Camera.MoveCamera(WheelDelta * 0.1);
end;

procedure TGtaEditor.FormKeyPress(Sender: TObject; var Key: char);
var
  speed: single;
begin

  GetKeyboardState(keys);

  if keys[vk_escape] > 13 then
  begin
		selipl  := 0;
		selitem := 0;
		lb_selection.items.clear;
  end;

  if keys[vk_control] > 13 then
    speed := 100000 / (ElapsedTime / 4)
  else
    speed := 100000 / (ElapsedTime * 4);

	if ((keys[vk_control] > 13) and (keys[Ord('Z')] > 13)) and (ActiveControl = GlPanel) then
	begin
		btn_undoClick(btn_undo);
	end;

	if ((keys[vk_control] > 13) and (keys[Ord('C')] > 13)) and (ActiveControl = GlPanel) then
	begin
		Cloneobject1Click(cloneobj);
	end;

  if ((keys[vk_shift] > 13) or (keys[VK_RBUTTON] > 13)) then
  begin
    if (keys[87] > 13) then
    begin
      Camera.MoveCamera(speed * mousemovemodifier);
      a2macc();
    end;
    if (keys[83] > 13) then
    begin
      Camera.MoveCamera(-speed * mousemovemodifier);
      a2macc();
    end;
    if (keys[68] > 13) then
	begin
      Camera.StrafeCamera(speed * mousemovemodifier);
      a2macc();
    end;
    if (keys[65] > 13) then
    begin
      Camera.StrafeCamera(-speed * mousemovemodifier);
      a2macc();
    end;

    // up/down Q+E
    if (keys[81] > 13) then
    begin // q
      Camera.Position[2] := (Camera.Position[2] + speed) * mousemovemodifier;
      Camera.View[2]     := (Camera.View[2] + speed) * mousemovemodifier;
      a2macc();
    end;
    if (keys[69] > 13) then
    begin // e
      Camera.Position[2] := (Camera.Position[2] - speed) * mousemovemodifier;
      Camera.View[2]     := (Camera.View[2] - speed) * mousemovemodifier;
      a2macc();
    end;

  end;

  if key = #13 then
    key := #0;

end;

procedure TGtaEditor.btn_impiplClick(Sender: TObject);
var
  i, j, o: integer;
  tmpstr:  string;
  iplidx:  integer;
  sinx, siny, sinz, cosx, cosy, cosz: single;
begin
  if OpenDialog2.Execute = False then
    exit;

  readwriter.Lines.loadfromfile(OpenDialog2.filename);

  iplidx := high(city.IPL);

  for i := 0 to readwriter.Lines.Count - 1 do
  begin

    j := pos('sampobj', lowercase(readwriter.Lines[i]));

    if j = 0 then
      continue; // no CreateObject no cake!

    textparser.setworkspace(readwriter.Lines[i]);

	if textparser.foo.Count = 12 then
    begin

      setlength(city.IPL[iplidx].InstObjects, length(city.IPL[iplidx].InstObjects) + 1);
      city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] := TINST.Create;

      with city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] do
      begin

        id   := StrToInt(textparser.indexed(0));
        Name := 'added object!';
		LoadedModelIndex := -1;
		draw_distance:= 500.0;

        int_id      := 0;
        Location[0] := textparser.fltindex(3);
        Location[1] := textparser.fltindex(4);
        Location[2] := textparser.fltindex(5);

        rx := textparser.fltindex(6);
        ry := textparser.fltindex(7);
        rz := textparser.fltindex(8);
        rw := textparser.fltindex(9);

        lod := -1;

        haslod  := False;
        rootlod := True;

        added   := True;
        deleted := False;

      end;

    end;

  end;

  mapedited();

end;

procedure TGtaEditor.btn_oldtestgtarClick(Sender: TObject);
{var
  tma, tmn: TMatrix3f;
  x, y:     integer;
}
begin
{
  if codeupdating = True then
    exit;

  if city.IPL[selipl].InstObjects[selitem].added = False then
    exit;

  city.IPL[selipl].InstObjects[selitem].SetGTARotation(
    strtofloat(i_rotx.Text),
    strtofloat(i_roty.Text),
    strtofloat(i_rotz.Text));
}
end;

procedure TGtaEditor.btn_camerahereClick(Sender: TObject);
begin
  textparser.setworkspace(Edit4.Text);

  Camera.Position[0] := textparser.fltindex(0) - 0.54;
  Camera.Position[1] := textparser.fltindex(1) - 0.84;
  Camera.Position[2] := textparser.fltindex(2) + 0.82;
{
-1178.83 -1947.00 291.81
-1179.37 -1947.84 290.99
0.00 0.00 1.00
}
  Camera.View[0]     := textparser.fltindex(0);
  Camera.View[1]     := textparser.fltindex(1);
  Camera.View[2]     := textparser.fltindex(2);
end;

procedure TGtaEditor.btn_previousideClick(Sender: TObject);
begin
  inp_ide.Text := IntToStr(StrToInt(inp_ide.Text) - 1);
end;

procedure TGtaEditor.btn_nextideClick(Sender: TObject);
begin
  inp_ide.Text := IntToStr(StrToInt(inp_ide.Text) + 1);
end;

procedure TGtaEditor.gencode();
var
  i, l:   integer;
  ftext:  string;
  center: t3drect;
  realcenter: TVector3f;
begin

  wnd_showcode.readwriter.Lines.Clear;
  wnd_showcode.lin_cars.Lines.Clear;
  DecimalSeparator := '.';

  ftext := 'CreateObject(%d, %0.5f, %0.5f, %0.5f,   %0.5f, %0.5f, %0.5f);';

  if wnd_showcode.CheckBox1.Checked = True then
    ftext := '%d, %0.5f, %0.5f, %0.5f,   %0.5f, %0.5f, %0.5f;';

  if wnd_showcode.CDO.Checked = True then
    ftext := 'CreateDynamicObject(%d, %0.5f, %0.5f, %0.5f,   %0.5f, %0.5f, %0.5f);';

  // #1: calculate center of objects, #2: use that as relative coords for stuff.
  if wnd_showcode.CheckBox2.Checked = True then
  begin
    center     := calculatecenterofmapping;
    realcenter := center[0];

    realcenter[0] := realcenter[0] + ((center[1][0] - center[0][0]) * 0.5);
    realcenter[1] := realcenter[1] + ((center[1][1] - center[0][1]) * 0.5);
    realcenter[2] := realcenter[2] + ((center[1][2] - center[0][2]) * 0.5);

  end;

  for L := 0 to high(city.IPL) do
  begin
    for i := 0 to high(city.IPL[L].InstObjects) do
    begin

      with city.IPL[L].InstObjects[i] do
      begin

        if (deleted = False) and (added = True) then
        begin

          if (id <= 611) and (id >= 400) then
            wnd_showcode.lin_cars.Lines.add(format('CreateVehicle(%d, %0.4f, %0.4f, %0.4f, %0.4f, %d, %d, %d);', [id, Location[0], Location[1], Location[2], ruz, -1, -1, 100]))
          else
          begin

            if wnd_showcode.CheckBox2.Checked = True then
            begin
              wnd_showcode.readwriter.Lines.add(format(ftext, [id, Location[0] - realcenter[0], Location[1] - realcenter[1], Location[2] - realcenter[2], rux, ruy, ruz]));
            end
            else
              wnd_showcode.readwriter.Lines.add(format(ftext, [id, Location[0], Location[1], Location[2], rux, ruy, ruz]));

          end;
        end;


        if (deleted = True) and (added = False) then
        begin
          // remove map object
          wnd_showcode.readwriter.Lines.add(format('RemoveBuildingForPlayer(playerid, %d, %0.4f, %0.4f, %0.4f, 0.25);', [id, Location[0], Location[1], Location[2]]));

{
          if lod <> -1 then
						wnd_showcode.readwriter.Lines.add(format('RemoveBuildingForPlayer(playerid, %d, %0.4f, %0.4f, %0.4f, 0.25); // lod for %d', [city.IPL[selipl].InstObjects[lod].id, city.IPL[selipl].InstObjects[lod].Location[0], city.IPL[selipl].InstObjects[lod].Location[1], city.IPL[selipl].InstObjects[lod].Location[2], id]));
}
        end;

      end;

    end;
  end;

end;

procedure TGtaEditor.btn_showcodeClick(Sender: TObject);
begin
  gencode();
  wnd_showcode.Show;
  wnd_showcode.BringToFront();
end;

procedure TGtaEditor.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin

  if cursorseen = False then
  begin
    ShowCursor(True);
    cursorseen := True;
  end;

  if ((key = vk_shift) or (key = VK_RBUTTON)) and (gcp = True) then
  begin
    SetCursorPos(oldcp.X, oldcp.Y);
    gcp := False;
    GlPanel.Cursor := crDefault;
  end;
end;

function TGtaEditor.cursorinview: boolean;
var
  rect: Trect;
  ncp:  Tpoint;
begin
  GetWindowRect(GlPanel.handle, rect);

  GetCursorPos(ncp);

  Result := True;

  if ((ncp.x < rect.left) or (ncp.x > rect.right)) or ((ncp.y < rect.top) or (ncp.y > rect.bottom)) then
    Result := False;
end;

procedure TGtaEditor.a2mp;
begin
  mmp := mmp * 1.01;
  if mmp > 200 then
    mmp := 200;
end;

procedure TGtaEditor.btn_sosClick(Sender: TObject);
begin
  pnlhelp.Visible := not pnlhelp.Visible;
end;

procedure TGtaEditor.ThreadedTimer3Timer(Sender: TObject);
begin

  if pnl_addide.Visible = True then
    exit;

  SetThreadAffinityMask(GetCurrentThread, 1); // use cpu / core #2

  // no keys? reset acceleration
  if not ((keys[87] > 13) or (keys[83] > 13) or (keys[68] > 13) or (keys[65] > 13) or (keys[81] > 13) or (keys[69] > 13)) then
    mousemovemodifier := default_move_speed;

  // stream-in
  StreamView;

  UnloadUnneededTextures;
end;

procedure TGtaEditor.btn_randomthingsClick(Sender: TObject);
{var
  i, l: integer;
}
begin
  // mass translation of added objs
{
  for L := 0 to high(city.IPL) do
  begin
    for i := 0 to high(city.IPL[L].InstObjects) do
    begin

      with city.IPL[L].InstObjects[i] do
      begin

          if (deleted = false) and (added = true) then begin

            // 1284.53, 2090.80, 1235.45
            // -567.52 -2928.91 0.00

            Location[0]:= Location[0] - 1284 - 550;
            Location[1]:= Location[1] - 6000;

        end;

      end;

    end;
  end;
}
end;

procedure TGtaEditor.cb_nvcClick(Sender: TObject);
begin
  nightmode := cb_nvc.Checked;
  UnloadUnneededModels(True);
end;

procedure TGtaEditor.Edit4Click(Sender: TObject);
begin
  Edit4.SelectAll;
end;

procedure TGtaEditor.btn_copyviewClick(Sender: TObject);
begin
  clipboard.AsText := getcameracmds();
end;

procedure TGtaEditor.insertobject(ide: integer; px, py, pz: single);
var
  iplidx: integer;
begin

  if (length(city.IPL) = 0) then
    exit;

  iplidx := high(city.IPL);

  setlength(city.IPL[iplidx].InstObjects, length(city.IPL[iplidx].InstObjects) + 1);

  //  outputdebugstring(PChar(format('added +1 inst for: %d, added inst idx is now %d', [iplidx, high(city.IPL[iplidx].InstObjects)])));

  city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] := TINST.Create;

	selipl  := iplidx;
	selitem := high(city.IPL[iplidx].InstObjects);

	makeundogroup();
  makeundo(selipl, selitem, 0, 'added object');

	lb_selection.items.clear;
	lb_selection.items.add(format('%d %d', [selipl, selitem]));

  with city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] do
  begin

    id   := ide;
    Name := 'added object!';
    LoadedModelIndex := -1;

    int_id      := 0;
    Location[0] := px;
    Location[1] := py;
    Location[2] := pz;

    rx := 0;
    ry := 0;
    rz := 0;
    rw := 1;

    rux := 0;
    ruy := 0;
    ruz := 0;

    lod := -1;

    haslod  := False;
    rootlod := True;

    added   := True;
    deleted := False;

  end;

  // map has been edited.
  mapedited();
  mousecontrol := False;

  refreshselectedobjectineditors();

end;

procedure TGtaEditor.btn_addnewobjClick(Sender: TObject);
var
  stringhere: string;
  split2:     integer;
  prompt:     string;
begin

  if (mouse3d[0] = 0) and (mouse3d[1] = 0) and (mouse3d[2] = 0) then
  begin
    ShowMessage('Click where you want to add object first, or just point at some place and press <INSERT>.');
    exit;
  end;

  if (PFListFiltered.ItemIndex <> -1) then
  begin
    split2     := pos('%', NewPrefabs.items[StrToInt(PFListFiltered.Items[PFListFiltered.ItemIndex])]);
    stringhere := copy(NewPrefabs.items[StrToInt(PFListFiltered.Items[PFListFiltered.ItemIndex])], split2 + 1, 2000);
  end
  else
  begin
    stringhere := '2000';
  end;

  if InputQuery('Add object', 'Enter IDE number', stringhere) = True then
  begin
    insertobject(strtointdef(stringhere, 2000), mouse3d[0], mouse3d[1], mouse3d[2]);
  end;

  GlPanel.SetFocus;

end;

procedure TGtaEditor.SpeedButton1Click(Sender: TObject);
var
  split2: integer;
  prompt: string;
begin
  if (cameraviews.ItemIndex = -1) then
	exit;

  split2 := pos('%', cameraviews.Items[cameraviews.ItemIndex]);

  prompt := copy(cameraviews.Items[cameraviews.ItemIndex], 0, split2 - 1);

  if InputQuery('Rename camera view', 'New name', prompt) = True then
  begin
    cameraviews.Items[cameraviews.ItemIndex] := prompt + copy(cameraviews.Items[cameraviews.ItemIndex], split2, 500);
  end;

  saveeditorinfo();
end;

procedure TGtaEditor.cameraviewsDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
var
  split2:   integer;
  strname:  string;
  actcolor: Tcolor;
begin

  split2 := pos('%', cameraviews.Items[Index]);

  strname := copy(cameraviews.Items[Index], 0, split2 - 1);

  textparser.setworkspace(copy(cameraviews.Items[index], split2 + 1, 500));

  with (Control as TListBox).Canvas do
  begin
    if odSelected in state then
      brush.Color := clHighlight
    else
      brush.Color := clBtnFace;

    FillRect(Rect);

    if odSelected in state then
      drawedge((Control as TListBox).Canvas.handle, rect, BDR_SUNKEN, BF_SOFT or BF_RECT)
    else
      drawedge((Control as TListBox).Canvas.handle, rect, EDGE_RAISED, BF_SOFT or BF_RECT);

    actcolor := clBtnText;
    if odSelected in state then
      actcolor := clHighlightText;

    if odFocused in state then
      drawfocusrect(rect);
    inflaterect(rect, -3, -3);

    (Control as TListBox).Canvas.brush.Style := bsclear;
    (Control as TListBox).Canvas.TextOut(rect.Left, rect.top, strname);
    (Control as TListBox).Canvas.TextOut(rect.Left, rect.top + 12, format('(%0.2f, %0.2f, %0.2f)', [textparser.fltindex(0), textparser.fltindex(1), textparser.fltindex(2)]));

  end;

end;

procedure TGtaEditor.ObjFilterChange(Sender: TObject);
var
  i: integer;
begin

  PFListFiltered.items.Clear;

  PFListFiltered.items.BeginUpdate;
  if objfilter.Text = '' then
  begin

    lblfilterindiactor.Color      := clbtnface;
    lblfilterindiactor.font.Color := clblack;

    for i := 0 to newprefabs.items.Count - 1 do
    begin
      PFListFiltered.Items.add(IntToStr(i));
    end;
  end
  else
  begin

    for i := 0 to newprefabs.items.Count - 1 do
    begin
      if Pos(lowercase(objfilter.Text), lowercase(newprefabs.items[i])) > 0 then
        PFListFiltered.Items.add(IntToStr(i));
    end;

    lblfilterindiactor.Color      := clyellow;
    lblfilterindiactor.font.Color := clred;

  end;

  PFListFiltered.items.EndUpdate;

end;

procedure TGtaEditor.PFListFilteredDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
var
  split2:  integer;
  strname: string;
  idenum:  string;
  bmp:     Tbitmap;
  jpg:     TJPEGImage;
begin

  split2  := pos('%', newprefabs.Items[StrToInt(pflistfiltered.items[Index])]);
  strname := copy(newprefabs.Items[StrToInt(pflistfiltered.items[Index])], 0, split2 - 1);
  idenum  := copy(newprefabs.Items[StrToInt(pflistfiltered.items[Index])], split2 + 1, 500);

  with (Control as TListBox).Canvas do
  begin
    if odSelected in state then
	  brush.Color := clHighlight
    else
      brush.Color := clBtnFace;

    FillRect(Rect);

    if odFocused in state then
      drawfocusrect(rect);
    inflaterect(rect, -3, -3);

    if fileexists(working_gta_dir + '\PrefabPics\' + idenum + '.jpg') = True then
    begin
			jpg := tjpegimage.Create;
			jpg.LoadFromFile(working_gta_dir + '\PrefabPics\' + idenum + '.jpg');
			(Control as TListBox).Canvas.StretchDraw(rect, jpg);
			jpg.Free;
		end
		else
		begin
			if fileexists(working_gta_dir + '\PrefabPics\' + idenum + '.bmp') = True then
			begin
				bmp := Tbitmap.Create;
				bmp.LoadFromFile(working_gta_dir + '\PrefabPics\' + idenum + '.bmp');
				(Control as TListBox).Canvas.StretchDraw(rect, bmp);
        bmp.Free;
      end;
    end;

    (Control as TListBox).Canvas.Pen.Color := clblack;
    (Control as TListBox).Canvas.TextOut(rect.Left - 1, rect.bottom - 12, '(' + idenum + ') ' + strname);

    inflaterect(rect, 3, 3);

    if odSelected in state then
      drawedge((Control as TListBox).Canvas.handle, rect, BDR_SUNKEN, BF_SOFT or BF_RECT)
    else
      drawedge((Control as TListBox).Canvas.handle, rect, EDGE_RAISED, BF_SOFT or BF_RECT);

  end;

end;

procedure TGtaEditor.btnclearfilterClick(Sender: TObject);
begin
  ObjFilter.Text := '';
end;

procedure TGtaEditor.renderoneClick(Sender: TObject);
begin

  u_edit.prefabextrastr := '_southnorth';
  rotation_x_axis := 0;
  rotation_y_axis := 0; // profile south-north
  renderpredabbtnClick(renderpredabbtn);

  u_edit.prefabextrastr := '_eastwest';
  rotation_x_axis := 90;
  rotation_y_axis := 0; // profile east-west
  renderpredabbtnClick(renderpredabbtn);

  u_edit.prefabextrastr := '_topbottom';
  rotation_x_axis := -90;
  rotation_y_axis := -90; // profile top-bottom
  renderpredabbtnClick(renderpredabbtn);

  u_edit.prefabextrastr := '_iso1';
  rotation_x_axis := -40;
  rotation_y_axis := -40; // isometrical 1
  renderpredabbtnClick(renderpredabbtn);

  u_edit.prefabextrastr := '_iso2';
  rotation_x_axis := 40;
  rotation_y_axis := -40; // isometrical 2
  renderpredabbtnClick(renderpredabbtn);

  u_edit.prefabextrastr := '';

end;

procedure TGtaEditor.btn_renderrangesClick(Sender: TObject);
var
  i: integer;
begin

  // check: lod_

  for i := StrToInt(Edit5.Text) to StrToInt(Edit6.Text) do
  begin
    addidetext.Text := IntToStr(i);
    renderoneClick(renderone);
  end;
end;

procedure TGtaEditor.btn_addprefabokClick(Sender: TObject);
begin
  newprefabs.Items.Add(addidedesc.Text + '%' + addidetext.Text);
  ObjFilterChange(ObjFilter);
  pnl_addide.hide;
  GlPanel.Align := alClient;

  saveeditorinfo();
end;

procedure TGtaEditor.btn_gtfoaddideClick(Sender: TObject);
begin
  pnl_addide.hide;
  GlPanel.Align := alClient;
end;

procedure TGtaEditor.addidetextChange(Sender: TObject);
begin
  prefabrenderid := addidetext.Text;
  renderpredabbtnClick(renderpredabbtn);
end;

procedure TGtaEditor.btndecClick(Sender: TObject);
begin
  addidetext.Text := IntToStr(StrToInt(addidetext.Text) - 1);
  if (StrToInt(addidetext.Text) < 0) then
    addidetext.Text := '0';
end;

procedure TGtaEditor.btnincClick(Sender: TObject);
begin
  addidetext.Text := IntToStr(StrToInt(addidetext.Text) + 1);
end;

procedure TGtaEditor.cb_mode_nolightingClick(Sender: TObject);
begin
  UnloadUnneededModels(True);
end;

procedure TGtaEditor.SpeedButton2Click(Sender: TObject);
var
  i: integer;
begin
  logger.Show;
  Splitter1.Show;

  if GtaObject = nil then
    exit;

  for i := GtaObject.ComponentCount - 1 downto 0 do
    if GtaObject.Components[i] <> nil then
    begin

      if GtaObject.Components[i] is TTxdUnit then
        logger.Lines.add(format('Texture: %s, ref: %d', [(GtaObject.Components[i] as TTxdUnit).filename, (GtaObject.Components[i] as TTxdUnit).refcount]));


      if GtaObject.Components[i] is TColObject then
        logger.Lines.add(format('Collision: %s', [(GtaObject.Components[i] as TColObject).Name]));

      if GtaObject.Components[i] is TDFFUnit then
      begin
        if (GtaObject.Components[i] as TDFFUnit).model = nil then
          continue;

        logger.Lines.add(format('Model: %s, IDE: %d, texture: %d', [(GtaObject.Components[i] as TDFFUnit).model.filenint, (GtaObject.Components[i] as TDFFUnit).IDE, (GtaObject.Components[i] as TDFFUnit).txdref]));

      end;

    end;

end;

procedure TGtaEditor.saveeditorinfo;
var
	reg: Tregistry;
begin

	Reg := TRegistry.Create;
	Reg.RootKey := HKEY_CURRENT_USER;
	Reg.OpenKey(editor_regkey, true);
	Reg.writebool('autokeys', cb_autopick.checked);

	Reg.writeinteger('nudge_power', nudge_power.position);
	Reg.writeinteger('nudge_power_rotation', nudgepowerrot.position);

	Reg.writeinteger('list_columns', PFListFiltered.columns);

	Reg.CloseKey;

  cameraviews.items.SaveToFile(ChangeFileExt(application.exename, '_cameras'));
  newprefabs.items.SaveToFile(ChangeFileExt(application.exename, '_objects'));
end;

procedure TGtaEditor.RunDebug(gta_sa_exe: string; txtfile: string);
const
  ACL_REVISION = 2;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  Created: boolean;
  hThread: THandle;
  pLibRemote: Pointer;
  NumBytes, ThreadID: cardinal;
  CmdLine, SAMP_DLL: string;
  pSD:    PSECURITY_DESCRIPTOR;
  SA:     SECURITY_ATTRIBUTES;
  pMyAcl: PACL;
  cbAcl:  DWORD;
begin
  if not FileExists(gta_sa_exe) then
  begin
    MessageDlg('GTA: San Andreas executable not found.', mtError, [mbOK], 0);
    exit;
  end;

  FillChar(StartInfo, SizeOf(TStartupInfo), 0);
  FillChar(ProcInfo, SizeOf(TProcessInformation), 0);
  StartInfo.cb := SizeOf(TStartupInfo);

  CmdLine := ' -d -l "' + txtfile + '" ';

  pSD := PSECURITY_DESCRIPTOR(HeapAlloc(GetProcessHeap(), 0,
    sizeof(SECURITY_DESCRIPTOR)));
  InitializeSecurityDescriptor(pSD, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorOwner(pSD, nil, False);
  SetSecurityDescriptorGroup(pSD, nil, False);
  cbAcl  := sizeof(ACL);
  pMyAcl := PACL(LocalAlloc(LPTR, cbAcl));
  if pMyAcl <> nil then
    if InitializeAcl(pMyAcl^, cbAcl, ACL_REVISION) then
      SetSecurityDescriptorDacl(pSD, True, pMyAcl, False);
  SA.nLength := sizeof(SA);
  SA.lpSecurityDescriptor := pSD;
  SA.bInheritHandle := False;

  Created := CreateProcess(nil, PChar('"' + gta_sa_exe + '"' + CmdLine), @SA, nil, False, CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS +
    CREATE_SUSPENDED, nil, PChar(ExtractFilePath(gta_sa_exe)),
    StartInfo, ProcInfo);

  LocalFree(cardinal(pMyACL));
  HeapFree(GetProcessHeap, 0, pSD);

  if not Created then
  begin
	MessageDlg('Unable to execute.', mtError, [mbOK], 0);
    Exit;
  end;

  if RT_GetVersion(nil) shr 31 = 0 then
    GetDebugPrivs;

  SAMP_DLL := ExtractFilePath(gta_sa_exe) + 'samp.dll';
  SetLength(SAMP_DLL, Length(SAMP_DLL) + 1);
  SAMP_DLL[Length(SAMP_DLL)] := #0;

  pLibRemote := xVirtualAllocEx(ProcInfo.hProcess, nil, MAX_PATH,
    MEM_COMMIT, PAGE_READWRITE);
  WriteProcessMemory(ProcInfo.hProcess, pLibRemote, PChar(SAMP_DLL),
    Length(SAMP_DLL), NumBytes);

  hThread := xCreateRemoteThread(ProcInfo.hProcess, nil, 0,
    GetProcAddress(GetModuleHandle('kernel32'), 'LoadLibraryA'), pLibRemote, 0, ThreadID);

  WaitForSingleObject(hThread, 2000);
  CloseHandle(hThread);
  VirtualFreeEx(ProcInfo.hProcess, pLibRemote, MAX_PATH, MEM_RELEASE);
  ResumeThread(ProcInfo.hThread);
  CloseHandle(ProcInfo.hProcess);
end;

procedure TGtaEditor.btn_testmapClick(Sender: TObject);
var
  ts: TStrings;
begin

  ts := TStringList.Create();

  wnd_showcode.readwriter.Lines.Clear;
	wnd_showcode.lin_cars.Lines.Clear;
	wnd_showcode.RadioButton1.Checked := True;
  wnd_showcode.CheckBox2.Checked    := False;
  gencode();

	ts.SetText(PChar(getcameracmds()));

	if selipl <> 0 then
		ts.Add(format('SetPlayerInterior(playerid, %d)', [city.IPL[selipl].InstObjects[selitem].int_id]));

	ts.Add(wnd_showcode.readwriter.Lines.GetText);
	ts.Add(wnd_showcode.lin_cars.Lines.GetText);

	ts.SaveToFile(GetTempDir + '\debug.txt');

	Application.Minimize;

	RunDebug(working_gta_dir + '\gta_sa.exe', GetTempDir + '\debug.txt');

end;

function TGtaEditor.getcameracmds: string;
begin
  Result := format('SetPlayerCameraPos(playerid, %0.4f, %0.4f, %0.4f);' + #10 + #13 + 'SetPlayerCameraLookAt(playerid, %0.4f, %0.4f, %0.4f);', [
    Camera.Position[0], Camera.Position[1], Camera.Position[2],
    Camera.View[0], Camera.View[1], Camera.View[2]]);
end;

procedure TGtaEditor.mapedited;
begin
  btn_showcode.Enabled := True;
  btn_addtoprefabs.Enabled := True;
  btn_addcameraview.Enabled := True;
  btn_ipl.Enabled := True;
end;

procedure TGtaEditor.BitBtn1Click(Sender: TObject);
begin
  wnd_carcolorpicker.Show;
end;

procedure TGtaEditor.a2macc;
begin
  mousemovemodifier := mousemovemodifier * 1.1;
  if mousemovemodifier > 20 then
    mousemovemodifier := 20;

  hadtf := True;
end;

procedure TGtaEditor.btn_prefabresetzoomClick(Sender: TObject);
begin
  zoomadd := 0;
end;

procedure TGtaEditor.inp_searchideChange(Sender: TObject);
var
	iide, ii: longword;
	nidx: integer;
begin

	list_ideall.Items.BeginUpdate;
	list_ideall.Items.Clear;

	for iide := 0 to high(mainidelist) do begin

		if mainidelist[iide] = nil then continue;

		with TOBJS(mainidelist[iide]) do begin
				if ((inp_searchide.Text = '') or  ((Pos(inp_searchide.Text, ModelName) <> 0)) and (Pos('lod', lowercase(ModelName)) = 0)) then
				begin

					if cb_bysize.Checked = True then
						if city.idemapping[iide] <> nil then
						begin

							if (rb_bigger.Checked = True) then
							begin
								if (city.idemapping[iide] as TIDEinforecord).collbounds.radius < strtofloat(inp_bysizer.Text) then
									continue
								else
								if (city.idemapping[iide] as TIDEinforecord).collbounds.radius > strtofloat(inp_bysizer.Text) then
									continue;
							end;
						end;


					nidx:= list_ideall.Items.Add(IntToStr(iide) + ',' + ModelName);

			end;

		end;

	end;

	list_ideall.Items.Endupdate;

end;

procedure TGtaEditor.list_ideallClick(Sender: TObject);
begin

  if list_ideall.ItemIndex = -1 then
    exit;

  textparser.setworkspace(list_ideall.items[list_ideall.ItemIndex]);

  addidetext.Text := textparser.indexed(0);
  addidedesc.Text := textparser.indexed(1);
end;

procedure TGtaEditor.refreshselectedobjectineditors;
var
  L, i, collindex: integer;
  obj: Pobjs;
  lmi, realptr: integer;
begin

  lmi := -1;

  obj := findIDE(city.IPL[selipl].InstObjects[selitem].id, False);

  if obj = nil then
    exit;

  lmi := city.IPL[selipl].InstObjects[selitem].LoadedModelIndex;

  sel_ide := obj.ID;

  list_dfftextures.Lines.Clear;
  txdtextures.Lines.Clear;

  updateeditorfromipl;

	iadv_iden.Text := IntToStr(city.IPL[selipl].InstObjects[selitem].id);
	mdl_name.Text := obj.ModelName;
	ainp_interior.Text := IntToStr(city.IPL[selipl].InstObjects[selitem].int_id);
	extras.Clear;

  extras.Lines.add(format('item %d lod %d', [selitem, city.IPL[selipl].InstObjects[selitem].lod]));

  if city.IPL[selipl].InstObjects[selitem].lod <> -1 then
    extras.Lines.add(format('lod info: ide %d', [
      city.IPL[selipl].InstObjects[city.IPL[selipl].InstObjects[selitem].lod].id
      ]));

  if city.idemapping[city.IPL[selipl].InstObjects[selitem].id] <> nil then
  begin

    with city.idemapping[city.IPL[selipl].InstObjects[selitem].id] as TIDEinforecord do
    begin

      if lmi <> -1 then
      begin
        if (GtaObject.Components[lmi] as TDFFUnit).collref <> nil then
          realptr := integer((GtaObject.Components[lmi] as TDFFUnit).collref)
        else
        begin

          collindex := IsCollLoaded(obj.ModelName);

		  if collindex <> -1 then
            (GtaObject.Components[lmi] as TDFFUnit).collref := TColObject(gtaobject.Components[collindex]);

          realptr := 0;
        end;
      end;

			extras.Lines.Add(format('COLL radius: %0.2f', [collbounds.radius]));
			extras.Lines.Add(format('COLL file: %s', [collname]));
			extras.Lines.Add(format('COLL collection: %s', [collectionname]));

			for i := 0 to ideflags.Items.Count - 1 do
      begin
				ideflags.Checked[i]     := bitunit.IsBitSet(city.IDE[idefile].objects[ideitem].Flags, i);
        ideflags.ItemEnabled[i] := False;
      end;

    end;

  end;

  if lmi <> -1 then
    (GtaObject.Components[lmi] as TDFFUnit).model.glDraw(nil, nil, True, 0, nightmode, false);

  inp_txdname.Text := obj.TextureName;

  lmi := city.IPL[selipl].InstObjects[selitem].LoadedModelIndex;

  if lmi <> -1 then
  begin

    if (GtaObject.Components[lmi] as TDFFUnit).txdref <> -1 then
      if GtaObject.Components[(GtaObject.Components[lmi] as TDFFUnit).txdref] <> nil then
        for i := 0 to high((GtaObject.Components[(GtaObject.Components[lmi] as TDFFUnit).txdref] as TtxdUnit).texture.textures) do
          txdtextures.Lines.add((GtaObject.Components[(GtaObject.Components[lmi] as TDFFUnit).txdref] as TtxdUnit).texture.textures[i].Name);
  end;

  //if Button = mbLeft then wnd_advinfo.show;

end;

procedure TGtaEditor.pleaseloadmethis(ide: integer);
begin

{
if ide = 400 then begin
  outputdebugstring(pchar('list: ' + loadnext.GetText));
end;
}
{
  if rendermodel(ide) = -1 then begin
    outputdebugstring('a-ha!');
    exit; // it is ALREADY LOADED ffs.
  end;
}
  loadnext.add(IntToStr(ide));
end;

procedure TGtaEditor.btn_newton_aClick(Sender: TObject);
var
  i, j, skiptil: integer;
  ide, spherecount: integer;
  parser:   TStrings;
  mkoffset: TMatrix4f;
  spheres:  array[0..255] of PNewtonCollision;
  cachefile: Tmemorystream;
begin

for ide:= 4 to 2000 do begin

	if FileExists(working_gta_dir + '\gta_shapes\' + inttostr(ide) + '.nsg') then begin
		cachefile := Tmemorystream.Create;
		cachefile.loadfromfile(working_gta_dir + '\gta_shapes\' + inttostr(ide) + '.nsg');
		newtonshapes[ide][0] := NewtonCreateCollisionFromSerialization(nworld, cacheread, cachefile);
		cachefile.Free;
	end;

	if FileExists(working_gta_dir + '\gta_shapes\' + inttostr(ide) + '.nsm') then begin
		cachefile := Tmemorystream.Create;
		cachefile.loadfromfile(working_gta_dir + '\gta_shapes\' + inttostr(ide) + '.nsm');
		newtonshapes[ide][1] := NewtonCreateCollisionFromSerialization(nworld, cacheread, cachefile);
		cachefile.Free;
	end;

end;

{
  parser := TStringList.Create;
  parser.LoadFromFile(extractfiledir(application.exename) + '\cars_coll_spheres.txt');

  skiptil := -1;

  for i := 0 to parser.Count - 1 do
  begin

    if skiptil >= i then
      continue;

    textparser.setworkspace(parser.Strings[i]);

    ide     := textparser.intindex(1);
    spherecount := textparser.intindex(2);
    skiptil := i + spherecount;

    if (spherecount > 0) then
    begin

      for j := 1 to spherecount do
      begin
        textparser.setworkspace(parser.Strings[i + j]);

        // build offset matrix.
		mkoffset := identity;
		mkoffset[3, 0] := textparser.fltindex(0);
		mkoffset[3, 1] := textparser.fltindex(1);
		mkoffset[3, 2] := textparser.fltindex(2);

		// build the sphere with specified offset matrix.
        spheres[j - 1] := NewtonCreateSphere(nworld, textparser.fltindex(3), textparser.fltindex(3), textparser.fltindex(3), 0, @mkoffset[0, 0]);

      end;

      // build the compound shape.
      newtonshapes[ide] := NewtonCreateCompoundCollision(nworld, spherecount, spheres[0], 0);
	end;

  end;

  parser.Free;
}

end;

procedure DebugShowGeometryCollision_POLY(const body: PNewtonBody; vertexCount: integer; const FaceArray: PFloat; faceId: integer); cdecl;
var
  i: integer;

  procedure rendervertex(const num: integer);
  begin
    glVertex3fv(pointer(integer(FaceArray) + num * 12));
  end;

begin

  glBegin(gl_polygon);

  for i := 0 to vertexCount - 1 do
  begin
    rendervertex(i);
  end;

  glend;
end;

// show rigid body collision geometry
procedure DebugShowBodyCollision_POLY(const body: Pnewtonbody; userData: pointer); cdecl;
var
  tempmatrix: TMatrix;
  material: PNewtonCollision;
  buffer: array[0..1024] of byte;
  colsptr: pointer;
  coltype: integer;
  compounds: array[0..1024] of PNewtonCollision;
  compoundcnt: integer;
  i: integer;
  f: file;
begin

  NewtonBodyGetMatrix(body, @tempmatrix);

  NewtonCollisionGetInfo(NewtonBodyGetCollision(body), @buffer);
  move(buffer[64], coltype, 4);
  // beta 19 public release adds +4
  move(buffer[72 + 4], compoundcnt, 4);
  move(buffer[76 + 4], colsptr, 4);

  if coltype = SERIALIZE_ID_COMPOUND then
  begin

    CopyMemory(@compounds, colsptr, compoundcnt * 4);

    for i := 0 to compoundcnt - 1 do
    begin
      glColor3ubv(@compounds[i]);
	  NewtonCollisionForEachPolygonDo(compounds[i], @tempmatrix, @DebugShowGeometryCollision_POLY, nil);
    end;

  end
  else
  begin
    material := NewtonBodyGetCollision(body);
    glColor3ubv(@material);
    NewtonCollisionForEachPolygonDo(NewtonBodyGetCollision(body), @tempmatrix, @DebugShowGeometryCollision_POLY, nil);
  end;

end;

procedure TGtaEditor.btn_buildworldClick(Sender: TObject);
var
  i:     integer;
  cl:    TStrings;
  carofs, carofs2: vectortypes.Tmatrix4f;
  rot:   vectortypes.Tmatrix4f;
  rot2:  vectortypes.Tmatrix4f;
  rot3:  vectortypes.Tmatrix4f;
  xx, xy, xz, xw, yy, yz, yw, zz, zw: single;
  Axis, temp: Tvector3f;
  tma:   TMatrix3f;
  quat:  array[0..3] of single;
  quat2: TQuaternion;
  x, y, z, w, s, Angle: single;
begin

	// todo: support virtual worlds

  cl := TStringList.Create;
  cl.LoadFromFile('C:\Documents and Settings\Jernej\Desktop\PSRVR\samp\scriptfiles\cars.txt');

  NewtonDestroyAllBodies(nworld);

  for i := 0 to cl.Count - 1 do
  begin

    textparser.setworkspace(cl.Strings[i]);

    if textparser.foo.Count < 5 then
      continue;

    carofs := IdentityHmgMatrix;

    quat[0] := textparser.fltindex(8);
    quat[1] := textparser.fltindex(9);
    quat[2] := textparser.fltindex(10);
    quat[3] := textparser.fltindex(11);
{
    quat2.ImagPart[0]:= quat[0];
    quat2.ImagPart[1]:= quat[1];
    quat2.ImagPart[2]:= quat[2];
    quat2.RealPart:= quat[3];

    carofs:= vectorgeometry.QuaternionToMatrix(quat2);
}

    // preprocess quarternion rotations
    X := quat[0];
    Y := quat[1];
    Z := quat[2];
    W := -quat[3];
    S := Sqrt(1.0 - W * W);

    // divide by zero
    if not (S = 0) then
    begin
      Axis[0] := X / S;
      Axis[1] := Y / S;
      Axis[2] := Z / S;
      Angle   := 2 * geometry.ArcCos(W);

      if not (Angle = 0) then
      begin
        carofs := CreateGlRotateMatrix(Angle * 180 / Pi, Axis[2], Axis[1], Axis[0]);
      end;
    end;

    rot := carofs;

	carofs[3, 0] := textparser.fltindex(2);
    carofs[3, 1] := textparser.fltindex(3);
	carofs[3, 2] := textparser.fltindex(4);

    Memo1.Lines.Clear;
	Memo1.Lines.Add(format('%0.4f %0.4f %0.4f', [carofs[0][0], carofs[0][1], carofs[0][2]]));
	Memo1.Lines.Add(format('%0.4f %0.4f %0.4f', [carofs[1][0], carofs[1][1], carofs[1][2]]));
	Memo1.Lines.Add(format('%0.4f %0.4f %0.4f', [carofs[2][0], carofs[2][1], carofs[2][2]]));

	if (newtonshapes[textparser.intindex(1)][0] <> nil) then
		newtonvehicles[textparser.intindex(0)] := NewtonCreateBody(nworld, newtonshapes[textparser.intindex(1)][0], @carofs[0, 0])
	else
		Memo1.Lines.Add(format('vehicle %d has no shape for %d', [textparser.intindex(0), textparser.intindex(1)]));

	//create newton bodies -> newtonvehicles

  end;

  cl.Free;

end;

procedure NewtonWorldForEachBodyDo(const newtonWorld: PNewtonWorld; callback: PNewtonBodyIterator);
var
  thebody:  PNewtonBody;
  mtr:      Tmatrix4f;
  Location: TVector3f;
  temp:     Tvector3f;
  distance: single;
begin

  thebody := NewtonWorldGetFirstBody(newtonWorld);

  while thebody <> nil do
  begin

    NewtonBodyGetMatrix(thebody, @mtr[0, 0]);

    location[0] := mtr[3, 0];
    location[1] := mtr[3, 1];
    location[2] := mtr[3, 2];

    temp     := geometry.VectorSubtract(Camera.Position, location);
    distance := geometry.VectorLength(temp);

    if distance < gtaeditor.drawdistance.Position then
    begin
      if (Frustum.IsPointWithin(Location)) = True then
        callback(thebody, newtonbodygetuserdata(thebody));
	end;

    thebody := NewtonWorldGetNextBody(newtonWorld, thebody);
  end;

end;


procedure TGtaEditor.DebugShowCollision_POLY;
begin
  if nworld <> nil then
	NewtonWorldForEachBodyDo(nWorld, DebugShowBodyCollision_POLY);
end;

function TGtaEditor.MouseWorldPos(x, y: integer): TVector;
var
  v, pickres: TVector;
begin
  y := glpanel.Height - y;

  vectorgeometry.SetVector(v, city.IPL[selipl].InstObjects[selitem].Location[0], city.IPL[selipl].InstObjects[selitem].Location[1], 0);

  ScreenVectorIntersectWithPlaneXY(v, city.IPL[selipl].InstObjects[selitem].Location[2], pickres);

  Result := pickres;
end;

function TGtaEditor.ScreenVectorIntersectWithPlaneXY(const aScreenPoint: TVector; const z: single; var intersectPoint: TVector): boolean;
begin

  Result := ScreenVectorIntersectWithPlane(aScreenPoint, vectorgeometry.VectorMake(0, 0, z), ZHmgVector, intersectPoint);
  intersectPoint[3] := 0;

end;

procedure TGtaEditor.renderbackground;
begin
  if backgroundtxd <> -1 then
  begin

    gldisable(gl_lighting);

    GlEnable2D();

    glBindTexture(GL_TEXTURE_2D, (GtaObject.Components[backgroundtxd] as TTxdUnit).texture.findglid('backg'));

    glDepthMask(False);
    glDisable(gl_cull_face);
    gldisable(GL_TEXTURE_GEN_S);
    gldisable(GL_TEXTURE_GEN_T);

    glColor4f(1, 1, 1, 0.5);
    glDisable(gl_blend);
    glenable(gl_texture_2d);

    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glvertex2f(0, 0);
    glTexCoord2f(1, 0);
    glvertex2f(GlPanel.Width, 0);
    glTexCoord2f(1, 1);
    glvertex2f(GlPanel.Width, GlPanel.Height);
    glTexCoord2f(0, 1);
    glvertex2f(0, GlPanel.Height);
    glend;

    glDisable2d();
    glDepthMask(True);

  end;
end;

function TGtaEditor.ScreenVectorIntersectWithPlane(const aScreenPoint, planePoint, planeNormal: TVector; var intersectPoint: TVector): boolean;
var
  v: TVector;
begin

  vectorgeometry.SetVector(v, ScreenToVector(aScreenPoint));
  Result := vectorgeometry.RayCastPlaneIntersect(vectorgeometry.VectorMake(Camera.Position[0], Camera.Position[1], Camera.Position[2]), v, planePoint, planeNormal, @intersectPoint);
  intersectPoint[3] := 1;

end;

function TGtaEditor.ScreenToVector(const aPoint: TVector): TVector;
begin
  Result    := vectorgeometry.VectorSubtract(ScreenToWorld(aPoint), vectorgeometry.VectorMake(Camera.Position[0], Camera.Position[1], Camera.Position[2]));
  Result[3] := 0;
end;

function TGtaEditor.ScreenToWorld(const aPoint: TVector): TVector;
var
  proj, mv: THomogeneousDblMatrix;
  x, y, z:  double;
begin
{
      SetMatrix(proj, ProjectionMatrix);
      SetMatrix(mv, ModelViewMatrix);
      gluUnProject(aPoint[0], aPoint[1], aPoint[2],
                   mv, proj, PHomogeneousIntVector(@FViewPort)^,
                   @x, @y, @z);
      SetVector(Result, x, y, z);
}
end;

function bla: tvector;
begin
{
  GLdouble pos3D_x, pos3D_y, pos3D_z;// arrays to hold matrix information
  GLdouble model_view[16];
  glGetDoublev(GL_MODELVIEW_MATRIX, model_view);
  GLdouble projection[16];
  glGetDoublev(GL_PROJECTION_MATRIX, projection);
  GLint viewport[4];
  glGetIntegerv(GL_VIEWPORT, viewport);  // get 3D coordinates based on window coordinates
  gluUnProject(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0.01,  model_view, projection, viewport,  &pos3D_x, &pos3D_y, &pos3D_z);  
}
end;

procedure TGtaEditor.performmousemoving(X, Y: integer);
var
  OutV, ObjV: TVector3d;
  SendV:      Tvector3f;
  newPos:     Tvector;

  rect: Trect;
  middleX, middleY: integer;

  mx, my: integer;
  chead:  single;

begin

  if mousecontrol = False then
    exit;

  if selipl = 0 then
    exit;

try
	if city.IPL[selipl].InstObjects[selitem].added = False then
		exit;

except
	exit;
end;

  //  GlPanel.Cursor:= crNone;

  mx := MouseXVal - X;
  my := MouseYVal - Y;

  if (mx = 0) and (my = 0) then
    exit; // nothing changed.

  oyea.Lines.add(format('%d %d', [mx, my]));

  chead := camera.getheading;

  if cb_autopick.Checked = True then
  begin

    if (MoveMode = SCREEN_ZAXIS) then
    begin // middle mouse button

      if keys[vk_control] > 13 then
      begin
        lb_mmode.ItemIndex := 3;
      end
      else
      begin
        lb_mmode.ItemIndex := 1;
      end;

    end
    else
    begin

      if keys[vk_control] > 13 then
      begin
        lb_mmode.ItemIndex := 2;
      end
      else
      begin
        lb_mmode.ItemIndex := 0;
      end;

    end;

  end;


  if lb_mmode.ItemIndex = 3 then
  begin
    if my <> 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].rux := city.IPL[selipl].InstObjects[selitem].rux + my * blobs * 3;
			city.IPL[selipl].InstObjects[selitem].SetGTARotation(city.IPL[selipl].InstObjects[selitem].rux, city.IPL[selipl].InstObjects[selitem].ruy, city.IPL[selipl].InstObjects[selitem].ruz);
		end;

		if mx <> 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].ruy := city.IPL[selipl].InstObjects[selitem].ruy + mx * blobs * 3;
			city.IPL[selipl].InstObjects[selitem].SetGTARotation(city.IPL[selipl].InstObjects[selitem].rux, city.IPL[selipl].InstObjects[selitem].ruy, city.IPL[selipl].InstObjects[selitem].ruz);
		end;
	end;

	if lb_mmode.ItemIndex = 1 then
	begin
		if my < 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].Location[2] := city.IPL[selipl].InstObjects[selitem].Location[2] - (cos(chead) * my * blobs);
		end;

		if my > 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].Location[2] := city.IPL[selipl].InstObjects[selitem].Location[2] - (cos(chead) * my * blobs);
		end;
	end;


	if lb_mmode.ItemIndex = 2 then
	begin
		if mx <> 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].ruz := city.IPL[selipl].InstObjects[selitem].ruz + mx * blobs * 3;
			city.IPL[selipl].InstObjects[selitem].SetGTARotation(city.IPL[selipl].InstObjects[selitem].rux, city.IPL[selipl].InstObjects[selitem].ruy, city.IPL[selipl].InstObjects[selitem].ruz);
		end;
	end;



	if lb_mmode.ItemIndex = 0 then
	begin
		// left
		if mx < 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].Location[0] := city.IPL[selipl].InstObjects[selitem].Location[0] + (cos(chead + 1.57079633) * mx * blobs);
			city.IPL[selipl].InstObjects[selitem].Location[1] := city.IPL[selipl].InstObjects[selitem].Location[1] + (sin(chead + 1.57079633) * mx * blobs);
		end;

		// right
		if mx > 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].Location[0] := city.IPL[selipl].InstObjects[selitem].Location[0] + (cos(chead + 1.57079633) * mx * blobs);
			city.IPL[selipl].InstObjects[selitem].Location[1] := city.IPL[selipl].InstObjects[selitem].Location[1] + (sin(chead + 1.57079633) * mx * blobs);
		end;

		if my < 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
			city.IPL[selipl].InstObjects[selitem].Location[0] := city.IPL[selipl].InstObjects[selitem].Location[0] + (cos(chead) * my * blobs);
			city.IPL[selipl].InstObjects[selitem].Location[1] := city.IPL[selipl].InstObjects[selitem].Location[1] + (sin(chead) * my * blobs);
		end;

		if my > 0 then
		begin
			makeundo(selipl, selitem, 1, 'edited');
      city.IPL[selipl].InstObjects[selitem].Location[0] := city.IPL[selipl].InstObjects[selitem].Location[0] + (cos(chead) * my * blobs);
      city.IPL[selipl].InstObjects[selitem].Location[1] := city.IPL[selipl].InstObjects[selitem].Location[1] + (sin(chead) * my * blobs);
    end;

  end;

	updateeditorfromipl;
  a2mp;

  GetWindowRect(GlPanel.Handle, rect);

  middleX := rect.Left + ((rect.right - rect.left) div 2);
  middleY := rect.top + ((rect.bottom - rect.top) div 2);

  // Set the mouse position to the middle of our window
  SetCursorPos(middleX, middleY);
  //  SetCursorPos(left + middleX, top + middleY + glpanel.top);

  MouseXVal := GlPanel.Width div 2;
  MouseYVal := GlPanel.Height div 2;

  if cursorseen = True then
  begin
    ShowCursor(False);
    cursorseen := False;
  end;

{
  exit;

  ObjV[0] := city.IPL[selipl].InstObjects[selitem].Location[0];
  ObjV[1] := city.IPL[selipl].InstObjects[selitem].Location[1];
  ObjV[2] := city.IPL[selipl].InstObjects[selitem].Location[2];

  ScreenToWorldCoords(X, Y, ObjV, MoveMode, OutV);

  SendV[0] := 0;
  SendV[1] := 0;
  SendV[2] := 0;

  if (MoveMode = SCREEN_XYPLANE) then
  begin
    SendV[0] := (OutV[0] - StartV[0]);
    SendV[1] := (OutV[1] - StartV[1]);

    if SendV[0] > 10 then
      exit;
    if SendV[1] > 10 then
      exit;

    SendV[2] := 0;
  end;

  if (MoveMode = SCREEN_ZAXIS) then
  begin
    SendV[0] := 0;
    SendV[1] := 0;
    SendV[2] := OutV[2] - StartV[2];
    if SendV[2] > 1 then
      exit;
  end;

  city.IPL[selipl].InstObjects[selitem].Location[0] := city.IPL[selipl].InstObjects[selitem].Location[0] + SendV[0];
  city.IPL[selipl].InstObjects[selitem].Location[1] := city.IPL[selipl].InstObjects[selitem].Location[1] + SendV[1];
  city.IPL[selipl].InstObjects[selitem].Location[2] := city.IPL[selipl].InstObjects[selitem].Location[2] + SendV[2];

  ObjV[0] := city.IPL[selipl].InstObjects[selitem].Location[0];
  ObjV[1] := city.IPL[selipl].InstObjects[selitem].Location[1];
  ObjV[2] := city.IPL[selipl].InstObjects[selitem].Location[2];

  ScreenToWorldCoords(X, Y, ObjV, MoveMode, StartV);

	updateeditorfromipl;
}
end;

procedure TGtaEditor.lb_mmodeDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
var
  split2:   integer;
  strname:  string;
  actcolor: Tcolor;
begin

  with (Control as TListBox).Canvas do
  begin
    if odSelected in state then
      brush.Color := clHighlight
    else
	  brush.Color := clBtnFace;

    FillRect(Rect);

    if odSelected in state then
      drawedge((Control as TListBox).Canvas.handle, rect, BDR_SUNKEN, BF_SOFT or BF_RECT)
    else
      drawedge((Control as TListBox).Canvas.handle, rect, EDGE_RAISED, BF_SOFT or BF_RECT);

    actcolor := clBtnText;
    if odSelected in state then
      actcolor := clHighlightText;

    if odFocused in state then
      drawfocusrect(rect);
    inflaterect(rect, -3, -3);

    (Control as TListBox).Canvas.brush.Style := bsclear;
    (Control as TListBox).Canvas.TextOut(rect.Left, rect.top, strname);
    (Control as TListBox).Canvas.TextOut(rect.Left, rect.top, (Control as TListBox).Items[Index]);

  end;

end;

function TGtaEditor.calculatecenterofmapping: t3drect;
var
  L, i: integer;
begin

  Result[0] := vectorgeometry.AffineVectorMake(99999, 999999, 99999);
  Result[1] := vectorgeometry.AffineVectorMake(-99999, -999999, -99999);

  for L := 0 to high(city.IPL) do
  begin
    for i := 0 to high(city.IPL[L].InstObjects) do
    begin

      with city.IPL[L].InstObjects[i] do
      begin

        if (deleted = True) or (added = False) then
          continue;

        if Location[0] < Result[0][0] then
          Result[0][0] := Location[0];
        if Location[1] < Result[0][1] then
          Result[0][1] := Location[1];
        if Location[2] < Result[0][2] then
          Result[0][2] := Location[2];

        if Location[0] > Result[1][0] then
          Result[1][0] := Location[0];
        if Location[1] > Result[1][1] then
          Result[1][1] := Location[1];
		if Location[2] > Result[1][2] then
          Result[1][2] := Location[2];

      end; // with object

    end;
  end;

end;

procedure TGtaEditor.CloneSelection(switchnewobj: boolean);
var
	iplidx: integer;

	i: integer;
	tipl, titem: integer;
begin
	if selitem = 0 then
		exit;
		
	for i:= 0 to lb_selection.items.count-1 do begin

		textparser.setworkspace(lb_selection.Items[i]);

		tipl:= textparser.intindex(0);
		titem:= textparser.intindex(1);


	iplidx := high(city.IPL);

	setlength(city.IPL[iplidx].InstObjects, length(city.IPL[iplidx].InstObjects) + 1);

	makeundogroup();
	makeundo(iplidx, high(city.IPL[iplidx].InstObjects), 0, 'added object');

	city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] := TINST.Create;

	with city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] do
	begin

		id   := city.IPL[tipl].InstObjects[titem].id;
		Name := 'added object!';
		LoadedModelIndex := city.IPL[tipl].InstObjects[titem].LoadedModelIndex;

		int_id   := 0;
		Location := city.IPL[tipl].InstObjects[titem].Location;

		rx := city.IPL[tipl].InstObjects[titem].rx;
		ry := city.IPL[tipl].InstObjects[titem].ry;
		rz := city.IPL[tipl].InstObjects[titem].rz;
		rw := city.IPL[tipl].InstObjects[titem].rw;

		rux := city.IPL[tipl].InstObjects[titem].rux;
		ruy := city.IPL[tipl].InstObjects[titem].ruy;
		ruz := city.IPL[tipl].InstObjects[titem].ruz;

		lod := -1;

		haslod  := False;
		rootlod := True;

		added   := True;
		deleted := False;

		if switchnewobj = True then
		begin
			selipl  := iplidx;
			selitem := high(city.IPL[iplidx].InstObjects);
		end;

		mapedited();
	end;


	end;





{
	if selitem = 0 then
		exit;

	iplidx := high(city.IPL);

  setlength(city.IPL[iplidx].InstObjects, length(city.IPL[iplidx].InstObjects) + 1);

  city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] := TINST.Create;

  //  outputdebugstring(PChar(format('added +1 inst for: %d, added inst idx is now %d', [iplidx, high(city.IPL[iplidx].InstObjects)])));

  with city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] do
  begin

    id   := city.IPL[selipl].InstObjects[selitem].id;
    Name := 'added object!';
    LoadedModelIndex := city.IPL[selipl].InstObjects[selitem].LoadedModelIndex;

    int_id   := 0;
    Location := city.IPL[selipl].InstObjects[selitem].Location;

    rx := city.IPL[selipl].InstObjects[selitem].rx;
    ry := city.IPL[selipl].InstObjects[selitem].ry;
    rz := city.IPL[selipl].InstObjects[selitem].rz;
    rw := city.IPL[selipl].InstObjects[selitem].rw;

    rux := city.IPL[selipl].InstObjects[selitem].rux;
    ruy := city.IPL[selipl].InstObjects[selitem].ruy;
    ruz := city.IPL[selipl].InstObjects[selitem].ruz;

    lod := -1;

    haslod  := False;
    rootlod := True;

    added   := True;
    deleted := False;

    mapedited();
  end;


}
end;

procedure TGtaEditor.importreadwriter;
var
  L, i, j, o: integer;
  tmpstr:   string;
  iplidx:   integer;
  iscar:    boolean;
  idei:     integer;
  tempoint: tvector3f;
  radius:   single;
  sinx, siny, sinz, cosx, cosy, cosz: single;

begin

  iplidx := high(city.IPL);

  for i := 0 to readwriter.Lines.Count - 1 do
  begin

	try
    iscar := False;

    j := pos('createobject', lowercase(readwriter.Lines[i]));

    // not found, try streamer createdynamicobject
    if j = 0 then
      j := pos('createdynamicobject', lowercase(readwriter.Lines[i]));

    if j = 0 then
    begin
      j := pos('removebuildingforplayer', lowercase(readwriter.Lines[i]));

      if j > 0 then
      begin

        j := pos('(', readwriter.Lines[i]);
        o := pos(')', readwriter.Lines[i]);

        if j > 0 then
        begin
		  tmpstr := copy(readwriter.Lines[i], j + 1, o - j - 1);

          tmpstr := textparser.stripcomments('//', tmpstr);
          textparser.setworkspace(tmpstr);

          idei     := textparser.intindex(1);
          tempoint := vectorgeometry.AffineVectorMake(textparser.fltindex(2), textparser.fltindex(3), textparser.fltindex(4));
          radius   := textparser.fltindex(5);

          for L := 0 to high(city.IPL) do
          begin
            for j := 0 to high(city.IPL[L].InstObjects) do
            begin

              with city.IPL[L].InstObjects[j] do
              begin

                if id <> idei then
                  continue;

                if (vectorgeometry.VectorDistance(Location, tempoint) < radius) then
                  Deleted := True;

              end;
            end;
          end;

		end;

		continue;
	  end;

    end; // removebuilding

	// CreateVehicle(400, 231.1018, 1855.6725, 21.7846, 0.0000, -1, -1, 100);

	if j = 0 then
	begin
      j := pos('createvehicle', lowercase(readwriter.Lines[i]));

      if j = 0 then
        j := pos('addstaticvehicle', lowercase(readwriter.Lines[i]));

      if j = 0 then
        j := pos('addvehicle', lowercase(readwriter.Lines[i]));

      if j = 0 then
        j := pos('addspecialvehicle', lowercase(readwriter.Lines[i]));


      if (j <> 0) then
        iscar := True;

    end;

	if j = 0 then
      continue; // no CreateObject no cake!

    j := pos('(', readwriter.Lines[i]);
    o := pos(')', readwriter.Lines[i]);

    if j > 0 then
    begin
      tmpstr := copy(readwriter.Lines[i], j + 1, o - j - 1);

      tmpstr := textparser.stripcomments('//', tmpstr);
      textparser.setworkspace(tmpstr);

      setlength(city.IPL[iplidx].InstObjects, length(city.IPL[iplidx].InstObjects) + 1);

      city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] := TINST.Create;

      with city.IPL[iplidx].InstObjects[high(city.IPL[iplidx].InstObjects)] do
      begin

        //if textparser.indexed(0) > 0 

        try
          id   := StrToInt(textparser.indexed(0));
          Name := 'added object!';
          LoadedModelIndex := -1;

          int_id      := 0;
          Location[0] := textparser.fltindex(1);
          Location[1] := textparser.fltindex(2);
          Location[2] := textparser.fltindex(3);

          if iscar = True then
          begin
            SetGTARotation(0, 0, textparser.fltindex(4));

            carcolor1 := textparser.intindex(5);
            carcolor2 := textparser.intindex(6);

          end
          else
            SetGTARotation(textparser.fltindex(4), textparser.fltindex(5), textparser.fltindex(6));

          lod := -1;

          haslod  := False;
          rootlod := True;

          added   := True;
          deleted := False;
        except
        end;

      end;

	end;

		except end;

	end;

  mapedited();

end;

procedure TGtaEditor.brn_importpasteClick(Sender: TObject);
begin

  readwriter.Lines.SetText(PChar(clipboard.astext));

  importreadwriter();
end;

procedure TGtaEditor.btn_transformallClick(Sender: TObject);
var
	i, tipl, titem: integer;
	fx, fy, fz: single;
begin

	textparser.setworkspace(inp_transformer.Text);

	if codeupdating = True then
			exit;

	fx:= textparser.fltindex(0);
	fy:= textparser.fltindex(1);
	fz:= textparser.fltindex(2);

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;

	city.IPL[tipl].InstObjects[titem].Location[0]:= city.IPL[tipl].InstObjects[titem].Location[0] + fx;
	city.IPL[tipl].InstObjects[titem].Location[1]:= city.IPL[tipl].InstObjects[titem].Location[1] + fy;
	city.IPL[tipl].InstObjects[titem].Location[2]:= city.IPL[tipl].InstObjects[titem].Location[2] + fz;

	end;
end;

procedure TGtaEditor.btn_rstanglesClick(Sender: TObject);
begin
inp_rotations.Text:= '000.0000, 000.0000, 000.0000';
end;

procedure TGtaEditor.dassaddsaClick(Sender: TObject);
var
  i, l: integer;
begin

  for L := 0 to high(city.IPL) do
  begin
    for i := 0 to high(city.IPL[L].InstObjects) do
    begin

      with city.IPL[L].InstObjects[i] do
      begin

			// WTF je to.
				if ((id <> 1209)
	and (id <> 1302  )
	and (id <> 1776 )
	and (id <> 1775)
	and (id <> 955)) then
	continue;

				added := True;

			end;

		end;
	end;

end;

procedure TGtaEditor.fuckbuttonClick(Sender: TObject);
var
	coll, coll2: TColObject;
	i: integer;
	ms: Tmemorystream;
begin

coll:= TColObject.Create(application);
coll2:= TColObject.Create(application);

ms:= Tmemorystream.create();
ms.LoadFromFile('C:\Documents and Settings\Jernej\Desktop\tram_merge.col');

coll.LoadFromStream(ms);
coll2.LoadFromStream(ms);

setlength(coll.Box, length(coll2.box));

for i:= 0 to high(coll2.Box) do begin
	coll.Box[i]:= coll2.box[i];
end;

ms.SetSize(0);
coll.SaveToStream(handle, ms, true);

ms.savetofile('C:\Documents and Settings\Jernej\Desktop\SUCCESS.col');

ms.free;


end;

procedure TGtaEditor.nudgeleftClick(Sender: TObject);
var
	i, tipl, titem: integer;
	chead: single;
begin

	chead := camera.getheading;

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;
		city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] + (cos(chead + 1.57079633) * nudgemp);
		city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] + (sin(chead + 1.57079633) * nudgemp);
	end;

	codeupdating := true;
	updatenudgeedtors();
	codeupdating := False;

end;

procedure TGtaEditor.nudgerightClick(Sender: TObject);
var
	i, tipl, titem: integer;
	chead: single;
begin

	chead := camera.getheading;

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;
		city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] - (cos(chead + 1.57079633) * nudgemp);
		city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] - (sin(chead + 1.57079633) * nudgemp);
	end;

	codeupdating := true;
	updatenudgeedtors();
	codeupdating := False;

end;

procedure TGtaEditor.nudgeupClick(Sender: TObject);
var
	i, tipl, titem: integer;
	chead: single;
begin

	chead := camera.getheading;

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;
		city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] + (cos(chead) * nudgemp);
		city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] + (sin(chead) * nudgemp);
	end;

	codeupdating := true;
	updatenudgeedtors();
	codeupdating := False;


end;

procedure TGtaEditor.nudgedownClick(Sender: TObject);
var
	i, tipl, titem: integer;
	chead: single;
begin

	chead := camera.getheading;

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;
			city.IPL[tipl].InstObjects[titem].Location[0] := city.IPL[tipl].InstObjects[titem].Location[0] - (cos(chead) * nudgemp);
			city.IPL[tipl].InstObjects[titem].Location[1] := city.IPL[tipl].InstObjects[titem].Location[1] - (sin(chead) * nudgemp);
	end;

	codeupdating := true;
	updatenudgeedtors();
	codeupdating := False;

end;

procedure TGtaEditor.nudge_powerChange(Sender: TObject);
begin
nudgemp:= nudge_power.position * (0.5 / 500);
Label52.caption:= format('nudge power: %0.4f', [nudgemp]);
end;

procedure TGtaEditor.nudgeraiseClick(Sender: TObject);
var
	i, tipl, titem: integer;
	chead: single;
begin

	chead := camera.getheading;

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;

		city.IPL[selipl].InstObjects[selitem].Location[2] := city.IPL[selipl].InstObjects[selitem].Location[2] + nudgemp;
	end;
end;

procedure TGtaEditor.nudgelowClick(Sender: TObject);
var
	i, tipl, titem: integer;
	chead: single;
begin

	chead := camera.getheading;

	for i:= 0 to lb_selection.items.count-1 do begin

	textparser.setworkspace(lb_selection.Items[i]);

	tipl:= textparser.intindex(0);
	titem:= textparser.intindex(1);

	if city.IPL[tipl].InstObjects[titem].added = False then
		continue;

		city.IPL[selipl].InstObjects[selitem].Location[2] := city.IPL[selipl].InstObjects[selitem].Location[2] - nudgemp;
	end;
end;

procedure TGtaEditor.BitBtn4Click(Sender: TObject);
begin
inp_ax.text:= format('%0.4f', [strtofloat(inp_ax.text) - nudgemp]);
end;

procedure TGtaEditor.BitBtn5Click(Sender: TObject);
begin
inp_ax.text:= format('%0.4f', [strtofloat(inp_ax.text) + nudgemp]);
end;

procedure TGtaEditor.btn_thingsgodownClick(Sender: TObject);
begin
inp_ay.text:= format('%0.4f', [strtofloat(inp_ay.text) - nudgemp]);
end;

procedure TGtaEditor.BitBtn2Click(Sender: TObject);
begin
inp_ay.text:= format('%0.4f', [strtofloat(inp_ay.text) + nudgemp]);
end;

procedure TGtaEditor.BitBtn6Click(Sender: TObject);
begin
inp_az.text:= format('%0.4f', [strtofloat(inp_az.text) + nudgemp]);
end;

procedure TGtaEditor.btn_rotatelClick(Sender: TObject);
begin
inp_rz.text:= format('%0.4f', [strtofloat(inp_rz.text) - nudgerotmp]);
end;

procedure TGtaEditor.btn_arrrClick(Sender: TObject);
begin
inp_rz.text:= format('%0.4f', [strtofloat(inp_rz.text) + nudgerotmp]);
end;

procedure TGtaEditor.inp_axChange(Sender: TObject);
begin

if codeupdating = true then exit;

codeupdating := True;
try
textparser.setworkspace(inp_coordsedit.text);
inp_coordsedit.text:= format('%s, %s, %s', [inp_ax.Text, inp_ay.Text, inp_az.Text]);
inp_rotations.Text := Format('%s, %s, %s', [inp_rx.text, inp_ry.text, inp_rz.text]);
codeupdating := false;
inp_coordseditChange(inp_coordsedit);
except end;

end;

procedure TGtaEditor.BitBtn7Click(Sender: TObject);
begin
inp_az.text:= format('%0.4f', [strtofloat(inp_az.text) - nudgemp]);
end;

procedure TGtaEditor.btn_loadwithcolsClick(Sender: TObject);
begin
btn_wantcols.checked:= true;
btn_load.click;
end;

procedure TGtaEditor.btn_rxdClick(Sender: TObject);
begin
inp_rx.text:= format('%0.4f', [strtofloat(inp_rx.text) - nudgerotmp]);
end;

procedure TGtaEditor.btn_rxuClick(Sender: TObject);
begin
inp_rx.text:= format('%0.4f', [strtofloat(inp_rx.text) + nudgerotmp]);
end;

procedure TGtaEditor.btn_rydClick(Sender: TObject);
begin
inp_ry.text:= format('%0.4f', [strtofloat(inp_ry.text) - nudgerotmp]);
end;

procedure TGtaEditor.btn_ryuClick(Sender: TObject);
begin
inp_ry.text:= format('%0.4f', [strtofloat(inp_ry.text) + nudgerotmp]);
end;

procedure TGtaEditor.updatenudgeedtors;
begin
if (selipl < 1) or (selitem < 0) then exit;

	with city.IPL[selipl].InstObjects[selitem] do
	begin
		inp_ax.Text := Format('%1.4f', [Location[0]]);
		inp_ay.Text := Format('%1.4f', [Location[1]]);
		inp_az.Text := Format('%1.4f', [Location[2]]);
		inp_rx.Text := Format('%1.4f', [rux]);
		inp_ry.Text := Format('%1.4f', [ruy]);
		inp_rz.Text := Format('%1.4f', [ruz]);
	end;
end;

procedure TGtaEditor.TabSheet2Resize(Sender: TObject);
var
b: integer;
begin

b:= PFListFiltered.Columns;

if b = 0 then
	b:= 1;

PFListFiltered.ItemHeight:= PFListFiltered.ClientWidth div b;
end;

procedure TGtaEditor.btn_cyclecolumnsClick(Sender: TObject);
begin

if PFListFiltered.columns = 2 then
	PFListFiltered.columns:= 0
else
	PFListFiltered.columns:= 2;

TabSheet2Resize(TabSheet2);

end;

procedure TGtaEditor.switch2img(imgidx: integer);
begin

	if imgidx = lastimg then exit;

	IMGLoadImg(PChar(city.imgfile[imgidx]));
	lastimg := imgidx;

end;

procedure TGtaEditor.makeundo(iplf, ipli: integer; typ: integer; reason:string);
begin

// type 0: delete this object on undo (was added later), type 1: revert to previous settings.

if typ = 0 then
	undostack.Items.Add(format('0,%d,%d,%d,%s', [undogroup, iplf, ipli, reason]))
else
	undostack.Items.Add(format('1,%d,%d,%d,%d,%s,%0.9f,%0.9f,%0.9f,%0.9f,%0.9f,%0.9f,%0.9f,%d,%d,%0.9f,%0.9f,%0.9f,%d,%d,%s', [undogroup,
	iplf,
	ipli,
	city.IPL[iplf].InstObjects[ipli].id,
	'FF',
	city.IPL[iplf].InstObjects[ipli].Location[0],
	city.IPL[iplf].InstObjects[ipli].Location[1],
	city.IPL[iplf].InstObjects[ipli].Location[2],
	city.IPL[iplf].InstObjects[ipli].rx,
	city.IPL[iplf].InstObjects[ipli].ry,
	city.IPL[iplf].InstObjects[ipli].rz,
	city.IPL[iplf].InstObjects[ipli].rw,
	byte(city.IPL[iplf].InstObjects[ipli].added),
	byte(city.IPL[iplf].InstObjects[ipli].deleted),
	city.IPL[iplf].InstObjects[ipli].rux,
	city.IPL[iplf].InstObjects[ipli].ruy,
	city.IPL[iplf].InstObjects[ipli].ruz,
	city.IPL[iplf].InstObjects[ipli].carcolor1,
	city.IPL[iplf].InstObjects[ipli].carcolor2,
	reason]
	));

end;

procedure TGtaEditor.btn_undoClick(Sender: TObject);
var
	iplf, ipli: integer;
	thisgroup: integer;
	canquit: boolean;
	hits: integer;
begin

if undostack.items.count < 1 then exit;

hits:= 0;
canquit:= false;

textparser.setworkspace(undostack.Items[undostack.items.count-1]);
thisgroup:= textparser.intindex(1);

repeat

if (thisgroup <> textparser.intindex(1)) then
	exit;

if (textparser.intindex(0) = 0) then begin
	city.IPL[textparser.intindex(2)].InstObjects[textparser.intindex(3)].deleted:= true;
end else begin

	iplf:= textparser.intindex(2);
	ipli:= textparser.intindex(3);

	city.IPL[iplf].InstObjects[ipli].id:= textparser.intindex(4);
	city.IPL[iplf].InstObjects[ipli].Name:= textparser.indexed(5);
	city.IPL[iplf].InstObjects[ipli].Location[0]:= textparser.fltindex(6);
	city.IPL[iplf].InstObjects[ipli].Location[1]:= textparser.fltindex(7);
	city.IPL[iplf].InstObjects[ipli].Location[2]:= textparser.fltindex(8);
	city.IPL[iplf].InstObjects[ipli].rx:= textparser.fltindex(9);
	city.IPL[iplf].InstObjects[ipli].ry:= textparser.fltindex(10);
	city.IPL[iplf].InstObjects[ipli].rz:= textparser.fltindex(11);
	city.IPL[iplf].InstObjects[ipli].rw:= textparser.fltindex(12);
	city.IPL[iplf].InstObjects[ipli].added:= textparser.fltindex(13) = 1;
	city.IPL[iplf].InstObjects[ipli].deleted:= textparser.fltindex(14) = 1;
	city.IPL[iplf].InstObjects[ipli].rux:= textparser.fltindex(15);
	city.IPL[iplf].InstObjects[ipli].ruy:= textparser.fltindex(16);
	city.IPL[iplf].InstObjects[ipli].ruz:= textparser.fltindex(17);
	city.IPL[iplf].InstObjects[ipli].carcolor1:= textparser.intindex(18);
	city.IPL[iplf].InstObjects[ipli].carcolor2:= textparser.intindex(19);

end;

	undostack.Items.Delete(undostack.items.count-1);

if undostack.items.count < 1 then
	exit;

	textparser.setworkspace(undostack.Items[undostack.items.count-1]);

	hits:= hits + 1;

	if hits > 100 then
		exit;

until canquit = true;


end;

procedure TGtaEditor.makeundogroup;
begin
	undogroup:= undogroup + 1;
end;

procedure TGtaEditor.QuickSort(iLo, iHi: Integer);
var
	 Lo, Hi, Pivot, T: Integer;
begin
	 Lo := iLo;
	 Hi := iHi;

	 Pivot:= integer(list_ideall.Items.Objects[(Lo + Hi) div 2]);

	 repeat

		 while integer(list_ideall.Items.Objects[Lo]) < Pivot do Inc(Lo);
		 while integer(list_ideall.Items.Objects[Hi]) > Pivot do Dec(Hi);

		 if Lo <= Hi then
		 begin

			 list_ideall.Items.Move(Lo, Hi);

			 Inc(Lo);
			 Dec(Hi);
		 end;
	 until Lo > Hi;
	 if Hi > iLo then QuickSort(iLo, Hi) ;
	 if Lo < iHi then QuickSort(Lo, iHi) ;
end;

function EnumScreensProc(hm: HScreen; dc: HDC; r: PRect; Data: Pointer): boolean; stdcall;
var
  moninfo: tagScreenINFOEXA;
  display: TDisplayDeviceA;
begin
  // 1 new Screen!

    setlength(Screens, length(Screens) + 1);

    // get Screen resolution, flags, etc..
    fillchar(moninfo, sizeof(moninfo), 0);
    moninfo.cbSize := 72;
		GetMonitorInfoA(hm, @moninfo);

	//  move(moninfo.szDevice, Screens[length(Screens)-1].name, 32); // no longer used, see below
		move(r^, Screens[length(Screens) - 1].Rect, sizeof(Trect));
		Screens[length(Screens) - 1].def := moninfo.dwFlags and ScreenINFOF_PRIMARY = ScreenINFOF_PRIMARY;

		Screens[length(Screens) - 1].depth := GetDeviceCaps(hm, BITSPIXEL);


    // get proper device name
    display.cb := sizeof(display);
    EnumDisplayDevicesA(nil, length(Screens) - 1, display, 0);

		move(display.DeviceString, Screens[length(Screens) - 1].Name, 128);

  Result := True;
end;

procedure TGtaEditor.btn_reportClick(Sender: TObject);
var
	i: integer;
	tempdc: hdc;
	buffer: pchar;
	reg: tregistry;
begin
	wnd_report.reports.lines.clear;

	wnd_report.reports.lines.add(wnd_about.Label1.caption);
	wnd_report.reports.lines.add('');

	TempDC:= GetDC(GetDesktopWindow());
	i:= GetDeviceCaps(TempDC, BITSPIXEL);

	wnd_report.reports.lines.add('Primary screen color depth: ' + inttostr(i) + ' bits.');

	if length(Screens) = 0 then
		EnumDisplayMonitors(0, nil, @EnumScreensProc, self);

	for i:= 0 to high(Screens) do begin


		wnd_report.reports.lines.add(format('Screen %s default: %d resolution: %dx%d location (%d, %d ) ',
		[Screens[i].Name, integer(Screens[i].def),

		Screens[i].rect.right - Screens[i].rect.left, Screens[i].rect.bottom - Screens[i].rect.top,

		Screens[i].rect.left, Screens[i].rect.top

		] ));

	end;

	wnd_report.reports.lines.add('');
	wnd_report.reports.lines.add('Running from: ' + application.exename);

 	Reg := TRegistry.Create;
 	Reg.RootKey := HKEY_CURRENT_USER;
	Reg.OpenKey('SOFTWARE\Rockstar Games\GTA San Andreas\Installation', False);
	if Reg.ValueExists('ExePath') then
		wnd_report.reports.lines.add('GTA path - HKCU: ' + Reg.ReadString('ExePath'))
	else
	begin
		Reg.RootKey := HKEY_LOCAL_MACHINE;
		Reg.OpenKey('SOFTWARE\Rockstar Games\GTA San Andreas\Installation', False);
		if Reg.ValueExists('ExePath') then
			wnd_report.reports.lines.add('GTA path - HKLM: ' + Reg.ReadString('ExePath'));
	end;
	Reg.CloseKey;

	wnd_report.reports.lines.add('');

	Buffer:= glGetString(GL_VERSION);
	wnd_report.reports.lines.add('OpenGL: ' + Buffer);

	Buffer:= glGetString(GL_RENDERER);
	wnd_report.reports.lines.add('Renderer: ' + Buffer);

	Buffer:= glGetString(GL_Vendor);
	wnd_report.reports.lines.add('Vendor: ' + Buffer);

//	Buffer:= glGetString(GL_EXTENSIONS);
//	wnd_report.reports.lines.add('Extensions: ' + Buffer);

	wnd_report.show;

end;

procedure TGtaEditor.btn_closematerialClick(Sender: TObject);
begin
wnd_advinfo.hide;
end;

procedure TGtaEditor.WMNCHitTest(var Msg: TWMNCHitTest);
begin
	inherited;
	
//	if Msg.Result = htClient then Msg.Result := htCaption;
end;

procedure TGtaEditor.Image15MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

		ReleaseCapture();
		SendMessage(wnd_advinfo.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);

end;


procedure TGtaEditor.convert_some_collsClick(Sender: TObject);
var
	i: integer;
	map, filebuff: Tmemorystream;
	collindex: integer;
	fobj: pobjs;
	avail2render: integer;
	dffloader:    TDffLoader;
	coll: TColObject;
	iide, ii: integer;
begin

if city.idetable = nil then begin
	showmessage('load the map.. or something.');
	exit;
end;


map:= tmemorystream.create;

//	city.IPL[selipl].InstObjects[selitem]

  for iide := 0 to high(city.IPL) do
  begin
	  for ii := 0 to high(city.IPL[iide].InstObjects) do
	  begin


		i:= city.IPL[iide].InstObjects[ii].id;


		if ((FileExists(working_gta_dir + '\gta_shapes\' + inttostr(i) + '.nsm')) or (FileExists(working_gta_dir + '\gta_shapes\' + inttostr(i) + '.nsg'))) then begin

			map.Write(i, sizeof(i));

			map.Write(city.IPL[iide].InstObjects[ii].Location[0], sizeof(city.IPL[iide].InstObjects[ii].Location[0]));
			map.Write(city.IPL[iide].InstObjects[ii].Location[1], sizeof(city.IPL[iide].InstObjects[ii].Location[1]));
			map.Write(city.IPL[iide].InstObjects[ii].Location[2], sizeof(city.IPL[iide].InstObjects[ii].Location[2]));

			map.Write(city.IPL[iide].InstObjects[ii].rx, sizeof(city.IPL[iide].InstObjects[ii].rx));
			map.Write(city.IPL[iide].InstObjects[ii].ry, sizeof(city.IPL[iide].InstObjects[ii].ry));
			map.Write(city.IPL[iide].InstObjects[ii].rz, sizeof(city.IPL[iide].InstObjects[ii].rz));
			map.Write(city.IPL[iide].InstObjects[ii].rw, sizeof(city.IPL[iide].InstObjects[ii].rw));

		end;


	  end;
  end;

  map.SaveToFile(working_gta_dir + '\gta_shapes\game.map');
  map.free;


  for iide := 0 to high(city.IDE) do
  begin
	if city.IDE[iide].Objects <> nil then
	  for ii := 0 to high(city.IDE[iide].Objects) do
	  begin
		i:= city.IDE[iide].Objects[ii].ID;

//	if (city.idetable.items[i] = nil) then
//		continue;

	fobj:= findIDE(i, true);

	if fobj = nil then continue;

	// vehicles are 400-611
	if ((i >= 400) and (i <= 611)) then begin

		if (fobj.Modelidx <> -1) and (fobj.modelinimg <> -1) then begin

			switch2img(fobj.modelinimg);

			filebuff      := Tmemorystream.Create;
			filebuff.size := IMGGetThisFile(fobj.Modelidx).sizeblocks * 2048;

			IMGExportBuffer(fobj.Modelidx, filebuff.Memory);

			dffloader:= TDffLoader.create;
			dffloader.filenint := GetTempDir + fobj.ModelName + '.dff';
			dffloader.LoadFromStream(filebuff);

			if dffloader <> nil then begin

				  if (length(dffloader.Clump) > 0) then begin

					if (dffloader.Clump[0].col3 <> nil) then begin

						coll:= TColObject.Create(self);
						dffloader.Clump[0].col3.Seek(0, soFromBeginning);

						if (coll.LoadFromStream(dffloader.Clump[0].col3) <> false) then
							coll2newton(inttostr(fobj.ID), coll)
						else
							Memo1.Lines.add('failed dff coll for: ' + fobj.modelname);

						coll.Free;

						continue;
					end;
				end;

			end;

			filebuff.Free;
			dffloader.Free;

		end;


	end;


	collindex:= loadcoll(fobj);

	if collindex <> -1 then
		coll2newton(inttostr(fobj.ID), TColObject(gtaobject.Components[collindex]));

	end;
	end;


	// TODO: shape for WATER.
	// TODO: export world data

end;

function TGtaEditor.loadcoll(fobj: Pobjs): integer;
var
	collindex: integer;
	filebuff: Tmemorystream;
	newcoll: TColObject;
begin

	collindex := IsCollLoaded(fobj.ModelName);

          if collindex = -1 then
          begin

            if city.idemapping[fobj.ID] <> nil then
            begin
              with city.idemapping[fobj.ID] as TIDEinforecord do
              begin

                if ((collectionfileindex <> -1) and (collectionfileindex <> -1)) then
                begin

									switch2img(imgindex);

                  //                  showmessage('DO WANT LOADED ' + collectionname);

                  filebuff := TMemoryStream.Create;

                  filebuff.size := IMGGetThisFile(collectionfileindex).sizeblocks * 2048;
                  IMGExportBuffer(collectionfileindex, filebuff.Memory);

                  while True = True do
                  begin
                    newcoll := TColObject.Create(GtaObject);

                    if newcoll.LoadFromStream(filebuff) = True then
                      newcoll.Name := lowercase(newcoll.Name)
                    else
                      break;

                  end;

                  filebuff.Free;

                end;
              end;

            end;

            // we loaded it.
			collindex := IsCollLoaded(fobj.ModelName);

		  end; // is coll loaded

	result:= collindex;

end;

procedure TGtaEditor.coll2newton(fname: string; coll: TColObject);
  var
	cachefile: Tmemorystream;
	pieces: array[0..255] of PNewtonCollision;
	compound_a: PNewtonCollision;
	trimesh: PNewtonCollision;
	usedpieces: integer;
	mkoffset: TMatrix4f;
	i: integer;
	blargh: array [0..2] of TVector3F;
  begin

	with coll do begin

	usedpieces:= 0;

	If not DirectoryExists(working_gta_dir + '\gta_shapes\') then
		MkDir(working_gta_dir + '\gta_shapes\');

	  for i := 0 to length(Box) - 1 do begin

		mkoffset := identity;

		mkoffset[3, 0] := box[i].min[0] + ((box[i].max[0] - box[i].min[0]) * 0.5);
		mkoffset[3, 1] := box[i].min[1] + ((box[i].max[1] - box[i].min[1]) * 0.5);
		mkoffset[3, 2] := box[i].min[2] + ((box[i].max[2] - box[i].min[2]) * 0.5);

		pieces[usedpieces]:= NewtonCreateBox(nworld, box[i].max[0] - box[i].min[0], box[i].max[1] - box[i].min[1], box[i].max[2] - box[i].min[2], 0, @mkoffset[0, 0]);
		Inc(usedpieces);

		//materialcolors[matmappers[box[i].surf.mat]]
		//box[i].min[0], box[i].min[1], box[i].min[2];

	  end;

	  for i := 0 to length(Sphere) - 1 do begin

		mkoffset := identity;
		mkoffset[3, 0] := Sphere[i].pos[0];
		mkoffset[3, 1] := Sphere[i].pos[1];
		mkoffset[3, 2] := Sphere[i].pos[2];

	   pieces[usedpieces]:= NewtonCreateSphere(nworld, Sphere[i].r, Sphere[i].r, Sphere[i].r, 0, @mkoffset[0, 0]);
	   Inc(usedpieces);

	  end;

	  if (usedpieces > 0) then begin
		compound_a:= NewtonCreateCompoundCollision(nworld, usedpieces, pieces[0], 0);

		cachefile := Tmemorystream.Create;
		NewtonCollisionSerialize(nworld, compound_a, cachewrite, cachefile);
		cachefile.SaveToFile(working_gta_dir + '\gta_shapes\' + fname + '.nsg');
		cachefile.Free;

	  end;

	  // serialize it
	  // gzip it

	  if (length(Face[0]) > 0) then begin

		trimesh:= NewtonCreateTreeCollision(nworld, 0);

		// start adding faces to the collision tree
		NewtonTreeCollisionBeginBuild(trimesh);

		  for i := 0 to length(Face[0]) - 1 do // 0 = model, 1 = shadow
		  begin

			//glcolor3ubv(@materialcolors[matmappers[face[k][i].surf.mat]]);

			blargh[0]:= Vertex[0][  Face[0][i].a  ].v;
			blargh[1]:= Vertex[0][  Face[0][i].b  ].v;
			blargh[2]:= Vertex[0][  Face[0][i].c  ].v;

			NewtonTreeCollisionAddFace(trimesh, 3, @blargh[0][0], 12, 0);

		  end;

		  NewtonTreeCollisionEndBuild(trimesh, 1);

		cachefile := Tmemorystream.Create;
		NewtonCollisionSerialize(nworld, trimesh, cachewrite, cachefile);
		cachefile.SaveToFile(working_gta_dir + '\gta_shapes\' + fname + '.nsm');
		cachefile.Free;


	  end;


	end;

end;

procedure TGtaEditor.btn_exportmapClick(Sender: TObject);
//var
//	iide, ii, i: integer;
//	map: tmemorystream;
begin

{
map:= TStringlist.create;

//	city.IPL[selipl].InstObjects[selitem]

  for iide := 0 to high(city.IPL) do
  begin
	  for ii := 0 to high(city.IPL[iide].InstObjects) do
	  begin


		i:= city.IPL[iide].InstObjects[ii].id;


		if ((FileExists(working_gta_dir + '\gta_shapes\' + inttostr(i) + '.nsm')) or (FileExists(working_gta_dir + '\gta_shapes\' + inttostr(i) + '.nsg'))) then begin


			map.Add(format('%d %0.5f %0.5f %0.5f %0.5f %0.5f %0.5f %0.5f ', [i, city.IPL[iide].InstObjects[ii].Location[0], city.IPL[iide].InstObjects[ii].Location[1], city.IPL[iide].InstObjects[ii].Location[2],
			city.IPL[iide].InstObjects[ii].rx,
			city.IPL[iide].InstObjects[ii].ry,
			city.IPL[iide].InstObjects[ii].rz,
			city.IPL[iide].InstObjects[ii].rw
			]))


		end;


	  end;
  end;

  map.SaveToFile(working_gta_dir + '\gta_shapes\' + inttostr(i) + '.mapt');
}
end;

procedure TGtaEditor.nudgepowerrotChange(Sender: TObject);
begin
nudgerotmp:= nudgepowerrot.position * (0.5 / 1500);
Label68.caption:= format('nudge power: %0.4f', [nudgemp]);
end;

end.

