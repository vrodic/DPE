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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FullSCR: TFullSCR;

implementation

{$R *.DFM}

procedure TFullSCR.FullImgClick(Sender: TObject);
begin
Hide;
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
Hide;
end;

end.
