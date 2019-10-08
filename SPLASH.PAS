unit splash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TSplashScreen = class(TForm)
    Bevel: TBevel;
    TitleCAP: TLabel;
    StatCAP: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SplashScreen: TSplashScreen;

implementation

{$R *.DFM}

end.
