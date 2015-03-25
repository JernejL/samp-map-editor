unit TextureStuff;

// misc texture conversion functions for GTA Map Viewer
// © 2005 by Steve M.

interface

procedure SwapRGBA(data: Pointer; Size: Integer);
procedure Image8to32(var Data: Pointer; Palette: Pointer; var Size: cardinal);
procedure SwizzledImage4to32(var Data: Pointer; Palette: Pointer; width, height: integer; var Size: cardinal);
procedure SwizzledImage8to32(var Data: Pointer; Palette: Pointer; width, height: integer; var Size: cardinal);
procedure WriteTGA(const name: string; Data: Pointer; width, height: integer);


implementation

procedure SwapRGBA(data: Pointer; Size: Integer);
// Swap image format from BGRA to RGBA
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,4
  dec ecx
  jnz @@loop
end;

procedure Image8to32(var Data: Pointer; Palette: Pointer; var Size: cardinal);
// Convert 8bit paletted image to 32bit
var
  img, img_p, data_p: Pointer;
  i: integer;
begin
  GetMem(img, Size*4);
  img_p:=img;
  data_p:=data;
  for i:=0 to Size-1 do begin
    PCardinal(img_p)^:=PCardinal(Cardinal(Palette)+PByte(data_p)^*4)^;
    inc(Cardinal(data_p));
    inc(Cardinal(img_p), 4);
  end;
  FreeMem(Data, Size);
  Data:=img;
  Size:=Size*4;
end;

// --- PS2 swizzled textures ---

function PixelToIndex(src: Pointer; w, h, x, y: Cardinal; is4bit: boolean): byte; //inline;
var
  i, block, swap, yy, column, octet, nybble: cardinal;
begin
	block := (y and (not 15)) * w + (x and (not 15)) * 2;
	swap := (((y + 2) shr 2) and 1) * 4;
	yy := (((y and (not 3)) shr 1) + (y and 1)) and 7;
	column := yy * w * 2 + ((x + swap) and 7) * 4;

	octet := (x shr 2) and 2;
	nybble := (y shr 1) and 1;

  if is4bit then begin
    i := PCardinal(Cardinal(src) + (block + column + octet) shr 1)^ shr (nybble shl 2);
    result := byte(i and 15);
  end else begin
    i := PCardinal(Cardinal(src) + block + column + octet + nybble)^;
    result := byte(i);
  end;
end;

procedure SwizzledImage4to32(var Data: Pointer; Palette: Pointer; width, height: integer; var Size: cardinal);
var
  img, img_p, data_p: Pointer;
  x, y: integer;
  i: cardinal;
begin
  GetMem(img, Size*8);
  img_p:=img;
  data_p:=data;

  for y:=0 to height-1 do
    for x:=0 to width-1 do begin
      i := 4 * PixelToIndex(data_p, width, height, x, y, true);
      PCardinal(img_p)^ := PCardinal(Cardinal(Palette) + i+0)^;
      inc(Cardinal(img_p), 3);
      {PByte(img_p)^ := PByte(Cardinal(Palette) + i+2)^; inc(Cardinal(img_p));
      PByte(img_p)^ := PByte(Cardinal(Palette) + i+1)^; inc(Cardinal(img_p));
      PByte(img_p)^ := PByte(Cardinal(Palette) + i+0)^; inc(Cardinal(img_p));}
      PByte(img_p)^ := PByte(Cardinal(Palette) + i+3)^ shl 1 - 1; inc(Cardinal(img_p));
    end;

  FreeMem(Data, Size);
  Data:=img;
  Size:=Size*8;
end;

procedure SwizzledImage8to32(var Data: Pointer; Palette: Pointer; width, height: integer; var Size: cardinal);

  function SwitchIndex(i: byte): byte;
  const map: array[0..3] of byte = (0, 16, 8, 24);
  begin
    result := (i and not 24) or map[(i and 24) shr 3];
  end;

var
  img, img_p, data_p: Pointer;
  x, y: integer;
  i: cardinal;
begin
  GetMem(img, Size*4);
  img_p:=img;
  data_p:=data;

  for y:=0 to height-1 do
    for x:=0 to width-1 do begin
      i := 4 * SwitchIndex(PixelToIndex(data_p, width, height, x, y, false));
      PCardinal(img_p)^ := PCardinal(Cardinal(Palette) + i+0)^;
      inc(Cardinal(img_p), 3);
      {PByte(img_p)^ := PByte(Cardinal(Palette) + i+2)^; inc(Cardinal(img_p));
      PByte(img_p)^ := PByte(Cardinal(Palette) + i+1)^; inc(Cardinal(img_p));
      PByte(img_p)^ := PByte(Cardinal(Palette) + i+0)^; inc(Cardinal(img_p));}
      PByte(img_p)^ := PByte(Cardinal(Palette) + i+3)^ shl 1 - 1; inc(Cardinal(img_p));
    end;

  FreeMem(Data, Size);
  Data:=img;
  Size:=Size*4;
end;


// --- output .tga ---
procedure WriteTGA(const name: string; Data: Pointer; width, height: integer);
var
  f: file;
begin
  Assign(f, name+'.tga');
  Rewrite(f, 1);

  blockwrite(f, #00#00#02#00#00#00#00#00#00#00#00#00, 12);
  blockwrite(f, width, 2);
  blockwrite(f, height, 2);
  blockwrite(f, #32#40, 2);

  blockwrite(f, data^, width*height*4);

  Close(f);
end;

end.
