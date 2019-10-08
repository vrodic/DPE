unit dpemform;
{ Digital Photo Editor Main Window Unit }
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ClipBrd, ComCtrls,ShellAPI, MRUFENG, Registry, TifMap,
  ExtCtrls, VStatus, TB97,Buttons,JPEG,PcxTga, ExtDlgs,ColorMan, Dither,
  ColorPanel, StdCtrls,GIFImage;

type
  TDPEMain = class(TForm)
    MainMenu: TMainMenu;
    MNUFile: TMenuItem;
    MNUExit: TMenuItem;
    N2: TMenuItem;
    MNUOpen: TMenuItem;
    NewMNU: TMenuItem;
    PrinterSetup: TPrinterSetupDialog;
    OpenDialog: TOpenPictureDialog;
    MNUEdit: TMenuItem;
    MNUPANI: TMenuItem;
    StatusBar: TVStatusBar;
    MNUWindow: TMenuItem;
    MNUCascade: TMenuItem;
    MNUTileVert: TMenuItem;
    MNUHelp: TMenuItem;
    MNUHELPT: TMenuItem;
    N3: TMenuItem;
    MNUAbout: TMenuItem;
    N4: TMenuItem;
    MNUEC: TMenuItem;
    ProgressBar: TProgressBar;
    MNUView: TMenuItem;
    MNUToolbar: TMenuItem;
    N1: TMenuItem;
    MNUFTW: TMenuItem;
    N5: TMenuItem;
    MNUFS: TMenuItem;
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
    MNUImage: TMenuItem;
    MNUFlip: TMenuItem;
    MNUMirror: TMenuItem;
    MNUColors: TMenuItem;
    MNUNI: TMenuItem;
    MNUReload: TMenuItem;
    MNUSL: TMenuItem;
    Dock1: TDock97;
    Dock2: TDock97;
    Dock3: TDock97;
    Dock4: TDock97;
    Toolbar: TToolbar97;
    FLNew: TToolbarButton97;
    FlOpen: TToolbarButton97;
    flsave: TToolbarButton97;
    FLCut: TToolbarButton97;
    Separator1: TToolbarSep97;
    FLCopy: TToolbarButton97;
    FLPaste: TToolbarButton97;
    FLClear: TToolbarButton97;
    Separator2: TToolbarSep97;
    FLFS: TToolbarButton97;
    FLInfo: TToolbarButton97;
    FLPrint: TToolbarButton97;
    FLIT: TToolbarButton97;
    Separator3: TToolbarSep97;
    FLStyle: TToolbarButton97;
    FLHelp: TToolbarButton97;
    Separator4: TToolbarSep97;
    MNUEffects: TMenuItem;
    MNUSoften: TMenuItem;
    MNUCoolColor: TMenuItem;
    MNUGreyScale: TMenuItem;
    MNUSChannels: TMenuItem;
    MNUDuplicate: TMenuItem;
    N7: TMenuItem;
    MNUICD: TMenuItem;
    MNUI24: TMenuItem;
    MNUI8: TMenuItem;
    MNUi4: TMenuItem;
    MNUDCD: TMenuItem;
    MNUD1: TMenuItem;
    MNUD4: TMenuItem;
    MNUD8: TMenuItem;
    SaveDialog: TSavePictureDialog;
    MNUAdjust: TMenuItem;
    MNUABC: TMenuItem;
    MNUARGB: TMenuItem;
    MNUAHSL: TMenuItem;
    MNURotate: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    MNULP: TMenuItem;
    MNUSP: TMenuItem;
    PalOpenDialog: TOpenDialog;
    PalSaveDialog: TSaveDialog;
    MNUSolarize: TMenuItem;
    ColorDialog: TColorDialog;
    MNUColorise: TMenuItem;
    N10: TMenuItem;
    MNUPrefSUB: TMenuItem;
    mnuFFP: TMenuItem;
    MNUResize: TMenuItem;
    N11: TMenuItem;
    MNUEPal: TMenuItem;
    MNUTileHorz: TMenuItem;
    MNUCrsz: TMenuItem;
    MNUABlend: TMenuItem;
    MNUDelete: TMenuItem;
    N12: TMenuItem;
    MNUSAW: TMenuItem;
    MNUButtonize: TMenuItem;
    ColorsTB: TToolbar97;
    MNUCP: TMenuItem;
    CPanel: TPanel;
    cselpnl: TPanel;
    ForeColorP: TColorPanel;
    BackColorP: TColorPanel;
    FlipBTN: TToolbarButton97;
    fcl: TPanel;
    rcap: TLabel;
    gcap: TLabel;
    bcap: TLabel;
    mcolor: TPanel;
    rccap: TLabel;
    gccap: TLabel;
    bccap: TLabel;
    hsvgen: TPanel;
    hsvgenimg: TImage;
    FLColors: TToolbarButton97;
    ITTB: TToolbar97;
    MNUIT: TMenuItem;
    PBT: TToolbarButton97;
    linet: TToolbarButton97;
    fft: TToolbarButton97;
    shapet: TToolbarButton97;
    StyleBARTB: TToolbar97;
    MNUSB: TMenuItem;
    RectSO: TPanel;
    ShapeCAP: TLabel;
    shapebox: TComboBox;
    stcap: TLabel;
    Stylebox: TComboBox;
    SizeSO: TPanel;
    SizeCAP: TLabel;
    SizeED: TEdit;
    sizeud: TUpDown;
    DropT: TToolbarButton97;
    RetT: TToolbarButton97;
    RetSO: TPanel;
    RMCAp: TLabel;
    RModeBox: TComboBox;
    StrCAP: TLabel;
    StrED: TEdit;
    strud: TUpDown;
    MNUADBRDR: TMenuItem;
    MNUGPrefs: TMenuItem;
    N13: TMenuItem;
    MNUUndo: TMenuItem;
    FLUndo: TToolbarButton97;
    MoverT: TToolbarButton97;
    EraserT: TToolbarButton97;
    MNUAContrast: TMenuItem;
    MNUResample: TMenuItem;
    MNUSharpen: TMenuItem;
    MNUChannels: TMenuItem;
    MNUCombining: TMenuItem;
    ZoomSO: TPanel;
    ZmCap: TLabel;
    MNUFSE: TMenuItem;
    procedure CheckTool(Count : Integer);
    procedure ShowHint(Sender : TObject);
    function  LoadToPicture(var Picture : TPicture; FileName : String) : boolean;
    function  LoadFinalize(var Picture : TPicture; FileName : string) : boolean;
    procedure LoadPhoto( FileName : string);
    procedure SaveToGif(Bitmap: TBitmap; FileName : string);
    procedure SaveToJPEG(Bitmap : TBitmap;FileName : String);
    procedure NewImage(X,Y,Depth,BackColor : Word);
    procedure ChannelCombine(rb, gb, bb : TBitmap);
    procedure MNUExitClick(Sender: TObject);
    procedure MNUPrintSetupClick(Sender: TObject);
    procedure MNUOpenClick(Sender: TObject);
    procedure MNUSaveAsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RecentFilesClick(Sender: TObject; MRUFileName: string);
    procedure MNUTileVertClick(Sender: TObject);
    procedure MNUCascadeClick(Sender: TObject);
    procedure NewMNUClick(Sender: TObject);
    procedure MNUECClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FLPasteClick(Sender: TObject);
    procedure MNUPANIClick(Sender: TObject);
    procedure MNUToolbarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MNUFTWClick(Sender: TObject);
    procedure MNUFSClick(Sender: TObject);
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
    procedure LoadJPG(FileName : String; FPicture : TPicture);
    procedure LoadGIF( FileName : String; FPicture : TPicture);
    procedure LoadICO(FileName : String; FPicture : TPicture);
    procedure EvPrg(Sender :TObject; Stage : TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
    procedure MNUSoftenClick(Sender: TObject);
    procedure MNUCoolColorClick(Sender: TObject);
    procedure MNUGreyScaleClick(Sender: TObject);
    procedure ToolbarVisibleChanged(Sender: TObject);
    procedure MNUSChannelsClick(Sender: TObject);
    procedure MNUDuplicateClick(Sender: TObject);
    procedure FLNewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FlOpenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure flsaveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLCutMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLCopyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLPasteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLClearMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLFSMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLInfoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLPrintMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLHelpMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MNUI8Click(Sender: TObject);
    procedure MNUI24Click(Sender: TObject);
    procedure MNUi4Click(Sender: TObject);
    procedure MNUD1Click(Sender: TObject);
    procedure MNUD4Click(Sender: TObject);
    procedure MNUD8Click(Sender: TObject);
    procedure MNURotateClick(Sender: TObject);
    procedure MNUARGBClick(Sender: TObject);
    procedure MNULPClick(Sender: TObject);
    procedure MNUSPClick(Sender: TObject);
    procedure MNUABCClick(Sender: TObject);
    procedure MNUSolarizeClick(Sender: TObject);
    procedure MNUAHSLClick(Sender: TObject);
    procedure MNUAboutClick(Sender: TObject);
    procedure MNUColoriseClick(Sender: TObject);
    procedure mnuFFPClick(Sender: TObject);
    procedure MNUResizeClick(Sender: TObject);
    procedure MNUEPalClick(Sender: TObject);
    procedure MNUTileHorzClick(Sender: TObject);
    procedure MNUCrszClick(Sender: TObject);
    procedure MNUABlendClick(Sender: TObject);
    procedure MNUDeleteClick(Sender: TObject);
    procedure MNUSAWClick(Sender: TObject);
    procedure MNUButtonizeClick(Sender: TObject);
    procedure MNUCPClick(Sender: TObject);
    procedure ColorsTBVisibleChanged(Sender: TObject);
    procedure FlipBTNClick(Sender: TObject);
    procedure ForeColorPClick(Sender: TObject);
    procedure BackColorPClick(Sender: TObject);
    procedure NeutralizeColorPal;
    //procedure GenerateSelector;
    procedure fclMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SetMColor(NewValue : TColor);
    procedure ForeColorPMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BackColorPMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure hsvgenimgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure hsvgenimgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure hsvgenimgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cselpnlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLColorsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MNUITClick(Sender: TObject);
    procedure ITTBVisibleChanged(Sender: TObject);
    procedure MNUSBClick(Sender: TObject);
    procedure StyleBARTBVisibleChanged(Sender: TObject);
    procedure PBTClick(Sender: TObject);
    procedure linetClick(Sender: TObject);
    procedure shapetClick(Sender: TObject);
    procedure StupidDo;
    procedure shapeboxChange(Sender: TObject);
    procedure StyleBARTBDockChanged(Sender: TObject);
    procedure StyleboxChange(Sender: TObject);
    procedure sizeudClick(Sender: TObject; Button: TUDBtnType);
    procedure SizeEDChange(Sender: TObject);
    procedure fftClick(Sender: TObject);
    procedure PBTMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure linetMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure fftMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure shapetMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DropTMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DropTClick(Sender: TObject);
    procedure RetTClick(Sender: TObject);
    procedure RModeBoxChange(Sender: TObject);
    procedure strudClick(Sender: TObject; Button: TUDBtnType);
    procedure StrEDChange(Sender: TObject);
    procedure RetTMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLITMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FLStyleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MNUADBRDRClick(Sender: TObject);
    procedure MNUGPrefsClick(Sender: TObject);
    procedure MNUUndoClick(Sender: TObject);
    procedure FLUndoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MoverTClick(Sender: TObject);
    procedure MoverTMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EraserTClick(Sender: TObject);
    procedure EraserTMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure MNUAContrastClick(Sender: TObject);
    procedure MNUResampleClick(Sender: TObject);
    procedure MNUSharpenClick(Sender: TObject);
    procedure MNUCombiningClick(Sender: TObject);
    procedure MNUFSEClick(Sender: TObject);
  private
     FNextViewerHandle : THandle;
     procedure SysMenuHint(var Message : TWMMenuSelect); message WM_MenuSelect;
     procedure OnDragDrop(var Message: TWMDropFiles); message WM_DropFiles;
     procedure OnChangeClip(var message :TWMDRAWCLIPBOARD);message WM_DrawClipBoard;
     procedure WMChangeCBCHain (var message : TMessage);message WM_CHANGECBCHAIN;
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
  {Misc properties}
  HDisplay : Boolean;
  UndoDisabled : Boolean;
  { JPEG Properties }
  JGreyScale : boolean;
  JOutQual : word;
  JProgressive : boolean;
  { Painting }
    ShapeIdx : integer;
    StyleIdx : integer;
    RetIDX : integer;
    SizePen,SizeLine,SizeBox,
    SizeRet,SizeEraser : integer;
    StrVal : integer;
const DPEIniName = 'Software\Vedran Rodic\DPE';  {name of the ini file}

implementation
uses photo, newimg,DMGMain,rotun,
  FS_UN, adclrun, ldun, solaun, abox,ffpun,rszun,epun,
  crszun,ablendun,mfimp,btnzun,adbrdrun,prun,conun,ccun;
{$R *.DFM}

var tft : TFPhoto; // Active MDI Child
    // for full screen edit
    oldpos : TRect;
    oldstate : TWindowState;
    ///////////////////////
procedure TDPEMain.EvPrg(Sender :TObject; Stage : TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
ProgressBar.Position := PercentDone;
end;

procedure TDPEMain.LoadJPG(FileName : String; FPicture : TPicture);
var JPEGImage : TJPEGImage;
begin
ProgressBar.Visible := True;
JPEGImage := TJPEGImage.Create;
JPEGImage.GrayScale := JGreyScale;
JPEGImage.OnProgress := EvPrg;
try
   JPEGImage.LoadFromFile(FileName);
except
   ProgressBar.Visible := False;
   Screen.Cursor := crDefault;
end;
FPicture.Bitmap.Assign(JPEGImage);
ProgressBar.Visible := False;
Screen.Cursor := crDefault;
JPEGImage.Free;
end;

procedure TDPEMain.LoadGIF(FileName : String; FPicture : TPicture);
var GIFImage : TGIFImage;
begin
  GIFImage := TGIFImage.Create;
  try
    GIFImage.OnProgress := EvPrg;
    GIFImage.LoadFromFile(FileName);
    FPicture.Bitmap.Assign(GIFImage);
  finally
    GIFImage.Free;
  end;
  Screen.Cursor := crDefault;
end;

procedure TDPEMain.LoadICO(FileName : String; FPicture : TPicture);
var ICOPicture : TPicture;
begin
     ICOPicture := TPicture.Create;
     ICOPicture.LoadFromFile(FileName);
     FPicture.Bitmap.PixelFormat := pf24bit;
     FPicture.Bitmap.Width := ICOPicture.Width;
     FPicture.Bitmap.Height := ICOPicture.Height;
     FPicture.Bitmap.Canvas.Draw(0,0,ICOPicture.Graphic);
     ICOPicture.Free;
     Screen.Cursor := crDefault;
end;

function GraphicCallBack(cProgress: longint): bool;
var
percent	: longint;
begin
  percent := cProgress;
  DPEMain.ProgressBar.Position := percent;
  {------------ MultiTasking enabled}
  //Application.ProcessMessages;
  GraphicCallBack := False;
end;

function DitherCallBack(cProgress: longint): bool;
var
percent	: longint;
begin
  percent := cProgress;
  DPEMain.ProgressBar.Position := percent;
  {------------ MultiTasking enabled}
  //Application.ProcessMessages;
  DitherCallBack := False;
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
     OpenDialog.InitialDir := ExtractFileDir(OpenDialog.FileName);
     for i := 0 to OpenDialog.Files.Count-1 do
     begin
       LoadPhoto(OpenDialog.Files[i]);
       //DPEMain.ActiveMDIChild.Refresh;
       Application.ProcessMessages;
       RecentFiles.LatestFile := LoadedFile;
     end;
end;
end;

procedure TDPEMain.MNUSaveAsClick(Sender: TObject);
begin
if MDIChildCount = 0 then exit;
tft := TFPhoto(ActiveMDIChild);
tft.SaveAsImage;
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
    for c := 0 to numfiles-1 do
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
// Called whenever contents of the clipboard changes
message.Result := SendMessage(WM_DRAWCLIPBOARD, FNextViewerHandle, 0, 0);
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

procedure TDPEMain.WMChangeCBCHain (var message : TMessage);
begin
  // Called when there is a change in the Clipboard viewer chain.
  if message.wParam = FNextViewerHandle then begin
    // the next viewer in the chain is being removed. Update our internal var.
    FNextViewerHandle := message.lParam;
    // Return 0 to indicate message was processed
    message.Result := 0;
  end else begin
    // Pass message on to next window in chain.
    message.Result := SendMessage(FNextViewerHandle, WM_CHANGECBCHAIN,
message.wParam, message.lParam);
  end;
end;

{procedure TDpeMain.GenerateSelector;
var imagebitmap : TBitmap;
    Imagebitmap2 : TBitmap;
    hsv : THsvColor;
    x,y : integer;
    p24 : PRGBByteArray;
    FN : TFileName;
const FNSTR = 'CSEL.BMP';
begin
FN := ExtractFilePath(Application.ExeName) + '\' + FNSTR;
if not FileExists(FN) then
begin
  imagebitmap := TBitmap.Create;
  imagebitmap.PixelFormat := pf24bit;
  imagebitmap.Width := 512;
  imagebitmap.Height := 360;
  hsv.s := 255;
  for y := 0 to 359 do
  begin
       p24 := Imagebitmap.Scanline[y];
       hsv.h := y;
       for x := 0 to 255 do
       begin
            hsv.V := x;
            p24[x] := HSVtoRGB(hsv);
       end;
  end;
  hsv.V := 255;
  for y := 0 to 359 do
  begin
       p24 := Imagebitmap.Scanline[y];
       hsv.h := y;
       for x := 256 to 511 do
       begin
            hsv.s := not(byte(x));
            p24[x] := HSVtoRGB(hsv);
       end;
  end;
  ImageBitmap2 := TBitmap.Create;
  ImageBitmap2.PixelFormat := pf24bit;
  ImageBitmap2.Width := hsvgenimg.Width;
  ImageBitmap2.Height := hsvgenimg.Height;
  ImageBitmap2.Canvas.StretchDraw(Rect(0,0,hsvgenimg.Width,hsvgenimg.Height),Imagebitmap);
  ImageBitmap2.SaveToFile(Fn);
  ImageBitmap.Free;
  ImageBitmap2.Free;
  GenerateSelector;
end
else
HsvgenImg.Picture.LoadFromFile(FN);
end;}

procedure TDPEMain.FormCreate(Sender: TObject);
begin
//GenerateSelector;
RecentFiles := TRecentFiles.Create(self);
RecentFiles.MaxFiles := 4;
RecentFiles.Menu := MNUFile;
RecentFiles.OnClick := RecentFilesClick;
Application.OnHint := ShowHint;
DragAcceptFiles(DPEMain.Handle,True);
// Hook the clipboard viewer chain
// Should also check for a possible null return value, which indicates
// that the function failed.
FNextViewerHandle := SetClipboardViewer(DPEMain.Handle);
RecentFiles.IniFileName := DPEIniName;
RegIniFile := TRegIniFile.Create(DPEIniName);
{Misc loading}
HDisplay := RegIniFile.ReadBool('Preferences','HDisplay',False);
UndoDisabled := RegIniFile.ReadBool('Preferences','UndoDisabled',False);
{JPEG Initialization}
JGreyScale := RegIniFile.ReadBool('Format','JPGGrey',False);
JOutQual := RegInifile.ReadInteger('Format','JPGQual',80);
JProgressive := RegIniFile.ReadBool('Format','JPGPr',False);
{}
{Tools init}
StyleIDX := RegIniFile.ReadInteger('Paint','Style',0);
ShapeIDX := RegIniFile.ReadInteger('Paint','Shape',0);
RetIDX := RegIniFile.ReadInteger('Paint','Retouch',0);
SizePen := RegIniFile.ReadInteger('Paint','Pen',0);
SizeLine := RegIniFile.ReadInteger('Paint','Width',0);
SizeBox := RegIniFile.ReadInteger('Paint','Line',0);
SizeEraser := RegIniFile.ReadInteger('Paint','Eraser',0);
SizeRet := RegIniFile.ReadInteger('Paint','Ret',0);
StrVal := RegIniFile.ReadInteger('Paint','RetStr',0);
ForeColorP.Color := RegIniFile.ReadInteger('Paint','ForeColor',RGB(0,0,0));
BackColorP.Color := RegIniFile.ReadInteger('Paint','BackColor',RGB(255,255,255));
{}
Top := RegIniFile.ReadInteger('Options','Top',0);
Left := RegIniFile.ReadInteger('Options','Left',0);
Width := RegIniFile.ReadInteger('Options','Width',Screen.Width);
Height := RegIniFile.ReadInteger('Options','Height',Screen.Height);
OpenDialog.InitialDir := Reginifile.ReadString('Options','InitialLoadDir','');
SaveDialog.InitialDir := reginifile.ReadString('Options','InitialSaveDir','');
MNUSL.Checked := RegIniFile.ReadBool('Options','StatusBar',True);
RegIniFile.Free;
StatusBar.Visible := MNUSL.Checked;
RecentFiles.LoadFromIniFile;
RegLoadToolBarPositions(DPEMain,DPEIniName+ '\Toolbars');
mg_SetTheCallBack(@GraphicCallBack);
DitherSetTheCallBack(@DitherCallBack);
ToolbarVisibleChanged(Self);
ColorsTBVisibleChanged(Self);
ITTBVisibleChanged(Self);
StyleBARTBVisibleChanged(Self);
MNUSL.Checked := StatusBar.Visible;
{Stupid stuff handling}
StupidDO;
{}
PBT.Down := True;
SizeUD.Position := SizePen;
SizeSO.Visible := True;
ZoomSO.Visible := False;
SizeED.Text := IntTostr(SizeUD.Position);
StrUD.Position := StrVal;
StrED.Text := IntToStr(StrUD.Position);
Tag := 2;
end;
procedure TDpeMain.StupidDo;
begin
  shapebox.ItemIndex := ShapeIDX;
  stylebox.ItemIndex := StyleIDX;
  RModeBox.ItemIndex := RetIDX;
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

procedure TDPEMain.MNUTileVertClick(Sender: TObject);
begin
TileMode := tbVertical;
Tile;
end;

procedure TDPEMain.MNUCascadeClick(Sender: TObject);
begin
Cascade;
end;

procedure TDPEMain.NewImage(X,Y,Depth,BackColor : Word);
var bitmap : TBitmap;
begin
Screen.Cursor := crHourGlass;
bitmap := TBitmap.Create;
case Depth of
  0: bitmap.PixelFormat := pf1bit;
  1: bitmap.PixelFormat := pf4Bit;
  2:
  begin
    bitmap.PixelFormat :=  pf8bit;
    //bitmap.Palette := CreateSpectrumPalette;
  end;
  3:
   begin
    bitmap.PixelFormat := pf8bit;
    bitmap.Palette := CreateGrayPalette;
   end;
  4 : bitmap.PixelFormat := pf24bit;
end;
bitmap.Width  := X;
bitmap.Height := Y;
case BackColor of
 0: bitmap.Canvas.Brush.Color := ForeColorP.Color;
 1: bitmap.Canvas.Brush.Color := BackColorP.Color;
 2: bitmap.Canvas.Brush.Color := clWhite;
 3: bitmap.Canvas.Brush.Color := clBlack;
 4: bitmap.Canvas.Brush.Color := clRed;
 5: bitmap.Canvas.Brush.Color := clGreen;
 6: bitmap.Canvas.Brush.Color := clBlue;
end;
if BackColor <> 2 then bitmap.Canvas.FillRect(Rect(0,0,bitmap.Width, bitmap.Height));
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.Caption:= photo.DefName + IntToStr(ImageCount);
LoadedFile := tft.Caption;
tft.Photo.Picture.Graphic := bitmap;
tft.FitImage(x,y);
bitmap.Free;
Screen.Cursor := crDefault;
tft.Photo.Hint := 'New created image';
tft.FormActivate(self);
tft.Saved := False;
CheckTool(MDIChildCount);
end;

procedure TDPEMain.NewMNUClick(Sender: TObject);
var w,h, bitdepth,backcolor : word;
begin
if NewImg.ShowNEWDLG(w,h,bitdepth,backcolor) = mrOK then
  NewImage(w,h,bitdepth,backcolor);
end;

procedure TDPEMain.MNUECClick(Sender: TObject);
begin
Clipboard.Clear;
end;

function TDPEMain.LoadToPicture(var Picture : TPicture; FileName : String) : boolean;
begin
Result := False;
if not FileExists(FileName) then Raise Exception.Create('Cannot open file ' + FileName);
FileExt := ANSILowerCase(ExtractFileExt(FileName));
Screen.Cursor := crHourGlass;
ProgressBar.Position := 0;
ProgressBar.Visible := True;
if (FileExt = '.bmp') or (FileExt = '.tif') or (FileExt = '.tga') or (FileExt = '.pcx') then
begin
     try
        Picture.LoadFromFile(FileName);
     finally
            Screen.Cursor := crDefault;
            ProgressBar.Visible := False;
     end;
end
else if (FileExt = '.jpg') or (FileExt = '.jpe') then LoadJPG(FileName, Picture)
else if (FileExt = '.gif') then LoadGIF(FileName, Picture)
else if (FileExt = '.wmf') or (FileExt = '.emf') then MFImp.ShowWMFImp(FileName,Picture)
else if (FileExt = '.ico') then LoadICO(FileName,Picture)
else
begin
     Picture.Free;
     ProgressBar.Visible := False;
     Screen.Cursor := crDefault;
     Application.MessageBox('The file type of this file is unknown.',Pchar(Application.Title),MB_ICONINFORMATION);
     Exit;
end;
LoadedFile := FileName;
Result := True;
end;

function TDPEMain.LoadFinalize(var Picture : TPicture; FileName : string) : boolean;
begin
tft.Photo.Picture.Assign(Picture);
tft.FitImage(Picture.Width,Picture.Height);
Picture.Free;
tft.Saved := True;
tft.FormActivate(Self);
tft.Photo.Hint := 'File: ' + ExtractFileName(FileName);
tft.Caption := ExtractFileName(LoadedFile);
ProgressBar.Visible := False;
result := true;
end;

procedure TDPEMain.LoadPhoto(FileName : String);
var tmp : TPicture;
    i : integer;
begin
// Check if file is already opened
if MDIChildCount <> 0 then
begin
   for i := MDIChildCount-1 downto 0 do
    if ANSILowerCase(TFPhoto(MDIChildren[i]).PhotoName) = AnsiLowerCase(FileName) then
    begin
      MDIChildren[i].Show;
      exit;
    end;
end;
//
tmp := TPicture.Create;
if not LoadToPicture(tmp,FileName) then Exit;
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
LoadFinalize(tmp,FileName);
CheckTool(MDIChildCount);
end;

procedure TDPEMain.CheckTool(Count : Integer);
begin
tft := TFPhoto(ActiveMDIChild);
if Count = 0 then
begin
 StatusBar.Panels[1].Text := '';
 StatusBar.Panels[2].Text := '';
 FLSave.Enabled := False;
 FLCut.Enabled := False;
 FLCopy.Enabled := False;
 FLClear.Enabled := False;
 FLFS.Enabled := False;
 FLPrint.Enabled := False;
 FLInfo.Enabled := False;
 MNUFS.Enabled := False;
 MNUWindow.Visible := False;
 MNUCut.Visible := False;
 MNUCopy.Visible := False;
 MNUPaste.Visible := False;
 MNUClear.Visible := False;
 MNUPANI.Visible := True;
 MNUSave.Visible := False;
 MNUSaveAS.Visible := False;
 MNUDelete.Visible := False;
 MNUClose.Visible := False;
 MNUSaw.Visible := False;
 MNUPrint.Visible := False;
 MNUPS.Visible := False;
 N6.Visible := False;
 N12.Visible := False;
 MNUImage.Visible := False;
 MNUColors.Visible := False;
 MNUReload.Visible := False;
 MNUUndo.Visible := False;
 FLUndo.Enabled := False;
 N13.Visible := False;
 // Image tools
 PBT.Enabled := False;
 LineT.Enabled := False;
 FFT.Enabled := False;
 ShapeT.Enabled := False;
 DropT.Enabled := False;
 RetT.Enabled := False;
 MoverT.Enabled := False;
 EraserT.Enabled := False;
 SizeUD.Enabled := False;
 SizeED.Enabled := False;
 StyleBox.Enabled := False;
 ShapeBox.Enabled := False;
 StrED.Enabled := False;
 StrUD.Enabled := False;
 RModeBox.Enabled := False;
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
 MNUFS.Enabled := True;
 MNUWindow.Visible := True;
 MNUCut.Visible := True;
 MNUCopy.Visible := True;
 MNUPaste.Visible := True;
 MNUClear.Visible := True;
 MNUPANI.Visible := False;
 MNUSave.Visible := True;
 MNUSaveAS.Visible := True;
 MNUDelete.Visible := True;
 MNUClose.Visible := True;
 MNUSAW.Visible := True;
 MNUPrint.Visible := True;
 MNUPS.Visible := True;
 N6.Visible := True;
 N12.Visible := True;
 MNUImage.Visible := True;
 MNUColors.Visible := True;
 MNUReload.Visible := True;
 MNUUndo.Visible := True;
 N13.Visible := True;
 // Image tools
 PBT.Enabled := True;
 LineT.Enabled := True;
 FFT.Enabled := True;
 ShapeT.Enabled := True;
 DropT.Enabled := True;
 RetT.Enabled := True;
 MoverT.Enabled := True;
 EraserT.Enabled := True;
 SizeUD.Enabled := True;
 SizeED.Enabled := True;
 StyleBox.Enabled := True;
 ShapeBox.Enabled := True;
 StrED.Enabled := True;
 StrUD.Enabled := True;
 RModeBox.Enabled := True;
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
//PBTClick(Sender);
end;

procedure TDPEMain.FLPasteClick(Sender: TObject);
begin
//if MDIChildCount = 0 then
  MNUPANIClick(Sender);
//else MNUICIClick(Sender);
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
       bitmap.PixelFormat := pf24Bit;      // !!
       tft.Photo.Picture.Bitmap.Assign(bitmap);
      finally
       Bitmap.Free;
     end;
     tft.FormActivate(Sender);
     tft.Modified := True;
     CheckTool(MDIChildCount);
   end;
end;

procedure TDPEMain.MNUToolbarClick(Sender: TObject);
begin
Toolbar.Visible := not Toolbar.Visible;
end;

procedure TDPEMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
if MNUFSE.Checked then MNUFSEClick(self);
RecentFiles.SaveToIniFile;
RegSaveToolBarPositions(DPEMain,DPEIniName+ '\Toolbars');
RegIniFile := TRegIniFile.Create(DPEIniName);
RegIniFile.WriteInteger('Options','Top',Top);
RegIniFile.WriteInteger('Options','Left',Left);
RegIniFile.WriteInteger('Options','Width',Width);
RegIniFile.WriteInteger('Options','Height',Height);
{Misc Saving}
RegIniFile.WriteBool('Preferences','HDisplay',HDisplay);
RegIniFile.WriteBool('Preferences','UndoDisabled',UndoDisabled);
{JPEG Saving}
RegIniFile.WriteBool('Format','JPGGrey',JGreyScale);
RegInifile.WriteInteger('Format','JPGQual',JOutQual);
RegIniFile.WriteBool('Format','JPGPr',JProgressive);
{}
{Tool Saving}
RegIniFile.WriteInteger('Paint','Style',StyleIDX);
RegIniFile.WriteInteger('Paint','Shape',ShapeIDX);
RegIniFile.WriteInteger('Paint','Retouch',RetIDX);
RegIniFile.WriteInteger('Paint','Pen',SizePen);
RegIniFile.WriteInteger('Paint','Width',SizeLine);
RegIniFile.WriteInteger('Paint','Line',SizeBox);
RegIniFile.WriteInteger('Paint','Eraser',SizeEraser);
RegIniFile.WriteInteger('Paint','Ret',SizeRet);
RegIniFile.WriteInteger('Paint','RetStr',StrVal);
RegIniFile.WriteInteger('Paint','ForeColor',ForeColorP.Color);
RegIniFile.WriteInteger('Paint','BackColor',BackColorP.Color);

{}
if not (OpenDialog.FileName = '') then reginifile.WriteString('Options','InitialLoadDir',ExtractFileDir(OpenDialog.FileName));
if not (SaveDialog.FileName = '') then reginifile.WriteString('Options','InitialSaveDir',ExtractFileDir(SaveDialog.FileName));
RegIniFile.WriteBool('Options','StatusBar',MNUSL.Checked);
ReginiFile.Free;
end;

procedure TDPEMain.MNUFTWClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
if tft.WindowState <> wsNormal then tft.WindowState := wsNormal;
tft.FitImage(tft.Photo.Picture.Width, tft.Photo.Picture.Height);
end;

procedure TDPEMain.MNUFSClick(Sender: TObject);
begin
if MDIChildCount = 0 then exit;
FS_UN.ShowFS;
end;

procedure TDPEMain.MNUCutClick(Sender: TObject);
begin
//if MDIChildCount = 0 then Exit;
MNUCopyClick(Sender);
MNUClearClick(Sender);
end;

procedure TDPEMain.MNUClearClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.ClearBitmap;
end;

procedure TDPEMain.MNUICIClick(Sender: TObject);
begin
// Code for pasting into the image
end;

procedure TDPEMain.MNUCopyClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
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
if MDIChildCount = 0 then Exit;
    for I := MDIChildCount-1 downto 0 do
      MDIChildren[I].Close;
CheckTool(0);
end;

procedure TDPEMain.SaveToGif(Bitmap: TBitmap; FileName : string);
var tmpbmp : TBitmap;
    GIFImage : TGIFImage;
begin
  ProgressBar.Visible := True;
  tmpbmp := TBitmap.Create;
  try
    tmpbmp.Assign(Bitmap);
    case tmpbmp.PixelFormat of pf24bit:  tmpbmp := TrueColorTo256(tmpbmp);
                               pf4bit,pf1bit : tmpbmp.PixelFormat := pf8bit;
    end;
    if  tmpbmp.Pixelformat <> pf8bit then
    begin
         tmpbmp.Free;
         raise Exception.Create('Unexpected error. Aborting.');
    end;
      GIFImage := TGIFImage.Create;
      try
        GIFImage.OnProgress := EvPrg;
        GIFImage.Assign(tmpbmp);
        GIFImage.SaveToFile(FileName);
      finally
        GIFImage.Free;
      end;
  finally
    tmpbmp.Free;
    ProgressBar.Visible := False;
  end;
end;

procedure TDPEMain.SavetoJPEG(Bitmap : TBitmap;FileName : String);
var JPEGImage : TJPEGImage;
 //   Stream :TMemoryStream;
begin
ProgressBar.Visible := True;
JPEGImage := TJPEGImage.Create;
JPEGImage.OnProgress := EvPrg;
JPEGImage.CompressionQuality := JOutQual;
JPEGImage.ProgressiveEncoding := JProgressive;
JPEGImage.Smoothing := JProgressive;
JPEGImage.Compress;
JPEGImage.Assign(Bitmap);
//Stream := TMemoryStream.Create;
JPEGImage.SaveToFile(FileName);
//Stream.SaveToFile(FileName);
//Stream.Free;
ProgressBar.Visible := False;
end; {SavetoJPEG}

procedure TDPEMain.MNUSaveClick(Sender: TObject);
begin
if MDIChildCount = 0 then exit;
tft := TFPhoto(ActiveMDIChild);
tft.SaveImage;
end;

procedure TDPEMain.MNUFlipClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.FlipBitmap;
end;

procedure TDPEMain.MNUMirrorClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.MirrorBitmap;
end;

procedure TDPEMain.MNUNIClick(Sender: TObject);
begin
tft := TFPhoto(ActiveMDIChild);
tft.InvertBitmap;
end;

procedure TDPEMain.MNUReloadClick(Sender: TObject);
var filename : string;
    pic : TPicture;
begin
if MDIChildCount = 0 then exit;
if MessageDlg('Lose all changes since your last save?',
   mtConfirmation, [mbYes, mbNo], 0) = idNo then exit;
tft := TFPhoto(ActiveMDIChild);
filename := tft.PhotoName;
pic := TPicture.Create;
if not LoadToPicture(pic,FileName) then exit;
tft.Photo.Picture.Assign(pic);
LoadFinalize(pic,FileName);
tft.Modified := False;
end;

procedure TDPEMain.MNUPrintClick(Sender: TObject);
begin
if not MNUPrint.Visible then exit;
end;

procedure TDPEMain.MNUSLClick(Sender: TObject);
begin
MNUSL.Checked := not MNUSL.Checked;
StatusBar.Visible := MNUSL.Checked;
end;

procedure TDPEMain.MNUSoftenClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.SoftenBMP(1);
end;

procedure TDPEMain.MNUCoolColorClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.CoolColorThing;
end;

procedure TDPEMain.MNUGreyScaleClick(Sender: TObject);
begin
tft := TFPhoto(ActiveMDIChild);
tft.GreyBitmap;
end;

procedure TDPEMain.ToolbarVisibleChanged(Sender: TObject);
begin
MNUToolbar.Checked := Toolbar.Visible;
end;

function PrepareGrayPalette : HPalette;
var Pal : TMaxLogPalette;
    PalEntry : TPaletteEntry;
    i : word;
begin
pal.palVersion := $300;
pal.palNumEntries := 256;
for i := 0 to 255 do
begin
     palentry.peRed := i;
     palentry.peGreen := i;
     palentry.peBlue := i;
     palentry.peFlags := 0;
     pal.PalPalEntry[i] := palentry;
end;
Result := CreatePalette(PLogPalette(@Pal)^);
end;

procedure TDPEMain.MNUSChannelsClick(Sender: TObject);
var basebitmap,processedbitmap : TBitmap;
    px,py,n : integer;
    p1 : PRGBByteArray;
    p2 : pByteArray;
    hpal : HPalette;
begin
hpal := PrepareGrayPalette;
tft := TFPhoto(ActiveMDIChild);
basebitmap := TBitmap.Create;
basebitmap.Assign(tft.Photo.Picture.bitmap);
basebitmap.PixelFormat := pf24bit;
/// red rippof
processedbitmap := TBitmap.Create;
processedBitmap.PixelFormat := pf8bit;
processedBitmap.Height := basebitmap.Height;
processedBitmap.Width := basebitmap.Width;
processedBitmap.Palette := hpal;
n := ImageCount+1;
for py := 0 to basebitmap.Height -1 do
begin
     P1 := basebitmap.ScanLine[py];
     p2 := processedbitmap.Scanline[py];
     for px := 0 to basebitmap.Width -1 do
     begin
          p2[px] := p1[px].Red;
     end;
end;
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(basebitmap.Width,basebitmap.Height);
tft.Caption := 'Red' + Inttostr(n);
tft.Photo.Picture.Bitmap.Assign(processedbitmap);
// green ripoff
processedBitmap.Free;
processedbitmap := TBitmap.Create;
processedBitmap.PixelFormat := pf8bit;
processedBitmap.Height := basebitmap.Height;
processedBitmap.Width := basebitmap.Width;
processedBitmap.Palette := hpal;
for py := 0 to basebitmap.Height -1 do
begin
     P1 := basebitmap.ScanLine[py];
     p2 := processedbitmap.Scanline[py];
     for px := 0 to basebitmap.Width -1 do
     begin
          p2[px] := p1[px].Green;
     end;
end;
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(basebitmap.Width,basebitmap.Height);
tft.Caption := 'Green' + Inttostr(n);
tft.Photo.Picture.Bitmap.Assign(processedbitmap);
// blue ripoff
processedBitmap.Free;
processedbitmap := TBitmap.Create;
processedBitmap.PixelFormat := pf8bit;
processedBitmap.Height := basebitmap.Height;
processedBitmap.Width := basebitmap.Width;
processedBitmap.Palette := hpal;
for py := 0 to basebitmap.Height -1 do
begin
     P1 := basebitmap.ScanLine[py];
     p2 := processedbitmap.Scanline[py];
     for px := 0 to basebitmap.Width -1 do
     begin
          p2[px] := p1[px].Blue;
     end;
end;
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(basebitmap.Width,basebitmap.Height);
tft.Caption := 'Blue' + Inttostr(n);
tft.Photo.Picture.Bitmap.Assign(processedbitmap);
tft.FormActivate(Sender);
processedbitmap.Free;
basebitmap.Free;
end;

procedure TDPEMain.MNUDuplicateClick(Sender: TObject);
var baseBitmap : TBitmap;
    cbitmap : TBitmap;
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
basebitmap := TBitmap.Create;
basebitmap.Assign(tft.Photo.Picture.Bitmap);
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(basebitmap.Width,basebitmap.Height);
tft.Caption := photo.DefName + Inttostr(ImageCount);
cbitmap := TBitmap.Create;
cbitmap.PixelFormat := basebitmap.PixelFormat;
cbitmap.Palette := basebitmap.Palette;
cbitmap.Width := basebitmap.Width;
cbitmap.Height := basebitmap.Height;
tft.Photo.Picture.Bitmap.Assign(cbitmap);
tft.Photo.Canvas.Draw(0,0,basebitmap);
cbitmap.Free;
basebitmap.Free;
tft.Saved := False;
tft.FormActivate(Sender);
end;

procedure TDPEMain.FLNewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := NewMNU.Hint;
end;

procedure TDPEMain.FlOpenMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUOpen.Hint;
end;

procedure TDPEMain.flsaveMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUSave.Hint;
end;

procedure TDPEMain.FLCutMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUCut.Hint;
end;

procedure TDPEMain.FLCopyMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUCopy.Hint;
end;

procedure TDPEMain.FLPasteMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUANI.Hint;
end;

procedure TDPEMain.FLClearMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUClear.Hint;
end;

procedure TDPEMain.FLFSMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUFS.Hint;
end;

procedure TDPEMain.FLInfoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
//StatusBar.Panels[0].Text := MNUInfo.Hint;
end;

procedure TDPEMain.FLPrintMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUPrint.Hint;
end;

procedure TDPEMain.FLHelpMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUHelp.Hint;
end;

procedure TDPEMain.MNUI8Click(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.ToXBit(pf8Bit);
end;

procedure TDPEMain.MNUI24Click(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.ToXBit(pf24Bit);
end;

procedure TDPEMain.MNUi4Click(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.ToXBit(pf4Bit);
end;

procedure TDPEMain.MNUD1Click(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.ToXBit(pf1Bit);
end;

procedure TDPEMain.MNUD4Click(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.ToXBit(pf4Bit);
end;

procedure TDPEMain.MNUD8Click(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.DitherTo8Bit;
end;

procedure TDPEMain.MNURotateClick(Sender: TObject);
var angle : integer;
    //autosize : boolean;
begin
if MDIChildCount = 0 then Exit;
if ShowRota(angle{,autosize}) = mrOK then
begin
      tft := TFPhoto(ActiveMDIChild);
      tft.RotateBitmap(angle{,autosize});
end;
end;

procedure TDPEMain.MNUARGBClick(Sender: TObject);
var r,g,b : integer;
begin
if MDIChildCount = 0 then Exit;
if ADCLRun.ShowADCLRDLG(r,g,b,0) = mrOK then
begin
 tft := TFPhoto(ActiveMDIChild);
 tft.RGBAdjustColor(r,g,b,true);
end;
end;

procedure TDPEMain.MNULPClick(Sender: TObject);
begin
if PalOpenDialog.Execute then
begin
     tft := TFPhoto(ActiveMDIChild);
     tft.LoadPalette(PalOpenDialog.FileName);
end;
end;

procedure TDPEMain.MNUSPClick(Sender: TObject);
begin
if PalSaveDialog.Execute then
begin
     tft := TFPhoto(ActiveMDIChild);
     tft.SavePalette(PalSaveDialog.FileName);
end;
end;

procedure TDPEMain.MNUABCClick(Sender: TObject);
var Gamma : integer;
begin
if MDIChildCount = 0 then Exit;
 if LDun.ShowLDDLG(Gamma) = mrOK then
 begin
      tft := TFPhoto(ActiveMDIChild);
      tft.GammaImage(Gamma,True);
 end;
end;

procedure TDPEMain.MNUSolarizeClick(Sender: TObject);
var threshold : integer;
begin
if MDIChildCount = 0 then Exit;
if SolaUN.ShowSolaDLG(threshold) = mrOK then
begin
     tft := TFPhoto(ActiveMDIChild);
     tft.Solarize(threshold);
end;
end;

procedure TDPEMain.MNUAHSLClick(Sender: TObject);
var h,s,v : integer;
begin
if MDIChildCount = 0 then Exit;
if ADCLRUN.ShowADCLRDLG(h,s,v,1) = mrOK then
begin
 tft := TFPhoto(ActiveMDIChild);
 tft.HSVAdjustColor(h,s,v,true);
end;
end;

procedure TDPEMain.MNUAboutClick(Sender: TObject);
begin
ABox.ShowAboutBox;
end;

procedure TDPEMain.MNUColoriseClick(Sender: TObject);
begin
if ColorDialog.Execute then
begin
 tft := TFPhoto(ActiveMDIChild);
 tft.ColoriseImage(GetRValue(ColorToRGB(ColorDialog.Color)),
                   GetGValue(ColorToRGB(ColorDialog.Color)),
                   GetBValue(ColorToRGB(ColorDialog.Color)));
end;
end;

procedure TDPEMain.mnuFFPClick(Sender: TObject);
begin
ffpun.ShowFFP;
end;

procedure TDPEMain.MNUResizeClick(Sender: TObject);
var w,h : word;
    fi : byte;
begin
if MDIChildCount = 0 then exit;
tft := TFPhoto(ActiveMDIChild);
if rszun.ShowRDLG(tft.Photo.Picture.Width,tft.Photo.Picture.Height,w,h,False,FI) = mrOK then
      tft.ResizeBitmap(w,h);
end;

procedure TDPEMain.MNUEPalClick(Sender: TObject);
var tmp : TColor;
begin
epun.ShowEpFRM(tmp,False);
end;

procedure TDPEMain.MNUTileHorzClick(Sender: TObject);
begin
TileMode := tbHorizontal;
Tile;
end;

procedure TDPEMain.MNUCrszClick(Sender: TObject);
var w,h : word;
    center : boolean;
begin
tft := TFPhoto(ActiveMDIChild);
w := tft.Photo.Picture.Width;
h := tft.Photo.Picture.Height;
if ShowCRSZ(w,h,center) = mrOK then
     tft.ResizeCanvas(w,h,center);
end;

procedure TDPEMain.MNUABlendClick(Sender: TObject);
var MDIIndex : integer;
    Grade : byte;
    SrcBitmap : TBitmap;
    T : TFPhoto;
begin
if ShowABLENDDlg(MDIIndex,Grade) = mrOK then
begin
     tft := TFPhoto(ActiveMDIChild);
     T := TFPhoto(MDIChildren[MDIIndex]);
     if t.Photo.Picture.Bitmap.PixelFormat = pf24bit then
        SRCBitmap := T.Photo.Picture.Bitmap
       else
       begin
            SRCBitmap := TBitmap.Create;
            SRCBitmap.PixelFormat := pf24Bit;
            SRCBitmap.Width := T.Photo.Picture.Bitmap.Width;
            SRCBitmap.Height := T.Photo.Picture.Bitmap.Height;
            SRCBitmap.Canvas.Draw(0,0,t.Photo.Picture.Bitmap);
       end;
     tft.AlphaBlend(SRCBitmap,Grade);
     if t.Photo.Picture.Bitmap.PixelFormat <> pf24bit then
        SRCBitmap.Free;
end;
end;

function FileRecycle(_File : TFilename): boolean;
var Struct: TSHFileOpStruct;
    pFromc: array[0..255] of char;
    Resul:  integer;
begin
 if not FileExists(_File) then
 begin
  FileRecycle := False;
  exit;
 end
 else
 begin
  fillchar(pfromc,SizeOf(pfromc),0);
  StrPcopy(pfromc,ExpandFileName(_File)+#0#0);
  Struct.wnd := 0;
  Struct.wFunc := FO_DELETE;
  Struct.pFrom := pFromC;
  Struct.pTo   := nil;
  Struct.fFlags:= FOF_ALLOWUNDO ;
  Struct.fAnyOperationsAborted := false;
  Struct.hNameMappings := nil;
  Resul := ShFileOperation(Struct);
  FileRecycle := (Resul = 0);
 end;
end; {FileRecycle}

procedure TDPEMain.MNUDeleteClick(Sender: TObject);
begin
if MDIChildCount = 0 then exit;
tft := TFPhoto(ActiveMDIChild);
FileRecycle(tft.PhotoName);
if not FileExists(tft.PhotoName) then tft.Saved:=False;
tft.FormActivate(Sender);
end;

procedure TDPEMain.MNUSAWClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
FileExt := ANSILowerCase(ExtractFileExt(tft.PhotoName));
if (FileExt = '.gif') or (FileExt = '.tga') or (FileExt = '.pcx')
or (FileExt = '.jpg') or (FileExt = '.wmf') or (FileExt = '.emf')
or (FileExt = '.ico') or (not tft.Saved) then
begin
     if Application.MessageBox('File is not saved as Windows Bitmap. Do you want to save it?', PChar(Application.Title), mb_YESNO) = IDYES then
     begin
          if SaveDialog.Execute then
          begin
               SaveDialog.InitialDir := ExtractFileDir(SaveDialog.FileName);
               Screen.Cursor := crHourGlass;
               if (Pos ('.', SaveDialog.FileName) = 0) then
               SaveDialog.FileName := Concat (SaveDialog.FileName, '.BMP');
               try
                  tft.Photo.Picture.SaveToFile(SaveDialog.FileName);
               finally
                      screen.Cursor := crDefault;
               end;
               RecentFiles.LatestFile := SaveDialog.FileName;
               SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(SaveDialog.FileName), SPIF_UPDATEINIFILE+SPIF_SENDWININICHANGE);
          end;
     end
     else Exit;
end
else
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(tft.PhotoName), SPIF_UPDATEINIFILE+SPIF_SENDWININICHANGE);
end;

procedure TDPEMain.MNUButtonizeClick(Sender: TObject);
var edge : integer;
    smooth : Boolean;
begin
if MDIChildCount = 0 then Exit;
if btnzun.ShowBTNeff(edge,smooth) = mrOK then
begin
     tft := TFPhoto(ActiveMDIChild);
     tft.MakeButton(edge,smooth);
end;
end;

procedure TDPEMain.MNUCPClick(Sender: TObject);
begin
ColorsTB.Visible := not ColorsTB.Visible;
end;

procedure TDPEMain.ColorsTBVisibleChanged(Sender: TObject);
begin
MNUCp.Checked := ColorsTB.Visible;
FLColors.Down := ColorsTB.Visible;
end;

procedure TDPEMain.FlipBTNClick(Sender: TObject);
var Cl : TColor;
begin
cl := BackColorP.Color;
BackColorP.Color := ForeColorP.Color;
ForeColorP.Color := cl;
end;

procedure TDPEMain.ForeColorPClick(Sender: TObject);
var tmp : TColor;
begin
if MDIChildCount = 0 then
begin
if ColorDialog.Execute then
  ForeColorP.Color := ColorDialog.Color;
end
else
begin
  tft := TFPhoto(ActiveMDIChild);
  case tft.Photo.Picture.Bitmap.PixelFormat of
    pf24bit:
    begin
         if ColorDialog.Execute then
         begin
            ForeColorP.Color := ColorDialog.Color;
         end;
    end;
    pf8bit,pf4bit,pf1bit :
    begin
      if epun.ShowEPFrm(tmp,True) = mrOk then ForeColorP.Color := tmp;
    end;
  end;
end;
SetMColor(ForeColorP.Color);
end;

procedure TDPEMain.BackColorPClick(Sender: TObject);
var tmp : TColor;
begin
if MDIChildCount = 0 then
begin
if ColorDialog.Execute then
  BackColorP.Color := ColorDialog.Color;
end
else
begin
  tft := TFPhoto(ActiveMDIChild);
  case tft.Photo.Picture.Bitmap.PixelFormat of
    pf24bit:
    begin
         if ColorDialog.Execute then
            BackColorP.Color := ColorDialog.Color;
    end;
    pf8bit,pf4bit,pf1bit :
    begin
      if epun.ShowEPFrm(tmp,True) = mrOk then BackColorP.Color := tmp;
    end;
  end;
end;
SetMColor(BackColorP.Color);
end;
procedure TDPEMain.NeutralizeColorPal;
const slashes = '--';
begin
 rccap.Caption := slashes;
 bccap.Caption := slashes;
 gccap.Caption := slashes;
 mcolor.Color := clBtnFace;
end;
procedure TDPEMain.fclMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
NeutralizeColorPal;
end;

procedure TDPEMain.ForeColorPMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
SetMColor(ForeColorP.Color);
end;

procedure TDPEMain.SetMColor(NewValue : TColor);
begin
if HDisplay then
begin
     rccap.Caption := IntToHex(GetRValue(NewValue),2);
     gccap.Caption := IntToHex(GetGValue(NewValue),2);
     bccap.Caption := IntToHex(GetBValue(NewValue),2);
end
else
begin
     rccap.Caption := IntTosTr(GetRValue(NewValue));
     gccap.Caption := IntTosTr(GetGValue(NewValue));
     bccap.Caption := IntTosTr(GetBValue(NewValue));
end;
     mColor.Color := newValue;
end;
procedure TDPEMain.BackColorPMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
SetMColor(BackColorP.Color);
end;
var mb : TMouseButton;
    down : Boolean;
procedure TDPEMain.hsvgenimgMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
SetMColor(hsvgenimg.Canvas.Pixels[x,y]);
if down then
case mb of mbLeft:
 ForeColorP.Color := hsvgenimg.Canvas.Pixels[x,y];
  mbRight : BackColorP.Color := hsvgenimg.Canvas.Pixels[x,y];
end;
end;

procedure TDPEMain.hsvgenimgMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
down := true;
mb := Button;
case mb of mbLeft:
 ForeColorP.Color := hsvgenimg.Canvas.Pixels[x,y];
  mbRight : BackColorP.Color := hsvgenimg.Canvas.Pixels[x,y];
end;
end;

procedure TDPEMain.hsvgenimgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
down := false;
end;

procedure TDPEMain.cselpnlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
NeutralizeColorPal;
end;

procedure TDPEMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
NeutralizeColorPal;
end;

procedure TDPEMain.FLColorsMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
StatusBar.Panels[0].Text := MNUCP.Hint;
end;

procedure TDPEMain.MNUITClick(Sender: TObject);
begin
ITTB.Visible := not ITTB.Visible;
end;

procedure TDPEMain.ITTBVisibleChanged(Sender: TObject);
begin
MNUIt.Checked := ITTB.Visible;
FLIT.Down := ITTB.Visible;
end;

procedure TDPEMain.MNUSBClick(Sender: TObject);
begin
StyleBarTB.Visible := not StyleBarTB.Visible;
end;

procedure TDPEMain.StyleBARTBVisibleChanged(Sender: TObject);
begin
MNUSB.Checked := StyleBarTB.Visible;
FLStyle.Down := StyleBarTB.Visible;
end;

procedure TDPEMain.PBTClick(Sender: TObject);
begin
ZoomSO.Visible := False;
SizeSO.Visible := True;
RectSO.Visible := False;
RetSO.Visible := False;
SizeCap.Caption := 'Size';
SizeUD.Position := SizePen;
SizeED.Hint := 'Size';
SizeED.Text := IntTostr(SizeUD.Position);
Tag := 2;
end;

procedure TDPEMain.linetClick(Sender: TObject);
begin
ZoomSO.Visible := False;
RectSO.Visible := False;
SizeSO.Visible := True;
RetSo.Visible := False;
SizeCap.Caption := 'Width';
SizeED.Hint := 'Width';
SizeUD.Position := SizeLine;
SizeED.Text := IntTostr(SizeUD.Position);
Tag := 3;
end;

procedure TDPEMain.shapetClick(Sender: TObject);
begin
ZoomSO.Visible := False;
RectSO.Visible := True;
RetSo.Visible := False;
SizeSO.Visible := True;
SizeCap.Caption := 'Line';
SizeUD.Position := SizeBox;
SizeED.Hint := 'Outline Width';
SizeED.Text := IntTostr(SizeUD.Position);
Tag := 4;
end;

procedure TDPEMain.shapeboxChange(Sender: TObject);
begin
ShapeIDX := shapebox.ItemIndex;
end;

procedure TDPEMain.StyleBARTBDockChanged(Sender: TObject);
begin
StupidDo;
end;

procedure TDPEMain.StyleboxChange(Sender: TObject);
begin
StyleIDX := stylebox.ItemIndex;
end;

procedure TDPEMain.sizeudClick(Sender: TObject; Button: TUDBtnType);
begin
if PBT.Down then
  SizePen := sizeud.Position;
if linet.Down then
  SizeLine := sizeud.Position;
if shapet.Down then
  SizeBox := sizeud.Position;
if RetT.Down then
  SizeRet := sizeud.Position;
if EraserT.Down then
  SizeEraser := sizeud.Position;
end;

procedure TDPEMain.SizeEDChange(Sender: TObject);
begin
if SizeEd.Text <> '' then
begin
 if PBT.Down then
   SizePen := StrToInt(SizeED.Text);
 if linet.Down then
   SizeLine := StrToInt(SizeED.Text);
 if shapet.Down then
   SizeBox := StrToInt(SizeED.Text);
 if retT.Down then
   SizeRet := StrToInt(SizeED.Text);
 if EraserT.Down then
   SizeEraser := StrToInt(SizeED.Text);  
end;
end;

procedure TDPEMain.fftClick(Sender: TObject);
begin
ZoomSO.Visible := False;
SizeSO.Visible := False;
RectSO.Visible := False;
RetSO.Visible := False;
ZoomSO.Visible := True;
Tag := 5;
end;

procedure TDPEMain.PBTMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Draw on image using various styles of paint brushes';
end;

procedure TDPEMain.linetMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Draw a line on the image';
end;

procedure TDPEMain.fftMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Fill an area of the image';
end;

procedure TDPEMain.shapetMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Draw shapes on the image';
end;

procedure TDPEMain.DropTMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Pick up a color from the image (Left click for foreground color, right click for background color)'
end;

procedure TDPEMain.DropTClick(Sender: TObject);
begin
ZoomSO.Visible := False;
SizeSO.Visible := False;
RectSO.Visible := False;
RetSO.Visible := False;
ZoomSO.Visible := True;
Tag := 6;
end;

procedure TDPEMain.RetTClick(Sender: TObject);
begin
ZoomSO.Visible := False;
RectSO.Visible := False;
RetSo.Visible := True;
SizeSO.Visible := True;
SizeUD.Position := SizeRet;
SizeED.Text := IntTostr(SizeUD.Position);
StrUD.Position := StrVal;
SizeED.Hint := 'Size';
StrEd.Text := IntToStr(StrUD.Position);
SizeCap.Caption := 'Size';
Tag := 7;
end;

procedure TDPEMain.RModeBoxChange(Sender: TObject);
begin
RetIDX := RModeBox.ItemIndex;
end;

procedure TDPEMain.strudClick(Sender: TObject; Button: TUDBtnType);
begin
if RetT.Down then
  StrVal := strud.Position;
end;

procedure TDPEMain.StrEDChange(Sender: TObject);
begin
if StrEd.Text = '' then Exit;
if RetT.Down then
  StrVal := StrToInt(StrEd.Text);
end;

procedure TDPEMain.RetTMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Draw on image using various photo retouching tools';
end;

procedure TDPEMain.FLITMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text  := MNUIT.Hint;
end;

procedure TDPEMain.FLStyleMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUSB.Hint;
end;

procedure TDPEMain.MNUADBRDRClick(Sender: TObject);
var TopA, BottomA, LeftA, RightA : integer;
begin
if adbrdrun.ShowADDBRDRDLG(TopA, BottomA, LeftA, RightA) = mrOk then
begin
     tft := TFPhoto(ActiveMDIChild);
     tft.AddBorders(TopA, BottomA, LeftA, RightA);
end;
end;

procedure TDPEMain.MNUGPrefsClick(Sender: TObject);
begin
prun.ShowPref;
end;

procedure TDPEMain.MNUUndoClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.DoUndo;
end;

procedure TDPEMain.FLUndoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := MNUUndo.Hint;
end;

procedure TDPEMain.MoverTClick(Sender: TObject);
begin
ZoomSO.Visible := False;
SizeSO.Visible := False;
RectSO.Visible := False;
RetSO.Visible := False;
ZoomSO.Visible := True;
Tag := 8;
end;

procedure TDPEMain.MoverTMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Move the visible area of the image';
end;

procedure TDPEMain.EraserTClick(Sender: TObject);
begin
ZoomSO.Visible := False;
SizeSO.Visible := True;
RectSO.Visible := False;
RetSO.Visible := False;
SizeCap.Caption := 'Size';
SizeUD.Position := SizeEraser;
SizeED.Hint := 'Size';
SizeED.Text := IntTostr(SizeUD.Position);
Tag := 9;
end;

procedure TDPEMain.EraserTMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
StatusBar.Panels[0].Text := 'Erase or undo parts of the image';
end;

procedure TDPEMain.FormDestroy(Sender: TObject);
begin
  // Remove ourselves from the clipboard viewer chain.
  ChangeClipboardChain(Handle, FNextViewerHandle);
end;

procedure TDPEMain.MNUAContrastClick(Sender: TObject);
var value : integer;
begin
if MDIChildCount = 0 then Exit;
 if Conun.ShowContraDLG(value) = mrOK then
 begin
      tft := TFPhoto(ActiveMDIChild);
      tft.ChangeContrast(value,True);
 end;
end;

procedure TDPEMain.MNUResampleClick(Sender: TObject);
var w,h : word;
    fi : byte;
begin
if MDIChildCount = 0 then exit;
tft := TFPhoto(ActiveMDIChild);
if rszun.ShowRDLG(tft.Photo.Picture.Width,tft.Photo.Picture.Height,w,h,True,fi) = mrOK then
      tft.ResampleBitmap(w,h,fi);
end;

procedure TDPEMain.MNUSharpenClick(Sender: TObject);
begin
if MDIChildCount = 0 then Exit;
tft := TFPhoto(ActiveMDIChild);
tft.SharpenImage;
end;

procedure TDPEMain.ChannelCombine(rb, gb, bb : TBitmap);
var tmp : TBitmap;
    x,y : integer;
    p24 : PRGBByteArray;
    pr,pg,pb : PByteArray;
begin
//if rb <> pf8bit)
if not ((rb.Width = gb.Width) and (rb.Width = bb.Width) and (rb.Height = gb.Height) and (rb.Height = bb.Height)) then
begin
 Application.MessageBox('Channel combining can only be done when all of source images you select are of the same width and height', PCHar(Application.Title),MB_ICONASTERISK);
 Exit;
end;
tmp := TBitmap.Create;
tmp.PixelFormat := pf24bit;
tmp.Width := rb.Width;
tmp.Height := rb.Height;
for y := 0 to rb.Height -1 do
begin
     p24 := tmp.ScanLine[y];
     pr := rb.ScanLine[y];
     pg := gb.ScanLine[y];
     pb := bb.ScanLine[y];
     for x := 0 to rb.Width -1 do
     begin
          p24[x].Red := pr[x];
          p24[x].Green := pg[x];
          p24[x].Blue := pb[x];
     end;
end;
Inc(ImageCount);
TFPhoto.Create(Self);
tft := TFPhoto(ActiveMDIChild);
tft.FitImage(tmp.Width,tmp.Height);
tft.Caption:= photo.DefName + IntToStr(ImageCount);
tft.Photo.Picture.Bitmap.Assign(tmp);
tmp.Free;
tft.FormActivate(self);
tft.Saved := False;
end;

procedure TDPEMain.MNUCombiningClick(Sender: TObject);
var rb, gb , bb : TBitmap;
    ri, gi , bi : integer;
    t : TFPhoto;
    i : integer;
    found : boolean;
begin
found := False;
for I := 0 to DPEMain.MDIChildCount-1 do
begin
     t := TFPhoto(DPEMain.MDIChildren[i]);
     if t.Photo.Picture.Bitmap.PixelFormat = pf8bit then
      Found := True;
end;
if not Found then
begin
     Application.MessageBox('There must be at least on 8 bit image currently open', PChar(Application.Title), MB_ICONASTERISK);
     exit;
end;
if ccun.ShowCCDLG(ri,gi,bi) = mrOK then
begin
     rb := TBitmap.Create;
     t := TFPhoto(MDIChildren[ri]);
     rb.Assign(t.Photo.Picture.Bitmap);
     gb := TBitmap.Create;
     t := TFPhoto(MDIChildren[gi]);
     gb.Assign(t.Photo.Picture.Bitmap);
     bb := TBitmap.Create;
     t := TFPhoto(MDIChildren[bi]);
     bb.Assign(t.Photo.Picture.Bitmap);
     ChannelCombine(rb,gb,bb);
     rb.Free;
     gb.Free;
     bb.Free;
end;
end;

procedure TDPEMain.MNUFSEClick(Sender: TObject);
var tmp : integer;
begin
if MNUFSE.Checked then
begin
  Top := oldpos.Top;
  Left := oldPos.Left;
  Width := oldpos.Right;
  Height := oldpos.Bottom;
  WindowState := oldState;
  BorderStyle := bsSizeable;
end
else
begin
  oldstate := WindowState;
  oldpos.Top := Top;
  oldpos.Left := Left;
  oldpos.Bottom := Height;
  oldpos.Right := Width;
  windowstate := wsNormal;
  BorderStyle := bsNone;
  tmp := {(GetSystemMetrics(SM_CYEDGE)*2)+  GetSystemMetrics(SM_CYCAPTION)+} GetSystemMetrics(SM_CYMENU)-2;
  Top := - tmp;
  Left := 0;
  Height := Screen.Height  +tmp+Statusbar.Height;
  Width := Screen.Width;
end;
 mnufse.Checked := not MNUFSe.Checked;
 StupidDO;
end;

end.
