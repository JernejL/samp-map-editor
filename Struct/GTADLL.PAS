unit gtadll;

interface

const
  gtainterface = 'gtainterface.dll';

// IMG utils

type
  Tdirentry = packed record
  startblock: Longword;
  sizeblocks: Longword;
  Name: array[0..23] of char; // null terminated, there is possible garbage after the null terminator
  end; // 32 bytes

Tdefragcallbackproc = procedure(const txt: pchar); stdcall;

function  IMGLoadImg(const filename: pchar): integer; stdcall; external gtainterface; // loads a img file, must be called before anything else

function IMGISV2: boolean; stdcall; external gtainterface; // tells you the img format version.

procedure IMGReDoDir; stdcall; external gtainterface; // recreates the img directory, neccesary by some functions

procedure IMGDelete(const index: integer); stdcall; external gtainterface; // removes the file from the directory and updates the directory
procedure IMGRemoveFile(const index: integer); stdcall; external gtainterface; // use if you have to remove several files at once, after you are done you must call IMGReDoDir otherwise img's directory is not updated.
procedure IMGReplaceFile(const index: integer; const filen: pchar; ForceToEnd: boolean); stdcall; external gtainterface; // replaces file with another bigger or smaller file, bigger files will be written at the end of img but the directory will stay on same place
Procedure IMGAddFile(const filename: pchar); stdcall; external gtainterface;
procedure IMGExportFile(const index: integer; const filen: pchar); stdcall; external gtainterface; // exports a file to disk
procedure IMGExportBuffer(const index: integer; buffer: pointer); stdcall; external gtainterface; // exports a file to buffer

// returns img directory file count
function  IMGFileCount: integer; stdcall; external gtainterface;

function IMGGetFileName(const index: integer): pchar; stdcall; external gtainterface;

// retrieves / sets the file dir record for any file, use this to list / rename files in your apps.
function  IMGGetThisFile(const index: integer): Tdirentry; stdcall; external gtainterface;
procedure IMGSetThisFile(const index: integer; const dir: Tdirentry); stdcall; external gtainterface; // after you call this

// writes / read data ftom / to img file at any file offset, application is responsible for alocating buffer memory
// the dll will only read it, you can also write beyond file end
procedure IMGReadBuffer(buffer: pchar; buffsize, fileofs: longword); stdcall; external gtainterface;
procedure IMGWriteBuffer(buffer: pchar; buffsize, fileofs: longword); stdcall; external gtainterface;

// fragmenter / defragmenter functions
function IMGHowMuchFragmented: integer; stdcall; external gtainterface;

procedure IMGDefrag(callback: Tdefragcallbackproc); stdcall; external gtainterface;

// IDE utils

// RWstrean utils

// TXD utils

implementation

end.