unit newimg;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls,SysUtils,Registry, ComCtrls;

type
  TNewImgF = class(TForm)
    okvir: TBevel;
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
    procedure init(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbChange(Sender: TObject);
    procedure resedClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewImgF: TNewImgF;
implementation
uses dpemform;
{$R *.DFM}

procedure TNewImgF.init(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
xres.Position := RegIniFile.ReadInteger('Image','X', Screen.Width);
yres.Position := RegIniFile.ReadInteger('Image','Y', Screen.Height);
RegIniFile.Free;
cb.ItemIndex := 9;
end;

procedure TNewImgF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
RegIniFile.WriteInteger('Image','X',xres.position);
RegIniFile.WriteInteger('Image','Y',yres.position);
RegIniFile.Free;
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
