unit rotun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,Registry;

type
  TRotateDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    angleed: TEdit;
    ANGUD: TUpDown;
    AngleCAP: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RotateDLG: TRotateDLG;
  function ShowRota(var angle: integer{;var autosize : boolean}) :integer;

implementation

{$R *.DFM}

uses DPemForm;

function ShowRota(var angle: integer{; var autosize : boolean}) :integer;
begin
  with TRotateDLG.Create(Application) do
  try
    result := ShowModal;
    if Result = mrOK then
    begin
       angle := ANGUd.Position;
       //autosize := ASCHK.Checked;
       RegIniFile := TRegIniFile.Create(DPEIniName);
       RegIniFile.WriteInteger('Rotate','Angle',ANGud.Position);
       //RegIniFile.WriteBool('Rotate','AutoSize',ASCHK.Checked);
       RegIniFile.Free;
    end;
  finally
    Free;
  end;
end;

procedure TRotateDLG.FormCreate(Sender: TObject);
begin
RegIniFile := TRegIniFile.Create(DPEIniName);
ANGud.Position := RegIniFile.ReadInteger('Rotate','Angle',45);
//ASCHK.Checked := RegIniFile.ReadBool('Rotate','AutoSize', True);
RegIniFile.Free;
end;

end.
