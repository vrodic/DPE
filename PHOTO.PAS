unit photo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls;

type
  TFPhoto = class(TForm)
    Photo: TImage;
    { Graphics Functions }
    procedure InvertPicture(rr,gg,bb : byte);
    procedure SetBSize(xdim,ydim :Word);
    procedure Flip(topc,leftc,bottomc,rightc : word);
    {------------------------------------------------}
    { Misc Functions }
    procedure FitImage(x,y: integer);
    {----------------}
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PhotoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
  public
   Modified : Boolean;
   PhotoName : string;
  end;

var
  FPhoto: TFPhoto;

const DefName = 'Image';

implementation

uses dpemform, newimg;
{$R *.DFM}

procedure TFPhoto.InvertPicture(rr,gg,bb : byte);
var i : word;
begin
Modified := True;
Photo.Canvas.Pen.Mode := pmNotXor;
Screen.Cursor := crHourglass;
Photo.Canvas.Pen.Color := RGB(rr,gg,bb);
Photo.Canvas.Pen.Width := Photo.Picture.Height;
Photo.Canvas.MoveTo(0,0);
for i := 0 to Photo.Picture.Height div Photo.Canvas.Pen.Width do
begin
     Photo.Canvas.MoveTo(0,Photo.Canvas.Pen.Width * i);
     Photo.Canvas.LineTo(Photo.Picture.Width,Photo.Canvas.Pen.Width * i);
end;
Photo.Canvas.Pen.Mode :=pmCopy;
Screen.Cursor := crDefault;
{srtox;
popset;}
end; {InvertPicture}

procedure TFPhoto.Flip(topc,leftc,bottomc,rightc : word);
var rt : TRect;
begin
Modified := True;
Screen.Cursor := crHourGlass;
rt.Top := topc;
rt.Left := leftc;
rt.Bottom := bottomc;
rt.Right := rightc;
try
   Photo.Canvas.StretchDraw(rt,Photo.Picture.Bitmap);
finally
   Screen.Cursor := crDefault;
end;
end;

procedure TFPhoto.SetBSize(xdim,ydim :Word);
var btmp : TBitmap;
    newbmp : TBitmap;
begin
if (xdim = Photo.Picture.Width) and (ydim = Photo.Picture.Height) then Exit;
Modified := True;
Screen.Cursor := crHourGlass;
btmp := TBitmap.Create;
newbmp := TBitmap.Create;
newbmp.Width := xdim;
newbmp.Height := ydim;
btmp.Assign(Photo.Picture);
newbmp.Canvas.StretchDraw(Rect(0,0,xdim,ydim),btmp);
Photo.Picture.Assign(newbmp);
newbmp.Free;
btmp.Free;
DPEMain.StatusBar.Panels[2].Text := IntToStr(Photo.Picture.Width) + 'x' + IntToStr(Photo.Picture.Height);
end; {SetBSize}

procedure TFPhoto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action := caFree;
DPEMain.CheckTool(DPEMain.MDIChildCount-1);
end;

procedure TFPhoto.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  SWarningText = 'Save changes to %s?';
begin
  if Modified then
  begin
    case MessageDlg(Format(SWarningText, [Caption]), mtConfirmation,
      [mbYes, mbNo, mbCancel], 0) of
      idYes: DPEMain.MNUSaveClick(Self);
      idCancel: CanClose := False;
    end;
  end;
end;

procedure TFPhoto.PhotoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Modified := True;
end;

procedure TFPhoto.FitImage(x,y: integer);
var tmp : TRect;
begin
tmp := DPEMain.ClientRect;
AutoScroll := False;
if x < tmp.Right then Width := x+9;
if y < tmp.Bottom then Height := y+27;
AutoScroll := True;
end;

procedure TFPhoto.FormCreate(Sender: TObject);
begin
PhotoName := dpemform.LoadedFile;
end;

procedure TFPhoto.FormActivate(Sender: TObject);
begin
DPEMain.StatusBar.Panels[2].Text := IntToStr(Photo.Picture.Width) + 'x' + IntToStr(Photo.Picture.Height) + ' ';
end;

end.
