unit MapLoader;

// map loading functions for GTA Map Viewer
// © 2005 by Steve M.

interface

uses
  Windows,
  Misc,
  RequiredTypes,
  FileTypes,
  Geometry,
  OpenGL12
  //,sysutils
  ;

  function  CheckGameDir(AGameDir: string): boolean;
  function  LoadMapFiles(AGameDir: string): boolean;
  procedure UnloadMapFiles;
  function  LoadStreamFile(sf: PStreamFile; keep: boolean): boolean;
  procedure ProcessStreamFiles(def: PItemDefinition);

  function GetLastDef(def: PItemDefinition): PItemDefinition;
  function GetLastInst(inst: PItemInstance): PItemInstance;
  function FindDef(def: PItemDefinition; ID: cardinal): PItemDefinition; overload;
  function FindDef(def: PItemDefinition; name: string): PItemDefinition; overload;

var
  _h_Wnd: ^HWND;
  _h_DC: ^HGLRC;

  MapLoaded: boolean = false;
  GameType : TGameType;
  GameDir  : string;

  numDef, numUsedDef, numInst, numVisibleInst, numEnex, numFilesPerFrame: integer;

  ItemDefs    : PItemDefinition;
  ItemInsts,
  VisibleInsts,
  VisInst_a   : PItemInstance;
  EnexMarkers : PEnex;
  IMG         : TArchive;
  vehicle_txd : PStreamFile;

implementation

const
  SupportedGameTypes: set of TGameType = [GTA_3_PC, GTA_VC_PC, {GTA_SA_PS2,} GTA_SA_PC];
  delims: TCharSet = [' ', ',', #9];
  space_delim: char = ' ';
  comma_delim: char = ',';

var
  log: textfile;

function GetLastDef(def: PItemDefinition): PItemDefinition;
begin
  result:=def;
  if Assigned(result) then while Assigned(result.next) do result:=result.next;
end;

function GetLastInst(inst: PItemInstance): PItemInstance;
begin
  result:=inst;
  if Assigned(result) then while Assigned(result.next) do result:=result.next;
end;

function GetLastEnex(enex: PEnex): PEnex;
begin
  result:=enex;
  if Assigned(result) then while Assigned(result.next) do result:=result.next;
end;

function FindDef(def: PItemDefinition; ID: cardinal): PItemDefinition;
begin
  result:=nil;
  while Assigned(def) do begin
    if Def.ID=ID then begin
      result:=def;
      exit;
    end;
    def:=def.next;
  end;
end;

function FindDef(def: PItemDefinition; name: string): PItemDefinition;
begin
  result:=nil;
  while Assigned(def) do begin
    if EqualStr(Def.ModelName, Name) then begin
      result:=def;
      exit;
    end;
    def:=def.next;
  end;
end;


function CheckGameDir(AGameDir: string): boolean;
const sup: array[boolean] of string = ('Unsupported', 'Supported');
begin
  result:=false;
  if (AGameDir='') or not DirectoryExists(AGameDir) then exit;
  AGameDir:=IncludeTrailingBackslash(AGameDir);

  GameType:=GTA_NONE;
  GameDir:='';

  if (GameType=GTA_NONE)
  and FileExists(AGameDir+'system.cnf')
  and FileExists(AGameDir+'models\gta3.img')
  and FileExists(AGameDir+'data\gta3.dat')
  then GameType:=GTA_3_PS2;

  if (GameType=GTA_NONE)
  and FileExists(AGameDir+'gta3.exe')
  and FileExists(AGameDir+'models\gta3.img')
  and FileExists(AGameDir+'data\gta3.dat')
  then GameType:=GTA_3_PC;

  if (GameType=GTA_NONE)
  and FileExists(AGameDir+'system.cnf')
  and FileExists(AGameDir+'models\gta3.img')
  and FileExists(AGameDir+'data\gta_vc.dat')
  then GameType:=GTA_VC_PS2;

  if (GameType=GTA_NONE)
  and FileExists(AGameDir+'gta-vc.exe')
  and FileExists(AGameDir+'models\gta3.img')
  and FileExists(AGameDir+'data\gta_vc.dat')
  then GameType:=GTA_VC_PC;

  if (GameType=GTA_NONE)
  and FileExists(AGameDir+'system.cnf')
  and FileExists(AGameDir+'models\gta3.img')
  //and FileExists(AGameDir+'models\gta_int.img')
  and FileExists(AGameDir+'data\gta.dat')
  then GameType:=GTA_SA_PS2;

  if (GameType=GTA_NONE)
  and FileExists(AGameDir+'gta_sa.exe')
  and FileExists(AGameDir+'models\gta3.img')
  //and FileExists(AGameDir+'models\gta_int.img')
  and FileExists(AGameDir+'data\gta.dat')
  then GameType:=GTA_SA_PC;

  result:=GameType in SupportedGameTypes;
  OutputDebugString(PChar(sup[result]+': '+GameTypeString[GameType]));
  if result then begin
    GameDir:=AGameDir;
    ChDir(GameDir);
  end;
end;

procedure UnloadMapFiles;
var
  id, id_next: PItemDefinition;
  ii, ii_next: PItemInstance;
  enex, enex_next: PEnex;
begin
  MapLoaded:=false;

  VisibleInsts:=nil;
  numVisibleInst:=0;
  id:=ItemDefs;  ItemDefs:=nil;
  ii:=ItemInsts; ItemInsts:=nil;
  enex:=EnexMarkers; EnexMarkers:=nil;

  OutputDebugString('Unloading Map Files...');

  while Assigned(enex) do begin
    enex_next:=enex.next;
    Dispose(enex);
    dec(numEnex);
    enex:=enex_next;
  end;
  OutputDebugString(PChar(inttostr(numEnex)+' enex markers remaining'));

  while Assigned(ii) do begin
    ii_next:=ii.next;
    Dispose(ii);
    dec(numInst);
    ii:=ii_next;
  end;
  OutputDebugString(PChar(inttostr(numInst)+' item instances remaining'));

  while Assigned(id) do begin
    id_next:=id.next;
    Dispose(id);
    dec(numDef);
    id:=id_next;
  end;
  OutputDebugString(PChar(inttostr(numDef)+' item definitions remaining'));

  FreeAndNil(IMG);
end;


function GetMapName(path: string): string;
var a, b, i: integer;
begin
  a:=0; b:=0;
  for i:=1 to length(path) do begin
    if path[i]='\' then a:=i
    else if path[i]='.' then b:=i;
  end;
  result:=copy(path, a+1, b-a-1);
end;


procedure LoadBoundingObjects(var col: file; offset, size: Cardinal; def: PItemDefinition);
const
  COLL='COLL';
  COL2='COL2';
  COL3='COL3';
var
  p: PItemDefinition;
  fourcc: array[0..3] of char;
  header: record
    size: cardinal;
    name: array[0..19] of char;
    id: cardinal;
  end;
  pos: cardinal;
  Ver2: boolean;
begin
  if not Assigned(def) then exit;

  //offset:=FilePos(col);
  Seek(col, offset);

  while not eof(col) and (Cardinal(FilePos(col))<Offset+Size) do begin
    BlockRead(col, fourcc, 4);
    if (fourcc=COLL) or (fourcc=COL2) or (fourcc=COL3) then begin
      Ver2 := (fourcc=COL2) or (fourcc=COL3);
      pos:=FilePos(col)+4;
      BlockRead(col, header, 28);

      p:=FindDef(def, header.name);
      if Assigned(p) then begin
        if Ver2 then begin
          BlockRead(col, p.Box, 24);
          BlockRead(col, p.Sphere, 16);
        end else begin
          BlockRead(col, p.Sphere.r, 4);
          BlockRead(col, p.Sphere.p, 12);
          BlockRead(col, p.Box, 24);
        end;
        p.HasBounds:=true;
      end else OutputDebugString(PChar('> Collision Object '+header.name+' can''t find an item definition.'));

      Seek(col, pos+header.size);
    end else Seek(col, Offset+Size);
  end;
end;

procedure LoadCol(fname: string);
var col: file;
begin
  OutputDebugString(PChar('COL - '+fname));

  if Assigned(ItemDefs) then begin
    Assign(col, fname);
    Reset(col, 1);
    LoadBoundingObjects(col, 0, FileSize(col), ItemDefs);
    Close(col);
  end;
end;

procedure LoadIDE(fname: string);
const
  OBJS='OBJS';
  TOBJ='TOBJ';
  ANIM='ANIM';
  CARS='CARS';
  TXDP='TXDP';
var
  ide: textfile;
  obj, new_obj: PItemDefinition;
  id: cardinal;
  i, numDist: integer;
  s, sec: string;
  sf: PStreamFile;
  endsec: boolean;
begin
  OutputDebugString(PChar('IDE - '+fname));

  obj:=GetLastDef(ItemDefs);

  Assign(ide, fname);
  Reset(ide);

  repeat
    repeat
      readln(ide, sec);
      sec:=trim(sec, true);
    until eof(ide) or (sec=OBJS) or (sec=TOBJ) or (sec=ANIM) or (sec=CARS) or (sec=TXDP);
    if not eof(ide) then repeat
      readln(ide, s);
      endsec:=EqualStr(s, 'end');
      if endsec then break;

      if (sec=OBJS) or (sec=TOBJ) or (sec=ANIM) then begin

        id:=StrToIntDef(ParseStr(comma_delim, s), 0);
        if id>0 then begin
          new(new_obj);
          ZeroMemory(new_obj, sizeof(TItemDefinition));
          
          new_obj.ID:=id;
          new_obj.ObjType:=otStatic;

          new_obj.ModelName   := ParseStr(comma_delim, s); // dff name
          new_obj.TexDictName := ParseStr(comma_delim, s); // txd name
          if (sec=ANIM) then
            new_obj.AnimName  := ParseStr(comma_delim, s); // ifp name

          new_obj.isLOD := (GameType<GTA_SA_PS2) and (( Pos2('LOD', new_obj.ModelName)=1 ) or ( Pos2('IslandLOD', new_obj.ModelName)=1 ));

          {if not OPT.QuickLoad then begin
            new_obj.Model:=IMG.Find(new_obj.ModelName+'.dff', feDFF);
            new_obj.TexDict:=IMG.Find(new_obj.TexDictName+'.txd', feTXD);
            if (sec=ANIM) then new_obj.Anim:=IMG.Find(new_obj.AnimName+'.ifp', feIFP);
            new_obj.isChecked:=true;
          end;}

          if GameType<GTA_SA_PS2 then begin
            numDist:=StrToIntDef(ParseStr(comma_delim, s), 1);
            for i:=2 to numDist do ParseStr(comma_delim, s);
          end;
          new_obj.Dist:=StrToIntDef(ParseStr(comma_delim, s), 150);
          new_obj.Flags:=StrToIntDef(ParseStr(comma_delim, s), 0);

          if (sec=TOBJ) then begin
            new_obj.t_on:=StrToIntDef(ParseStr(comma_delim, s), 0);
            new_obj.t_off:=StrToIntDef(ParseStr(comma_delim, s), 24);
            new_obj.timed:=true;
          end else
            new_obj.timed:=false;

          if Assigned(obj) then obj.next:=new_obj else ItemDefs:=new_obj;
          obj:=new_obj;
          inc(numDef);
        end;

      end else if (sec=CARS) and Opt.VehicleTest then begin

        id:=StrToIntDef(ParseStr(comma_delim, s), 0);
        if id>0 then begin
          new(new_obj);
          ZeroMemory(new_obj, sizeof(TItemDefinition));
          
          new_obj.ID:=id;
          new_obj.ObjType:=otCar;

          // space/tab must be delimiter too, at least for SA 
          new_obj.ModelName   := ParseStr(delims, s); // dff name
          new_obj.TexDictName := ParseStr(delims, s); // txd name

          // find files right now
          new_obj.Model:=IMG.Find(new_obj.ModelName+'.dff', feDFF);
          if Assigned(new_obj.Model) then
            new_obj.Model.isSpecial:=true // used to identify it as car
          else
            OutputDebugString(PChar('DFF NOT FOUND: '+new_obj.ModelName+' (#'+inttostr(new_obj.ID)+')'));
          new_obj.TexDict:=IMG.Find(new_obj.TexDictName+'.txd', feTXD);
          if Assigned(new_obj.TexDict) then
            new_obj.TexDict.Parent:=vehicle_txd
          else
            OutputDebugString(PChar('TXD NOT FOUND: '+new_obj.TexDictName+' (#'+inttostr(new_obj.ID)+')'));
          new_obj.isChecked:=true;

          new_obj.Dist:=300;
          //new_obj.Flags:=0;

          if GameType>=GTA_SA_PS2 then begin
            new_obj.HasBounds:=true;
            new_obj.Sphere.r:=3;
          end;

          if Assigned(obj) then obj.next:=new_obj else ItemDefs:=new_obj;
          obj:=new_obj;
          inc(numDef);
        end;

      end else if (sec=TXDP) then begin

        sf := IMG.Find(ParseStr(comma_delim, s)+'.txd', feTXD);
        if Assigned(sf) then begin
          sf.Parent := IMG.Find(ParseStr(comma_delim, s)+'.txd', feTXD);
          LoadStreamFile(sf.Parent, true);
          //if OPT.Verbose and Assigned(sf.Parent) and sf.Parent.isLoaded then OutputDebugString(PChar('> '+sf.Parent.Name+' loaded as parent of '+sf.Name));
        end;

      end;

    until eof(ide) or endsec;
  until eof(ide);

  Close(ide);
end;

procedure LoadBinIPL(var ipl: file; offset, size: Cardinal);
const
  BNRY='bnry';
var
  obj, new_obj: PItemInstance;
  def: PItemDefinition;
  fourcc: array[0..3] of char;
  header: record
    count: array[0..5] of integer;
    sec: array[0..5] of record
      offset, unk: integer;
    end;
  end;
  instrec: record
    pos: TVector3F;
    rot: TQuaternion;
    ID, Interior, Flags: integer;
  end;
  carrec: record
    pos: TVector3F;
    rot: single;
    ID: integer;
    unk: array[0..6] of integer;
  end;
  i: integer;
begin
  //bin ipl files: pos (x, y, z); quat (x, y, z, w); ObjectID; InteriorID; Flags

  Seek(ipl, offset);
  BlockRead(ipl, fourcc, 4);

  if (size<116) or (fourcc<>BNRY) then
    OutputDebugString('ERROR - invalid binary ipl file')
  else begin
    BlockRead(ipl, header, 72);

    with header do if (count[1]>0) or (count[2]>0) or (count[3]>0) or (count[5]>0) then OutputDebugString('> Unknown section found!');

    obj:=GetLastInst(ItemInsts);

    // read item instances
    seek(ipl, offset+header.sec[0].offset);
    for i:=1 to header.count[0] do begin
      BlockRead(ipl, instrec, 40);

      def:=FindDef(ItemDefs, instrec.ID);
      if Assigned(def) then begin
        new(new_obj);
        ZeroMemory(new_obj, sizeof(TItemInstance));

        new_obj.def:=def;
        new_obj.Interior:=instrec.Interior;
        new_obj.Pos:=instrec.pos;
        QuatToAxisRot(instrec.rot, new_obj.RotAngle, new_Obj.RotAxis);
        new_obj.Flags:=instrec.Flags;

        if Assigned(obj) then obj.next:=new_obj else ItemInsts:=new_obj;
        obj:=new_obj;
        inc(numInst);

        //writeln(log, instrec.ID, ', ', def.modelname, ', ', instrec.Interior, ', ', instrec.Pos[0]:1:3, ', ', instrec.Pos[1]:1:3, ', ', instrec.Pos[2]:1:3, ', ', instrec.rot.vector[0]:1:3, ', ', instrec.rot.vector[1]:1:3, ', ', instrec.rot.vector[2]:1:3, ', ', instrec.rot.vector[3]:1:3, ', ', instrec.Flags);
      end else
        if opt.Verbose then OutputDebugString(PChar('> Undefined ID: #'+inttostr(instrec.ID)));

    end;

    // read car instances
    seek(ipl, offset+header.sec[4].offset);
    if Opt.VehicleTest then for i:=1 to header.count[4] do begin
      BlockRead(ipl, carrec, 48);

      if carrec.ID<400 then continue;

      def:=FindDef(ItemDefs, carrec.ID);
      if Assigned(def) then begin
        new(new_obj);
        ZeroMemory(new_obj, sizeof(TItemInstance));

        new_obj.def:=def;
        new_obj.Flags:=-1;
        new_obj.Pos:=carrec.pos;
        new_obj.Pos[2]:=new_obj.Pos[2]+1;
        //new_obj.RotAxis[2]:=1;
        //new_obj.RotAngle:=carrec.rot;

        if Assigned(obj) then obj.next:=new_obj else ItemInsts:=new_obj;
        obj:=new_obj;
        inc(numInst);
      end else
        if opt.Verbose then OutputDebugString(PChar('> Undefined Car ID: #'+inttostr(carrec.ID)));

    end;

  end;

end;

procedure LoadIPL(fname: string);
const
  INST='INST';
  ENEX='ENEX';
var
  ipl: textfile;
  obj, obj2, new_obj, first_obj: PItemInstance;
  new_enex, last_enex: PEnex;
  def: PItemDefinition;
  sf: PStreamFile;
  i, i2, numw: integer;
  id: cardinal;
  quat: TQuaternion;
  s, sec, name: string;
  endsec: boolean;
begin
  OutputDebugString(PChar('IPL - '+fname));

  obj:=GetLastInst(ItemInsts);
  last_enex:=GetLastEnex(EnexMarkers);
  first_obj:=nil;

  Assign(ipl, fname);
  Reset(ipl);

  repeat
    repeat
      readln(ipl, sec);
      sec:=trim(sec, true);
    until eof(ipl) or (sec=INST) or (sec=ENEX);
    if not eof(ipl) then repeat
      readln(ipl, s);
      endsec:=EqualStr(s, 'end');
      if endsec then break;

      if (sec=INST) then begin

        id:=StrToIntDef(ParseStr(comma_delim, s), 0);
        if id>0 then begin
          def:=FindDef(ItemDefs, ID);
          if Assigned(def) then begin
            new(new_obj);
            ZeroMemory(new_obj, sizeof(TItemInstance));

            new_obj.def:=def;

            numw:=CountWords(s)+1; // number of parameters, some are optional

            ParseStr(comma_delim, s); // dff name

            if ((GameType in [GTA_VC_PS2, GTA_VC_PC]) and (numw=13))
            or ((GameType in [GTA_SA_PS2, GTA_SA_PC]) )//and (numw in [11, 14]))
            then
              new_obj.Interior:=StrToIntDef(ParseStr(comma_delim, s), 0); // interior

            new_obj.Pos[0]:=StrToFloatDef(ParseStr(comma_delim, s), 0); // position
            new_obj.Pos[1]:=StrToFloatDef(ParseStr(comma_delim, s), 0);
            new_obj.Pos[2]:=StrToFloatDef(ParseStr(comma_delim, s), 0);

            if (GameType<GTA_SA_PS2) or (numw>11) then
              for i:=0 to 2 do ParseStr(comma_delim, s); // unused scale

            Quat.Vector[0]:=StrToFloatDef(ParseStr(comma_delim, s), 0); // rotation quaternion
            Quat.Vector[1]:=StrToFloatDef(ParseStr(comma_delim, s), 0);
            Quat.Vector[2]:=StrToFloatDef(ParseStr(comma_delim, s), 0);
            Quat.Vector[3]:=StrToFloatDef(ParseStr(comma_delim, s), 1);

            //OutputDebugString(PChar(new_obj.def.Name+' - '+floattostr(Quat.Vector[0], 3)+', '+floattostr(Quat.Vector[1], 3)+', '+floattostr(Quat.Vector[2], 3)+', '+floattostr(Quat.Vector[3], 3)));

            //new_obj.Mat:=QuatToMat(quat);
            //MatrixTranspose(new_obj.mat);
            //Move(new_obj.Pos, new_obj.Mat[3], 12);
            QuatToAxisRot(quat, new_obj.RotAngle, new_Obj.RotAxis);

            if GameType>=GTA_SA_PS2 then
              new_obj.Flags:=StrToIntDef(ParseStr(comma_delim, s), -1) // parent LOD
            else
              new_obj.Flags:=-1;


            if Assigned(obj) then obj.next:=new_obj else ItemInsts:=new_obj;
            if not Assigned(first_obj) then first_obj:=new_obj;
            obj:=new_obj;
            inc(numInst);
          end else if opt.Verbose then begin
            name:=ParseStr(comma_delim, s); // dff name
            OutputDebugString(PChar('> Undefined ID: #'+inttostr(id)+' - '+name));
          end;
        end;

      end else if (sec=ENEX) then begin
        new(new_enex);
        ZeroMemory(new_enex, sizeof(TEnex));

        // entrance position
        new_enex.Entrance[0] := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.Entrance[1] := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.Entrance[2] := StrToFloatDef(ParseStr(comma_delim, s), 0);

        // parameters
        new_enex.Rotation := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.OffsetX := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.OffsetY := StrToFloatDef(ParseStr(comma_delim, s), 0);

        // const 8
        new_enex.Eight := StrToIntDef(ParseStr(comma_delim, s), 8);

        // target position
        new_enex.Target[0] := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.Target[1] := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.Target[2] := StrToFloatDef(ParseStr(comma_delim, s), 0);

        // flags and settings
        new_enex.UnkF := StrToFloatDef(ParseStr(comma_delim, s), 0);
        new_enex.Interior := StrToIntDef(ParseStr(comma_delim, s), 0);
        new_enex.Flag1 := StrToIntDef(ParseStr(comma_delim, s), 4);
        new_enex.Name := ParseStr(comma_delim, s);
        new_enex.Flag2 := StrToIntDef(ParseStr(comma_delim, s), 0);
        new_enex.Flag3 := StrToIntDef(ParseStr(comma_delim, s), 2);

        // time
        new_enex.t_on := StrToIntDef(ParseStr(comma_delim, s), 0);
        new_enex.t_off := StrToIntDef(ParseStr(comma_delim, s), 24);

        if Assigned(last_enex) then last_enex.next:=new_enex else EnexMarkers:=new_enex;
        last_enex:=new_enex;
        inc(numEnex);
      end;

    until eof(ipl) or endsec;
  until eof(ipl);

  Close(ipl);

  // load accompanying binary IPLs
  name:=GetMapName(fname)+'_stream';
  sf:=IMG.Entries[feIPL];
  while Assigned(sf) do begin
    if EqualStr(copy(sf.Name, 0, length(name)), name) then begin
      OutputDebugString(PChar('IPL - '+sf.Name));
      LoadBinIPL(sf.Archive.f, sf.Offset, sf.Size);
      sf.isSpecial:=true;
    end;
    sf:=sf.Next;
  end;

  // assign LOD hierarchies for this IPL
  obj:=first_obj;
  i:=0;
  while Assigned(obj) do begin
    if obj.Flags>-1 then begin
      if obj.Flags>i then begin
        i2:=i+1;
        obj.ParentLOD:=obj.next;
      end else begin
        i2:=0;
        obj.ParentLOD:=first_obj;
      end;
      while Assigned(obj.ParentLOD) and (i2<obj.Flags) do begin
        obj.ParentLOD:=obj.ParentLOD.next;
        inc(i2);
      end;
      if Assigned(obj.ParentLOD) then
        obj.ParentLOD.def.isLOD:=true
      else
        OutputDebugString(PChar('> Parent LOD for #'+inttostr(obj.def.ID)+' '+obj.def.modelname+' not found.'));
    end;
    obj:=obj.next;
    inc(i);
  end;
end;

procedure LoadDat(datname: string);
var
  dat: textfile;
  s, fname: string;
begin
  OutputDebugString(PChar('DAT - '+datname));
  Assign(dat, datname);
  Reset(dat);
  while not eof(dat) do begin
    {readln(dat, s);
    i:=pos2(' ', s);
    fname:=copy(s, i+1, length(s)-i);
    s:=copy(s, 0, i-1);}
    readln(dat, fname);
    s:=ParseStr(delims, fname);

    SetWindowText(_h_Wnd^, PChar('Loading Map Files... ['+floattostr(filepos(dat)*100/filesize(dat))+'%] - '+fname));

    if EqualStr(s, 'IMG') and
       EqualStr(extractfileext(fname), '.img') and
       FileExists(fname)
    then IMG.AttachArchive(fname) else

    if EqualStr(s, 'IDE') and
       ( (Opt.MapFilter='') or (Pos2(Opt.MapFilter, fname)>0) ) and
       EqualStr(extractfileext(fname), '.ide') and
       FileExists(fname)
    then LoadIDE(fname) else

    if EqualStr(s, 'COLFILE') and
       ( (Opt.MapFilter='') or (Pos2(Opt.MapFilter, fname)>0) )
    then begin
      ParseStr(delims, fname); // zone
      if EqualStr(extractfileext(fname), '.col') and
         FileExists(fname)
      then LoadCOL(fname);
    end else

    if EqualStr(s, 'IPL') and
       ( (Opt.MapFilter='') or (Pos2(Opt.MapFilter, fname)>0) ) and
       //EqualStr(extractfileext(fname), '.ipl') and
       FileExists(fname)
    then LoadIPL(fname);

    if (EqualStr(s, 'TEXDICTION') or EqualStr(s, 'MODELFILE')) and
       FileExists(fname)
    then IMG.AddExternal(fname);
  end;
  Close(dat);
end;

function LoadMapFiles(AGameDir: string): boolean;
var
  s: string;
  sf: PStreamFile;
  //id: PItemDefinition;
  t0: cardinal;
begin
  result:=false;

  if MapLoaded then UnloadMapFiles;

  ItemDefs :=nil;
  ItemInsts:=nil;
  VisibleInsts:=nil;
  numDef:=0;
  numInst:=0;
  numVisibleInst:=0;

  if not CheckGameDir(AGameDir) then exit;

  OutputDebugString('Loading Map Files...');
  t0:=GetTickCount;

  try

    // load img archive
    IMG:=TArchive.Create('models\gta3.img');
    if not Assigned(img) then exit;
    if FileExists('models\gta_int.img') then IMG.AttachArchive('models\gta_int.img');
    vehicle_txd:=IMG.AddExternal('models\generic\vehicle.txd');

    // load .dat files and content
    LoadDat('data\default.dat');
    case GameType of
      GTA_3_PC  : LoadDat('data\gta3.dat');
      GTA_VC_PC : LoadDat('data\gta_vc.dat');
      GTA_SA_PS2,
      GTA_SA_PC : LoadDat('data\gta.dat');
    else
      exit;
    end;

    // Load IPLs in IMG
    s:='Loading Remaining Binary IPL Files...';
    OutputDebugString(PChar(s));
    SetWindowText(_h_Wnd^, PChar(s));
    //Assign(log, 'binipl.txt'); rewrite(log); writeln(log, '# printout of binary ipl files in GTA SA'#13#10#13#10'inst');
    sf:=IMG.Entries[feIPL];
    while Assigned(sf) do begin
      if not sf.isSpecial and ((Opt.MapFilter='') or (Pos2(Opt.MapFilter, sf.Name)>0)) then begin
        OutputDebugString(PChar('IPL - '+sf.Name));
        //writeln(log, #13#10'# '+sf.Name);
        LoadBinIPL(sf.Archive.f, sf.Offset, sf.Size);
      end;
      sf:=sf.Next;
    end;
    //writeln(log, 'end'); close(log);

    // Load COLs in IMG
    s:='Loading Collision Files...';
    OutputDebugString(PChar(s));
    SetWindowText(_h_Wnd^, PChar(s));
    sf:=IMG.Entries[feCOL];
    while Assigned(sf) do begin
      if (Opt.MapFilter='') or (Pos2(Opt.MapFilter, sf.Name)>0) then begin
        OutputDebugString(PChar('COL - '+sf.Name));
        LoadBoundingObjects(sf.Archive.f, sf.Offset, sf.Size, ItemDefs);
      end;
      sf:=sf.Next;
    end;

    (*id:=ItemDefs;
    while Assigned(id) do begin
      if not id.HasBounds {and (pos2('lod', id.Name)=0)} then OutputDebugString(PChar('Without col: #'+inttostr(id.ID)+' - '+id.ModelName));
      id:=id.next;
    end;*)


    result:=true;

    s:='Map Files loaded in '+FloatToStr((GetTickCount-t0)/1000, 2)+' sec';
    SetWindowText(_h_Wnd^, PChar(s));
    OutputDebugString(PChar(s));

    if GameType=GTA_SA_PS2 then begin
      glEnable(GL_CULL_FACE);
      glDisable(GL_LIGHTING);
      glDisable(GL_BLEND);
    end else begin
      glEnable(GL_CULL_FACE);
      glEnable(GL_LIGHTING);
      glDisable(GL_BLEND);
    end;
    glEnable(GL_TEXTURE_2D);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    EngineTime.GameTime:=12*60; // 12:00 am

  finally
    if result then
      MapLoaded:=true
    else
      UnloadMapFiles;
  end;
end;

function LoadStreamFile(sf: PStreamFile; keep: boolean): boolean;
begin
  result:=false;
  if not Assigned(sf) or sf.isFaulty or sf.isLoaded then exit;

  with sf^ do try
    if Opt.Verbose then OutputDebugString(PChar('+ '+Name));
    case ext of
      feDFF: data:=TDFFClump.Create;
      feTXD: data:=TTexDict.Create;
      //feIFP: data:=TIFPAnim.Create;
    end;
    result:=data.LoadFromStream(Archive.f, Offset, Size, sf.isSpecial);
  finally
    if result then begin
      isLoaded:=true;
      KeepInMem:=keep;
      inc(IMG.numLoadedStreamFiles);
    end else begin
      isFaulty:=true;
      FreeAndNil(data);
      OutputDebugString(PChar('Can''t load "'+Name+'" due to errors!'));
    end;
  end;
end;

procedure ProcessStreamFiles(def: PItemDefinition);
var
  FilesLoaded: boolean;
  i: integer;
  sf: PStreamFile;
begin
  if not Assigned(def) then exit;

  if def.isUsed and not def.isChecked and (numFilesPerFrame<Opt.MaxFilesPerFrame) then begin
    // find needed files in the archive on first use
    def.Model:=IMG.Find(def.ModelName+'.dff', feDFF);
    if not Assigned(def.Model) then OutputDebugString(PChar('DFF NOT FOUND: '+def.ModelName+' (#'+inttostr(def.ID)+')'));
    def.TexDict:=IMG.Find(def.TexDictName+'.txd', feTXD);
    if not Assigned(def.TexDict) then OutputDebugString(PChar('TXD NOT FOUND: '+def.TexDictName+' (#'+inttostr(def.ID)+')'));
    {if def.AnimName<>'' then begin
      def.Anim:=IMG.Find(def.AnimName+'.ifp', feIFP);
      if not Assigned(def.Anim) then OutputDebugString(PChar('IFP NOT FOUND: '+def.AnimName+' (#'+inttostr(def.ID)+')'));
    end;}
    def.isChecked:=true;
  end;

  //if def.Timed and not CheckGameTime(def.t_on, def.t_off) then def.isUsed:=false;
  if def.isUsed then inc(numUsedDef);

  FilesLoaded:=false;

  for i:=0 to 2 do begin
    case i of
      // dff must be loaded last
      0: sf:=def.TexDict; // txd
      //1: sf:=def.Anim; // ifp
      2: sf:=def.Model; // dff
    else
      sf:=nil;
    end;

    if Assigned(sf) then with sf^ do begin

      if def.isUsed then isNeeded:=true;

      if isNeeded then begin
        // file is needed and must be made available

        LastRequest:=EngineTime.CurrentTicks;

        if (numFilesPerFrame<Opt.MaxFilesPerFrame)
        and LoadStreamFile(sf, false) then begin
          if ext=feDFF then with (data as TDFFClump) do begin
            AttachTXD(def.TexDict, def.HasAlpha);
            //AttachIFP(def.AnimName);
          end;
          FilesLoaded:=true;
        end;

      end else if isLoaded and not KeepInMem and (LastRequest+Opt.StreamWaitTime<EngineTime.CurrentTicks) then begin
        // file isn't needed anymore and can be removed from memory

        if Opt.Verbose then OutputDebugString(PChar('- '+Name));
        isLoaded:=false;
        FreeAndNil(data);
        dec(IMG.numLoadedStreamFiles);

      end;

    end; //if, with
  end; //for

  if FilesLoaded then inc(numFilesPerFrame);
end;

end.
