unit Dmgrpcx;

Interface

uses Windows;

{==============================================	exported PCX-Functions}
function LoadThePCX: boolean;

               Implementation

uses DMGBasic, SysUtils;

{----------------------------------------------	PCX-Header}
type
pPCXHeader	= ^tPCXHeader;
tPCXHeader	= packed record
		  ID		: byte;
                  Version	: byte;
                  Coding	: byte;
                  BitsPixel	: byte;
                  xMin		: word;
                  yMin		: word;
                  xMax		: word;
                  yMax		: word;
                  xDPI		: word;
                  yDPI		: word;
                  Colors	: array[0..15] of TRGBColor;
                  Reserved1	: byte;
                  Planes	: byte;
                  WidthBytes	: word;
                  ColorMode	: word;
                  Reserved2	: array[0..57] of byte;
end {record tPCXHeader};

{----------------------------------------------	GetHeader}
function GetHeader(PCXHeader: pPCXHeader): boolean;
var Palette16: tLogPalette;
    DC: hDC;
    i: integer;
    PaletteKennung: byte;
    rRead : longint; // number of bytes actually transfered to buffer (Stream.Read)
begin
  with DMGS
  do begin
     Result := false;
     rRead := Stream.Read(PCXHeader^, sizeof(tPCXHeader));
     if (rRead <> sizeof(tPCXHeader))
     then begin
          mg_LastError := MGERR_READERROR;
          exit;
     end;
     if (PCXHeader^.ID <> 10)
     then begin
          mg_LastError := MGERR_WRONGFORM;
          exit;
     end {bad Header};
     with PCXHeader^ do BPP := BitsPixel * Planes;
     ColorD := (1 SHL BPP) AND $1ff;
     if (PCXHeader^.Version = 3)
     then begin
          DC := CreateDC('Display', nil, nil, nil);
          GetSystemPaletteEntries(DC, 0, ColorD, Palette16.palPalEntry);
          DeleteDC(DC);
          for i := 0 to ColorD - 1
          do with Palette16.palPalEntry[i]
          do begin
             Palette[i, Red]   := peRed;
             Palette[i, Green] := peGreen;
             Palette[i, Blue]  := peBlue;
          end {for i := 0 to ColorD - 1};
     end {PCX-Format Version 3}
     else if (BPP = 8)
     then begin
          Stream.Seek(-(sizeof(tRawPalette) + 1), 2);
          rRead := Stream.Read(PaletteKennung, sizeof(PaletteKennung));
          if (rRead <> sizeof(PaletteKennung))
          then begin
               mg_LastError := MGERR_READERROR;
               rError := true;
               exit;
          end;
          if (PaletteKennung <> $c)
          then begin
               mg_LastError := MGERR_WRONGFORM;
               exit;
          end {bad Pallete};
          rRead := Stream.Read(Palette, sizeof(tRawPalette));
          if (rRead <> sizeof(tRawPalette))
          then begin
               mg_LastError := MGERR_READERROR;
               rError := true;
               exit;
          end;
     end {PCX-Format 8bpp-Palette}
     else for i := 0 to ColorD - 1
          do with PCXHeader^
          do begin
             Palette[i, Red]   := Colors[i, Red];
             Palette[i, Green] := Colors[i, Green];
             Palette[i, Blue]  := Colors[i, Blue];
     end {Palette from header};
     rOffset :=  sizeof(tPCXHeader);
     Stream.Seek(sizeof(tPCXHeader), 0);
  end {with DMGS};
  Result := true;
end {function GetHeader};
{----------------------------------------------	Expand}
function Expand(Coding: byte): boolean;
var Zaehler, i: byte;
    ImageByte : byte;
begin
  with DMGS
  do begin
     if (Coding = 1)
     then repeat
          ImageByte := GetStreamByte;
          if (ImageByte AND $c0 = $c0)
          then begin
               Zaehler   := ImageByte AND $3f;
               ImageByte := GetStreamByte;
               for i := 1 to Zaehler do SetExpandByte(ImageByte);
          end else SetExpandByte(ImageByte);
     until rError OR wError OR bAbort
     else repeat
          ImageByte := GetStreamByte;
          SetExpandByte(ImageByte);
     until rError OR wError OR bAbort;
     SetExpandByte(Flush_Buffer);
     if bAbort
     then Result := false
     else Result := true;
  end {with DMGS};
end {function Expand};
{----------------------------------------------	Repack1or8}
procedure Repack1or8;
var pDIBv, pPCXv: pointer;
    DIBoff: longint;
    y, cHei: integer;
    Percent: longint;
begin
  with DMGS
  do begin
     wOffset := 0;
     DIBoff := cDIB + cBMI;
     cHei   := pBMI^.bmiHeader.biHeight;
     PercentFactor := 100 / cHei;
     for y := 1 to cHei
     do begin
        pPCXv := pWrite + wOffset;
        inc(wOffset, wLineLength);
        dec(DIBoff, cDibLine);
        pDIBv := pChar(pBMI) + DIBoff;
        Move(pPCXv^, pDIBv^, wLineLength);
         if (MulTa <> nil)
        then begin
             Percent   := round(y * PercentFactor);
             bAbort := TMultiTasking(MulTa)(Percent);
             if bAbort then exit;
        end {MultiTasking};
     end;
  end {with DMGS};
end {procedure Repack1or8};
{----------------------------------------------	Repack2or4}
procedure Repack2or4;
const
qMask          = $80;
zmask1hb        = $20;
zmask2hb        = $02;
var
pDIBv, pPCXv    : ^byte;
p1, p2, p3, p4  : pByteArray;
DIBoff          : longint;
PCXBPL          : longint;  // bits per line
cqPix, czPix    : word;
cHei, cWid      : word;
x, y            : integer;
cqmask, czmask  : byte;
Percent         : longint;
begin
  with DMGS
  do begin
     p1 := nil;
     p2 := nil;
     p3 := nil;
     p4 := nil;
     wOffset := 0;
     with pBMI^.bmiHeader
     do begin
        cHei   := biHeight;
        cWid   := biWidth - 1;
     end {with pBMI^.bmiHeader};
     PCXBPL := wLineLength * BPP;
     DIBoff   := cBMI + cDIB;
     case BPP of
          2: begin
               p1 := pByteArray(pWriteBuf);
               p2 := pByteArray(pChar(p1) + wLineLength);
             end {case 2};
          4: begin
               p1 := pByteArray(pWriteBuf);
               p2 := pByteArray(pChar(p1) + wLineLength);
               p3 := pByteArray(pChar(p2) + wLineLength);
               p4 := pByteArray(pChar(p3) + wLineLength);
             end {case 4};
     end {case BPP};
     PercentFactor := 100 / cHei;
     dec(cHei);
     for y := 0 to cHei
     do begin
        pPCXv := pointer(pWrite + wOffset);
        inc(wOffset, PCXBPL);
        Move(pPCXv^, pWriteBuf^, PCXBPL);
        fillchar(pReadBuf^, cDIBline, #0);
        cqmask := qMask;
        case BPP of
             2: czmask := zmask1hb;
             4: czmask := qMask;
             else czmask := 0;
        end {case BPP};
        cqPix  := 0;
        czPix  := 0;
        for x := 0 to cWid
        do begin
           case BPP of
                2: begin
                     if (p2^[cqPix] AND cqmask <> 0)
                     then pReadBuf^[czPix] := pReadBuf^[czPix] OR czmask;
                     czmask := czmask SHR 1;
                     if (p1^[cqPix] AND cqmask <> 0)
                     then pReadBuf^[czPix] := pReadBuf^[czPix] OR czmask;
                     if (czmask = $10)
                     then czmask := zmask2hb
                     else begin
                          czmask := zmask1hb;
                          inc(czPix);
                     end ;
                   end {case 2};
                4: begin
                     if (p4^[cqPix] AND cqmask <> 0)
                     then pReadBuf^[czPix] := pReadBuf^[czPix] OR czmask;
                     czmask := czmask SHR 1;
                     if (p3^[cqPix] AND cqmask <> 0)
                     then pReadBuf^[czPix] := pReadBuf^[czPix] OR czmask;
                     czmask := czmask SHR 1;
                     if (p2^[cqPix] AND cqmask <> 0)
                     then pReadBuf^[czPix] := pReadBuf^[czPix] OR czmask;
                     czmask := czmask SHR 1;
                     if (p1^[cqPix] AND cqmask <> 0)
                     then pReadBuf^[czPix] := pReadBuf^[czPix] OR czmask;
                     czmask := czmask SHR 1;
                     if (czmask = 0)
                     then begin
                          czmask := qMask;
                          inc(czPix);
                     end;
                   end {case 4};

           end {case BPP};
           cqmask := cqmask SHR 1;
           if (cqmask = 0)
           then begin
                cqmask := qMask;
                inc(cqPix);
           end;
        end;
        dec(DIBoff, cDIBline);
        pDIBv := pointer(pChar(pBMI) + DIBoff);
        Move(pReadBuf^, pDIBv^, cDIBline);
        if (MulTa <> nil)
        then begin
             Percent:= round(y * PercentFactor);
             bAbort := TMultiTasking(MulTa)(Percent);
             if bAbort then exit;
        end {MultiTasking};
     end;
  end {with DMGS};
end {procedure Repack2or4};
{----------------------------------------------	Repack24}
procedure Repack24;
var pR, pG, pB: pChar;
    pDIBv: pointer;
    pPCXv: pointer;
    DIBoff: longint;
    x, y: word;
    cHei, cWid: word;
    PCXRow: longint;
    Percent: longint;
begin
  with DMGS
  do begin
     wOffset  := 0;
     PCXRow := wlineLength * 3;
     DIBoff   := cDIB + cBMI;
     cHei     := pBMI^.bmiHeader.biHeight;
     cWid     := pBMI^.bmiHeader.biWidth - 1;
     PercentFactor := 100 / cHei;
     pR := pChar(pWriteBuf);
     pG := pR + wLineLength;
     pB := pG + wLineLength;
     for y := 1 to cHei
     do begin
        pPCXv := pWrite + wOffset;
        Move(pPCXv^, pWriteBuf^, PCXRow);
        inc(wOffset, PCXRow);
        for x := 0 to cWid
        do begin
           pBGRArr(pReadBuf)^[x, Bc]  := byte(pB[x]);
           pBGRArr(pReadBuf)^[x, Gc] := byte(pG[x]);
           pBGRArr(pReadBuf)^[x, Rc]   := byte(pR[x]);
        end;
        dec(DIBoff, cDIBline);
        pDIBv := pChar(pBMI) + DIBoff;
        Move(pReadBuf^, pDIBv^, cDIBline);
        if (MulTa <> nil)
        then begin
             Percent := round(y * PercentFactor);
             bAbort  := TMultiTasking(MulTa)(Percent);
             if bAbort then exit;
        end {MultiTasking};
     end;
  end {with DMGS do with DMGS};
end {procedure Repack24};

{==============================================	Exported PCX-Functions}
function LoadThePCX: boolean;
var cWid, cHei: word;
    PCXHeader: tPCXHeader;
begin
  Result := false;
  if not(GetHeader(@PCXHeader))
  then begin
       ExitConvProc(mg_LastError);
       exit;
  end;
   with PCXHeader, DMGS
  do begin
     cWid     := longint(xMax - xMin + 1);
     cHei     := longint(yMax - yMin + 1);
     BPP      := BitsPixel * Planes;
     cDIB     := mg_GetDIBSize(cWid, cHei, BPP);
     cDIBLine := cDIB DIV cHei;
     cBMI     := sizeof(TBitmapInfoHeader);
     if (BPP < 9) then cBMI := cBMI + ColorD * sizeof(TRGBQuad);
     wLineLength := longint(WidthBytes);
     wSize := wLineLength * longint(cHei) * longint(Planes);
  end {with PCXHeader do with DMGS do};
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
  if not(Expand(PCXHeader.Coding))
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
     case BPP of
          1, 8 : Repack1or8;
          2, 4 : Repack2or4;
          24   : Repack24;
     end {case BPP};
  end {with DMGS};
  if DMGS.bAbort
  then begin
       ExitConvProc(MGERR_CANCEL);
       exit;
  end {user abort};
  FreeExpandedMem;
  ExitConvProc(0);
  Result := mg_LastError = 0;
end {function LoadThePCX};

end.
