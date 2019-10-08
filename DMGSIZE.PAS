unit Dmgsize;

interface

uses Windows;

{==============================================	exported Sizing-Functions}
function mg_TrueColorSizeDown(pBMI: pBitmapInfo; Wid, Hei: longint)
         : pBitmapInfo; stdcall;
function mg_TrueColorSizeUp(pBMI: pBitmapInfo; Wid, Hei: longint)
         : pBitmapInfo; stdcall;
function mg_ResizePicture(pBMI: pBitmapInfo; Wid, Hei: longint)
         : pBitmapInfo; stdcall;

implementation

uses DMGBasic, SysUtils;

{==============================================	private Sizing-Functions}

{----------------------------------------------	ResamplePicture}
{ in DMCoSi.hqDIB  : the original Bitmap                       }
{ in DMCoSi.czWid and DMCoSi.czHei : in Width and Height     }
{ in DMCoSi.cqWid and DMCoSi.cqHei : out Width and Height    }
{ SizeDown         : true, SizeUp                        }
{ Ergebnis-DIB     : DMCoSi.pzBMI                              }
function ResamplePicture(SizeDown: bool): boolean;
var
{-------------- Quelle}
cqBMI           : longint;
cqOffs          : longint;
{-------------- Ziel}
czBMI           : longint;
czDIB           : longint;
czOffs          : longint;
BPP             : longint;
{-------------- HelpVariables}
qPtr, zPtr      : pByte;
pQ, pZ          : pBGRArr;
y, x, yp, xp    : integer;
yStart, yEnde   : integer;
xStart, xEnde   : integer;
Proz            : longint;
SumB, SumG, SumR: longint;
rEHy, rLHy      : longint;
rEHx, rLHx      : longint;
begin
  {------------- StartInitialising}
  Result := false;
  with DMCoSi
  do begin
     {---------- input image processing}
     with pqBMI^.bmiHeader
     do begin
        {------- input must be True-Color}
        if (biBitCount <= 8)
        then begin
             ExitCoSiProc(MGERR_NOTRUECOL);
             exit;
        end {no TrueColor-Image};
        {------- Output data}
        cqBMI := sizeof(tBitmapInfoHeader);
        BPP   := biBitCount;
        cqLen := mg_GetDIBSize(biWidth, biHeight, biBitCount) DIV biHeight;
     end;
     czDIB := mg_GetDIBSize(czWid, czHei, BPP);
     czLen := czDIB DIV czHei;
     czBMI := cqBMI;
     pzBMI := mg_SetupDIB(nil, czWid, czHei, czDIB, czBMI, BPP);
     if (pzBMI = nil)
     then begin
          ExitCoSiProc(MGERR_NOMEMORY);
          exit;
     end;
     if not(GetResampleTabelle)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     if not(GetCoSiBuf)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     {---------- Startinitialising}
     ProzFaktor := 100 / czHei;
     dec(czHei);
     czOffs := czBMI;
     pQ := pBGRArr(pqBuf);
     pZ := pBGRArr(pzBuf);
     SumB := 0;
     SumG := 0;
     SumR := 0;
     for y := 0 to czHei
     do begin
        {------- Startinitialising for y}
        yStart := pyPix^[y, Erster];
        yEnde  := pyPix^[y, Letzter];
        rEHy   := pyRnd^[y, Erster];
        rLHy   := pyRnd^[y, Letzter];
        cqOffs := cqBMI + yStart * cqLen;
        fillchar(pZ^, czLen, #0);
        for yp := yStart to yEnde
        do begin
           qPtr := pointer(pChar(pqBMI) + cqOffs);
           inc(cqOffs, cqLen);
           Move(qPtr^, pqBuf^, cqLen);
           for x := 0 to czWid - 1
           do begin
              {- Startinitialising for x}
              xStart := pxPix^[x, Erster];
              xEnde  := pxPix^[x, Letzter];
              rEHx   := pxRnd^[x, Erster];
              rLHx   := pxRnd^[x, Letzter];
              for xp := xStart to xEnde
              do begin
                 case SizeDown of
                      true:
                      begin
                        SumB := (pQ^[xp, Bc]  SHL MP) DIV rFWF;
                        SumG := (pQ^[xp, Gc] SHL MP) DIV rFWF;
                        SumR := (pQ^[xp, Rc]   SHL MP) DIV rFWF;
                        if (xp = xStart)
                        then begin
                             SumB := (rEHx * SumB) SHR MP;
                             SumG := (rEHx * SumG) SHR MP;
                             SumR := (rEHx * SumR) SHR MP;
                        end
                        else if (xp = xEnde)
                        then begin
                             SumB := (rLHx * SumB) SHR MP;
                             SumG := (rLHx * SumG) SHR MP;
                             SumR := (rLHx * SumR) SHR MP;
                        end;
                        if (yp = yStart)
                        then begin
                             SumB := (rEHy * SumB) SHR MP;
                             SumG := (rEHy * SumG) SHR MP;
                             SumR := (rEHy * SumR) SHR MP;
                        end
                        else if (yp = yEnde)
                        then begin
                             SumB := (rLHy * SumB) SHR MP;
                             SumG := (rLHy * SumG) SHR MP;
                             SumR := (rLHy * SumR) SHR MP;
                        end;
                      end;
                      false:
                      begin
                        SumB := pQ^[xp, Bc];
                        SumG := pQ^[xp, Gc];
                        SumR := pQ^[xp, Rc];
                        if (xStart <> xEnde)
                        then begin
                             if (xp = xStart)
                             then begin
                                  SumB := (SumB * rEHx) SHR MP;
                                  SumG := (SumG * rEHx) SHR MP;
                                  SumR := (SumR * rEHx) SHR MP;
                             end
                             else if (xp = xEnde)
                             then begin
                                  SumB := (SumB * rLHx) SHR MP;
                                  SumG := (SumG * rLHx) SHR MP;
                                  SumR := (SumR * rLHx) SHR MP;
                             end;
                        end;
                        if (yStart <> yEnde)
                        then begin
                             if (yp = yStart)
                             then begin
                                  SumB := (SumB * rEHy) SHR MP;
                                  SumG := (SumG * rEHy) SHR MP;
                                  SumR := (SumR * rEHy) SHR MP;
                             end
                             else if (yp = yEnde)
                             then begin
                                  SumB := (SumB * rLHy) SHR MP;
                                  SumG := (SumG * rLHy) SHR MP;
                                  SumR := (SumR * rLHy) SHR MP;
                             end;
                        end;
                      end;
                 end {case SizeDown};
                 pZ^[x, Bc]  := pZ^[x, Bc]  + SumB;
                 pZ^[x, Gc] := pZ^[x, Gc] + SumG;
                 pZ^[x, Rc]   := pZ^[x, Rc]   + SumR;
              end;
           end;
        end;
        zPtr := pointer(pChar(pzBMI) + czOffs);
        inc(czOffs, czLen);
        Move(pzBuf^, zPtr^, czLen);
        {------- MultiTasking}
        if (MulTa <> nil)
        then begin
             Proz := round(y * ProzFaktor);
             if TMultiTasking(MulTa)(DMG_Resize, Proz)
             then begin
                  ExitCoSiProc(MGERR_CANCEL);
                  exit;
             end {UserAbort};
        end {MultiTasking};
     end;
  end;
  ExitCoSiProc(0);
  Result := mg_LastError = 0;
end {function ResamplePicture};

{==============================================	Exported Sizing-Functions}

{----------------------------------------------	mg_TrueColorSizeDown}
{ in pBMI        : the original Bitmap                              }
{ in Hei, Wid    : the Width and Height                             }
{ DIB   : Result                                                    }
function mg_TrueColorSizeDown(pBMI: pBitmapInfo; Wid, Hei: longint): pBitmapInfo;
begin
  {------------- Startinitialising}
  Result := nil;
  mg_LastError := 0;
  if (pBMI = nil) then exit;
  fillchar(DMCoSi, sizeof(tDMCoSi), #0);
  with DMCoSi
  do begin
     pqBMI := pBMI;
     czWid := Wid;
     czHei := Hei;
     cqWid := pBMI^.bmiHeader.biWidth;
     cqHei := pBMI^.bmiHeader.biHeight;
     if (cqWid <= czWid) OR (cqHei <= czWid)
     then mg_LastError := MGERR_NOTLOWER
     else if ResamplePicture(true) then Result := pzBMI;
  end {with DMCoSi};
end {function mg_TrueColorSizeDown};
{----------------------------------------------	mg_TrueColorSizeUp}
{ in pBMI        : the original Bitmap                            }
{ in Hei, Wid    : the Width and Height                           }
{ DIB   : Result                                                  }
function mg_TrueColorSizeUp(pBMI: pBitmapInfo; Wid, Hei: longint): pBitmapInfo;
begin
  {------------- Startinitialising}
  Result := nil;
  mg_LastError := 0;
  if (pBMI = nil) then exit;
  fillchar(DMCoSi, sizeof(tDMCoSi), #0);
  with DMCoSi
  do begin
     pqBMI := pBMI;
     czWid := Wid;
     czHei := Hei;
     cqWid := pBMI^.bmiHeader.biWidth;
     cqHei := pBMI^.bmiHeader.biHeight;
     if (cqWid >= czWid) OR (cqHei >= czHei)
     then mg_LastError := MGERR_NOTHIGHER
     else if ResamplePicture(false) then Result := pzBMI;
  end {with DMCoSi};
end {function mg_TrueColorSizeUp};
{----------------------------------------------	mg_ResizePicture}
{ in pBMI        : the original Bitmap                          }
{ in Hei, Wid    : the Width and -Height                        }
{ DIB   : Result                                                }
function mg_ResizePicture(pBMI: pBitmapInfo; Wid, Hei: longint): pBitmapInfo;
var
{---------------- Quell-DIB}
cqBMI           : longint;
cqOffs          : longint;
{---------------- Ziel-DIB}
czBMI           : longint;
czDIB           : longint;
czOffs          : longint;
BPP             : longint;
qPtr, zPtr      : pByte;
y, ySrc         : integer;
x, xSrc         : integer;
yp, cQ, cZ      : integer;
PixWid          : word;
Proz            : longint;
cqmask, czmask  : byte;
Pixel           : byte;
Maske           : byte;
maskq           : byte;
begin
  {------------- StartInitialising}
  Result := nil;
  mg_LastError := 0;
  if (pBMI = nil) then exit;
  fillchar(DMCoSi, sizeof(tDMCoSi), #0);
  with DMCoSi
  do begin
     pqBMI := pBMI;
     czWid := Wid;
     czHei := Hei;
     with pqBMI^.bmiHeader
     do begin
        BPP   := biBitCount;
        cqLen := mg_GetDIBSize(biWidth, biHeight, biBitCount) DIV biHeight;
        cqWid := biWidth;
        cqHei := biHeight;
     end;
     if (BPP > 8) AND (BPP < 24) then BPP := 24;
     Maske  := 0;
     PixWid := 0;
     case BPP of
          1  : Maske  := $80;
          2  : Maske  := $c0;
          4  : Maske  := $f0;
          8  : PixWid := 1;
          24 : PixWid := 3;
     end;
     if not(GetResizeTabelle)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     y := mg_GetPaletteSize(pqBMI);
     cqBMI := sizeof(TBitmapInfoHeader) + y;
     czDIB := mg_GetDIBSize(czWid, czHei, BPP);
     czLen := czDIB DIV czHei;
     czBMI := cqBMI;
     pzBMI := mg_SetupDIB(nil, czWid, czHei, czDIB, czBMI, BPP);
     if (pzBMI = nil)
     then begin
          ExitCoSiProc(MGERR_NOMEMORY);
          exit;
     end;
     if (BPP <= 8)
     then begin
          qPtr := pointer(pChar(pqBMI) + sizeof(TBitmapInfoHeader));
          zPtr := pointer(pChar(pzBMI) + sizeof(TBitmapInfoHeader));
          Move(qPtr^, zPtr^, y);
     end;
     if not(GetCoSiBuf)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     {---------- Startinitialising}
     ProzFaktor := 100 / czHei;
     dec(czWid);
     dec(czHei);
     cqOffs := cqBMI;
     czOffs := czBMI;
     ySrc := yIdx^[0];
     case BPP of

       {-------- 256 and Colorplanes}
       8, 24:
       for y := 0 to czHei
       do begin
          while (ySrc <> yIdx^[y])
          do begin
             inc(ySrc);
             inc(cqOffs, cqLen);
          end;
          qPtr := pointer(pChar(pqBMI) + cqOffs);
          Move(qPtr^, pqBuf^, cqLen);
          xSrc  := xIdx^[0];
          for x := 0 to czWid
          do begin
             while (xSrc <> xIdx^[x]) do inc(xSrc);
             cQ := xSrc * PixWid;
             cZ := x * PixWid;
             for yp := 0 to PixWid - 1
             do begin
                Pixel := pByteArray(pqBuf)^[cQ + yp];
                pByteArray(pzBuf)^[cZ + yp] := Pixel;
             end;
          end;
          zPtr := pointer(pChar(pzBMI) + czOffs);
          inc(czOffs, czLen);
          Move(pzBuf^, zPtr^, czLen);
          {----- MultiTasking}
          if (MulTa <> nil)
          then begin
               Proz := round(y * ProzFaktor);
               if TMultiTasking(MulTa)(DMG_Resize, Proz)
               then begin
                    ExitCoSiProc(MGERR_CANCEL);
                    exit;
               end {UserAbort};
          end {MultiTasking};
       end;

       1, 2, 4:
       for y := 0 to czHei
       do begin
          while (ySrc <> yIdx^[y])
          do begin
             inc(ySrc);
             inc(cqOffs, cqLen);
          end;
          qPtr := pointer(pChar(pqBMI) + cqOffs);
          Move(qPtr^, pqBuf^, cqLen);
          fillchar(pzBuf^, czLen, #0);
          xSrc   := xIdx^[0];
          cqmask := Maske;
          czmask := Maske;
          cQ     := 0;
          cZ     := 0;
          for x := 0 to czWid
          do begin
             while (xSrc <> xIdx^[x])
             do begin
                inc(xSrc);
                cqmask := cqmask SHR BPP;
                if (cqmask = 0)
                then begin
                     cqmask := Maske;
                     inc(cQ);
                end;
             end;
             Pixel := pByteArray(pqBuf)^[cQ] AND cqmask;
             if (Pixel <> 0)
             then begin
                  if (cqmask <> czmask)
                  then begin
                       maskq := cqmask;
                       while (maskq <> czmask)
                       do if (maskq <  czmask)
                       then begin
                            Pixel := Pixel SHL BPP;
                            maskq := maskq SHL BPP;
                       end
                       else begin
                            Pixel := Pixel SHR BPP;
                            maskq := maskq SHR BPP;
                       end;
                  end;
                  Pixel := Pixel OR pByteArray(pzBuf)^[cZ];
                  pByteArray(pzBuf)^[cZ] := Pixel;
             end;
             czmask := czmask SHR BPP;
             if (czmask = 0)
             then begin
                  czmask := Maske;
                  inc(cZ);
             end;
          end;
          zPtr := pointer(pChar(pzBMI) + czOffs);
          inc(czOffs, czLen);
          Move(pzBuf^, zPtr^, czLen);
          {----- MultiTasking}
          if (MulTa <> nil)
          then begin
               Proz := round(y * ProzFaktor);
               if TMultiTasking(MulTa)(DMG_Resize, Proz)
               then begin
                    ExitCoSiProc(MGERR_CANCEL);
                    exit;
               end {UserAbort};
          end {MultiTasking};
       end;
     end;
  end;
  ExitCoSiProc(0);
  Result := DMCoSi.pzBMI;
end {function mg_ResizePicture};

end.
