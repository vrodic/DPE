unit PcxTga;

interface

uses
  Windows, SysUtils, Classes, Graphics;

type

  { TPcxMap Class }
  TPcxMap = class(TBitmap)
  private
    { Private declarations }
  public
    {constructor Create; override;
    destructor Destroy; override;}
    procedure LoadFromStream(Stream: TStream); override;
  end;

  { TTgaMap class }
  TTgaMap = class(TBitmap)
  private
    { Private declarations }
  public
    {constructor Create; override;
    destructor Destroy; override;}
    procedure LoadFromStream(Stream: TStream); override;
  end;


implementation

uses DmgBasic,DMGMain;
const TGAc = 1;
      PCXc = 2;

{constructor TPcxMap.Create;
begin
  inherited Create;
end;

destructor TPcxMap.Destroy;
begin
  inherited Destroy;
end;

constructor TTgaMap.Create;
begin
  inherited Create;
end;

destructor TTgaMap.Destroy;
begin
  inherited Destroy;
end;}

procedure TPcxmap.LoadFromStream(Stream: TStream);
var Bitmap  : hBitmap;
    NewDIB  : pBitmapInfo;
    FStream : TMemoryStream;
begin
  FStream := TMemoryStream.Create;
  FStream.CopyFrom(Stream, Stream.Size);
  FStream.Position := 0;
  NewDIB := mg_LoadThePicture(pcxc,FStream);
  if (NewDIB = nil) then
  begin
       raise exception.Create(LoadErrStr);
       Exit;
  end;
  {DIB to BMP conversion}
  Bitmap := mg_MakeBMPfromDIB(NewDIB);
  {error?}
  if (Bitmap = 0) then
       raise Exception.Create(errbmpstr)
  else begin
       TBitmap(Self).Handle := Bitmap;
       //Changed(Self);
  end;
  //FStream.Free;  // This line causes error ??
end;

procedure TTGAmap.LoadFromStream(Stream: TStream);
var Bitmap  : hBitmap;
    NewDIB  : pBitmapInfo;
    FStream : TMemoryStream;
begin
  FStream := TMemoryStream.Create;
  FStream.CopyFrom(Stream, Stream.Size);
  FStream.Position := 0;
  NewDIB := mg_LoadThePicture(TGAC,FStream);
  if (NewDIB = nil) then
  begin
       raise exception.Create(LoadErrStr);
       Exit;
  end;
  {DIB to BMP conversion}
  Bitmap := mg_MakeBMPfromDIB(NewDIB);
  {error?}
  if (Bitmap = 0) then
       raise Exception.Create(errbmpstr)
  else begin
       TBitmap(Self).Handle := Bitmap;
       //Changed(Self);
  end;
  //FStream.Free;  // This line causes error ??
end;

initialization
  { register the TPcxMap and TTgaMap as a new graphic file format
    now all the TPicture storage stuff can access our new
    Pcx and Tga graphic format !
  }
  TPicture.RegisterFileFormat('pcx','PCX-Format', TPcxMap);
  TPicture.RegisterFileFormat('tga','TGA-Format', TTgaMap);
end.
