unit FS_UN;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TFullSCR = class(TForm)
    FullImg: TImage;
    procedure FullImgClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FullSCR: TFullSCR;

procedure ShowFS;

implementation

{$R *.DFM}

uses dpemform,photo;

procedure ShowFS;
begin
  with TFullSCR.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TFullSCR.FullImgClick(Sender: TObject);
begin
ModalResult := mrOK;
end;

procedure TFullSCR.FormShow(Sender: TObject);
begin
Width := Screen.Width;
Height := Screen.Height;
HorzScrollBar.Range := FullImg.Picture.Width;
VertScrollBar.Range := FullImg.Picture.Height;
end;

procedure TFullSCR.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of     {INC and DEC do not work for}
                {Position property}
           37: HorzScrollBar.Position := HorzScrollBar.Position-1;
           39: HorzScrollBar.Position := HorzScrollBar.Position+1;
           38: VertScrollBar.Position := VertScrollBar.Position-1;
           40: VertScrollBar.Position := VertScrollBar.Position+1;
           33: VertScrollBar.Position := VertScrollBar.Position-20;
           34: VertScrollBar.Position := VertScrollBar.Position+20;
           35: HorzScrollBar.Position := HorzScrollBar.Position+20;
           36: HorzScrollBar.Position := HorzScrollBar.Position-20;
end;
end;

procedure TFullSCR.FormKeyPress(Sender: TObject; var Key: Char);
begin
ModalResult := mrOK;
end;

procedure TFullSCR.FormCreate(Sender: TObject);
var tft : TFPhoto;
begin
tft := TFPhoto(DPEMain.ActiveMDIChild);
FullImg.Picture.Bitmap.Assign(tft.Photo.Picture.Bitmap);
end;

end.
