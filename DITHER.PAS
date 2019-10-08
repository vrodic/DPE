unit Dither;

Interface

uses Windows,Graphics;

{==============================================	exported Color-Functions}
function TrueColorTo256(pBMI: TBitmap) : tbitmap;
procedure DitherSetTheCallBack(CallBack: tFarProc);

Implementation

uses Colorman, SysUtils;

{----------------------------------------------	StandardErrors}
const
ERR_CANCEL    = 128;
ERR_NOMEMORY  = 139;
{----------------------------------------------	DIB-Palette}
{----------------------------------------------	MultiTasking-Function}
{ wMsg      : DMG_xxx-Constant                }
{ cProgress : progress in percent             }
type
tDitherProgress   = function(cProgress: longint): boolean;

{----------------------------------------------	Bitmaps }
var
pqBitmap       : TBitmap;
pzBitmap       : TBitmap;

{---------------------------------------------- MultiTasking}
MultiTask           : TFarProc;
LastError : word;

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
cHBROutCol      : longint;

{==============================================	Functions for TrueColorTo256}

{----------------------------------------------	Histogramm}
function Histogramm: boolean;
var  p24 : PRGBByteArray;
     h               : integer;
     Percent         : integer;
     r, g, b         : byte;
     y, x            : integer;
     PercentFactor   : single;
begin
  with pBoxArr^[0]
  do begin
     fillchar(Freq[RedI],   sizeof(tFreqZeile), #0);
     fillchar(Freq[GreenI], sizeof(tFreqZeile), #0);
     fillchar(Freq[BlueI],  sizeof(tFreqZeile), #0);
     PercentFactor := 100 / pzBitmap.Height;
     for y := 0 to pzBitmap.Height - 1
     do begin
        p24 := pqBitmap.Scanline[y];
        for x := 0 to pzBitmap.Width - 1
        do begin
           r := p24[x].Red SHR cBits;
           inc(Freq[RedI, r]);
           g := p24[x].Green SHR cBits;
           inc(Freq[GreenI, g]);
           b := p24[x].Blue SHR cBits;
           inc(Freq[BlueI, b]);
           h := r SHL Bits;
           h := (h OR g) SHL Bits;
           h := h OR b;
           inc(pHisto^[h]);
        end;
        if (MultiTask <> nil)
        then begin
             Percent := round(y * PercentFactor);
             if TDitherProgress(MultiTask)(Percent)
             then begin
                  LastError := ERR_CANCEL;
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
     if (MultiTask <> nil)
     then begin
          Proz := round(i * ProzFaktor);
          if TDitherProgress(MultiTask)(Proz)
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
var p24           : PRGBByteArray;
    p8            : PByteArray;
    Proz          : longint;
    b, g, r       : integer;
    y, x          : integer;
    p             : integer;
    PercentFactor : single;
begin
  PercentFactor := 100 / pzBitmap.Height;
  for y := 0 to pzBitmap.Height - 1
  do begin
     p24 := pqBitmap.Scanline[y];
     p8 :=  pzBitmap.Scanline[y];
     for x := 0 to pzBitmap.Width - 1
     do begin
        r := (p24[x].Red   AND $f8) SHL (Bits + Bits - cBits);
        g := (p24[x].Green AND $f8) SHL (Bits        - cBits);
        b := (p24[x].Blue  AND $f8) SHR                cBits;
        p := r OR g OR b;
        p8[x] := pmap^[p];
     end;
     {---------- MultiTasking}
     if (MultiTask <> nil)
     then begin
          Proz := round(y * PercentFactor);
          if TDitherProgress(MultiTask)(Proz)
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
    On EOutOfMemory do LastError := ERR_NOMEMORY;
  end;
  Result := LastError = 0;
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

function TrueColorTo256(pBMI: TBitmap) : tbitmap;
const zColor = 1 SHL 8;
var Pal      : TMaxLogPalette;
    PalEntry : TPaletteEntry;
    i        : integer;
    bErg     : boolean;
begin
   LastError := 0;
   pHisto  := nil;
   pBoxArr := nil;
   pMap    := nil;
   pqBitmap := pBMI;
   with pqBitmap
   do begin
      if not (PixelFormat = pf24bit)
      then begin
           raise Exception.Create('Image is not 24 bit image');
           exit;
      end ;
   end {with pqBMI^.bmiHeader};
   pzBitmap := TBitmap.Create;
   pzBitmap.PixelFormat := pf8bit;
   pzBitmap.Width := pqBitmap.Width;
   pzBitmap.Height := pqBitmap.Height;
   cHBRPix := pqBitmap.Width;
   cHBRPix := cHBRPix * pqBitmap.Height;
   cHBRCol := zColor;
   if not(GetHBRmem)
   then begin
        FreeHBRmem;
        raise exception.Create('Error on memory alloc!');
        exit;
   end {Abort};
   if not(Histogramm)
   then begin
        FreeHBRmem;
        raise exception.Create('Canceled!');
        exit;
   end {Abort};
   cHBROutCol := CutBoxes;
   pal.palVersion := $300;
   pal.palNumEntries := cHBROutCol;
   for i := 0 to cHBROutCol - 1
   do with pBoxArr^[i]
   do begin
      Palentry.peRed := round(Mean[RedI])   SHL cBits;
      Palentry.peGreen := round(Mean[GreenI]) SHL cBits;
      Palentry.peBlue  := round(Mean[BlueI])  SHL cBits;
      Palentry.peFlags := 0;
      pal.PalPalEntry[i] := palentry;
   end;
   pzBitmap.Palette := CreatePalette(PLogPalette(@Pal)^);
   if not(MakeRGBmap)
   then begin
        FreeHBRmem;
        raise exception.Create('Canceled!');
        exit;
   end {Abort};
   bErg := ChangeTheColors;
   FreeHBRmem;
   if not(bErg)
   then begin
        raise exception.Create('Canceled!');
        exit;
   end {Abort};
   Result := pzBitmap;
// !! Maybe I need to free something ??
end {function TrueColorTo256};

procedure DitherSetTheCallBack(CallBack: tFarProc);
begin
  MultiTask := CallBack;
end {procedure mg_SetTheCallBack};


end.
