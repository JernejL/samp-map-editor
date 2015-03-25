unit rwtxd;

interface

uses sysutils, dialogs, classes, opengl12, u_txdrecords;

const
  GL_RGBA4 = $8056;
  GL_RGB4  = $804F;

  // savage S3 texture compression
  GL_COMPRESSED_RGB_S3TC_DXT1_EXT  = $83F0;
  GL_COMPRESSED_RGBA_S3TC_DXT1_EXT = $83F1; // this one is rare, AVOID IT!
  GL_COMPRESSED_RGBA_S3TC_DXT3_EXT = $83F2;
  GL_COMPRESSED_RGBA_S3TC_DXT5_EXT = $83F3;

type

  Tnamedtexture = packed record
    gltex: gluint;
    Name:  array[0..31] of char;
  end;

  Ttxdloader = class
  public
    Texturecount: integer;
    is_loaded:    boolean;
    textures:     array of Tnamedtexture;
    procedure unload;
    procedure loadfromfile(filen: string);
    procedure loadfromstream(ms: Tmemorystream; filen: string);
    function findglid(Name: string): gluint;
  end;

implementation

{$IFDEF map_editor}
uses u_edit;
{$ENDIF}


{ Ttxdloader }

function Ttxdloader.findglid(Name: string): gluint;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to high(textures) do
  begin
    if lowercase(textures[i].Name) = lowercase(Name) then
    begin
      Result := textures[i].gltex;
      exit;
    end;
  end;

end;

procedure Ttxdloader.loadfromfile(filen: string);
var
  ms: Tmemorystream;
begin
  ms := Tmemorystream.Create;
  ms.LoadFromFile(filen);
  loadfromstream(ms, filen);
  ms.Free;
end;

procedure Ttxdloader.loadfromstream(ms: Tmemorystream; filen: string);
var
  header: TTXD_file_header;
  texheader: TTXD_image_header;
  texcount: byte;
  i, j: integer;
  imgptr: pointer;
  lw: longword;
begin

  is_loaded := False;

  ms.position := 24;
	ms.Read(texcount, 1);

	ms.position := sizeof(header);

	if (texcount > 200) then begin
		 showmessage(format('%s contains unusual number of textures: %d - please investigate.', [filen, texcount]));
	end;

//	if filen = 'balloon_texts.txd' then
//	ms.SaveToFile('c:\dmp.txd');
		//showmessage('balloon');

  setlength(textures, texcount);

  for i := 0 to texcount - 1 do
  begin

    ms.Read(texheader, sizeof(texheader) - 4);
    fillchar(textures[i].Name, sizeof(textures[i].Name), 0);
    //textures[i].Name:= lowercase(textures[i].Name);
    move(texheader.Name, textures[i].Name, sizeof(texheader.Name));

    //glGetError)

    glGenTextures(1, @textures[i].gltex);
    glBindTexture(GL_TEXTURE_2D, textures[i].gltex);

    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    if texheader.bitsperpixel = 0 then
      continue;
    //if texheader.bitsperpixel <> 16 then showmessage(inttostr(texheader.bitsperpixel));

    { txdversion: 9 bitsperpixel: 16 dxtcompression: 8 }
    // GL_BGRA_EXT, GL_BGR_EXT, GL_RGBA, GL_RGB

    if copy(texheader.alpha_used, 0, 3) = 'DXT' then
    begin
      for j := 0 to texheader.mipmaps - 1 do
      begin
        ms.Read(lw, sizeof(lw));

        if j = 0 then // read ONLY main image, ignore the mipmaps.
        begin
          imgptr := ms.Memory;
          imgptr := ptr(longword(imgptr) + ms.position);

          case texheader.alpha_used[3] of
            '1':
            begin
              if (texheader.alphaname <> '') then
                glCompressedTexImage2DARB(GL_TEXTURE_2D, j, GL_COMPRESSED_RGBA_S3TC_DXT1_EXT, texheader.Width, texheader.Height, 0, lw, imgptr)
              else
                glCompressedTexImage2DARB(GL_TEXTURE_2D, j, GL_COMPRESSED_RGB_S3TC_DXT1_EXT, texheader.Width, texheader.Height, 0, lw, imgptr);
            end;
            '3': glCompressedTexImage2DARB(GL_TEXTURE_2D, j, GL_COMPRESSED_RGBA_S3TC_DXT3_EXT, texheader.Width, texheader.Height, 0, lw, imgptr);
            else
            begin
              ShowMessage(texheader.alpha_used);
            end;
          end;

        end;

        ms.seek(lw, sofromcurrent);
      end; // 16 bit dxt
    end
    else
    begin

    	if texheader.mipmaps = 0 then texheader.mipmaps:= 1;

      if (texheader.bitsperpixel = 32) or (texheader.bitsperpixel = 24) then
        for j := 0 to texheader.mipmaps - 1 do
        begin
          ms.Read(lw, sizeof(lw));

          if j = 0 then // read ONLY main image, ignore the mipmaps.
          begin
            imgptr := ms.Memory;
            imgptr := ptr(longword(imgptr) + ms.position);

            if texheader.bitsperpixel = 32 then
              //if texheader.data_size > (texheader.width * texheader.height * 3) then
              glTexImage2D(GL_TEXTURE_2D, j, 4, texheader.Width, texheader.Height, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, imgptr)
            else
              glTexImage2D(GL_TEXTURE_2D, j, 3, texheader.Width, texheader.Height, 0, GL_BGR_EXT, GL_UNSIGNED_BYTE, imgptr);

          end;

          ms.seek(lw, sofromcurrent);
        end; // 32 / 24 bit dxt
    end;
  end;

  is_loaded := True;

end;

procedure Ttxdloader.unload;
var
  i: integer;
  texuint: array[0..255] of gluint;
begin

  for i := 0 to high(textures) do
  begin
    texuint[i] := textures[i].gltex;
  end;

  glDeleteTextures(high(textures), @texuint[0]);

  setlength(textures, 0);

end;

end.

