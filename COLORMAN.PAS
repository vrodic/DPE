unit ColorMan;

interface

uses Windows, SysUtils, Graphics,math; {location of TColor def}

TYPE
  TTrueColor = record
     Blue : byte;
     Green : byte;
     Red : Byte;
  end;
  THSVColor = record
     H : integer;
     S : byte;
     V : byte;
  end;
  TCMYKColor = record
     C : byte;
     M : byte;
     Y : byte;
     K : byte;
  end;
  PRGBByteArray = ^TRGBByteArray;
  TRGBByteArray = array[0..32767] of TTrueColor;

function BrightenColor(BaseColor: TTrueColor; Adjust : Integer): TTrueColor;
  //Convert the BaseColor to the Grade of Adjust Brighten Color
function DarkenColor(BaseColor: TTrueColor; Adjust : Integer): TTrueColor;
  //Convert the BaseColor to the Grade of Adjust Darken Color
function ColorToGrey(SC : TTrueColor) : TTrueColor;
function SingleToGrey(SC : TTrueColor) : byte;
function RGBTC(R,G,B : Byte) : TTrueColor;
function Colorise(SC, MC : TTrueColor) : TTrueColor; //Convert the SC to MC Color
function ERGB(R,G,B : Real) : TTrueColor; //Error RGB Color
function CorrectColor(C : Real) : Integer; //Correct the Wrong Color Byte
function MergeColor(C1, C2 : TTrueColor) : TTrueColor; //Merge Two Color to One
function MiscColor(var C : Variant) : TTrueColor; //Misc A Number of Colors To One
function MiscBmpToColor(Bitmap : TBitmap; W, H : Integer; A : TRect) : TTrueColor;
//Misc A Whole BMP to One Color
function IsGreyColor(C : TTrueColor) : Boolean; //Check if the Color is grey color
function IsLightColor(C : TTrueColor) : Boolean; //Check if the Color is Light Color

{Added 19-March-1997}
function RGBAvg(C : TTrueColor) : Integer;
function SumRGB(C : TTrueColor) : Integer;
function CompareR(C1, C2 : TTrueColor) : Integer;
function CompareG(C1, C2 : TTrueColor) : Integer;
function CompareB(C1, C2 : TTrueColor) : Integer;
function CompareColor(C1, C2 : TTrueColor) : Integer;

function ColorMod(C1 : TTrueColor; R,G,B : Integer) : TTrueColor;
//function ColorAdd(C1, C2 : TTrueColor) : TTrueColor;
//function ColorMinus(C1, C2 : TTrueColor) : TTrueColor;

function InvertColor(C: TTrueColor) : TTrueColor;
function CentreRGB(C : TTrueColor; Percent : Integer) : TTrueColor;

// 10 July 1997
function MergeColorExt(C1, C2 : TTrueColor; Grade: Byte) : TTrueColor;
{Color Conversions} // !NEW
function HSVTC(H, S, V : integer) : THSVColor;
PROCEDURE HLStoRGB (CONST H,L,S:  INTEGER;    {h IN 0..359; l,s IN 0..255}
                    VAR   RGB:  TTrueColor);  {r, g and b IN [0..255]}
function HSVtoRGB (HSV: THSVColor) :TTrueColor;
function CMYKtoRGB (CMYK : TCMYKColor) : TTrueColor;

FUNCTION RGBIntensity(CONST RGB:  TTrueColor):  INTEGER;
FUNCTION RGBLightness(CONST RGB:  TTrueColor):  INTEGER;
FUNCTION RGBSaturation(CONST RGB:  TTrueColor):  INTEGER;
FUNCTION RGBValue(CONST RGB:  TTrueColor):  INTEGER;
PROCEDURE RGBtoHLS (CONST RGB:    TTrueColor; {r, g and b IN [0..255]}
                    VAR   H,L,S:  integer);   {h IN 0..359; l,s IN 0..255}
function RGBtoHSV (CONST RGB:    TTrueColor) :  THSVColor;
function ColorHSVMod(C1 : THSVColor; h,s,v : integer): THSVColor;
function RGBtoCMYK (CONST RGB : TTrueColor)  : TCMYKColor;
//function Max(X, Y: Integer): Integer;

implementation

PROCEDURE MinMax3(CONST i,j,k:  INTEGER; VAR min, max:  INTEGER);
BEGIN
    IF   i > j
    THEN BEGIN
      IF   i > k
      THEN max := i
      ELSE max := k;

      IF   j < k
      THEN min := j
      ELSE min := k
    END
    ELSE BEGIN
      IF   j > k
      THEN max := j
      ELSE max := k;

      IF   i < k
      THEN min := i
      ELSE min := k
   END
END {MinMax3};

function Min(X, Y: Integer): Integer;
begin
	if X < Y then Result := X else Result := Y;
end;

function Max(X, Y: Integer): Integer;
begin
	if X > Y then Result := X else Result := Y;
end;

function RGBTC(R, G, B : Byte) : TTrueColor;
begin
Result.Red := R;
Result.Green := G;
Result.Blue := B;
end;

function CentreRGB(C : TTrueColor; Percent : Integer) : TTrueColor;
var
  Avg : Integer;
  R, G, B : Integer;
begin
  Avg := RGBAvg(C);
  R := C.Red;
  G := C.Green;
  B := C.Blue;
  R := R - (R - Avg) * Percent;
  G := G - (G - Avg) * Percent;
  B := B - (B - Avg) * Percent;
  Result.Red := R;
  Result.Green := G;
  Result.Blue := B;
end;

function InvertColor(C: TTrueColor) : TTrueColor;
begin
  Result.Red := NOT(C.Red);
  Result.Green := NOT(C.Green);
  Result.Blue := NOT(C.Blue);
end;

function CorrectIColor(C : Integer) : Integer;
begin
  Result := C;
  if Result > 255 then Result := 255;
  if Result < 0 then Result := 0;
end;

function IRGB(R,G,B : Integer) : TTrueColor;
begin
	Result.Red := CorrectIColor(R);
        Result.Green := CorrectIColor(G);
        Result.Blue := CorrectIColor(B);
end;

function ColorMod(C1 : TTrueColor; R,G,B : Integer) : TTrueColor;
begin
  Result := IRGB(C1.Red + R, C1.Green + G,
    C1.Blue + B);
end;

{function ColorAdd(C1, C2 : TTrueColor) : TTrueColor;
begin
  Result := IRGB(C1.Red + C2.Red, C1.Green + C2.Green,
    C1.Blue + C2.Blue);
end;}

{function ColorMinus(C1, C2 : TTrueColor) : TTrueColor;
begin
  Result := IRGB(C1.Red - C2.Red, C1.Green - C2.Green,
    C1.Blue - C2.Blue);
end;}

function CompareR(C1, C2 : TTrueColor) : Integer;
begin
  Result := C1.Red - C2.Red;
end;

function CompareG(C1, C2 : TTrueColor) : Integer;
begin
  Result := C1.Green - C2.Green;
end;

function CompareB(C1, C2 : TTrueColor) : Integer;
begin
  Result := C1.Blue - C2.Blue;
end;

function CompareColor(C1, C2 : TTrueColor) : Integer;
begin
  Result := RGBAvg(C1) - RGBAvg(C2);
end;

function SumRGB(C : TTrueColor) : Integer;
begin
  Result := C.Red + C.Green + C.Blue;
end;

function RGBAvg(C : TTrueColor) : Integer;
begin
  Result := SumRGB(C) div 3;
end;

function IsLightColor(C : TTrueColor) : Boolean;
var
	Count : Integer;
begin
  Count := 0;
  // Check if any of these value is more than a half of 255
  C := ColorToGrey(C);
	if C.Red < 96 then Count := Count + 1;
	if C.Green < 96 then Count := Count + 1;
	if C.Blue < 96 then Count := Count + 1;

  {-------------------------------------------
  |   0      |---|---|---|---|     255       |
  |   Black                        White     |
  -------------------------------------------}

  if Count > 1 then
    Result := False
  else
    Result := True;
end;


function IsGreyColor(C : TTrueColor) : Boolean;
begin
  {A Grey Color is combined with eque R,G,B Value}
	{Check if Red = Green, Blue = Green }
	if (C.Red = C.Green) and (C.Blue = C.Green) then
  	Result := True
  else
  	Result := False;
end;

{
This function is written after the MiscColor, because I thought the Variant
Parameter Make the tranfering too slow.
}

function MiscBmpToColor(Bitmap : TBitmap; W, H : Integer; A : TRect) : TTrueColor;
var
  C : TTrueColor;
  k, i, j : Integer;
  pR, pG, pB : LongInt;
  P24 : PRGBByteArray;
begin
  K := 0; pR := 0; pG := 0; pB := 0;
  for i := A.Top to A.Bottom do
  begin
  P24 := Bitmap.ScanLine[i];
    for j := A.Left to A.Right do
    begin
     	if not ((j < 0) or (i <= 0) or (j > W) or (i > H)) then
        begin
      	  C := P24[j];
          Inc(pR, C.Red);
          Inc(pG, C.Green);
          inc(pB, C.Blue);
          k := k + 1;
        end;
    end;
  end;
  pR := Round( pR / k );
  pB := Round( pB / k );
  pG := Round( pG / k );
  Result := RGBTC(pR, pG, pB);
end;

function MergeColor(C1, C2 : TTrueColor) : TTrueColor;
begin
	MergeColorExt(C1, C2, 50);
end;

function MergeColorExt(C1, C2 : TTrueColor; Grade: Byte) : TTrueColor;
var pR, pG, pB : Real;
begin
  pR := (C1.Red * Grade / 100 + C2.Red * (100-Grade) / 100);
  pG := (C1.Green * Grade / 100 + C2.Green * (100-Grade) / 100);
  pB := (C1.Blue * Grade / 100 + C2.Blue * (100-Grade) / 100);
  Result := ERGB(pR, pG, pB);
end;

function MiscColor(var C : Variant) : TTrueColor;
var
	pR, pG, pB : LongInt;
  Count, i, l, h : Integer;
begin
  l := VarArrayLowBound	(C, 1);
  h := VarArrayHighBound (C, 1);
  Count := h - l + 1;
  pR := 0; pG := 0; pB := 0;
  for i := l to h do
  begin
  	pR := pR + GetRValue(C[i]);
  	pG := pG + GetGValue(C[i]);
  	pB := pB + GetBValue(C[i]);
  end;
  pR := Round( pR / Count );
  pB := Round( pB / Count );
  pG := Round( pG / Count );
  Result.Red := pR;
  Result.Green := pG;
  Result.Blue := pB;
end;

function CorrectColor(C : Real) : Integer;
begin
  Result := Round(C);
  if Result > 255 then Result := 255;
  if Result < 0 then Result := 0;
end;

function ERGB(R,G,B : Real) : TTrueColor;
begin
	Result.Red := CorrectColor(R);
        Result.Green := CorrectColor(G);
        Result.Blue := CorrectColor(B);
end;

function Colorise(SC, MC : TTrueColor) : TTrueColor;
var pR, pG, pB : Real;
begin
  // take the each percentage of r, g, b in the given color
  pR := MC.Red / 255 + 1;
  pG := MC.Green / 255 + 1;
  pB := MC.Blue / 255 + 1;
  Result := ColorToGrey(SC);
  Result := ERGB(pR * Result.Red, pG * Result.Green, pB * Result.Blue);
end;

function ColorToGrey(SC : TTrueColor) : TTrueColor;
var avg : Integer;
begin
  avg := Round((SC.Red * 20 + SC.Green * 50 + SC.Blue*30)/100);
  Result.Red := avg;
  Result.Green := avg;
  Result.Blue := avg;
end;

function SingleToGrey(SC : TTrueColor) : byte;
begin
  Result := Round((SC.Red * 20 + SC.Green * 50 + SC.Blue*30)/100);
end;

function BrightenColor(BaseColor: TTrueColor; Adjust : Integer): TTrueColor;
begin
  Result.Red := Min(BaseColor.Red + Adjust, 255);
  Result.Green := Min(BaseColor.Green + Adjust, 255);
  Result.Blue := Min(BaseColor.Blue + Adjust, 255);
end;

function DarkenColor(BaseColor: TTrueColor; Adjust : Integer): TTrueColor;
begin
  Result.Red := Max(BaseColor.Red - Adjust, 0);
  Result.Green := Max(BaseColor.Green - Adjust, 0);
  Result.Blue := Max(BaseColor.Blue - Adjust, 0);
end;


FUNCTION RGBTriple(CONST vred, vgreen, vblue:  BYTE):  TTrueColor;
BEGIN
    WITH RESULT DO
    BEGIN
      Red   := red;
      Green := green;
      Blue  := blue
    END
END {RGBTriple};


PROCEDURE AssignRGBTriple (VAR TargetTriple:  TTrueColor;
                             CONST OriginTriple:  TTrueColor);
BEGIN
    TargetTriple.Red   := OriginTriple.Red;
    TargetTriple.Green := OriginTriple.Green;
    TargetTriple.Blue  := OriginTriple.Blue
END {AssignRGBTriple};

  {==  Color Conversions  =============================================}

  {HSV to RGB.
    H = 0 to 359 (corresponding to 0..359 degrees around hexcone)
    S = 0 (shade of gray) to 255 (pure color)
    V = 0 (black) to 255 {white)

    Based on C Code in "Computer Graphics -- Principles and Practice,"
    Foley et al, 1996, p. 594.  Floating point fractions, 0..1, replaced with
    integer values, 0..255.
  }
PROCEDURE HLStoRGB (CONST H,L,S:  INTEGER;    {h IN 0..359; l,s IN 0..255}
                      VAR   RGB:  TTrueColor);  {r, g and b IN [0..255]}
BEGIN

END {HLStoRGB};


  {HSV to RGB.
    H = 0 to 359 (corresponding to 0..359 degrees around hexcone)
    S = 0 (shade of gray) to 255 (pure color)
    V = 0 (black) to 255 {white)

    Based on C Code in "Computer Graphics -- Principles and Practice,"
    Foley et al, 1996, p. 594.  Floating point fractions, 0..1, replaced with
    integer values, 0..255.
  }

function HSVtoRGB (HSV: THSVColor) :TTrueColor;
CONST divisor:  INTEGER = 255*60;
VAR   f    :  INTEGER;
      hTemp:  INTEGER;
      p,q,t:  INTEGER;
      VS   :  INTEGER;
BEGIN
    IF   hsv.s = 0
    THEN AssignRGBTriple(Result, RGBTC(hsv.v,hsv.v,hsv.v))  {Achromatic:  shades of gray}
    ELSE BEGIN
      IF   hsv.H = 360
      THEN hTemp := 0
      ELSE hTemp := hsv.H;
      f := hTemp MOD 60;
      hTemp := hTemp DIV 60;   {h is now IN [0,6)}
      VS := hsv.V*hsv.S;
      p := hsv.V - VS DIV 255;
      q := hsv.V - (VS*f) DIV divisor;
      t := hsv.V - (VS*(60 - f)) DIV divisor;
      WITH Result DO
      BEGIN
        CASE hTemp OF
          0:  BEGIN  Red := hsv.V;  Green := t;  Blue := p  END;
          1:  BEGIN  Red := q;  Green := hsv.V;  Blue := p  END;
          2:  BEGIN  Red := p;  Green := hsv.V;  Blue := t  END;
          3:  BEGIN  Red := p;  Green := q;  Blue := hsv.V  END;
          4:  BEGIN  Red := t;  Green := p;  Blue := hsv.V  END;
          5:  BEGIN  Red := hsv.V;  Green := p;  Blue := q  END;
        END
      END
    END
END {HSVtoRGB};


  {See [Russ95, p. 41]}
FUNCTION RGBIntensity(CONST RGB:  TTrueColor):  INTEGER;
BEGIN
    WITH RGB DO
      RESULT := (Red + Green + Blue) DIV 3
END {RGBIntensity};


  {See [Foley96, p. 595]}
FUNCTION RGBLightness(CONST RGB:  TTrueColor):  INTEGER;
VAR
      min:  INTEGER;
      max:  INTEGER;
BEGIN
    WITH RGB DO
      MinMax3(Red, Green, Blue, min, max);
    RESULT := (min + max) DIV 2
END {RGBLightness};


  {See [Foley96, p. 592]}
FUNCTION RGBSaturation(CONST RGB:  TTrueColor):  INTEGER;
VAR MaxValue:  INTEGER;
    MinValue:  INTEGER;
BEGIN
     WITH RGB DO
       MinMax3(Red, GReen, Blue, MinValue, MaxValue);

    {Calculate saturation:  saturation is 0 if r, g and b are all 0}
    IF   MaxValue = 0
    THEN RESULT := 0
    ELSE RESULT := (255 * (MaxValue - MinValue)) DIV MaxValue;
END {RGBSaturation};


  {See [Foley96, p. 592]}
FUNCTION RGBValue(CONST RGB:  TTrueColor):  INTEGER;
BEGIN
    WITH RGB DO
      RESULT := MaxIntValue( [Red, Green, Blue] )
END {RGBValue};


  {RGB, each 0 to 255, to HLS.
   H = 0 to 359 (corresponding to 0..359 degrees around hexcone)
   S = 0 (shade of gray) to 255 (pure color)
   S = 0 (black) to 255 {white)

   Based on C Code in "Computer Graphics -- Principles and Practice,"
   Foley et al, 1996, p. 595.  Floating point fractions, 0..1, replaced with
   integer values, 0..255.
  }

PROCEDURE RGBtoHLS (CONST RGB:    TTrueColor; {r, g and b IN [0..255]}
                      VAR   H,L,S:  INTEGER);   {h IN 0..359; l,s IN 0..255}
VAR   Delta   :  INTEGER;
      MaxValue:  INTEGER;
      MinValue:  INTEGER;
BEGIN
    WITH RGB DO
      MinMax3(Red, Green, Blue, MinValue, MaxValue);

    L := (MaxValue + MinValue) DIV 2;   {Lightness}

    IF   MaxValue = MinValue   {Achromatic case since r = g = b}
    THEN BEGIN
      S := 0;
      H := 0;     {Use 0 for undefined value}
    END
    ELSE BEGIN
      Delta := MaxValue - MinValue;

      IF   L <= 128
      THEN S := 255*Delta DIV (MaxValue + MinValue)
      ELSE S := 255*Delta DIV (510 - (MaxValue + MinValue));

      WITH RGB DO
      BEGIN
        IF   Red = MaxValue
        THEN H := (60*(Green-Blue)) DIV Delta            {degrees -- between yellow and magenta}
        ELSE
          IF   Green = MaxValue
          THEN H := 120 + (60*(Blue-Red)) DIV Delta      {degrees -- between cyan and yellow}
          ELSE
            IF  Blue = MaxValue
            THEN H := 240 + (60*(Red-Green)) DIV Delta;  {degrees -- between magenta and cyan}
      END;
      IF   H < 0
      THEN H := H + 360;
    END
END {oHLS};


  {RGB, each 0 to 255, to HSV.
   H = 0 to 359 (corresponding to 0..359 degrees around hexcone)
   S = 0 (shade of gray) to 255 (pure color)
   V = 0 (black) to 255 {white)

   Based on C Code in "Computer Graphics -- Principles and Practice,"
   Foley et al, 1996, p. 592.  Floating point fractions, 0..1, replaced with
   integer values, 0..255.
  }

function RGBtoHSV (CONST RGB:    TTrueColor) :  THSVColor;
VAR   Delta   :  INTEGER;
      MinValue:  INTEGER;
      h,s,v :  integer;
BEGIN
    WITH RGB DO
      MinMax3(Red, Green, Blue, MinValue, V);
    Delta := V - MinValue;

    {Calculate saturation:  saturation is 0 if r, g and b are all 0}
    IF   V = 0
    THEN S := 0
    ELSE S := (255 * Delta) DIV V;

    IF   S = 0
    THEN H := 0   {Achromatic:  When s = 0, h is undefined but assigned the value 0}
    ELSE BEGIN    {Chromatic}

      WITH RGB DO
      BEGIN
        IF   Red = V
        THEN H := (60*(Green-Blue)) DIV Delta            {degrees -- between yellow and magenta}
        ELSE
          IF   Green = V
          THEN H := 120 + (60*(Blue-Red)) DIV Delta      {degrees -- between cyan and yellow}
          ELSE
            IF  Blue = V
            THEN H := 240 + (60*(Red-Green)) DIV Delta;  {degrees -- between magenta and cyan}
      END;

      IF   H < 0
      THEN H := H + 360;
    END;
    Result := HSVTC(h,s,v);
END {oHSV};

function HSVTC(H, S, V : integer) : THSVColor;
begin
  Result.H := H;
  Result.S := S;
  Result.V := V;
end;

function CorrectHColor(C : Integer) : Integer;
begin
  Result := C;
  if Result > 359 then Result := 359;
  if Result < 0 then Result := 0;
end;

function IHSV(H,S,V : Integer) : THSVColor;
begin
	Result.H := CorrectHColor(H);
        Result.S := CorrectIColor(S);
        Result.V := CorrectIColor(V);
end;

function ColorHSVMod(C1 : THSVColor;h,s,v : integer) : THSVColor;
begin
  Result := IHSV(C1.H + H, C1.S + S,
    C1.V + V);
end;

function CMYKtoRGB (CMYK : TCMYKColor) : TTrueColor;
begin
   if (Integer(CMYK.C) + Integer(CMYK.K)) < 255 then
     Result.Red := 255 - (CMYK.C + CMYK.K) else
     Result.Red := 0;
   if (Integer(CMYK.M) + Integer(CMYK.K)) < 255 then
     Result.Green := 255 - (CMYK.M + CMYK.K) else
     Result.Green := 0;
   if (Integer(CMYK.Y) + Integer(CMYK.K)) < 255 then
     Result.Blue := 255 - (CMYK.Y + CMYK.K) else
     Result.Blue := 0;
end;

function RGBtoCMYK (CONST RGB : TTrueColor)  : TCMYKColor;
begin
  Result.C := 255 - RGB.Red;
  Result.M := 255 - RGB.Green;
  Result.Y := 255 - RGB.Blue;
  if Result.C < Result.M then
    Result.K := Result.C else
    Result.K := Result.M;
  if Result.Y < Result.K then
    Result.K := Result.Y;
  if Result.k > 0 then begin
    Result.c := Result.c - Result.k;
    Result.m := Result.m - Result.k;
    Result.y := Result.y - Result.k;
  end;
end;

procedure ColorCorrectCMYK(var CMYK : TCMYKColor);
var
  MinColor : byte;
begin
  if CMYK.C < CMYK.M then
    MinColor := CMYK.C else
    MinColor := CMYK.M;
  if CMYK.Y < MinColor  then
    MinColor := CMYK.Y;
  if MinColor + CMYK.K > 255 then
    MinColor := 255 - CMYK.K;
  CMYK.C := CMYK.C - MinColor;
  CMYK.M := CMYK.M - MinColor;
  CMYK.Y := CMYK.Y - MinColor;
  CMYK.K := CMYK.K + MinColor;
end;

end.

