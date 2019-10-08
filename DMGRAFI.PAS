{----------------------------------------------	DMGrafik-Callback messages}
const
DMG_Expand       =  0;
DMG_Repack       =  1;
DMG_Resize       =  2;
DMG_ChgToGray    =  3;
DMG_ExpToTrue    =  4;
DMG_Histogramm   =  5;
DMG_Remap        =  6;
DMG_ChgTo256     =  7;
{----------------------------------------------	StandardErrors}
const
MGERR_FIRST      = 128;
MGERR_CANCEL     = 128;
MGERR_NOMEMORY   = 129;
MGERR_MEMNOTFIX  = 130;
MGERR_WRONGFORM  = 131;
MGERR_READOPEN   = 132;
MGERR_WRITEOPEN  = 133;
MGERR_READERROR  = 134;
MGERR_WRITEERROR = 135;
MGERR_FILENOTFND = 136;
MGERR_NOWINBMP   = 137;
MGERR_NOTSUPPORT = 138;
MGERR_NOTRUECOL  = 139;
MGERR_ISTRUECOL  = 140;
MGERR_ENDOFIMG   = 141;
MGERR_NOTLOWER   = 142;
MGERR_NOTHIGHER  = 143;
MGERR_WRONGDLL   = 144;
MGERR_JPGWARNUNG = 145;
MGERR_TOFEWCOLORS= 146;
MGERR_LAST       = 146;
{----------------------------------------------	DIB-Palette}
type
tRGBType        = (Red, Green, Blue);
pRGBColor	= ^tRGBColor;
tRGBColor       = array[tRGBType] of byte;
{----------------------------------------------	Raw-Palette}
type
pRawPalette     = ^tRawPalette;
tRawPalette     = array[0..255] of tRGBColor;
{----------------------------------------------	MultiTasking-Function}
{ wMsg      : DMG_xxx-Constant                }
{ cProgress : progress in percent             }
type
tMultiTasking   = function(wMsg: word; cProgress: longint): boolean; stdcall;
