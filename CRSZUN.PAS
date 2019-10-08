unit crszun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, Registry;

type
  Tcrszfrm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    widthed: TEdit;
    wcap: TLabel;
    hcap: TLabel;
    highted: TEdit;
    centerchk: TCheckBox;
    widthud: TUpDown;
    heightud: TUpDown;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  crszfrm: Tcrszfrm;
function ShowCRSZ(var w,h : word; var center : boolean): integer;

implementation

uses dpemform;

function ShowCRSZ(var w,h : word; var center : boolean): integer;
var RegIniFile : TRegIniFile;
begin
  with Tcrszfrm.Create(Application) do
  try
    RegIniFile := TRegIniFile.Create(DPEIniName);
    widthud.Position := RegIniFile.ReadInteger('ResizeCanvas','Width',w);
    heightud.Position := RegIniFile.ReadInteger('ResizeCanvas','Height',h);
    centerchk.Checked := RegIniFile.ReadBool('ResizeCanvas','Center',False);
    RegIniFile.Free;
    Result := ShowModal;
    if Result = mrOK then
    begin
      w := widthud.Position;
      h := heightud.Position;
      center := centerchk.Checked;
      RegIniFile := TRegIniFile.Create(DPEIniName);
      RegIniFile.WriteInteger('ResizeCanvas','Width',widthud.Position);
      RegIniFile.WriteInteger('ResizeCanvas','Height',heightud.Position);
      RegIniFile.WriteBool('ResizeCanvas','Center',centerchk.Checked);
      RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;
{$R *.DFM}

end.
