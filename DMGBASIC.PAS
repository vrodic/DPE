unit Dmgbasic;

Interface

uses Windows, SysUtils, Classes;

{----------------------------------------------	StandardErrors}
const
MGERR_CANCEL     = 128;
MGERR_NOMEMORY   = 129;
MGERR_WRONGFORM  = 131;
MGERR_READOPEN   = 132;
MGERR_READERROR  = 134;
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
{ cProgress : progress in percent             }
type
tMultiTasking   = function(cProgress: longint): boolean;
{----------------------------------------------	Longint-Operations}
const
MaxSmallInt     = 32767;
{----------------------------------------------	IO-Buffer}
const
cIOBufLen       = 8192 * 2;
Flush_Buffer    = $1ff;
{----------------------------------------------	DIB-Types}
type
tBGRColVal    = (Bc, Gc, Rc);
tBGRColor     = array[tBGRColVal] of byte;
tBGRArr       = array[0..MaxSmallInt] of tBGRColor;
pBGRArr       = ^tBGRArr;
{----------------------------------------------	structures for converter}
type
pDMGS           = ^tDMGS;
tDMGS           = record
                  {---------------------------- Aborts and errors}
                  bAbort        : bool;
                  rError        : bool;
                  wError        : bool;
                  {---------------------------- Stream}
                  StreamOpen    : boolean;
                  Stream        : tStream;
                  rSize         : longint;
                  {---------------------------- ReadBuffer}
                  pReadBuf      : pByteArray;
                  rBufLen       : word;
                  rBufOffs      : word;
                  rLaenge       : longint;
                  rOffset       : longint;
                  rGelesen      : longint;
                  {---------------------------- Image packers}
                  pWrite        : pChar;
                  wOffset       : longint;
                  wSize         : longint;
                  wLineLength   : longint;
                  {---------------------------- WriteBuffer}
                  pWriteBuf     : pByteArray;
                  wBufLen       : word;
                  wBufOffs      : word;
                  wLaenge       : longint;
                  {---------------------------- DIB}
                  pBMI          : pBitmapInfo;
                  cBMI          : longint;
                  cDIB          : longint;
                  cDIBLine      : longint;
                  ColorD        : word;
                  BPP           : word;
                  Palette       : tRawPalette;
end {record tDMGS};
{==============================================	global Variables}

{---------------------------------------------- ErrorHandling}
var
mg_LastError    : word;
{---------------------------------------------- Structures}
DMGS            : tDMGS;
{---------------------------------------------- MultiTasking}
MulTa           : TFarProc;
PercentFactor   : single;


{==============================================	exported Basic-Functions}
function  mg_MakeBMPfromDIB(pBMI: pBitmapInfo): hBitmap;
function  mg_GetDIBSize(cWid, cHei: longint; BPP: word): longint;
function  mg_SetupDIB(Palette: pRawPalette; cWid, cHei, cDIB, cBMI: longint;
          BPP: word): pBitmapInfo;

{==============================================	helpers}
function  GetStreamByte: byte;
procedure SetExpandByte(Pix: smallint);
function  GetPictureStream(var FStream : TMemoryStream): boolean;
procedure FreePictureStream;
function  GetBufferMem: boolean;
function  GetExpandedMem: boolean;
procedure FreeExpandedMem;
procedure ExitConvProc(ErrorN: word);

Implementation

{----------------------------------------------	GetStreamByte}
function GetStreamByte: byte;
var
Percent            : integer;
begin
  with DMGS
  do begin
     Result := 0;
     if (rBufOffs >= rLaenge)
     then begin
          rLaenge := rSize - rOffset;
          if (rLaenge <= 0)
          then begin
               rError := true;
               exit;
          end;
          if (rLaenge > rBufLen) then rLaenge := rBufLen;
          inc(rOffset, rLaenge);
          rGelesen := Stream.Read(pReadBuf^, rLaenge);
          Result := pReadBuf^[0];
          rBufOffs := 1;
          {----- MultiTasking}
          if (MulTa <> nil)
          then begin
               Percent := Round(rOffset * PercentFactor);
               bAbort := tMultiTasking(MulTa)(Percent);
          end {MultiTasking};
     end
     else begin
          Result := pReadBuf^[rBufOffs];
          inc(rBufOffs);
     end;
  end {with DMGS};
end {function GetStreamByte};
{----------------------------------------------	SetExpandByte}
procedure SetExpandByte(Pix: smallint);
var
Zeiger          : pointer;
begin
  with DMGS
  do begin
     if (Pix = Flush_Buffer)
     then if (wBufOffs > 0)
     then begin
          if (wOffset + wBufOffs >= wSize) then wBufOffs := wSize - wOffset - 1;
          Zeiger := pWrite + wOffset;
          Move(pWriteBuf^, Zeiger^, wBufOffs);
          exit;
     end;
     if (wBufOffs >= wLaenge)
     then begin
          Zeiger := pWrite + wOffset;
          inc(wOffset, wLaenge);
          Move(pWriteBuf^, Zeiger^, wLaenge);
          wLaenge := wSize - wOffset;
          if (wLaenge <= 0)
          then begin
               wError := true;
               wBufOffs := 0;
               exit;
          end;
          if (wLaenge > wBufLen) then wLaenge := wBufLen;
          pWriteBuf^[0] := byte(Pix);
          wBufOffs := 1;
     end
     else begin
          pWriteBuf^[wBufOffs] := byte(Pix);
          inc(wBufOffs);
     end;
  end {with DMGS};
end {procedure SetExpandByte};
{----------------------------------------------	GetPictureStream}
function GetPictureStream(var FStream : TMemoryStream): boolean;
begin
  try
    with DMGS
    do begin
       StreamOpen := false;
       Stream := FStream;
       rSize := Stream.Size;
       PercentFactor := 100 / rSize;
       StreamOpen := true;
       Result := true;
    end {DMGS};
  except
    On EFOpenError
    do begin
       Result := false;
       mg_LastError := MGERR_READOPEN;
    end;
  end;
end {function GetPictureStream};
{----------------------------------------------	FreePictureStream}
procedure FreePictureStream;
begin
  with DMGS
  do if StreamOpen
  then begin
       Stream.Free;
       StreamOpen := false;
  end;
end {procedure FreePictureStream};
{----------------------------------------------	GetBufferMem}
function GetBufferMem: boolean;
begin
  with DMGS
  do begin
     if (rBufLen < cIOBufLen) then rBufLen := cIOBufLen;
     rBufOffs := rBufLen;
     if (wBufLen < cIOBufLen) then wBufLen := cIOBufLen;
     wLaenge  := wBufLen;
     try
       GetMem(pReadBuf, rBufLen);
       GetMem(pWriteBuf, wBufLen);
     except
       On EOutOfMemory do mg_LastError := MGERR_NOMEMORY;
     end
  end {with DMGS do};
  Result := mg_LastError = 0;
end {function GetBufferMem};
{----------------------------------------------	FreeBufferMem}
procedure FreeBufferMem;
begin
  with DMGS
  do begin
     if (pReadBuf <> nil)
     then begin
          FreeMem(pReadBuf);
          pReadBuf := nil;
     end;
     if (pWriteBuf <> nil)
     then begin
          FreeMem(pWriteBuf);
          pWriteBuf := nil;
     end;
  end {with DMGS};
end {procedure FreeBufferMem};
{----------------------------------------------	GetExpandedMem}
function GetExpandedMem: boolean;
begin
  with DMGS
  do try
     GetMem(pWrite, wSize);
  except
    On EOutOfMemory do mg_LastError := MGERR_NOMEMORY;
  end;
  Result := mg_LastError = 0;
end {function GetExpandedMem};
{----------------------------------------------	FreeExpandedMem}
procedure FreeExpandedMem;
begin
  with DMGS
  do if (pWrite <> nil)
  then begin
       FreeMem(pWrite);
       pWrite := nil;
  end;
end {procedure FreeExpandedMem};
{----------------------------------------------	ExitConvProc}
procedure ExitConvProc(ErrorN: word);
begin
  FreePictureStream;
  FreeExpandedMem;
  FreeBufferMem;
  with DMGS
  do if (pBMI <> nil) AND (ErrorN <> 0)
  then begin
       FreeMem(pBMI);
       pBMI := nil;
  end;
  mg_LastError := ErrorN;
end {procedure ExitConvProc};
{---------------------------------------------- mg_GetNumColors}
function mg_GetNumColors(BMI: pBitmapInfo): longint;
var ColorB: longint;
begin
  with BMI^.bmiHeader do ColorB := 1 SHL (biBitCount * biPlanes);
  Result := ColorB AND $1ff;
end {function mg_GetNumColors};
{----------------------------------------------	mg_GetPaletteSize}
function mg_GetPaletteSize(BMI: pBitmapInfo): longint;
begin
  Result := mg_GetNumColors(BMI) * sizeof(TRGBQuad);
end {function mg_GetPaletteSize};
{----------------------------------------------	mg_GetDIBSize}
function mg_GetDIBSize(cWid, cHei: longint; BPP: word): longint;
var
depth          : longint;
begin
  case BPP of
       1            : depth := 4 * ((cWid + 31) DIV 32);
       2, 4         : depth := 4 * ((cWid + 7)  DIV 8);
       8            : depth := 4 * ((cWid + 3)  DIV 4);
       15, 16, 24   : depth := 4 * ((3 * cWid + 3) DIV 4);
       else           depth := 0;
  end {case BPP};
  Result := depth * cHei;
end {function mg_GetDIBSize};
{----------------------------------------------	mg_SetupDIB}
function mg_SetupDIB(Palette: pRawPalette; cWid, cHei, cDIB, cBMI: longint;
         BPP: word): pBitmapInfo;
var
i, ColorB       : longint;
pBMI            : pBitmapInfo;
begin
  try
    GetMem(pBMI, cBMI + cDIB);
    fillchar(pBMI^, cBMI + cDIB, #0);
    Result := pBMI;
    with pBMI^.bmiHeader
    do begin
       biSize        := sizeof(tBitmapInfoHeader);
       biWidth       := cWid;
       biHeight      := cHei;
       biPlanes      := 1;
       biBitCount    := BPP;
       biCompression := BI_RGB;
       biSizeImage   := cDIB;
       ColorB        := (1 SHL BPP) AND $1ff;
       biClrUsed     := ColorB;
    end;
    {$R-}
    if (BPP <= 8) AND (Palette <> nil)
    then for i := 0 to ColorB - 1
    do with pBMI^.bmiColors[i]
    do begin
       rgbRed      := Palette^[i, Red];
       rgbGreen    := Palette^[i, Green];
       rgbBlue     := Palette^[i, Blue];
       rgbReserved := 0;
    end;
    {$R+}
  except
    On EOutOfMemory
    do begin
       mg_LastError := MGERR_NOMEMORY;
       Result := nil;
    end;
  end;
end {function mg_SetupDIB};
{----------------------------------------------	mg_MakeBMPfromDIB}
function mg_MakeBMPfromDIB(pBMI: pBitmapInfo): hBitmap;
var
DC        : hDC;
pHilf     : pointer;
Offset    : longint;
begin
  Result := 0;
  if (pBMI = nil) then exit;
  DC := GetDC(0);
  if (DC <> 0)
  then begin
       Offset := sizeof(tBitmapInfoHeader) + mg_GetPaletteSize(pBMI);
       pHilf  := pChar(pBMI) + Offset;
       {-------- Bitmap creating}
       Result := CreateDIBitmap(DC, pBMI^.bmiHeader, cbm_Init,
                 pHilf, pBMI^, dib_RGB_Colors);
       {-------- DisplayContext release}
       ReleaseDC(0, DC);
  end {DisplayContext not valid};
end {function mg_MakeBMPfromDIB};

end.
