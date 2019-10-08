unit ccun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TCCDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    RCCAP: TLabel;
    GCCAP: TLabel;
    BCCAP: TLabel;
    RCMB: TComboBox;
    GCMB: TComboBox;
    BCMB: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CCDLG: TCCDLG;

function ShowCCDLG(var RIndex, GIndex, BIndex : integer) : integer;

implementation


{$R *.DFM}

uses dpemform,photo;

var
   tstr : TStringList;

function ShowCCDLG(var RIndex, GIndex, BIndex : integer) : integer;
begin
  with TCCDlg.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
         RIndex := StrToInt(tstr.Strings[RCMB.ItemIndex]);
         GIndex := StrToInt(tstr.Strings[GCMB.ItemIndex]);
         BIndex := StrToInt(tstr.Strings[BCMB.ItemIndex]);
    end;
  finally
    Free;
  end;
end;

procedure TCCDLG.FormCreate(Sender: TObject);
var i : integer;
    t : TFPhoto;
    n : integer;
begin
tstr := TStringList.Create;
n := -1;
for I := 0 to DPEMain.MDIChildCount-1 do
begin
     t := TFPhoto(DPEMain.MDIChildren[i]);
     if t.Photo.Picture.Bitmap.PixelFormat = pf8bit then
     begin
          t := TFPhoto(DPEMain.MDIChildren[i]);
          RCMB.Items.Add(t.Caption);
          GCMB.Items.Add(t.Caption);
          BCMB.Items.Add(t.Caption);
          tstr.Add(IntToStr(i));
          inc(n);
     end;
end;
RCMB.ItemIndex := n;
if n >= 1 then GCMB.Itemindex := RCMB.ItemIndex -1 else GCMB.ItemIndex := n;
if n >= 2 then BCMB.ItemIndex := GCMB.ItemIndex -1 else BCMB.ItemIndex := GCMB.ItemIndex;
end;

procedure TCCDLG.FormDestroy(Sender: TObject);
begin
tstr.Free;
end;

end.
