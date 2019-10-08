unit DMGrBMP;

interface

uses Windows,Classes,Graphics;

{==============================================	exported Bitmap-Functions}
function  mg_GetDIBMeasure(pBMI: pBitmapInfo): longint; stdcall;
function  mg_MakeBMPfromDIB(pBMI: pBitmapInfo): hBitmap; stdcall;
function  mg_SaveTheDIB(pBMI: pBitmapInfo; Name: pChar): boolean; stdcall;

{==============================================	exported Help functions}
function LoadTheDIB: boolean;
function LoadDIBfromBMP(Bitmap: TBitmap; var GDIB : pBitmapInfo): boolean;

implementation

uses DMGBasic, SysUtils;

{----------------------------------------------	TestWinDIB}
function TestWinDIB(pBMF: pBitmapFileHeader; pBMI: pBitmapInfo): boolean;
begin
  TestWinDIB := false;
  if (pBMF^.bfType <> Bitmap_Type) then exit;
  if (pBMI^.bmiHeader.biSize <> sizeof(tBitmapInfoHeader))
  then exit
  else TestWinDIB := true;
end {function TestWinDIB};

{----------------------------------------------	mg_GetDIBMeasure}
function mg_GetDIBMeasure(pBMI: pBitmapInfo): longint;
var
Wert            : LongRec;
begin
  if (pBMI <> nil)
  then with pBMI^.bmiHeader
  do begin
     Wert.Lo := biWidth;
     Wert.Hi := biHeight;
     Result := longint(Wert);
  end {with pBMI^.bmiHeader}
  else Result := 0;
end {function mg_GetDIBMeasure};

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
{----------------------------------------------	mg_SaveTheDIB}
function mg_SaveTheDIB(pBMI: pBitmapInfo; Name: pChar): boolean;
const
dmWriteOpen     = fmCreate OR fmShareExclusive;
var
pHilf           : pointer;
Erg, cBMI	: longint;
Laenge          : longint;
Stream		: tFileStream;
BMF		: tBitmapFileHeader;
Buf             : string;
begin
  Result := false;
  if (pBMI = nil) then exit;
  {------------	BitmapFileHeader filling}
  cBMI :=  sizeof(tBitmapInfoHeader) + mg_GetPaletteSize(pBMI);
  BMF.bfType := Bitmap_Type;
  BMF.bfSize := sizeof(tBitmapFileHeader) + cBMI + pBMI^.bmiHeader.biSizeImage;
  BMF.bfReserved1 := 0;
  BMF.bfReserved2 := 0;
  BMF.bfOffBits := sizeof(tBitmapFileHeader) + cBMI;
  try
    {----------- Image-Stream init}
    Buf    := StrPas(Name);
    Stream := tFileStream.Create(Buf, dmWriteOpen);
    {----------- BitmapFileHeader writing}
    Laenge := sizeof(BMF);
    Erg    := Stream.Write(BMF, Laenge);
    if (Erg <> Laenge)
    then begin
         Stream.Free;
         mg_LastError := MGERR_WRITEERROR;
         exit;
    end {if Stream-Error};
    {----------- DIB writing}
    pHilf  := pBMI;
    Laenge := cBMI + pBMI^.bmiHeader.biSizeImage;
    Erg    := Stream.Write(pHilf^, Laenge);
    Stream.Free;
    if (Erg <> Laenge)
    then mg_LastError := MGERR_WRITEERROR
    else Result := mg_LastError = 0;
  except
    On EFCreateError do mg_LastError := MGERR_WRITEOPEN;
  end {except};
end {function mg_SaveTheDIB};

{----------------------------------------------	LoadTheDIB}
{ Input:                                                  }
{ DMGS.ImageName       : FileName                         }
{ Output:                                                 }
{ DMGS.pBMI            : the Image as DIB                 }
{ mg_LastError         : one error Return = false         }
function LoadTheDIB: boolean;
const
dmReadOpen      = fmOpenRead OR fmShareDenyWrite;
var
pHilf           : pointer;
Laenge          : longint;
Err             : longint;
BMF		: tBitmapFileHeader;
begin
  Result := false;
  with DMGS
  do try
     {----------- ImageFile open}
     Stream := tFileStream.Create(ImageName, dmReadOpen);
     {----------- FileHeader read}
     Laenge := sizeof(tBitmapFileHeader);
     Err    := Stream.Read(BMF, Laenge);
     if (Err <> Laenge)
     then begin
          Stream.Free;
          mg_LastError := MGERR_READERROR;
          exit;
     end {error};
     {---------- Malloc for header}
     Laenge := sizeof(tBitmapInfoHeader);
     GetMem(pBMI, Laenge);
     {---------- BitmapInfoHeader reading}
     Laenge := sizeof(tBitmapInfoHeader);
     Err    := Stream.Read(pBMI^, Laenge);
     if (Err <> Laenge)
     then begin
          Stream.Free;
          FreeMem(pBMI);
          mg_LastError := MGERR_READERROR;
          exit;
     end {error};
     {---------- bitmap testing}
     if not(TestWinDIB(Addr(BMF), pBMI))
     then begin
          Stream.Free;
          FreeMem(pBMI);
          mg_LastError := MGERR_NOWINBMP;
          exit;
     end {error};
     {---------- Color number load}
     ColorD := mg_GetPaletteSize(pBMI);

     cDIB := pBMI^.bmiHeader.biSizeImage;
     if (cDIB = 0) then cDIB := BMF.bfSize - BMF.bfOffBits;
     inc(Laenge, ColorD);
     inc(Laenge, cDIB);
     ReAllocMem(pBMI, Laenge);
     if (ColorD > 0)
     then begin
          Laenge := sizeof(tBitmapInfoHeader);
          pHilf  := pChar(pBMI) + Laenge;
          Laenge := ColorD;
          Err    := Stream.Read(pHilf^, Laenge);
          if (Err <> Laenge)
          then begin
               Stream.Free;
               FreeMem(pBMI);
               mg_LastError := MGERR_READERROR;
               exit;
          end {error};
     end ;
     Stream.Seek(BMF.bfOffBits, 0);
     Laenge := sizeof(tBitmapInfoHeader) + ColorD;
     pHilf  := pChar(pBMI) + Laenge;
     Laenge := cDIB;
     Err    := Stream.Read(pHilf^, Laenge);
     Stream.Free;
     if (Err <> Laenge)
     then begin
          FreeMem(pBMI);
          mg_LastError := MGERR_READERROR;
          exit;
     end;
  except
    On EFOpenError do mg_LastError := MGERR_READOPEN;
    On EOutOfMemory
    do begin
       Stream.Free;
       mg_LastError := MGERR_NOMEMORY;
    end;
  end {with DMGS};
  Result := mg_LastError = 0;
end {function LoadTheDIB};


// LoadDIBfromStream
// same like the LoadDIB but only
// this makes DIB from memory stream

function LoadDIBfromBMP(Bitmap: TBitmap; var GDIB : pBitmapInfo): boolean;
var pHilf: pointer;
    Laenge,Err: longint;
    BMF: tBitmapFileHeader;
begin
  FillChar(DMGS, sizeof(tDMGS), #0);
  mg_LastError  := 0;
  Result := false;
  with DMGS
  do try
     Stream := TMemoryStream.Create;
     (Bitmap as TGraphic).SaveToStream(Stream);
     Stream.Position := 0;
     Laenge := sizeof(tBitmapFileHeader);
     Err    := Stream.Read(BMF, Laenge);
     if (Err <> Laenge)
     then begin
          Stream.Free;
          mg_LastError := MGERR_READERROR;
          exit;
     end;
     Laenge := sizeof(tBitmapInfoHeader);
     GetMem(pBMI, Laenge);
     Laenge := sizeof(tBitmapInfoHeader);
     Err    := Stream.Read(pBMI^, Laenge);
     if (Err <> Laenge)
     then begin
          Stream.Free;
          FreeMem(pBMI);
          mg_LastError := MGERR_READERROR;
          exit;
     end;
     if not(TestWinDIB(Addr(BMF), pBMI))
     then begin
          Stream.Free;
          FreeMem(pBMI);
          mg_LastError := MGERR_NOWINBMP;
          exit;
     end;
     ColorD := mg_GetPaletteSize(pBMI);
     cDIB := pBMI^.bmiHeader.biSizeImage;
     if (cDIB = 0) then cDIB := BMF.bfSize - BMF.bfOffBits;
     inc(Laenge, ColorD);
     inc(Laenge, cDIB);
     ReAllocMem(pBMI, Laenge);
     if (ColorD > 0)
     then begin
          Laenge := sizeof(tBitmapInfoHeader);
          pHilf  := pChar(pBMI) + Laenge;
          Laenge := ColorD;
          Err    := Stream.Read(pHilf^, Laenge);
          if (Err <> Laenge)
          then begin
               Stream.Free;
               FreeMem(pBMI);
               mg_LastError := MGERR_READERROR;
               exit;
          end;
     end;
     Stream.Seek(BMF.bfOffBits, 0);
     Laenge := sizeof(tBitmapInfoHeader) + ColorD;
     pHilf  := pChar(pBMI) + Laenge;
     Laenge := cDIB;
     Err    := Stream.Read(pHilf^, Laenge);
     Stream.Free;
     if (Err <> Laenge)
     then begin
          FreeMem(pBMI);
          mg_LastError := MGERR_READERROR;
          exit;
     end;
  except
    On EFOpenError do mg_LastError := MGERR_READOPEN;
    On EOutOfMemory
    do begin
       Stream.Free;
       mg_LastError := MGERR_NOMEMORY;
    end;
  end;
  Result := mg_LastError = 0;
  gDIB := DMGS.pBMI;
end {function LoadDIBfromBMP};

end.
