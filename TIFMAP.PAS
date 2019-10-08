unit TifMap;

interface

uses Windows, SysUtils, Classes, Graphics, Dialogs;

const
  { Data for TIFF format }
  TIFFIntel         =  18761;
  TIFFMotorola      =  19789;
  TIFFLongMask      =  65535;
  TIFFHiColMask     =  65280;
  TIFFLoColMask     =  255;
  TIFFDataMask      =  120;

  { Dimension TIFF }
  TIFFbyte          =  1;
  TIFFascii         =  2;
  TIFFshort         =  3;
  TIFFlong          =  4;
  TIFFractional     =  5;

  { Type of compression }
  TIFFCompNone      =  1;
  TIFFCompHuff      =  2;
  TIFFCompFax3      =  3;
  TIFFCompFax4      =  4;
  TIFFCompLzwT      =  5;
  TIFFCompPack      =  32773;

  { Costants for decompression }
  LZWMINCODESIZE    = 9;
  LZWMAXCODESIZE    = 12;
  MAXCODES          = 4095;				{ the maximum number of different codes 0 inclusive }

  CodeMask: array[0..14] of Word = (  { bit masks for use with Next code }
    0,
    $0001, $0003,
    $0007, $000F,
    $001F, $003F,
    $007F, $00FF,
    $01FF, $03FF,
    $07FF, $0FFF,
    $1FFF, $3FFF);

  { Colori }
  RGB_RED              =  0;
  RGB_GREEN            =  1;
  RGB_BLUE             =  2;
  RGB_SIZE             =  3;

  { Nomi Tag TIFF }
  NewSubFile           =  254;
  SubfileType          =  255;
  ImageWidth           =  256;
  ImageLength          =  257;
  RowsPerStrip         =  278;
  StripOffSets         =  273;
  StripByteCounts      =  279;
  SamplesPerPixel      =  277;
  BitsPerSample        =  258;
  Compression          =  259;
  PredictorType        =  317;
  PlanarConfiguration  =  284;
  Group3Options        =  292;
  Group4Options        =  293;
  FillOrder            =  266;
  Threshholding        =  263;
  CellWidth            =  264;
  CellLength           =  265;
  MinSampleValue       =  280;
  MaxSampleValue       =  281;
  PhotometricInterp    =  262;
  GrayResponseUnit     =  290;
  GrayResponseCurve    =  291;
  ColorResponseUnit    =  300;
  ColorResponseCurves  =  301;
  XResolution          =  282;
  YResolution          =  283;
  ResolutionUnit       =  296;
  Orientation          =  274;
  DocumentName         =  269;
  PageName             =  285;
  XPosition            =  286;
  YPosition            =  287;
  PageNumber           =  297;
  ImageDescription     =  270;
  Make                 =  271;
  Model                =  272;
  FreeOffsets          =  288;
  FreeByteCounts       =  289;
  ColorMap             =  320;
  Artist               =  315;
  DateTime             =  306;
  HostComputer         =  316;
  Software             =  305;

  { error constants }
  geNoError         =  0;  { no errors found }
  geNoFile          =  1;  { tiff file not found }
  geNotTIF          =  2;  { file is not a tiff file }
  geFileTooLong     =  3;  { no Global Color table found }
  geBadData         =  4;  { image descriptor preceeded by other unknown data }
  geFormatUnsup     =  5;  { Block has no data }
  geUnExpectedEOF   =  6;  { unexpected EOF }
  geBadCodeSize     =  7;  { bad code size }
  geBadCode         =  8;  { Bad code was found }
  geBitSizeOverflow =  9;  { bit size went beyond 12 bits }
  geNoBMP           = 10;  { Could not make BMP file }

  ErrName: Array[1..10] of string = (
	'TIFF file not found',
	'Not a TIFF file',
	'File Too big',
	'Bad data',
	'Unsupported Format',
 	'Unexpected EOF',
	'Bad code size',
	'Bad code',
	'Bad bit size',
  'Bad bitmap');


type
  ETifException = class(Exception)
  end;

type
  GraphicLine      = array [0..7200] of byte;
  PBmLine         = ^TBmpLinesStruct;
  TBmpLinesStruct = record
    LineData  : GraphicLine;
    LineNo    : Integer;
  end;

Type
  TColorItem = record			{ one item a a color table }
    Red: Byte;
    Green: Byte;
    Blue: Byte;
  end;

Type
  TColorTable = Array[0..255] of TColorItem;	{ the color table }

Type
  TFileDescriptor = record
    Palette: TColorTable;
    Width: Integer;
    Depth: Integer;
    bits: Integer;
  End;

type
  TImageDescriptor = record
    Photomet: Word;
    NumberType: Word;
    RowsPerStrip: Word;
    Count: Word;
    Samples: Word;
    PlanarConfig: Word;
    Compression: Word;
    Predictor: Word;
    BitsPerSample: Word;
    Palette: Boolean;
    ByteCount: LongInt;
    Offset: LongInt;
  End;

Type
  TTifmap = class(TBitmap)
  private
    FStream: TMemoryStream;       	                { the file stream for the gif file }
    ID: TImageDescriptor;                     { image descriptor }
    FD: TFileDescriptor;                      { file descriptor }
    BmHeader: TBitmapInfoHeader;              { File Header for bitmap file}
    LineBuffer: GraphicLine;                  { array for buffer line output }
    ImageLines: TList;                        { Image data}
    CurrentY  : Integer;                      { current screen locations }
    AuxWord: Array [1..2] Of Byte;
    AuxLong: Array [1..4] Of Byte;

    { ****** LZW Decompresion ****** }
    ClearCode     : Word;
    EndingCode    : Word;
    Code          : Word;
    OldCode       : Word;
    FirstFreeSlot : Word;
    BytesWrited   : Word;   { Number of bytes written to LineBuffer }
    CurrCodeSize  : Byte;
    CurrByte      : Byte;
    BitsLeft      : Byte;
    LZWTable: Array [0..MAXCODES] Of String;

    procedure InitializeTable;
    procedure WriteString(StrOut: String; LineWidth: Integer);
    Function AddStringToTable(NewEntry: String): Boolean;
    Function GetNextCode: Word;
    Function IsInTable(Code: Word): Boolean;
    Function StringFromCode(Code: Word): String;
    { ****** End LZW Decompresion ****** }

    procedure Error(ErrCode: integer);
    Procedure ReadTiff;
    Function ReadLine(Bytes: Integer): Boolean;
    Function ReadPackLine(Bytes: Integer): Boolean;
    Function ReadLZWData(Bytes: Integer): Boolean;
    Function GetWord: Word;
    Function GetLong: LongInt;
    Procedure DecodeTag;
    Procedure SetDefaults;
    procedure CreateLine;
    procedure InsertLine;
    procedure CreateBitHeader;                {Takes Tif info. and converts to BMP}
    procedure SaveTifToStream(Stream: TStream);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
  end;


implementation

uses Math, dpemform;

constructor TTifmap.Create;
begin
  inherited Create;
  FStream := nil;
  ImageLines := TList.Create;
end;

destructor TTifmap.Destroy;
begin
  ImageLines.Free;
  inherited Destroy;
end;

procedure TTifmap.Error(ErrCode: integer);
begin
  raise ETifException.Create(ErrName[ErrCode]);
end;

procedure TTifmap.LoadFromStream(Stream: TStream);
begin
  {this if want percent}
  DPEMain.ProgressBar.Visible := True;
  { }
  try
    FStream := TMemoryStream.Create;
    FStream.CopyFrom(Stream, Stream.Size);
    FStream.Position := 0;
    CurrentY := 0;
    ReadTiff;
    CreateBitHeader;
    try
      SaveTifToStream(FStream);
      inherited LoadFromStream(FStream);
    Finally
      FStream.Free;
    end;
  Finally
  end;
  {this if want percent}
  DPEMain.ProgressBar.Visible := False;
  { }
end;

Procedure TTifmap.ReadTiff;
Var
  L: LongInt;
  I, J, N, Bytes: Word;
Begin
  ImageLines.Clear;
  ImageLines.Capacity := FD.Depth;
  ID.NumberType := GetWord;
  If (ID.NumberType <> TIFFIntel) And (ID.NumberType <> TIFFMotorola) Then
  Begin
    Error(geNotTIF);
    Exit;
  End;
  GetWord;
  L := GetLong;
  FStream.Position := L;
  SetDefaults;
  N := GetWord;
  For I := 0 To (N - 1) Do DecodeTag;
  If (FD.Width = 0) Or (FD.Depth = 0) Or (ID.Offset = 0) Then
  Begin
    Error(geBadData);
    Exit;
  End;
  FD.Bits := ID.Samples * ID.BitsPerSample;
  If (FD.Bits = 8) And Not ID.Palette Then
    For I := 0 To 255 Do                  { SetUp of Palette for Gray Scale Images }
    Begin
      FD.Palette[I].Red := Word(I);
      FD.Palette[I].Green := Word(I);
      FD.Palette[I].Blue := Word(I);
    End;
  Bytes := Word((LongInt(FD.Width) *
                 LongInt(ID.Samples) *
                 LongInt(ID.BitsPerSample) + 7) Shr 3);
  If Bytes > 7200 Then
  Begin
    Error(geFileTooLong);
    Exit;
  End;
  If ID.Count = 1 Then
  Begin
    FStream.Position := ID.Offset;
    If ID.Compression = TIFFCompLzwT Then
    Begin
      CurrByte := 0;
      BitsLeft := 0;
      BytesWrited := 0;
      InitializeTable;    { Initialize decoding paramaters }
      If Not ReadLZWData(Bytes) Then
      Begin
        Error(geBadCode);
        Exit;
      End;
    End
    Else
      For I := 0 To (FD.Depth - 1) Do
      Begin
        If Not ReadLine(Bytes) Then
        Begin
          Error(geBadData);
          Exit;
        End;
        InsertLine;
      End;
  End
  else
  For L := 0 To (ID.Count - 1) Do
  Begin
    FStream.Position := ID.Offset + (L * 4);
    FStream.Position := GetLong;
    If ID.Compression = TIFFCompLzwT Then
    Begin
      CurrByte := 0;
      BitsLeft := 0;
      BytesWrited := 0;
      InitializeTable;    { Initialize decoding paramaters }
      If Not ReadLZWData(Bytes) Then
      Begin
        Error(geBadCode);
        Exit;
      End;
    End
    Else
      For J := 0 To (ID.RowsPerStrip - 1) Do
      Begin
        If ((L * ID.RowsPerStrip) + J) >= FD.Depth Then Break;
        If Not ReadLine(Bytes) Then
        Begin
          Error(geBadData);
          Exit;
        End;
        InsertLine;
      End;
  End;
End;

Function TTifmap.ReadLine(Bytes: Integer): Boolean;
Var
  Ret: Boolean;
Begin
  Ret := True;
  If ID.Compression = TIFFCompNone Then
  Begin
    If FStream.Read(LineBuffer, Bytes) <> Bytes Then
    Begin
      Error(geUnExpectedEOF);
      Ret := False;
    End;
  End
  Else If ID.Compression = TIFFCompPack Then
    Ret := ReadPackLine(Bytes)
  Else
  Begin
    Error(geFormatUnsup);
    Ret := False;
  End;
  Result := Ret;
End;

Function TTifmap.ReadPackLine(Bytes: Integer): Boolean;
Var
  I, N: Integer;
  C: Byte;
  Ret: Boolean;
Begin
  C := 0;
  N := 0;
  Ret := True;
  Repeat
    If FStream.Read(C, 1) < 1 then
    Begin
      Error(geUnExpectedEOF);
      Ret := False;
      Break;
    End
    Else
    Begin
      If (C And TIFFDataMask) > 32 Then
      Begin
        If C <> TIFFDataMask Then
        Begin
          I := Integer((Not C) + 2);  { C = 8 }
          If FStream.Read(C, 1) < 1 then
          Begin
            Error(geUnExpectedEOF);
            Ret := False;
            Break;
          End;
          While I > 0 Do
          Begin
            LineBuffer[N] := C;
            Inc(N);
            Dec(I);
          End;
        End;
      End
      Else
      Begin
        I := Integer(C) + 1;
        While I > 0 Do
        Begin
          FStream.Read(LineBuffer[N], 1);
          Inc(N);
          Dec(I);
        End;
      End;
    End;
  Until N >= Bytes;
  Result := Ret;
End;

{ ********************************************************************* }
{ ************************** LZW  Decompression *********************** }
{ ********************************************************************* }

procedure TTifmap.InitializeTable;
Var
  I: Word;
Begin
  For I := 0 To MAXCODES Do LZWTable[I] := '';
  For I := 0 To 255 Do LZWTable[I] := Chr(I);
  ClearCode := 256;
  EndingCode := 257;
  FirstFreeSlot := 258;
  CurrCodeSize := LZWMINCODESIZE;
End;

procedure TTifmap.WriteString(StrOut: String; LineWidth: Integer);
Var
  OutLength, LastPos: Word;
  I: Word;
Begin
  OutLength := Length(StrOut);
  LastPos := BytesWrited + OutLength;
  If LastPos <= LineWidth Then
  Begin
    For I := 1 To OutLength Do
      LineBuffer[BytesWrited - 1 + I] := Ord(StrOut[I]);
    If LastPos = LineWidth Then
    Begin
      InsertLine;
      BytesWrited := 0;
    End
    Else BytesWrited := BytesWrited + OutLength;
  End
  Else
  Begin
    For I := 1 To (LineWidth - BytesWrited) Do
      LineBuffer[BytesWrited - 1 + I] := Ord(StrOut[I]);
    LastPos := (LineWidth - BytesWrited + 1);
    InsertLine;
    For I := LastPos To OutLength Do
      LineBuffer[I - LastPos] := Ord(StrOut[I]);
    BytesWrited := OutLength - LastPos + 1;
  End;
End;

Function TTifmap.AddStringToTable(NewEntry: String): Boolean;
Var
  Ret: Boolean;
Begin
  If FirstFreeSlot = (MAXCODES + 1) Then
    Ret := False
  Else
  Begin
    Ret := True;
    LZWTable[FirstFreeSlot] := NewEntry;
    Inc(FirstFreeSlot);
    If (FirstFreeSlot = 511) Or (FirstFreeSlot = 1023) Or (FirstFreeSlot = 2047) Then
      Inc(CurrCodeSize);
  End;
  Result := Ret;
End;

Function TTifmap.GetNextCode: Word;
Var
  Out, Aux: Word;
begin
  Out := 0;
  if BitsLeft = 0 then    	                      { any bits left in byte ? }
  begin
    FStream.Read(CurrByte, 1); 	                  { get a byte }
    BitsLeft := 8;                        	      { set bits left in the byte }
  end;
  If CurrCodeSize > BitsLeft Then     	          { need more bits ? }
  begin
    Out := CurrByte Shl (CurrCodeSize - BitsLeft);
    FStream.Read(CurrByte, 1);             	      { get another byte }
    Aux := CurrByte;
    If (CurrCodeSize - BitsLeft - 8) > 0 Then
      Aux := Aux Shl (CurrCodeSize - BitsLeft - 8)
    Else Aux := Aux shr (8 - (CurrCodeSize - BitsLeft));
    Out := Out or Aux;      	                    { add the remaining bits to the return value }
    BitsLeft := BitsLeft + 8;                     { set bit counter }
  end;
  If CurrCodeSize > BitsLeft Then      	          { need more bits ? }
  begin
    FStream.Read(CurrByte, 1);             	      { get another byte }
    Out := Out or (CurrByte shr (8 - (CurrCodeSize - BitsLeft)));
    BitsLeft := BitsLeft + 8;                     { set bit counter }
  end;
  BitsLeft := BitsLeft - CurrCodeSize;            { subtract the code size from bitsleft }
  Out := Out and CodeMask[CurrCodeSize];          { mask off the right number of bits }
  Result := Out;                                  { mask off the right number of bits }
End;

Function TTifmap.IsInTable(Code: Word): Boolean;
Begin
  Result := Code < FirstFreeSlot;
End;

Function TTifmap.StringFromCode(Code: Word): String;
Begin
  Result := LZWTable[Code];
End;

Function TTifmap.ReadLZWData(Bytes: Integer): Boolean;
Var
  Ret: Boolean;
  OutString: String;
Begin
  Ret := True;
  Code := GetNextCode;
  while (Code <> EndingCode) Do
  Begin
    if Code = ClearCode Then
    Begin
      InitializeTable();
      Code := GetNextCode;
      if Code = EndingCode Then break;
      WriteString(StringFromCode(Code), Bytes);
      OldCode := Code;
    End                               { end of ClearCode case }
    else
    Begin
      if IsInTable(Code) Then
      Begin
        WriteString(StringFromCode(Code), Bytes);
        OutString := StringFromCode(OldCode) +
                     StringFromCode(Code)[1];
        If Not AddStringToTable(OutString) Then
        Begin
          Ret := False;
          Break;
        End;
        OldCode := Code;
      End
      else
      Begin
        If OldCode >= FirstFreeSlot Then
          OldCode := FirstFreeSlot - 1;
        OutString := StringFromCode(OldCode) +
                     StringFromCode(OldCode)[1];
        WriteString(OutString, Bytes);
        If Not AddStringToTable(OutString) Then
        Begin
          Ret := False;
          Break;
        End;
        OldCode := Code;
      End;                            { end of not-ClearCode case }
    End;
    Code := GetNextCode;
  End;                                    { end of while loop }
  Result := Ret;
End;

{ ********************************************************************* }
{ ********************************************************************* }


Function TTifmap.GetWord: Word;
Begin
  FStream.Read(AuxWord, 2);
  If ID.NumberType = TIFFIntel Then
    Result := Word(AuxWord[1]) +
              Word(AuxWord[2]) Shl 8
  Else
    Result := Word(AuxWord[2]) +
              Word(AuxWord[1]) Shl 8;
End;

Function TTifmap.GetLong: LongInt;
Begin
  FStream.Read(AuxLong, 4);
  If ID.NumberType = TIFFIntel Then
    Result := LongInt(AuxLong[1]) +
              LongInt(AuxLong[2]) Shl 8 +
              LongInt(AuxLong[3]) Shl 16 +
              LongInt(AuxLong[4]) Shl 24
  Else
    Result := LongInt(AuxLong[4]) +
              LongInt(AuxLong[3]) Shl 8 +
              LongInt(AuxLong[2]) Shl 16 +
              LongInt(AuxLong[1]) Shl 24;
End;

Procedure TTifmap.DecodeTag;
Var
  Length, Offset, Pos: LongInt;
  Tag, TType, ForLimit, I, C: Word;
Begin
  Tag := GetWord;
  TType := GetWord;
  If TType = TIFFlong Then
  Begin
    Length := GetLong;
    Offset := GetLong;
  End
  Else
  Begin
    If ID.NumberType = TIFFIntel Then
    Begin
      Length := LongInt(GetWord);
      GetWord;
      Offset := LongInt(GetWord);
      GetWord;
    End
    Else
    Begin
      GetWord;
      Length := LongInt(GetWord);
      If Length > 2 Then
      Begin
        GetWord;
        Offset := LongInt(GetWord);
      End
      Else
      Begin
        Offset := LongInt(GetWord);
        GetWord;
      End;
    End;
  End;
  Case Tag Of
    ImageWidth          : FD.Width := Integer(Offset);
    ImageLength         : FD.Depth := Integer(Offset);
    RowsPerStrip        : If TType = TIFFlong Then
                            ID.RowsPerStrip := Word(Offset)
                          Else ID.RowsPerStrip := Word(Offset And TIFFLongMask);
    StripOffSets        : Begin
                            If TType = TIFFlong Then
                              ID.Offset :=Offset
                            Else ID.Offset := Offset And TIFFLongMask;
                            ID.Count := Word(Length);
                          End;
    StripByteCounts     : If TType = TIFFlong Then
                            ID.ByteCount := Offset
                          Else ID.ByteCount := Offset And TIFFLongMask;
    SamplesPerPixel     : ID.Samples := Word(Offset);
    BitsPerSample       : If Length > 1 Then
                          Begin
                            Pos := FStream.Position;
                            FStream.Position := Offset;
                            ID.BitsPerSample := GetWord;
                            FStream.Position := Pos;
                          End
                          Else ID.BitsPerSample := Word(Offset);
    Compression         : ID.Compression := Word(Offset);
    PredictorType       : ID.Predictor := Word(Offset);
    PlanarConfiguration : ID.PlanarConfig := Word(Offset);
    PhotometricInterp   : ID.Photomet := Word(Offset);
    ColorMap            : Begin
                            Pos := FStream.Position;
                            FStream.Position := Offset;
                            ForLimit := (1 Shl ID.BitsPerSample) - 1;
                            If ForLimit > 255 Then ForLimit := 255;
                            For I := 0 To ForLimit Do
                            Begin
                              C := GetWord;
                              If ((C And TIFFHiColMask) <> 0) And ((C And TIFFLoColMask) = 0) Then
                                C := C Shr 8;
                              FD.Palette[I].Red := C;
                            End;
                            For I := 0 To ForLimit Do
                            Begin
                              C := GetWord;
                              If ((C And TIFFHiColMask) <> 0) And ((C And TIFFLoColMask) = 0) Then
                                C := C Shr 8;
                              FD.Palette[I].Green := C;
                            End;
                            For I := 0 To ForLimit Do
                            Begin
                              C := GetWord;
                              If ((C And TIFFHiColMask) <> 0) And ((C And TIFFLoColMask) = 0) Then
                                C := C Shr 8;
                              FD.Palette[I].Blue := C;
                            End;
                            FStream.Position := Pos;
                            ID.Palette := True;
                          End;
  End;
End;

Procedure TTifmap.SetDefaults;
Begin
  FD.Width := 0;
  FD.Depth := 0;
  FD.Bits := 0;
  ID.PlanarConfig := 1;
  ID.Samples := 1;
  ID.Compression := 1;
  ID.Offset := 0;
  ID.Photomet := 0;
  ID.Palette := False;
End;

procedure TTifmap.InsertLine;
Var
  K: Integer;
  Col, Aux: Word;
Begin
  If ID.Predictor = 2 Then
    For K := 1 To (FD.Width - 1) Do
      LineBuffer[K] := LineBuffer[K] + LineBuffer[K-1];

  Aux := (FD.Width Div 8 + 10);
  If (FD.Bits = 1) And (ID.Photomet = 0) Then
    For  K := 0 to Aux Do LineBuffer[K] := not LineBuffer[K];

  If FD.Bits > 8 Then
    For K := 0 To (FD.Width - 1) Do
    Begin
      Col := LineBuffer[K * RGB_SIZE + RGB_RED];
      LineBuffer[K * RGB_SIZE + RGB_RED] := LineBuffer[K * RGB_SIZE + RGB_BLUE];
      LineBuffer[K * RGB_SIZE + RGB_BLUE] := Col;
    End;
  CreateLine;
End;

procedure TTifmap.CreateLine;
var
  p: PBmLine;
begin
  {if want percent up}
  DPEMain.ProgressBar.Position := trunc(100*(CurrentY/FD.Depth));
  {Create a new bmp line}
  New(p);                       {Fill in the data}
  p^.LineData := LineBuffer;
  p^.LineNo := CurrentY;        {Add it to the list of lines}
  ImageLines.Add(p);            {Prepare for the next line}
  Inc(CurrentY);
end;

procedure TTifmap.CreateBitHeader;
{ This routine takes the values from the TIF image
  descriptor and fills in the appropriate values in the
  bit map header struct. }
begin
  with BmHeader do
  begin
    biSize           := Sizeof(TBitmapInfoHeader);
    biWidth          := FD.Width;
    biHeight         := FD.Depth;
    biPlanes         := 1;            {Arcane and rarely used}
    biBitCount       := FD.Bits;      {Number of bit per pixel}
    biCompression    := BI_RGB;       {Sorry Did not implement compression in this version}
    biSizeImage      := 0;            {Valid since we are not compressing the image}
    biXPelsPerMeter  :=143;           {Rarely used very arcane field}
    biYPelsPerMeter  :=143;           {Same}
    biClrUsed        := 0;            {all colors are used}
    biClrImportant   := 0;            {all colors are important}
  end;
end;

procedure TTifmap.SaveTifToStream(Stream: TStream);
var
  BitFile: TBitmapFileHeader;
  i: integer;
  ch: char;
  p: PBmLine;
  PalSize, LineWidth, x: integer;
begin
  If FD.Bits = 1 Then LineWidth := (FD.Width + 7) Div 8
  Else If FD.Bits = 4 Then LineWidth := ((FD.Width + 7) Div 8) Shl 2
  Else If FD.Bits = 8 Then LineWidth := FD.Width
  Else LineWidth := FD.Width * RGB_SIZE;
  PalSize := (4 * Round(Power(2, FD.Bits)));
  If FD.Bits > 8 Then PalSize := 0;
  with BitFile do
  begin
    bfSize := PalSize +
              Sizeof(TBitmapFileHeader) +  {Color map info}
	            Sizeof(TBitmapInfoHeader) +
              (((FD.Depth * LineWidth) * FD.Bits) Div 8);
    bfReserved1 := 0; {not currently used}
    bfReserved2 := 0; {not currently used}
    bfOffBits := PalSize +
                 Sizeof(TBitmapFileHeader)+
                 Sizeof(TBitmapInfoHeader);
  end;
  with Stream do
  begin                                     {Write the file header}
    Position := 0;
    ch := 'B';
    Write(ch, 1);
    ch := 'M';
    Write(ch, 1);
    Write(BitFile.bfSize,sizeof(BitFile.bfSize));
    Write(BitFile.bfReserved1,sizeof(BitFile.bfReserved1));
    Write(BitFile.bfReserved2,sizeof(BitFile.bfReserved2));
    Write(BitFile.bfOffBits,sizeof(BitFile.bfOffBits));
    Write(BmHeader,sizeof(BmHeader));       {Write the bitmap image header info}
    If FD.Bits = 1 Then
      Write(#0#0#0#0#255#255#255#0, 8)
    Else If FD.Bits = 4 Then
      for i := 0 to 15 do                     {Write the BGR palete inforamtion to this file}
      begin
        Write(FD.Palette[i].Blue,1);
        Write(FD.Palette[i].Green,1);
        Write(FD.Palette[i].Red,1);
        Write(ch,1); {Bogus palete entry required by windows}
      end
    Else If FD.Bits = 8 Then
      for i := 0 to 255 do                     {Write the BGR palete inforamtion to this file}
      begin
        Write(FD.Palette[i].Blue,1);
        Write(FD.Palette[i].Green,1);
        Write(FD.Palette[i].Red,1);
        Write(ch,1); {Bogus palete entry required by windows}
      end;
    ch := chr(0);
    for i := (ImageLines.Count - 1) downto 0  do
    begin
      p := ImageLines.Items[i];
      x := LineWidth;
      Write(p^.LineData, x);
      while (x and 3) <> 0 do { Pad up to 4-byte boundary with zeroes }
      begin
        Inc(x);
        Write(ch, 1);
      end;
    end;
    Position := 0; { reset mewmory stream}
    for i := (ImageLines.Count - 1) downto 0  do
    begin
      p := ImageLines.Items[i];
      Dispose(P);
    End;
  end;
end;
initialization
  { register the TTifBitmap as a new graphic file format
    now all the TPicture storage stuff can access our new
    TIFF graphic format !
  }
  TPicture.RegisterFileFormat('tif','TIFF-Format', TTifmap);
end.
