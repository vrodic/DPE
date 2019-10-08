unit adclrun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  TADCLRDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    REDED: TEdit;
    RedS: TUpDown;
    REDCAP: TLabel;
    GreenED: TEdit;
    GreenS: TUpDown;
    GreenCAP: TLabel;
    BlueED: TEdit;
    BlueS: TUpDown;
    BlueCAP: TLabel;
    PreviewBTN: TButton;
    procedure PreviewBTNClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

  public
    { Public declarations }
  end;

var
  ADCLRDLG: TADCLRDLG;

function ShowADCLRDLG(var r,g,b : integer; Mode : integer) :  integer;

implementation

{$R *.DFM}
uses DPEMForm,Photo;

var tft : TFPhoto;
    tmpbmp : TBitmap;
    modi : boolean;
    hpal : HPalette;
    dmode : integer;
function ShowADCLRDLG(var r,g,b : integer; Mode : integer) :  integer;
begin
  dmode := mode;
  with TADCLRDLG.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
     case dmode of
      0: // RGB adjust dialog
      begin
         r := Reds.Position;
         g := GreenS.Position;
         b := BlueS.Position;
         RegIniFile := TRegIniFile.Create(DPEIniName);
         RegIniFile.WriteInteger('RGBAdjust','R',RedS.Position);
         RegIniFile.WriteInteger('RGBAdjust','B',BlueS.Position);
         RegIniFile.WriteInteger('RGBAdjust','G',GreenS.Position);
         RegIniFile.Free;
      end;
      1: // HSV adjust dialog
      begin
         r := RedS.Position;
         g := GreenS.Position;
         b := BlueS.Position;
         RegIniFile := TRegIniFile.Create(DPEIniName);
         RegIniFile.WriteInteger('HSVAdjust','H',RedS.Position);
         RegIniFile.WriteInteger('HSVAdjust','S',GreenS.Position);
         RegIniFile.WriteInteger('HSVAdjust','V',BlueS.Position);
         RegIniFile.Free;
      end;
     end;
    end;
  finally
    Free;
  end;
end;

procedure TADCLRDLG.PreviewBTNClick(Sender: TObject);
begin
modi := True;
tmpbmp.Palette := hpal;
tft.Photo.Canvas.Draw(0,0,tmpbmp);
case dmode of
 0: tft.RGBAdjustColor(Reds.Position,GreenS.Position, BlueS.Position,false);
 1: tft.HSVAdjustColor(Reds.Position,GreenS.Position, BlueS.Position,false);
end;
end;

procedure TADCLRDLG.CancelBtnClick(Sender: TObject);
begin
if modi then tft.Photo.Picture.Bitmap.Assign(tmpbmp);
end;

procedure TADCLRDLG.FormCreate(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
case dmode of
  0:
  begin
       RedS.Position := RegIniFile.ReadInteger('RGBAdjust','R',0);
       BlueS.Position := RegIniFile.ReadInteger('RGBAdjust','B',0);
       GreenS.Position := RegIniFile.ReadInteger('RGBAdjust','G',0);
  end;
  1:
  begin
       REDS.Max := 359;
       REDS.Min := -359;
       REDCap.Caption :=   '&H:';
       GreenCap.Caption := '&S:';
       BlueCap.Caption :=  '&V:';
       RedED.Left := 40;
       GreenED.Left := 40;
       BlueED.Left := 40;
       Caption := 'HSV Adjust';
       RedS.Position := RegIniFile.ReadInteger('HSVAdjust','H',0);
       GreenS.Position := RegIniFile.ReadInteger('HSVAdjust','S',0);
       BlueS.Position := RegIniFile.ReadInteger('HSVAdjust','V',0);
  end;
end;
RegIniFile.Free;
modi := False;
tft := TFPhoto(DPEMain.ActiveMDIChild);
tmpbmp := TBitmap.Create;
tmpbmp.PixelFormat := tft.Photo.Picture.Bitmap.PixelFormat;
hpal := tft.Photo.Picture.Bitmap.Palette;
tmpbmp.Palette := hpal;
tmpbmp.Width := tft.Photo.Picture.Width;
tmpbmp.Height := tft.Photo.Picture.Height;
tmpbmp.Canvas.Draw(0,0,tft.Photo.Picture.Bitmap);
end;

procedure TADCLRDLG.FormClose(Sender: TObject; var Action: TCloseAction);
begin
tmpbmp.Free;
end;

end.
