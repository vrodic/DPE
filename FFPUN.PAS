unit ffpun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, ComCtrls;

type
  Tffpfrm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    PageControl1: TPageControl;
    JPGSHT: TTabSheet;
    jdccap: TLabel;
    jpggreychk: TCheckBox;
    Line1: TBevel;
    encocap: TLabel;
    jpgcled: TEdit;
    jpgclud: TUpDown;
    qlcap: TLabel;
    jprogchk: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ffpfrm: Tffpfrm;
  procedure ShowFFP;
implementation

uses dpemform;

procedure ShowFFP;
begin
  with TFFPFrm.Create(Application) do
  try
    if ShowModal = mrOK then
    begin
        dpemform.JOutQual := jpgclud.Position;
        dpemform.JGreyScale := jpgGreyChk.Checked;
        dpemform.JProgressive := jprogchk.Checked;
    end;
  finally
    Free;
  end;
end;

{$R *.DFM}

procedure Tffpfrm.FormCreate(Sender: TObject);
begin
jpgGreyCHK.Checked := dpemform.JGreyScale;
jprogchk.Checked := dpemform.JProgressive;
jpgclud.Position := dpemform.JOutQual;
end;

end.
