unit conun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls,Registry, ComCtrls;

type
  TAContrastDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    PreviewBTN: TButton;
    TrackBar: TTrackBar;
    val: TLabel;
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
  AContrastDLG: TAContrastDLG;

function ShowContraDLG(var value : integer) :  integer;

implementation

{$R *.DFM}

uses dpemform,photo;

var tmpbmp : TBitmap;
    modi : boolean;
    tft : TFPhoto;
    hpal : HPalette;

function ShowContraDLG(var value : integer) :  integer;
begin
  with TAContrastDLG.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
        value := TrackBar.Position;
        RegIniFile := TRegIniFile.Create(DPEIniName);
        RegIniFile.WriteInteger('BC','Contrast',TrackBar.Position);
        RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;
procedure TAContrastDLG.TrackBarChange(Sender: TObject);
begin
val.Caption := IntToStr(TrackBar.Position) + '%';
end;

procedure TAContrastDLG.PreviewBTNClick(Sender: TObject);
begin
modi := True;
tmpbmp.Palette := hpal;
tft.Photo.Canvas.Draw(0,0,tmpbmp);
tft.ChangeContrast(Trackbar.Position,false);
end;

procedure TAContrastDLG.CancelBtnClick(Sender: TObject);
begin
if modi then tft.Photo.Picture.Bitmap.Assign(tmpbmp);
end;

procedure TAContrastDLG.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
tmpbmp.Free;
end;

procedure TAContrastDLG.FormCreate(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
TrackBar.Position := RegIniFile.ReadInteger('BC','Contrast',0);
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
