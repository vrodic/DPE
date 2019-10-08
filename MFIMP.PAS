unit MFImp;
{ Meta/Vector Importing Dialog }
interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, ComCtrls;

type
  TWMFImp = class(TForm)
    OKBTN: TButton;
    oszgrp: TGroupBox;
    impszgrp: TGroupBox;
    wpcap: TLabel;
    wip: TLabel;
    hpcap: TLabel;
    hip: TLabel;
    wipcap: TLabel;
    hipcap: TLabel;
    wed: TEdit;
    hed: TEdit;
    wud: TUpDown;
    hud: TUpDown;
  end;

var
  WMFImp: TWMFImp;
procedure ShowWMFImp(FileName : String;Picture: TPicture);

implementation
{$R *.DFM}

uses DpemForm,Photo;

procedure ShowWMFImp(FileName : String;Picture: TPicture);
var Pict : TPicture;
begin
  with TWMFImp.Create(Application) do
  begin
      Pict := TPicture.Create;
      try
         Pict.LoadFromFile(FileName);
         wip.Caption := IntToStr(Pict.Width);
         hip.Caption := IntToStr(Pict.Height);
         wud.Position := Pict.Width;
         hud.Position := Pict.Height;
         ShowModal;
         Picture.Bitmap.PixelFormat := pf24bit;
         Picture.Bitmap.Width := wud.Position;
         Picture.Bitmap.Height := hud.Position;
         Picture.Bitmap.Canvas.StretchDraw(Rect(0,0,wud.Position+1,hud.Position+1),Pict.Graphic);
      finally
         Pict.Free;
         DPEMain.ProgressBar.Visible := False;
         Screen.Cursor := crDefault;
         Free;
      end;
  end;
end; { ShowWMFImp }
end. { MFImp }
