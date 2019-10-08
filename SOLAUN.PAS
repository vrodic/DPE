unit solaun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls;

type
  TSolarizeDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    Thresholdcap: TLabel;
    thrUD: TUpDown;
    thred: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SolarizeDLG: TSolarizeDLG;

function ShowSOLADLG(var t : integer) :  integer;

implementation

{$R *.DFM}

function ShowSOLADLG(var t : integer) :  integer;
begin
  with TSolarizeDLG.Create(Application) do
  try
    result := ShowModal;
    t := thrUD.Position;
  finally
    Free;
  end;
end;

end.
