unit Dmgrtga;

Interface

uses Windows;

function LoadTheTGA: boolean;

Implementation

uses DMGBasic, SysUtils;


{----------------------------------------------	TGA-Header}
type
pTGAHeader	= ^tTGAHeader;
tTGAHeader	= packed record
		  IDlen		: byte;
                  CMapType	: byte;
                  SubType	: byte;
                  B3            : word;
                  MapLen	: word;
                  MapEntrySize	: byte;
                  B8            : byte;
                  B9	        : byte;
                  B10           : byte;
                  B11	        : byte;
                  Width		: word;
                  Height	: word;
                  Flags1	: byte;
                  Flags2	: byte;
end {record tTGAHeader};
{----------------------------------------------	constants for 16bpp-Images}
const
c5to8bits       : array[0..31] of Byte
                = (  0,   8,  16,  24,  32,  41,  49,  57,
                    65,  74,  82,  90,  98, 106, 115, 123,
                   131, 139, 148, 156, 164, 172, 180, 189,
                   197, 205, 213, 222, 230, 238, 246, 255);


{----------------------------------------------	GetHeader}
function GetHeader(TGAHeader: pTGAHeader): boolean;
var i: integer;
    PixelSize: byte;
    InterlaceType: byte;
begin
  Result := false;
  with DMGS
  do begin
     rGelesen := Stream.Read(TGAHeader^, sizeof(tTGAHeader));
     if (rGelesen <> sizeof(tTGAHeader))
     then begin
          mg_LastError := MGERR_READERROR;
          rError := true;
          exit;
     end;
     rOffset :=  sizeof(tTGAHeader);
     with TGAHeader^
     do begin
        if (Flags1 = 15) then Flags1 := 16;
        BPP           := Flags1 AND 7;
        PixelSize     := Flags1 SHR 3;
        InterlaceType := Flags2 SHR 6;
        {------ Header testing}
        if (MapLen > 0)
        OR (PixelSize < 2) OR (PixelSize > 4)
        OR (BPP <> 0)
        OR (InterlaceType <> 0)
        OR (SubType <> 2) AND (SubType <> 10)
        then begin
             mg_LastError := MGERR_WRONGFORM;
             exit;
        end;
        for i := 0 to IDlen - 1 do GetStreamByte;
     end {with TGAHeader^};
     if rError
     then mg_LastError := MGERR_READERROR
     else Result := true;
  end {with DMGS};
end {function GetHeader};
{----------------------------------------------	Expand}
function Expand(PixelSize: byte; Coding: boolean): boolean;
var BlkCnt: smallint;
    RleCnt: smallint;
    i: integer;
    j: byte;
    ImagePixel: array[1..4] of byte;
{----------------------------------------------	Subprocedure ReadPixel}
procedure ReadPixel;
var i: integer;
begin
  for i := 1 to PixelSize do ImagePixel[i] := GetStreamByte;
end {procedure ReadPixel};
{----------------------------------------------	Subprocedure ReadRLEPixel}
procedure ReadRLEPixel;
var i: integer;
    ImageByte: byte;
begin
  if (RleCnt > 0)
  then begin
       dec(RleCnt);
       exit;
  end {gepackter PixelBlock};
  dec(BlkCnt);
  if (BlkCnt < 0)
  then begin
       ImageByte := GetStreamByte;
       if (ImageByte AND $80 <> 0)
       then begin
            RleCnt := smallint(ImageByte AND $7f);
            BlkCnt := 0;
       end {neuer gepackter Block}
       else begin
            BlkCnt := smallint(ImageByte AND $7f);
       end {neuer ungepackter Block};
  end {if (BlkCnt < 0)};
  for i := 1 to PixelSize do ImagePixel[i] := GetStreamByte;
end {procedure ReadRLEPixel};
{----------------------------------------------	MainFunction Expand}
begin
  with DMGS
  do begin
     Result := false;
     BlkCnt := 0;
     RleCnt := 0;
     case PixelSize of

          {---- 16bpp}
          2   :
          repeat
            if (Coding) then ReadRlePixel else ReadPixel;
            i := ImagePixel[1] + (ImagePixel[2] SHL 8);
            j := c5to8bits[i AND $1f];
            SetExpandByte(j);
            i := i SHR 5;
            j := c5to8bits[i AND $1f];
            SetExpandByte(j);
            i := i SHR 5;
            j := c5to8bits[i AND $1f];
            SetExpandByte(j);
          until rError OR wError OR bAbort;

          {---- 24/32bpp}
          3, 4:
          repeat
            if (Coding) then ReadRlePixel else ReadPixel;
            for i := 1 to 3 do SetExpandByte(ImagePixel[i]);
          until rError OR wError OR bAbort;

     end {case};
     SetExpandByte(Flush_Buffer);
     if bAbort
     then mg_LastError := MGERR_CANCEL
     else Result := true;
  end {with DMGS};
end {function Expand};
{----------------------------------------------	Repack24}
procedure Repack24(IsBottomUp: boolean);
var pDIBv: pointer;
    pTGAv: pointer;
    DIBoff: longint;
    y, cHei: integer;
    Proz: longint;
begin
  with DMGS
  do begin
     wOffset := 0;
     if IsBottomUp
     then DIBoff := cBMI - cDIBline
     else DIBoff := cDIB + cBMI;
     cHei := pBMI^.bmiHeader.biHeight;
     ProzFaktor := 100 / cHei;
     for y := 1 to cHei
     do begin
        pTGAv := pWrite + wOffset;
        inc(wOffset, wLineLength);
        if IsBottomUp then inc(DIBoff, cDIBline) else dec(DIBoff, cDIBline);
        pDIBv := pChar(pBMI) + DIBoff;
        Move(pTGAv^, pDIBv^, wLineLength);
        if (MulTa <> nil)
        then begin
             Proz   := round(y * ProzFaktor);
             bAbort := TMultiTasking(MulTa)(DMG_Repack, Proz);
             if bAbort then exit;
        end;
     end;
  end {with DMGS};
end {procedure Repack24};

{==============================================	Exported TGA-Functions}
function LoadTheTGA: boolean;
var cWid, cHei: word;
    TGAHeader: tTGAHeader;
    PixelSize: byte;
    IsBottomUp: boolean;
    Coding: boolean;
begin
  Result := false;
  if not(GetPictureStream)
  then begin
       ExitConvProc(mg_LastError);
       exit;
  end {Error while reading image};
  if not(GetHeader(@TGAHeader))
  then begin
       ExitConvProc(mg_LastError);
       exit;
  end;
  with TGAHeader, DMGS
  do begin
     cWid        := longint(Width);
     cHei        := longint(Height);
     BPP         := 24;
     ColorD      := 1 SHL BPP AND $1ff;
     cDIB        := mg_GetDIBSize(cWid, cHei, BPP);
     cDIBLine    := cDIB DIV cHei;
     cBMI        := sizeof(TBitmapInfoHeader);
     if (BPP < 9) then cBMI := cBMI + ColorD * sizeof(TRGBQuad);
     PixelSize   := Flags1 SHR 3;
     IsBottomUp  := (Flags2 AND $20 = 0);
     wLineLength := longint(Width) * 3;
     wSize       := wLineLength * longint(cHei);
     if (SubType > 8)
     then begin
          Coding := true;
          dec(SubType, 8);
     end
     else Coding := false;
  end {with TGAHeader do with DMGS do};
  DMGS.rBufLen := DMGS.cDIBLine;
  DMGS.wBufLen := DMGS.wLineLength * 3;
  if not(GetBufferMem)
  then begin
       ExitConvProc(mg_LastError);
       exit;
  end;
  if not(GetExpandedMem)
  then begin
       ExitConvProc(mg_LastError);
       exit;
  end;
  if not(Expand(PixelSize, Coding))
  then begin
       ExitConvProc(mg_LastError);
       exit;
  end;
  FreePictureStream;
  with DMGS
  do begin
     pBMI := mg_SetupDIB(@Palette, cWid, cHei, cDIB, cBMI, BPP);
     if (pBMI = nil)
     then begin
          ExitConvProc(MGERR_NOMEMORY);
          exit;
     end;
  end {with DMGS};
  Repack24(IsBottomUp);
  if DMGS.bAbort
  then begin
       ExitConvProc(MGERR_CANCEL);
       exit;
  end;
  FreeExpandedMem;
  ExitConvProc(0);
  Result := mg_LastError = 0;
end {function LoadTheTGA};

end.
