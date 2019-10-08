unit prun;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, ComCtrls;

type
  TprDLG = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    PageControl: TPageControl;
    PalSHT: TTabSheet;
    CPalGRP: TGroupBox;
    DRad: TRadioButton;
    HRad: TRadioButton;
    UndoPG: TTabSheet;
    UDRad: TRadioButton;
    UNTM: TRadioButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  prDLG: TprDLG;

procedure ShowPREF;
implementation

{$R *.DFM}

uses dpemform;

procedure ShowPREF;
begin
  with TprDLG.Create(Application) do
  try
    if ShowModal = mrOK then
    begin
        dpemform.HDisplay := HRad.Checked;
        dpemform.UndoDisabled := UDRad.Checked;
    end;
  finally
    Free;
  end;
end;

procedure TprDLG.FormCreate(Sender: TObject);
begin
Caption := Application.Title + ' ' + Caption;
HRad.Checked := dpemForm.HDisplay;
UDRad.Checked := dpemForm.UndoDisabled;
end;

end.
