unit DMGMain;

interface

uses Windows,Classes;

{==============================================	exported Main-Functions}
function mg_LoadThePicture(t : byte; var FStream : TMemoryStream): pBitmapInfo;
procedure mg_SetTheCallBack(CallBack: tFarProc);
procedure mg_FreeTheDIB(pBMI: pBitmapInfo);

implementation

uses DMGBasic, DMGrPCX, DMGrTGA, SysUtils;

{----------------------------------------------	mg_SetTheCallBack}
procedure mg_SetTheCallBack(CallBack: tFarProc);
begin
  MulTa := CallBack;
end {procedure mg_SetTheCallBack};
{----------------------------------------------	mg_LoadThePicture}
function mg_LoadThePicture(t : byte; var FStream : TMemoryStream): pBitmapInfo;
var ReadOK            : boolean;
begin
  {------------	DMGS initialising}
  FillChar(DMGS, sizeof(tDMGS), #0);
  mg_LastError  := 0;
  ReadOK := False;
  if not GetPictureStream(FStream) then raise Exception.Create(LOADERRSTR);
  case t of
          1:  ReadOK := LoadTheTGA;
          2:  ReadOK := LoadThePCX;
       end {case FormatTyp};
       if ReadOK then Result := DMGS.pBMI else Result := nil;
end {function mg_LoadThePicture};
{----------------------------------------------	mg_FreeTheDIB}
procedure mg_FreeTheDIB(pBMI: pBitmapInfo);
begin
  if (pBMI <> nil) then FreeMem(pBMI);
end {procedure mg_FreeTheDIB};

end.
