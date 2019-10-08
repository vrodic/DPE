unit photo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls,ColorMan,Dither,bmp2gif;

type
  TDrawingTool = (dtLine, dtRectangle, dtEllipse, dtRoundRect);
  TFPhoto = class(TForm)
    Photo: TImage;
    { Graphics Functions }
    procedure ClearBitmap;
    procedure AddBorders(TopA, BottomA, LeftA, RightA : integer);
    procedure InvertBitmap;
    procedure Solarize(Threshold : byte);
    procedure GreyBitmap;
    procedure DitherTo8Bit;
    procedure RGBAdjustColor(R,G,B : integer;forreel : boolean);
    procedure HSVAdjustColor(H,S,V : Integer;forreel : boolean);
    procedure RotateBitmap(Angle : integer{; autosize : boolean});
    //procedure AdequateSize(bitmap : TBitmap;fangle : double);
    procedure ResizeBitmap(xdim,ydim :Word);
    procedure ResampleBitmap(xdim,ydim : word ; FilterIndex : byte);
    procedure MirrorBitmap;
    procedure FlipBitmap;
    procedure SoftenBMP(Deep : integer);
    procedure SharpenImage;
    procedure ColoriseImage(R, G, B : Byte);
    procedure CoolColorThing;
    procedure ToXBit(FPixelFormat : TPixelFormat);
    procedure LoadPalette(FileName : string);
    procedure SavePalette(FileName : string);
    procedure GammaImage(AmountGamma : integer;forreel : boolean);
    procedure ApplyPalette(hpal : HPalette);
    procedure ResizeCanvas(width,height : word; center : boolean);
    procedure AlphaBlend(SRCBitmap : TBitmap; Grade : byte);
    procedure MakeButton(Border : Integer; Soft : Boolean);
    procedure ChangeContrast(value : integer; forreel : Boolean);
    procedure LightenAtXY(x,y : Integer);
    procedure DarkenAtXY(x,y : Integer);
    procedure SoftenAtXY(x,y : Integer);
    procedure DoUndoAtXY(x,y : integer);
    {------------------------------------------------}
    { Misc Functions }
    procedure FitImage(x,y: integer);
    procedure SaveImage;
    procedure SaveAsImage;
    procedure SaveUndo;
    procedure DoUndo;
    {----------------}
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PhotoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PhotoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PhotoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure SysMenuHint(var Message : TWMMenuSelect); message WM_MenuSelect;
  public
   Modified : Boolean;
   PhotoName : string;
   Saved : Boolean;
   UndoBitmap : TBitmap;
   UA : Boolean;
   Resized : Boolean; // prevents flicker on undo
   DrawingTool: TDrawingTool;
   Origin, MovePt: TPoint;
   procedure DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);

  end;

function PrepareGrayPalette : HPalette;
var
  FPhoto: TFPhoto;

const DefName = 'Image';
      UBASTR = 'You cannot use the eraser brush at this time.';
implementation

uses dpemform, newimg,Resample;
{$R *.DFM}
var
    PenTool : Boolean;
    Drawing : Boolean;
    FButton : TMouseButton;
    Dropper : Boolean;
    Lighten, Darken, Soften : Boolean;
    RetBMP : TBitmap;
    Mover : Boolean;
    Eraser : Boolean;
function PrepareGrayPalette : HPalette;
var Pal : TMaxLogPalette;
    PalEntry : TPaletteEntry;
    i : word;
begin
pal.palVersion := $300;
pal.palNumEntries := 256;
for i := 0 to 255 do
begin
     palentry.peRed := i;
     palentry.peGreen := i;
     palentry.peBlue := i;
     palentry.peFlags := 0;
     pal.PalPalEntry[i] := palentry;
end;
Result := CreatePalette(PLogPalette(@Pal)^);
end;

function Invert8bitPalette(HPal : HPalette) : HPalette;
var pal :TMaxLogPalette;
    PalEntry : TPaletteEntry;
    i : word;
begin
pal.palVersion := $300;
pal.palNumEntries := 256;
GetPaletteEntries(hpal,0,256,Pal.palpalentry);
for i := 0 to 255 do
begin
palentry := pal.palpalentry[i];
palentry.peRed := not palentry.peRed;
palentry.peGreen := not palentry.peGreen;
palentry.peBlue := not palentry.peBlue;
palentry.peFlags := 0;
pal.palpalentry[i] := palentry;
end;
Result := CreatePalette(PLogPalette(@Pal)^);
end;

procedure TFPhoto.SaveImage;
var FileExt : string[4];
begin
FileExt := ANSILowerCase(ExtractFileExt(PhotoName));
if (not Saved) or (FileExt = '.pcx') or (FileExt = '.tga') or (FileExt = '.tif')
   or (FileExt = '.wmf') or (FileExt = '.emf') or (FileExt = '.ico')
   or ((FileGetAttr(PhotoName) and faReadOnly) = faReadOnly) then
    SaveAsImage
else
begin
     if FileExt = '.bmp' then Photo.Picture.Bitmap.SaveToFile(PhotoName);
     if (FileExt = '.jpg') or (FileExt = '.jpe') then DPEMain.SaveToJPEG(Photo.Picture.Bitmap,PhotoName);
     if FileExt = '.gif' then DPEMain.SavetoGif(Photo.Picture.Bitmap,PhotoName);
     Modified := False;
     Saved := True;
end;
end;

procedure TFPhoto.SaveAsImage;
var tmp : string;
    FileExt : string[4];
begin
  if DPEMain.SaveDialog.Execute then
  begin
       DPEMain.SaveDialog.InitialDir := ExtractFileDir(DPEMain.SaveDialog.FileName);
       Screen.Cursor := crHourGlass;
       tmp := DPEMain.SaveDialog.FileName;
       if (Pos ('.', tmp) = 0) then
       begin
            case DPEMain.SaveDialog.FilterIndex of 1: tmp := Concat (tmp, '.BMP');
                                         2: tmp := Concat (tmp, '.JPG');
                                         3: tmp := Concat(tmp,'.GIF');
            end;
       end;
       FileExt := ANSILowerCase(ExtractFileExt(tmp));
       try
         if (FileExt = '.jpg') or (FileExt = '.jpe') then DPEMain.SavetoJPEG(Photo.Picture.Bitmap,tmp) else if FileExt = '.bmp' then
          Photo.Picture.Bitmap.SaveToFile(tmp)
           else if (FileExt = '.gif') then DPEMain.SavetoGif(Photo.Picture.Bitmap,tmp);
       finally
         Screen.Cursor := crDefault;
       end;
       PhotoName := tmp;
       Caption := ExtractFileName(PhotoName);
       Photo.Hint := 'File: ' + ExtractFileName(PhotoName);
       Modified := False;
       Saved := True;
       FormActivate(Self);
       DPEMain.RecentFiles.LatestFile := PhotoName;
  end;
end;

procedure TFPhoto.ApplyPalette(hpal : hpalette);
var p81,p82 :PByteArray;
    x,y : integer;
    bmp : TBitmap;
begin
bmp := TBitmap.Create;
bmp.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
bmp.Width := Photo.Picture.Bitmap.Width;
bmp.Height := Photo.Picture.Bitmap.Height;
bmp.Palette := hpal;
for y := 0 to bmp.Height -1 do
begin
     p81 := Photo.Picture.Bitmap.Scanline[y];
     p82 := bmp.ScanLine[y];
     for x := 0 to bmp.Width -1 do
     begin
          p82[x] := p81[x];
     end;
end;
Photo.Picture.Bitmap.Assign(bmp);
bmp.Free;
end;

procedure TFPhoto.GammaImage(AmountGamma : integer; forreel : boolean);
var p24 : PRGBByteArray;
    x,y : integer;
    tempbmp : TBitmap;
    Align : boolean;
begin
if AmountGamma = 0 then Exit;
if forreel then SaveUndo;
if AmountGamma < 0 then
begin
     AmountGamma := -AmountGamma;
     Align := true
end else Align := false;
tempbmp := TBitmap.Create;
tempbmp.Assign(photo.Picture.Bitmap);
tempbmp.PixelFormat := pf24bit;
if Align then
begin
     for y := 0 to tempbmp.height -1 do
     begin
       P24 := tempbmp.ScanLine[y];
       for x := 0 to tempbmp.width -1 do
         p24[x] := DarkenColor(p24[x],AmountGamma);
     end;
end
else
begin
     for y := 0 to tempbmp.height -1 do
     begin
        P24 := tempbmp.ScanLine[y];
        for x := 0 to tempbmp.width -1 do
           p24[x] := BrightenColor(p24[x],AmountGamma);
     end;
end;
photo.Canvas.Draw(0,0,tempbmp);
tempbmp.Free;
Modified := True;
end;

procedure TFPhoto.LoadPalette(FileName : string);
var f : textfile;
    Line : string;
    rs,gs,bs : string[3];
    sp : word;
    i,ci : integer;
    pal : TMaxLogpalette;
    r,g,b : byte;
    c : word;
    maxpos1,maxpos2 : integer;
begin
assignfile(f,FileName);
FileMode := 0;
reset(f);
ReadLN(f,Line);
ReadLN(f,Line);
ReadLN(f,Line);
c := strtoint(line);
if (c <>16) and (c <> 256) then
begin
 Application.MessageBox('Invalid palette file!', 'Error',MB_ICONERROR);
 CloseFile(f);
 Exit;
end;
case c  of 16: photo.Picture.Bitmap.PixelFormat := pf4bit;
           256: photo.Picture.Bitmap.PixelFormat := pf8bit;
end;
pal.palVersion := $300;
pal.palNumEntries := c;
for i := 0 to pal.PalNumEntries-1 do
begin
 ReadLN(f,line);
     rs := '';
     gs := '';
     bs := '';
     sp := pos(' ',line);
     maxpos1 := sp-1;
     delete(line,sp,1);
     sp := pos(' ', line);
     maxpos2 := sp-1;
     delete(line,sp,1);
     for ci := 1 to maxpos1 do
     begin
       rs := rs +line[ci];
     end;
     for ci := maxpos1+1 to maxpos2 do
     begin
        gs := gs + line[ci];
     end;
     for ci := maxpos2+1 to length(line) do
     begin
        bs := bs +line[ci];
     end;
     r := strtoint(rs);
     g := strtoint(gs);
     b := strtoint(bs);
     pal.palpalentry[i].peRed := r;
     pal.palpalentry[i].peGreen := g;
     pal.palpalentry[i].peBlue := b;
end;
photo.picture.bitmap.palette := CreatePalette(PLogPalette(@Pal)^);
FormActivate(Self);
Modified := True;
CloseFile(f);
end; {LoadPalette}

procedure TFPhoto.SavePalette(FileName : string);
var pal : TMaxLogPalette;
    i : word;
    f : textfile;
    line : string;
begin
pal.palVersion := $300;
case photo.picture.bitmap.pixelformat of
  pf8bit :pal.palNumEntries := 256;
  pf4bit :pal.palnumentries := 16;
  pf1bit :pal.palnumentries := 2;
end;
GetPaletteEntries(Photo.Picture.Bitmap.Palette,0,Pal.PalNumEntries,Pal.palpalentry);
AssignFile(f, FileName);
FileMode := 1;
Rewrite(f);
WriteLN(f,'JASC-PAL');
WriteLN(f,'0100');
WriteLN(f,inttostr(pal.palnumentries));
for i := 0 to pal.palnumentries-1 do
begin
line := inttostr(pal.palpalentry[i].peRed)+ ' ' +
        inttostr(pal.palpalentry[i].peGreen) + ' ' +
        inttostr(pal.palpalentry[i].peBlue);
WriteLN(f,Line);
end;
CloseFile(f);
end;

procedure TFPhoto.DitherTo8Bit;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
photo.picture.bitmap := TrueColorTo256(photo.picture.bitmap);
if photo.picture.bitmap.PixelFormat <> pf8bit then
  raise Exception.Create('Error on dither!');
DPEMain.ProgressBar.Visible := False;
FormActivate(Self);
Modified := True;
end;

procedure TFPhoto.ToXBit(FPixelFormat : TPixelFormat);
begin
SaveUndo;
Photo.Picture.Bitmap.PixelFormat := FPixelFormat;
FormActivate(Self);
Modified := True;
end;

procedure TFPhoto.CoolColorThing;
var p24 : PRGBByteArray;
    x,y : integer;
    tempbmp : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
tempbmp := TBitmap.Create;
tempbmp.Assign(Photo.Picture.Bitmap);
tempbmp.PixelFormat := pf24bit;
for y := 0 to tempbmp.height -1 do
begin
     P24 := tempbmp.ScanLine[y];
     DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
     for x := 0 to tempbmp.width -1 do
         p24[x] := Colorise(p24[x],p24[x]);
end;
photo.Canvas.Draw(0,0,tempbmp);
tempbmp.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
end;

procedure TFPhoto.RGBAdjustColor(R,G,B : integer; forreel : boolean);
var
  x,y : integer;
  P24 : PRGBByteArray;
  ImageBitmap : TBitmap;
  pal :TMaxLogPalette;
  PalEntry : TPaletteEntry;
  TC : TTrueColor;
  i : word;
begin
DPEMain.ProgressBar.Visible := True;
if forreel then SaveUndo;
ImageBitmap := TBitmap.Create;
ImageBitmap.Assign(Photo.Picture.Bitmap);
case ImageBitmap.PixelFormat of pf24Bit:
 begin
  for y := 0 to ImageBitmap.height -1 do
  begin
       DPEMain.ProgressBar.Position := trunc(100*(Y/ImageBitmap.Height));
       P24 := ImageBitmap.ScanLine[y];
       for x := 0 to ImageBitmap.width -1 do
         P24[x] := ColorMod(P24[x],R,G,B); // Cool Efetct;
  end;
 end;
    pf8bit:
 begin
  IMageBitmap.Palette := Photo.Picture.Bitmap.Palette;
  pal.palVersion := $300;
  pal.palNumEntries := 256;
  GetPaletteEntries(ImageBitmap.Palette,0,256,Pal.palpalentry);
  for i := 0 to 255 do
  begin
     palentry := pal.palpalentry[i];
     TC.Red := palentry.peRed;
     TC.Green := palentry.peGreen;
     TC.Blue := palentry.peBlue;
     TC := ColorMod(TC,R,G,B);
     palentry.peRed := tc.Red;
     palentry.peBlue := tc.Blue;
     palentry.peGreen := tc.Green;
     palentry.peFlags := 0;
     pal.palpalentry[i] := palentry;
  end;
  Imagebitmap.Palette:= CreatePalette(PLogPalette(@Pal)^);
 end;
end;
Photo.Picture.Assign(ImageBitmap);
ImageBitmap.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
end;

procedure TFPhoto.RotateBitmap(Angle : integer{; autosize : boolean});
  VAR
    cosTheta       :  DOUBLE;
    //Delta          :  INTEGER;
    i              :  INTEGER;
    iRotationAxis  :  INTEGER;
    iOriginal      :  INTEGER;
    iPrime         :  INTEGER;
    iPrimeRotated  :  INTEGER;
    j              :  INTEGER;
    jRotationAxis  :  INTEGER;
    jOriginal      :  INTEGER;
    jPrime         :  INTEGER;
    jPrimeRotated  :  INTEGER;
    RowOriginal    :  pRGBByteArray;
    RowRotated     :  pRGBByteArray;
    RowOriginal8   :  pByteArray;
    RowRotated8    :  pByteArray;
    sinTheta       :  DOUBLE;
    //StartTime      :  INTEGER;
    Theta          :  DOUBLE;       {radians}
    BitmapOriginal : TBitmap;
    BitmapRotated : TBitmap;
    BackColor : TTrueColor;
    BackColor8 : Byte;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
BitmapOriginal := TBitmap.Create;
BitmapOriginal.Assign(Photo.Picture.Bitmap);
//if autosize then AdequateSize(BitmapOriginal,angle);
//BitmapOriginal.PixelFormat := pf24bit;
BitmapRotated := TBitmap.Create;
BitmapRotated.PixelFormat := BitmapOriginal.PixelFormat;
BitmapRotated.Width  := BitmapOriginal.Width;
BitmapRotated.Height := BitmapOriginal.Height;
iRotationAxis := BitmapRotated.Width  DIV 2;
jRotationAxis := BitmapRotated.Height DIV 2;
Theta := -Angle * PI / 180;
sinTheta := SIN(Theta);
cosTheta := COS(Theta);
case BitmapOriginal.PixelFormat of pf24bit:
 begin
   BackColor.Red := GetRValue(ColorToRGB(DPEMain.BackColorP.Color));
   BackColor.Blue := GetBValue(ColorToRGB(DPEMain.BackColorP.Color));
   BackColor.Green := GetGValue(ColorToRGB(DPEMain.BackColorP.Color));
  FOR j := 0 TO BitmapRotated.Height-1 DO
  BEGIN
       RowRotated  := BitmapRotated.Scanline[j];
       jPrime := 2*(j - jRotationAxis) + 1;
       DPEMain.ProgressBar.Position := trunc(100*(j/BitmapRotated.Height));
       FOR i := 0 TO BitmapRotated.Width-1 DO
       BEGIN
           iPrime := 2*(i - iRotationAxis) + 1;
           iPrimeRotated := ROUND(iPrime * CosTheta - jPrime * sinTheta);
           jPrimeRotated := ROUND(iPrime * sinTheta + jPrime * cosTheta);
           iOriginal := (iPrimeRotated - 1) DIV 2 + iRotationAxis;
           jOriginal := (jPrimeRotated - 1) DIV 2 + jRotationAxis;
           IF   (iOriginal >= 0) AND (iOriginal <= BitmapOriginal.Width-1) AND
                (jOriginal >= 0) AND (jOriginal <= BitmapOriginal.Height-1) THEN
           BEGIN
                RowOriginal := BitmapOriginal.Scanline[jOriginal];
                RowRotated[i].Blue  := RowOriginal[iOriginal].Blue;
                RowRotated[i].Green := RowOriginal[iOriginal].Green;
                RowRotated[i].Red   := RowOriginal[iOriginal].Red;
           END
           ELSE RowRotated[i] := BackColor;  {assign "corner" color}
       END
  END;
 end;
                              pf8bit,pf4bit,pf1bit:
 begin
  backcolor8 := 1;
  BitmapRotated.Palette := Photo.Picture.Bitmap.Palette;
  FOR j := 0 TO BitmapRotated.Height-1 DO
  BEGIN
       RowRotated8  := BitmapRotated.Scanline[j];
       jPrime := 2*(j - jRotationAxis) + 1;
       DPEMain.ProgressBar.Position := trunc(100*(j/BitmapRotated.Height));
       FOR i := 0 TO BitmapRotated.Width-1 DO
       BEGIN
           iPrime := 2*(i - iRotationAxis) + 1;
           iPrimeRotated := ROUND(iPrime * CosTheta - jPrime * sinTheta);
           jPrimeRotated := ROUND(iPrime * sinTheta + jPrime * cosTheta);
           iOriginal := (iPrimeRotated - 1) DIV 2 + iRotationAxis;
           jOriginal := (jPrimeRotated - 1) DIV 2 + jRotationAxis;
           IF   (iOriginal >= 0) AND (iOriginal <= BitmapOriginal.Width-1) AND
                (jOriginal >= 0) AND (jOriginal <= BitmapOriginal.Height-1) THEN
           BEGIN
                RowOriginal8:= BitmapOriginal.Scanline[jOriginal];
                RowRotated8[i]  := RowOriginal8[iOriginal];
           END
           ELSE RowRotated8[i] := BackColor8;  {assign "corner" color}
       END
  END;
 end;
end;
Photo.Picture.Bitmap.Assign(BitmapRotated);
BitmapRotated.Free;
BitmapOriginal.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
{if AutoSize then
begin
  FitImage(Photo.Picture.Width, Photo.Picture.Height);
  FormActivate(Self);
end;}
end;


procedure TFPhoto.Solarize(Threshold : byte);
var p24 : PRGBByteArray;
    //p8 : PByteArray;
    x,y : integer;
    tempbmp : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
tempbmp := TBitmap.Create;
tempbmp.Assign(Photo.Picture.Bitmap);
tempbmp.PixelFormat := pf24Bit;
{case tempbmp.PixelFormat of pf24Bit:
 begin}
  for y := 0 to tempbmp.height -1 do
  begin
       P24 := tempbmp.ScanLine[y];
       DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
       for x := 0 to tempbmp.width -1 do
       begin
           p24[x].Blue := threshold xor p24[x].Blue;
           p24[x].Green := threshold xor p24[x].Green;
           p24[x].Red := threshold xor p24[x].Red;
       end;
  end;
{ end;}

//                            pf8Bit:
 {begin
  for y := 0 to tempbmp.height -1 do
  begin
       P8 := tempbmp.ScanLine[y];
       DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
       for x := 0 to tempbmp.width -1 do
       begin
           p8[x] := not(byte(p8[x]));
       end;
  end;
  //tempbmp.Palette := Invert8bitPalette(tempbmp.Palette);
 end;}
{end;}
photo.Canvas.Draw(0,0,tempbmp);
tempbmp.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
end; {Solarize}

procedure TFPhoto.InvertBitmap;
var p24 : PRGBByteArray;
    //p8 : PByteArray;
    x,y : integer;
    tempbmp : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
tempbmp := TBitmap.Create;
tempbmp.Assign(Photo.Picture.Bitmap);
tempbmp.PixelFormat := pf24Bit;
{case tempbmp.PixelFormat of pf24Bit:
 begin}
  for y := 0 to tempbmp.height -1 do
  begin
       P24 := tempbmp.ScanLine[y];
       DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
       for x := 0 to tempbmp.width -1 do
       begin
           p24[x].Blue := not p24[x].Blue;
           p24[x].Green := not p24[x].Green;
           p24[x].Red := not p24[x].Red;
       end;
  end;
{ end;}

//                            pf8Bit:
 {begin
  for y := 0 to tempbmp.height -1 do
  begin
       P8 := tempbmp.ScanLine[y];
       DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
       for x := 0 to tempbmp.width -1 do
       begin
           p8[x] := not(byte(p8[x]));
       end;
  end;
  //tempbmp.Palette := Invert8bitPalette(tempbmp.Palette);
 end;}
{end;}
photo.Canvas.Draw(0,0,tempbmp);
tempbmp.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
end; {InvertBitmap}

procedure TFPhoto.HSVAdjustColor(H,S,V : Integer; forreel : boolean);
var
  ht : THSVColor;
  x,y : integer;
  P24 : PRGBByteArray;
  ImageBitmap : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
if forreel then SaveUndo;
ImageBitmap := TBitmap.Create;
ImageBitmap.Assign(Photo.Picture.Bitmap);
ImageBitmap.PixelFormat := pf24Bit;
for y := 0 to ImageBitmap.height -1 do
begin
     DPEMain.ProgressBar.Position := trunc(100*(Y/ImageBitmap.Height));
     P24 := ImageBitmap.ScanLine[y];
     for x := 0 to ImageBitmap.width -1 do
     begin
          ht := RGBtoHSV(P24[x]);
          ht := ColorHSVMod(ht,H,S,V);
          P24[x] := HSVtoRGB(ht);
     end;
end;
photo.Canvas.Draw(0,0,ImageBitmap);
ImageBitmap.Free;
DPEMain.Progressbar.Visible := False;
Modified := True;
end;

procedure TFPhoto.GreyBitmap;
var p24 : PRGBByteArray;
    p8 : PByteArray;
    x,y : integer;
    tempbmp : TBitmap;
    outbitmap : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
tempbmp := TBitmap.Create;
tempbmp.Assign(Photo.Picture.Bitmap);
outbitmap := TBitmap.Create;
outbitmap.PixelFormat := pf8bit;
outbitmap.Width := tempbmp.Width;
outbitmap.Height := tempbmp.Height;
outbitmap.Palette := PrepareGrayPalette;
//tempbmp.PixelFormat := pf24bit;
for y := 0 to tempbmp.height -1 do
begin
     P24 := tempbmp.ScanLine[y];
     p8 := outbitmap.ScanLine[y];
     DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
     for x := 0 to tempbmp.width -1 do
         p8[x] := SingleToGrey(p24[x]);
end;
photo.Picture.Bitmap.Assign(outbitmap);
FormActivate(Self);
tempbmp.Free;
outbitmap.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
end; {GreyBitmap}

procedure TFPhoto.ColoriseImage(R, G, B : Byte);
var p24 : PRGBByteArray;
    x,y : integer;
    tempbmp : TBitmap;
    pR, pG, pB : Real;
    TrueColor : TTrueColor;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
tempbmp := TBitmap.Create;
tempbmp.Assign(Photo.Picture.Bitmap);
tempbmp.PixelFormat := pf24bit;
pR := R / 255 + 1;
pG := G / 255 + 1;
pB := B / 255 + 1;
for y := 0 to tempbmp.height -1 do
begin
     P24 := tempbmp.ScanLine[y];
     DPEMain.ProgressBar.Position := trunc(100*(y/tempBmp.Height));
     for x := 0 to tempbmp.width -1 do
     begin
         TrueColor := p24[x];
         TrueColor := ColorToGrey(TrueColor);
         p24[x] := ERGB(pR * TrueColor.Red, pG * TrueColor.Green, pB * TrueColor.Blue);
         //p24[x] := Colorise(p24[x],rgbtc(r,g,b));
     end;
end;
Photo.Canvas.Draw(0,0,tempbmp);
tempbmp.Free;
DPEMain.ProgressBar.Visible := False;
Modified := True;
end;

procedure TFPhoto.SoftenBMP(Deep : integer);
var
  i , j : Integer;
  SR : TRect;
  P24 : PRGBByteArray;
  tempw, temph,ih,jh : integer;
  ImageBitmap : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
ImageBitmap := TBitmap.Create;
ImageBitmap.Assign(photo.Picture.Bitmap);
ImageBitmap.PixelFormat := pf24bit;
tempw := ImageBitmap.Width-1;
temph := ImageBitmap.Height-Deep;
  for i := 0 to temph do
  begin
    P24 := ImageBitmap.ScanLine[i];
    DPEMain.ProgressBar.Position := trunc(100*(i/ImageBitmap.Height));
    ih := i - Deep;
    for j := 0 to tempw do
    begin
    jh := j-Deep;
      if not ((jh < 0) or (ih < 0)) then
      begin
        SR := Bounds(jh, ih, Deep*2, Deep*2);
        P24[j] := MiscBmpToColor(ImageBitmap,tempw, temph, SR);
      end
      else
      begin
        SR := Bounds(jh+1, ih+1, (Deep*2)-1, (Deep*2)-1);
        P24[j] := MiscBmpToColor(ImageBitmap,tempw, temph, SR);
      end;
    end;
  end;
Photo.Canvas.Draw(0,0,ImageBitmap);
ImageBitmap.Free;
DPEMain.ProgressBar.visible := false;
Modified := True;
end;

procedure TFPhoto.SharpenImage;
var P : PRGBByteArray;
    bmp : TBitmap;
    tmp : TBitmap;
    x,y : integer;
    ii,iii : integer;
    it : double;
    ip : integer;
    pixelmatrix : array[0..3] of PRGBByteArray;

 function I(xx,yy:integer):TTrueColor;
 begin
   if xx < 0 then inc(xx);
   if xx > bmp.Width -1 then dec(xx);
   if y > yy then
    result := PRGBByteArray(pixelmatrix[2])[xx]
    else if y = yy then result := PRGBByteArray(pixelmatrix[1])[xx]
    else result := PRGBByteArray(pixelmatrix[0])[xx]
 end;

begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
Modified := True;
bmp := TBitmap.Create;
bmp.PixelFormat := pf24bit;
bmp.Width := Photo.Picture.Bitmap.Width;
bmp.Height := Photo.Picture.Bitmap.Height;
bmp.Assign(Photo.Picture.Bitmap);
tmp := TBitmap.Create;
tmp.PixelFormat := pf24bit;
tmp.Width := Photo.Picture.Bitmap.Width;
tmp.Height := Photo.Picture.Bitmap.Height;
tmp.Assign(Photo.Picture.Bitmap);
for y := 0 to bmp.Height -1 do
begin
     p := bmp.ScanLine[y];
     DPEMain.Progressbar.Position := trunc(100*(y/bmp.Height));
     iii := 0;
     for ii := y-1 to y+1 do
     begin
          if ii < 0 then pixelmatrix[0] := tmp.ScanLine[ii+1]
          else if ii > bmp.Height-1 then pixelmatrix[2] := tmp.ScanLine[ii-1]
          else pixelmatrix[iii] := tmp.ScanLine[ii];
          inc(iii);
     end;
     for x := 0 to bmp.Width-1 do
     begin
        /// Sharpen ///
        //////////////
	it := (100 * I(x,y).Red -
             (I(x-1,y-1).Red + i(x,y-1).Red + i(x+1,y-1).Red + I(x-1,y).Red +
              I(x+1,y).Red + I(x-1,y+1).Red+ I(x,y+1).Red + I(x+1,y+1).Red) *
             50 / 8) / 50;
        ip := round(it);
        if ip < 0 then
          p[x].Red := 0
	else if ip > 255 then
          p[x].Red := 255
	else
          p[x].Red := ip;
	it := (100 * I(x,y).Green -
             (I(x-1,y-1).Green + i(x,y-1).Green + i(x+1,y-1).Green + I(x-1,y).Green +
              I(x+1,y).Green + I(x-1,y+1).Green+ I(x,y+1).Green + I(x+1,y+1).Green) *
             50 / 8) / 50;
        ip := round(it);
        if ip < 0 then
          p[x].Green := 0
	else if ip > 255 then
          p[x].Green := 255
	else
          p[x].Green := ip;
	it := (100 * I(x,y).Blue -
             (I(x-1,y-1).Blue + i(x,y-1).Blue + i(x+1,y-1).Blue + I(x-1,y).Blue +
              I(x+1,y).Blue + I(x-1,y+1).Blue+ I(x,y+1).Blue + I(x+1,y+1).Blue) *
             50 / 8) / 50;
        ip := round(it);
        if ip < 0 then
          p[x].Blue := 0
	else if ip > 255 then
          p[x].Blue := 255
	else
          p[x].Blue := ip;
        //////////////////
        //////////////////
     end;
end;
Photo.Canvas.Draw(0,0,bmp);
DPEMain.ProgressBar.Visible := False;
bmp.Free;
tmp.Free;
end;

procedure TFPhoto.MirrorBitmap;
var
  x,y : integer;
  PT1,PT2 : PRGBByteArray;
  tc : TTrueColor;
  imagebitmap,tempbitmap : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
ImageBitmap := TBitmap.Create;
ImageBitmap.Assign(Photo.Picture.Bitmap);
ImageBitmap.PixelFormat := pf24bit;
tempbitmap := TBitmap.Create;
tempbitmap.Width := ImageBitmap.Width;
tempbitmap.Height := ImageBitmap.Height;
tempbitmap.PixelFormat := pf24bit;
for y := 0 to ImageBitmap.height -1 do
begin
     DPEMain.ProgressBar.Position := trunc(100*(Y/ImageBitmap.Height));
     PT1 := ImageBitmap.ScanLine[y];
     PT2 := tempBitmap.ScanLine[y];
     for x := 0 to ImageBitmap.width -1 do
     begin
          tc := pt1[ImageBitmap.Width-x-1];
          pt2[x] := tc;
     end;
end;
ImageBitmap.Assign(tempbitmap);
tempbitmap.Free;
Photo.Canvas.Draw(0,0,imagebitmap);
ImageBitmap.Free;
DPEMain.ProgressBar.Visible := false;
Modified := True;
end;

procedure TFPhoto.FlipBitmap;
var
  x,y : integer;
  PT1,PT2 : PRGBByteArray;
  tc : TTrueColor;
  imagebitmap,tempbitmap : TBitmap;
begin
DPEMain.ProgressBar.Visible := True;
SaveUndo;
ImageBitmap := TBitmap.Create;
ImageBitmap.Assign(Photo.Picture.Bitmap);
ImageBitmap.PixelFormat := pf24bit;
tempbitmap := TBitmap.Create;
tempbitmap.Width := ImageBitmap.Width;
tempbitmap.Height := ImageBitmap.Height;
tempbitmap.PixelFormat := pf24bit;
for y := 0 to ImageBitmap.height -1 do
begin
     DPEMain.ProgressBar.Position := trunc(100*(Y/ImageBitmap.Height));
     PT1 := ImageBitmap.ScanLine[y];
     PT2 := tempBitmap.ScanLine[ImageBitmap.Height-y-1];
     for x := 0 to ImageBitmap.width -1 do
     begin
          tc := pt1[x];
          pt2[x] := tc;
     end;
end;
ImageBitmap.Assign(tempbitmap);
tempbitmap.Free;
Photo.Canvas.Draw(0,0,imagebitmap);
ImageBitmap.Free;
DPEMain.ProgressBar.visible := false;
Modified := True;
end;

procedure TFPhoto.ResizeBitmap(xdim,ydim :Word);
var btmp : TBitmap;
    newbmp : TBitmap;
begin
if (xdim = Photo.Picture.Width) and (ydim = Photo.Picture.Height) then Exit;
SaveUndo;
Resized := True;
Modified := True;
btmp := TBitmap.Create;
newbmp := TBitmap.Create;
newbmp.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
newbmp.Palette := Photo.Picture.Bitmap.Palette;
newbmp.Width := xdim;
newbmp.Height := ydim;
btmp.Assign(Photo.Picture.Bitmap);
btmp.Palette := Photo.Picture.Bitmap.Palette;
newbmp.Canvas.StretchDraw(Rect(0,0,xdim,ydim),btmp);
Photo.Picture.Assign(newbmp);
newbmp.Free;
btmp.Free;
FitImage(Photo.Picture.Width, Photo.Picture.Height);
FormActivate(Self);
end; {ResizeBitmap}

procedure TFPhoto.ResampleBitmap(xdim,ydim : word ; FilterIndex : byte);
var tmp :TBitmap;
begin
if (xdim = Photo.Picture.Width) and (ydim = Photo.Picture.Height) then Exit;
DPEMain.ProgressBar.Visible := True;
SaveUndo;
Resized := True;
Modified := True;
tmp := TBitmap.Create;
tmp.PixelFormat := pf24bit;
tmp.Width := xdim;
tmp.Height := ydim;
StrecthBitmap(Photo.Picture.Bitmap,tmp,ResampleFilters[FilterIndex].Filter,ResampleFilters[FilterIndex].Width);
Photo.Picture.Assign(tmp);
tmp.Free;
FitImage(Photo.Picture.Width, Photo.Picture.Height);
DPEMain.ProgressBar.Visible := False;
FormActivate(Self);
end; {ResampleBitmap}

procedure TFPhoto.ResizeCanvas(width,height : word; center : boolean);
var tmp : TBitmap;
begin
SaveUndo;
Resized := True;
tmp := TBitmap.Create;
tmp.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
tmp.Palette := Photo.Picture.Bitmap.Palette;
tmp.Width := width;
tmp.Height := Height;
if DPEMain.BackColorP.Color <> clWhite then
begin
     tmp.Canvas.Brush.Color := DPEMain.BackColorP.Color;
     tmp.Canvas.FillRect(Rect(0,0,Width,Height));
end;
if center then
     tmp.Canvas.Draw(tmp.Width div 2 -photo.picture.width div 2,tmp.Height div 2 - photo.picture.height div 2, photo.Picture.Bitmap)
  else
     tmp.Canvas.Draw(0,0,Photo.Picture.Bitmap);
Photo.Picture.Bitmap.Assign(tmp);
tmp.Free;
Modified := True;
FitImage(Photo.Picture.Width, Photo.Picture.Height);
FormActivate(Self);
end;

procedure TFPhoto.AlphaBlend(SRCBitmap : TBitmap; Grade : byte);
var outb : TBitmap;
    x,y : integer;
    p1,p2,p3 : PRGBByteArray;
    ow,oh : integer;
begin
     DPEMain.ProgressBar.Visible := True;
     SaveUndo;
     outb := TBitmap.Create;
     outb.PixelFormat := pf24bit;
     if SRCBitmap.Width < Photo.Picture.Bitmap.Width then
     ow := SRCBitmap.Width else Ow := Photo.Picture.Bitmap.Width;
     if SRCBitmap.Height < Photo.Picture.Bitmap.Height then
     oh := SRCBitmap.Height else Oh := Photo.Picture.Bitmap.Height;
     outb.Width := ow;
     outb.Height := oh;
     for y := 0 to oH-1 do
     begin
          p1 := Photo.Picture.Bitmap.ScanLine[y];
          p2 := srcbitmap.ScanLine[y];
          p3 := outb.ScanLine[y];
          DPEMain.ProgressBar.Position := trunc(100*(y/oh));
          for x := 0 to oW-1 do
          begin
               p3[x] := MergeColorExt(p2[x],p1[x],Grade)
          end;
     end;
     //src.Free;
     Photo.Canvas.Draw(0,0,outb);
     outb.Free;
     DPEMain.ProgressBar.Visible := False;
     Modified := True;
end;

procedure TFPhoto.MakeButton(Border : Integer; Soft : Boolean);
var i, j : Integer;
    Edge : Integer;
    p24 : PRGBByteArray;
    tempimage : TBitmap;
begin
SaveUndo;
tempimage := TBitmap.Create;
tempimage.Assign(Photo.Picture.Bitmap);
tempimage.PixelFormat := pf24bit;
Edge := 96;
for j := 1 to Border do
  for i := j - 1 to tempimage.Width - j do
  begin
    p24 := tempImage.ScanLine[j-1];
    p24[i] := BrightenColor(p24[i], Edge);
    p24 := tempimage.ScanLine[tempimage.Height - j];
    p24[i] := DarkenColor(p24[i],Edge);
    if Soft then Edge := Round(96 - (j-1) / Border * 96);
  end;
Edge := 96;
for j := 1 to Border do
  for i := j - 1 to tempimage.Height - j do
  begin
    p24 := tempImage.ScanLine[i];
    p24[j-1] := BrightenColor(p24[j-1],Edge);
    p24[tempimage.Width - j] := DarkenColor(P24[tempimage.Width - j], Edge);
    if Soft then Edge := Round(96 - (j-1) / Border * 96);
  end;
Photo.Canvas.Draw(0,0,TempImage);
tempimage.Free;
Modified := True;
end; {MakeButton}

procedure TFPhoto.LightenAtXY(x,y : integer);
var p24 : PRGBByteArray;
    xi,yi : integer;
    mi1,mi2,mi3,mi4 : integer;
begin
 mi1 := y-SizeRet;
 if mi1 < 0 then mi1 := 0;
 mi2 := y+SizeRet;
 if mi2 > RetBMP.Height -1 then mi2 := RetBMP.Height -1;
 mi3 := x-SizeRet;
 if mi3 < 0 then mi3 := 0;
 mi4 := x+SizeRet;
 if mi4 > RetBMP.Width -1 then mi4 := RetBMP.Width-1;
  for yi := mi1 to mi2 do
  begin
       p24 := RetBMP.ScanLine[yi];
       for xi := mi3 to mi4 do
       begin
            p24[xi] := BrightenColor(p24[xi],StrVal);
       end;
  end;
  Photo.Picture.Bitmap.Assign(RetBMP);
end;

procedure TFPhoto.DarkenAtXY(x,y : integer);
var p24 : PRGBByteArray;
    xi,yi : integer;
    mi1,mi2,mi3,mi4 : integer;
begin
 mi1 := y-SizeRet;
 if mi1 < 0 then mi1 := 0;
 mi2 := y+SizeRet;
 if mi2 > RetBMP.Height -1 then mi2 := RetBMP.Height -1;
 mi3 := x-SizeRet;
 if mi3 < 0 then mi3 := 0;
 mi4 := x+SizeRet;
 if mi4 > RetBMP.Width -1 then mi4 := RetBMP.Width-1;
  for yi := mi1 to mi2 do
  begin
       p24 := RetBMP.ScanLine[yi];
       for xi := mi3 to mi4 do
       begin
            p24[xi] := DarkenColor(p24[xi],StrVal);
       end;
  end;
  Photo.Picture.Bitmap.Assign(RetBMP);
end;

procedure TFPhoto.SoftenAtXY(x,y : integer);
var p24 : PRGBByteArray;
    xi,yi : integer;
    mi1,mi2,mi3,mi4 : integer;
    tempw,ih,jh, temph : integer; //
    SR : TRect; //
const deep = 1;//
begin
 tempw := RetBMP.Width-1;
 temph := RetBMP.Height-Deep;
 mi1 := y-SizeRet;
 if mi1 < 0 then mi1 := 0;
 mi2 := y+SizeRet;
 if mi2 > RetBMP.Height -1 then mi2 := RetBMP.Height -1;
 mi3 := x-SizeRet;
 if mi3 < 0 then mi3 := 0;
 mi4 := x+SizeRet;
 if mi4 > RetBMP.Width -1 then mi4 := RetBMP.Width-1;
  for yi := mi1 to mi2 do
  begin
       p24 := RetBMP.ScanLine[yi];
       ih := yi - Deep;
       for xi := mi3 to mi4 do
       begin
            jh := xi-Deep;
            if not ((jh < 0) or (ih < 0)) then
            begin
                 SR := Bounds(jh, ih, Deep*2, Deep*2);
                 P24[xi] := MiscBmpToColor(RetBMP,tempw, temph, SR);
            end
            else
            begin
                 SR := Bounds(jh+1, ih+1, (Deep*2)-1, (Deep*2)-1);
                 P24[xi] := MiscBmpToColor(RetBMP,tempw, temph, SR);
            end;
            ////////////////////////////////////////////
       end;
  end;
  Photo.Picture.Bitmap.Assign(RetBMP);
end;

procedure TFPhoto.DoUndoAtXY(x,y : integer);
var p241,p242 : PRGBByteArray;
    p81,p82 : PByteArray;
    xi,yi : integer;
    mi1,mi2,mi3,mi4 : integer;
    TC : TTrueColor;   // stupid bug workaround
    T : Byte;
begin
 mi1 := y-SizeEraser;
 if mi1 < 0 then mi1 := 0;
 mi2 := y+SizeEraser;
 if mi2 > RetBMP.Height -1 then mi2 := RetBMP.Height -1;
 mi3 := x-SizeEraser;
 if mi3 < 0 then mi3 := 0;
 mi4 := x+SizeEraser;
 if mi4 > RetBMP.Width -1 then mi4 := RetBMP.Width-1;
 case RetBMP.PixelFormat of
   pf24bit:
    begin
     for yi := mi1 to mi2 do
     begin
          p241 := RetBMP.ScanLine[yi];
          p242 := UndoBitmap.ScanLine[yi];
           for xi := mi3 to mi4 do
          begin
                TC := p242[xi];
                p241[xi] := TC;
          end;
     end;
   end;
   pf1bit,pf4bit,pf8bit:
    begin
     for yi := mi1 to mi2 do
     begin
          p81 := RetBMP.ScanLine[yi];
          p82 := UndoBitmap.ScanLine[yi];
          for xi := mi3 to mi4 do
          begin
               t := p82[xi];
               p81[xi] := t;
          end;
     end;
    end;
 end;
 Photo.Picture.Bitmap.Assign(RetBMP);
end;


procedure TFPhoto.AddBorders(TopA, BottomA, LeftA, RightA : integer);
var t : TBitmap;
begin
if (topA = 0) and (BottomA = 0) and (LeftA = 0) and (RightA = 0) then Exit;
SaveUndo;
Resized := True;
t := TBitmap.Create;
t.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
t.Palette := Photo.Picture.Bitmap.Palette;
t.Width := Photo.Picture.Bitmap.Width +  LeftA + RightA;
t.Height := Photo.Picture.Bitmap.Height + TopA + BottomA;
t.Canvas.Brush.Color := DPEMain.BackColorP.Color;
t.Canvas.FillRect(Rect(0,0,t.Width,t.Height));
t.Canvas.Draw(LeftA, TopA, Photo.Picture.Bitmap);
Photo.Picture.Bitmap.Assign(t);
t.Free;
Modified := True;
FitImage(Photo.Picture.Width, Photo.Picture.Height);
FormActivate(Self);
end;

procedure TFPhoto.ClearBitmap;
var oldcolor : TColor;
begin
SaveUndo;
oldColor := Photo.Canvas.Brush.Color;
Photo.Canvas.Brush.Color := DPEMain.BackColorP.Color;
Photo.Canvas.FillRect(Rect(0,0,Photo.Picture.Width,Photo.Picture.Height));
Photo.Canvas.Brush.Color := oldcolor;
Modified := True;
end;

procedure TFPhoto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action := caFree;
DPEMain.CheckTool(DPEMain.MDIChildCount-1);
end;

procedure TFPhoto.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  SWarningText = 'Save changes to %s?';
begin
  if Modified then
  begin
    case MessageDlg(Format(SWarningText, [Caption]), mtConfirmation,
      [mbYes, mbNo, mbCancel], 0) of
      idYes: SaveImage;
      idCancel: CanClose := False;
    end;
  end;
end;

procedure TFPhoto.PhotoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Photo.Canvas.Brush.Color := DPEMain.BackColorP.Color;
FButton := Button;
case FButton of mbLeft:
                  begin
                   Photo.Canvas.Pen.Color := DPEMain.ForeColorP.Color;
                  end;
               mbRight:
                  begin
                   Photo.Canvas.Pen.Color := DPEMain.BackColorP.Color;
                  end;
end;
case DPEMain.Tag of 2:
    begin
      SaveUndo;
      Photo.Canvas.Pen.Width := SizePen;
      PenTool := True;
      Photo.Canvas.MoveTo(X, Y);
      Photo.Canvas.LineTo(X,Y);
      if Photo.Canvas.Pen.Width = 1 then Photo.Canvas.Pixels[X,Y] := Photo.Canvas.Pen.Color;
      Modified := True;
    end;
                    3:
    begin
         SaveUndo;
         Photo.Canvas.Pen.Width := SizeLine;
         Drawing := True;
         DrawingTool := dtLine;
         Modified := True;
    end;
                    4:
    begin
         SaveUndo;
         Photo.Canvas.Pen.Width := SizeBox;
         Drawing := True;
         case DPEMain.shapebox.itemindex of
           0: DrawingTool := dtRectangle;
           1: DrawingTool := dtRoundRect;
           2: DrawingTool := dtEllipse;
         end;
         case DPEMain.StyleBox.ItemIndex of
           0: Photo.Canvas.Brush.Style := bsClear;
           1: Photo.Canvas.Brush.Style := bsSolid;
           2: Photo.Canvas.Brush.Style := bsBDiagonal;
           3: Photo.Canvas.Brush.Style := bsFDiagonal;
           4: Photo.Canvas.Brush.Style := bsCross;
           5: Photo.Canvas.Brush.Style := bsDiagCross;
           6: Photo.Canvas.Brush.Style := bsHorizontal;
           7: Photo.Canvas.Brush.Style := bsVertical;
         end;
         Modified := True;
    end;
                    5:
    begin
         SaveUndo;
         Photo.Canvas.Brush.Style := bsSolid;
         if FButton = mbLeft then Photo.Canvas.Brush.Color := DPEMain.ForeColorP.Color
         else Photo.Canvas.Brush.Color := DPEMain.BackColorP.Color;
         Photo.Canvas.FloodFill(X,Y,Photo.Canvas.Pixels[x,y],fsSurface);
         Modified := True;
    end;
                    6:
    begin
         Dropper := True;
         DPEMain.SetMColor(Photo.Canvas.Pixels[X,Y]);
         if FButton = mbLeft then DPEMain.ForeColorP.Color := DPeMain.Mcolor.Color else
          DPeMain.BackColorP.Color := DPEMain.mcolor.Color;
    end;
                    7:
    begin
         if Photo.Picture.Bitmap.PixelFormat <> pf24bit then
           raise Exception.Create('Image must be a 24 bit bitmap!');
         SaveUndo;
         Modified := True;
         RetBMP := TBitmap.Create;
         RetBMP.PixelFormat := pf24bit;
         RetBMP.Width := Photo.Picture.Bitmap.Width;
         RetBMP.Height := Photo.Picture.Bitmap.Height;
         RetBMP.Canvas.Draw(0,0,Photo.Picture.Bitmap);
         case DPEMain.RModeBox.ItemIndex of
              0:
              begin
                   Lighten := True;
                   LightenAtXY(x,y);
              end;
              1:
              begin
                   Darken := True;
                   DarkenAtXY(x,y);
              end;
              2:
              begin
                   Soften := True;
                   SoftenATXY(x,y);
              end;
         end;
    end;
                    8:
    begin
         Mover := True;
    end;
                    9:
    begin
         if UA then
         begin
              if UndoBitmap.PixelFormat <> Photo.Picture.Bitmap.PixelFormat then
              begin
                 Application.MessageBox('The current image has a different pixel depth than the undo buffer. ' + UBASTR,PChar(Application.Title),MB_ICONWARNING);
                 Exit;
              end;
              if (UndoBitmap.Width <> Photo.Picture.Bitmap.Width) or (UndoBitmap.Height <> Photo.Picture.Bitmap.Height) then
              begin
                 Application.MessageBox('The current image has a different size than the undo buffer. ' + UBASTR,PChar(Application.Title),MB_ICONWARNING);
                 Exit;
              end;
             Eraser := True;
             RetBMP := TBitmap.Create;
             RetBMP.PixelFormat := photo.Picture.Bitmap.PixelFormat;
             RetBMP.Palette := photo.Picture.Bitmap.Palette;
             RetBMP.Width := Photo.Picture.Bitmap.Width;
             RetBMP.Height := Photo.Picture.Bitmap.Height;
             RetBMP.Canvas.Draw(0,0,Photo.Picture.Bitmap);
             DoUndoAtXY(X,Y);
         end
         else
         begin
            Application.MessageBox('There is nothing to undo. ' + UBASTR,PChar(Application.Title),MB_ICONWARNING);
            Exit;
         end;
    end;
end;
  Origin := Point(X, Y);
  MovePt := Origin;
end;

procedure TFPhoto.FitImage(x,y: integer);
var tmp : TRect;
    bx,by : boolean;
begin
if WindowState = wsNormal then
begin
  tmp := DPEMain.ClientRect;
  AutoScroll := False;
  bx := False;
  by := False;
  if x < tmp.Right then
  begin
       Width := x+9;
       bx := True;
  end else Width := tmp.Right-4;
  if y < tmp.Bottom then
  begin
       Height := y+27;
       by := True;
  end else Height := tmp.Bottom-52;
  if bx and (not by) then Width := Width +GetSystemMetrics(SM_CXHSCROLL)-1;
  if by and (not bx) then Height := Height + GetSystemMetrics(SM_CYHSCROLL);
  AutoScroll := True;
end;
end;
var JustCreated : Boolean;
procedure TFPhoto.FormCreate(Sender: TObject);
begin
Resized := False;
UA := False;
JustCreated := True;
PhotoName := dpemform.LoadedFile;
Photo.Picture.Bitmap.HandleType := bmDIB;
end;

procedure TFPhoto.FormActivate(Sender: TObject);
var s : string;
begin
case Photo.Picture.Bitmap.PixelFormat of
 pf24bit:
  begin
       s := '16 Million';
       DPEMain.MNUD1.Enabled := True;
       DPEMain.MNUD4.Enabled := True;
       DPEMain.MNUD8.Enabled := True;
       DPEMain.MNUi24.Enabled := False;
       DPEMain.MNUi8.Enabled := False;
       DPEMain.MNUi4.Enabled := False;
       DPEMain.MNUGreyScale.Enabled := True;
       DPEMain.MNUSP.Enabled := False;
       DPEMain.MNUResize.Enabled := True;
       DPEMain.MNUResample.Enabled := True;
       DPEMain.MNUEPal.Enabled := False;
       DPEMain.MNUABlend.Enabled := True;
  end;
 pf8bit :
  begin
       s :='256';
       DPEMain.MNUD1.Enabled := True;
       DPEMain.MNUD4.Enabled := True;
       DPEMain.MNUD8.Enabled := False;
       DPEMain.MNUi4.Enabled := False;
       DPEMain.MNUi24.Enabled := True;
       DPEMain.MNUi8.Enabled := False;
       DPEMain.MNUGreyScale.Enabled := False;
       DPEMain.MNUSP.Enabled := True;
       DPEMain.MNUResize.Enabled := False;
       DPEMain.MNUResample.Enabled := False;
       DPEMain.MNUEPal.Enabled := True;
       DPEMain.MNUABlend.Enabled := False;
  end;
 pf4bit :
  begin
       s := '16';
       DPEMain.MNUD1.Enabled := True;
       DPEMain.MNUD4.Enabled := False;
       DPEMain.MNUD8.Enabled := False;
       DPEMain.MNUi4.Enabled := False;
       DPEMain.MNUi24.Enabled := True;
       DPEMain.MNUi8.Enabled := True;
       DPEMain.MNUGreyScale.Enabled := False;
       DPEMain.MNUSP.Enabled := True;
       DPEMain.MNUResize.Enabled := False;
       DPEMain.MNUResample.Enabled := False;
       DPEMain.MNUEPal.Enabled := True;
       DPEMain.MNUABlend.Enabled := False;
  end;
 //pf32bit: s := '32 Bit';
 pf1bit :
  begin
       s := '2';
       DPEMain.MNUD1.Enabled := False;
       DPEMain.MNUD4.Enabled := False;
       DPEMain.MNUD8.Enabled := False;
       DPEMain.MNUi4.Enabled := True;
       DPEMain.MNUi24.Enabled := True;
       DPEMain.MNUi8.Enabled := True;
       DPEMain.MNUGreyScale.Enabled := False;
       DPEMain.MNUSP.Enabled := True;
       DPEMain.MNUResize.Enabled := False;
       DPEMain.MNUResample.Enabled := False;
       DPEMain.MNUEPal.Enabled := True;
       DPEMain.MNUABlend.Enabled := False;
  end;
 {pf16bit: s := '16 bit';
 pf15bit: s := '15 bit';
 pfCustom : s := 'Custom';}
 pfDevice :
  begin
       s := 'Device';
       DPEMain.MNUD1.Enabled := True;
       DPEMain.MNUD4.Enabled := True;
       DPEMain.MNUD8.Enabled := True;
       DPEMain.MNUi4.Enabled := True;
       DPEMain.MNUi24.Enabled := True;
       DPEMain.MNUi8.Enabled := True;
       DPEMain.MNUGreyScale.Enabled := False;
       DPEMain.MNUResize.Enabled := False;
       DPEMain.MNUResample.Enabled := False;
       DPEMain.MNUEPal.Enabled := False;
       DPEMain.MNUABlend.Enabled := False;
  end;
end;
//DPEMain.MNUSave.Enabled := Saved;
if not JustCreated then
begin
  DPEMain.MNUReload.Enabled := Saved;
  DPEMain.MNUDelete.Enabled := Saved;
  DPEMain.MNUUndo.Enabled := UA;
  DPEMain.FLUndo.Enabled := UA;
  DPEMain.StatusBar.Panels[2].Text := IntToStr(Photo.Picture.Width) + 'x' + IntToStr(Photo.Picture.Height) + ' x '+ s+ ' Colors';
  {DPEMain.ForeColorP.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
  DPEMain.ForeColorP.Palette := Photo.Picture.Bitmap.Palette;
  DPEMain.BackColorP.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
  DPEMain.BackColorP.Palette := Photo.Picture.Bitmap.Palette;}
end;
JustCreated := False;
end;

procedure TFPhoto.PhotoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
DPEMain.StatusBar.Panels[1].Text := IntToStr(X) + ',' + IntToStr(Y);
if PenTool then Photo.Canvas.LineTo(x,y);
if Drawing then
begin
     DrawShape(Origin, MovePt, pmNotXor);
     MovePt := Point(X, Y);
     DrawShape(Origin, MovePt, pmNotXor);
end;
if Dropper then
begin
   DPEMain.SetMColor(Photo.Canvas.Pixels[X,Y]);
   if FButton = mbLeft then DPEMain.ForeColorP.Color := DPeMain.Mcolor.Color else
     DPeMain.BackColorP.Color := DPEMain.mcolor.Color;
end;
if Mover then
begin
   HorzScrollBar.Position := HorzScrollBar.Position - (X - Origin.X);
   VertScrollBar.Position := VertScrollBar.Position - (Y - Origin.Y);
end;
if Eraser then DoUndoAtXY(x,y);
if Lighten then LightenAtXY(x,y);
if Darken then DarkenAtXY(x,y);
if Soften then SoftenAtXY(x,y);
end;

procedure TFPhoto.DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
begin
  with Photo.Canvas do
  begin
    Pen.Mode := AMode;
    case DrawingTool of
      dtLine: begin
                MoveTo(TopLeft.X, TopLeft.Y);
                LineTo(BottomRight.X, BottomRight.Y);
              end;
      {dtKrivu :  arc(topleft.x,topleft.y,bottomright.x,bottomright.y,topleft.x,topleft.y,topleft.x,topleft.y);
      dtLinija: chord(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y,topleft.x,topleft.x,bottomright.x,bottomright.y);
      dtTekst:begin
                   if upisi.Angle.position = 0 then Textout(TopLeft.X,TopLeft.Y,upisi.tekst.text)
                   else CanvasTextOutAngle(slika.Canvas,TopLeft.X,TopLeft.Y,upisi.Angle.Position * 10,upisi.tekst.Text);
              end;}
      dtRectangle: Rectangle(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
      dtEllipse: Ellipse(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
      dtRoundRect: RoundRect(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y,
        (TopLeft.X - BottomRight.X) div 2, (TopLeft.Y - BottomRight.Y) div 2);
      //dtSquare: Rectangle(TopLeft.X, TopLeft.Y, BottomRight.X,BottomRight.Y);
    end;
  end;
end;

procedure TFPhoto.SysMenuHint(var Message : TWMMenuSelect);
begin
If (message.Menuflag and MF_SysMenu) = MF_SysMenu then
begin
 case Message.IDItem of
     0: Application.Hint := '';
     SC_Close: Application.Hint := 'Close the active window and prompts to save documents';
     SC_MAximize: Application.Hint := 'Enlarge the window to the full size';
     sc_Minimize: Application.Hint := 'Reduces window to an icon';
     sc_Restore: Application.Hint := 'Restores the window to the normal size';
     sc_Move: Application.Hint := 'Change the window position';
     sc_Size: Application.Hint := 'Change the window size';
     SC_NextWindow: Application.Hint := 'Switches to the next document';
 else
 Application.Hint := '';
end;
Message.result  := 0;
end
else inherited;
end;

procedure TFPhoto.PhotoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if drawing then
begin
     DrawShape(Origin, Point(X, Y), pmCopy);
     Drawing := False;
end;
Mover := False;
PenTool := False;
Dropper := False;
if Lighten or Darken or Soften or Eraser then RetBMP.Free;
Lighten := False;
Darken := False;
Soften := False;
Eraser := False;
end;

procedure TFPhoto.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
   37: HorzScrollBar.Position := HorzScrollBar.Position-1;
   39: HorzScrollBar.Position := HorzScrollBar.Position+1;
   38: VertScrollBar.Position := VertScrollBar.Position-1;
   40: VertScrollBar.Position := VertScrollBar.Position+1;
   33: VertScrollBar.Position := VertScrollBar.Position-20;
   34: VertScrollBar.Position := VertScrollBar.Position+20;
   35: HorzScrollBar.Position := HorzScrollBar.Position+20;
   36: HorzScrollBar.Position := HorzScrollBar.Position-20;
end;
end;

procedure TFPhoto.SaveUndo;
begin
  if dpemform.UndoDisabled then Exit;
  if UA {UndoBitmap <> nil} then
  //begin
    UndoBitmap.Free;
    //UndoBitmap := nil;
  //end;
  UndoBitmap := TBitmap.Create;
  UndoBitmap.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
  UndoBitmap.Palette := Photo.Picture.Bitmap.Palette;
  UndoBitmap.Width := Photo.Picture.Bitmap.Width;
  UndoBitmap.Height := Photo.Picture.Bitmap.Height;
  UndoBitmap.Canvas.Draw(0,0,Photo.Picture.Bitmap);
  UA := True;
  FormActivate(Self);
end;

procedure TFPhoto.DoUndo;
begin
 UA := False;
 Photo.Picture.Bitmap.Assign(UndoBitmap);
 UndoBitmap.Free;
 //UndoBitmap := nil;
 if Resized then FitImage(Photo.Picture.Width, Photo.Picture.Height);
 Resized := False;
 FormActivate(Self);
end;

{new functions}
function GetMediaContrast(bitmap:TBitmap):integer;
var
   bmp:windows.tbitmap;
   q,w,h:integer;
   mm:integer;
   mt:integer;
   x,y:integer;
begin
   getobject(Bitmap.handle,sizeof(bmp),@bmp);
   if bmp.bmBitsPixel<> 24 then exit;
   q:=1;
   mt:=0;
   w:=bmp.bmWidth*3-1;
   h:=bmp.bmHeight-1;
   for y:=0 to h do
     for x:=0 to w do
       with bmp do
       begin
            mt:=mt+pbyte(cardinal(bmBits)+x+y*bmWidthBytes)^;
           inc(q);
       end;
   mm:=trunc(mt) div q;
   result:=mm;
end;

procedure Contrast(bitmap:TBitmap;vv:integer;mm:integer);
var
   bmp:windows.tbitmap;
   e,w,h:integer;
   vd:double;
   x,y:integer;
begin
   getobject(Bitmap.handle,sizeof(bmp),@bmp);
   if bmp.bmBitsPixel<>24 then Exit;
   if vv>=0 then vd:=1+vv/10
      else vd:= 1-sqrt(-vv)/10;
   w:=bmp.bmWidth*3-1;
   h:=bmp.bmHeight-1;
   for y:=0 to h do
   begin
       DPEMain.ProgressBar.Position := trunc(100*(y/h));
       for x:=0 to w do
         with bmp do
         begin
             e:=mm+trunc((pbyte(cardinal(bmBits)+x+y*bmWidthBytes)^-mm)*vd);
             if e>255 then e:=255
               else if e<0 then e:=0;
             pbyte(cardinal(bmBits)+x+y*bmWidthBytes)^:=byte(e);
         end;
   end;
end;

procedure TFPhoto.ChangeContrast(value : integer;forreel : boolean);
var tmp : TBitmap;
begin
 if value = 0 then Exit;
 DPEMain.ProgressBar.Visible := True;
 if forreel then SaveUndo;
 tmp := TBitmap.Create;
 tmp.Assign(Photo.Picture.Bitmap);
 tmp.PixelFormat := pf24bit;
 Contrast(tmp,value,GetMediaContrast(tmp));
 Photo.Canvas.Draw(0,0,tmp);
 tmp.Free;
 DPEMain.ProgressBar.Visible := False;
 Modified := True;
end;

{procedure TFPhoto.AdequateSize(bitmap : tbitmap;fangle : double);
var
   xshearfac, yshearfac:single;
   cols,rows,tempcols,yshearjunk,Height,x2shearjunk,Width:integer;
   tmp : TBitmap;
begin
fangle:=fangle*PI/180;
xshearfac:= sin(fangle/2) / cos(fangle/2);
if xshearfac<0 then
xshearfac:= -xshearfac;
yshearfac:=sin( fangle );
if yshearfac<0 then yshearfac:= -yshearfac;
cols:=Bitmap.Width;
rows:=Bitmap.Height;
//xelrow:= allocmem(cols*3);
tempcols:= round( rows * xshearfac + cols + 0.999999) ;
yshearjunk:= round( ( tempcols - cols ) * yshearfac );
Height:= round( tempcols*yshearfac+rows+0.999999 );
x2shearjunk:= round( (Height-rows-yshearjunk)*xshearfac );
Height := round( Height-(2 * yshearjunk) );
Width := round( Height * xshearfac + tempcols + 0.999999 - 2 * x2shearjunk );
Resized := True;
tmp := TBitmap.Create;
tmp.PixelFormat := Photo.Picture.Bitmap.PixelFormat;
tmp.Palette := Photo.Picture.Bitmap.Palette;
tmp.Width := width;
tmp.Height := Height;
if DPEMain.BackColorP.Color <> clWhite then
begin
     tmp.Canvas.Brush.Color := DPEMain.BackColorP.Color;
     tmp.Canvas.FillRect(Rect(0,0,Width,Height));
end;
tmp.Canvas.Draw(tmp.Width div 2 -photo.picture.width div 2,tmp.Height div 2 - photo.picture.height div 2, photo.Picture.Bitmap);
Bitmap.Assign(tmp);
tmp.Free;
end;}

end.
