{

special: Longword;               // 4354= 16bit <- SET IF XBOX
                                 // 4358= 8bpp
                                 // 4353= 32bpp               *
                                 // 4353= DXT3
                                 // 4353= DXT1
                                 // 4354= NONRECOMPRESIBLE DXT - hud and such images.

}

unit u_txdrecords;

interface

type

TTXD_file_header = packed record
filetype: Longword; // 22 - txd
size: Longword;     // filesize - 12
gametype: Longword; // 134283263 = GTA3,
                    // 67239935 = gta3 frontend
                    // 268697599 = GTAVC
                    // 201523199 = gtavc frontend
                    // 335609855 = xbox vc
split: Longword;    // 1
end;                // 16

TTXD_image_header = packed record // 124 bytes
// txd image info header
RwTxdExt: Longword;              // 4 = extension
RWVersion: Longword;             // Renderware version number
texturecount: word;              // texture count if this is the first image!
                                 // otherwise Renderware version number
dummy: word;                     // part 2 of renderware version

TextureNative: Longword;         // 21

SizeOfTextureNative: Longword;   // size of data + 116
RWVersiona: Longword;            // Renderware version number

TxdStruct: Longword;             // always 1, what could it be...
SizeOfTxdStruct: Longword;       // size of data + 92

RWVersionb: Longword;            // Renderware version number
TXDVersion: Longword;            // 8 for vice city pc, 5 for vicecity XBOX, 9 for san andreas pc

FilterFlags: Longword;           // 4354= 16bit <- ALWAYS IF XBOX
                                 // 4358= 8bpp
                                 // 4354= 32bpp
                                 // 4358= DXT3
                                 // 0000= DXT1
                                 // 4354= NONRECOMPRESIBLE DXT - hud and such images.


Name:      array[0..31] of char; // name for image, null terminated
alphaname: array[0..31] of char; // name for alpha / mask, null terminated, format 9 stores something else here


image_flags: Longword;           // alpha flags
                                 // 512 = 16bpp no alpha
                                 // 768 = 16bpp with alpha

                                 // 9728= 8bpp no alpha
                                 // 9472= 8bpp with alpha

                                 // 1536= 32bpp no alpha   < -+- SET IF ANY XBOX
                                 // 1280= 32bpp with alpha < /

                                 // 512? = dxt1 no alpha
                                 // 768 = dxt3 with alpha
                                 // ? = dxt3 no alpha

                                 // 256 = used in generic.txd (first of 2 duplicates in img file)
                                 // and in hud.txd too


                                 // 6 = was used for body in ashdexx's sample
                                 // custom xbox working txd


alpha_used: array[0..3] of char; // alpha used flag: 1 or 0  note: very very long boolean value
                                 // format 9 uses fourcc codes for dxt compression here
width: word;                     // width of image
height: word;                    // height of image
BitsPerPixel: Byte;              // image data type
mipmaps: Byte;                   // usualy 1. some vice city txds had mipmaps but game didn't use them.
                                 // san andreas makes full use of mipmaps.
set_to_4: Byte;                  // 4
dxtcompression: Byte;            // directx compression= DXT + this number
                                 // 15 = DXT3 XBOX
                                 // 12 = DXT1 XBOX

data_size: Longword;             // size of image data if image is 8 bpp then there is a palette before this!
end;

implementation

end.
