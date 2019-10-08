unit Dmgcolor;

Interface

uses Windows;

{==============================================	exported Color-Functions}
function mg_TrueColorToGrey(pBMI: pBitmapInfo): pBitmapInfo; stdcall;
function mg_TrueColorTo256(pBMI: pBitmapInfo): pBitmapInfo; stdcall;
function mg_ExpandToTrueColor(pBMI: pBitmapInfo): pBitmapInfo; stdcall;

Implementation

uses DMGBasic, SysUtils;


{----------------------------------------------	types for the BMI-Palette}
type
pRGBQArray      = ^tRGBQArray;
tRGBQArray      = array[0..255] of tRGBQuad;


{----------------------------------------------	Color Constants}
const
RedI            = 0;
GreenI          = 1;
BlueI           = 2;
{----------------------------------------------	Color Constants}
const
Bits            = 5;
cBits           = 8 - Bits;
ColorMaxI       = 1 SHL Bits;
cHistogramm     = ColorMaxI * ColorMaxI * ColorMaxI;
{----------------------------------------------	ColorBox}
type
tMean           = array[RedI..BlueI] of single;
tFreqZeile      = array[0..ColorMaxI - 1] of longint;
tFreqArray      = array[RedI..BlueI] of tFreqZeile;
tLowHigh        = array[RedI..BlueI] of integer;
pBox            = ^tBox;
tBox            = record
                  WeiVar : single;
                  mean   : tMean;
                  weight : longint;
                  Freq   : tFreqArray;
                  low    : tLowHigh;
                  high   : tLowHigh;
end {record tBox};
{----------------------------------------------	ColorBoxes, Histogramm, RGBMap}
type
pBoxes          = ^tBoxes;
tBoxes          = array[0..255] of tBox;
pHistogramm     = ^tHistogramm;
tHistogramm     = array[0..cHistogramm - 1] of longint;
type
pRGBmap         = ^tRGBmap;
tRGBmap         = array[0..cHistogramm - 1] of byte;

{==============================================	global Variables}
var
pHisto          : pHistogramm;
pBoxArr         : pBoxes;
pMap            : pRGBmap;
cHBRPix         : longint;
cHBRCol         : longint;
cHBRqBMI        : longint;
cHBRzBMI        : longint;
cHBROutCol      : longint;

{==============================================	Functions for TrueColorTo256}

{----------------------------------------------	Histogramm}
function Histogramm: boolean;
var
qPtr            : pointer;
cqOffs          : longint;
pQ              : pBGRArr;
h               : integer;
Proz            : integer;
r, g, b         : byte;
y, x            : integer;
begin
  with pBoxArr^[0]
  do begin
     fillchar(Freq[RedI],   sizeof(tFreqZeile), #0);
     fillchar(Freq[GreenI], sizeof(tFreqZeile), #0);
     fillchar(Freq[BlueI],  sizeof(tFreqZeile), #0);
     ProzFaktor := 100 / DMCoSi.czHei;
     cqOffs     := cHBRqBMI;
     pQ         := pBGRArr(DMCoSi.pqBuf);
     for y := 0 to DMCoSi.czHei - 1
     do begin
        qPtr := pChar(DMCoSi.pqBMI) + cqOffs;
        inc(cqOffs, DMCoSi.cqLen);
        Move(qPtr^, DMCoSi.pqBuf^, DMCoSi.cqLen);
        for x := 0 to DMCoSi.czWid - 1
        do begin
           r := pQ^[x, Rc] SHR cBits;
           inc(Freq[RedI, r]);
           g := pQ^[x, Gc] SHR cBits;
           inc(Freq[GreenI, g]);
           b := pQ^[x, Bc] SHR cBits;
           inc(Freq[BlueI, b]);
           h := r SHL Bits;
           h := (h OR g) SHL Bits;
           h := h OR b;
           inc(pHisto^[h]);
        end;
        if (MulTa <> nil)
        then begin
             Proz := round(y * ProzFaktor);
             if TMultiTasking(MulTa)(DMG_Histogramm, Proz)
             then begin
                  mg_LastError := MGERR_CANCEL;
                  Result := false;
                  exit;
             end {UserAbort};
        end {MultiTasking};
     end ;
  end {with pBoxArr^[0]};
  Result := true;
end {function Histogramm};
{----------------------------------------------	BoxStats}

procedure BoxStats(var pn: tBox);
var
mean1, vari1    : single;
hw              : single;
i, col          : integer;
begin
  pn.WeiVar := 0.0;
  if (pn.Weight = 0) then exit;
  for col := RedI to BlueI
  do begin
     vari1 := 0.0;
     mean1 := 0.0;
     for i := pn.Low[col] to pn.High[col] - 1
     do begin
        {------- mean1 := mean1 + i * Freq[col, i]}
        hw    := pn.Freq[col, i];
        hw    := hw * i;
        mean1 := mean1 + hw;
        {------- vari1 := vari1 + i * i * Freq[col, i]}
        hw    := hw * i;
        vari1 := vari1 + hw;
     end {for i := pn.Low[col] to pn.High[col] - 1};
     pn.Mean[col] := mean1 / pn.Weight;
     {---------- WeiVar := WeiVar + vari1 - mean[col] * mean[col] * Weight}
     hw := pn.mean[col];
     hw := hw * hw * pn.Weight;
     hw := vari1 - hw;
     pn.WeiVar := pn.WeiVar + hw;
  end;
  pn.WeiVar := pn.WeiVar / cHBRPix;
end {procedure BoxStats};
{----------------------------------------------	FindCutPoint}
function FindCutPoint(var pn, nBox1, nBox2: tBox; RGB: byte): boolean;
var
u, v, max       : single;
hw              : single;
OptWei          : longint;
CurWei          : longint;
myfreq          : longint;
h               : integer;
rOff, gOff      : integer;
i, CutPt        : integer;
maxIdx, minIdx  : integer;
l1, l2, h1, h2  : integer;
b, g, r         : byte;
begin
  Result := false;
  if (pn.Low[RGB] + 1 = pn.High[RGB]) then exit;
  MinIdx := round((pn.Mean[RGB] + pn.Low[RGB]) * 0.5);
  MaxIdx := round((pn.Mean[RGB] + pn.High[RGB]) * 0.5);
  CutPt  := MinIdx;
  OptWei := pn.Weight;
  CurWei := 0;
  for i := pn.Low[RGB] to MinIdx - 1 do CurWei := CurWei + longint(pn.Freq[RGB, i]);
  u := 0.0;
  Max := -1.0;
  for i := MinIdx to MaxIdx
  do begin
     inc(CurWei, pn.Freq[RGB, i]);
     if (CurWei = pn.Weight) then break;
     {---------- u := u + (i * Freq[RGB, i]) / Weight}
     hw := i;
     hw := (hw * pn.Freq[RGB, i]) / pn.Weight;
     u  := u + hw;
     {---------- v := (CurWei / (Weight - CurWei)) * (mean[RGB] - u)^2}
     hw := pn.Mean[RGB];
     hw := hw - u;
     hw := hw * hw;
     v  := CurWei;
     v  := (v / (pn.Weight - CurWei)) * hw;
     if (v > max)
     then begin
          max    := v;
          CutPt  := i;
          OptWei := CurWei;
     end {if (v > max)};
  end {for i := MinIdx to MaxIdx};
  inc(CutPt);
  Move(pn, nBox1, sizeof(tBox));
  Move(pn, nBox2, sizeof(tBox));
  nBox1.Weight := OptWei;
  nBox2.Weight := nBox2.Weight - OptWei;
  if (nBox1.Weight = 0) OR (nBox2.Weight = 0)
  then begin
       exit;
  end;
  nBox1.High[RGB] := CutPt;
  nBox2.Low[RGB]  := CutPt;
  fillchar(nBox1.Freq[RedI],   sizeof(tFreqZeile), #0);
  fillchar(nBox1.Freq[GreenI], sizeof(tFreqZeile), #0);
  fillchar(nBox1.Freq[BlueI],  sizeof(tFreqZeile), #0);
  for r := nBox1.Low[RedI] to nBox1.High[RedI] - 1
  do begin
     rOff := r SHL Bits;
     for g := nBox1.Low[GreenI] to nBox1.High[GreenI] - 1
     do begin
        gOff := (rOff OR g) SHL Bits;
        for b := nBox1.Low[BlueI] to nBox1.High[BlueI] - 1
        do begin
           h := gOff OR b;
           myfreq := pHisto^[h];
           if (myfreq <> 0)
           then begin
                inc(nBox1.Freq[RedI,   r], myfreq);
                inc(nBox1.Freq[GreenI, g], myfreq);
                inc(nBox1.Freq[BlueI,  b], myfreq);
                dec(nBox2.Freq[RedI,   r], myfreq);
                dec(nBox2.Freq[GreenI, g], myfreq);
                dec(nBox2.Freq[BlueI,  b], myfreq);
           end;
        end ;
     end;
  end;
  for r := RedI to BlueI
  do begin
     l1 := ColorMaxI;
     l2 := ColorMaxI;
     h1 := 0;
     h2 := 0;
     for g := 0 to ColorMaxI - 1
     do begin
        if (nBox1.Freq[r, g] <> 0)
        then begin
             if (g < l1) then l1 := g;
             if (g > h1) then h1 := g;
        end {if (nBox1.Freq[r, g] <> 0)};
        if (nBox2.Freq[r, g] <> 0)
        then begin
             if (g < l2) then l2 := g;
             if (g > h2) then h2 := g;
        end {if (nBox1.Freq[r, g] <> 0)};
     end {for g := 0 to ColorMaxI};
     nBox1.Low[r]  := l1;
     nBox2.Low[r]  := l2;
     nBox1.High[r] := h1 + 1;
     nBox2.High[r] := h2 + 1;
  end;
  BoxStats(nBox1);
  BoxStats(nBox2);
  Result := true;
end {function FindCutPoint};
{----------------------------------------------	CutBox}
function CutBox(var pn, nBox1: tBox): boolean;
const
Hugo            = 1.7 * 10308;                  {MaxDouble}
var
i               : integer;
TotVar          : array[RedI..BlueI] of double;
nBoxes          : array[RedI..BlueI, 0..1] of tBox;
begin
  if (pn.WeiVar = 0.0) OR (pn.Weight = 0)
  then begin
       pn.WeiVar := 0.0;
       Result := false;
       exit;
  end else Result := true;
  for i := RedI to BlueI
  do begin
     if (FindCutPoint(pn, nBoxes[i, 0], nBoxes[i, 1], i))
     then TotVar[i] := nBoxes[i, 0].WeiVar + nBoxes[i, 1].WeiVar
     else TotVar[i] := Hugo;
  end;
  if  (TotVar[RedI] < Hugo)
  AND (TotVar[RedI] <= TotVar[GreenI])
  AND (TotVar[RedI] <= TotVar[BlueI])
  then begin
       Move((nBoxes[RedI, 0]), pn,    sizeof(tBox));
       Move((nBoxes[RedI, 1]), nBox1, sizeof(tBox));
       exit;
  end
  else if  (TotVar[GreenI] < Hugo)
  AND (TotVar[GreenI] <= TotVar[RedI])
  AND (TotVar[GreenI] <= TotVar[BlueI])
  then begin
       Move((nBoxes[GreenI, 0]), pn,    sizeof(tBox));
       Move((nBoxes[GreenI, 1]), nBox1, sizeof(tBox));
       exit;
  end
  else if  (TotVar[BlueI] < Hugo)
  then begin
       Move((nBoxes[BlueI, 0]), pn,    sizeof(tBox));
       Move((nBoxes[BlueI, 1]), nBox1, sizeof(tBox));
       exit;
  end;
  pn.WeiVar := 0.0;
  Result := false;
end;
{----------------------------------------------	CutBoxes}
function CutBoxes: integer;
var
CurBox, n, i    : integer;
Max             : single;
begin
  with pBoxArr^[0]
  do begin
     Low[RedI]    := 0;
     Low[GreenI]  := 0;
     Low[BlueI]   := 0;
     High[RedI]   := ColorMaxI;
     High[GreenI] := ColorMaxI;
     High[BlueI]  := ColorMaxI;
     Weight       := cHBRPix;
  end;
  BoxStats(pBoxArr^[0]);
  CurBox := 1;
  while (CurBox < cHBRCol)
  do begin
     n   := CurBox;
     max := 0.0;
     for i := 0 to CurBox - 1
     do with pBoxArr^[i]
     do begin
        if (WeiVar > Max)
        then begin
             Max := WeiVar;
             n   := i;
        end;
     end;
     if (n = CurBox) then break;
     if (CutBox(pBoxArr^[n], pBoxArr^[CurBox])) then inc(CurBox);
  end;
  Result := CurBox;
end {function CutBoxes};
{----------------------------------------------	MakeRGBmap}
function MakeRGBmap: boolean;
var
ProzFaktor      : single;
Proz            : integer;
i, p            : integer;
r, g, b         : integer;
rOff, gOff      : integer;
begin
  ProzFaktor := 100 / cHBROutCol;
  for i := 0 to cHBROutCol - 1
  do with pBoxArr^[i]
  do begin
     for r := Low[RedI] to High[RedI] - 1
     do begin
        rOff := r SHL Bits;
        for g := Low[GreenI] to High[GreenI] - 1
        do begin
           gOff := (rOff OR g) SHL Bits;
           for b := Low[BlueI] to High[BlueI] - 1
           do begin
              p := gOff OR b;
              pMap^[p] := i;
           end;
        end;
     end;
     {---------- MultiTasking}
     if (MulTa <> nil)
     then begin
          Proz := round(i * ProzFaktor);
          if TMultiTasking(MulTa)(DMG_Remap, Proz)
          then begin
               Result := false;
               exit;
          end {UserAbort};
     end {MultiTasking};
  end;
  Result := true;
end {function MakeRGBmap};
{----------------------------------------------	ChangeTheColors}
function ChangeTheColors: boolean;
var
qPtr            : pByte;
cqOffs          : longint;
zPtr            : pByte;
czOffs          : longint;
pQ              : pBGRArr;
Proz            : longint;
b, g, r         : integer;
y, x            : integer;
p               : integer;
begin
  ProzFaktor := 100 / DMCoSi.czHei;
  cqOffs := cHBRqBMI;
  czOffs := cHBRzBMI;
  pQ := pBGRArr(DMCoSi.pqBuf);
  for y := 0 to DMCoSi.czHei - 1
  do begin
     qPtr := pointer(pChar(DMCoSi.pqBMI) + cqOffs);
     inc(cqOffs, DMCoSi.cqLen);
     Move(qPtr^, DMCoSi.pqBuf^, DMCoSi.cqLen);
     for x := 0 to DMCoSi.czWid - 1
     do begin
        r := (pQ^[x, Rc]   AND $f8) SHL (Bits + Bits - cBits);
        g := (pQ^[x, Gc] AND $f8) SHL (Bits        - cBits);
        b := (pQ^[x, Bc]  AND $f8) SHR                cBits;
        p := r OR g OR b;
        pByteArray(DMCoSi.pzBuf)^[x] := pMap^[p];
     end;
     zPtr := pointer(pChar(DMCoSi.pzBMI) + czOffs);
     inc(czOffs, DMCoSi.czLen);
     Move(DMCoSi.pzBuf^, zPtr^, DMCoSi.czLen);
     {---------- MultiTasking}
     if (MulTa <> nil)
     then begin
          Proz := round(y * ProzFaktor);
          if TMultiTasking(MulTa)(DMG_ChgTo256, Proz)
          then begin
               Result := false;
               exit;
          end {UserAbort};
     end {MultiTasking};
  end;
  Result := true;
end {function ChangeTheColors};
{----------------------------------------------	GetHBRmem}
function GetHBRmem: boolean;
begin
  try
    GetMem(pHisto, sizeof(tHistogramm));
    GetMem(pBoxArr, sizeof(tBoxes));
    GetMem(pMap, sizeof(tRGBmap));
    fillchar(pHisto^, sizeof(tHistogramm), #0);
    fillchar(pBoxArr^, sizeof(tBoxes), #0);
    fillchar(pMap^, sizeof(tRGBmap), #0);
  except
    On EOutOfMemory do mg_LastError := MGERR_NOMEMORY;
  end;
  Result := mg_LastError = 0;
end {function GetHBRmem};
{----------------------------------------------	FreeHBRmem}
procedure FreeHBRmem;
begin
  if (pHisto <> nil)
  then begin
       FreeMem(pHisto);
       pHisto := nil;
  end;
  if (pBoxArr <> nil)
  then begin
       FreeMem(pBoxArr);
       pBoxArr := nil;
  end;
  if (pMap <> nil)
  then begin
       FreeMem(pMap);
       pMap := nil;
  end;
end {procedure FreeHBRmem};

function mg_TrueColorTo256(pBMI: pBitmapInfo): pBitmapInfo;
const
zBPP            = 8;
zFarben         = 1 SHL zBPP;
var
Palette         : pRGBQArray;
czDIB           : longint;
i               : integer;
bErg            : boolean;
begin
  Result := nil;
  mg_LastError := 0;
  if (pBMI = nil) then exit;                    {kein Bild da ???}
  fillchar(DMCoSi, sizeof(tDMCoSi), #0);
  pHisto  := nil;
  pBoxArr := nil;
  pMap    := nil;
  with DMCoSi
  do begin
     pqBMI := pBMI;
     with pqBMI^.bmiHeader
     do begin
        if (biBitCount <= 8)                    {kein TrueColor}
        then begin
             ExitCoSiProc(MGERR_NOTRUECOL);
             exit;
        end ;
        czWid := biWidth;
        czHei := biHeight;
        cHBRqBMI := sizeof(tBitmapInfoHeader);
        cqLen := mg_GetDIBSize(czWid, czHei, biBitCount) DIV czHei;
     end {with pqBMI^.bmiHeader};
     czDIB := mg_GetDIBSize(czWid, czHei, zBPP);
     cHBRzBMI := sizeof(tBitmapInfoHeader) + zFarben * sizeof(TRGBQuad);;
     czLen := czDIB DIV czHei;
     pzBMI := mg_SetupDIB(nil, czWid, czHei, czDIB, cHBRzBMI, zBPP);
     if (pzBMI = nil)
     then begin
          ExitCoSiProc(MGERR_NOMEMORY);
          exit;
     end;
     if not(GetCoSiBuf)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     cHBRPix := czWid;
     cHBRPix := cHBRPix * czHei;
     cHBRCol := zFarben;
     if not(GetHBRmem)
     then begin
          FreeHBRmem;
          ExitCoSiProc(mg_LastError);
          exit;
     end {Abort};
     if not(Histogramm)
     then begin
          FreeHBRmem;
          ExitCoSiProc(MGERR_CANCEL);
          exit;
     end {Abort};
     cHBROutCol := CutBoxes;
     Palette := pRGBQArray(pChar(pzBMI) + sizeof(TBitmapInfoHeader));
     for i := 0 to cHBROutCol - 1
     do with pBoxArr^[i]
     do begin
        Palette^[i].rgbRed   := round(Mean[RedI])   SHL cBits;
        Palette^[i].rgbGreen := round(Mean[GreenI]) SHL cBits;
        Palette^[i].rgbBlue  := round(Mean[BlueI])  SHL cBits;
        Palette^[i].rgbReserved := 0;
     end;
     if not(MakeRGBmap)
     then begin
          FreeHBRmem;
          ExitCoSiProc(MGERR_CANCEL);
          exit;
     end {Abort};
     bErg := ChangeTheColors;
     FreeHBRmem;
     if not(bErg)
     then begin
          ExitCoSiProc(MGERR_CANCEL);
          exit;
     end {Abort};
  end {with DMCoSi};
  ExitCoSiProc(0);
  Result := DMCoSi.pzBMI;
end {function mg_TrueColorTo256};

function mg_TrueColorToGrey(pBMI: pBitmapInfo): pBitmapInfo;
var
cqBMI           : longint;
cqOffs          : longint;
czBMI           : longint;
czDIB           : longint;
czOffs          : longint;
BPP             : longint;
qPtr            : pByte;                        {Zeiger auf 1 Quellpixel}
zPtr            : pByte;                        {Zeiger auf 1 Zielpixel}
pQ              : pBGRArr;
y, x            : integer;
Proz            : longint;
Color           : byte;
b, g, r         : longint;
begin
  Result := nil;
  mg_LastError := 0;
  if (pBMI = nil) then exit;                    {kein Bild da ???}
  fillchar(DMCoSi, sizeof(tDMCoSi), #0);
  with DMCoSi
  do begin
     pqBMI := pBMI;
     with pqBMI^.bmiHeader
     do begin
        if (biBitCount <= 8)                    {kein TrueColor}
        then begin
             ExitCoSiProc(MGERR_NOTRUECOL);
             exit;
        end;
        czWid := biWidth;
        czHei := biHeight;
        BPP   := biBitCount;
        cqBMI := sizeof(tBitmapInfoHeader);
        cqLen := mg_GetDIBSize(czWid, czHei, BPP) DIV czHei;
     end {with pqBMI^.bmiHeader};
     BPP   := 8;
     czDIB := mg_GetDIBSize(czWid, czHei, BPP);
     czBMI := sizeof(tBitmapInfoHeader) + 256 * sizeof(TRGBQuad);;
     czLen := czDIB DIV czHei;
     pzBMI := mg_SetupDIB(nil, czWid, czHei, czDIB, czBMI, BPP);
     if (pzBMI = nil)
     then begin
          ExitCoSiProc(MGERR_NOMEMORY);
          exit;
     end;
     if not(GetCoSiBuf)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     for y := 0 to 255
     do with pzBMI^.bmiColors[y]
     do begin
        rgbRed   := y;
        rgbGreen := y;
        rgbBlue  := y;
        rgbReserved := 0;
     end;
     ProzFaktor := 100 / czHei;
     dec(czHei);
     dec(czWid);
     cqOffs := cqBMI;
     czOffs := czBMI;
     pQ := pBGRArr(pqBuf);
     for y := 0 to czHei
     do begin
        qPtr := pointer(pChar(pqBMI) + cqOffs);
        inc(cqOffs, cqLen);
        Move(qPtr^, pqBuf^, cqLen);
        for x := 0 to czWid
        do begin
           b := pQ^[x, Bc];
           g := pQ^[x, Gc];
           r := pQ^[x, Rc];
           Color := byte((r * 77 + g * 151 + b * 28) SHR 8);
           pByteArray(pzBuf)^[x] := Color;
        end;
        zPtr := pointer(pChar(pzBMI) + czOffs);
        inc(czOffs, czLen);
        Move(pzBuf^, zPtr^, czLen);
        {------- MultiTasking}
        if (MulTa <> nil)
        then begin
             Proz := round(y * ProzFaktor);
             if TMultiTasking(MulTa)(DMG_ChgToGray, Proz)
             then begin
                  ExitCoSiProc(MGERR_CANCEL);
                  exit;
             end {UserAbrot};
        end {MultiTasking};
     end;
  end {with DMCoSi};
  ExitCoSiProc(0);
  Result := DMCoSi.pzBMI;
end {function mg_TrueColorToGrey};
function mg_ExpandToTrueColor(pBMI: pBitmapInfo): pBitmapInfo;
var
cqBMI           : longint;
cqOffs          : longint;
czBMI           : longint;
czDIB           : longint;
czOffs          : longint;
BPP             : word;
qPtr            : pByte;                        {Zeiger auf 1 Quellpixel}
zPtr            : pByte;                        {Zeiger auf 1 Zielpixel}
pZ              : pBGRArr;
Palette         : pRGBQArray;
Proz            : longint;
x, y            : integer;
cqPix           : integer;
Pixel           : byte;                         {Index in Farbtabelle}
Maske           : byte;                         {Default-Pixelmaske}
cqmask, czmask  : byte;                         {Quell- und Zielmaske}
maskq           : byte;                         {Hilfsmaske}
begin
  Result := nil;
  fillchar(DMCoSi, sizeof(tDMCoSi), #0);
  mg_LastError := 0;
  if (pBMI = nil) then exit;                    {kein Bild da ???}
  with DMCoSi
  do begin
     DMCoSi.pqBMI := pBMI;
     with pqBMI^.bmiHeader
     do begin
        BPP := biBitCount;
        if (BPP > 8)
        then begin
             ExitCoSiProc(MGERR_ISTRUECOL);
             exit;
        end;
        Maske  := 0;
        czmask := 0;
        case BPP of
          1 : begin
                Maske  := $80;
                czmask := $01;
              end;
          2 : begin
                Maske  := $c0;
                czmask := $03;
              end;
          4 : begin
                Maske  := $f0;
                czmask := $0f;
              end;
        end {case BPP of};
        czWid   := biWidth;
        czHei   := biHeight;
        cqLen   := mg_GetDIBSize(czWid, czHei, BPP) DIV biHeight;
        cqBMI   := sizeof(TBitmapInfoHeader) + mg_GetPaletteSize(pqBMI);
        Palette := pointer(pChar(pqBMI) + sizeof(TBitmapInfoHeader));
     end {with pqBMI^.bmiHeader};
     czBMI := sizeof(TBitmapInfoHeader);
     czDIB := mg_GetDIBSize(czWid, czHei, 24);
     czLen := czDIB DIV czHei;
     pzBMI := mg_SetupDIB(nil, czWid, czHei, czDIB, czBMI, 24);
     if (pzBMI = nil)
     then begin
          ExitCoSiProc(MGERR_NOMEMORY);
          exit;
     end;
     if not(GetCoSiBuf)
     then begin
          ExitCoSiProc(mg_LastError);
          exit;
     end;
     ProzFaktor := 100 / czHei;
     dec(czWid);
     dec(czHei);
     cqOffs := cqBMI;
     czOffs := czBMI;
     pZ := pBGRArr(pzBuf);
     case BPP of
       8:
       for y := 0 to czHei
       do begin
          qPtr := pointer(pChar(pqBMI) + cqOffs);
          inc(cqOffs, cqLen);
          Move(qPtr^, pqBuf^, cqLen);
          for x := 0 to czWid
          do begin
             Pixel := pByteArray(pqBuf)^[x];
             pZ^[x, Bc]  := Palette^[Pixel].rgbBlue;
             pZ^[x, Gc] := Palette^[Pixel].rgbGreen;
             pZ^[x, Rc]   := Palette^[Pixel].rgbRed;
          end;
          zPtr := pointer(pChar(pzBMI) + czOffs);
          inc(czOffs, czLen);
          Move(pzBuf^, zPtr^, czLen);
          {----- MultiTasking}
          if (MulTa <> nil)
          then begin
               Proz := round(y * ProzFaktor);
               if TMultiTasking(MulTa)(DMG_ExpToTrue, Proz)
               then begin
                    ExitCoSiProc(MGERR_CANCEL);
                    exit;
               end {UserAbort};
          end {MultiTasking};
       end {256 Colors};

       1, 2, 4:
       for y := 0 to czHei
       do begin
          qPtr := pointer(pChar(pqBMI) + cqOffs);
          inc(cqOffs, cqLen);
          Move(qPtr^, pqBuf^, cqLen);
          cqPix  := 0;
          cqmask := Maske;
          for x := 0 to czWid
          do begin
             Pixel := pByteArray(pqBuf)^[cqPix] AND cqmask;
             if (Pixel <> 0)
             then if (cqmask <> czmask)
             then begin
                  maskq := cqmask;
                  while (maskq <> czmask)
                  do begin
                     Pixel := Pixel SHR BPP;
                     maskq := maskq SHR BPP;
                  end;
             end;
             cqmask := cqmask SHR BPP;
             if (cqmask = 0)
             then begin
                  cqmask := Maske;
                  inc(cqPix);
             end;
             pZ^[x, Bc] := Palette^[Pixel].rgbBlue;
             pZ^[x, Gc] := Palette^[Pixel].rgbGreen;
             pZ^[x, Rc] := Palette^[Pixel].rgbRed;
          end;
          zPtr := pointer(pChar(pzBMI) + czOffs);
          inc(czOffs, czLen);
          Move(pzBuf^, zPtr^, czLen);
          {----- MultiTasking}
          if (MulTa <> nil)
          then begin
               Proz := round(y * ProzFaktor);
               if TMultiTasking(MulTa)(DMG_ExpToTrue, Proz)
               then begin
                    ExitCoSiProc(MGERR_CANCEL);
                    exit;
               end {UserAbort};
          end {MultiTasking};
       end;
     end {case BPP of};
  end {with DMCoSi};
  ExitCoSiProc(0);
  Result := DMCoSi.pzBMI;
end {function mg_ExpandToTrueColor};

end.
