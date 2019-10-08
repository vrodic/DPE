unit DMGMain;

interface

uses Windows;

{==============================================	exported Main-Functions}
procedure mg_GraphicError(Win: tHandle; Tit, Zus: pChar; Error: word); stdcall;
function  mg_GetLastError: word; stdcall;
function  mg_LoadThePicture(Name: pChar; InMem: bool): pBitmapInfo; stdcall;
function  mg_CheckFormat(Extension: pChar): Bool; stdcall;
procedure mg_SetTheCallBack(CallBack: tFarProc); stdcall;
procedure mg_FreeTheDIB(pBMI: pBitmapInfo); stdcall;

implementation

uses DMGBasic, DMGrBMP, DMGrJPEG, DMGrPCX, DMGrTGA, SysUtils;
{$R DMGError.res}

{==============================================	private Functions}

{----------------------------------------------	GetFormatTyp}
function GetFormatTyp(Extension: PChar): tImageFormat;
var Buf: string;
begin
  Buf := AnsiLowerCase(StrPas(Extension));
  if (Buf = '.bmp') OR (Buf = '.dib') OR (Buf = '.rle') then Result := tbf_BMP
  else if (Buf = '.jpg') {or (Buf = '.jpe')} then Result := tbf_JPG
  else if (Buf = '.tga') then Result := tbf_TGA
  else if (Buf = '.pcx') then Result := tbf_PCX
  else Result := tbf_Unknown;
end {function GetFormatTyp};

{----------------------------------------------	mg_GraphicError}
procedure mg_GraphicError(Win: tHandle; Tit, Zus: pChar; Error: word);
var
Buf             : string;
begin
  if (Error > MGERR_LAST) OR (Error < MGERR_FIRST) then exit;
  Buf := LoadStr(Error);
  if (Zus <> nil) then Buf := Buf + Zus;
  MessageBeep(mb_IconHand);
  MessageBox(Win, pChar(Buf), Tit, mb_IconHand);
end {procedure mg_GrafikFehler};
{----------------------------------------------	mg_GetLastError}
function mg_GetLastError: word;
begin
  Result := mg_LastError;
  mg_LastError := 0;
end {function mg_GetLastError};
{----------------------------------------------	mg_CheckFormat}
function mg_CheckFormat(Extension: pChar): Bool;
begin
  if (GetFormatTyp(Extension) <> tbf_Unknown)
  then mg_CheckFormat := true
  else mg_CheckFormat := false;
end {function mg_CheckFormat};
{----------------------------------------------	mg_SetTheCallBack}
procedure mg_SetTheCallBack(CallBack: tFarProc);
begin
  MulTa := CallBack;
end {procedure mg_SetTheCallBack};
{----------------------------------------------	mg_LoadThePicture}
function mg_LoadThePicture(Name: pChar; InMem: bool): pBitmapInfo;
var
Buf             : string;
bErg            : boolean;
begin
  {------------	DMGS initialising}
  FillChar(DMGS, sizeof(tDMGS), #0);
  mg_LastError  := 0;
  DMGS.ImageName := Name;
  InMemory      := InMem;                       {laden vom Speicher/Datei}
  {------------	Test file existance}
  if FileExists(DMGS.ImageName)
  then begin
       {-------- Image file format testing}
       Buf := ExtractFileExt(StrPas(Name));
       case GetFormatTyp(pChar(Buf)) of
            tbf_BMP:  bErg := LoadTheDIB;
            tbf_JPG:  bErg := LoadTheJPG;
            tbf_TGA:  bErg := LoadTheTGA;
            tbf_PCX:  bErg := LoadThePCX;
            else begin
                 mg_LastError := MGERR_NOTSUPPORT;
                 bErg  := false;
            end;
       end {case FormatTyp};
       if bErg then Result := DMGS.pBMI else Result := nil;
  end {FileExists}
  else begin
       Result := nil;
       mg_LastError := MGERR_FILENOTFND;
  end;
end {function mg_LoadThePicture};
{----------------------------------------------	mg_FreeTheDIB}
procedure mg_FreeTheDIB(pBMI: pBitmapInfo);
begin
  if (pBMI <> nil) then FreeMem(pBMI);
end {procedure mg_FreeTheDIB};

end.
