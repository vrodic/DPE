unit rszun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  TrszDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    sns: TGroupBox;
    RESGroup: TRadioGroup;
    csgrp: TGroupBox;
    xcap: TLabel;
    csrad: TRadioButton;
    xsz: TEdit;
    ysz: TEdit;
    xud: TUpDown;
    yud: TUpDown;
    ARCHK: TCheckBox;
    RCap: TLabel;
    rfilter: TComboBox;
    procedure csradClick(Sender: TObject);
    procedure RESGroupClick(Sender: TObject);
    procedure xszExit(Sender: TObject);
    procedure yszExit(Sender: TObject);
    procedure xszEnter(Sender: TObject);
    procedure ARCHKClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  rszDLG: TrszDLG;
  opw,oph : word;
function ShowRDLG(ow,oh : word;var w,h : word; Resample : Boolean; var FilterIndex : Byte) : integer;

implementation

{$R *.DFM}
uses dpemform,Resample;

function GetMass(o1, z1, z2: longint): word;
var
Faktor          : single;
begin
  Faktor := 100 * z1 / o1;
  Result := round(z2 * Faktor / 100);
end {function TSizeEinstellForm.GetMass};

function ShowRDLG(ow,oh : word;var w,h : word; Resample : boolean; var FilterIndex : byte) : integer;
var i : byte;
begin
  with TrszDLG.Create(Application) do
  try
    opw := ow;
    oph := oh;
    RegIniFile := TRegIniFile.Create(DPEIniName);
    if Resample then
    begin
         RESGroup.ItemIndex := RegIniFile.ReadInteger('Resample','Select',-1);
         xud.Position := RegIniFile.ReadInteger('Resample','Width',ow);
         yud.Position := RegIniFile.ReadInteger('Resample','Height',oh);
         ARCHK.Checked := RegIniFile.ReadBool('Resample','AspectRatio',True);
         for i := 0 to 6 do
         begin
           rfilter.Items.Add(ResampleFilters[i].Name);
         end;
         rfilter.ItemIndex := RegIniFile.ReadInteger('Resample','Filter',4);
         Caption := 'Resample';
         rfilter.Visible := true;
         rcap.Visible := true;
    end
    else
    begin
         RESGroup.ItemIndex := RegIniFile.ReadInteger('Resize','Select',-1);
         xud.Position := RegIniFile.ReadInteger('Resize','Width',ow);
         yud.Position := RegIniFile.ReadInteger('Resize','Height',oh);
         ARCHK.Checked := RegIniFile.ReadBool('Resize','AspectRatio',True);
    end;
    RegIniFile.Free;
    {opw := xud.Position;
    oph := yud.Position;}
    if RESGroup.ItemIndex = -1 then
    begin
      csrad.Checked := True;
      csradClick(csrad);
    end;
    result := ShowModal;
    if result = mrOK then
    begin
      RegIniFile := TRegIniFile.Create(DPEIniName);
      if Resample then
      begin
        RegIniFile.WriteBool('Resample','AspectRatio',ARCHK.Checked);
        RegIniFile.WriteInteger('Resample','Filter',rfilter.ItemIndex);
        RegIniFile.WriteInteger('Resample','Width',xud.Position);
        RegIniFile.WriteInteger('Resample','Height',yud.Position);
        RegIniFile.WriteInteger('Resample','Select',RESGroup.ItemIndex);
        FilterIndex := rfilter.ItemIndex;
      end
      else
      begin
        RegIniFile.WriteBool('Resize','AspectRatio',ARCHK.Checked);
        RegIniFile.WriteInteger('Resize','Width',xud.Position);
        RegIniFile.WriteInteger('Resize','Height',yud.Position);
        RegIniFile.WriteInteger('Resize','Select',RESGroup.ItemIndex);
      end;
      RegIniFile.Free;
      case RESGroup.ItemIndex of
           -1:
           begin
                w := xud.Position;
                h := yud.Position;
           end;
           0:
           begin
                w := 320;
                h := 200;
           end;
           1:
           begin
                w := 320;
                h := 240;
           end;
           2:
           begin
                w := 640;
                h := 480;
           end;
           3:
           begin
                w := 800;
                h := 600;
           end;
           4:
           begin
                w := 1024;
                h := 768;
           end;
      end;
    end;

 finally
    Free;
  end;
end;


procedure TrszDLG.csradClick(Sender: TObject);
begin
resGroup.ItemIndex := -1;
end;

procedure TrszDLG.RESGroupClick(Sender: TObject);
begin
csrad.Checked := False;
end;

procedure TrszDLG.xszExit(Sender: TObject);
begin
  if ARCHK.Checked
  then yud.Position := GetMass(opw, xud.Position, oph);
end;

procedure TrszDLG.yszExit(Sender: TObject);
begin
  if ARCHK.Checked
  then xud.Position := GetMass(oph, yud.Position, opw);
end;

procedure TrszDLG.xszEnter(Sender: TObject);
begin
csrad.Checked := True;
csradClick(Sender);
end;

procedure TrszDLG.ARCHKClick(Sender: TObject);
begin
if ARCHK.Checked then
 xszExit(Sender);
end;

procedure TrszDLG.OKBtnClick(Sender: TObject);
begin
if ARCHK.Checked then
begin
 if xsz.Focused then xszExit(Sender);
 if ysz.Focused then yszExit(Sender);
end;
end;

end.
