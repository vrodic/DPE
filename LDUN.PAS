unit ldun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  TLDDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    TrackBar: TTrackBar;
    kol: TLabel;
    PreviewBTN: TButton;
    procedure TrackBarChange(Sender: TObject);
    procedure PreviewBTNClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LDDialog: TLDDialog;
function ShowLDDLG(var gamma : integer) :  integer;

implementation

uses dpemform, Photo;

{$R *.DFM}

var tmpbmp : TBitmap;
    modi : boolean;
    tft : TFPhoto;
    hpal : HPalette;

function ShowLDDLG(var gamma : integer) :  integer;
begin
  with TLDDialog.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
        gamma := TrackBar.Position;
        RegIniFile := TRegIniFile.Create(DPEIniName);
        RegIniFile.WriteInteger('BC','Gamma',TrackBar.Position);
        RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;

procedure TLDDialog.TrackBarChange(Sender: TObject);
begin
kol.Caption := IntToStr(TrackBar.Position);
end;

procedure TLDDialog.PreviewBTNClick(Sender: TObject);
begin
modi := True;
tmpbmp.Palette := hpal;
tft.Photo.Canvas.Draw(0,0,tmpbmp);
tft.GammaImage(Trackbar.Position,false);
end;

procedure TLDDialog.CancelBtnClick(Sender: TObject);
begin
if modi then tft.Photo.Picture.Bitmap.Assign(tmpbmp);
end;

procedure TLDDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
tmpbmp.Free;
end;

procedure TLDDialog.FormCreate(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
TrackBar.Position := RegIniFile.ReadInteger('BC','Gamma',0);
RegIniFile.Free;
TrackBarChange(Sender);
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

end.
