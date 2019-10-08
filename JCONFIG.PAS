Unit Jconfig;

interface

{from: jconfig.bcc --- jconfig.h for Borland C (Turbo C) on MS-DOS or OS/2.}
{ see jconfig.doc for explanations }

{$ifdef __MSDOS__}
{$define USE_MSDOS_MEMMGR}      { Define this if you use jmemdos.c }
const
  MAX_ALLOC_CHUNK = 65520L;     { Maximum request to malloc() }
{$define USE_FMEM}              { Borland has _fmemcpy() and _fmemset() }
{$endif} { JPEG_CJPEG_DJPEG }

implementation

end.