unit ablendun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  TablendDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    AICAP: TLabel;
    ICMB: TComboBox;
    PSRCCAP: TLabel;
    ped: TEdit;
    pud: TUpDown;
    pcap: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ablendDLG: TablendDLG;
function ShowABLENDDlG(var MDIIndex : integer; var Grade : byte) : integer;

implementation


{$R *.DFM}
uses dpemform,photo;
function ShowABLENDDlG(var MDIIndex : integer; var Grade : byte) : integer;
begin
  with TABLENDDlg.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
         MDIIndex := ICMB.ItemIndex;
         Grade := pud.Position;
         RegIniFile := TRegIniFile.Create(DPEIniName);
         RegIniFile.WriteInteger('AlphaBlend','Percent',PUD.Position);
         RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;
procedure TablendDLG.FormCreate(Sender: TObject);
var i : integer;
    t : TFPhoto;
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
PUD.Position := RegIniFile.ReadInteger('AlphaBlend','Percent',50);
RegIniFile.Free;
for I := 0 to DPEMain.MDIChildCount-1 do
begin
     t := TFPhoto(DPEMain.MDIChildren[i]);
     ICMB.Items.Add(t.Caption);
end;
{if ICMB.Items.Count = 1 then
begin
     Application.MessageBox('There must be at least 2 24 bit opened images to perform this operation!',PChar(Application.Title),MB_ICONHAND);
     Close;
end;}
ICMB.ItemIndex := 0;
end;

end.
