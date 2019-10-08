unit btnzun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  Tbtneffdlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    ewed: TEdit;
    ewcap: TLabel;
    ewud: TUpDown;
    sechk: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  btneffdlg: Tbtneffdlg;

function ShowBTNEff(var edge: integer; var smooth: boolean) :integer;

implementation

uses dpemform;

function ShowBTNEff(var edge: integer; var smooth: boolean) :integer;
begin
  with TbtneffDLG.Create(Application) do
  try
    RegIniFile := TRegIniFile.Create(DPEIniName);
    ewud.Position := RegIniFile.ReadInteger('Effects','BEdge',10);
    sechk.Checked := RegIniFile.ReadBool('Effects','BSoftEdge',True);
    RegIniFile.Free;
    result := ShowModal;
    if Result = mrOk then
    begin
         RegIniFile := TRegIniFile.Create(DPEIniName);
         RegIniFile.WriteInteger('Effects','BEdge',ewud.Position);
         RegIniFile.WriteBool('Effects','BSoftEdge',sechk.Checked);
         RegIniFile.Free;
         edge := ewud.Position;
         smooth := sechk.Checked;
    end;
  finally
    Free;
  end;
end;

{$R *.DFM}

end.
