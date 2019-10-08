program dpe;

uses
  Forms,
  dpemform in 'dpemform.pas' {DPEMain},
  photo in 'photo.pas' {FPhoto},
  newimg in 'Newimg.pas' {NewImgF},
  splash in 'splash.pas' {SplashScreen},
  FS_UN in 'FS_UN.pas' {FullSCR};

{$R *.RES}

begin
  SplashScreen := TSplashScreen.Create(Application);
  SplashScreen.Show;
  SplashScreen.Update;
  Application.Title := 'Digital Photo Editor';
  Application.Initialize;
  Application.CreateForm(TDPEMain, DPEMain);
  Application.CreateForm(TNewImgF, NewImgF);
  Application.CreateForm(TFullSCR, FullSCR);
  SplashScreen.Hide;
  SplashScreen.Free;
  Application.Run;
end.
