unit epun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, PalEd;

type
  Tepfrm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    PaletteEdit: TPaletteEdit;
    ICap: TLabel;
    idxcap: TLabel;
    CCAP: TLabel;
    cicap: TLabel;
    RevertBTN: TButton;
    procedure PaletteEditMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure RevertBTNClick(Sender: TObject);
    procedure PaletteEditColorChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  epfrm: Tepfrm;

function ShowEPFrm(var TheColor : TColor; SelectPal : boolean) : integer;

implementation

{$R *.DFM}


uses dpemform,photo;

const SELSTR = 'Select Color From Palette';
var tft : TFPhoto;
    Colors : integer;
function ShowEPFrm(var TheColor : TColor; SelectPal : boolean) : integer;
begin
  with TEPFrm.Create(Application) do
  try
    if SelectPal then Caption := SELSTR;
    result := ShowModal;
    if result = mrOk then TheColor := PaletteEdit.CurrentColor;
  finally
    Free;
  end;
end;

procedure Tepfrm.PaletteEditMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
PaletteEditColorChange(Sender);
end;

procedure Tepfrm.FormCreate(Sender: TObject);
var  t : Tcolor;
     i : integer;
     pal : TMaxLogPalette;
begin
tft := TFPhoto(DPEMain.ActiveMDIChild);
Colors := 256;
case tft.Photo.Picture.Bitmap.PixelFormat of
     pf4bit : Colors := 16;
     pf1bit  : Colors := 2;
end;
GetPaletteEntries(tft.Photo.Picture.Bitmap.Palette,0,Colors,Pal.palpalentry);
PaletteEdit.MaxColors := Colors;
PaletteEdit.SetColor(0,RGB(pal.palpalentry[0].peBlue,pal.palpalentry[0].peGreen,pal.palpalentry[0].peRed));
for i := 1 to Colors-1 do
begin
     PaletteEdit.SetColor(i,RGB(pal.palpalentry[i].peRed,pal.palpalentry[i].peGreen,pal.palpalentry[i].peBlue));
end;
idxCap.Caption := inttostr(PaletteEdit.CurrentColorIndex);
t := PaletteEdit.CurrentColor;
cicap.Caption := ' R: ' + IntToStr(GetRValue(ColorToRGB(t))) + ', G: ' + Inttostr(GetGValue(ColorToRGB(t))) +', B: ' +InttoStr(GetBValue(ColorToRGB(t)));
end;

procedure Tepfrm.OKBtnClick(Sender: TObject);
var pal : TMAxLogPalette;
    i : integer;
    t : TColor;
    hpal : hpalette;
begin
pal.palVersion := $300;
pal.palNumEntries := Colors;
t := PaletteEdit.GetColor(0);
// I dont know what bug is this, but first palette
// entry is in BGR order, so this workaround is
// applied
Pal.Palpalentry[0].peBlue := GetRvalue(ColorToRGB(t));
Pal.Palpalentry[0].peGreen := GetGvalue(ColorToRGB(t));
Pal.Palpalentry[0].peRed := GetBvalue(ColorToRGB(t));
Pal.Palpalentry[0].peFlags := 0;
for i := 1 to Colors-1 do
begin
     t := PaletteEdit.GetColor(i);
     Pal.Palpalentry[i].peBlue := GetBvalue(ColorToRGB(t));
     Pal.Palpalentry[i].peGreen := GetGvalue(ColorToRGB(t));
     Pal.Palpalentry[i].peRed := GetRvalue(ColorToRGB(t));
     Pal.Palpalentry[i].peFlags := 0;
end;
hpal := CreatePalette(PLogPalette(@Pal)^);
tft.ApplyPalette(hpal);
end;

procedure Tepfrm.RevertBTNClick(Sender: TObject);
begin
FormCreate(Sender);
PaletteEdit.Repaint;
end;

procedure Tepfrm.PaletteEditColorChange(Sender: TObject);
var t : TColor;
begin
idxCap.Caption := inttostr(PaletteEdit.CurrentColorIndex);
t := PaletteEdit.CurrentColor;
cicap.Caption := ' R: ' + IntToStr(GetRValue(ColorToRGB(t))) + ', G: ' + Inttostr(GetGValue(ColorToRGB(t))) +', B: ' +InttoStr(GetBValue(ColorToRGB(t)));
end;

end.
