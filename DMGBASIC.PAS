unit Dmgbasic;

Interface

uses Windows, SysUtils, Classes;
{$I DMGRAFI.PAS}
{----------------------------------------------	Bitmap-Header}
const
Bitmap_Type	= $4d42;			{'BM' - lo/hi}
{----------------------------------------------	Longint-Operations}
const
MP              = 7;
Multipli        = 1 SHL MP;
MaxSmallInt     = 32767;
{----------------------------------------------	IO-Buffer}
const
cIOBufLen       = 8192 * 2;
Flush_Buffer    = $1ff;
{----------------------------------------------	DIB-Types}
type
tBGRColVal      = (Bc, Gc, Rc);
tBGRColor       = array[tBGRColVal] of byte;
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
                  ImageName      : string;
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
{----------------------------------------------	Types for Resize}
type
tIntArray       = array[0..MaxSmallInt] of smallint;
pIntArray       = ^tIntArray;
{----------------------------------------------	Types for Resample}
type
tGrenz          = (Erster, Letzter);
tPixel          = array[tGrenz] of smallint;
tPixelTab       = array[0..MaxSmallInt] of tPixel;
pPixelTab       = ^tPixelTab;
tRand           = array[tGrenz] of smallint;
tRandTab        = array[0..MaxSmallInt] of tRand;
pRandTab        = ^tRandTab;
{----------------------------------------------	Structure for Color/Sizing}
type
pDMCoSi         = ^tDMCoSi;
tDMCoSi         = record
                  {---------------------------- DIB}
                  pqBMI       : pBitmapInfo;
                  cqWid       : word;
                  cqHei       : word;
                  {---------------------------- DIB}
                  pzBMI       : pBitmapInfo;
                  czWid       : word;
                  czHei       : word;
                  {---------------------------- ReadBuffer}
                  pqBuf       : pointer;
                  cqLen       : longint;
                  {---------------------------- WriteBuffer}
                  pzBuf       : pointer;
                  czLen       : longint;
                  {---------------------------- ResizeTables}
                  xIdx, yIdx  : pIntArray;
                  {---------------------------- ResampleTables}
                  pyPix, pxPix: pPixelTab;
                  pyRnd, pxRnd: pRandTab;
end {record tDMCoSi};
{----------------------------------------------	Image Format}
type
tImageFormat     = (tbf_Unknown, tbf_BMP, tbf_JPG, tbf_TGA, tbf_PCX);

{==============================================	global Variables}

{---------------------------------------------- ErrorHandling}
var
mg_LastError    : word;
{----------------------------------------------}
rFWF            : word;
{---------------------------------------------- Structures}
InMemory        : boolean;
DMGS            : tDMGS;
DMCoSi          : tDMCoSi;
{---------------------------------------------- MultiTasking}
MulTa           : TFarProc;
ProzFaktor      : single;
{---------------------------------------------- JPEG}
JPEG_Palette    : boolean;
JPEG_GrayScale  : boolean;
JPEG_DitherMode : integer;
JPEG_TwoPass    : boolean;
JPEG_Quality    : integer;


{==============================================	exported Basic-Functions}
function  mg_GetNumColors(BMI: pBitmapInfo): longint; stdcall;
function  mg_GetPaletteSize(BMI: pBitmapInfo): longint; stdcall;
function  mg_GetDIBSize(cWid, cHei: longint; BPP: word): longint; stdcall;
function  mg_SetupDIB(Palette: pRawPalette; cWid, cHei, cDIB, cBMI: longint;
          BPP: word): pBitmapInfo; stdcall;

{==============================================	helpers}
function  GetStreamByte: byte;
procedure SetExpandByte(Pix: smallint);
function  GetPictureStream: boolean;
procedure FreePictureStream;
function  GetBufferMem: boolean;
function  GetExpandedMem: boolean;
procedure FreeExpandedMem;
function  GetResizeTabelle: boolean;
function  GetResampleTabelle: boolean;
function  GetCoSiBuf: boolean;
procedure ExitConvProc(Fehler: word);
procedure ExitCoSiProc(Fehler: word);

Implementation

{----------------------------------------------	GetStreamByte}
function GetStreamByte: byte;
var
Proz            : integer;
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
               Proz   := Round(rOffset * ProzFaktor);
               bAbort := tMultiTasking(MulTa)(DMG_Expand, Proz);
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
function GetPictureStream: boolean;
const
fmFileOpen      = fmOpenRead OR fmShareDenyWrite;
var
FileStream      : tFileStream;
MemStream       : tMemoryStream;
begin
  try
    with DMGS
    do begin
       StreamOpen := false;
       {-------- MemoryStream}
       if InMemory
       then begin
            MemStream := tMemoryStream.Create;
            MemStream.LoadFromFile(ImageName);
            Stream := MemStream;
       end {MemoryStream}
       {-------- FileStream}
       else begin
            FileStream := tFileStream.Create(ImageName, fmFileOpen);
            Stream := FileStream;
       end;
       rSize := Stream.Size;
       ProzFaktor := 100 / rSize;
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
{----------------------------------------------	GetResizeTabelle}
function  GetResizeTabelle: boolean;
var
Faktor          : single;
Index           : smallint;
begin
  with DMCoSi
  do try
     GetMem(xIdx, sizeof(smallint) * czWid);
     GetMem(yIdx, sizeof(smallint) * czHei);
     Faktor := czWid / cqWid;
     for Index := 0 to czWid - 1 do xIdx^[Index] := round(Index / Faktor);
     Faktor := czHei / cqHei;
     for Index := 0 to czHei - 1 do yIdx^[Index] := round(Index / Faktor);
  except
    On EOutOfMemory do mg_LastError := MGERR_NOMEMORY;
  end;
  Result := mg_LastError = 0;
end {function GetResizeTabelle};
{----------------------------------------------	FreeResizeTabelle}
procedure FreeResizeTabelle;
begin
  with DMCoSi
  do begin
     if (xIdx <> nil)
     then begin
          FreeMem(xIdx);
          xIdx := nil;
     end;
     if (yIdx <> nil)
     then begin
          Freemem(yIdx);
          yIdx := nil;
     end;
  end {with DMCoSi};
end {procedure FreeResizeTabelle};
{----------------------------------------------	GetResampleTabelle}
function  GetResampleTabelle: boolean;
var
rSFy, rSFx      : single;
rEQP, rLQP      : single;
Fak1, Fak2      : single;
Hilfe           : single;
iEQP, iLQP      : smallint;
Index           : smallint;
begin
  with DMCoSi
  do try
     GetMem(pyPix, sizeof(tPixel) * czHei);
     GetMem(pxPix, sizeof(tPixel) * czWid);
     GetMem(pyRnd, sizeof(tRand) * czHei);
     GetMem(pxRnd, sizeof(tRand) * czWid);
     rSFy := cqHei / czHei;
     rSFx := cqWid / czWid;
     rFWF := round(rSFY * rSFx * Multipli);
     for index := 0 to czHei - 1
     do begin
        rEQP := rSFy * index;
        rLQP := rSFy * (index + 1);
        iEQP := trunc(rEQP);
        iLQP := trunc(rLQP);
        if (iLQP >= rLQP) then dec(iLQP);
        if (cqHei > czHei)
        then begin
             {-- SampleDown}
             Fak1 := 1 + iEQP - rEQP;
             Fak2 := rLQP - iLQP;
        end
        else begin
             {-- SampleUp}
             Hilfe := iLQP / rSFy;
             Fak1  := Hilfe - index;
             Fak2  := index + 1 - Hilfe;
        end;
        pyPix^[index, Erster]  := iEQP;
        pyPix^[index, Letzter] := iLQP;
        pyRnd^[index, Erster]  := round(Fak1 * Multipli);
        pyRnd^[index, Letzter] := round(Fak2 * Multipli);
     end;
     for index := 0 to czWid - 1
     do begin
        rEQP := rSFx * index;
        rLQP := rSFx * (index + 1);
        iEQP := trunc(rEQP);
        iLQP := trunc(rLQP);
        if (iLQP >= rLQP) then dec(iLQP);
        if (cqWid > czWid)
        then begin
             {-- SampleDown}
             Fak1 := 1 + iEQP - rEQP;
             Fak2 := rLQP - iLQP;
        end
        else begin
             {-- SampleUp}
             Hilfe := iLQP / rSFx;
             Fak1  := Hilfe - index;
             Fak2  := index + 1 - Hilfe;
        end;
        pxPix^[index, Erster]  := iEQP;
        pxPix^[index, Letzter] := iLQP;
        pxRnd^[index, Erster]  := round(Fak1 * Multipli);
        pxRnd^[index, Letzter] := round(Fak2 * Multipli);
     end;
  except
    On EOutOfMemory do mg_LastError := MGERR_NOMEMORY;
  end;
  Result := mg_LastError = 0;
end {function GetResampleTabelle};
{----------------------------------------------	FreeResampleTabelle}
procedure FreeResampleTabelle;
begin
  with DMCoSi
  do begin
     if (pyPix <> nil)
     then begin
          FreeMem(pyPix);
          pyPix := nil;
     end;
     if (pxPix <> nil)
     then begin
          FreeMem(pxPix);
          pxPix := nil;
     end;
     if (pyRnd <> nil)
     then begin
          FreeMem(pyRnd);
          pyRnd := nil;
     end;
     if (pxRnd <> nil)
     then begin
          FreeMem(pxRnd);
          pxRnd := nil;
     end;
  end {with DMCoSi};
end {procedure FreeResampleTabelle};
{----------------------------------------------	GetCoSiBuf}
function GetCoSiBuf: boolean;
begin
  with DMCoSi
  do try
     Getmem(pqBuf, cqLen + 1);
     GetMem(pzBuf, czLen + 1);
  except
    On EOutOfMemory do mg_LastError := MGERR_NOMEMORY;
  end;
  Result := mg_LastError = 0;
end {function GetCoSiBuf};
{----------------------------------------------	FreeCoSiBuf}
procedure FreeCoSiBuf;
begin
  with DMCoSi
  do begin
     if (pqBuf <> nil)
     then begin
          FreeMem(pqBuf);
          pqBuf := nil;
     end;
     if (pzBuf <> nil)
     then begin
          Freemem(pzBuf);
          pzBuf := nil;
     end ;
  end {with DMGS};
end {procedure FreeCoSiBuf};
{----------------------------------------------	ExitConvProc}
procedure ExitConvProc(Fehler: word);
begin
  FreePictureStream;
  FreeExpandedMem;
  FreeBufferMem;
  with DMGS
  do if (pBMI <> nil) AND (Fehler <> 0)
  then begin
       FreeMem(pBMI);
       pBMI := nil;
  end;
  mg_LastError := Fehler;
end {procedure ExitConvProc};
{----------------------------------------------	ExitCoSiProc}
procedure ExitCoSiProc(Fehler: word);
begin
  FreeCoSiBuf;
  FreeResizeTabelle;
  FreeResampleTabelle;
  with DMCoSi
  do if (pzBMI <> nil) AND (Fehler <> 0)
  then begin
       FreeMem(pzBMI);
       pzBMI := nil;
  end;
  mg_LastError := Fehler;
end {procedure ExitCoSiProc};

{----------------------------------------------	mg_GetNumColors}
function mg_GetNumColors(BMI: pBitmapInfo): longint;
var
ColorB		: longint;
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

end.
