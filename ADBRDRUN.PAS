unit adbrdrun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  TAddBRDRDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    BRDRSZGRP: TGroupBox;
    SymmCHK: TCheckBox;
    topcap: TLabel;
    toped: TEdit;
    topud: TUpDown;
    btmcap: TLabel;
    btmed: TEdit;
    btmud: TUpDown;
    lefted: TEdit;
    LeftCAP: TLabel;
    leftud: TUpDown;
    rghtcap: TLabel;
    rghted: TEdit;
    rghtud: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure topedChange(Sender: TObject);
    procedure btmedChange(Sender: TObject);
    procedure leftedChange(Sender: TObject);
    procedure rghtedChange(Sender: TObject);
    procedure SymmCHKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddBRDRDLG: TAddBRDRDLG;
function ShowADDBRDRDLG(var TopA, BottomA, LeftA, RightA : integer) : integer;

implementation

{$R *.DFM}
uses dpemform;

function ShowADDBRDRDLG(var TopA, BottomA, LeftA, RightA : integer) : integer;
begin
  with TAddBRDRDLG.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
         TopA := TopUD.Position;
         BottomA := btmud.Position;
         LeftA := leftud.Position;
         RightA := rghtud.Position;
         RegIniFile := TRegIniFile.Create(DPEIniName);
         RegIniFile.WriteInteger('AddBorders','Top',topUd.Position);
         RegIniFile.WriteInteger('AddBorders','Bottom',BtmUd.Position);
         RegIniFile.WriteInteger('AddBorders','Left',Leftud.Position);
         RegIniFile.WriteInteger('AddBorders','Right', RghtUd.Position);
         RegIniFile.WriteBool('AddBorders','Symmetric', SymmCHK.Checked);
         RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;
procedure TAddBRDRDLG.FormCreate(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
topud.Position := RegIniFile.ReadInteger('AddBorders','Top',0);
btmud.Position := RegIniFile.ReadInteger('AddBorders','Bottom',0);
leftud.Position := RegIniFile.ReadInteger('AddBorders','Left',0);
rghtud.Position := RegIniFile.ReadInteger('AddBorders','Right', 0);
SymmCHK.Checked := RegIniFile.ReadBool('AddBorders','Symmetric', False);
RegIniFile.Free;
topEdChange(Sender);
end;

procedure TAddBRDRDLG.topedChange(Sender: TObject);
begin
//if topEd.Text <> '' then topud.Position := StrToInt(TopEd.Text);
if SymmCHK.Checked then
begin
     btmud.Position  := topud.Position;
     leftud.Position := topud.Position;
     rghtud.Position := topud.Position;
end;
end;

procedure TAddBRDRDLG.btmedChange(Sender: TObject);
begin
//if btmEd.Text <> '' then btmud.Position := StrToInt(btmEd.Text);
if SymmCHK.Checked then
begin
     topud.Position  := btmud.Position;
     leftud.Position := btmud.Position;
     rghtud.Position := btmud.Position;
end;
end;

procedure TAddBRDRDLG.leftedChange(Sender: TObject);
begin
//if leftEd.Text <> '' then leftud.Position := StrToInt(leftEd.Text);
if SymmCHK.Checked then
begin
     btmud.Position  := leftud.Position;
     topud.Position := leftud.Position;
     rghtud.Position := leftud.Position;
end;
end;

procedure TAddBRDRDLG.rghtedChange(Sender: TObject);
begin
//if rghtEd.Text <> '' then rghtud.Position := StrToInt(rghted.Text);
if SymmCHK.Checked then
begin
     btmud.Position  := rghtud.Position;
     leftud.Position := rghtud.Position;
     topud.Position := rghtud.Position;
end;
end;

procedure TAddBRDRDLG.SymmCHKClick(Sender: TObject);
begin
topEdChange(Sender);
end;

end.
