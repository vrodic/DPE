unit dpemform;
{ Digital Photo Editor Main Window Unit }
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ClipBrd, ComCtrls,ShellAPI, MRUFENG, Registry, GifMap, TifMap,
  ExtCtrls, VStatus, Flatbtn, TB97,Buttons;

type
  TDPEMain = class(TForm)
    MainMenu: TMainMenu;
    MNUFile: TMenuItem;
    MNUExit: TMenuItem;
    N2: TMenuItem;
    MNUOpen: TMenuItem;
    NewMNU: TMenuItem;
    PrinterSetup: TPrinterSetupDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    MNUEdit: TMenuItem;
    MNUPANI: TMenuItem;
    StatusBar: TVStatusBar;
    MNUWindow: TMenuItem;
    MNUCascade: TMenuItem;
    MNUTile: TMenuItem;
    MNUHelp: TMenuItem;
    HelpTo1: TMenuItem;
    N3: TMenuItem;
    About1: TMenuItem;
    N4: TMenuItem;
    MNUEC: TMenuItem;
    ProgressBar: TProgressBar;
    View1: TMenuItem;
    Toolbar1: TMenuItem;
    N1: TMenuItem;
    MNUFTW: TMenuItem;
    N5: TMenuItem;
    FLFullScr: TMenuItem;
    MNUCut: TMenuItem;
    MNUCopy: TMenuItem;
    MNUPaste: TMenuItem;
    MNUClear: TMenuItem;
    MNUANI: TMenuItem;
    MNUICI: TMenuItem;
    MNUSave: TMenuItem;
    MNUSaveAS: TMenuItem;
    MNUClose: TMenuItem;
    MNUCloseAll: TMenuItem;
    N6: TMenuItem;
    MNUPrint: TMenuItem;
    MNUPS: TMenuItem;
    Image1: TMenuItem;
    MNUFlip: TMenuItem;
    MNUMirror: TMenuItem;
    Colors1: TMenuItem;
    MNUNI: TMenuItem;
    MNUReload: TMenuItem;
    MNUSL: TMenuItem;
    Dock1: TDock97;
    Dock2: TDock97;
    Dock3: TDock97;
    Dock4: TDock97;
    Toolbar: TToolbar97;
    FLNew: TSpeedButton;
    FlOpen: TSpeedButton;
    flsave: TSpeedButton;
    FLCut: TSpeedButton;
    Separator1: TToolbarSep97;
    FLCopy: TSpeedButton;
    FLPaste: TSpeedButton;
    FLClear: TSpeedButton;
    Separator2: TToolbarSep97;
    FLFS: TSpeedButton;
    FLInfo: TSpeedButton;
    FLPrint: TSpeedButton;
    FLDT: TSpeedButton;
    Separator3: TToolbarSep97;
    FLStyle: TSpeedButton;
    FLHelp: TSpeedButton;
    Separator4: TToolbarSep97;
    procedure CheckTool(Count : Integer);
    procedure ShowHint(Sender : TObject);
    procedure LoadPhoto( FileName : string);
    function  ImageLoad(ImageName: string;What: TObject): bool;
    procedure NewImage(X,Y : Word);
    procedure MNUExitClick(Sender: TObject);
    procedure MNUPrintSetupClick(Sender: TObject);
    procedure MNUOpenClick(Sender: TObject);
    procedure MNUSaveAsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RecentFilesClick(Sender: TObject; MRUFileName: string);
    procedure MNUTileClick(Sender: TObject);
    procedure MNUCascadeClick(Sender: TObject);
    procedure NewMNUClick(Sender: TObject);
    procedure MNUECClick(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FLPasteClick(Sender: TObject);
    procedure MNUPANIClick(Sender: TObject);
    procedure Toolbar1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MNUFTWClick(Sender: TObject);
    procedure FLFullScrClick(Sender: TObject);
    procedure MNUCutClick(Sender: TObject);
    procedure MNUClearClick(Sender: TObject);
    procedure MNUICIClick(Sender: TObject);
    procedure MNUCopyClick(Sender: TObject);
    procedure MNUCloseClick(Sender: TObject);
    procedure MNUPSClick(Sender: TObject);
    procedure MNUCloseAllClick(Sender: TObject);
    procedure MNUSaveClick(Sender: TObject);
    procedure MNUFlipClick(Sender: TObject);
    procedure MNUMirrorClick(Sender: TObject);
    procedure MNUNIClick(Sender: TObject);
    procedure MNUReloadClick(Sender: TObject);
    procedure MNUPrintClick(Sender: TObject);
    procedure MNUSLClick(Sender: TObject);
  private
     procedure SysMenuHint(var Message : TWMMenuSelect); message WM_MenuSelect;
     procedure OnDragDrop(var Message: TWMDropFiles); message WM_DropFiles;
     procedure OnChangeClip(var message :TWMDRAWCLIPBOARD);message WM_DrawClipBoard;
  public
    RecentFiles: TRecentFiles;
  end;

var
  DPEMain: TDPEMain;
  LoadedFile : String;
  RegIniFile : TRegIniFile;
  FileExt : string[4];
  ImageCount : word;
  UserAbort : boolean;

const DPEIniName = 'Software\Vedran Rodic\DPE';  {name of the ini file}

implementation
uses photo, newimg,DMGMain, DMGBasic, DMGColor, DMGSize, DMGrBMP, DMGrJPEG,
  FS_UN;
{$R *.DFM}
var MemDib : pBitmapInfo;
    MemWidth,MemHeight : word;
    tft : TFPhoto;

function GraphicCallBack(wMsg: word; cProgress: longint): bool; stdcall;
var
percent	: longint;
begin
  GraphicCallBack := UserAbort;
  if UserAbort then exit;
  case wMsg of
       DMG_Expand,
       DMG_Repack,
       DMG_Resize,
       DMG_ChgToGray,
       DMG_ExpToTrue,
       DMG_Histogramm,
       DMG_Remap,
       DMG_ChgTo256  : percent := cProgress;
       else percent := 0;
  end {case mMsg of};
  DPEMain.ProgressBar.Position := percent;
  {------------ MultiTasking enabled}
  Application.ProcessMessages;
  GraphicCallBack := UserAbort;
end;

function CheckImageFormat(Extension: string): boolean;
begin
    Result := mg_CheckFormat(pChar(Extension));
end;

procedure TDPEMain.MNUExitClick(Sender: TObject);
begin
Close;
end;

procedure TDPEMain.MNUPrintSetupClick(Sender: TObject);
begin
PrinterSetup.Execute;
end;

procedure TDPEMain.MNUOpenClick(Sender: TObject);
var i : word;
begin
if OpenDialog.Execute then
begin
     for i := 0 to OpenDialog.Files.Count-1 do
     begin
       LoadPhoto(OpenDialog.Files[i]);
       RecentFiles.LatestFile := LoadedFile;
     end;
end;
end;

procedure TDPEMain.MNUSaveAsClick(Sender: TObject);
begin
  if not MNUSaveAS.Visible then exit;
  if SaveDialog.Execute then
  begin
       { code comez here }
  end;
end;

procedure TDPEMain.SysMenuHint(var Message : TWMMenuSelect);
begin
If (message.Menuflag and MF_SysMenu) = MF_SysMenu then
begin
 case Message.IDItem of
     0: Application.Hint := '';
     SC_Close: Application.Hint := MNUExit.Hint;
     SC_MAximize: Application.Hint := 'Enlarge the window to the full size';
     sc_Minimize: Application.Hint := 'Reduces window to an icon';
     sc_Restore: Application.Hint := 'Restores the window to the normal size';
     sc_Move: Application.Hint := 'Change the window position';
     sc_Size: Application.Hint := 'Change the window size';
 else
 Application.Hint := '';
end;
Message.result  := 0;
end
else inherited;
end;

procedure TDPEMain.OnDragDrop(var  message : TWMDropFiles);
var c,numfiles : Integer;
    lpzFilename :PChar;
    tmp : String;
begin
    numfiles := DragQueryFile(Message.Drop,$FFFFFFFF,nil,0);
    lpzFileName := strAlloc(101);
    for c := 0 to numfiles do
    begin
       dragQueryFile(Message.Drop,c,lpzFileName,100);
       tmp := StrPas(lpzFilename);
       LoadPhoto(tmp);
       RecentFiles.LatestFile := LoadedFile;
    end;
    strDispose(lpzFilename);
    DragFinish(message.drop);
    message.result := 0;
end;

procedure TDPEMain.OnChangeClip(var message :TWMDRAWCLIPBOARD);
begin
if Clipboard.HasFormat(CF_Bitmap)  then
begin
    MNUPANI.Enabled := True;
    MNUEC.Enabled := True;
    FLPaste.Enabled := True;
   MNUPaste.Enabled := True;
end
else
begin
    MNUPANI.Enabled := False;
    MNUEC.Enabled := False;
    FLPaste.Enabled := False;
    MNUPaste.Enabled := False;
end;
end;

procedure TDPEMain.FormCreate(Sender: TObject);
begin
RecentFiles := TRecentFiles.Create(self);
RecentFiles.MaxFiles := 4;
RecentFiles.Menu := MNUFile;
RecentFiles.OnClick := RecentFilesClick;
Application.OnHint := ShowHint;
DragAcceptFiles(DPEMain.Handle,True);
SetClipboardViewer(DPEMain.Handle);
RecentFiles.IniFileName := DPEIniName;
RegIniFile := TRegIniFile.Create(DPEIniName);
Top := RegIniFile.ReadInteger('Options','Top',0);
Left := RegIniFile.ReadInteger('Options','Left',0);
Width := RegIniFile.ReadInteger('Options','Width',Screen.Width);
Height := RegIniFile.ReadInteger('Options','Height',Screen.Height);
RegIniFile.Free;
RecentFiles.LoadFromIniFile;
RegLoadToolBarPositions(DPEMain,DPEIniName+ 'Toolbars');
mg_SetTheCallBack(@GraphicCallBack);
Toolbar1.Checked := Toolbar.Visible;
MNUSL.Checked := StatusBar.Visible;
end;
procedure TDPEMain.ShowHint(Sender : TObject);
begin
StatusBar.Panels[0].Text := Application.Hint;
end;

procedure TDPEMain.RecentFilesClick(Sender: TObject; MRUFileName: string);
begin
LoadPhoto(MRUFileName);
RecentFiles.LatestFile := LoadedFile;
end;

procedure TDPEMain.MNUTileClick(Sender: TObject);
begin
Tile;
end;

procedure TDPEMain.MNUCascadeClick(Sender: TObject);
begin
Cascade;
end;

procedure TDPEMain.NewImage(X,Y : Word);
var bitmap : TBitmap;
begin
Screen.Cursor := crHourGlass;
bitmap := TBitmap.Create;
bitmap.Width  := X;
bitmap.Height := Y;
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(x,y);
tft.Caption:= photo.DefName + IntToStr(ImageCount);
LoadedFile := tft.Caption;
tft.Photo.Picture.Graphic := bitmap;
bitmap.Free;
Screen.Cursor := crDefault;
tft.Photo.Hint := 'New created image';
StatusBar.Panels[2].Text := IntToStr(tft.Photo.Picture.Width) + 'x' + IntToStr(tft.Photo.Picture.Height) + ' ';
CheckTool(MDIChildCount);
end;
procedure TDPEMain.NewMNUClick(Sender: TObject);
begin
if NewImgF.ShowModal = mrOK then NewImage(NewImgF.Xres.Position,NewImgF.Yres.position);
end;

procedure TDPEMain.MNUECClick(Sender: TObject);
begin
Clipboard.Clear;
end;

procedure TDPEMain.LoadPhoto(FileName : String);
var tmp : TPicture;
begin
FileExt := ANSILowerCase(ExtractFileExt(FileName));
Screen.Cursor := crHourGlass;
{there are two decoders included}
{if you want to use second just }
{comment "or (FileExt = '.gif')"}
{in the next line}
tmp := TPicture.Create;
if (FileExt = '.bmp') or (FileExt = '.gif') or (FileExt = '.tif') then
begin
     try
        tmp.LoadFromFile(FileName);
     finally
            Screen.Cursor := crDefault;
     end;
end
else
begin
     if not(CheckImageFormat(FileExt)) then
     begin
          raise Exception.Create('Image format not supported!');
          Exit;
     end;
     Screen.Cursor := crDefault;
     ProgressBar.Visible := True;
     ProgressBar.Position := 0;
     ProgressBar.Max := 100;
     if not ImageLoad(FileName,tmp) then raise Exception.Create('Error while reading file!');
end;
     LoadedFile := FileName;
     TFPhoto.Create(Self);
     tft := TFPhoto(ActiveMDIChild);
     tft.Photo.Picture.Bitmap.Assign(tmp.Bitmap);
     tft.FitImage(tmp.Width,tmp.Height);
     tmp.Free;
     StatusBar.Panels[2].Text := IntToStr(tft.Photo.Picture.Width) + 'x' + IntToStr(tft.Photo.Picture.Height) + ' ';
     tft.Photo.Hint := 'File: ' + ExtractFileName(FileName);
     tft.Caption := ExtractFileName(LoadedFile);
     CheckTool(MDIChildCount);
end;
{--------- loading for exotic formats ----------}
function TDPEMain.ImageLoad(ImageName: string;What: TObject): bool;
var
   Bitmap  : hBitmap;
   NewDIB  : pBitmapInfo;
   Measure : LongRec;
begin
  //Result := False;
  NewDIB := mg_LoadThePicture(pChar(ImageName), true);
  if (NewDIB = nil) then
  begin
       if not FileExists(ImageName) then
           raise Exception.Create('File: ' + ImageName + ' does not exist!')
       else
           raise exception.Create('Error while loading!');
       ProgressBar.Position := 0;
       ProgressBar.Max := 10;
       ProgressBar.Visible := False;
       Exit;
  end;
  {mg_FreeTheDIB(MemDIB);}
  MemDIB := NewDIB;
  Measure := LongRec(mg_GetDIBMeasure(NewDIB));
  MemWidth := Measure.Lo;
  MemHeight := Measure.Hi;
  {------------- DIB to BMP conversion}
  Bitmap := mg_MakeBMPfromDIB(MemDIB);
  {------------- error?}
  if (Bitmap = 0) then
       raise Exception.Create('Error while converting to BMP!')
  else begin
       {-------- putting BMP in ImageObject}
       TPicture(What).Bitmap.Handle := Bitmap;
       Result := True;
  end;
  ProgressBar.Position := 0;
  ProgressBar.Max := 10;
  ProgressBar.Visible := False;
  mg_FreeTheDIB(MemDIB);
end {function ImageLoad};

procedure TDPEMain.Hide1Click(Sender: TObject);
begin
tft := TFPhoto(ActiveMDIChild);
tft.Close;
end;
procedure TDPEMain.CheckTool(Count : Integer);
begin
tft := TFPhoto(ActiveMDIChild);
if Count = 0 then
begin
 StatusBar.Panels[2].Text := '';
 FLSave.Enabled := False;
 FLCut.Enabled := False;
 FLCopy.Enabled := False;
 FLClear.Enabled := False;
 FLFS.Enabled := False;
 FLPrint.Enabled := False;
 FLInfo.Enabled := False;
 FLFullScr.Enabled := False;
 MNUWindow.Visible := False;
 MNUCut.Visible := False;
 MNUCopy.Visible := False;
 MNUPaste.Visible := False;
 MNUClear.Visible := False;
 MNUPANI.Visible := True;
 MNUSave.Visible := False;
 MNUSaveAS.Visible := False;
 MNUClose.Visible := False;
 MNUCloseAll.Visible := False;
 MNUPrint.Visible := False;
 MNUPS.Visible := False;
 N6.Visible := False;
 Image1.Visible := False;
 Colors1.Visible := False;
 MNUReload.Visible := False;
end
else
begin
 FLSave.Enabled := True;
 FLCut.Enabled := True;
 FLCopy.Enabled := True;
 FLClear.Enabled := True;
 FLFS.Enabled := True;
 FLPrint.Enabled := True;
 FLInfo.Enabled := True;
 FLFullScr.Enabled := True;
 MNUWindow.Visible := True;
 MNUCut.Visible := True;
 MNUCopy.Visible := True;
 MNUPaste.Visible := True;
 MNUClear.Visible := True;
 MNUPANI.Visible := False;
 MNUSave.Visible := True;
 MNUSaveAS.Visible := True;
 MNUClose.Visible := True;
 MNUCloseAll.Visible := True;
 MNUPrint.Visible := True;
 MNUPS.Visible := True;
 N6.Visible := True;
 Image1.Visible := True;
 Colors1.Visible := True;
 MNUReload.Visible := True;
end;
end;
procedure TDPEMain.FormShow(Sender: TObject);
var i : word;
begin
CheckTool(MDIChildCount);
if paramcount > 0 then
begin
   for i := 1 to ParamCount do
   begin
        LoadPhoto(ParamStr(i));
        RecentFiles.LatestFile := LoadedFile;
   end;
end;
end;

procedure TDPEMain.FLPasteClick(Sender: TObject);
begin
if MDIChildCount = 0 then
  MNUPANIClick(Sender)
else MNUICIClick(Sender);
end;

procedure TDPEMain.MNUPANIClick(Sender: TObject);
var bitmap : TBitmap;
begin
  if Clipboard.HasFormat(CF_BITMAP) then	{ check to see if there is a picture }
   begin
     Bitmap := TBitmap.Create; 	{Create a bitmap to hold the contents of the Clipboard}
     try
       Bitmap.Assign(Clipboard);	{get the bitmap off the clipboard using Assign}
       TFPhoto.Create(Self);
       tft := TFPhoto(ActiveMDIChild);
       Inc(ImageCount);
       tft.Caption:= photo.DefName + IntToStr(ImageCount);
       tft.FitImage(Bitmap.Width,Bitmap.Height);
       tft.Photo.Picture.Graphic := bitmap;
      finally
       Bitmap.Free;
     end;
     StatusBar.Panels[2].Text := IntToStr(tft.Photo.Picture.Width) + 'x' + IntToStr(tft.Photo.Picture.Height) + ' ';
     tft.Modified := True;
     CheckTool(MDIChildCount);
     {srtox;
     popset;}
   end;
end;

procedure TDPEMain.Toolbar1Click(Sender: TObject);
begin
if Toolbar.Visible then Toolbar.Hide else ToolBar.Show;
Toolbar1.Checked := Toolbar.Visible;
end;

procedure TDPEMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
RecentFiles.SaveToIniFile;
RegSaveToolBarPositions(DPEMain,DPEIniName+ 'Toolbars');
end;

procedure TDPEMain.MNUFTWClick(Sender: TObject);
begin
if not MNUFTW.Visible then exit;
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(tft.Photo.Picture.Width, tft.Photo.Picture.Height);
end;

procedure TDPEMain.FLFullScrClick(Sender: TObject);
begin
if not FLFullScr.Visible then exit;
tft := TFPhoto(ActiveMDIChild);
FullScr.FullImg.Picture.Bitmap.Assign(tft.Photo.Picture.Bitmap);
FullScr.Show;
end;

procedure TDPEMain.MNUCutClick(Sender: TObject);
begin
MNUCopyClick(Sender);
MNUClearClick(Sender);
end;

procedure TDPEMain.MNUClearClick(Sender: TObject);
var oldcolor : TColor;
begin
tft := TFPhoto(ActiveMDIChild);
oldColor := tft.Photo.Canvas.Brush.Color;
tft.Photo.Canvas.Brush.Color := clWhite;
tft.Photo.Canvas.FillRect(Rect(0,0,tft.Photo.Picture.Width,tft.Photo.Picture.Height));
tft.Photo.Canvas.Brush.Color := oldcolor;
end;

procedure TDPEMain.MNUICIClick(Sender: TObject);
begin
// Code for pasting into the image
end;

procedure TDPEMain.MNUCopyClick(Sender: TObject);
begin
tft := TFPhoto(ActiveMDIChild);
Clipboard.Assign(tft.Photo.Picture.Bitmap);
end;

procedure TDPEMain.MNUCloseClick(Sender: TObject);
begin
tft := TFPhoto(ActiveMDIChild);
tft.Close;
end;

procedure TDPEMain.MNUPSClick(Sender: TObject);
begin
PrinterSetup.Execute;
end;

procedure TDPEMain.MNUCloseAllClick(Sender: TObject);
var i : integer;
begin
    for I := MDIChildCount-1 downto 0 do
      MDIChildren[I].Close;
CheckTool(0);
end;

procedure TDPEMain.MNUSaveClick(Sender: TObject);
begin
if not MNUSave.Visible then exit;
// Code for saving
end;

procedure TDPEMain.MNUFlipClick(Sender: TObject);
begin
if not MNUFlip.Visible then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.Flip(tft.Photo.Picture.Height,0,0,tft.Photo.Picture.Width);
end;

procedure TDPEMain.MNUMirrorClick(Sender: TObject);
begin
if not MNUMirror.Visible then exit;
tft := TFPhoto(ActiveMDIChild);
tft.Flip(0,tft.Photo.Picture.Width,tft.Photo.Picture.Height,0);
end;

procedure TDPEMain.MNUNIClick(Sender: TObject);
begin
tft := TFPhoto(ActiveMDIChild);
tft.InvertPicture(0,0,0);
end;

procedure TDPEMain.MNUReloadClick(Sender: TObject);
begin
if not MNUReload.Visible then exit;
tft := TFPhoto(ActiveMDIChild);
if ImageLoad(tft.PhotoName,tft.Photo.Picture) then tft.Modified := False;
end;

procedure TDPEMain.MNUPrintClick(Sender: TObject);
begin
if not MNUPrint.Visible then exit;
end;

procedure TDPEMain.MNUSLClick(Sender: TObject);
begin
if MNUSL.Checked then MNUSL.Checked := False
   else MNUSL.Checked := True;
StatusBar.Visible := MNUSL.Checked;
end;

end.
