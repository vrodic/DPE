program dpe;

uses
  Forms,
  dpemform in 'dpemform.pas' {DPEMain},
  photo in 'photo.pas' {FPhoto},
  newimg in 'Newimg.pas' {NewImgF},
  splash in 'splash.pas' {SplashScreen},
  FS_UN in 'FS_UN.pas' {FullSCR},
  rotun in 'rotun.pas' {RotateDLG},
  adclrun in 'adclrun.pas' {ADCLRDLG},
  ldun in 'Ldun.pas' {LDDialog},
  solaun in 'solaun.pas' {SolarizeDLG},
  abox in 'Abox.pas' {AboutBox},
  ffpun in 'ffpun.pas' {ffpfrm},
  rszun in 'rszun.pas' {rszDLG},
  epun in 'epun.pas' {epfrm},
  crszun in 'crszun.pas' {crszfrm},
  ablendun in 'ablendun.pas' {ablendDLG},
  MFImp in 'Mfimp.pas' {WMFImp},
  btnzun in 'btnzun.pas' {btneffdlg},
  adbrdrun in 'adbrdrun.pas' {AddBRDRDLG},
  prun in 'prun.pas' {prDLG},
  conun in 'conun.pas' {AContrastDLG},
  ccun in 'ccun.pas' {CCDLG};

{$R *.RES}

begin
  SplashScreen := TSplashScreen.Create(Application);
  SplashScreen.Show;
  SplashScreen.Update;
  Application.Title := 'Digital Photo Editor';
  Application.Initialize;
  Application.CreateForm(TDPEMain, DPEMain);
  SplashScreen.Hide;
  SplashScreen.Free;
  Application.Run;
end.
