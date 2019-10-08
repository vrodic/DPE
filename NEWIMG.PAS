unit newimg;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls,SysUtils,Registry, ComCtrls;

type
  TNewImgF = class(TForm)
    Bevel: TBevel;
    xresed: TEdit;
    yresed: TEdit;
    sir: TLabel;
    visina: TLabel;
    OKBtn: TButton;
    cb: TComboBox;
    xcap: TLabel;
    Cancel: TButton;
    precap: TLabel;
    xres: TUpDown;
    yres: TUpDown;
    Itype: TComboBox;
    ITypeCap: TLabel;
    bcolorcap: TLabel;
    bcolor: TComboBox;
    mcap: TLabel;
    mqcap: TLabel;
    procedure MemREQ(Sender : TObject);
    procedure init(Sender: TObject);
    procedure cbChange(Sender: TObject);
    procedure resedClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewImgF: TNewImgF;
function ShowNEWDLG(var W,H,BitDepth,BackColor : word) :  integer;

implementation
uses dpemform;
{$R *.DFM}

function ShowNEWDLG(var W,H,BitDepth,BackColor : word) :  integer;
begin
  with TNEWIMGF.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
         W := xres.Position;
         H := yres.Position;
         BitDepth := IType.ItemIndex;
         BackColor := BColor.ItemIndex;
         RegIniFile := TRegIniFile.Create(DPEIniName);
         RegIniFile.WriteInteger('Image','X',xres.position);
         RegIniFile.WriteInteger('Image','Y',yres.position);
         RegIniFile.WriteInteger('Image','Depth',itype.ItemIndex);
         RegIniFile.WriteInteger('Image','Background',bcolor.ItemIndex);
         RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;
procedure TNewImgF.MemREQ(Sender : TObject);
var m : Real;
begin
  m := 0;
  case itype.ItemIndex of
   0: m := 0.125;
   1: m := 0.5;
   2,3: m := 1;
   4: m := 3;
  end;
  mqcap.Caption := FormatFloat('0.0',(xres.Position * yres.Position *m)/1024) + ' KB';
end;

procedure TNewImgF.init(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
xres.Position := RegIniFile.ReadInteger('Image','X', Screen.Width);
yres.Position := RegIniFile.ReadInteger('Image','Y', Screen.Height);
itype.ItemIndex := RegIniFile.ReadInteger('Image','Depth',4);
bcolor.ItemIndex := RegIniFile.ReadInteger('Image','Background', 0);
RegIniFile.Free;
cb.ItemIndex := 9;
MemReq(Sender);
end;

procedure TNewImgF.cbChange(Sender: TObject);
begin
case cb.itemindex of
     0:
       begin
            xres.Position := Screen.Width;
            yres.Position := screen.Height;
       end;
     1:
       begin
            xres.Position := 320;
            yres.Position := 200;
       end;
     2:
       begin
            xres.Position := 320;
            yres.Position := 240;
       end;
     3:
       begin
            xres.Position := 640;
            yres.Position := 400;
       end;
     4:
       begin
            xres.Position := 640;
            yres.Position := 480;
       end;
     5:
       begin
            xres.Position := 800;
            yres.Position := 600;
       end;
     6:
       begin
            xres.Position := 1024;
            yres.Position := 768;
       end;
     7:
       begin
            xres.Position := 1280;
            yres.Position := 1024;
       end;
     8:
       begin
            xres.Position := 1600;
            yres.Position := 1200;
       end;
end;
end;

procedure TNewImgF.resedClick(Sender: TObject);
begin
cb.ItemIndex := 9;
end;


end.
