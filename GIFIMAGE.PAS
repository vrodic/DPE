unit GIFImage;

(*******************************************************************************
********************************************************************************
**                                                                            **
** Project:	GIF Graphics Object                                           **
** Module:	gifimage                                                      **
** Description:	TGraphic implementation of the GIF89a graphics format.        **
** Version:	2.0                                                           **
** Release:	3                                                             **
** Date:	26-APR-1998                                                   **
** Target:	Win32, Delphi 2 & 3, C++ Builder 3                            **
** Author(s):	anme: Anders Melander, anders@melander.dk                     **
**		fila: Filip Larsen, filip@post4.tele.dk                       **
**		rps: Reinier Sterkenburg                                      **
** Copyright	(c) 1997,98 by Anders Melander                                **
** Formatting:	2 space indent, 8 space tabs, 80 columns.                     **
**                                                                            **
********************************************************************************
********************************************************************************

This software is copyrighted as noted above.  It may be freely copied, modified,
and redistributed, provided that the copyright notice(s) is preserved on all
copies.

There is no warranty or other guarantee of fitness for this software, it is
provided solely "as is".  Bug reports or fixes may be sent to the author, who
may or may not act on them as he desires.

You may not include this software in a program or other software product without
supplying the source, or without informing the end-user that the source is
available for no extra charge.

If you modify this software, you should include a notice in the "Revision
history" section giving the name of the person performing the modification, the
date of modification, and the reason for such modification.

--------------------------------------------------------------------------------
Here's some additional copyrights for you:

Portions copyright (c) Borland International.

The Graphics Interchange Format(c) is the Copyright property of CompuServe
Incorporated.  GIF(sm) is a Service Mark property of CompuServe Incorporated.

  +-------------------------------------------------------------------+
  | Copyright 1993, David Koblas (koblas@netcom.com)                  |
  |                                                                   |
  | Permission to use, copy, modify, and to distribute this software  |
  | and its documentation for any purpose is hereby granted without   |
  | fee, provided that the above copyright notice appear in all       |
  | copies and that both that copyright notice and this permission    |
  | notice appear in supporting documentation.  There is no           |
  | representations about the suitability of this software for        |
  | any purpose.  this software is provided "as is" without express   |
  | or implied warranty.                                              |
  |                                                                   |
  +-------------------------------------------------------------------+

Copyright (C) 1989 by Jef Poskanzer.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted, provided that
the above copyright notice appear in all copies and that both that copyright
notice and this permission notice appear in supporting documentation.  This
software is provided "as is" without express or implied warranty.

COPYRIGHT 1994,1995 BY THE QUEST CENTER AT COLD SPRING HARBOR LABS.
Permission granted for unlimited use, provided that Thomas Boutell and the Quest
Center at Cold Spring Harbor Labs are given credit for the library in the
user-visible documentation of your software. If you modify gd, we ask that you
share the modifications with us so they can be added to the distribution.
See gd.html for details.

--------------------------------------------------------------------------------
Revision history:

0001	120797	anme	- Modified GifImage (see credits) to derive from TGraphic.
			- Added TPicture registration.
			- Added support for stream based (TStream) instead of
			  file based I/O.

0002	150797	anme	- Zapped version 0.01 - it was just too damned slow.
			- Version 0.02 is a completely new design rewritten from
			  scratch from the gif89a specification.
	200797	anme	- Implemented GIF compressor (see credits).
			  10-20 times faster that version 0.01 on some images.
		fila	- Improved hash key generator - Average hit ratio is now
			  about 5:1 compared to 2:1 for original algorithm.
	220797	anme	- Optimized compressor hash functions - Average hit
			  ratio is now about 15:1.
	270797	anme	- Implemented GIF decompressor (see credits).
			  Fast'n dirty port of "C" version. Will need to be
			  optimized and cleaned up at some point.

0100	300797	anme	- Implemented TGIFPainter for drawing animated GIFs.
			- Implemented TGIFAppExtNSLoop to support Netscape loop
			  extension.
			- Implemented TGIFUnknownAppExtension to support unknown
			  application extensions.

0101	030897	anme	- Added TGIFPainter support for transparent GIFs
			  Only supported for D3 in this version.
	080897	anme	- Added TGIFPainter support for Disposal.
	110897	anme	- Fixed TGIFPainter thread termination on TGIFImage
			  destruction.
	160897	anme	- Fixed bug in TGIFSubImage.Assign(TGIFSubImage).
			- Added TPicture registration.
			- Completed implementation of TGraphic functions.
	230897	anme	- Improved handling of Paint & Draw options.
			- Improved handling of threaded/animated Draw().
	271097	anme	- Added handling of non-compliant zero-padding between
			  image blocks.
			- sDecodeTooFewBits is now treated as a warning condition
			  instead of an error.
			- Added validation of Color Index for TGIFHeader
			  BackgroundColorIndex and TGIFGraphicControlExtension
			  TransparentColorIndex.
			  Invalid index triggers a sBadColorIndex warning and
			  sets the index to 0.
			- Changed TGIFImage.Paint to draw in main thread if
			  there is only one sub image.
	221197	anme	- Fixed bug in TGIFAppExtNSLoop. Signature was not
			  written to GIF file.
			- Changed TGIFImage.Add() to return index of new item.
			- Added ability to TGIFColorMap.Optimize to remove
			  unused palette entries after bitmap import.
			- Added check for empty colormap in ExportPalette.
			- Added Restart to TGIFPainter for improved performance.
	291197	anme	- Fixed Access Violation when streaming an empty
			  TGIFSubImage by improving TGIFSubImage.GetEmpty.
			- Added Painters property to TGIFImage to make it
			  possible to determine if a given painter is still
			  alive.
			- Fixed reentrancy bug in TGIFPainter.Execute that would
			  corrupt the destination canvas handle under some
			  obscure circumstances.
	061297	anme	- Improved handling of Paint executing in main thread.
			- Released as beta 0101a.

0102	201297	anme    - Added Warning method to TGIFItem and TColorMap to
			  improve centralized error handling.
			  This was done to handle invalid Background color index
			  values in GIFs produced by Microsoft's free GIF
			  animator tool. The problem was brought to my attention
			  by Brad Choate - Thanks.
			- Removed unused gwsOK and gwOK constants.
			- Changed TGIFWarning to procedure of object.
			- TGIFImage.Bitmap is now volatile but still public...
			- Changed TGIFImage.Draw and Paint completely to draw
			  indirectly via a TBitmap.
			  This should eliminate the goAsync problem for Draw.
			- Added TGIFImage.StopDraw to stop async Draw.
			- Removed potential leak in TGIFPainter.Execute.
			  If an exception was raised during the extension
			  preprocessing, the frame buffers would not be freed.
			- TGIFImage.Assign can now assign from any TPicture that
			  can assign to a TBitmap (TPicture->TBitmap->TGIFimage)
	271297	anme	- Added goDirectDraw option.
			  goDirectDraw will cause TGIFImage.Draw() to Paint()
			  directly on the destination canvas instead of via the
			  bitmap buffer.
			- Added TGIFImage.ThreadPriority property.
			- Added TGIFImage.DrawBackgroundColor property.
			- Added TGIFSubImage.StretchDraw().
			- Added TGIFSubImage.ScaleRect().
	110198	anme	- Misc mods based on feedback from Reinier Sterkenburg.
			  <r.p.sterkenburg@dataweb.nl>:
			  - Added TGIFList.Image property in order to be able to
			    report warnings in LoadFromStream.
			  - TGIFExtensionList.LoadFromStream now handles missing
			    extension introducers.
			    Instead of generating an exception, a warning event
			    is now produced.
			  - TGIFSubImage.Decompress now handles premature end of
			    file.
			    Instead of generating an exception, a warning event
			    is now produced.
	150198	anme	- Added TGIFList.Warning to enable graceful recovery
			  from "bad block type" in TGIFImageList.LoadFromStream.
			- Fixed disposal problem in TGIFPainter.DoPaintFrame.
			- Added TGIFPainter.DoPaint for non-buffered paint.
	220198	anme	- Added check for no color tables defined.
			  Causes a sNoColorTable exception.
			- Rewritten palette management.
			- Temporarily added DoTransparent parameter to
			  TGIFSubImage.Draw and StretchDraw until
			  TBitmap.Transparent problem is fixed.
			- Added goLoopContinously to TGIFDrawOptions on request
			  from Reinier Sterkenburg.
			  The loop count specified in the GCE will be ignored
			  if this option is set.
			- Added TGIFImage.PaintTryLock.
			- Added code in TGIFImage.PaintLock to avoid dead locks.
	270198	anme	- Added TGIFColorMap.Data property for access to raw
			  colormap data.
			- Added TGIFSubImage.DoGetBitmap and DoGetDitherBitmap.
			- Added Floyd Steinberg dithering to TGIFSubImage
			  GetBitmap via DoGetDitherBitmap (see credits).
			- Added goDither to TGIFDrawOptions.
			- Fixed goLoopContinously for GIFs without loop ext.
			- Modified TGIFApplicationExtension.LoadFromStream
			  to handle GIFs produced by older Adobe programs.
	280198	anme	- Fixed bug in TGIFImage.Pack: Only first subimage's
			  bitmap and palette was zapped.
			- Added TGIFSubImage.Mask for better transparency
			  implementation. Mask is create in DoGet*Bitmap
			  and used in StretchDraw.
			- Copied TransparentStretchBlt from D3 graphics.pas to
			  implement transparency without TBitmap.Transparent.
	050298	anme	- Fixed TransparentStretchBlt by using method posted
			  to borland.public.delphi.vcl.components.writing by
			  Brian Lowe of Acro Technology Inc. on 30Jan98.
			  This solved a problem that I must have used at least
			  60 hours trying to nail.
			  Thank you to Stefan Hoffmeister for bringing the fix
			  to my attention.
			- Added TGIFSubImage.Transparent read-only property for
			  better performance.
			- Removed PaintLock/PaintUnlock from TGIFImage.Destroy
			  which caused a dead lock under rare circumstances.
	110298	anme	- Moved buffer setup from TGIFPainter.Execute to
			  TGIFPainter.Create.
			- Added adjustment of animation delay.
			  The animation delay now compensates for the time spent
			  converting the GIF to a bitmap resulting in a more
			  smooth startup animation.
			- Replaced use of Sleep() in threaded paint with
			  WaitForSingleObject with timeout.
			  This will enable TGIFPainter.Stop to abort the thread
			  even though it is waiting for the delay to expire.
			- Added TGIFImage.NewBitmap.
			- Added buffering of background in TGIFPainter for
			  transparent paint with dmBackground disposal.
			- The goFullDraw option is now obsolete.
			- Fixed deadlock problem in TGIFPainter.Stop when
			  TGIFPainter was running in main thread.
	190298	anme	- Added goAutoDither option.
			  The goAutoDither option modifies the behavior of the
			  goDither option. If goAutoDither is set, the goDither
			  option will be ignored on displays which supports more
			  than 256 colors.
			- Renamed the goDrawTransparent option to goTransparent.

0105	280298	anme	- Fixed loop bug in TGIFPainter.Execute.
			  Loop would wrap to wrong frame if loop extension
			  wasn't the first.
			- Fixed bug in transparent dmBackground disposal.
			  Only area covered by previous frame should be
			  restored - not complete image.
			- "Minor" optimizations of TGIFSubImage.Decompress.
			- Added progress events to TGIFImage.LoadFromStream
			  and SaveToStream.
			- Released as version 0105.
			  Even though the last release was version 0101 beta A,
			  I have decided to bump the version number up to 0105
			  to reflect the major improvements over the last
			  release.
			  Unfortunately this release does still not support
			  Delphi 2 as promised.

0106	090398	anme	- Minor improvement of Progress events in
			  TGIFImage.LoadFromStream and SaveToStream.
			- Added TGIFImageList.SaveToStream method.
			- Added Progress events to TGIFImage.Assign.
			- Added copy of OnProgress and OnChange properties to
			  TGIFImage.Assign.
	100398	anme	- Fixed bug in TGIFPainter.Stop when drawing in main
			  thread. TGIFPainter object was deleted before Execute
			  method had finished resulting in access violations.
0200	150398	rps	- Ported to Delphi 2.x by Reinier Sterkenburg.
			  Added support for PixelFormat and ScanLine for Delphi
			  2.x
			  Reiniers port will later be merged with the main
			  source and released as version 2.x.
	290398	anme	- Added Getters and Setters for TGIFSubImage Left, Top,
			  Width and Height properties (and various others) for
			  compatibility with C++ Builder.
			  C++ Builder does not support properties of the form
			  property <name>:<type> read <record>.<field> etc.
			- Changed some compile time conditions for compatibility
			  with C++ Builder.
			  Now uses {$ifndef ver90} instead of {$ifdef ver100} to
			  check for Delphi 3.x and later.
			- Added PixelFormat support for Delphi 2.x with
			  SetPixelFormat and GetPixelFormat utility functions.
	010498	anme	- Misc modifications after studying Netscape Mozilla
			  source code:
			  * Removed comment about GIFDefaultDelay since the
			    correct value has now been verified.
			  * Added GIFMinimumDelay to limit animation speed.
			  * Added support for ANIMEXTS extension.
			  * More tolerant load of GIF header.
			- Added STRICT_MOZILLA conditional define to disable
			  non-Mozilla compliant behaviour.
			- Ported TGIFSubImage.Assign to Delphi 2:
			  * Fixed bugs in import of 1 bit/pixel bitmaps.
			  * Replaced use of TBitmap.Scanline[] and PixelFormat
			    with internal DIB support functions.
			  * Fixed bugs in import via TCanvas.Pixels.
			- Fixed memory allocation bug in TColorMap.SetCapacity.
			  Too little memory was being reallocated on resize.
	060498	anme	- Ported TGIFSubImage.GetXXXBitmap to Delphi 2 by
			  removing dependancy on TBitmap.ScanLine.
			- Added GIFMaximumDelay to replace hardcoded limit
			  in TGIFPainter.Execute.
			- Merged Reinier Sterkenburg's Delphi 2 port with the
			  main source.
			- Added a lot of Delphi 3 stuff that's missing from
			  Delphi 2.
	110498	anme	- Modified DoGetBitmap and DoGetDitherBitmap to
			  circumvent Delphi 2's braindead palette behaviour;
			  When realizing a palette the first and last 10 palette
			  entries are always set to the system palette colors no
			  matter what palette we attempt to define. This is
			  basically a Windows issue but since Delphi 3 doesn't
			  have this problem, I blame it on Delphi 2.
			- Tweaked animation timing values to compensate for
			  the fact that we perform better than Mozilla.
			  Added FAST_AS_HELL conditional define to disable
			  tweaks.
			- Added paint events to TGIFImage and TGIFPainter:
			  OnStartPaint, OnPaint, OnLoop and OnEndPaint.
			- Changed TGIFPainter.ActiveImage to be a property.
			- Added dummy component registration procedure Register
			  to allow design time GIF paint options to be set and
			  add design time support to Delphi 2.
			  The Register procedure by default disables the
			  goLoop option at design time to avoid using CPU
			  resources and distract the developer.
	140498	anme	- Fixed "TBitmap.PixelFormat := pf8bit" leak by using
			  method posted to borland.public.delphi.graphics by
			  Greg Chapman on 15 Feb 1998.
			  Scratch yet another bug that I simply couldn't locate.
			  Thank you to Yorai Aminov and Mark Zamoyta for
			  bringing the fix to my attention.
	180498	anme	- Misc changes after feedback from Reinier Sterkenburg:
			  * Added clear of image memory to
                            TGIFSubImage.Decompress to avoid "random noise" in
                            incomplete or corrupted images.
			  * Fixed bug in handling of Adobe Application
			    Extensions which caused "Abstract error".
			- Added required compiler options.
			- Fixed bug in TGIFImage.InternalPaint that caused a
			  "Out of system resources" error when width or height
			  of paint rect was <= 0 and multiple paint threads
			  where in use.
			- Minor improvement of animation timing when running in
			  main thread.
			- Removed PaintLock functions since they where not
			  nescessary and caused a major bottle neck when running
			  multiple threads on the same image.
			  This has caused a general performance improvement.
			- Added conditional TPicture registration via the
			  REGISTER_TGIFIMAGE conditional define.
        230498	anme	- Fixed GetPixelFormat to support NT after feedback from
        		  Reinier Sterkenburg.
        		- Added CopyPalette function to support old versions of
                          Delphi 2.x
                        - Added Exception trap to TGIFPainter.Execute.
                          Nescessary to make sure that an exception doesn't halt
                          the thread and thus hangs the application.
        260598	anme	- Implemented clipboard support.
        		- Source cleaned up for release.

	260498	anme	- Released as version 2.0

--------------------------------------------------------------------------------
Credits:
Many of the algorithms and methods used in this library are based on work
originally done by others:

The "TBitmap.PixelFormat := pf8bit" leak was fixed by:
  * Greg Chapman <glc@well.com>
  with help from:
  * Yorai Aminov <yaminov@trendline.co.il> and
  * Mark Zamoyta <markcaz@earthlink.net>

The Delphi 2.x port was based on work done by:
  * Reinier Sterkenburg <r.p.sterkenburg@dataweb.nl>
    Reinier has also been *very* helpful with beta testing.

TransparentStretchBlt was fixed by:
  * Brian Lowe of Acro Technology Inc. <brianlow@acrotechweb.com>
  and brought to my attention by:
  * Stefan Hoffmeister <Stefan.Hoffmeister@Uni-Passau.de>

The dithering routines is based on work done by:
  * David Ullrich <ullrich@hardy.math.okstate.edu>, who also helped me weed
    out a few bugs in my implementation. Thanks.
  * Jef Poskanzer in ppmquant.c from the netpbm library

The compressor is based on:
  * ppmtogif.c (pbmplus) by Jef Poskanzer and others.
  * gifcompr.c, gifencode.c (GIFENCOD) by David Rowley <mgardi@watdscu.waterloo.edu>.
  * writegif.c (GIFTOOL) by David Koblas <koblas@netcom.com>
  * compress.c - File compression ala IEEE Computer, June 1984, by
    Spencer W. Thomas       (decvax!harpo!utah-cs!utah-gr!thomas)
    Jim McKie               (decvax!mcvax!jim)
    Steve Davies            (decvax!vax135!petsd!peora!srd)
    Ken Turkowski           (decvax!decwrl!turtlevax!ken)
    James A. Woods          (decvax!ihnp4!ames!jaw)
    Joe Orost               (decvax!vax135!petsd!joe)
  * gcd.c (gd) by Tom Boutell <boutell@boutell.com>

The decompressor is based on work done by
  * readgif.c (GIFTOOL) by David Koblas <koblas@netcom.com>

The hash routines was adapted from
  * gif_hash.c (gif-lib) by Gershon Elber <gershon@cs.utah.edu>
  * with help from Filip Larsen <filip@post4.tele.dk>

Version 0.01 was based on work done by:
  * Sean Wenzel, Compuserve 71736,1245
  * Richard Dominelli, RichardA_Dominelli@mskcc.org
  * Richard Shotbolt, Compuserve 100327,2305
  * Stefan Böther, stefc@fabula.com
  * Reinier Sterkenburg, r.p.sterkenburg@dataweb.nl

--------------------------------------------------------------------------------
Known problems:
* Import of 16, 24 and 32 bit images (using the Assing method) will most
  likely mess up the colors of the image.
  Thanks to Mark Vaughan for pointing this out to me.
* Buffered display flickers when TGIFImage is used by a transparent TImage
  component.
  This is a problem with TImage caused by the fact that TImage was designed
  with static images in mind. Not much I can do about it.

--------------------------------------------------------------------------------
To do (in rough order of priority):

* Palette optimizer with color quantization

* Non-compressed GIFs (LZW-less)

* Implement TGIFPainter support for:
  Morphing
  goValidateCanvas option
  Source/Target canvas palette normalization

* Optimize TGIFSubImage.Decompress

* Implement TGIFPainter support for:
  Interlaced display
  Progressive display (piped load/decompress/display)

* Implement TGIFPainter support for:
  UserInput
  Text extension
********************************************************************************
*******************************************************************************)


interface
(*******************************************************************************
**
**		Conditional Compiler Symbols
**
********************************************************************************

  DEBUG				Must be defined if any of the DEBUG_xxx
  				symbols are defined.
                                If the symbol is defined the source will not be
                                optimized and overflow- and range checks will be
                                enabled.

  DEBUG_HASHPERFORMANCE		Calculates hash table performance data.
  DEBUG_HASHFILLFACTOR		Calculates fill factor of hash table -
  				Interferes with DEBUG_HASHPERFORMANCE.
  DEBUG_COMPRESSPERFORMANCE	Calculates LZW compressor performance data.
  DEBUG_DECOMPRESSPERFORMANCE	Calculates LZW decompressor performance data.

  GIF_NOSAFETY			Define this symbol to disable overflow- and
				range checks.
                                Ignore if the DEBUG symbol is defined.

  STRICT_MOZILLA		Define to mimic Mozilla as closely as possible.
  				If not defined, a slightly more "optimal"
                                implementation is used (IMHO).

  FAST_AS_HELL			Define this symbol to use strictly GIF compliant
  				(but too fast) animation timing.
                                Since our paint routines are much faster than
                                Mozilla's, the standard GIF and Mozilla values
                                causes animations to loop too fast.
                                If the symbol is _not_ defined, an alternative
                                set of tweaked timing values will be used.
                                The tweaked values are not optimal but are based
                                on tests performed on my reference system:
                                - Windows 95
                                - 133 MHz Pentium
                                - 64Mb RAM
                                - Diamond Stealth64/V3000
                                - 1600*1200 in 256 colors
                                The alternate values can be modified if you are
                                not satisfied with my defaults (they can be
                                found a few pages down).

  REGISTER_TGIFIMAGE            Define this symbol to register TGIFImage with
  				the TPicture class and integrate with TImage.
                                This is required to be able to display GIFs in
                                the TImage component (using TGIFImage anyway).
                                Undefine if you use another GIF library to
                                provide GIF support for TImage.
*)

{$DEFINE REGISTER_TGIFIMAGE}
{_$DEFINE DEBUG}


(*******************************************************************************
**
**		Compiler Options required to compile this library
**
*******************************************************************************)
{$A+,B-,H+,J+,K-,M-,T-,X+}
{$IFDEF DEBUG}
  {$C+}	// ASSERTIONS
  {$O-}	// OPTIMIZATION
  {$Q+}	// OVERFLOWCHECKS
  {$R+}	// RANGECHECKS
{$ELSE}
  {$C-}	// ASSERTIONS
  {$O+}	// OPTIMIZATION
  {$IFDEF GIF_NOSAFETY}
    {$Q-}// OVERFLOWCHECKS
    {$R-}// RANGECHECKS
  {$ELSE}
    {$Q+}// OVERFLOWCHECKS
    {$R+}// RANGECHECKS
  {$ENDIF}
{$ENDIF}

(*******************************************************************************
**
**			External dependecies
**
*******************************************************************************)
uses
  sysutils,
  Windows,
  Graphics,
  Classes;

(*******************************************************************************
**
**			Misc constants and support types
**
*******************************************************************************)
const
  GIFMaxColors	= 256;			// Max number of colors supported by GIF
  					// Don't bother changing this value!

var
{$IFDEF FAST_AS_HELL}
  GIFDelayExp: integer = 10;		// Delay multiplier in mS.
{$ELSE}
  GIFDelayExp: integer = 12;		// Delay multiplier in mS. Tweaked.
{$ENDIF}
					// * GIFDelayExp:
  					// The following delay values should all
                                        // be multiplied by this value to
                                        // calculate the effective time (in mS).
                                        // According to the GIF specs, this
                                        // value should be 10.
                                        // Since our paint routines are much
                                        // faster than Mozilla's, you might need
                                        // to increase this value if your
                                        // animations loops too fast. The
                                        // optimal value is impossible to
                                        // determine since it depends on the
                                        // speed of the CPU, the viceo card,
                                        // memory and many other factors.

  GIFDefaultDelay: integer = 10;	// * GIFDefaultDelay:
  					// Default animation delay.
  					// This value is used if no GCE is
                                        // defined.
                                        // (10 = 100 mS)

{$IFDEF FAST_AS_HELL}
  GIFMinimumDelay: integer = 1;		// Minimum delay (from Mozilla source).
  					// (1 = 10 mS)
{$ELSE}
  GIFMinimumDelay: integer = 4;		// Minimum delay (from Mozilla source).
  					// Tweaked.
{$ENDIF}
					// * GIFMinimumDelay:
					// The minumum delay used in the Mozilla
                                        // source is 10mS. This corresponds to a
                                        // value of 1. However, since our paint
                                        // routines are much faster than
                                        // Mozilla's, a value of 3 or 4 gives
                                        // better results.

  GIFMaximumDelay: integer = 1000;	// * GIFMaximumDelay:
  					// Maximum delay when painter is running
  					// in main thread (goAsync is not set).
                                        // This value guarantees that a very
                                        // long and slow GIF does not hang the
                                        // system.
                                        // (1000 = 10000 mS = 10 Seconds)

type
  TGIFVersion = (gvUnknown, gv87a, gv89a);
  TGIFVersionRec = array[0..2] of char;

const
  GIFVersions : array[gv87a..gv89a] of TGIFVersionRec = ('87a', '89a');

type
  // TGIFImage only throws exceptions of type GIFException
  GIFException = class(EInvalidGraphic);

  // Severity level as indicated in the Warning methods and the OnWarning event
  TGIFSeverity = (gsInfo, gsWarning, gsError);

(*******************************************************************************
**
**			Delphi 2.x support
**
*******************************************************************************)
{$IFDEF VER90}
type
  // TThreadList from Delphi 3 classes.pas
  TThreadList = class
  private
    FList: TList;
    FLock: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Item: Pointer);
    procedure Clear;
    function  LockList: TList;
    procedure Remove(Item: Pointer);
    procedure UnlockList;
  end;

  // From Delphi 3 sysutils.pas
  EOutOfMemory = class(Exception);

  // From Delphi 3 classes.pas
  EOutOfResources = class(EOutOfMemory);

  // From Delphi 3 windows.pas
  PMaxLogPalette = ^TMaxLogPalette;
  TMaxLogPalette = packed record
    palVersion: Word;
    palNumEntries: Word;
    palPalEntry: array [Byte] of TPaletteEntry;
  end; { TMaxLogPalette }

  // From Delphi 3 graphics.pas. Used by the D3 TGraphic class.
  TProgressStage = (psStarting, psRunning, psEnding);
  TProgressEvent = procedure (Sender: TObject; Stage: TProgressStage;
    PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string) of object;

{$ENDIF}

(*******************************************************************************
**
**			Forward declarations
**
*******************************************************************************)
type
  TGIFImage = class;
  TGIFSubImage = class;

(*******************************************************************************
**
**			TGIFItem
**
*******************************************************************************)
  TGIFItem = class(TPersistent)
  private
    FGIFImage: TGIFImage;
  protected
    function GetVersion: TGIFVersion; virtual;
    procedure Warning(Severity: TGIFSeverity; Message: string); virtual;
  public
    constructor Create(GIFImage: TGIFImage); virtual;

    procedure SaveToStream(Stream: TStream); virtual; abstract;
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    property Version: TGIFVersion read GetVersion;
    property Image: TGIFImage read FGIFImage;
  end;

(*******************************************************************************
**
**			TGIFList
**
*******************************************************************************)
  TGIFList = class(TPersistent)
  private
    FItems: TList;
    FImage: TGIFImage;
  protected
    function GetItem(Index: Integer): TGIFItem;
    procedure SetItem(Index: Integer; Item: TGIFItem);
    function GetCount: Integer;
    procedure Warning(Severity: TGIFSeverity; Message: string); virtual;
  public
    constructor Create(Image: TGIFImage);
    destructor Destroy; override;

    function Add(Item: TGIFItem): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function First: TGIFItem;
    function IndexOf(Item: TGIFItem): Integer;
    procedure Insert(Index: Integer; Item: TGIFItem);
    function Last: TGIFItem;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: TGIFItem): Integer;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream; Parent: TObject); virtual; abstract;

    property Items[Index: Integer]: TGIFItem read GetItem write SetItem; default;
    property Count: Integer read GetCount;
    property List: TList read FItems;
    property Image: TGIFImage read FImage;
  end;

(*******************************************************************************
**
**			TGIFColorMap
**
*******************************************************************************)
  // One way to do it:
  //  TBaseColor = (bcRed, bcGreen, bcBlue);
  //  TGIFColor = array[bcRed..bcBlue] of BYTE;
  // Another way:
  TGIFColor = packed record
    Red: byte;
    Green: byte;
    Blue: byte;
  end;

  TColorMap = packed array[0..GIFMaxColors-1] of TGIFColor;
  PColorMap = ^TColorMap;

  TGIFColorMap = class(TPersistent)
  private
    FColorMap		: PColorMap;
    FCount		: integer;
    FCapacity		: integer;
    FOptimized		: boolean;
  protected
    function GetColor(Index: integer): TColor;
    procedure SetColor(Index: integer; Value: TColor);
    function GetBitsPerPixel: integer;
    function DoOptimize(Image: TGIFSubImage; CleanUp: boolean): boolean;
    procedure SetCapacity(Size: integer);
    procedure Warning(Severity: TGIFSeverity; Message: string); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    class function Color2RGB(Color: TColor): TGIFColor;
    class function RGB2Color(Color: TGIFColor): TColor;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream; Count: integer);
    procedure Assign(Source: TPersistent); override;
    function IndexOf(Color: TColor): integer;
    function Add(Color: TColor): integer;
    procedure Delete(Index: integer);
    procedure Clear;
    function Optimize: boolean; virtual; abstract;
    procedure Changed; virtual; abstract;
    procedure ImportPalette(Palette: HPalette);
    procedure ImportColorTable(Pal: pointer; Count: integer);
    procedure ImportDIBColors(Handle: HDC);
    function ExportPalette: HPalette;
    property Colors[Index: integer]: TColor read GetColor write SetColor; default;
    property Data: PColorMap read FColorMap;
    property Count: integer read FCount;
    property Optimized: boolean read FOptimized;
    property BitsPerPixel: integer read GetBitsPerPixel;
  end;

(*******************************************************************************
**
**			TGIFHeader
**
*******************************************************************************)
  TLogicalScreenDescriptor = packed record
    ScreenWidth: word;              { logical screen width }
    ScreenHeight: word;             { logical screen height }
    PackedFields: byte;             { packed fields }
    BackgroundColorIndex: byte;     { index to global color table }
    AspectRatio: byte;              { actual ratio = (AspectRatio + 15) / 64 }
  end;

  TGIFHeader = class(TGIFItem)
  private
    FLogicalScreenDescriptor: TLogicalScreenDescriptor;
    FColorMap		: TGIFColorMap;
    procedure Prepare;
  protected
    function GetVersion: TGIFVersion; override;
    function GetBackgroundColor: TColor;
    procedure SetBackgroundColor(Color: TColor);
    procedure SetBackgroundColorIndex(Index: BYTE);
    function GetBitsPerPixel: integer;
    function GetColorResolution: integer;
  public
    constructor Create(GIFImage: TGIFImage); override;
    destructor Destroy; override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    property Version: TGIFVersion read GetVersion;
    property Width: WORD read FLogicalScreenDescriptor.ScreenWidth
                            write FLogicalScreenDescriptor.ScreenWidth;
    property Height: WORD read FLogicalScreenDescriptor.ScreenHeight
                             write FLogicalScreenDescriptor.Screenheight;
    property BackgroundColorIndex: BYTE read FLogicalScreenDescriptor.BackgroundColorIndex
                                           write SetBackgroundColorIndex;
    property BackgroundColor: TColor read GetBackgroundColor
                                     write SetBackgroundColor;
    property AspectRatio: BYTE read FLogicalScreenDescriptor.AspectRatio
                                  write FLogicalScreenDescriptor.AspectRatio;
    property ColorMap: TGIFColorMap read FColorMap;
    property BitsPerPixel: integer read GetBitsPerPixel;
    property ColorResolution: integer read GetColorResolution;
  end;

(*******************************************************************************
**
**                      TGIFExtension
**
*******************************************************************************)
  TGIFExtensionType = BYTE;
  TGIFExtension = class;
  TGIFExtensionClass = class of TGIFExtension;

  TGIFGraphicControlExtension = class;

{$WARNINGS OFF} // To avoid warning about hiding base class constructor
  TGIFExtension = class(TGIFItem)
  private
    FSubImage: TGIFSubImage;
  protected
    function GetExtensionType: TGIFExtensionType; virtual; abstract;
    function GetVersion: TGIFVersion; override;
    function DoReadFromStream(Stream: TStream): TGIFExtensionType;
    class procedure RegisterExtension(elabel: BYTE; eClass: TGIFExtensionClass);
    class function FindExtension(Stream: TStream): TGIFExtensionClass;
    class function FindSubExtension(Stream: TStream): TGIFExtensionClass; virtual;
  public
    constructor Create(ASubImage: TGIFSubImage); virtual;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    property ExtensionType: TGIFExtensionType read GetExtensionType;
    property SubImage: TGIFSubImage read FSubImage;
  end;
{$WARNINGS ON}

(*******************************************************************************
**
**			TGIFSubImage
**
*******************************************************************************)
  TGIFExtensionList = class(TGIFList)
  protected
    function GetExtension(Index: Integer): TGIFExtension;
    procedure SetExtension(Index: Integer; Extension: TGIFExtension);
  public
    procedure LoadFromStream(Stream: TStream; Parent: TObject); override;
    property Extensions[Index: Integer]: TGIFExtension read GetExtension write SetExtension; default;
  end;

  TImageDescriptor = packed record
    Separator: byte;	{ fixed value of ImageSeparator }
    Left: word;		{ Column in pixels in respect to left edge of logical screen }
    Top: word;		{ row in pixels in respect to top of logical screen }
    Width: word;	{ width of image in pixels }
    Height: word;	{ height of image in pixels }
    PackedFields: byte;	{ Bit fields }
  end;

  TGIFSubImage = class(TGIFItem)
  private
    FDIBInfo		: PBitmapInfo;
    FDIBBits		: pointer;
    FDIBInfoSize	: integer;
    FDIBBitsSize	: longInt;
    FBitmap		: TBitmap;
    FMask		: HBitmap;
    FNeedMask		: boolean;
    FLocalPalette	: HPalette;
    FData		: PChar;
    FDataSize		: integer;
    FColorMap		: TGIFColorMap;
    FImageDescriptor	: TImageDescriptor;
    FExtensions		: TGIFExtensionList;
    FTransparent	: boolean;
    FGCE		: TGIFGraphicControlExtension;
    procedure Prepare;
    procedure Compress(Stream: TStream);
    procedure Decompress(Stream: TStream);
  protected
    function GetVersion: TGIFVersion; override;
    function GetInterlaced: boolean;
    procedure SetInterlaced(Value: boolean);
    function GetColorResolution: integer;
    function GetBitsPerPixel: integer;
    procedure AssignTo(Dest: TPersistent); override;
    function DoGetBitmap: TBitmap;
    function DoGetDitherBitmap: TBitmap;
    function GetBitmap: TBitmap;
    procedure SetBitmap(Value: TBitmap);
    procedure FreeBitmap;
    procedure FreeMask;
    function GetEmpty: Boolean;
    function GetPalette: HPALETTE;
    procedure SetPalette(Value: HPalette);
    function GetActiveColorMap: TGIFColorMap;
    function GetBoundsRect: TRect;
    function GetClientRect: TRect;
    function GetPixel(x, y: integer): BYTE;
    procedure NewBitmap;
    procedure NewImage;
    procedure FreeDIB;
    procedure BitmapToDIB(ABitmap: TBitmap);
    procedure DIBToBitmap(ABitmap: TBitmap);
    function GetScanLine(Row: Integer): PChar;
    function ScaleRect(DestRect: TRect): TRect;
    function HasMask: boolean;
    function GetBounds(Index: integer): WORD;
    procedure SetBounds(Index: integer; Value: WORD);
  public
    constructor Create(GIFImage: TGIFImage); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromFile(const Filename: string); virtual;
    procedure Assign(Source: TPersistent); override;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect; DoTransparent: boolean);
    procedure StretchDraw(ACanvas: TCanvas; const Rect: TRect; DoTransparent: boolean);
    property Left: WORD index 1 read GetBounds write SetBounds;
    property Top: WORD index 2 read GetBounds write SetBounds;
    property Width: WORD index 3 read GetBounds write SetBounds;
    property Height: WORD index 4 read GetBounds write SetBounds;
    property BoundsRect: TRect read GetBoundsRect;
    property ClientRect: TRect read GetClientRect;
    property Interlaced: boolean read GetInterlaced write SetInterlaced;
    property ColorMap: TGIFColorMap read FColorMap;
    property ActiveColorMap: TGIFColorMap read GetActiveColorMap;
    property Data: PChar read FData;
    property DataSize: integer read FDataSize;
    property Extensions: TGIFExtensionList read FExtensions;
    property Version: TGIFVersion read GetVersion;
    property ColorResolution: integer read GetColorResolution;
    property BitsPerPixel: integer read GetBitsPerPixel;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property Mask: HBitmap read FMask;
    property Palette: HPALETTE read GetPalette write SetPalette;
    property Empty: boolean read GetEmpty;
    property Transparent: boolean read FTransparent;
    property GraphicControlExtension: TGIFGraphicControlExtension read FGCE;
    property Pixels[x, y: integer]: BYTE read GetPixel;
  end;

(*******************************************************************************
**
**                      TGIFTrailer
**
*******************************************************************************)
  TGIFTrailer = class(TGIFItem)
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
  end;

(*******************************************************************************
**
**                      TGIFGraphicControlExtension
**
*******************************************************************************)
  // Graphic Control Extension block a.k.a GCE
  TGIFGCERec = packed record
    BlockSize: byte;         { should be 4 }
    PackedFields: Byte;
    DelayTime: Word;         { in centiseconds }
    TransparentColorIndex: Byte;
    Terminator: Byte;
  end;

  TDisposalMethod = (dmNone, dmNoDisposal, dmBackground, dmPrevious);

  TGIFGraphicControlExtension = class(TGIFExtension)
  private
    FGCExtension: TGIFGCERec;
  protected
    function GetExtensionType: TGIFExtensionType; override;
    function GetTransparent: boolean;
    procedure SetTransparent(Value: boolean);
    function GetTransparentColor: TColor;
    procedure SetTransparentColor(Color: TColor);
    function GetTransparentColorIndex: BYTE;
    procedure SetTransparentColorIndex(Value: BYTE);
    function GetDelay: WORD;
    procedure SetDelay(Value: WORD);
    function GetUserInput: boolean;
    procedure SetUserInput(Value: boolean);
    function GetDisposal: TDisposalMethod;
    procedure SetDisposal(Value: TDisposalMethod);

  public
    constructor Create(ASubImage: TGIFSubImage); override;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    property Delay: WORD read GetDelay write SetDelay;
    property Transparent: boolean read GetTransparent write SetTransparent;
    property TransparentColorIndex: BYTE read GetTransparentColorIndex
                                            write SetTransparentColorIndex;
    property TransparentColor: TColor read GetTransparentColor write SetTransparentColor;
    property UserInput: boolean read GetUserInput write SetUserInput;
    property Disposal: TDisposalMethod read GetDisposal write SetDisposal;
  end;

(*******************************************************************************
**
**                      TGIFTextExtension
**
*******************************************************************************)
  TGIFPlainTextExtensionRec = packed record
    BlockSize: byte;         { should be 12 }
    Left, Top, Width, Height: Word;
    CellWidth, CellHeight: Byte;
    TextFGColorIndex,
    TextBGColorIndex: Byte;
  end;

  TGIFTextExtension = class(TGIFExtension)
  private
    FText		: TStrings;
    FPlainTextExtension	: TGIFPlainTextExtensionRec;
  protected
    function GetExtensionType: TGIFExtensionType; override;
    function GetForegroundColor: TColor;
    procedure SetForegroundColor(Color: TColor);
    function GetBackgroundColor: TColor;
    procedure SetBackgroundColor(Color: TColor);
    function GetBounds(Index: integer): WORD;
    procedure SetBounds(Index: integer; Value: WORD);
    function GetCharWidthHeight(Index: integer): BYTE;
    procedure SetCharWidthHeight(Index: integer; Value: BYTE);
    function GetColorIndex(Index: integer): BYTE;
    procedure SetColorIndex(Index: integer; Value: BYTE);
  public
    constructor Create(ASubImage: TGIFSubImage); override;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    property Left: WORD index 1 read GetBounds write SetBounds;
    property Top: WORD index 2 read GetBounds write SetBounds;
    property GridWidth: WORD index 3 read GetBounds write SetBounds;
    property GridHeight: WORD index 4 read GetBounds write SetBounds;
    property CharWidth: BYTE index 1 read GetCharWidthHeight write SetCharWidthHeight;
    property CharHeight: BYTE index 2 read GetCharWidthHeight write SetCharWidthHeight;
    property ForegroundColorIndex: BYTE index 1 read GetColorIndex write SetColorIndex;
    property ForegroundColor: TColor read GetForegroundColor;
    property BackgroundColorIndex: BYTE  index 2 read GetColorIndex write SetColorIndex;
    property BackgroundColor: TColor read GetBackgroundColor;
    property Text: TStrings read FText write FText;
  end;

(*******************************************************************************
**
**                      TGIFCommentExtension
**
*******************************************************************************)
  TGIFCommentExtension = class(TGIFExtension)
  private
    FText		: TStrings;
  protected
    function GetExtensionType: TGIFExtensionType; override;
  public
    constructor Create(ASubImage: TGIFSubImage); override;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    property Text: TStrings read FText;
  end;

(*******************************************************************************
**
**                      TGIFApplicationExtension
**
*******************************************************************************)
  TGIFIdentifierCode = array[0..7] of char;
  TGIFAuthenticationCode = array[0..2] of char;
  TGIFApplicationRec = packed record
    Identifier: TGIFIdentifierCode;
    Authentication: TGIFAuthenticationCode;
  end;

  TGIFApplicationExtension = class;
  TGIFAppExtensionClass = class of TGIFApplicationExtension;

  TGIFApplicationExtension = class(TGIFExtension)
  private
    FIdent		: TGIFApplicationRec;
  protected
    function GetExtensionType: TGIFExtensionType; override;
    procedure SaveData(Stream: TStream); virtual; abstract;
    procedure LoadData(Stream: TStream); virtual; abstract;
  public
    constructor Create(ASubImage: TGIFSubImage); override;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    class procedure RegisterExtension(eIdent: TGIFApplicationRec; eClass: TGIFAppExtensionClass);
    class function FindSubExtension(Stream: TStream): TGIFExtensionClass; override;
    property Identifier: TGIFIdentifierCode read FIdent.Identifier
      write FIdent.Identifier;
    property Authentication: TGIFAuthenticationCode read FIdent.Authentication
      write FIdent.Authentication;
  end;

(*******************************************************************************
**
**                      TGIFUnknownAppExtension
**
*******************************************************************************)
  TGIFBlock = class(TObject)
  private
    FSize		: BYTE;
    FData		: pointer;
  public
    constructor Create(ASize: integer);
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    property Size: BYTE read FSize;
    property Data: pointer read FData;
  end;

  TGIFUnknownAppExtension = class(TGIFApplicationExtension)
  private
    FBlocks		: TList;
  protected
    procedure SaveData(Stream: TStream); override;
    procedure LoadData(Stream: TStream); override;
  public
    constructor Create(ASubImage: TGIFSubImage); override;
    destructor Destroy; override;
    property Blocks: TList read FBlocks;
  end;

(*******************************************************************************
**
**                      TGIFAppExtNSLoop
**
*******************************************************************************)
  TGIFAppExtNSLoop = class(TGIFApplicationExtension)
  private
    FLoops		: WORD;
  protected
    procedure SaveData(Stream: TStream); override;
    procedure LoadData(Stream: TStream); override;
  public
    constructor Create(ASubImage: TGIFSubImage); override;
    property Loops: WORD read FLoops write FLoops;
  end;

(*******************************************************************************
**
**                      TGIFImage
**
*******************************************************************************)
  TGIFImageList = class(TGIFList)
  protected
    function GetImage(Index: Integer): TGIFSubImage;
    procedure SetImage(Index: Integer; SubImage: TGIFSubImage);
  public
    procedure LoadFromStream(Stream: TStream; Parent: TObject); override;
    procedure SaveToStream(Stream: TStream); override;
    property SubImages[Index: Integer]: TGIFSubImage read GetImage write SetImage; default;
  end;

  TGIFDrawOption =
    (goAsync,			// Asyncronous draws (paint in thread)
     goTransparent,		// Transparent draws
     goAnimate,			// Animate draws
     goLoop,			// Loop animations
     goLoopContinously,		// Ignore loop count and loop forever
     goValidateCanvas,		// Validate canvas in threaded paint ***NOT IMPLEMENTED***
     goDirectDraw,		// Draw() directly on canvas
     goDither,			// Dither to Netscape palette
     goAutoDither		// Only dither on 256 color systems
    );
  TGIFDrawOptions = set of TGIFDrawOption;
  // Note: if goAsync is not set then goDirectDraw should be set. Otherwise
  // the image will not be displayed.

  PGIFPainter = ^TGIFPainter;

  TGIFPainter = class(TThread)
  private
    FImage		: TGIFImage;	// The TGIFImage that owns this painter
    FCanvas		: TCanvas;	// Destination canvas
    FRect		: TRect;	// Destination rect
    FDrawOptions	: TGIFDrawOptions;// Paint options
    FActiveImage	: integer;	// Current frame
    Disposal		,		// Used by synchronized paint
    OldDisposal		: TDisposalMethod;// Used by synchronized paint
    BackupBuffer	: TBitmap;	// Used by synchronized paint
    FrameBuffer		: TBitmap;	// Used by synchronized paint
    Background		: TBitmap;	// Used by synchronized paint
    ValidateDC		: HDC;
    DoRestart		: boolean;	// Flag used to restart animation
    FStarted		: boolean;	// Flag used to signal start of paint
    PainterRef		: PGIFPainter;	// Pointer to var referencing painter
    DelayEvent		: THandle;	// Animation delay event
    FEvent		: TNotifyEvent;	// Used by synchronized events
    FOnStartPaint	: TNotifyEvent;
    FOnPaint		: TNotifyEvent;
    FOnLoop		: TNotifyEvent;
    FOnEndPaint		: TNotifyEvent;
    procedure DoSynchronize(Method: TThreadMethod);
    					// Conditional sync stub
    procedure DoZap;			// Sync. shutdown procedure
    procedure PrefetchBitmap;		// Sync. bitmap prefetch
    procedure DoPaintFrame;		// Sync. buffered paint procedure
    procedure DoPaint;			// Sync. paint procedure
    procedure DoEvent;			// Sync. event procedure
  protected
    procedure Execute; override;
  public
    constructor Create(AImage: TGIFImage; ACanvas: TCanvas; ARect: TRect;
      Options: TGIFDrawOptions);
    constructor CreateRef(var Painter: TGIFPainter; AImage: TGIFImage; ACanvas: TCanvas; ARect: TRect;
      Options: TGIFDrawOptions);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure Restart;
    property Image: TGIFImage read FImage;
    property Canvas: TCanvas read FCanvas;
    property Rect: TRect read FRect write FRect;
    property DrawOptions: TGIFDrawOptions read FDrawOptions write FDrawOptions;
    property Started: boolean read FStarted;
    property ActiveImage: integer read FActiveImage;
    property OnStartPaint: TNotifyEvent read FOnStartPaint write FOnStartPaint;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnLoop: TNotifyEvent read FOnLoop write FOnLoop;
    property OnEndPaint	: TNotifyEvent read FOnEndPaint	 write FOnEndPaint	;
  end;

  TGIFWarning = procedure(Sender: TObject; Severity: TGIFSeverity; Message: string) of object;

  TGIFImage = class(TGraphic)
  private
    IsDrawing		: Boolean;
    IsInsideGetPalette	: boolean;
    FImages		: TGIFImageList;
    FHeader		: TGIFHeader;
    FGlobalPalette	: HPalette;
    FPainters		: TThreadList;
    FDrawOptions	: TGIFDrawOptions;
    FOnWarning		: TGIFWarning;
    FBitmap		: TBitmap;
    FDrawPainter	: TGIFPainter;
    FThreadPriority	: TThreadPriority;
    FDrawBackgroundColor: TColor;
    FOnStartPaint	: TNotifyEvent;
    FOnPaint		: TNotifyEvent;
    FOnLoop		: TNotifyEvent;
    FOnEndPaint		: TNotifyEvent;
{$IFDEF VER90}
    FPaletteModified	: Boolean;
    FOnProgress		: TProgressEvent;
{$ENDIF}
  protected
    procedure Changed(Sender: TObject); {$IFDEF VER90} virtual; {$ELSE} override; {$ENDIF}
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure AssignTo(Dest: TPersistent); override;
    function InternalPaint(var Painter: TGIFPainter; ACanvas: TCanvas; const Rect: TRect; Options: TGIFDrawOptions): TGIFPainter;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function Equals(Graphic: TGraphic): Boolean; override;
    function GetPalette: HPALETTE; {$IFDEF VER90} virtual; {$ELSE} override; {$ENDIF}
    procedure SetPalette(Value: HPalette); {$IFDEF VER90} virtual; {$ELSE} override; {$ENDIF}
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    function GetVersion: TGIFVersion;
    function GetColorResolution: integer;
    function GetBitsPerPixel: integer;
    function GetBackgroundColorIndex: BYTE;
    function GetBackgroundColor: TColor;
    procedure SetDrawOptions(Value: TGIFDrawOptions);
    procedure NewImage;
    function GetBitmap: TBitmap;
    function NewBitmap: TBitmap;
    procedure FreeBitmap;
    function GetColorMap: TGIFColorMap;
    function GetDoDither: boolean;
    property DrawPainter: TGIFPainter read FDrawPainter; // Extremely volatile
    property DoDither: boolean read GetDoDither;
{$IFDEF VER90}
    procedure Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte;  RedrawNow: Boolean; const R: TRect; const Msg: string); dynamic;
{$ENDIF}
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    function Add(Source: TPersistent): integer;
    procedure Pack;
    procedure Clear;
    procedure StopDraw;
    function Paint(ACanvas: TCanvas; const Rect: TRect; Options: TGIFDrawOptions): TGIFPainter;
    procedure PaintStart;
    procedure PaintPause;
    procedure PaintStop;
    procedure PaintResume;
    procedure Warning(Sender: TObject; Severity: TGIFSeverity; Message: string); virtual;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); override;
    property GlobalColorMap: TGIFColorMap read GetColorMap;
    property Version: TGIFVersion read GetVersion;
    property Images: TGIFImageList read FImages;
    property ColorResolution: integer read GetColorResolution;
    property BitsPerPixel: integer read GetBitsPerPixel;
    property BackgroundColorIndex: BYTE read GetBackgroundColorIndex;
    property BackgroundColor: TColor read GetBackgroundColor;
    property Header: TGIFHeader read FHeader;
    property DrawOptions: TGIFDrawOptions read FDrawOptions write SetDrawOptions;
    property DrawBackgroundColor: TColor read FDrawBackgroundColor write FDrawBackgroundColor;
    property OnWarning: TGIFWarning read FOnWarning write FOnWarning;
    property Painters: TThreadList read FPainters;
    property ThreadPriority: TThreadPriority read FThreadPriority write FThreadPriority;
    property Bitmap: TBitmap read GetBitmap; // Volatile - beware!
    property OnStartPaint: TNotifyEvent read FOnStartPaint write FOnStartPaint;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnLoop: TNotifyEvent read FOnLoop write FOnLoop;
    property OnEndPaint	: TNotifyEvent read FOnEndPaint	 write FOnEndPaint	;
{$IFDEF VER90}
    property Palette: HPALETTE read GetPalette write SetPalette;
    property PaletteModified: Boolean read FPaletteModified write FPaletteModified;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
{$ENDIF}
  end;

(*******************************************************************************
**
**                      Utility routines
**
*******************************************************************************)
  // WebPalette creates a 216 color uniform palette a.k.a. the Netscape Palette
  function WebPalette: HPalette;

(*******************************************************************************
**
**                      Library defaults
**
*******************************************************************************)
var
  // Default options for TGIFImage.DrawOptions.
  GIFImageDefaultDrawOptions : TGIFDrawOptions =
    [goAsync, goLoop, goTransparent, goAnimate, goDither, goAutoDither];

  // WARNING! Do not use goAsync and goDirectDraw unless you have absolute
  // control of the destination canvas.
  // TGIFPainter will continue to write on the canvas even after the canvas has
  // been deleted, unless *you* prevent it.
  // The goValidateCanvas option will fix this problem if it is ever implemented.

  // Default painter thread priority
  GIFImageDefaultThreadPriority: TThreadPriority = tpNormal;

  // DoAutoDither is set to True in the initializaion section if the desktop DC
  // supports 256 colors or less.
  // It can be modified in your application to disable/enable Auto Dithering
  DoAutoDither: boolean = False;

(*******************************************************************************
**
**                      Design Time support
**
*******************************************************************************)
// Dummy component registration for design time support of GIFs in TImage
procedure Register;

(*******************************************************************************
********************************************************************************
**
**			Implementation
**
********************************************************************************
*******************************************************************************)
implementation

uses
{$ifdef DEBUG}
  dialogs,
  {$ifdef DEBUG_COMPRESSPERFORMANCE}
    mmsystem,
  {$else}
    {$ifdef DEBUG_DECOMPRESSPERFORMANCE}
      mmsystem,
    {$endif}
  {$endif}
{$endif}
  messages,
  Consts;

(*******************************************************************************
**
**                      Error messages
**
*******************************************************************************)
{$ifndef VER90}
resourcestring
{$else}
const
{$endif}
  // GIF Error messages
  sOutOfData		= 'Premature end of data';
  sTooManyColors	= 'Color table overflow';
  sBadColorIndex	= 'Invalid color index';
  sBadVersion		= 'Unsupported GIF version';
  sBadSignature		= 'Invalid GIF signature';
  sScreenBadColorSize	= 'Invalid number of colors specified in Screen Descriptor';
  sImageBadColorSize	= 'Invalid number of colors specified in Image Descriptor';
  sUnknownExtension	= 'Unknown extension type';
  sBadExtensionLabel	= 'Invalid extension introducer';
  sOutOfMemDIB		= 'Failed to allocate memory for GIF DIB';
  sDIBCreate		= 'Failed to create DIB from Bitmap';
  sDecodeTooFewBits	= 'Decoder bit buffer under-run';
  sDecodeCircular	= 'Circular decoder table entry';
  sBadTrailer		= 'Invalid Image trailer';
  sBadExtensionInstance	= 'Internal error: Extension Instance does not match Extension Label';
  sBadBlockSize		= 'Unsupported Application Extension block size';
  sBadBlock		= 'Unknown GIF block type';
  sUnsupportedClass	= 'Object type not supported for operation';
  sInvalidData		= 'Invalid GIF data';
  sBadHeight		= 'Image height too small for contained frames';
  sBadWidth		= 'Image width too small for contained frames';
  sGIFToClipboard	= 'Clipboard operations not supported for GIF objects'; // Obsolete ***FIXME***
  sScreenSizeExceeded	= 'Image exceeds Logical Screen size';
  sNoColorTable		= 'No global or local color table defined';
  sBadPixelCoordinates	= 'Invalid pixel coordinates';
  sUnsupportedBitmap	= 'Unsupported bitmap format';
  sInvalidPixelFormat	= 'Unsupported PixelFormat';
  sBadDimension		= 'Invalid image dimensions';
  sNoDIB		= 'Image has no DIB';
{$IFDEF VER90}
  // From Delphi 3 consts.pas
  SOutOfResources	= 'Out of system resources';
  SInvalidBitmap	= 'Bitmap image is not valid';
  SScanLine		= 'Scan line index out of range';
{$ENDIF}

(*******************************************************************************
**
**                      Misc texts
**
*******************************************************************************)
  // File filter name
  sGIFImageFile		= 'GIF Image';

  // Progress messages
  sProgressLoading	= 'Loading...';
  sProgressSaving	= 'Saving...';
  sProgressConverting	= 'Converting...';
  sProgressRendering	= 'Rendering...';
  sProgressCopying	= 'Copying...';

(******************************************************************************)
const
  { Extension/block label values }
  bsPlainTextExtension		= $01;
  bsGraphicControlExtension	= $F9;
  bsCommentExtension		= $FE;
  bsApplicationExtension	= $FF;

  bsImageDescriptor		= Ord(',');
  bsExtensionIntroducer		= Ord('!');
  bsTrailer			= ord(';');

  // Thread message - Used by TThread.Synchronize()
  CM_EXECPROC 		= $8FFF; // Defined in classes.pas


(*******************************************************************************
**
**                      Global variables
**
*******************************************************************************)
// GIF Clipboard format identifier for use by LoadFromClipboardFormat and
// SaveToClipboardFormat.
// Set in Initialization section.
var
  CF_GIF: WORD;

(*******************************************************************************
**
**                      Design Time support
**
*******************************************************************************)
procedure Register;
begin
  // Dummy component registration to add design-time support of GIFs to TImage
  // Since TGIFImage isn't a component there's nothing to register here, but
  // since Register is only called at design time we can set the design time
  // GIF paint options here (modify as you please):

  // Don't loop animations at design-time. Animated GIFs will animate once and
  // then stop thus not using CPU resources and distracting the developer.
  Exclude(GIFImageDefaultDrawOptions, goLoop);
end;

(*******************************************************************************
**
**			Utilities
**
*******************************************************************************)

function WebPalette: HPalette;
type
  TLogWebPalette	= packed record
    palVersion		: word;
    palNumEntries	: word;
    PalEntries		: array[0..5,0..5,0..5] of TPaletteEntry;
  end;
var
  r, g, b		: byte;
  LogWebPalette		: TLogWebPalette;
  LogPalette		: TLogpalette absolute LogWebPalette; // Stupid typecast
begin
  with LogWebPalette do
  begin
    palVersion:= $300;
    palNumEntries:= 216;
    for r:=0 to 5 do
      for g:=0 to 5 do
        for b:=0 to 5 do
        begin
          with PalEntries[r,g,b] do
          begin
            peRed := 51 * r;
            peGreen := 51 * g;
            peBlue := 51 * b;
            peFlags := 0;
          end;
         end;
  end;
  Result := CreatePalette(Logpalette);
end;

(*
**  GDI Error handling
**  Copied from graphics.pas
*)
function GDICheck(Value: Integer): Integer;
var
  ErrorCode: Integer;
  Buf: array [Byte] of Char;

  function ReturnAddr: Pointer;
  // From classes.pas
  asm
    MOV		EAX,[EBP+4] // sysutils.pas says [EBP-4] !
  end;

begin
  if (Value = 0) then
  begin
    ErrorCode := GetLastError;
    if (ErrorCode <> 0) and (FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil,
      ErrorCode, LOCALE_USER_DEFAULT, Buf, sizeof(Buf), nil) <> 0) then
      raise EOutOfResources.Create(Buf) at ReturnAddr
    else
      raise EOutOfResources.Create(SOutOfResources) at ReturnAddr;
  end;
  Result := Value;
end;

(*
**  Raise error condition
*)
procedure Error(msg: string);
  function ReturnAddr: Pointer;
  // From classes.pas
  asm
    MOV		EAX,[EBP+4] // sysutils.pas says [EBP-4] !
  end;
begin
  raise GIFException.Create(msg) at ReturnAddr;
end;

(*
**  Return number bytes required to
**  hold a given number of bits.
*)
function ByteAlignBit(Bits: Cardinal): Cardinal;
begin
  Result := (Bits+7) SHR 3;
end;
// Rounded up to nearest 2
function WordAlignBit(Bits: Cardinal): Cardinal;
begin
  Result := ((Bits+15) SHR 4) SHL 1;
end;
// Rounded up to nearest 4
function DWordAlignBit(Bits: Cardinal): Cardinal;
begin
  Result := ((Bits+31) SHR 5) SHL 2;
end;
// Round to arbitrary number of bits
function AlignBit(Bits, BitsPerPixel, Alignment: Cardinal): Cardinal;
begin
  Dec(Alignment);
  Result := ((Bits * BitsPerPixel) + Alignment) and not Alignment;
  Result := Result SHR 3;
end;

(*
**  Compute Bits per Pixel from Number of Colors
**  (Return the ceiling log of n)
*)
function Colors2bpp(val: integer): integer;
var
  i			: integer;
begin
  (*
  ** This might be faster computed by multiple if then else statements
  *)
  if (val = 0) then
    Result := 0
  else
  begin
    for i := 1 to 8 do
      if (val <= (1 SHL i)) then
      begin
        Result := i;
        exit;
      end;
    Result := 8;
  end;
end;

(*
**  Write an ordinal byte value to a stream
*)
procedure WriteByte(Stream: TStream; b: BYTE);
begin
  Stream.Write(b, 1);
end;

(*
**  Read an ordinal byte value from a stream
*)
function ReadByte(Stream: TStream): BYTE;
begin
  Stream.Read(Result, 1);
end;

(*
**  Read data from stream and raise exception of EOF
*)
procedure ReadCheck(Stream: TStream; var Buffer; Size: LongInt);
var
  ReadSize		: integer;
begin
  ReadSize := Stream.Read(Buffer, Size);
  if (ReadSize <> Size) then
    Error(sOutOfData);
end;

(*
**  Write a string list to a stream as multiple blocks
**  of max 255 characters in each.
*)
procedure WriteStrings(Stream: TStream; Text: TStrings);
var
  i			: integer;
  b			: BYTE;
  size			: integer;
  s			: string;
begin
  for i := 0 to Text.Count-1 do
  begin
    s := Text[i];
    size := length(s);
    if (size > 255) then
      b := 255
    else
      b := size;
    while (size > 0) do
    begin
      dec(size, b);
      WriteByte(Stream, b);
      Stream.Write(PChar(s)^, b);
      delete(s, 1, b);
      if (b > size) then
        b := size;
    end;
  end;
  // Terminating zero (length = 0)
  WriteByte(Stream, 0);
end;


(*
**  Read a string list from a stream as multiple blocks
**  of max 255 characters in each.
*)
procedure ReadStrings(Stream: TStream; Text: TStrings);
var
  size			: BYTE;
  buf			: array[0..255] of char;
begin
  Text.Clear;
  if (Stream.Read(size, 1) <> 1) then
    exit;
  while (size > 0) do
  begin
    ReadCheck(Stream, buf, size);
    buf[size] := #0;
    Text.Add(Buf);
    if (Stream.Read(size, 1) <> 1) then
      exit;
  end;
end;


(*******************************************************************************
**
**			Delphi 2.x support
**
*******************************************************************************)
{$IFDEF VER90}
var
  // From Delphi 3 graphics.pas
  SystemPalette16: HPalette; // 16 color palette that maps to the system palette
{$ENDIF}

type
{$IFDEF VER90}
  // From Delphi 3 graphics.pas
  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom);
{$ENDIF}
  TPixelFormats = set of TPixelFormat;

const
  // Only pf1bit, pf4bit, pf8bit and pf24bit is supported at this time
  SupportedPixelformats: TPixelFormats = [pf1bit, pf4bit, pf8bit, pf24bit];


// --------------------------
// InitializeBitmapInfoHeader
// --------------------------
// Fills a TBitmapInfoHeader with the values of a bitmap when converted to a
// DIB of a specified PixelFormat.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// Info		The TBitmapInfoHeader buffer that will receive the values.
// PixelFormat	The pixel format of the destination DIB.
//
procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var Info: TBitmapInfoHeader;
  PixelFormat: TPixelFormat);
// From graphics.pas, "optimized" for our use
var
  DIB		: TDIBSection;
  Bytes		: Integer;
begin
  DIB.dsbmih.biSize := 0;
  Bytes := GetObject(Bitmap, SizeOf(DIB), @DIB);
  if (Bytes = 0) then
    Error(sInvalidBitmap);

  if (Bytes >= (sizeof(DIB.dsbm) + sizeof(DIB.dsbmih))) and
    (DIB.dsbmih.biSize >= sizeof(DIB.dsbmih)) then
    Info := DIB.dsbmih
  else
  begin
    FillChar(Info, sizeof(Info), 0);
    with Info, DIB.dsbm do
    begin
      biSize := SizeOf(Info);
      biWidth := bmWidth;
      biHeight := bmHeight;
    end;
  end;
  case PixelFormat of
    pf1bit: Info.biBitCount := 1;
    pf4bit: Info.biBitCount := 4;
    pf8bit: Info.biBitCount := 8;
    pf24bit: Info.biBitCount := 24;
  else
    Error(sInvalidPixelFormat);
    // Info.biBitCount := DIB.dsbm.bmBitsPixel * DIB.dsbm.bmPlanes;
  end;
  Info.biPlanes := 1;
  Info.biSizeImage := AlignBit(Info.biWidth, Info.biBitCount, 32) * abs(Info.biHeight);
end;

// -------------------
// InternalGetDIBSizes
// -------------------
// Calculates the buffer sizes nescessary for convertion of a bitmap to a DIB
// of a specified PixelFormat.
// See the GetDIBSizes API function for more info.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// InfoHeaderSize
//		The returned size of a buffer that will receive the DIB's
//		TBitmapInfo structure.
// ImageSize	The returned size of a buffer that will receive the DIB's
//		pixel data.
// PixelFormat	The pixel format of the destination DIB.
//
procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
  var ImageSize: longInt; PixelFormat: TPixelFormat);
// From graphics.pas, "optimized" for our use
var
  Info		: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, Info, PixelFormat);
  // Check for palette device format
  if (Info.biBitCount > 8) then
  begin
    // Header but no palette
    InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    if ((Info.biCompression and BI_BITFIELDS) <> 0) then
      Inc(InfoHeaderSize, 12);
  end else
    // Header and palette
    InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) * (1 shl Info.biBitCount);
  ImageSize := Info.biSizeImage;
end;

// --------------
// InternalGetDIB
// --------------
// Converts a bitmap to a DIB of a specified PixelFormat.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// Pal		The handle of the source palette.
// BitmapInfo	The buffer that will receive the DIB's TBitmapInfo structure.
//		A buffer of sufficient size must have been allocated prior to
//		calling this function.
// Bits		The buffer that will receive the DIB's pixel data.
//		A buffer of sufficient size must have been allocated prior to
//		calling this function.
// PixelFormat	The pixel format of the destination DIB.
//
// Returns:
// True on success, False on failure.
//
// Note: The InternalGetDIBSizes function can be used to calculate the
// nescessary sizes of the BitmapInfo and Bits buffers.
//
function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; PixelFormat: TPixelFormat): Boolean;
// From graphics.pas, "optimized" for our use
var
  OldPal	: HPALETTE;
  DC		: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), PixelFormat);
  OldPal := 0;
  DC := CreateCompatibleDC(0);
  try
    if (Palette <> 0) then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := (GetDIBits(DC, Bitmap, 0, abs(TBitmapInfoHeader(BitmapInfo).biHeight),
      @Bits, TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0);
  finally
    if (OldPal <> 0) then
      SelectPalette(DC, OldPal, False);
    DeleteDC(DC);
  end;
end;

// ----------
// DIBFromBit
// ----------
// Converts a bitmap to a DIB of a specified PixelFormat.
// The DIB is returned in a TMemoryStream ready for streaming to a BMP file.
//
// Note: As opposed to D2's DIBFromBit function, the returned stream also
// contains a TBitmapFileHeader at offset 0.
//
// Parameters:
// Stream	The TMemoryStream used to store the bitmap data.
//		The stream must be allocated and freed by the caller prior to
//		calling this function.
// Src		The handle of the source bitmap.
// Pal		The handle of the source palette.
// PixelFormat	The pixel format of the destination DIB.
// DIBHeader	A pointer to the DIB's TBitmapInfo (or TBitmapInfoHeader)
//		structure in the memory stream.
//		The size of the structure can either be deduced from the
//		pixel format (i.e. number of colors) or calculated by
//		subtracting the DIBHeader pointer from the DIBBits pointer.
// DIBBits	A pointer to the DIB's pixel data in the memory stream.
//
procedure DIBFromBit(Stream: TMemoryStream; Src: HBITMAP;
  Pal: HPALETTE; PixelFormat: TPixelFormat; var DIBHeader, DIBBits: Pointer);
// (From D2 graphics.pas, "optimized" for our use)
var
  HeaderSize		: integer;
  FileSize		: longInt;
  ImageSize		: longInt;
  BitmapFileHeader	: PBitmapFileHeader;
begin
  if (Src = 0) then
    Error(sInvalidBitmap);
  // Get header- and pixel data size for new pixel format
  InternalGetDIBSizes(Src, HeaderSize, ImageSize, PixelFormat);
  // Make room in stream for a TBitmapInfo and pixel data
  FileSize := sizeof(TBitmapFileHeader) + HeaderSize + ImageSize;
  Stream.SetSize(FileSize);
  // Get pointer to TBitmapFileHeader
  BitmapFileHeader := Stream.Memory;
  // Get pointer to TBitmapInfo
  DIBHeader := Pointer(Longint(BitmapFileHeader) + sizeof(TBitmapFileHeader));
  // Get pointer to pixel data
  DIBBits := Pointer(Longint(DIBHeader) + HeaderSize);
  // Initialize file header
  FillChar(BitmapFileHeader^, sizeof(TBitmapFileHeader), 0);
  with BitmapFileHeader^ do
  begin
    bfType := $4D42; // 'BM' = Windows BMP signature
    bfSize := FileSize; // File size (not needed)
    bfOffBits := sizeof(TBitmapFileHeader) + HeaderSize; // Offset of pixel data
  end;
  // Get pixel data in new pixel format
  InternalGetDIB(Src, Pal, DIBHeader^, DIBBits^, PixelFormat);
end;

// --------------
// GetPixelFormat
// --------------
// Returns the current pixel format of a bitmap.
//
// Replacement for delphi 3 TBitmap.PixelFormat getter.
//
// Parameters:
// Bitmap	The bitmap which pixel format is returned.
//
// Returns:
// The PixelFormat of the bitmap
//
function GetPixelFormat(Bitmap: TBitmap): TPixelFormat;
{$IFDEF VER90}
// From graphics.pas, "optimized" for our use
var
  DIBSection		: TDIBSection;
  Bytes			: Integer;
begin
  Result := pfCustom; // This value is never returned
  if (Bitmap.Handle <> 0) then
  begin
    Bytes := GetObject(Bitmap.Handle, SizeOF(DIBSection), @DIBSection);
    if (Bytes = 0) then
      Error(sInvalidBitmap);

    with (DIBSection) do
    begin
      // Check for NT bitmap
      if (Bytes < (SizeOf(dsbm) + SizeOf(dsbmih))) or (dsbmih.biSize < SizeOf(dsbmih)) then
        DIBSection.dsBmih.biBitCount := dsbm.bmBitsPixel * dsbm.bmPlanes;

      case (dsBmih.biBitCount) of
        0: Result := pfDevice;
        1: Result := pf1bit;
        4: Result := pf4bit;
        8: Result := pf8bit;
        16: case (dsBmih.biCompression) of
              BI_RGB:
                Result := pf15Bit;
              BI_BITFIELDS:
                if (dsBitFields[1] = $07E0) then
                  Result := pf16Bit;
            end;
        24: Result := pf24Bit;
        32: if (dsBmih.biCompression = BI_RGB) then
              Result := pf32Bit;
      else
        Error(sUnsupportedBitmap);
      end;
    end;
  end else
//    Result := pfDevice;
    Error(sUnsupportedBitmap);
end;
{$ELSE}
begin
  Result := Bitmap.PixelFormat;
end;
{$ENDIF}

// --------------
// SetPixelFormat
// --------------
// Changes the pixel format of a TBitmap.
//
// Replacement for delphi 3 TBitmap.PixelFormat setter.
// The returned TBitmap will always be a DIB.
//
// Note: Under Delphi 3.x this function will leak a palette handle each time it
//       converts a TBitmap to pf8bit format!
//       If possible, use SafeSetPixelFormat instead to avoid this.
//
// Parameters:
// Bitmap	The bitmap to modify.
// PixelFormat	The pixel format to convert to.
//
procedure SetPixelFormat(Bitmap: TBitmap; PixelFormat: TPixelFormat);
{$IFDEF VER90}
var
  Stream	: TMemoryStream;
  Header	,
  Bits		: Pointer;
begin
  // Can't change anything without a handle
  if (Bitmap.Handle = 0) then
    Error(sInvalidBitmap);

  // Only convert to supported formats
  if not(PixelFormat in SupportedPixelformats) then
    Error(sInvalidPixelFormat);

  // No need to convert to same format
  if (GetPixelFormat(Bitmap) = PixelFormat) then
    exit;

  Stream := TMemoryStream.Create;
  try
    // Convert to DIB file in memory stream
    DIBFromBit(Stream, Bitmap.Handle, Bitmap.Palette, PixelFormat, Header, Bits);
    // Load DIB from stream
    Stream.Position := 0;
    Bitmap.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;
{$ELSE}
begin
  Bitmap.PixelFormat := PixelFormat;
end;
{$ENDIF}

{$IFNDEF VER90}
var
  pf8BitBitmap: TBitmap = nil;
{$ENDIF}

// --------------
// SetPixelFormat
// --------------
// Changes the pixel format of a TBitmap but doesn't preserve the contents.
//
// Replacement for delphi 3 TBitmap.PixelFormat setter.
// The returned TBitmap will always be an empty DIB of the same size as the
// original bitmap.
//
// This function is used to avoid the palette handle leak that SetPixelFormat
// and TBitmap.PixelFormat suffers from.
//
// Parameters:
// Bitmap	The bitmap to modify.
// PixelFormat	The pixel format to convert to.
//
procedure SafeSetPixelFormat(Bitmap: TBitmap; PixelFormat: TPixelFormat);
{$IFDEF VER90}
begin
  SetPixelFormat(Bitmap, PixelFormat);
end;
{$ELSE}
var
  Width			,
  Height	: integer;
begin
  if (PixelFormat = pf8bit) then
  begin
    // Solution to "TBitmap.PixelFormat := pf8bit" leak by Greg Chapman <glc@well.com>
    if (pf8BitBitmap = nil) then
    begin
      // Create a "template" bitmap
      // The bitmap is deleted in the finalization section of the unit.
      pf8BitBitmap:= TBitmap.Create;
      // Convert template to pf8bit format
      // This will leak 1 palette handle, but only once
      pf8BitBitmap.PixelFormat:= pf8Bit;
    end;
    // Store the size of the original bitmap
    Width := Bitmap.Width;
    Height := Bitmap.Height;
    // Convert to pf8bit format by copying template
    Bitmap.Assign(pf8BitBitmap);
    // Restore the original size
    Bitmap.Width := Width;
    Bitmap.Height := Height;
  end else
    // This is safe since only pf8bit leaks
    Bitmap.PixelFormat := PixelFormat;
end;
{$ENDIF}


{$IFDEF VER90}

// -----------
// CopyPalette
// -----------
// Copies a HPALETTE.
//
// Copied from D3 graphics.pas.
// This is declared private in some old versions of Delphi 2 so we have to
// implement it here to support those old versions.
//
// Parameters:
// Palette	The palette to copy.
//
// Returns:
// The handle to a new palette.
//
function CopyPalette(Palette: HPALETTE): HPALETTE;
var
  PaletteSize: Integer;
  LogPal: TMaxLogPalette;
begin
  Result := 0;
  if Palette = 0 then Exit;
  PaletteSize := 0;
  if GetObject(Palette, SizeOf(PaletteSize), @PaletteSize) = 0 then Exit;
  if PaletteSize = 0 then Exit;
  with LogPal do
  begin
    palVersion := $0300;
    palNumEntries := PaletteSize;
    GetPaletteEntries(Palette, 0, PaletteSize, palPalEntry);
  end;
  Result := CreatePalette(PLogPalette(@LogPal)^);
end;


// TThreadList implementation from Delphi 3 classes.pas
constructor TThreadList.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FList := TList.Create;
end;

destructor TThreadList.Destroy;
begin
  LockList;    // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    DeleteCriticalSection(FLock);
  end;
end;

procedure TThreadList.Add(Item: Pointer);
begin
  LockList;
  try
    if FList.IndexOf(Item) = -1 then
      FList.Add(Item);
  finally
    UnlockList;
  end;
end;

procedure TThreadList.Clear;
begin
  LockList;
  try
    FList.Clear;
  finally
    UnlockList;
  end;
end;

function  TThreadList.LockList: TList;
begin
  EnterCriticalSection(FLock);
  Result := FList;
end;

procedure TThreadList.Remove(Item: Pointer);
begin
  LockList;
  try
    FList.Remove(Item);
  finally
    UnlockList;
  end;
end;

procedure TThreadList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;
// End of TThreadList implementation

// From Delphi 3 sysutils.pas
{ CompareMem performs a binary compare of Length bytes of memory referenced
  by P1 to that of P2.  CompareMem returns True if the memory referenced by
  P1 is identical to that of P2. }
function CompareMem(P1, P2: Pointer; Length: Integer): Boolean; assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,P1
        MOV     EDI,P2
        MOV     EDX,ECX
        XOR     EAX,EAX
        AND     EDX,3
        SHR     ECX,1
        SHR     ECX,1
        REPE    CMPSD
        JNE     @@2
        MOV     ECX,EDX
        REPE    CMPSB
        JNE     @@2
@@1:    INC     EAX
@@2:    POP     EDI
        POP     ESI
end;

// Dummy ASSERT procedure since ASSERT does not exist in Delphi 2.x
procedure ASSERT(Condition: boolean; Message: string);
begin
end;

{$ENDIF} // Delphi 2.x stuff

(*******************************************************************************
**
**			TGIFColorMap
**
*******************************************************************************)
const
  InitColorMapSize = 16;
  DeltaColorMapSize = 32;

constructor TGIFColorMap.Create;
begin
  inherited Create;
  FColorMap := nil;
  FCapacity := 0;
  FCount := 0;
  FOptimized := False;
end;

destructor TGIFColorMap.Destroy;
begin
  Clear;
  Changed;
  inherited Destroy;
end;

procedure TGIFColorMap.Clear;
begin
  if (FColorMap <> nil) then
    FreeMem(FColorMap);
  FColorMap := nil;
  FCapacity := 0;
  FCount := 0;
  FOptimized := False;
end;

class function TGIFColorMap.Color2RGB(Color: TColor): TGIFColor;
begin
  Result.Blue := (Color shr 16) and $FF;
  Result.Green := (Color shr 8) and $FF;
  Result.Red  := Color and $FF;
end;

class function TGIFColorMap.RGB2Color(Color: TGIFColor): TColor;
begin
  Result := (Color.Blue SHL 16) OR (Color.Green SHL 8) OR Color.Red;
end;

procedure TGIFColorMap.SaveToStream(Stream: TStream);
var
  Dummies		: integer;
  Dummy			: TGIFColor;
begin
  if (FCount = 0) then
    exit;
  Stream.WriteBuffer(FColorMap^, FCount*sizeof(TGIFColor));
  Dummies := (1 SHL BitsPerPixel)-FCount;
  Dummy.Red := 0;
  Dummy.Green := 0;
  Dummy.Blue := 0;
  while (Dummies > 0) do
  begin
    Stream.WriteBuffer(Dummy, sizeof(TGIFColor));
    dec(Dummies);
  end;
end;

procedure TGIFColorMap.LoadFromStream(Stream: TStream; Count: integer);
begin
  Clear;
  SetCapacity(Count);
  ReadCheck(Stream, FColorMap^, Count*sizeof(TGIFColor));
  FCount := Count;
end;

function TGIFColorMap.IndexOf(Color: TColor): integer;
var
  RGB			: TGIFColor;
begin
  RGB := Color2RGB(Color);
  if (FOptimized) then
  begin
    // Optimized palette has most used entries first
    Result := 0;
    // Reverse search to (hopefully) check latest colors first
    while (Result < FCount) do
      with (FColorMap^[Result]) do
      begin
        if (RGB.Red = Red) and (RGB.Green = Green) and (RGB.Blue = Blue) then
          exit;
        Inc(Result);
      end;
    Result := -1;
  end else
  begin
    Result := FCount-1;
    // Reverse search to (hopefully) check latest colors first
    while (Result >= 0) do
      with (FColorMap^[Result]) do
      begin
        if (RGB.Red = Red) and (RGB.Green = Green) and (RGB.Blue = Blue) then
          exit;
        Dec(Result);
      end;
  end;
end;

procedure TGIFColorMap.SetCapacity(Size: integer);
begin
  if (Size >= FCapacity) then
  begin
    if (Size <= InitColorMapSize) then
      FCapacity := InitColorMapSize
    else
      FCapacity := (Size + DeltaColorMapSize - 1) DIV DeltaColorMapSize * DeltaColorMapSize;
    if (FCapacity > GIFMaxColors) then
      FCapacity := GIFMaxColors;
    ReallocMem(FColorMap, FCapacity * sizeof(TGIFColor));
  end;
end;

procedure TGIFColorMap.ImportPalette(Palette: HPalette);
type
  PalArray =  array[byte] of TPaletteEntry;
var
  Pal			: ^PalArray;
  NewCount		: integer;
  i			: integer;
begin
  Clear;
  GetMem(Pal, sizeof(TPaletteEntry) * 256);
  try
    NewCount := GetPaletteEntries(Palette, 0, 256, pal^);
    if (NewCount = 0) then
      exit;
    SetCapacity(NewCount);
    for i := 0 to NewCount-1 do
      with FColorMap[i], Pal[i] do
      begin
        Red := peRed;
        Green := peGreen;
        Blue := peBlue;
      end;
    FCount := NewCount;
  finally
    FreeMem(Pal);
  end;
  Changed;
end;

procedure TGIFColorMap.ImportColorTable(Pal: pointer; Count: integer);
type
  // From Delphi 3 graphics.pas
  PRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = array[Byte] of TRGBQuad;
var
  i			: integer;
begin
  Clear;
  if (Count = 0) then
    exit;
  SetCapacity(Count);
  for i := 0 to Count-1 do
    with FColorMap[i], PRGBQuadArray(Pal)[i] do
    begin
      Red := rgbRed;
      Green := rgbGreen;
      Blue := rgbBlue;
    end;
  FCount := Count;
  Changed;
end;

procedure TGIFColorMap.ImportDIBColors(Handle: HDC);
var
  Pal			: Pointer;
  NewCount		: integer;
begin
  Clear;
  GetMem(Pal, sizeof(TRGBQuad) * 256);
  try
    NewCount := GetDIBColorTable(Handle, 0, 256, Pal^);
    ImportColorTable(Pal, NewCount);
  finally
    FreeMem(Pal);
  end;
  Changed;
end;

function TGIFColorMap.ExportPalette: HPalette;
var
  Pal			: TMaxLogPalette;
  i			: Integer;
begin
  if (Count = 0) then
  begin
    Result := 0;
    exit;
  end;
  Pal.palVersion := $300;
  Pal.palNumEntries := Count;
  for i := 0 to Count-1 do
    with FColorMap[i], Pal.palPalEntry[i] do
    begin
      peRed := Red;
      peGreen := Green;
      peBlue := Blue;
      peFlags := 0;
    end;
  Result := CreatePalette(PLogPalette(@Pal)^);
end;

function TGIFColorMap.Add(Color: TColor): integer;
begin
  // Look up color before add (same as IndexOf)
  Result := IndexOf(Color);
  if (Result >= 0) then
    exit;

  if (FCount >= GIFMaxColors) then
    Error(sTooManyColors);

  Result := FCount;
  if (Result >= FCapacity) then
    SetCapacity(FCount+1);
  FColorMap^[FCount] := Color2RGB(Color);
  inc(FCount);
  FOptimized := False;
  Changed;
end;

procedure TGIFColorMap.Delete(Index: integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(sBadColorIndex);
  dec(FCount);
  if (Index < FCount) then
    System.Move(FColorMap^[Index + 1], FColorMap^[Index], (FCount - Index)* sizeof(TGIFColor));
  FOptimized := False;
  Changed;
end;

function TGIFColorMap.GetColor(Index: integer): TColor;
begin
  if (Index < 0) or (Index >= FCount) then
    Warning(gsWarning, sBadColorIndex);
  Result := RGB2Color(FColorMap^[Index]);
end;

procedure TGIFColorMap.SetColor(Index: integer; Value: TColor);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(sBadColorIndex);
  FColorMap^[Index] := Color2RGB(Value);
  Changed;
end;

type
  TUsageCount = record
    Index		: integer;
    Count		: integer;
  end;

function TGIFColorMap.DoOptimize(Image: TGIFSubImage; CleanUp: Boolean): boolean;
var
  Pixel			,
  LastPixel		: PChar;
  Usage			: array[0..255] of TUsageCount;
  TempMap		: array[0..255] of TGIFColor;
  ReverseMap		: array[0..255] of BYTE;
  i			: integer;
  LastFound		: boolean;
  NewCount		: integer;

  procedure QuickSort(L, R: Integer);
  var
    I, J: Integer;
  const // Statics minimizes stack usage
    P: integer = 0;
    T: TUsageCount = (Index: 0; Count:0);
  begin
    repeat
      I := L;
      J := R;
      P := Usage[(L + R) shr 1].Count;
      repeat
        while (Usage[I].Count - P > 0) do inc(I);
        while (Usage[J].Count - P < 0) do dec(J);
        if (I <= J) then
        begin
          T := Usage[I];
          Usage[I] := Usage[J];
          Usage[J] := T;
          inc(I);
          dec(J);
        end;
      until I > J;
      if L < J then QuickSort(L, J);
      { Something missing here... }
      L := I;
    until I >= R;
  end;

begin
  if (FCount <= 1) then
  begin
    Result := False;
    exit;
  end;

  FOptimized := True;
  Result := True;

  for i := 0 to FCount-1 do
  begin
    Usage[i].Index := i;
    Usage[i].Count := 0;
  end;

  Pixel := Image.data;
  LastPixel := Pixel + Image.Width * Image.Height;

  (*
  ** Sum up usage count for each color
  *)
  while (Pixel < LastPixel) do
  begin
    inc(Usage[ord(Pixel^)].Count);
    inc(Pixel);
  end;

  (*
  **  Sort according to usage count
  *)
  QuickSort(0, FCount-1);

  (*
  ** Test for table already sorted
  *)
  for i := 0 to FCount-1 do
    if (Usage[i].Index <> i) then
      break;
  if (i = FCount) then
    exit;

  (*
  ** Build old to new map
  *)
  for i := 0 to FCount-1 do
    ReverseMap[Usage[i].Index] := i;

  (*
  **  Reorder all pixel to new map
  *)
  Pixel := Image.data;
  while (Pixel < LastPixel) do
  begin
    Pixel^ := chr(ReverseMap[ord(Pixel^)]);
    inc(Pixel);
  end;

  (*
  **  Reorder transparent colors
  *)
  if (Image.Transparent) then
    Image.GraphicControlExtension.TransparentColorIndex :=
      ReverseMap[Image.GraphicControlExtension.TransparentColorIndex];
{
  for i := 0 to Image.Extensions.Count-1 do
    if (Image.Extensions[i] is TGIFGraphicControlExtension) then
    begin
      if (TGIFGraphicControlExtension(Image.Extensions[i]).Transparent) then
        TGIFGraphicControlExtension(Image.Extensions[i]).TransparentColorIndex :=
          ReverseMap[TGIFGraphicControlExtension(Image.Extensions[i]).TransparentColorIndex];
      break;
    end;
}
  (*
  **  Reorder colormap
  *)
  LastFound := False;
  NewCount := 0;
  Move(FColorMap^, TempMap, FCount * sizeof(TGIFColor));
  for i := 0 to FCount-1 do
  begin
    FColorMap^[ReverseMap[i]] := TempMap[i];
    // Find last used color index
    if (Usage[i].Count = 0) and not(LastFound) then
    begin
      LastFound := True;
      if (CleanUp) then
        NewCount := i;
    end;
  end;

  if (CleanUp) then
    FCount := NewCount;

  Changed;
end;

function TGIFColorMap.GetBitsPerPixel: integer;
begin
  Result := Colors2bpp(FCount);
end;

procedure TGIFColorMap.Assign(Source: TPersistent);
begin
  if (Source is TGIFColorMap) then
  begin
    Clear;
    FCapacity := TGIFColorMap(Source).FCapacity;
    FCount := TGIFColorMap(Source).FCount;
    FOptimized := TGIFColorMap(Source).FOptimized;
    FColorMap := AllocMem(FCapacity * sizeof(TGIFColor));
    System.Move(TGIFColorMap(Source).FColorMap^, FColorMap^, FCount * sizeof(TGIFColor));
    Changed;
  end else
    inherited Assign(Source);
end;

(*******************************************************************************
**
**			TGIFItem
**
*******************************************************************************)
constructor TGIFItem.Create(GIFImage: TGIFImage);
begin
  inherited Create;

  FGIFImage := GIFImage;
end;

procedure TGIFItem.Warning(Severity: TGIFSeverity; Message: string);
begin
  FGIFImage.Warning(self, Severity, Message);
end;

function TGIFItem.GetVersion: TGIFVersion;
begin
  Result := gv87a;
end;

(*******************************************************************************
**
**			TGIFList
**
*******************************************************************************)
constructor TGIFList.Create(Image: TGIFImage);
begin
  inherited Create;
  FImage := Image;
  FItems := TList.Create;
end;

destructor TGIFList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TGIFList.GetItem(Index: Integer): TGIFItem;
begin
  Result := TGIFItem(FItems[Index]);
end;

procedure TGIFList.SetItem(Index: Integer; Item: TGIFItem);
begin
  FItems[Index] := Item;
end;

function TGIFList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGIFList.Add(Item: TGIFItem): Integer;
begin
  Result := FItems.Add(Item);
end;

procedure TGIFList.Clear;
begin
  while (FItems.Count > 0) do
    Delete(0);
end;

procedure TGIFList.Delete(Index: Integer);
begin
  TGIFItem(FItems[Index]).Free;
  FItems.Delete(Index);
end;

procedure TGIFList.Exchange(Index1, Index2: Integer);
begin
  FItems.Exchange(Index1, Index2);
end;

function TGIFList.First: TGIFItem;
begin
  Result := TGIFItem(FItems.First);
end;

function TGIFList.IndexOf(Item: TGIFItem): Integer;
begin
  Result := FItems.IndexOf(Item);
end;

procedure TGIFList.Insert(Index: Integer; Item: TGIFItem);
begin
  FItems.Insert(Index, Item);
end;

function TGIFList.Last: TGIFItem;
begin
  Result := TGIFItem(FItems.Last);
end;

procedure TGIFList.Move(CurIndex, NewIndex: Integer);
begin
  FItems.Move(CurIndex, NewIndex);
end;

function TGIFList.Remove(Item: TGIFItem): Integer;
begin
  Result := FItems.Remove(Item);
end;

procedure TGIFList.SaveToStream(Stream: TStream);
var
  i			: integer;
begin
  for i := 0 to FItems.Count-1 do
    TGIFItem(FItems[i]).SaveToStream(Stream);
end;

procedure TGIFList.Warning(Severity: TGIFSeverity; Message: string);
begin
  Image.Warning(self, Severity, Message);
end;

(*******************************************************************************
**
**			TGIFGlobalColorMap
**
*******************************************************************************)
type
  TGIFGlobalColorMap = class(TGIFColorMap)
  private
    FHeader	: TGIFHeader;
  protected
    procedure Warning(Severity: TGIFSeverity; Message: string); override;
  public
    constructor Create(HeaderItem: TGIFHeader);
    function Optimize: boolean; override;
    procedure Changed; override;
  end;

constructor TGIFGlobalColorMap.Create(HeaderItem: TGIFHeader);
begin
  Inherited Create;
  FHeader := HeaderItem;
end;

procedure TGIFGlobalColorMap.Warning(Severity: TGIFSeverity; Message: string);
begin
  FHeader.Image.Warning(self, Severity, Message);
end;

function TGIFGlobalColorMap.Optimize: boolean;
begin
  { Optimize with first image, Remove unused colors if only one image }
  if (FHeader.Image.Images.Count > 0) then
    Result := DoOptimize(TGIFSubImage(FHeader.Image.Images.First), (FHeader.Image.Images.Count = 1))
  else
    Result := False;
end;

procedure TGIFGlobalColorMap.Changed;
begin
  FHeader.Image.Palette := 0;
end;

(*******************************************************************************
**
**			TGIFHeader
**
*******************************************************************************)
constructor TGIFHeader.Create(GIFImage: TGIFImage);
begin
  inherited Create(GIFImage);
  FColorMap := TGIFGlobalColorMap.Create(self);
  FLogicalScreenDescriptor.ScreenWidth := 0;
  FLogicalScreenDescriptor.ScreenHeight := 0;
  FLogicalScreenDescriptor.PackedFields := 0;
  FLogicalScreenDescriptor.BackgroundColorIndex := 0;
  FLogicalScreenDescriptor.AspectRatio := 0;
end;

destructor TGIFHeader.Destroy;
begin
  FColorMap.Free;
  inherited Destroy;
end;

procedure TGIFHeader.AssignTo(Dest: TPersistent);
begin
  if Dest is TGIFHeader then
    with TGIFHeader(Dest) do
    begin
      ColorMap.Assign(Self.ColorMap);
      FLogicalScreenDescriptor := self.FLogicalScreenDescriptor;
    end
  else
    inherited AssignTo(Dest);
end;

type
  TGIFHeaderRec = packed record
    Signature: array[0..2] of char; { contains 'GIF' }
    Version: TGIFVersionRec;   { '87a' or '89a' }
  end;

const
  { logical screen descriptor packed field masks }
  lsdGlobalColorTable	= $80;		{ set if global color table follows L.S.D. }
  lsdColorResolution	= $70;		{ Color resolution - 3 bits }
  lsdSort		= $08;		{ set if global color table is sorted - 1 bit }
  lsdColorTableSize	= $07;		{ size of global color table - 3 bits }
  					{ Actual size = 2^value+1    - value is 3 bits }
procedure TGIFHeader.Prepare;
var
  pack			: BYTE;
begin
  Pack := $00;
  if (ColorMap.Count > 0) then
  begin
    Pack := lsdGlobalColorTable;
    if (ColorMap.Optimized) then
      Pack := Pack OR lsdSort;
  end;
  // Note: The SHL below was SHL 5 in the original source, but that looks wrong
  Pack := Pack OR ((Image.ColorResolution SHL 4) AND lsdColorResolution);
  Pack := Pack OR ((Image.BitsPerPixel-1) AND lsdColorTableSize);
  FLogicalScreenDescriptor.PackedFields := Pack;
end;

procedure TGIFHeader.SaveToStream(Stream: TStream);
var
  GifHeader		: TGIFHeaderRec;
  v			: TGIFVersion;
begin
  v := Image.Version;
  if (v = gvUnknown) then
    Error(sBadVersion);

  GifHeader.Signature := 'GIF';
  GifHeader.Version := GIFVersions[v];

  Prepare;
  Stream.Write(GifHeader, sizeof(GifHeader));
  Stream.Write(FLogicalScreenDescriptor, sizeof(FLogicalScreenDescriptor));
  if (FLogicalScreenDescriptor.PackedFields AND lsdGlobalColorTable = lsdGlobalColorTable) then
    ColorMap.SaveToStream(Stream);
end;

procedure TGIFHeader.LoadFromStream(Stream: TStream);
var
  GifHeader		: TGIFHeaderRec;
  ColorCount		: integer;
begin
  ReadCheck(Stream, GifHeader, sizeof(GifHeader));
  if (uppercase(GifHeader.Signature) <> 'GIF') then
    Error(sBadSignature);

  ReadCheck(Stream, FLogicalScreenDescriptor, sizeof(FLogicalScreenDescriptor));

  if (FLogicalScreenDescriptor.PackedFields AND lsdGlobalColorTable = lsdGlobalColorTable) then
  begin
    ColorCount := 2 SHL (FLogicalScreenDescriptor.PackedFields AND lsdColorTableSize);
    if (ColorCount < 2) or (ColorCount > 256) then
      Error(sScreenBadColorSize);
    ColorMap.LoadFromStream(Stream, ColorCount)
  end else
    ColorMap.Clear;
end;

function TGIFHeader.GetVersion: TGIFVersion;
begin
  if (FColorMap.Optimized) or (AspectRatio <> 0) then
    Result := gv89a
  else
    Result := inherited GetVersion;
end;

function TGIFHeader.GetBackgroundColor: TColor;
begin
  Result := FColorMap[BackgroundColorIndex];
end;

procedure TGIFHeader.SetBackgroundColor(Color: TColor);
var
  Index			: integer;
begin
  Index := FColorMap.IndexOf(Color);
  if (Index = -1) then
    Index := FColorMap.Add(Color);
  BackgroundColorIndex := Index;
end;

procedure TGIFHeader.SetBackgroundColorIndex(Index: BYTE);
begin
  if (Index < 0) or ((Index >= FColorMap.Count) and (FColorMap.Count > 0)) then
  begin
    Warning(gsWarning, sBadColorIndex);
    Index := 0;
  end;
  FLogicalScreenDescriptor.BackgroundColorIndex := Index;
end;

function TGIFHeader.GetBitsPerPixel: integer;
begin
  Result := FColorMap.BitsPerPixel;
end;

function TGIFHeader.GetColorResolution: integer;
begin
  Result := FColorMap.BitsPerPixel-1;
end;

(*******************************************************************************
**
**			TGIFLocalColorMap
**
*******************************************************************************)
type
  TGIFLocalColorMap = class(TGIFColorMap)
  private
    FSubImage		: TGIFSubImage;
  protected
    procedure Warning(Severity: TGIFSeverity; Message: string); override;
  public
    constructor Create(SubImage: TGIFSubImage);
    function Optimize: boolean; override;
    procedure Changed; override;
  end;

constructor TGIFLocalColorMap.Create(SubImage: TGIFSubImage);
begin
  Inherited Create;
  FSubImage := SubImage;
end;

procedure TGIFLocalColorMap.Warning(Severity: TGIFSeverity; Message: string);
begin
  FSubImage.Image.Warning(self, Severity, Message);
end;

function TGIFLocalColorMap.Optimize: boolean;
begin
  Result := DoOptimize(FSubImage, True);
end;

procedure TGIFLocalColorMap.Changed;
begin
  FSubImage.Palette := 0;
end;

(*******************************************************************************
**
**			TGIFSubImage
**
*******************************************************************************)
function TGIFExtensionList.GetExtension(Index: Integer): TGIFExtension;
begin
  Result := TGIFExtension(Items[Index]);
end;

procedure TGIFExtensionList.SetExtension(Index: Integer; Extension: TGIFExtension);
begin
  Items[Index] := Extension;
end;

procedure TGIFExtensionList.LoadFromStream(Stream: TStream; Parent: TObject);
var
  b			: BYTE;
  Extension		: TGIFExtension;
  ExtensionClass	: TGIFExtensionClass;
begin
  // Peek ahead to determine block type
  if (Stream.Read(b, 1) <> 1) then
    exit;
  while not(b in [bsTrailer, bsImageDescriptor]) do
  begin
    if (b = bsExtensionIntroducer) then
    begin
      ExtensionClass := TGIFExtension.FindExtension(Stream);
      if (ExtensionClass = nil) then
        Error(sUnknownExtension);
      Stream.Seek(-1, soFromCurrent);
      Extension := ExtensionClass.Create(Parent as TGIFSubImage);
      try
        Extension.LoadFromStream(Stream);
        Add(Extension);
      except
        Extension.Free;
        raise;
      end;
    end else
    begin
      Warning(gsWarning, sBadExtensionLabel);
      break;
    end;
    if (Stream.Read(b, 1) <> 1) then
      exit;
  end;
  Stream.Seek(-1, soFromCurrent);
end;

const
  { image descriptor bit masks }
  idLocalColorTable	= $80;    { set if a local color table follows }
  idInterlaced		= $40;    { set if image is interlaced }
  idSort		= $20;    { set if color table is sorted }
  idReserved		= $0C;    { reserved - must be set to $00 }
  idColorTableSize	= $07;    { size of color table as above }

constructor TGIFSubImage.Create(GIFImage: TGIFImage);
begin
  inherited Create(GIFImage);
  FExtensions := TGIFExtensionList.Create(GIFImage);
  FColorMap := TGIFLocalColorMap.Create(self);
  FImageDescriptor.Separator := bsImageDescriptor;
  FImageDescriptor.Left := 0;
  FImageDescriptor.Top := 0;
  FImageDescriptor.Width := 0;
  FImageDescriptor.Height := 0;
  FImageDescriptor.PackedFields := 0;
  FDIBInfo := nil;
  FDIBBits := nil;
  FBitmap := nil;
  FMask := 0;
  FNeedMask := True;
  FData := nil;
  FDataSize := 0;
  FTransparent := False;
  FGCE := nil;
  // Remember to synchronize with TGIFSubImage.Clear
end;

destructor TGIFSubImage.Destroy;
begin
  Clear;
  FExtensions.Free;
  FColorMap.Free;
  if (FLocalPalette <> 0) then
    DeleteObject(FLocalPalette);
  inherited Destroy;
end;

procedure TGIFSubImage.Clear;
begin
  FExtensions.Clear;
  FColorMap.Clear;
  if (FData <> nil) then
    FreeMem(FData);
  FData := nil;
  FDataSize := 0;
  Height := 0;
  Width := 0;
  FTransparent := False;
  FGCE := nil;
  FreeDIB;
  FreeBitmap;
  FreeMask;
  // Remember to synchronize with TGIFSubImage.Create
end;

// Free the DIB allocated by BitmapToDIB
procedure TGIFSubImage.FreeDIB;
begin
  if (FDIBInfo <> nil) then
    FreeMem(FDIBInfo);
  if (FDIBBits <> nil) then
    GlobalFreePtr(FDIBBits);
  FDIBInfo := nil;
  FDIBBits := nil;
end;

// Create DIB from Bitmap
procedure TGIFSubImage.BitmapToDIB(ABitmap: TBitmap);
var
  PixelFormat		: TPixelFormat;

{$IFDEF VER90}
  SrcColors		,
  DstColors		: WORD;

  // From Delphi 3.02 graphics.pas
  // There is a bug in the ByteSwapColors from Delphi 3.0
  procedure ByteSwapColors(var Colors; Count: Integer);
  var   // convert RGB to BGR and vice-versa.  TRGBQuad <-> TPaletteEntry
    SysInfo: TSystemInfo;
  begin
    GetSystemInfo(SysInfo);
    asm
          MOV   EDX, Colors
          MOV   ECX, Count
          DEC   ECX
          JS    @@END
          LEA   EAX, SysInfo
          CMP   [EAX].TSystemInfo.wProcessorLevel, 3
          JE    @@386
    @@1:  MOV   EAX, [EDX+ECX*4]
          BSWAP EAX
          SHR   EAX,8
          MOV   [EDX+ECX*4],EAX
          DEC   ECX
          JNS   @@1
          JMP   @@END
    @@386:
          PUSH  EBX
    @@2:  XOR   EBX,EBX
          MOV   EAX, [EDX+ECX*4]
          MOV   BH, AL
          MOV   BL, AH
          SHR   EAX,16
          SHL   EBX,8
          MOV   BL, AL
          MOV   [EDX+ECX*4],EBX
          DEC   ECX
          JNS   @@2
          POP   EBX
      @@END:
    end;
  end;
{$ENDIF}

begin
  if (ABitmap.Handle = 0) then
    Error(sInvalidBitmap);
  FreeDIB;

  // Make sure that the DIB is returned in a supported format
  PixelFormat := GetPixelFormat(ABitmap);
  if not(PixelFormat in SupportedPixelformats) then
    PixelFormat := pf8bit;

  // Get header- and pixel data size for pf8bit format
  InternalGetDIBSizes(ABitmap.Handle, FDIBInfoSize, FDIBBitsSize, PixelFormat);

  // Allocate TBitmapInfo structure
  GetMem(FDIBInfo, FDIBInfoSize);
  try
    // Allocate pixel buffer
    FDIBBits := GlobalAllocPtr(GMEM_MOVEABLE, FDIBBitsSize);
    if (FDIBBits = nil) then
      raise EOutOfMemory.Create(sOutOfMemDIB);
    // Get pixel data in pf8bit format
    if not(InternalGetDIB(ABitmap.Handle, ABitmap.Palette, FDIBInfo^, FDIBBits^, PixelFormat)) then
      Error(sDIBCreate);

{$IFDEF VER90}
    // ***FIXME***
    // Adjust for Delphi 2.x braindead palette behaviour:
    //
    // Copies the colors from a palette to a BitmapInfo structure.
    // When converting a DIB or DDB, the palette is realized and can therefore
    // not be used for our purpose; The first and last 10 palette entries are
    // allways set to the system palette colors no matter what palette we
    // attempt to define!
    // To circumvent this problem we import the palette to the DIB ourself.
    // For some strange reason this problem only occurs under Delphi 2.x.


    // Find number of colors defined by palette
    if (ABitmap.Palette = 0) or
      (GetObject(ABitmap.Palette, sizeof(SrcColors), @SrcColors) = 0) or
      (SrcColors = 0) then
      exit;
    // Determine how many colors there are room for in DIB header
    DstColors := FDIBInfo^.bmiHeader.biClrUsed;
    if (DstColors = 0) then
      DstColors := 1 SHL FDIBInfo^.bmiHeader.biBitCount;
    // Don't copy any more colors than there are room for
    if (DstColors <> 0) and (DstColors < SrcColors) then
      SrcColors := DstColors;

    // Copy all colors...
    GetPaletteEntries(ABitmap.Palette, 0, SrcColors, FDIBInfo^.bmiColors[0]);
    // ...and convert BGR to RGB
    ByteSwapColors(FDIBInfo^.bmiColors[0], SrcColors);

    // Finally zero any unused entried
    if (SrcColors < DstColors) then
      FillChar(pointer(LongInt(@FDIBInfo^.bmiColors)+SizeOf(TRGBQuad)*SrcColors)^,
        DstColors - SrcColors, 0);
{$ENDIF}

  except
    FreeDIB;
    raise;
  end;
end;

// Convert DIB created by BitmapToDIB back to a TBitmap
procedure TGIFSubImage.DIBToBitmap(ABitmap: TBitmap);
var
  Stream		: TMemoryStream;
  FileSize		: longInt;
  BitmapFileHeader	: TBitmapFileHeader;

  procedure ImportPalette(Palette: HPalette);
  type
    PalArray		=  array[byte] of TPaletteEntry;
  var
    Pal			: PalArray;
  begin
    GetPaletteEntries(Palette, 0, 256, pal);
  end;

begin
  if (FDIBInfo = nil) or (FDIBBits = nil) then
    exit;
  Stream := TMemoryStream.Create;
  try
    // Make room in stream for a TBitmapInfo and pixel data
    FileSize := sizeof(TBitmapFileHeader) + FDIBInfoSize + FDIBBitsSize;
    Stream.SetSize(FileSize);
    // Initialize file header
    FillChar(BitmapFileHeader, sizeof(TBitmapFileHeader), 0);
    with BitmapFileHeader do
    begin
      bfType := $4D42; // 'BM' = Windows BMP signature
      bfSize := FileSize; // File size (not needed)
      bfOffBits := sizeof(TBitmapFileHeader) + FDIBInfoSize; // Offset of pixel data
    end;
    // Save file header
    Stream.Write(BitmapFileHeader, sizeof(TBitmapFileHeader));
    // Save TBitmapInfo structure
    Stream.Write(FDIBInfo^, FDIBInfoSize);
    // Save pixel data
    Stream.Write(FDIBBits^, FDIBBitsSize);

    // Rewind and load DIB into bitmap
    Stream.Position := 0;
    ABitmap.LoadFromStream(Stream);
    ImportPalette(ABitmap.Palette);
  finally
    Stream.Free;
  end;
end;

function TGIFSubImage.GetScanLine(Row: Integer): PChar;
begin
  if (FDIBBits = nil) then
    Error(sNoDIB);
  with FDIBInfo^.bmiHeader do
  begin
    if (Row < 0) or (Row >= Height) then
      raise EInvalidGraphicOperation.Create(SScanLine);
    GDIFlush;

    if biHeight > 0 then  // bottom-up DIB
      Row := biHeight - Row - 1;
    Integer(Result) := Integer(FDIBBits) + Row * AlignBit(biWidth, biBitCount, 32);
  end;
end;

function TGIFSubImage.GetEmpty: Boolean;
begin
  Result := ((FData = nil) or (FDataSize = 0) or (Height = 0) or (Width = 0));
   // and (ColorMap.Count = 0); Why this?
end;

function TGIFSubImage.GetPalette: HPALETTE;
begin
  if (FBitmap <> nil) and (FBitmap.Palette <> 0) then
    // Use bitmaps own palette if possible
    Result := FBitmap.Palette
  else if (FLocalPalette <> 0) then
    // Or a previously exported local palette
    Result := FLocalPalette
  else if (Image.DoDither) then
  begin
    // or create a new dither palette
    FLocalPalette := WebPalette;
    Result := FLocalPalette;
  end
  else if (ColorMap.Count > 0) then
  begin
    // or create a new if first time
    FLocalPalette := ColorMap.ExportPalette;
    Result := FLocalPalette;
  end else
    // Use global palette if everything else fails
    Result := Image.Palette;
end;

procedure TGIFSubImage.SetPalette(Value: HPalette);
var
  NeedNewBitmap		: boolean;
begin
  if (Value <> FLocalPalette) then
  begin
    // Zap old palette
    if (FLocalPalette <> 0) then
      DeleteObject(FLocalPalette);
    // Zap bitmap unless new palette is same as bitmaps own
    NeedNewBitmap := (FBitmap <> nil) and (Value <> FBitmap.Palette);
    if (NeedNewBitmap) then
      FreeBitmap;

    // Use new palette
    FLocalPalette := Value;
    if (NeedNewBitmap) then
    begin
      // Need to create new bitmap and repaint
      Image.PaletteModified := True;
      Image.Changed(Self);
    end;
  end;
end;

procedure TGIFSubImage.NewImage;
begin
  if (FData <> nil) then
    FreeMem(FData);
  FDataSize := Height * Width;
  if (FDataSize <> 0) then
    GetMem(FData, FDataSize)
  else
    FData := nil;
end;

procedure TGIFSubImage.FreeBitmap;
begin
  if (FBitmap <> nil) then
  begin
    FBitmap.Free;
    FBitmap := nil;
  end;
end;

procedure TGIFSubImage.FreeMask;
begin
  if (FMask <> 0) then
  begin
    DeleteObject(FMask);
    FMask := 0;
  end;
  FNeedMask := True;
end;

function TGIFSubImage.HasMask: boolean;
begin
  if (FNeedMask) and (Transparent) then
  begin
    // Zap old bitmap
    FreeBitmap;
    // Create new bitmap and mask
    GetBitmap;
  end;
  Result := (FMask <> 0);
end;

function TGIFSubImage.GetBounds(Index: integer): WORD;
begin
  case (Index) of
    1: Result := FImageDescriptor.Left;
    2: Result := FImageDescriptor.Top;
    3: Result := FImageDescriptor.Width;
    4: Result := FImageDescriptor.Height;
  else
    Result := 0; // To avoid compiler warnings
  end;
end;

procedure TGIFSubImage.SetBounds(Index: integer; Value: WORD);
begin
  case (Index) of
    1: FImageDescriptor.Left := Value;
    2: FImageDescriptor.Top := Value;
    3: FImageDescriptor.Width := Value;
    4: FImageDescriptor.Height := Value;
  end;
end;

procedure TGIFSubImage.NewBitmap;
begin
  FreeBitmap;
  FBitmap := TBitmap.Create;
end;

{$RANGECHECKS OFF}
function TGIFSubImage.DoGetDitherBitmap: TBitmap;
type
  TErrors		= array[0..0] of LongInt;
  PErrors		= ^TErrors;

const
  // Integer arithmetic scaling factor
  // All math operations are scaled by this factor to avoid using floating point
  FS_SCALE		= 1024;

var
  LinesRead		: Integer;
  DestScanLine		,
  Src			: PChar;
  PtrInc		: Integer;

  ThisErrorR		,
  ThisErrorG		,
  ThisErrorB		,
  NextErrorR		,
  NextErrorG		,
  NextErrorB		: PErrors;
  Error			: LongInt;
  SR, SG, SB		: LongInt;
  R, G, B		: byte;
  Direction		: integer;
  Row, Col		: integer;
  Color			: TGIFColor;
  ColMap		: PColorMap;
  Index			: byte;
  TransparentIndex	: byte;
  IsTransparent		: boolean;
  WasTransparent	: boolean;
  i			: integer;

  MaskBits		: PChar;
  MaskDest		: PChar;
  MaskRow		: PChar;
  MaskRowWidth		,
  MaskRowBitWidth	: integer;
  Bit			,
  RightBit		: BYTE;

  procedure SwapError(var P1, P2: PErrors);
  var
    P			: PErrors;
  begin
    P:= P1;
    P1:= P2;
    P2:= P;
  end;

begin
  Result := TBitmap.Create;

  // Set bitmap width and height
  Result.Width := Width;
  Result.Height := Height;
  // Set the bitmap pixel format
  SafeSetPixelFormat(Result, pf8bit); // 8 bits per pixel/256 colors
  // Build and copy palette to bitmap
  Result.Palette := CopyPalette(Palette);

  if (Empty) then
    exit;

  // Get DIB buffer for scanline operations
{$IFDEF VER90}
  BitmapToDIB(Result);
{$ENDIF}
  try

    // Determine if this image is transparent
    IsTransparent := FNeedMask and Transparent;
    WasTransparent := False;
    FNeedMask := False;
    TransparentIndex := 0;
    if (FMask = 0) and (IsTransparent) then
    begin
      IsTransparent := True;
      TransparentIndex := GraphicControlExtension.TransparentColorIndex;
    end;

    // Allocate bit buffer for transparency mask
    if (IsTransparent) then
    begin
      MaskRowWidth := ((Width+15) DIV 16) * 2;
      MaskRowBitWidth := (Width+7) DIV 8;
      RightBit := $01 SHL ((8 - (Width AND $0007)) AND $0007);
      GetMem(MaskBits, MaskRowWidth * Height);
      FillChar(MaskBits^, MaskRowWidth * Height, 0);
      IsTransparent := (MaskBits <> nil);
    end else
    begin
      MaskBits := nil;
      MaskRowWidth := 0;
      MaskRowBitWidth := 0;
      RightBit := $00;
    end;

    try
      (* Initialize Floyd-Steinberg error vectors. *)
      GetMem(ThisErrorR, sizeof(LongInt)*(Width+2));
      GetMem(ThisErrorG, sizeof(LongInt)*(Width+2));
      GetMem(ThisErrorB, sizeof(LongInt)*(Width+2));
      GetMem(NextErrorR, sizeof(LongInt)*(Width+2));
      GetMem(NextErrorG, sizeof(LongInt)*(Width+2));
      GetMem(NextErrorB, sizeof(LongInt)*(Width+2));
      try
        FillChar(ThisErrorR^, sizeof(LongInt)*(Width+2), 0);
        FillChar(ThisErrorG^, sizeof(LongInt)*(Width+2), 0);
        FillChar(ThisErrorB^, sizeof(LongInt)*(Width+2), 0);

{$IFDEF VER90}
        DestScanline := GetScanLine(0);
        PtrInc := Integer(GetScanLine(1)) - Integer(DestScanline);
{$ELSE}
        DestScanline := Result.ScanLine[0];
        PtrInc := Integer(Result.ScanLine[1]) - Integer(DestScanline);
{$ENDIF}
        MaskRow := MaskBits;

        LinesRead := 0;
        Src := FData;
        Direction := 1;

        ColMap := ActiveColorMap.Data;

        while (LinesRead < Height) do
        begin
          if (LinesRead MOD 32 = 0) then
            Image.Progress(Self, psRunning, LinesRead * 100 DIV Height, False, Rect(0,0,0,0), sProgressRendering);

          FillChar(NextErrorR^, sizeof(LongInt)*(Width+2), 0);
          FillChar(NextErrorG^, sizeof(LongInt)*(Width+2), 0);
          FillChar(NextErrorB^, sizeof(LongInt)*(Width+2), 0);

          if (Direction = 1) then
          begin
            Col := 0;
            MaskDest := MaskRow;
            Bit := $80;
          end else
          begin
            Col := Width-1;
            MaskDest := MaskRow + MaskRowBitWidth-1;
            Bit := RightBit;
          end;

          while (Col < Width) and (Col >= 0) do
          begin
            Index := ord(Src[Col]);
            Color := ColMap[ord(Index)];
            if (IsTransparent and (Index = TransparentIndex)) then
            begin
              MaskDest^ := char(byte(MaskDest^) OR Bit);
              WasTransparent := True;
              DestScanline[Col] := char(Round(Color.Blue / 51.0)+6*Round(Color.Green / 51.0)+36*Round(Color.Red / 51.0));
            end else
            begin
              Color := ColMap[ord(Index)];
              (* Use Floyd-Steinberg errors to adjust actual color. *)
              SR := Color.Red + ThisErrorR[col + 1] DIV FS_SCALE;
              R := round(SR / 51.0);
              if (R < 0) then
                R := 0
              else if (R > 5) then
                R := 5;

              SG := Color.Green + ThisErrorG[col + 1] DIV FS_SCALE;
              G := round(SG / 51.0);
              if (G < 0) then
                G := 0
              else if (G > 5) then
                G := 5;

              SB := Color.Blue + ThisErrorB[col + 1] DIV FS_SCALE;
              B := round(SB / 51.0);
              if (B < 0) then
                B := 0
              else if (B > 5) then
                B := 5;

              (* Map dithered pixel to netscape color cube *)
              DestScanline[Col] := char(B + 6*G + 36*R);

              (* Propagate Floyd-Steinberg error terms. *)
              if (Direction = 1) then
              begin
                Error := (SR - R*51) * FS_SCALE;
                ThisErrorR[col+2] := ThisErrorR[col+2] + (Error * 7) DIV 16;
                NextErrorR[col  ] := NextErrorR[col  ] + (Error * 3) DIV 16;
                NextErrorR[col+1] := NextErrorR[col+1] + (Error * 5)  DIV 16;
                NextErrorR[col+2] := NextErrorR[col+2] + Error DIV 16;
                Error := (SG - G*51) * FS_SCALE;
                ThisErrorG[col+2] := ThisErrorG[col+2] + (Error * 7) DIV 16;
                NextErrorG[col  ] := NextErrorG[col  ] + (Error * 3) DIV 16;
                NextErrorG[col+1] := NextErrorG[col+1] + (Error * 5)  DIV 16;
                NextErrorG[col+2] := NextErrorG[col+2] + Error DIV 16;
                Error := (SB - B*51) * FS_SCALE;
                ThisErrorB[col+2] := ThisErrorB[col+2] + (Error * 7) DIV 16;
                NextErrorB[col  ] := NextErrorB[col  ] + (Error * 3) DIV 16;
                NextErrorB[col+1] := NextErrorB[col+1] + (Error * 5)  DIV 16;
                NextErrorB[col+2] := NextErrorB[col+2] + Error DIV 16;
              end else
              begin
                Error := (SR - R*51) * FS_SCALE;
                ThisErrorR[col  ] := ThisErrorR[col  ] + (Error * 7) DIV 16;
                NextErrorR[col+2] := NextErrorR[col+2] + (Error * 3) DIV 16;
                NextErrorR[col+1] := NextErrorR[col+1] + (Error * 5)  DIV 16;
                NextErrorR[col  ] := NextErrorR[col  ] + Error DIV 16;
                Error := (SG - G*51) * FS_SCALE;
                ThisErrorG[col  ] := ThisErrorG[col  ] + (Error * 7) DIV 16;
                NextErrorG[col+2] := NextErrorG[col+2] + (Error * 3) DIV 16;
                NextErrorG[col+1] := NextErrorG[col+1] + (Error * 5)  DIV 16;
                NextErrorG[col  ] := NextErrorG[col  ] + Error DIV 16;
                Error := (SB - B*51) * FS_SCALE;
                ThisErrorB[col  ] := ThisErrorB[col  ] + (Error * 7) DIV 16;
                NextErrorB[col+2] := NextErrorB[col+2] + (Error * 3) DIV 16;
                NextErrorB[col+1] := NextErrorB[col+1] + (Error * 5)  DIV 16;
                NextErrorB[col  ] := NextErrorB[col  ] + Error DIV 16;
              end;
            end;
            if (IsTransparent) then
            begin
              if (Direction = 1) then
              begin
                Bit := Bit SHR 1;
                if (Bit = $00) then
                begin
                  Bit := $80;
                  inc(MaskDest, 1);
                end;
              end else
              begin
                Bit := Bit SHL 1;
                if (Bit = $00) then
                begin
                  Bit := $01;
                  inc(MaskDest, -1);
                end;
              end;
            end;
            Inc(Col, Direction);
          end;

          SwapError(ThisErrorR, NextErrorR);
          SwapError(ThisErrorG, NextErrorG);
          SwapError(ThisErrorB, NextErrorB);

          Direction := -Direction;

          Inc(DestScanline, PtrInc);
          Inc(Src, Width);
          Inc(LinesRead);
          if (IsTransparent) then
            Inc(MaskRow, MaskRowWidth);
        end;
      finally
        FreeMem(ThisErrorR);
        FreeMem(ThisErrorG);
        FreeMem(ThisErrorB);
        FreeMem(NextErrorR);
        FreeMem(NextErrorG);
        FreeMem(NextErrorB);
      end;
      // Transparent paint needs a mask bitmap
      if (IsTransparent) and (WasTransparent) then
        FMask := CreateBitmap(Width, Height, 1, 1, MaskBits);
    finally
      if (MaskBits <> nil) then
        FreeMem(MaskBits);
    end;

{$IFDEF VER90}
    DIBToBitmap(Result);
{$ENDIF}
  finally
    // Free DIB buffer used for scanline operations
{$IFDEF VER90}
    FreeDIB;
{$ENDIF}
  end;
end;
{$RANGECHECKS ON}

function TGIFSubImage.DoGetBitmap: TBitmap;
var
  LinesPerCall		,
  LinesRead		: Integer;
  DestScanLine		,
  Src			: PChar;
  PtrInc		: Integer;
  TransparentIndex	: byte;
  IsTransparent		: boolean;
  WasTransparent	: boolean;

  MaskBits		: PChar;
  MaskDest		: PChar;
  MaskRow		: PChar;
  MaskRowWidth		: integer;
  Row, Col		: integer;
  Bit			: integer;
begin
  Result := TBitmap.Create;

  // Set bitmap width and height
  Result.Width := Width;
  Result.Height := Height;
  // Set the bitmap pixel format
  SafeSetPixelFormat(Result, pf8bit); // 8 bits per pixel/256 colors
  // Build and copy palette to bitmap
  Result.Palette := CopyPalette(Palette);

  if (Empty) then
    exit;

  // Get DIB buffer for scanline operations
{$IFDEF VER90}
  BitmapToDIB(Result);
{$ENDIF}
  try

    // Determine if this image is transparent
    IsTransparent := FNeedMask and Transparent;
    WasTransparent := False;
    FNeedMask := False;
    TransparentIndex := 0;
    if (FMask = 0) and (IsTransparent) then
    begin
      IsTransparent := True;
      TransparentIndex := GraphicControlExtension.TransparentColorIndex;
    end;
    // Allocate bit buffer for transparency mask
    if (IsTransparent) then
    begin
      MaskRowWidth := ((Width+15) DIV 16) * 2;
      GetMem(MaskBits, MaskRowWidth * Height);
      FillChar(MaskBits^, MaskRowWidth * Height, 0);
      IsTransparent := (MaskBits <> nil);
    end else
    begin
      MaskBits := nil;
      MaskRowWidth := 0;
    end;

    try

{$IFDEF VER90}
      DestScanline := GetScanLine(0);
      PtrInc := Integer(GetScanLine(1)) - Integer(DestScanline);
{$ELSE}
      DestScanline := Result.ScanLine[0];
      PtrInc := Integer(Result.ScanLine[1]) - Integer(DestScanline);
{$ENDIF}
      if (PtrInc > 0) and ((PtrInc AND 3) = 0) then
         // If no dword padding is required and output bitmap is top-down
        LinesPerCall := Height // Read multiple rows per call
      else
        LinesPerCall := 1; // Otherwise read one row at a time

      LinesRead := 0;
      Src := FData;
      MaskRow := MaskBits;
      while (LinesRead < Height) do
      begin
        if (LinesRead MOD 32 = 0) then
          Image.Progress(Self, psRunning, LinesRead * 100 DIV Height, False, Rect(0,0,0,0), sProgressRendering);
        Move(Src^, DestScanline^, LinesPerCall * Width);
        Inc(DestScanline, PtrInc * LinesPerCall);
        Inc(LinesRead, LinesPerCall);

        if (IsTransparent) then
        begin
          for Row := 0 to LinesPerCall-1 do
          begin
            Bit := $80;
            MaskDest := MaskRow;
            for Col := 0 to Width-1 do
            begin
              if (Src[Col] = char(TransparentIndex)) then
              begin
                MaskDest^ := char(byte(MaskDest^) OR Bit);
                WasTransparent := True;
              end;

              Bit := Bit SHR 1;
              if (Bit = $00) then
              begin
                Bit := $80;
                inc(MaskDest);
              end;
            end;
            Inc(Src, Width);
            Inc(MaskRow, MaskRowWidth);
          end;
        end else
          Inc(Src, Width * LinesPerCall);
      end;

      // Transparent paint needs a mask bitmap
      if (IsTransparent) and (WasTransparent) then
        FMask := CreateBitmap(Width, Height, 1, 1, MaskBits);
    finally
      if (MaskBits <> nil) then
        FreeMem(MaskBits);
    end;
{$IFDEF VER90}
    DIBToBitmap(Result);
{$ENDIF}
  finally
    // Free DIB buffer used for scanline operations
{$IFDEF VER90}
    FreeDIB;
{$ENDIF}
  end;
end;

function TGIFSubImage.GetBitmap: TBitmap;
var
  n			: integer;
begin
  Result := FBitmap;
  if (Result <> nil) or (Empty) then
    Exit;

  try
    Image.Progress(Self, psStarting, 0, False, Rect(0,0,0,0), sProgressRendering);
    try

      if (Image.DoDither) then
        // Create dithered bitmap
        FBitmap := DoGetDitherBitmap
      else
        // Create "regular" bitmap
        FBitmap := DoGetBitmap;

      Result := FBitmap;

    finally
      if ExceptObject = nil then
        n := 100
      else
        n := 0;
      Image.Progress(Self, psEnding, n, Image.PaletteModified, Rect(0,0,0,0),
        sProgressRendering);
      // Make sure new palette gets realized, in case OnProgress event didn't.
//      if Image.PaletteModified then
//        Image.Changed(Self);
    end;
  except
    on EAbort do ;   // OnProgress can raise EAbort to cancel image load
  end;

end;

procedure TGIFSubImage.SetBitmap(Value: TBitmap);
begin
  FreeBitmap;
  if (Value <> nil) then
    Assign(Value);
end;

function TGIFSubImage.GetActiveColorMap: TGIFColorMap;
begin
  if (ColorMap.Count > 0) or (Image.GlobalColorMap.Count = 0) then
    Result := ColorMap
  else
    Result := Image.GlobalColorMap;
end;

function TGIFSubImage.GetInterlaced: boolean;
begin
  Result := (FImageDescriptor.PackedFields AND idInterlaced) <> 0;
end;

procedure TGIFSubImage.SetInterlaced(Value: boolean);
begin
  if (Value) then
    FImageDescriptor.PackedFields := FImageDescriptor.PackedFields OR idInterlaced
  else
    FImageDescriptor.PackedFields := FImageDescriptor.PackedFields AND NOT(idInterlaced);
end;

function TGIFSubImage.GetVersion: TGIFVersion;
var
  v			: TGIFVersion;
  i			: integer;
begin
  if (ColorMap.Optimized) then
    Result := gv89a
  else
    Result := inherited GetVersion;
  i := 0;
  while (Result < high(TGIFVersion)) and (i < FExtensions.Count) do
  begin
    v := FExtensions[i].Version;
    if (v > Result) then
      Result := v;
  end;
end;

function TGIFSubImage.GetColorResolution: integer;
begin
  Result := ColorMap.BitsPerPixel-1;
end;

function TGIFSubImage.GetBitsPerPixel: integer;
begin
  Result := ColorMap.BitsPerPixel;
end;

function TGIFSubImage.GetBoundsRect: TRect;
begin
  Result := Rect(FImageDescriptor.Left,
    FImageDescriptor.Top,
    FImageDescriptor.Left+FImageDescriptor.Width,
    FImageDescriptor.Top+FImageDescriptor.Height);
end;

function TGIFSubImage.GetClientRect: TRect;
begin
  Result := Rect(0, 0, FImageDescriptor.Width, FImageDescriptor.Height);
end;

function TGIFSubImage.GetPixel(x, y: integer): BYTE;
begin
  if (x < 0) or (x > Width-1) or (y < 0) or (y > Height-1) then
    Error(sBadPixelCoordinates);
  Result := BYTE(PChar(longInt(FData) + y * Width + x)^);
end;

procedure TGIFSubImage.Prepare;
var
  Pack			: BYTE;
begin
  Pack := FImageDescriptor.PackedFields;
  if (ColorMap.Count > 0) then
  begin
    Pack := idLocalColorTable;
    if (ColorMap.Optimized) then
      Pack := Pack OR idSort;
    Pack := (Pack AND NOT(idColorTableSize)) OR (ColorResolution AND idColorTableSize);
  end else
    Pack := Pack AND NOT(idLocalColorTable OR idSort OR idColorTableSize);
  FImageDescriptor.PackedFields := Pack;
end;

(*******************************************************************************
**
**			THashTable
**
*******************************************************************************)
const
  HashKeyBits		= 13;			// Max number of bits per Hash Key
  GIFCodeBits		= 12;			// Max number of bits per GIF token code

  HashSize		= 8009;			// Size of hash table
  						// Must be prime
                                                // Must be > than HashMaxCode
                                                // Must be < than HashMaxKey

  StackSize		= (2 SHL GIFCodeBits);	// Size of decompression stack
  TableSize		= (1 SHL GIFCodeBits);	// Size of decompression table

  HashKeyMax		= (1 SHL HashKeyBits)-1;// Max hash key value
  						// 13 bits = 8191
  GIFCodeMax		= (1 SHL GIFCodeBits)-1;// Max GIF token code
  						// 12 bits = 4095

  TableMaxMaxCode	= (1 SHL GIFCodeBits);	//
  TableMaxFill		= TableMaxMaxCode-1;	// Clear table when it fills to this point
  						// Must be <= GIFCodeMax

  HashKeyMask		= HashKeyMax;		// $1FFF
  GIFCodeMask		= GIFCodeMax;		// $0FFF

  HashEmpty		= $000FFFFF;		// 20 bits

type
(******************************************************************************
 * A Hash Key is 20 bits wide.
 * The lower 8 bits are the postfix character (the new pixel).
 * The upper 12 bits are the prefix code (the GIF token).
 ******************************************************************************)
  // A KeyInt must be able to represent the integer values -1..(2^20)-1
  KeyInt = longInt;	// 32 bits
  CodeInt = SmallInt;	// 16 bits

  THashArray = array[0..HashSize-1] of KeyInt;
  PHashArray = ^THashArray;

  THashTable = class
{$ifdef DEBUG_HASHPERFORMANCE}
    CountLookupFound: longInt;
    CountMissFound: longInt;
    CountLookupNotFound: longInt;
    CountMissNotFound: longInt;
{$endif}
    HashTable: PHashArray;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Insert(Key: KeyInt; Code: CodeInt);
    function Lookup(Key: KeyInt): CodeInt;
  end;

function HashKey(Key: KeyInt): CodeInt;
begin
  Result := ((Key SHR (GIFCodeBits-8)) XOR Key) MOD HashSize;
end;

function NextHashKey(HKey: CodeInt): CodeInt;
var
  disp		: CodeInt;
begin
  (*
  ** secondary hash (after G. Knott)
  *)
  disp := HashSize - HKey;
  if (HKey = 0) then
    disp := 1;
//  disp := 13;		// disp should be prime relative to HashSize, but
			// it doesn't seem to matter here...
  dec(HKey, disp);
  if (HKey < 0) then
    inc(HKey, HashSize);
  Result := HKey;
end;


constructor THashTable.Create;
begin
  if ($FFFFFFFF <> -1) then
    halt; // Error: Implementation assumes $FFFFFFFF = -1

  inherited Create;
  GetMem(HashTable, sizeof(THashArray));
  Clear;
{$ifdef DEBUG_HASHPERFORMANCE}
  CountLookupFound := 0;
  CountMissFound := 0;
  CountLookupNotFound := 0;
  CountMissNotFound := 0;
{$endif}
end;

destructor THashTable.Destroy;
begin
{$ifdef DEBUG_HASHPERFORMANCE}
  ShowMessage(
    Format('Found: %d  HitRate: %.2f',
      [CountLookupFound, (CountLookupFound+1)/(CountMissFound+1)])+#13+
    Format('Not found: %d  HitRate: %.2f',
      [CountLookupNotFound, (CountLookupNotFound+1)/(CountMissNotFound+1)]));
{$endif}
  FreeMem(HashTable);
  inherited Destroy;
end;

// Clear hash table and fill with empty slots (doh!)
procedure THashTable.Clear;
{$ifdef DEBUG_HASHFILLFACTOR}
var
  i			,
  Count			: longInt;
{$endif}
begin
{$ifdef DEBUG_HASHFILLFACTOR}
  Count := 0;
  for i := 0 to HashSize-1 do
    if (HashTable[i] SHR GIFCodeBits <> HashEmpty) then
      inc(Count);
  ShowMessage(format('Size: %d, Filled: %d, Rate %.4f',
    [HashSize, Count, Count/HashSize]));
{$endif}

  FillChar(HashTable^, sizeof(THashArray), $FF);
end;

// Insert new key/value pair into hash table
procedure THashTable.Insert(Key: KeyInt; Code: CodeInt);
var
  HKey			: CodeInt;
begin
  // Create hash key from prefix string
  HKey := HashKey(Key);

  // Scan for empty slot
  // while (HashTable[HKey] SHR GIFCodeBits <> HashEmpty) do { Unoptimized }
  while (HashTable[HKey] AND (HashEmpty SHL GIFCodeBits) <> (HashEmpty SHL GIFCodeBits)) do { Optimized }
    HKey := NextHashKey(HKey);
  // Fill slot with key/value pair
  HashTable[HKey] := (Key SHL GIFCodeBits) OR (Code AND GIFCodeMask);
end;

// Search for key in hash table.
// Returns value if found or -1 if not
function THashTable.Lookup(Key: KeyInt): CodeInt;
var
  HKey			: CodeInt;
  HTKey			: KeyInt;
{$ifdef DEBUG_HASHPERFORMANCE}
  n			: LongInt;
{$endif}
begin
  // Create hash key from prefix string
  HKey := HashKey(Key);

{$ifdef DEBUG_HASHPERFORMANCE}
  n := 0;
{$endif}
  // Scan table for key
  // HTKey := HashTable[HKey] SHR GIFCodeBits; { Unoptimized }
  Key := Key SHL GIFCodeBits; { Optimized }
  HTKey := HashTable[HKey] AND (HashEmpty SHL GIFCodeBits); { Optimized }
  // while (HTKey <> HashEmpty) do { Unoptimized }
  while (HTKey <> HashEmpty SHL GIFCodeBits) do { Optimized }
  begin
    if (Key = HTKey) then
    begin
      // Extract and return value
      Result := HashTable[HKey] AND GIFCodeMask;
{$ifdef DEBUG_HASHPERFORMANCE}
      inc(CountLookupFound);
      inc(CountMissFound, n);
{$endif}
      exit;
    end;
{$ifdef DEBUG_HASHPERFORMANCE}
    inc(n);
{$endif}
    // Try next slot
    HKey := NextHashKey(HKey);
    // HTKey := HashTable[HKey] SHR GIFCodeBits; { Unoptimized }
    HTKey := HashTable[HKey] AND (HashEmpty SHL GIFCodeBits); { Optimized }
  end;
  // Found empty slot - key doesn't exist
  Result := -1;
{$ifdef DEBUG_HASHPERFORMANCE}
  inc(CountLookupNotFound);
  inc(CountMissNotFound, n);
{$endif}
end;

procedure TGIFSubImage.Decompress(Stream: TStream);
var
  table0		: array[0..TableSize-1] of integer;
  table1		: array[0..TableSize-1] of integer;
  firstcode, oldcode	: integer;
  buf			: array[0..257] of BYTE;

  Dest			: PChar;
//  b			: BYTE;
  v			,
  xpos, ypos, pass	: integer;

  stack			: array[0..StackSize-1] of integer;
  Source			: ^integer;
  BitsPerCode		: integer;		// number of CodeTableBits/code
  InitialBitsPerCode	: BYTE;

  MaxCode		: CodeInt;		// maximum code, given BitsPerCode
  MaxCodeSize		: integer;
  ClearCode		: integer;		// Special code to signal "Clear table"
  EOFCode		: integer;		// Special code to signal EOF
  step			: integer;
  i			: integer;

  StartBit		,			// Index of bit buffer start
  LastBit		,			// Index of last bit in buffer
  LastByte		: integer;		// Index of last byte in buffer
  get_done		,
  return_clear		,
  ZeroBlock		: boolean;
{$ifdef DEBUG_DECOMPRESSPERFORMANCE}
  TimeStartDecompress	: LongInt;
  TimeStopDecompress	: LongInt;
{$endif}

  function nextCode(BitsPerCode: integer): integer;
  const
    masks: array[0..15] of integer =
      ($0000, $0001, $0003, $0007,
       $000f, $001f, $003f, $007f,
       $00ff, $01ff, $03ff, $07ff,
       $0fff, $1fff, $3fff, $7fff);
  var
    StartIndex, EndIndex		: integer;
    ret			: integer;
    EndBit		: integer;
    count		: BYTE;
  begin
    if (return_clear) then
    begin
      return_clear := FALSE;
      Result := ClearCode;
      exit;
    end;

    EndBit := StartBit + BitsPerCode;

    if (EndBit >= LastBit) then
    begin
      if (get_done) then
      begin
        if (StartBit >= LastBit) then
          Warning(gsWarning, sDecodeTooFewBits);
        Result := -1;
        exit;
      end;
      buf[0] := buf[LastByte-2];
      buf[1] := buf[LastByte-1];

      if (Stream.Read(count, 1) <> 1) then
      begin
        Result := -1;
        exit;
      end;
      if (count = 0) then
      begin
        ZeroBlock := True;
        get_done := TRUE;
      end else
      begin
        // Handle premature end of file
        if (Stream.Size - Stream.Position < Count) then
        begin
          Warning(gsWarning, sOutOfData);
          // Not enough data left - Just read as much as we can get
          Count := Stream.Size - Stream.Position;
        end;
        if (Count <> 0) then
          ReadCheck(Stream, Buf[2], Count);
      end;

      LastByte := 2 + count;
      StartBit := (StartBit - LastBit) + 16;
      LastBit := LastByte * 8;

      EndBit := StartBit + BitsPerCode;
    end;

    EndIndex := EndBit DIV 8;
    StartIndex := StartBit DIV 8;

    ASSERT(StartIndex <= high(buf), 'StartIndex too large');
    if (StartIndex = EndIndex) then
      ret := buf[StartIndex]
    else
      if (StartIndex + 1 = EndIndex) then
        ret := buf[StartIndex] OR (buf[StartIndex+1] SHL 8)
      else
        ret := buf[StartIndex] OR (buf[StartIndex+1] SHL 8) OR (buf[StartIndex+2] SHL 16);

    ret := (ret SHR (StartBit AND $0007)) AND masks[BitsPerCode];

    Inc(StartBit, BitsPerCode);

    Result := ret;
  end;

  function NextLZW: integer;
  var
    code, incode	: integer;
    i			: integer;
    b			: BYTE;
  begin
    code := nextCode(BitsPerCode);
    while (code >= 0) do
    begin
      if (code = ClearCode) then
      begin
        ASSERT(ClearCode < TableSize, 'ClearCode too large');
        for i := 0 to ClearCode-1 do
        begin
          table0[i] := 0;
          table1[i] := i;
        end;
        for i := ClearCode to TableSize-1 do
        begin
          table0[i] := 0;
          table1[i] := 0;
        end;
        BitsPerCode := InitialBitsPerCode+1;
        MaxCodeSize := 2 * ClearCode;
        MaxCode := ClearCode + 2;
        Source := @stack;
        repeat
          firstcode := nextCode(BitsPerCode);
          oldcode := firstcode;
        until (firstcode <> ClearCode);

        Result := firstcode;
        exit;
      end;
      if (code = EOFCode) then
      begin
        Result := -2;
        if (ZeroBlock) then
          exit;
        // Eat rest of data blocks
        if (Stream.Read(b, 1) <> 1) then
          exit;
        while (b <> 0) do
        begin
          Stream.Seek(b, soFromCurrent);
          if (Stream.Read(b, 1) <> 1) then
            exit;
        end;
        exit;
      end;

      incode := code;

      if (code >= MaxCode) then
      begin
        Source^ := firstcode;
        Inc(Source);
        code := oldcode;
      end;

      ASSERT(Code < TableSize, 'Code too large');
      while (code >= ClearCode) do
      begin
        Source^ := table1[code];
        Inc(Source);
        if (code = table0[code]) then
          Error(sDecodeCircular);
        code := table0[code];
        ASSERT(Code < TableSize, 'Code too large');
      end;

      firstcode := table1[code];
      Source^ := firstcode;
      Inc(Source);

      code := MaxCode;
      if (code <= GIFCodeMax) then
      begin
        table0[code] := oldcode;
        table1[code] := firstcode;
        Inc(MaxCode);
        if ((MaxCode >= MaxCodeSize) and (MaxCodeSize <= GIFCodeMax)) then
        begin
          MaxCodeSize := MaxCodeSize * 2;
          Inc(BitsPerCode);
        end;
      end;

      oldcode := incode;

      if (longInt(Source) > longInt(@stack)) then
      begin
        Dec(Source);
        Result := Source^;
        exit;
      end
    end;
    Result := code;
  end;

  function readLWZ: integer;
  begin
    if (longInt(Source) > longInt(@stack)) then
    begin
      Dec(Source);
      Result := Source^;
    end else
      Result := NextLZW;
  end;

begin
  NewImage;

  // Clear image data in case decompress doesn't complete
  FillChar(FData^, FDataSize, 0);

{$ifdef DEBUG_DECOMPRESSPERFORMANCE}
  TimeStartDecompress := timeGetTime;
{$endif}

  (*
  ** Read initial code size in bits from stream
  *)
  if (Stream.Read(InitialBitsPerCode, 1) <> 1) then
    exit;

  (*
  **  Initialize the Compression routines
  *)
  BitsPerCode := InitialBitsPerCode + 1;
  ClearCode := 1 SHL InitialBitsPerCode;
  EOFCode := ClearCode + 1;
  MaxCodeSize := 2 * ClearCode;
  MaxCode := ClearCode + 2;

  StartBit := 0;
  LastBit := 0;
  LastByte := 2;

  ZeroBlock := False;
  get_done := FALSE;
  return_clear := TRUE;

  Source := @stack;

  try
    if (Interlaced) then
    begin
      ypos := 0;
      pass := 0;
      step := 8;

      for i := 0 to Height-1 do
      begin
        Dest := FData + Width * ypos;
        for xpos := 0 to width-1 do
        begin
          v := readLWZ;
          if (v < 0) then
            exit;
          Dest^ := char(v);
          Inc(Dest);
        end;
        Inc(ypos, step);
        if (ypos >= height) then
          repeat
            if (pass > 0) then
              step := step DIV 2;
            Inc(pass);
            ypos := step DIV 2;
          until (ypos <= height);
      end;
    end else
    begin
      Dest := FData;
      for ypos := 0 to (height * width)-1 do
      begin
        v := readLWZ;
        if (v < 0) then
          exit;
        Dest^ := char(v);
        Inc(Dest);
      end;
    end;
  finally
    if (readLWZ >= 0) then
      ;
//      raise GIFException.Create('Too much input data, ignoring extra...');
  end;
{$ifdef DEBUG_DECOMPRESSPERFORMANCE}
  TimeStopDecompress := timeGetTime;
  ShowMessage(format('Decompressed %d pixels in %d mS, Rate %d pixels/mS',
    [Height*Width, TimeStopDecompress-TimeStartDecompress,
    (Height*Width) DIV (TimeStopDecompress-TimeStartDecompress+1)]));
{$endif}
end;

procedure TGIFSubImage.Compress(Stream: TStream);
const
  EndBlockByte		= $00;			// End of block marker

var
  bpp			: integer;		// Bits Per Pixel
  Pixel			: PChar;		// Pointer to current pixel
  PixelVal		: char;			// Value of current pixel (LZW Postfix character)
  Prefix		: CodeInt;		// LZW Prefix string
  cX			: LongInt;		// Current X counter (Width - X)
  Y			: LongInt;		// Current Y
  Pass			: integer;		// Interlace pass

  // Hash stuff
  HashTable		: THashTable;

  // LZW Code table stuff
  BitsPerCode		: integer;		// number of CodeTableBits/code
  MaxCode		: CodeInt;		// maximum code, given BitsPerCode

  NewKey		: KeyInt;
  NewCode		: CodeInt;

  FreeEntry		: CodeInt;		// next unused code in table
  OutputBucket		: longInt;		// Output bit bucket
  OutputBits		: integer;		// Number of bits in bucket
  // Block compression parameters -- after all codes are used up,
  // and compression rate changes, start over.
  ClearFlag		: Boolean;
  InitialBitsPerCode	: integer;

  ClearCode		: integer;		// Special output code to signal "Clear table"
  EOFCode		: integer;		// Special output code to signal EOF
  Buffer		: TMemoryStream;	// Output buffer for blocking data into 255 byte chunks

{$ifdef DEBUG_COMPRESSPERFORMANCE}
  TimeStartCompress: LongInt;
  TimeStopCompress: LongInt;
{$endif}

  (*
   * Bump (X,Y) to point to the next pixel
   *)
  function BumpPixel: boolean;
  begin
    (*
     * Bump the current X position
     *)
    dec(cX);

    (*
     * If we are at the end of a scan line, set curx back to the beginning
     * If we are interlaced, bump the cury to the appropriate spot,
     * otherwise, just increment it.
     *)
    if (cX <= 0) then
    begin

      if not(Interlaced) then
      begin
        Result := False;
        exit;
      end;

      cX := Width;
      case (Pass) of
        0:
          begin
            inc(Y, 8);
            if (Y >= Height) then
            begin
              inc(Pass);
              Y := 4;
            end;
          end;
        1:
          begin
            inc(Y, 8);
            if (Y >= Height) then
            begin
              inc(Pass);
              Y := 2;
            end;
          end;
        2:
          begin
            inc(Y, 4);
            if (Y >= Height) then
            begin
              inc(Pass);
              Y := 1;
            end;
          end;
        3:
          inc(Y, 2);
      end;

      if (Y >= height) then
      begin
        Result := False;
        exit;
      end;
      Pixel := FData + (Y * Width);
    end;
    Result := True;
  end;

  function MaxCodesFromBits(Bits: integer): CodeInt;
  begin
    Result := (CodeInt(1) SHL Bits) - 1;
  end;

  procedure Output(code: CodeInt);
  const
    BitBucketMask: array[0..16] of longInt =
      ($0000,
       $0001, $0003, $0007, $000F,
       $001F, $003F, $007F, $00FF,
       $01FF, $03FF, $07FF, $0FFF,
       $1FFF, $3FFF, $7FFF, $FFFF);
  var
    Size		,
    Chunk		: integer;
  begin
    if (OutputBits > 0) then
      OutputBucket := (OutputBucket AND BitBucketMask[OutputBits]) OR
        (longInt(code) SHL OutputBits)
    else
      OutputBucket := code;

    inc(OutputBits, BitsPerCode);

    while (OutputBits >= 8) do
    begin
      WriteByte(Buffer, OutputBucket AND $FF);
      OutputBucket := OutputBucket SHR 8;
      dec(OutputBits, 8);
      // Flush buffer
      if (Buffer.Position >= 254) then
      begin
        Size := Buffer.Position;
        Buffer.Seek(0, soFromBeginning);
        while (Size > 0) do
        begin
          if (Size >= 254) then
            Chunk := 254
          else
            Chunk := Size;
          WriteByte(Stream, Chunk);
          dec(Size, Chunk);
          Stream.CopyFrom(Buffer, Chunk);
        end;
        Buffer.Seek(0, soFromBeginning);
      end;
    end;

    (*
    ** If the next entry is going to be too big for the code size,
    ** then increase it, if possible.
    *)
    if (FreeEntry > MaxCode) or (ClearFlag) then
    begin
      if (ClearFlag) then
      begin
        BitsPerCode := InitialBitsPerCode;
        MaxCode := MaxCodesFromBits(BitsPerCode);
        ClearFlag := FALSE;
      end else
      begin
        inc(BitsPerCode);
        if (BitsPerCode = GIFCodeBits) then
          MaxCode := TableMaxMaxCode
        else
          MaxCode := MaxCodesFromBits(BitsPerCode);
      end;
    end;

    if (code = EOFCode) then
    begin
      (*
      ** At EOF, write the rest of the buffer.
      *)
      while (OutputBits > 0) do
      begin
        WriteByte(Buffer, OutputBucket AND $FF);
        OutputBucket := OutputBucket SHR 8;
        dec(OutputBits, 8);
      end;
      // Flush buffer
      if (Buffer.Position > 0) then
      begin
        Size := Buffer.Position;
        Buffer.Seek(0, soFromBeginning);
        while (Size > 0) do
        begin
          if (Size >= 254) then
            Chunk := 254
          else
            Chunk := Size;
          WriteByte(Stream, Chunk);
          dec(Size, Chunk);
          Stream.CopyFrom(Buffer, Chunk);
        end;
        Buffer.Seek(0, soFromBeginning);
      end;
    end;
  end;

  (*
   * Clear out the hash table
   *)
  procedure HashClear;
  begin
    HashTable.Clear;
    FreeEntry := ClearCode + 2;
    ClearFlag := TRUE;
    output(ClearCode);
  end;


begin
{$ifdef DEBUG_COMPRESSPERFORMANCE}
  TimeStartCompress := timeGetTime;
{$endif}
  if (ColorMap.Count > 0) then
    bpp := ColorMap.BitsPerPixel
  else
    bpp := Image.BitsPerPixel;

  (*
  ** Set up the globals:  InitialBitsPerCode - initial number of CodeTableBits
  *)
  if (bpp <= 1) then
  begin
    InitialBitsPerCode := 3;
    WriteByte(Stream, 2);
  end else
  begin
    InitialBitsPerCode := bpp + 1;
    WriteByte(Stream, bpp);
  end;

  (*
  ** Set up the necessary values
  *)
  ClearFlag := FALSE;
  BitsPerCode := InitialBitsPerCode;
  MaxCode := MaxCodesFromBits(BitsPerCode);
//  HashSize := Hash_Size;
  OutputBucket := 0;
  OutputBits  := 0;

  HashTable := THashTable.Create;
  try

//    ClearCode := (1 SHL InitialBitsPerCode);
    ClearCode := (1 SHL (InitialBitsPerCode - 1));
    EOFCode := ClearCode + 1;

    Buffer := TMemoryStream.Create;
    try
      Buffer.SetSize(256);
      // clear hash table and sync decoder
      HashClear;

      // Reset pixel counter
      if (Interlaced) then
        cX := width
      else
        cX := FDataSize;
      // Reset row counter
      Y := 0;
      Pass := 0;

      // Safety check for empty image
      if (FData <> nil) and (FDataSize > 0) then
      begin
        Pixel := FData;
        Prefix := CodeInt(Pixel^);
        inc(Pixel);
        while (BumpPixel) do
        begin
          (*
          **  Fetch the next pixel
          *)
          PixelVal := Pixel^;
          inc(Pixel);

          (*
          **  Append Postfix to Prefix and lookup in table...
          *)
          NewKey := (KeyInt(Prefix) SHL 8) OR ord(PixelVal);
          NewCode := HashTable.Lookup(NewKey);
          if (NewCode >= 0) then
          begin
            (*
            **  ...if found, get next pixel
            *)
            Prefix := NewCode;
            continue;
          end;

          (*
          **  ...if not found, output and start over
          *)
          Output(Prefix);
          Prefix := CodeInt(PixelVal);

          if (FreeEntry < TableMaxFill) then
          begin
            HashTable.Insert(NewKey, FreeEntry);
            inc(FreeEntry);
          end else
            HashClear;
        end;
        Output(Prefix);
      end;
      (*
      ** Put out the final code.
      *)
      Output(EOFCode);

    finally
      Buffer.Free;
    end;
{$ifdef DEBUG_COMPRESSPERFORMANCE}
  TimeStopCompress := timeGetTime;
  ShowMessage(format('Compressed %d pixels in %d mS, Rate %d pixels/mS',
    [Height*Width, TimeStopCompress-TimeStartCompress,
    (Height*Width) DIV (TimeStopCompress-TimeStartCompress+1)]));
{$endif}
  finally
    HashTable.Free;
  end;
  (*
  **  End block byte
  *)
  WriteByte(Stream, EndBlockByte);
end;

procedure TGIFSubImage.SaveToStream(Stream: TStream);
begin
  FExtensions.SaveToStream(Stream);
  if (Empty) then
    exit;
  Prepare;
  Stream.Write(FImageDescriptor, sizeof(TImageDescriptor));
  ColorMap.SaveToStream(Stream);
  Compress(Stream);
end;

procedure TGIFSubImage.LoadFromFile(const Filename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(Filename, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TGIFSubImage.LoadFromStream(Stream: TStream);
var
  ColorCount		: integer;
  b			: BYTE;
begin
  Clear;
  FExtensions.LoadFromStream(Stream, self);
  // Check for extension without image
  if (Stream.Read(b, 1) <> 1) then
    exit;
  Stream.Seek(-1, soFromCurrent);
  if (b = bsTrailer) or (b = 0) then
    exit;

  ReadCheck(Stream, FImageDescriptor, sizeof(TImageDescriptor));

  // From Mozilla source:
  // Work around more broken GIF files that have zero image
  // width or height
  if (FImageDescriptor.Height = 0) or (FImageDescriptor.Width = 0) then
  begin
    FImageDescriptor.Height := Image.Height;
    FImageDescriptor.Width := Image.Width;
    Warning(gsWarning, sScreenSizeExceeded);
  end;

  if (FImageDescriptor.PackedFields AND idLocalColorTable = idLocalColorTable) then
  begin
    ColorCount := 2 SHL (FImageDescriptor.PackedFields AND idColorTableSize);
    if (ColorCount < 2) or (ColorCount > 256) then
      Error(sImageBadColorSize);
    ColorMap.LoadFromStream(Stream, ColorCount);
  end;

  Decompress(Stream);
end;

procedure TGIFSubImage.AssignTo(Dest: TPersistent);
begin
  if (Dest is TBitmap) then
    Dest.Assign(Bitmap)
  else
    inherited AssignTo(Dest);
end;

procedure TGIFSubImage.Assign(Source: TPersistent);
var
  MemoryStream		: TMemoryStream;
  i			: integer;
  Colors		: integer;
  PixelFormat		: TPixelFormat;

  procedure Import8Bit(Dest: PChar);
  var
    y			: integer;
  begin
    for y := 0 to Height-1 do
    begin
      if (y MOD 32 = 0) then
        Image.Progress(Self, psRunning, y * 100 DIV Height, False, Rect(0,0,0,0), sProgressConverting);
      Move(GetScanline(y)^, Dest^, Width);
      inc(Dest, Width);
    end;
  end;

  procedure Import4Bit(Dest: PChar);
  var
    x, y		: integer;
    Scanline		: PChar;
  begin
    for y := 0 to Height-1 do
    begin
      if (y MOD 32 = 0) then
        Image.Progress(Self, psRunning, y * 100 DIV Height, False, Rect(0,0,0,0), sProgressConverting);
      ScanLine := GetScanLine(y);
      for x := 0 to Width-1 do
      begin
        if (x AND $01 = 0) then
          Dest^ := chr(ord(ScanLine^) SHR 4)
        else
        begin
          Dest^ := chr(ord(ScanLine^) AND $0F);
          inc(ScanLine);
        end;
        inc(Dest);
      end;
    end;
  end;

  procedure Import1Bit(Dest: PChar);
  var
    x, y		: integer;
    Scanline		: PChar;
    Bit			: integer;
    Byte		: integer;
  begin
    for y := 0 to Height-1 do
    begin
      if (y MOD 32 = 0) then
        Image.Progress(Self, psRunning, y * 100 DIV Height, False, Rect(0,0,0,0), sProgressConverting);
      ScanLine := GetScanLine(y);
      x := Width;
      Bit := 0;
      Byte := 0; // To avoid compiler warning
      while (x > 0) do
      begin
        if (Bit = 0) then
        begin
          Bit := 8;
          Byte := ord(ScanLine^);
          inc(Scanline);
        end;
        Dest^ := chr((Byte AND $80) SHR 7);
        Byte := Byte SHL 1;
        inc(Dest);
        dec(Bit);
        dec(x);
      end;
    end;
  end;

  procedure ImportAnyBit(Dest: PChar);
  type
    TCacheEntry = record
      Color		: TColor;
      Index		: integer;
    end;
  const
    // Size of palette cache.
    // The cache holds the palette index of the last "CacheSize" colors
    // processed. Hopefully the cache can speed things up a bit... Initial
    // testing shows that this is indeed the case at least for non-dithered
    // bitmaps.
    // All the same, a small hash table would probably be much better.
    CacheSize		= 8;
  var
    i			: integer;
    Cache		: array[0..CacheSize-1] of TCacheEntry;
    LastEntry		: integer;
    Pixel		: TColor;
    x, y		: integer;
  label
    NextPixel;
  begin
    for i := 0 to CacheSize-1 do
      Cache[i].Index := -1;
    LastEntry := 0;

    // Copy all pixels and build colormap
    for y := 0 to Height-1 do
    begin
      if (y MOD 32 = 0) then
        Image.Progress(Self, psRunning, y * 100 DIV Height, False, Rect(0,0,0,0), sProgressConverting);
      for x := 0 to Width-1 do
      begin
        Pixel := FBitmap.Canvas.Pixels[x,y];
        // Scan cache for color from most recently processed color to last
        // recently processed. This is done because TColorMap.Add is very slow.
        i := LastEntry;
        repeat
          if (Cache[i].Index = -1) then
            break;
          if (Cache[i].Color = Pixel) then
          begin
            Dest^ := chr(Cache[i].Index);
            LastEntry := i;
            goto NextPixel;
          end;
          if (i = 0) then
            i := CacheSize-1
          else
            dec(i);
        until (i = LastEntry);
        // Color not found in cache, do it the slow way instead
        Dest^ := chr(FColorMap.Add(Pixel));
        // Add color and index to cache
        LastEntry := (LastEntry + 1) MOD CacheSize;
        Cache[LastEntry].Color := Pixel;
        Cache[LastEntry].Index := ord(Dest^);

        NextPixel:
        Inc(Dest);
      end;
    end;
  end;

begin
  if (Source is TGIFSubImage) then
  begin
    // Zap existing colormap, extensions and bitmap
    Clear;
    if (TGIFSubImage(Source).Empty) then
      exit;
    // Not very effecient method: Save source image to a stream and read it back
    // It would be much more efficient to copy the data directly
    MemoryStream := TMemoryStream.Create;
    try
      TGIFSubImage(Source).SaveToStream(MemoryStream);
      MemoryStream.Seek(0, soFromBeginning);
      LoadFromStream(MemoryStream);
      if (TGIFSubImage(Source).FBitmap <> nil) then
      begin
        NewBitmap;
        FBitmap.Assign(TGIFSubImage(Source).FBitmap);
      end;
    finally
      MemoryStream.Free;
    end;
  end else
  if (Source is TBitmap) then
  begin
    // Zap existing colormap, extensions and bitmap
    Clear;
    if (TBitmap(Source).Empty) then
      exit;

    // Create new bitmap and copy
    NewBitmap;
    FBitmap.Assign(TBitmap(Source));

    // Convert image to 8 bits/pixel or less
    PixelFormat := GetPixelFormat(FBitmap);

    // ***FIXME*** Needed to support import of more than 256 colors
    // Very sub-optimal solution
    if (PixelFormat > pf8bit) then
    begin
      SetPixelFormat(FBitmap, pf8bit);
      PixelFormat := pf8bit;
    end;

    Width := FBitmap.Width;
    Height := FBitmap.Height;
    // Allocate new buffer
    NewImage;

    Image.Progress(Self, psStarting, 0, False, Rect(0,0,0,0), sProgressConverting);
    try
      if (PixelFormat in [pf1bit, pf4bit, pf8bit]) then
      begin
        BitmapToDIB(FBitmap);
        try
          // Copy colormap
          Colors := FDIBInfo^.bmiHeader.biClrUsed;
          if (Colors = 0) then
            Colors := 1 SHL FDIBInfo^.bmiHeader.biBitCount;
          FColorMap.ImportColorTable(@(FDIBInfo^.bmiColors), Colors);

          // Copy pixels
          case (PixelFormat) of
            pf8bit: Import8Bit(Fdata);
            pf4bit: Import4Bit(Fdata);
            pf1bit: Import1Bit(Fdata);
          end;

        finally
          FreeDIB;
        end;
      end else
        // Copy all pixels and build colormap
        ImportAnyBit(FData);
    finally
      if ExceptObject = nil then
        i := 100
      else
        i := 0;
      Image.Progress(Self, psEnding, i, Image.PaletteModified, Rect(0,0,0,0), sProgressConverting);
    end;

  end else
    inherited Assign(Source);
end;

// Copied from D3 graphics.pas
// Fixed by Brian Lowe of Acro Technology Inc. 30Jan98
function TransparentStretchBlt(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
  SrcDC: HDC; SrcX, SrcY, SrcW, SrcH: Integer; MaskDC: HDC; MaskX,
  MaskY: Integer): Boolean;
const
  ROP_DstCopy		= $00AA0029;
var
  MemDC			,
  OrMaskDC		: HDC;
  MemBmp		,
  OrMaskBmp		: HBITMAP;
  Save			,
  OrMaskSave		: THandle;
  crText, crBack	: TColorRef;
  SavePal		: HPALETTE;

begin
  Result := True;
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (SrcW = DstW) and (SrcH = DstH) then
  begin
    MemBmp := GDICheck(CreateCompatibleBitmap(SrcDC, 1, 1));
    MemBmp := SelectObject(MaskDC, MemBmp);
    try
      MaskBlt(DstDC, DstX, DstY, DstW, DstH, SrcDC, SrcX, SrcY, MemBmp, MaskX,
        MaskY, MakeRop4(ROP_DstCopy, SrcCopy));
    finally
      MemBmp := SelectObject(MaskDC, MemBmp);
      DeleteObject(MemBmp);
    end;
    Exit;
  end;

  SavePal := 0;
  MemDC := GDICheck(CreateCompatibleDC(DstDC));
  try
    { Color bitmap for combining OR mask with source bitmap }
    MemBmp := GDICheck(CreateCompatibleBitmap(DstDC, SrcW, SrcH));
    try
      Save := SelectObject(MemDC, MemBmp);

      { This bitmap needs the size of the source but DC of the dest }
      OrMaskDC := GDICheck(CreateCompatibleDC(DstDC));
      try
        { Need a monochrome bitmap for OR mask!! }
        OrMaskBmp := GDICheck(CreateBitmap(SrcW, SrcH, 1, 1, nil));
        try
          OrMaskSave := SelectObject(OrMaskDC, OrMaskBmp);

          // OrMask := 1
          // Original: BitBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, OrMaskDC, SrcX, SrcY, WHITENESS);
          // Replacement, but not needed: PatBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, WHITENESS);
          // OrMask := OrMask XOR Mask
          // Not needed: BitBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, MaskDC, SrcX, SrcY, SrcInvert);
          // OrMask := NOT Mask
          BitBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, MaskDC, SrcX, SrcY, NotSrcCopy);

          // Retrieve source palette (with dummy select)
          SavePal := SelectPalette(SrcDC, SystemPalette16, False);
          // Restore source palette
          SelectPalette(SrcDC, SavePal, False);
          // Select source palette into memory buffer
          if SavePal <> 0 then
            SavePal := SelectPalette(MemDC, SavePal, True)
          else
            SavePal := SelectPalette(MemDC, SystemPalette16, True);
          RealizePalette(MemDC);

          // Mem := OrMask
          BitBlt(MemDC, SrcX, SrcY, SrcW, SrcH, OrMaskDC, SrcX, SrcY, SrcCopy);
          // Mem := Mem AND Src
          BitBlt(MemDC, SrcX, SrcY, SrcW, SrcH, SrcDC, SrcX, SrcY, SrcAnd);
//{}        StretchBlt(DstDC, DstX, DstY, DstW DIV 2, DstH, MemDC, SrcX, SrcY, SrcW, SrcH, SrcCopy);
//{}        StretchBlt(DstDC, DstX+DstW DIV 2, DstY, DstW DIV 2, DstH, SrcDC, SrcX, SrcY, SrcW, SrcH, SrcCopy);
//{}        exit;

          if (OrMaskSave <> 0) then
            SelectObject(OrMaskDC, OrMaskSave);
        finally
          DeleteObject(OrMaskBmp);
        end;
      finally
        DeleteDC(OrMaskDC);
      end;

      crText := SetTextColor(DstDC, $00000000);
      crBack := SetBkColor(DstDC, $00FFFFFF);

      { All color rendering is done at 1X (no stretching),
        then final 2 masks are stretched to dest DC }
      // Neat trick!
      // Dst := Dst AND Mask
      StretchBlt(DstDC, DstX, DstY, DstW, DstH, MaskDC, SrcX, SrcY, SrcW, SrcH, SrcAnd);
      // Dst := Dst OR Mem
      StretchBlt(DstDC, DstX, DstY, DstW, DstH, MemDC, SrcX, SrcY, SrcW, SrcH, SrcPaint);

      SetTextColor(DstDC, crText);
      SetTextColor(DstDC, crBack);

      if (Save <> 0) then
        SelectObject(MemDC, Save);
    finally
      DeleteObject(MemBmp);
    end;
  finally
    if (SavePal <> 0) then
      SelectPalette(MemDC, SavePal, False);
    DeleteDC(MemDC);
  end;
end;

procedure TGIFSubImage.Draw(ACanvas: TCanvas; const Rect: TRect; DoTransparent: boolean);
begin
  StretchDraw(ACanvas, ScaleRect(Rect), DoTransparent);
end;

type
  // Dummy class used to give access to protected method TCanvas.Changed
  TChangableCanvas = class(TCanvas)
  public
    procedure Changed; override;
  end;

procedure TChangableCanvas.Changed;
begin
  inherited;
end;

procedure TGIFSubImage.StretchDraw(ACanvas: TCanvas; const Rect: TRect; DoTransparent: boolean);
var
  MaskDC		: HDC;
  Save			: THandle;

begin
  if (DoTransparent) and (Transparent) and (HasMask) then
  begin
    // Draw transparent using mask
    Save := 0;
    MaskDC := 0;
    try
      MaskDC := GDICheck(CreateCompatibleDC(0));
      Save := SelectObject(MaskDC, FMask);

      TransparentStretchBlt(ACanvas.Handle, Rect.Left, Rect.Top,
        Rect.Right - Rect.Left, Rect.Bottom - Rect.Top,
        Bitmap.Canvas.Handle, 0, 0, Width,
        Height, MaskDC, 0, 0);

      // Since we are not using any of the TCanvas functions (only handle)
      // we need to fire the TCanvas.Changed method "manually".
      TChangableCanvas(ACanvas).Changed;

    finally
      if (Save <> 0) then
        SelectObject(MaskDC, Save);
      if (MaskDC <> 0) then
        DeleteDC(MaskDC);
    end;
    exit;
  end else
    ACanvas.StretchDraw(Rect, Bitmap);
end;

// Given a destination rect (DestRect) calculates the
// area covered by this sub image
function TGIFSubImage.ScaleRect(DestRect: TRect): TRect;
var
  HeightMul		,
  HeightDiv		: integer;
  WidthMul		,
  WidthDiv		: integer;
begin
  HeightDiv := Image.Height;
  HeightMul := DestRect.Bottom-DestRect.Top;
  WidthDiv := Image.Width;
  WidthMul := DestRect.Right-DestRect.Left;

  Result.Left := DestRect.Left + muldiv(Left, WidthMul, WidthDiv);
  Result.Top := DestRect.Top + muldiv(Top, HeightMul, HeightDiv);
  Result.Right := DestRect.Left + muldiv(Left+Width, WidthMul, WidthDiv);
  Result.Bottom := DestRect.Top + muldiv(Top+Height, HeightMul, HeightDiv);
end;

(*******************************************************************************
**
**			TGIFTrailer
**
*******************************************************************************)
procedure TGIFTrailer.SaveToStream(Stream: TStream);
begin
  WriteByte(Stream, bsTrailer);
end;

procedure TGIFTrailer.LoadFromStream(Stream: TStream);
var
  b			: BYTE;
begin
  if (Stream.Read(b, 1) <> 1) then
    exit;
  if (b <> bsTrailer) then
    Warning(gsWarning, sBadTrailer);
end;

(*******************************************************************************
**
**		TGIFExtension registration database
**
*******************************************************************************)
type
  TExtensionLeadIn = packed record
    Introducer: byte;      { always $21 }
    ExtensionLabel: byte;
  end;

  PExtRec = ^TExtRec;
  TExtRec = record
    ExtClass: TGIFExtensionClass;
    ExtLabel: BYTE;
  end;

  TExtensionList = class(TList)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(eLabel: BYTE; eClass: TGIFExtensionClass);
    function FindExt(eLabel: BYTE): TGIFExtensionClass;
    procedure Remove(eClass: TGIFExtensionClass);
  end;

constructor TExtensionList.Create;
begin
  inherited Create;
  Add(bsPlainTextExtension, TGIFTextExtension);
  Add(bsGraphicControlExtension, TGIFGraphicControlExtension);
  Add(bsCommentExtension, TGIFCommentExtension);
  Add(bsApplicationExtension, TGIFApplicationExtension);
end;

destructor TExtensionList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count-1 do
    Dispose(PExtRec(Items[I]));
  inherited Destroy;
end;

procedure TExtensionList.Add(eLabel: BYTE; eClass: TGIFExtensionClass);
var
  NewRec: PExtRec;
begin
  New(NewRec);
  with NewRec^ do
  begin
    ExtLabel := eLabel;
    ExtClass := eClass;
  end;
  inherited Add(NewRec);
end;

function TExtensionList.FindExt(eLabel: BYTE): TGIFExtensionClass;
var
  I: Integer;
begin
  for I := Count-1 downto 0 do
    with PExtRec(Items[I])^ do
      if ExtLabel = eLabel then
      begin
        Result := ExtClass;
        Exit;
      end;
  Result := nil;
end;

procedure TExtensionList.Remove(eClass: TGIFExtensionClass);
var
  I: Integer;
  P: PExtRec;
begin
  for I := Count-1 downto 0 do
  begin
    P := PExtRec(Items[I]);
    if P^.ExtClass.InheritsFrom(eClass) then
    begin
      Dispose(P);
      Delete(I);
    end;
  end;
end;

var
  ExtensionList: TExtensionList = nil;

function GetExtensionList: TExtensionList;
begin
  if (ExtensionList = nil) then
    ExtensionList := TExtensionList.Create;
  Result := ExtensionList;
end;

(*******************************************************************************
**
**			TGIFExtension
**
*******************************************************************************)
function TGIFExtension.GetVersion: TGIFVersion;
begin
  Result := gv89a;
end;

class procedure TGIFExtension.RegisterExtension(eLabel: BYTE; eClass: TGIFExtensionClass);
begin
  GetExtensionList.Add(eLabel, eClass);
end;

class function TGIFExtension.FindExtension(Stream: TStream): TGIFExtensionClass;
var
  eLabel		: BYTE;
  SubClass		: TGIFExtensionClass;
  Pos			: LongInt;
begin
  Pos := Stream.Position;
  if (Stream.Read(eLabel, 1) <> 1) then
  begin
    Result := nil;
    exit;
  end;
  Result := GetExtensionList.FindExt(eLabel);
  while (Result <> nil) do
  begin
    SubClass := Result.FindSubExtension(Stream);
    if (SubClass = Result) then
      break;
    Result := SubClass;
  end;
  Stream.Position := Pos;
end;

class function TGIFExtension.FindSubExtension(Stream: TStream): TGIFExtensionClass;
begin
  Result := self;
end;

constructor TGIFExtension.Create(ASubImage: TGIFSubImage);
begin
  inherited Create(ASubImage.Image);
  FSubImage := ASubImage;
end;

procedure TGIFExtension.SaveToStream(Stream: TStream);
var
  ExtensionLeadIn	: TExtensionLeadIn;
begin
  ExtensionLeadIn.Introducer := bsExtensionIntroducer;
  ExtensionLeadIn.ExtensionLabel := ExtensionType;
  Stream.Write(ExtensionLeadIn, sizeof(ExtensionLeadIn));
end;

function TGIFExtension.DoReadFromStream(Stream: TStream): TGIFExtensionType;
var
  ExtensionLeadIn	: TExtensionLeadIn;
begin
  ReadCheck(Stream, ExtensionLeadIn, sizeof(ExtensionLeadIn));
  if (ExtensionLeadIn.Introducer <> bsExtensionIntroducer) then
    Error(sBadExtensionLabel);
  Result := ExtensionLeadIn.ExtensionLabel;
end;

procedure TGIFExtension.LoadFromStream(Stream: TStream);
begin
  // Seek past lead-in
  // Stream.Seek(sizeof(TExtensionLeadIn), soFromCurrent);
  if (DoReadFromStream(Stream) <> ExtensionType) then
    Error(sBadExtensionInstance);
end;

(*******************************************************************************
**
**			TGIFGraphicControlExtension
**
*******************************************************************************)
const
  { Extension flag bit masks }
  efInputFlag		= $02;		{ 00000010 }
  efDisposal		= $1C;		{ 00011100 }
  efTransparent		= $01;		{ 00000001 }
  efReserved		= $E0;		{ 11100000 }

constructor TGIFGraphicControlExtension.Create(ASubImage: TGIFSubImage);
begin
  inherited Create(ASubImage);

  FGCExtension.BlockSize := 4;
  FGCExtension.PackedFields := $00;
  FGCExtension.DelayTime := 0;
  FGCExtension.TransparentColorIndex := 0;
  FGCExtension.Terminator := 0;
  if (ASubImage.FGCE = nil) then
    ASubImage.FGCE := self;
end;

destructor TGIFGraphicControlExtension.Destroy;
begin
  // Clear transparent flag in sub image
  if (Transparent) then
    SubImage.FTransparent := False;

  if (SubImage.FGCE = self) then
    SubImage.FGCE := nil;

  inherited Destroy;
end;

function TGIFGraphicControlExtension.GetExtensionType: TGIFExtensionType;
begin
  Result := bsGraphicControlExtension;
end;

function TGIFGraphicControlExtension.GetTransparent: boolean;
begin
  Result := (FGCExtension.PackedFields AND efTransparent) <> 0;
end;

procedure TGIFGraphicControlExtension.SetTransparent(Value: boolean);
begin
  // Set transparent flag in sub image
  SubImage.FTransparent := Value;
  if (Value) then
    FGCExtension.PackedFields := FGCExtension.PackedFields OR efTransparent
  else
    FGCExtension.PackedFields := FGCExtension.PackedFields AND NOT(efTransparent);
end;

function TGIFGraphicControlExtension.GetTransparentColor: TColor;
begin
  Result := SubImage.ActiveColorMap[TransparentColorIndex];
end;

procedure TGIFGraphicControlExtension.SetTransparentColor(Color: TColor);
var
  Index			: integer;
begin
  with SubImage do
  begin
    Index := ActiveColorMap.IndexOf(Color);
    if (Index = -1) then
      Index := ActiveColorMap.Add(Color);
  end;
  FGCExtension.TransparentColorIndex := Index;
end;

function TGIFGraphicControlExtension.GetTransparentColorIndex: BYTE;
begin
  Result := FGCExtension.TransparentColorIndex;
end;

procedure TGIFGraphicControlExtension.SetTransparentColorIndex(Value: BYTE);
begin
  if (Value < 0) or
    ((Value >= SubImage.ActiveColorMap.Count) and (SubImage.ActiveColorMap.Count > 0)) then
  begin
    Warning(gsWarning, sBadColorIndex);
    Value := 0;
  end;
  FGCExtension.TransparentColorIndex := Value;
end;

function TGIFGraphicControlExtension.GetDelay: WORD;
begin
  Result := FGCExtension.DelayTime;
end;
procedure TGIFGraphicControlExtension.SetDelay(Value: WORD);
begin
  FGCExtension.DelayTime := Value;
end;

function TGIFGraphicControlExtension.GetUserInput: boolean;
begin
  Result := (FGCExtension.PackedFields AND efInputFlag) <> 0;
end;

procedure TGIFGraphicControlExtension.SetUserInput(Value: boolean);
begin
  if (Value) then
    FGCExtension.PackedFields := FGCExtension.PackedFields OR efInputFlag
  else
    FGCExtension.PackedFields := FGCExtension.PackedFields AND NOT(efInputFlag);
end;

function TGIFGraphicControlExtension.GetDisposal: TDisposalMethod;
begin
  Result := TDisposalMethod((FGCExtension.PackedFields AND efDisposal) SHR 2);
end;

procedure TGIFGraphicControlExtension.SetDisposal(Value: TDisposalMethod);
begin
  FGCExtension.PackedFields := FGCExtension.PackedFields AND NOT(efDisposal)
    OR ((ord(Value) SHL 2) AND efDisposal);
end;

procedure TGIFGraphicControlExtension.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(FGCExtension, sizeof(FGCExtension));
end;

procedure TGIFGraphicControlExtension.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  ReadCheck(Stream, FGCExtension, sizeof(FGCExtension));
  // Set transparent flag in sub image
  if (Transparent) then
    SubImage.FTransparent := True;
end;

(*******************************************************************************
**
**			TGIFTextExtension
**
*******************************************************************************)
constructor TGIFTextExtension.Create(ASubImage: TGIFSubImage);
begin
  inherited Create(ASubImage);
  FText := TStringList.Create;
  FPlainTextExtension.BlockSize := 12;
  FPlainTextExtension.Left := 0;
  FPlainTextExtension.Top := 0;
  FPlainTextExtension.Width := 0;
  FPlainTextExtension.Height := 0;
  FPlainTextExtension.CellWidth := 0;
  FPlainTextExtension.CellHeight := 0;
  FPlainTextExtension.TextFGColorIndex := 0;
  FPlainTextExtension.TextBGColorIndex := 0;
end;

destructor TGIFTextExtension.Destroy;
begin
  FText.Free;
  inherited Destroy;
end;

function TGIFTextExtension.GetExtensionType: TGIFExtensionType;
begin
  Result := bsPlainTextExtension;
end;

function TGIFTextExtension.GetForegroundColor: TColor;
begin
  Result := SubImage.ColorMap[ForegroundColorIndex];
end;

procedure TGIFTextExtension.SetForegroundColor(Color: TColor);
var
  Idx			: integer;
begin
  with SubImage do
  begin
    Idx := ActiveColorMap.IndexOf(Color);
    if (Idx = -1) then
      Idx := ActiveColorMap.Add(Color);
  end;
  ForegroundColorIndex := Idx;
end;

function TGIFTextExtension.GetBackgroundColor: TColor;
begin
  Result := SubImage.ActiveColorMap[BackgroundColorIndex];
end;

procedure TGIFTextExtension.SetBackgroundColor(Color: TColor);
var
  Idx			: integer;
begin
  with SubImage do
  begin
    Idx := ColorMap.IndexOf(Color);
    if (Idx = -1) then
      Idx := ColorMap.Add(Color);
  end;
  BackgroundColorIndex := Idx;
end;

function TGIFTextExtension.GetBounds(Index: integer): WORD;
begin
  case (Index) of
    1: Result := FPlainTextExtension.Left;
    2: Result := FPlainTextExtension.Top;
    3: Result := FPlainTextExtension.Width;
    4: Result := FPlainTextExtension.Height;
  else
    Result := 0; // To avoid compiler warnings
  end;
end;

procedure TGIFTextExtension.SetBounds(Index: integer; Value: WORD);
begin
  case (Index) of
    1: FPlainTextExtension.Left := Value;
    2: FPlainTextExtension.Top := Value;
    3: FPlainTextExtension.Width := Value;
    4: FPlainTextExtension.Height := Value;
  end;
end;

function TGIFTextExtension.GetCharWidthHeight(Index: integer): BYTE;
begin
  case (Index) of
    1: Result := FPlainTextExtension.CellWidth;
    2: Result := FPlainTextExtension.CellHeight;
  else
    Result := 0; // To avoid compiler warnings
  end;
end;

procedure TGIFTextExtension.SetCharWidthHeight(Index: integer; Value: BYTE);
begin
  case (Index) of
    1: FPlainTextExtension.CellWidth := Value;
    2: FPlainTextExtension.CellHeight := Value;
  end;
end;

function TGIFTextExtension.GetColorIndex(Index: integer): BYTE;
begin
  case (Index) of
    1: Result := FPlainTextExtension.TextFGColorIndex;
    2: Result := FPlainTextExtension.TextBGColorIndex;
  else
    Result := 0; // To avoid compiler warnings
  end;
end;

procedure TGIFTextExtension.SetColorIndex(Index: integer; Value: BYTE);
begin
  case (Index) of
    1: FPlainTextExtension.TextFGColorIndex := Value;
    2: FPlainTextExtension.TextBGColorIndex := Value;
  end;
end;

procedure TGIFTextExtension.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(FPlainTextExtension, sizeof(FPlainTextExtension));
  WriteStrings(Stream, FText);
end;

procedure TGIFTextExtension.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  ReadCheck(Stream, FPlainTextExtension, sizeof(FPlainTextExtension));
  ReadStrings(Stream, FText);
end;

(*******************************************************************************
**
**			TGIFCommentExtension
**
*******************************************************************************)
constructor TGIFCommentExtension.Create(ASubImage: TGIFSubImage);
begin
  inherited Create(ASubImage);
  FText := TStringList.Create;
end;

destructor TGIFCommentExtension.Destroy;
begin
  FText.Free;
  inherited Destroy;
end;

function TGIFCommentExtension.GetExtensionType: TGIFExtensionType;
begin
  Result := bsCommentExtension;
end;

procedure TGIFCommentExtension.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  WriteStrings(Stream, FText);
end;

procedure TGIFCommentExtension.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  ReadStrings(Stream, FText);
end;

(*******************************************************************************
**
**		TGIFApplicationExtension registration database
**
*******************************************************************************)
type
  PAppExtRec = ^TAppExtRec;
  TAppExtRec = record
    AppClass: TGIFAppExtensionClass;
    Ident: TGIFApplicationRec;
  end;

  TAppExtensionList = class(TList)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(eIdent: TGIFApplicationRec; eClass: TGIFAppExtensionClass);
    function FindExt(eIdent: TGIFApplicationRec): TGIFAppExtensionClass;
    procedure Remove(eClass: TGIFAppExtensionClass);
  end;

constructor TAppExtensionList.Create;
const
  NSLoopIdent: array[0..1] of TGIFApplicationRec =
    ((Identifier: 'NETSCAPE'; Authentication: '2.0'),
     (Identifier: 'ANIMEXTS'; Authentication: '1.0'));
begin
  inherited Create;
  Add(NSLoopIdent[0], TGIFAppExtNSLoop);
  Add(NSLoopIdent[1], TGIFAppExtNSLoop);
end;

destructor TAppExtensionList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count-1 do
    Dispose(PAppExtRec(Items[I]));
  inherited Destroy;
end;

procedure TAppExtensionList.Add(eIdent: TGIFApplicationRec;
  eClass: TGIFAppExtensionClass);
var
  NewRec: PAppExtRec;
begin
  New(NewRec);
  NewRec^.Ident := eIdent;
  NewRec^.AppClass := eClass;
  inherited Add(NewRec);
end;

function TAppExtensionList.FindExt(eIdent: TGIFApplicationRec): TGIFAppExtensionClass;
var
  I: Integer;
begin
  for I := Count-1 downto 0 do
    with PAppExtRec(Items[I])^ do
      if CompareMem(@Ident, @eIdent, sizeof(TGIFApplicationRec)) then
      begin
        Result := AppClass;
        Exit;
      end;
  Result := nil;
end;

procedure TAppExtensionList.Remove(eClass: TGIFAppExtensionClass);
var
  I: Integer;
  P: PAppExtRec;
begin
  for I := Count-1 downto 0 do
  begin
    P := PAppExtRec(Items[I]);
    if P^.AppClass.InheritsFrom(eClass) then
    begin
      Dispose(P);
      Delete(I);
    end;
  end;
end;

var
  AppExtensionList: TAppExtensionList = nil;

function GetAppExtensionList: TAppExtensionList;
begin
  if (AppExtensionList = nil) then
    AppExtensionList := TAppExtensionList.Create;
  Result := AppExtensionList;
end;

class procedure TGIFApplicationExtension.RegisterExtension(eIdent: TGIFApplicationRec;
  eClass: TGIFAppExtensionClass);
begin
  GetAppExtensionList.Add(eIdent, eClass);
end;

class function TGIFApplicationExtension.FindSubExtension(Stream: TStream): TGIFExtensionClass;
var
  eIdent		: TGIFApplicationRec;
  OldPos		: longInt;
  Size			: BYTE;
begin
  OldPos := Stream.Position;
  Result := nil;
  if (Stream.Read(Size, 1) <> 1) then
    exit;

  // Some old Adobe export filters mistakenly uses a value of 10
  if (Size = 10) then
  begin
    // ***FIXME*** replace with seek or...
    // read and check contents = 'Adobe'
    if (Stream.Read(eIdent, 10) <> 10) then
      exit;
    Result := TGIFUnknownAppExtension;
    exit;
  end else
  if (Size <> sizeof(TGIFApplicationRec)) or
    (Stream.Read(eIdent, sizeof(eIdent)) <> sizeof(eIdent)) then
  begin
    Stream.Position := OldPos;
    Result := inherited FindSubExtension(Stream);
  end else
  begin
    Result := GetAppExtensionList.FindExt(eIdent);
    if (Result = nil) then
      Result := TGIFUnknownAppExtension;
  end;
end;

(*******************************************************************************
**
**			TGIFApplicationExtension
**
*******************************************************************************)
constructor TGIFApplicationExtension.Create(ASubImage: TGIFSubImage);
begin
  inherited Create(ASubImage);
  FillChar(FIdent, sizeof(FIdent), 0);
end;

destructor TGIFApplicationExtension.Destroy;
begin
  inherited Destroy;
end;

function TGIFApplicationExtension.GetExtensionType: TGIFExtensionType;
begin
  Result := bsApplicationExtension;
end;

procedure TGIFApplicationExtension.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  WriteByte(Stream, sizeof(FIdent)); // Block size
  Stream.Write(FIdent, sizeof(FIdent));
  SaveData(Stream);
end;

procedure TGIFApplicationExtension.LoadFromStream(Stream: TStream);
var
  i			: integer;
begin
  inherited LoadFromStream(Stream);
  i := ReadByte(Stream);
  // Some old Adobe export filters mistakenly uses a value of 10
  if (i = 10) then
    FillChar(FIdent, sizeOf(FIdent), 0)
  else
    if (i < 11) then
      Error(sBadBlockSize);

  ReadCheck(Stream, FIdent, sizeof(FIdent));

  Dec(i, sizeof(FIdent));
  // Ignore extra data
  Stream.Seek(i, soFromCurrent);

  // ***FIXME***
  // If self class is TGIFApplicationExtension, this will cause an "abstract
  // error".
  // TGIFApplicationExtension.LoadData should read and ignore rest of block.
  LoadData(Stream);
end;

(*******************************************************************************
**
**			TGIFUnknownAppExtension
**
*******************************************************************************)
constructor TGIFBlock.Create(ASize: integer);
begin
  inherited Create;
  FSize := ASize;
  GetMem(FData, FSize);
end;

destructor TGIFBlock.Destroy;
begin
  FreeMem(FData);
  inherited Destroy;
end;

procedure TGIFBlock.SaveToStream(Stream: TStream);
begin
  Stream.Write(FSize, 1);
  Stream.Write(FData^, FSize);
end;

procedure TGIFBlock.LoadFromStream(Stream: TStream);
begin
  ReadCheck(Stream, FData^, FSize);
end;

constructor TGIFUnknownAppExtension.Create(ASubImage: TGIFSubImage);
begin
  inherited Create(ASubImage);
  FBlocks := TList.Create;
end;

destructor TGIFUnknownAppExtension.Destroy;
var
  i			: integer;
begin
  for i := 0 to FBlocks.Count-1 do
    TGIFBlock(FBlocks[i]).Free;
  FBlocks.Free;
  inherited Destroy;
end;


procedure TGIFUnknownAppExtension.SaveData(Stream: TStream);
var
  i			: integer;
begin
  for i := 0 to FBlocks.Count-1 do
    TGIFBlock(FBlocks[i]).SaveToStream(Stream);
  // Terminating zero
  WriteByte(Stream, 0);
end;

procedure TGIFUnknownAppExtension.LoadData(Stream: TStream);
var
  b			: BYTE;
  Block			: TGIFBlock;
  i			: integer;
begin
  // Zap old blocks
  for i := 0 to FBlocks.Count-1 do
    TGIFBlock(FBlocks[i]).Free;
  FBlocks.Clear;

  // Read blocks
  if (Stream.Read(b, 1) <> 1) then
    exit;
  while (b <> 0) do
  begin
    Block := TGIFBlock.Create(b);
    try
      Block.LoadFromStream(Stream);
    except
      Block.Free;
      raise;
    end;
    FBlocks.Add(Block);
    if (Stream.Read(b, 1) <> 1) then
      exit;
  end;
end;

(*******************************************************************************
**
**                      TGIFAppExtNSLoop
**
*******************************************************************************)
constructor TGIFAppExtNSLoop.Create(ASubImage: TGIFSubImage);
const
  NSLoopIdent: TGIFApplicationRec = (Identifier: 'NETSCAPE'; Authentication: '2.0');
begin
  inherited Create(ASubImage);
  FIdent := NSLoopIdent;
end;

procedure TGIFAppExtNSLoop.SaveData(Stream: TStream);
begin
  WriteByte(Stream, 3); // Size of block
  WriteByte(Stream, 1); // Dummy - must be 1
  Stream.Write(FLoops, sizeof(FLoops)); // Loop count
  WriteByte(Stream, 0); // Terminating zero
end;

procedure TGIFAppExtNSLoop.LoadData(Stream: TStream);
begin
  if (ReadByte(Stream) <> 3) then // Size of block
    Error(sInvalidData);
  if (ReadByte(Stream) <> 1) then  // Dummy - must be 1
    Error(sInvalidData);
  ReadCheck(Stream, FLoops, sizeof(FLoops)); // Loop count
  if (ReadByte(Stream) <> 0) then // Terminating zero
    Error(sInvalidData);
end;

(*******************************************************************************
**
**			TGIFImage
**
*******************************************************************************)
function TGIFImageList.GetImage(Index: Integer): TGIFSubImage;
begin
  Result := TGIFSubImage(Items[Index]);
end;

procedure TGIFImageList.SetImage(Index: Integer; SubImage: TGIFSubImage);
begin
  Items[Index] := SubImage;
end;

procedure TGIFImageList.LoadFromStream(Stream: TStream; Parent: TObject);
var
  b			: BYTE;
  SubImage		: TGIFSubImage;
begin
  // Peek ahead to determine block type
  repeat
    if (Stream.Read(b, 1) <> 1) then
      exit;
  until (b <> 0); // Ignore 0 padding (non-compliant)

  while (b <> bsTrailer) do
  begin
    Stream.Seek(-1, soFromCurrent);
    if (b in [bsExtensionIntroducer, bsImageDescriptor]) then
    begin
      SubImage := TGIFSubImage.Create(Parent as TGIFImage);
      try
        SubImage.LoadFromStream(Stream);
        Image.Progress(Self, psRunning, Stream.Position * 100 DIV Stream.Size, False, Rect(0,0,0,0), sProgressLoading);
        Add(SubImage);
      except
        SubImage.Free;
        raise;
      end;
    end else
    begin
      Warning(gsWarning, sBadBlock);
      break;
    end;
    repeat
      if (Stream.Read(b, 1) <> 1) then
        exit;
    until (b <> 0); // Ignore 0 padding (non-compliant)
  end;
  Stream.Seek(-1, soFromCurrent);
end;

procedure TGIFImageList.SaveToStream(Stream: TStream);
var
  i			: integer;
begin
  for i := 0 to Count-1 do
  begin
    TGIFItem(Items[i]).SaveToStream(Stream);
    Image.Progress(Self, psRunning, (i+1) * 100 DIV Count, False, Rect(0,0,0,0), sProgressSaving);
  end;
end;

constructor TGIFPainter.CreateRef(var Painter: TGIFPainter; AImage: TGIFImage;
  ACanvas: TCanvas; ARect: TRect; Options: TGIFDrawOptions);
begin
  Create(AImage, ACanvas, ARect, Options);
  PainterRef := @Painter;
  if (PainterRef <> nil) then
    PainterRef^ := self;
end;

constructor TGIFPainter.Create(AImage: TGIFImage; ACanvas: TCanvas; ARect: TRect;
  Options: TGIFDrawOptions);
var
  i			: integer;
  BackgroundColor	: TColor;
  Disposals		: set of TDisposalMethod;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FImage := AImage;
  FCanvas := ACanvas;
  FRect := ARect;
  FActiveImage := -1;
  FDrawOptions := Options;
  FStarted := False;
  BackupBuffer := nil;
  FrameBuffer := nil;
  Background := nil;
  DelayEvent := 0;

  if (FDrawOptions >= [goAnimate, goAsync]) and (FImage.Images.Count > 1) then
    DelayEvent := CreateEvent(nil, False, False, nil);

  // Preprocessing of extensions to determine if we need frame buffers
  Disposals := [];
  if (FImage.DrawBackgroundColor = clNone) then
  begin
    if (FImage.GlobalColorMap.Count > 0) then
      BackgroundColor := FImage.BackgroundColor
    else
      BackgroundColor := ColorToRGB(clWindow);
  end else
    BackgroundColor := ColorToRGB(FImage.DrawBackgroundColor);

  for i := 0 to FImage.Images.Count-1 do
    if (FImage.Images[i].GraphicControlExtension <> nil) then
      with (FImage.Images[i].GraphicControlExtension) do
        Include(Disposals, Disposal);

  // Need background buffer to draw transparent on background
  if (dmBackground in Disposals) and (goTransparent in FDrawOptions) then
  begin
    Background := TBitmap.Create;
    Background.Height := FRect.Bottom-FRect.Top;
    Background.Width := FRect.Right-FRect.Left;
{$IFNDEF VER90}
    Background.Transparent := False;
{$ENDIF}
    // Copy background immediately
    Background.Canvas.CopyMode := cmSrcCopy;
    Background.Canvas.CopyRect(Background.Canvas.ClipRect, FCanvas, FRect);
  end;
  // Need frame- and backup buffer to restore to previous and background
  if ((Disposals * [dmPrevious, dmBackground]) <> []) then
  begin
    BackupBuffer := TBitmap.Create;
    BackupBuffer.Height := FRect.Bottom-FRect.Top;
    BackupBuffer.Width := FRect.Right-FRect.Left;
    BackupBuffer.Canvas.CopyMode := cmSrcCopy;
    BackupBuffer.Canvas.Brush.Color := BackgroundColor;
    BackupBuffer.Canvas.Brush.Style := bsSolid;
{$IFNDEF VER90}
    BackupBuffer.Transparent := False;
{$ENDIF}
{$IFDEF DEBUG}
    BackupBuffer.Canvas.Brush.Color := clBlack;
    BackupBuffer.Canvas.Brush.Style := bsDiagCross;
    SetBkColor(BackupBuffer.Canvas.Handle, ColorToRGB(BackgroundColor));
{$ENDIF}
    // Step 1: Copy destination to backup buffer
    //         Always executed before first frame and only once.
    BackupBuffer.Canvas.CopyRect(BackupBuffer.Canvas.ClipRect, FCanvas, FRect);
    FrameBuffer := TBitmap.Create;
    FrameBuffer.Height := FRect.Bottom-FRect.Top;
    FrameBuffer.Width := FRect.Right-FRect.Left;
    FrameBuffer.Canvas.CopyMode := cmSrcCopy;
    FrameBuffer.Canvas.Brush.Color := BackgroundColor;
    FrameBuffer.Canvas.Brush.Style := bsSolid;
{$IFNDEF VER90}
    FrameBuffer.Transparent := False;
{$ENDIF}
{$IFDEF DEBUG}
    FrameBuffer.Canvas.Brush.Color := clBlack;
    FrameBuffer.Canvas.Brush.Style := bsDiagCross;
    SetBkColor(FrameBuffer.Canvas.Handle, ColorToRGB(BackgroundColor));
{$ENDIF}
  end;
end;

destructor TGIFPainter.Destroy;
begin
  // Zap pointer to self and remove from painter list
  DoSynchronize(DoZap);

  if (DelayEvent <> 0) then
    CloseHandle(DelayEvent);

  inherited Destroy;
end;

// Conditional Synchronize
procedure TGIFPainter.DoSynchronize(Method: TThreadMethod);
begin
  if (goAsync in FDrawOptions) then
    // Execute Synchronized if requested...
    Synchronize(Method)
  else
    // ...Otherwise just execute in current thread (probably main thread)
    Method;
end;

// Delete frame buffers
procedure TGIFPainter.DoZap;
begin
  if (PainterRef <> nil) and (PainterRef^ = self) then
    PainterRef^ := nil;

  if (FImage <> nil) then
  begin
    FImage.FPainters.Remove(self);
    FImage := nil;
  end;

  if (BackupBuffer <> nil) then
    BackupBuffer.Free;
  if (FrameBuffer <> nil) then
    FrameBuffer.Free;
  if (Background <> nil) then
    Background.Free;
end;

procedure TGIFPainter.DoEvent;
begin
  if (Assigned(FEvent)) then
    FEvent(self);
end;

// Non-buffered paint
procedure TGIFPainter.DoPaint;
begin
  if (goValidateCanvas in FDrawOptions) then
    if (GetObjectType(ValidateDC) <> OBJ_DC) then
    begin
      Terminate;
      exit;
    end;
  FImage.Images[ActiveImage].Draw(FCanvas, FRect, (goTransparent in FDrawOptions));
  FStarted := True;
end;

// Buffered paint
procedure TGIFPainter.DoPaintFrame;
var
  DrawDestination	: TCanvas;
  DrawRect		: TRect;
  DoStep3		,
  DoStep5		,
  DoStep6		: boolean;
  SavePal		,
  SourcePal		: HPALETTE;
  r			: TRect;
begin
  if (goValidateCanvas in FDrawOptions) then
    if (GetObjectType(ValidateDC) <> OBJ_DC) then
    begin
      Terminate;
      exit;
    end;

  DrawDestination := nil;
  DoStep3 := False;
  DoStep5 := False;
  DoStep6 := False;
{
Disposal mode state machine:

Step 1: Copy destination to backup buffer
        Always executed before first frame and only once.
        Done in constructor.
Step 2: Clear previous frame (not used here)
Step 3: Copy backup buffer to frame buffer
Step 4: Draw frame
Step 5: Copy buffer to destination
Step 6: Clear frame from backup buffer
+------------+------------------+---------------------+------------------------+
|New  \  Old |  dmNone          |  dmBackground       |  dmPrevious            |
+------------+------------------+---------------------+------------------------+
|dmNone      |                  |                     |                        |
|            |4. Paint on backup|4. Paint on backup   |4. Paint on backup      |
|            |5. Restore        |5. Restore           |5. Restore              |
+------------+------------------+---------------------+------------------------+
|dmBackground|                  |                     |                        |
|            |4. Paint on backup|4. Paint on backup   |4. Paint on backup      |
|            |5. Restore        |5. Restore           |5. Restore              |
|            |6. Clear backup   |6. Clear backup      |6. Clear backup         |
+------------+------------------+---------------------+------------------------+
|dmPrevious  |                  |                     |                        |
|            |                  |3. Copy backup to buf|3. Copy backup to buf   |
|            |4. Paint on dest  |4. Paint on buf      |4. Paint on buf         |
|            |                  |5. Copy buf to dest  |5. Copy buf to dest     |
+------------+------------------+---------------------+------------------------+
}
  case (Disposal) of
    dmNone, dmNoDisposal:
    begin
      DrawDestination := BackupBuffer.Canvas;
      DrawRect := BackupBuffer.Canvas.ClipRect;
      DoStep5 := True;
    end;
    dmBackground:
    begin
      DrawDestination := BackupBuffer.Canvas;
      DrawRect := BackupBuffer.Canvas.ClipRect;
      DoStep5 := True;
      DoStep6 := True;
    end;
    dmPrevious:
      case (OldDisposal) of
        dmNone, dmNoDisposal:
        begin
          DrawDestination := FCanvas;
          DrawRect := FRect;
        end;
        dmBackground,
        dmPrevious:
        begin
          DrawDestination := FrameBuffer.Canvas;
          DrawRect := FrameBuffer.Canvas.ClipRect;
          DoStep3 := True;
          DoStep5 := True;
        end;
      end;
  end;

  // Find source palette
  SourcePal := FImage.Images[ActiveImage].Palette;
  if (SourcePal = 0) then
    SourcePal := SystemPalette16; // This should never happen

  SavePal := SelectPalette(DrawDestination.Handle, SourcePal, False);
  RealizePalette(DrawDestination.Handle);

  // Step 3: Copy backup buffer to frame buffer
  if (DoStep3) then
    FrameBuffer.Canvas.CopyRect(FrameBuffer.Canvas.ClipRect,
      BackupBuffer.Canvas, BackupBuffer.Canvas.ClipRect);

  // Step 4: Draw frame
  if (DrawDestination <> nil) then
    FImage.Images[ActiveImage].Draw(DrawDestination, DrawRect, (goTransparent in FDrawOptions));

  // Step 5: Copy buffer to destination
  if (DoStep5) then
  begin
    FCanvas.CopyMode := cmSrcCopy;
    FCanvas.CopyRect(FRect, DrawDestination, DrawRect);
  end;

  if (SavePal <> 0) then
    SelectPalette(DrawDestination.Handle, SavePal, False);

  // Step 6: Clear frame from backup buffer
  if (DoStep6) then
  begin
    if (goTransparent in FDrawOptions) then
    begin
//      BackupBuffer.Canvas.CopyRect(BackupBuffer.Canvas.ClipRect,
//        Background.Canvas, Background.Canvas.ClipRect)
      r := FImage.Images[ActiveImage].ScaleRect(BackupBuffer.Canvas.ClipRect);
      BackupBuffer.Canvas.CopyRect(r, Background.Canvas, r)
    end else
      BackupBuffer.Canvas.FillRect(FImage.Images[ActiveImage].ScaleRect(FRect));
  end;

  FStarted := True;
end;

// Prefetch bitmap
// Used to force the GIF image to be rendered as a bitmap
procedure TGIFPainter.PrefetchBitmap;
begin
  FImage.Images[ActiveImage].Bitmap;
end;

procedure TGIFPainter.Execute;
var
  i			: integer;
  LoopCount		,
  LoopPoint		: integer;
  Looping		: boolean;
  Ext			: TGIFExtension;
  Delay			: integer;
  Msg			: TMsg;
  DelayUsed		,
  DelayStart		: longInt;

  procedure FireEvent(Event: TNotifyEvent);
  begin
    if not(Assigned(Event)) then
      exit;
    FEvent := Event;
    try
      DoSynchronize(DoEvent);
    finally
      FEvent := nil;
    end;
  end;

begin
{
  Disposal:
    dmNone: Same as dmNodisposal
    dmNoDisposal: Do not dispose
    dmBackground: Clear with background color *)
    dmPrevious: Previous image
    *) Note: Background color should either be a BROWSER SPECIFIED Background
       color (DrawBackgroundColor) or the background image if any frames are
       transparent.
}
  try
    try
      if (goValidateCanvas in FDrawOptions) then
        ValidateDC := FCanvas.Handle;
      DoRestart := True;

      // Loop to restart paint
      while (DoRestart) and not(Terminated) do
      begin
        // Fire OnStartPaint event
        FireEvent(FOnStartPaint);

        DoRestart := False;
        LoopCount := 1;
        LoopPoint := 0;
        Looping := False;
        if (goAsync in DrawOptions) then
          Delay := 0
        else
          Delay := 1; // Dummy to process messages
        OldDisposal := dmNoDisposal;
        FStarted := False;
        // Fetch delay start time
        DelayStart := GetTickCount;

        // Loop to loop - duh!
        while ((LoopCount <> 0) or (goLoopContinously in DrawOptions)) and
          not(Terminated or DoRestart) do
        begin
          // Fire OnLoopPaint event
          if (FStarted) then
            FireEvent(FOnLoop);

          FActiveImage := LoopPoint;
          // Loop to animate
          while (ActiveImage < FImage.Images.Count) and not(Terminated or DoRestart) do
          begin
            // Ignore empty images
            if (FImage.Images[ActiveImage].Empty) then
              break;
            // Delay from previous image
            if (Delay > 0) then
            begin
              // Prefetch frame bitmap
              DoSynchronize(PrefetchBitmap);
              // Calculate number of mS used in prefetch
              DelayUsed := GetTickCount-DelayStart;
              // Convert delay value to mS and...
              // ...Adjust for time already spent converting GIF to bitmap.
              Delay := Delay * GIFDelayExp - DelayUsed;

              // Sleep in one chunk if we are running in a thread
              if (goAsync in DrawOptions) then
              begin
                // Use of WaitForSingleObject allows TGIFPainter.Stop to wake us up
                if (Delay > 0) then
                  if (WaitForSingleObject(DelayEvent, Delay) <> WAIT_TIMEOUT) then
                    exit;
              end else
              begin
                if (Delay <= 0) then
                  Delay := 1;
                // Fetch start time
                DelayUsed := GetTickCount;
                // If we are not running in a thread we Sleep in small chunks
                // and give the user a chance to abort
                while (Delay > 0) and not(Terminated) do
                begin
                  Sleep(100);
                  // Calculate number of mS delayed in this chunk
                  DelayUsed := GetTickCount-DelayUsed;
                  dec(Delay, DelayUsed);
                  // Reset start time for chunk
                  DelayUsed := GetTickCount;
                  // Application.ProcessMessages wannabe
                  while (not Terminated) and (PeekMessage(Msg, 0, 0, 0, PM_REMOVE)) do
                  begin
                    if (Msg.Message <> WM_QUIT) then
                    begin
                      TranslateMessage(Msg);
                      DispatchMessage(Msg);
                    end else
                    begin
                      // Put WM_QUIT back in queue and get out of here fast
                      PostQuitMessage(Msg.WParam);
                      Terminate;
                    end;
                  end;
                end;
              end;
            end else
              Sleep(0); // Yield
            if (Terminated) then
              exit;

            // Fetch delay start time
            DelayStart := GetTickCount;

            // Pre-draw processing of extensions
            Disposal := dmNoDisposal;
            for i := 0 to FImage.Images[ActiveImage].Extensions.Count-1 do
            begin
              Ext := FImage.Images[ActiveImage].Extensions[i];
              if (Ext is TGIFAppExtNSLoop) then
              begin
                // Recursive loops not supported (or defined)
                if (Looping) then
                  continue;
                Looping := True;
                LoopCount := TGIFAppExtNSLoop(Ext).Loops;
                if ((LoopCount = 0) or (goLoopContinously in DrawOptions)) and
                  (goAsync in DrawOptions) then
                  LoopCount := -1; // Infinite if running in separate thread
  {$IFNDEF STRICT_MOZILLA}
                // Loop from this image and on
                // Note: This is not standard behavior
                LoopPoint := ActiveImage;
  {$ENDIF}
              end else
              if (Ext is TGIFGraphicControlExtension) then
                Disposal := TGIFGraphicControlExtension(Ext).Disposal;
            end;
            // Fire OnPaint event
            FireEvent(FOnPaint);
            if (Terminated) then
              exit;
            // Paint the image
            if (BackupBuffer <> nil) then
              DoSynchronize(DoPaintFrame)
            else
              DoSynchronize(DoPaint);
            OldDisposal := Disposal;

            // Nothing more to do unless we are animating
            if not(goAnimate in DrawOptions) then
              break;
            if (Terminated) then
              exit;

            Delay := GIFDefaultDelay; // Default delay
            // Post-draw processing of extensions
            if (FImage.Images[ActiveImage].GraphicControlExtension <> nil) then
              if (FImage.Images[ActiveImage].GraphicControlExtension.Delay > 0) then
              begin
                Delay := FImage.Images[ActiveImage].GraphicControlExtension.Delay;

                // Enforce minimum animation delay in compliance with Mozilla
                if (Delay < GIFMinimumDelay) then
                  Delay := GIFMinimumDelay;

                // Do not delay more than 10 seconds if running in main thread
                if (Delay > GIFMaximumDelay) and not(goAsync in DrawOptions) then
                  Delay := GIFMaximumDelay; // Max 10 seconds
              end;
            Inc(FActiveImage);
          end;

          if (LoopCount > 0) then
            Dec(LoopCount);
          if ([goAnimate, goLoop] * DrawOptions <> [goAnimate, goLoop]) then
            break;
        end;
      end;
      FActiveImage := -1;
      // Fire OnEndPaint event
      FireEvent(FOnEndPaint);
    finally
      // If we are running in the main thread we will have to zap our self
      if not(goAsync in DrawOptions) then
        Free;
    end;
  except
    // Eat exception and terminate thread
    Terminate;
    // If we allow the exception to abort the thread at this point, the
    // application will hang since the thread destructor will never be called
    // and the application will wait forever for the thread to die!
  end;
end;

procedure TGIFPainter.Start;
begin
  if (goAsync in FDrawOptions) then
    Resume;
end;

procedure TGIFPainter.Stop;
begin
  Terminate;
  if (goAsync in FDrawOptions) then
  begin
    // Signal WaitForSingleObject delay to abort
    if (DelayEvent <> 0) then
      SetEvent(DelayEvent);
    if (Suspended) then
      Resume; // Must be running before we can terminate
  end;
end;

procedure TGIFPainter.Restart;
begin
  DoRestart := True;
  if (Suspended) and (goAsync in FDrawOptions) then
    Resume; // Must be running before we can terminate
end;

(*
*)
constructor TGIFImage.Create;
begin
  inherited Create;
  FImages := TGIFImageList.Create(self);
  FHeader := TGIFHeader.Create(self);
  FPainters := TThreadList.Create;
  FGlobalPalette := 0;
  FDrawOptions := GIFImageDefaultDrawOptions;
  FThreadPriority := GIFImageDefaultThreadPriority;
  FDrawBackgroundColor := clNone;
  IsDrawing := False;
  IsInsideGetPalette := False;
  NewImage;
end;

destructor TGIFImage.Destroy;
var
  i			: integer;
begin
  PaintStop;
  with FPainters.LockList do
    try
      for i := Count-1 downto 0 do
        TGIFPainter(Items[i]).FImage := nil;
    finally
      FPainters.UnLockList;
    end;

  Clear;
  FPainters.Free;
  FImages.Free;
  FHeader.Free;
  inherited Destroy;
end;

procedure TGIFImage.Clear;
begin
  PaintStop;
  FreeBitmap;
  FImages.Clear;
  FHeader.ColorMap.Clear;
  FHeader.Height := 0;
  FHeader.Width := 0;
  FHeader.Prepare;
  Palette := 0;
end;

procedure TGIFImage.NewImage;
begin
  Clear;
end;

function TGIFImage.GetVersion: TGIFVersion;
var
  v			: TGIFVersion;
  i			: integer;
begin
  Result := gvUnknown;
  for i := 0 to FImages.Count-1 do
  begin
    v := FImages[i].Version;
    if (v > Result) then
      Result := v;
    if (v >= high(TGIFVersion)) then
      break;
  end;
end;

function TGIFImage.GetColorResolution: integer;
var
  i			: integer;
begin
  Result := FHeader.ColorResolution;
  for i := 0 to FImages.Count-1 do
    if (FImages[i].ColorResolution > Result) then
      Result := FImages[i].ColorResolution;
end;

function TGIFImage.GetBitsPerPixel: integer;
var
  i			: integer;
begin
  Result := FHeader.BitsPerPixel;
  for i := 0 to FImages.Count-1 do
    if (FImages[i].BitsPerPixel > Result) then
      Result := FImages[i].BitsPerPixel;
end;

function TGIFImage.GetBackgroundColorIndex: BYTE;
begin
  Result := FHeader.BackgroundColorIndex;
end;

function TGIFImage.GetBackgroundColor: TColor;
begin
  Result := FHeader.BackgroundColor;
end;

procedure TGIFImage.SetDrawOptions(Value: TGIFDrawOptions);
begin
  if (FDrawOptions = Value) then
    exit;

  if (DrawPainter <> nil) then
    DrawPainter.Stop;

  FDrawOptions := Value;
  // Zap all bitmaps
  Pack;
  Changed(self);
end;

procedure TGIFImage.Pack;
var
  i			: integer;
begin
  // Zap bitmaps and palettes
  FreeBitmap;
  Palette := 0;
  for i := 0 to FImages.Count-1 do
  begin
    FImages[i].Bitmap := nil;
    FImages[i].Palette := 0;
  end;

  // Only pack if no global colormap and a single image
  if (FHeader.ColorMap.Count > 0) or (FImages.Count <> 1) then
    exit;

  // Copy local colormap to global
  FHeader.ColorMap.Assign(FImages[0].ColorMap);
  // Zap local colormap
  FImages[0].ColorMap.Clear;
end;

procedure TGIFImage.SaveToStream(Stream: TStream);
var
  n			: Integer;
begin
  Progress(Self, psStarting, 0, False, Rect(0,0,0,0), sProgressSaving);
  try
    // Write header
    FHeader.SaveToStream(Stream);
    // Write images
    FImages.SaveToStream(Stream);
    // Write trailer
    with TGIFTrailer.Create(self) do
      try
        SaveToStream(Stream);
      finally
        Free;
      end;
  finally
    if ExceptObject = nil then
      n := 100
    else
      n := 0;
    Progress(Self, psEnding, n, True, Rect(0,0,0,0), sProgressSaving);
  end;
end;

procedure TGIFImage.LoadFromStream(Stream: TStream);
var
  n			: Integer;
begin
  Progress(Self, psStarting, 0, False, Rect(0,0,0,0), sProgressLoading);
  try
    // Zap old image
    Clear;
    // Read header
    FHeader.LoadFromStream(Stream);
    // Read images
    FImages.LoadFromStream(Stream, self);
    // Read trailer
    with TGIFTrailer.Create(self) do
      try
        LoadFromStream(Stream);
      finally
        Free;
      end;
  finally
    if ExceptObject = nil then
      n := 100
    else
      n := 0;
    Progress(Self, psEnding, n, True, Rect(0,0,0,0), sProgressLoading);
  end;
end;

function TGIFImage.GetBitmap: TBitmap;
begin
  if not(Empty) then
  begin
    Result := FBitmap;
    if (Result <> nil) then
      exit;
    FBitmap := TBitmap.Create;
    Result := FBitmap;
    FBitmap.OnChange := Changed;
    // Use first image as default
    if (Images.Count > 0) then
    begin
      if (Images[0].Width = Width) and (Images[0].Height = Height) then
      begin
        // Use first image as it has same dimensions
        FBitmap.Assign(Images[0].Bitmap);
      end else
      begin
        // Draw first image on bitmap
        FBitmap.Palette := CopyPalette(Palette);
        FBitmap.Height := Height;
        FBitmap.Width := Width;
{$IFNDEF VER90}
        FBitmap.Transparent := False;
{$ENDIF}
        Images[0].Draw(FBitmap.Canvas, FBitmap.Canvas.ClipRect, False);
      end;
    end;
  end else
    Result := nil
end;

// Create a new (empty) bitmap
function TGIFImage.NewBitmap: TBitmap;
begin
  Result := FBitmap;
  if (Result <> nil) then
    exit;
  FBitmap := TBitmap.Create;
  Result := FBitmap;
  FBitmap.OnChange := Changed;
  // Draw first image on bitmap
  FBitmap.Palette := CopyPalette(Palette);
  FBitmap.Height := Height;
  FBitmap.Width := Width;
{$IFNDEF VER90}
  FBitmap.Transparent := False;
{$ENDIF}
end;

procedure TGIFImage.FreeBitmap;
begin
  if (DrawPainter <> nil) then
    DrawPainter.Stop;

  if (FBitmap <> nil) then
  begin
    FBitmap.Free;
    FBitmap := nil;
  end;
end;

function TGIFImage.Add(Source: TPersistent): integer;
var
  Image			: TGIFSubImage;
  HasChanged		: boolean;
begin
  if not((Source is TBitmap) or (Source is TGIFSubImage)) then
    Error(sUnsupportedClass);
  if (Source is TBitmap) then
  begin
    Image := TGIFSubImage.Create(self);
    Image.Assign(Source);
  end else
    Image := TGIFSubImage(Source);
  Result := FImages.Add(Image);
  HasChanged := False;
  // Set width & height if added image is larger than existing images
{$IFDEF STRICT_MOZILLA}
  // From Mozilla source:
  // Work around broken GIF files where the logical screen
  // size has weird width or height. [...]
  if (FHeader.Width < Image.Width) or (FHeader.Height < Image.Height) then
  begin
    HasChanged := True;
    FHeader.Width := Image.Width;
    FHeader.Height := Image.Height;
    Image.Left := 0;
    Image.Top := 0;
  end;
{$ELSE}
  if (FHeader.Width < Image.Left+Image.Width) then
  begin
    HasChanged := True;
    FHeader.Width := Image.Left+Image.Width;
    Warning(self, gsWarning, sBadWidth)
  end;
  if (FHeader.Height < Image.Top+Image.Height) then
  begin
    HasChanged := True;
    FHeader.Height := Image.Top+Image.Height;
    Warning(self, gsWarning, sBadHeight)
  end;
{$ENDIF}

  if (HasChanged) then
  begin
    Warning(Image, gsWarning, sScreenSizeExceeded);
    FreeBitmap;
    Changed(self);
  end;
end;

function TGIFImage.GetEmpty: Boolean;
begin
  Result := (FImages.Count = 0);
end;

function TGIFImage.GetHeight: Integer;
begin
  Result := FHeader.Height;
end;

function TGIFImage.GetWidth: Integer;
begin
  Result := FHeader.Width;
end;

function TGIFImage.Equals(Graphic: TGraphic): Boolean;
begin
  Result := (Graphic = self);
end;

function TGIFImage.GetPalette: HPALETTE;
begin
  // Check for recursion
  // (TGIFImage.GetPalette->TGIFSubImage.GetPalette->TGIFImage.GetPalette etc...)
  if (IsInsideGetPalette) then
    Error(sNoColorTable);
  IsInsideGetPalette := True;
  try
    Result := 0;
    if (FBitmap <> nil) and (FBitmap.Palette <> 0) then
      // Use bitmaps own palette if possible
      Result := FBitmap.Palette
    else if (FGlobalPalette <> 0) then
      // Or a previously exported global palette
      Result := FGlobalPalette
    else if (DoDither) then
    begin
      // or create a new dither palette
      FGlobalPalette := WebPalette;
      Result := FGlobalPalette;
    end else
    if (FHeader.ColorMap.Count > 0) then
    begin
      // or create a new if first time
      FGlobalPalette := FHeader.ColorMap.ExportPalette;
      Result := FGlobalPalette;
    end else
    if (FImages.Count > 0) then
      // This can cause a recursion if no global palette exist and image[0]
      // hasn't got one either. Checked by the IsInsideGetPalette semaphor.
      Result := FImages[0].Palette;
  finally
    IsInsideGetPalette := False;
  end;
end;

procedure TGIFImage.SetPalette(Value: HPalette);
var
  NeedNewBitmap		: boolean;
begin
  if (Value <> FGlobalPalette) then
  begin
    // Zap old palette
    if (FGlobalPalette <> 0) then
      DeleteObject(FGlobalPalette);

    // Zap bitmap unless new palette is same as bitmaps own
    NeedNewBitmap := (FBitmap <> nil) and (Value <> FBitmap.Palette);
    if (NeedNewBitmap) then
      FreeBitmap;

    // Use new palette
    FGlobalPalette := Value;

    if (NeedNewBitmap) then
    begin
      // Need to create new bitmap and repaint
      PaletteModified := True;
      Changed(Self);
    end;
  end;
end;

procedure TGIFImage.Changed(Sender: TObject);
begin
  inherited Changed(Sender);
end;

procedure TGIFImage.SetHeight(Value: Integer);
var
  i			: integer;
begin
  for i := 0 to Images.Count-1 do
    if (Images[i].Top + Images[i].Height > Value) then
      Error(sBadHeight);
  Header.Height := Value;
  FreeBitmap;
  Changed(self);
end;

procedure TGIFImage.SetWidth(Value: Integer);
var
  i			: integer;
begin
  for i := 0 to Images.Count-1 do
    if (Images[i].Left + Images[i].Width > Value) then
      Error(sBadWidth);
  Header.Width := Value;
  FreeBitmap;
  Changed(self);
end;

procedure TGIFImage.AssignTo(Dest: TPersistent);
begin
  if (Dest is TBitmap) then
    Dest.Assign(Bitmap)
  else
    inherited AssignTo(Dest);
end;

procedure TGIFImage.Assign(Source: TPersistent);
var
  i			: integer;
  Image			: TGIFSubImage;
  Bitmap		: TBitmap;
begin
  if (Source is TGIFImage) then
  begin
    Clear;
    OnProgress := TGIFImage(Source).OnProgress;
    Progress(Self, psStarting, 0, False, Rect(0,0,0,0), sProgressCopying);
    try
      OnChange := TGIFImage(Source).OnChange;
      FOnWarning := TGIFImage(Source).OnWarning;
      FHeader.Assign(TGIFImage(Source).Header);
      FThreadPriority := TGIFImage(Source).ThreadPriority;
      FDrawBackgroundColor := TGIFImage(Source).DrawBackgroundColor;
      FDrawOptions := TGIFImage(Source).DrawOptions;

      for i := 0 to TGIFImage(Source).Images.Count-1 do
      begin
        Image := TGIFSubImage.Create(self);
        Image.Assign(TGIFImage(Source).Images[i]);
        Add(Image);
        Progress(Self, psRunning, (i+1) * 100 DIV TGIFImage(Source).Images.Count, False, Rect(0,0,0,0), sProgressCopying);
      end;
    finally
      if ExceptObject = nil then
        i := 100
      else
        i := 0;
      Progress(Self, psEnding, i, False, Rect(0,0,0,0), sProgressCopying);
    end;
  end else
  if (Source is TBitmap) then
  begin
    Clear;
    Add(Source);
  end else
  if (Source is TGraphic) then
  begin
    Bitmap := TBitmap.Create;
    try
      Bitmap.Assign(Source);
      Clear;
      Add(Bitmap);
    finally
      Bitmap.Free;
    end;
  end else
    inherited Assign(Source);
end;

procedure TGIFImage.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);
{$IFDEF REGISTER_TGIFIMAGE}
var
  Data			: THandle;
  Size			: Longint;
  Buffer		: Pointer;
  Stream		: TMemoryStream;
  Bmp			: TBitmap;
begin
  Data := GetClipboardData(CF_GIF);
  if (Data <> 0) then
  begin
    // Get size and pointer to data
    Size := GlobalSize(Data);
    Buffer := GlobalLock(Data);
    try
      Stream := TMemoryStream.Create;
      try
        // Copy data to a stream
        Stream.SetSize(Size);
        Move(Buffer^, Stream.Memory^, Size);
        // Load GIF from stream
        LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
    finally
      GlobalUnlock(Data);
    end;
  end else
  begin
    // No GIF on clipboard - try loading a bitmap instead
    Bmp := TBitmap.Create;
    try
      Bmp.LoadFromClipboardFormat(AFormat, AData, APalette);
      Assign(Bmp);
    finally
      Bmp.Free;
    end;
  end;
end;
{$ELSE}
begin
  Error(sGIFToClipboard);
end;
{$ENDIF}

procedure TGIFImage.SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
  var APalette: HPALETTE);
{$IFDEF REGISTER_TGIFIMAGE}
var
  Stream		: TMemoryStream;
  Data			: THandle;
  Buffer		: Pointer;
begin
  if (Empty) then
    exit;
  // First store a bitmap version on the clipboard...
  Bitmap.SaveToClipboardFormat(AFormat, AData, APalette);
  // ...then store a GIF
  Stream := TMemoryStream.Create;
  try
    // Save the GIF to a memory stream
    SaveToStream(Stream);
    Stream.Position := 0;
    // Allocate some memory for the GIF data
    Data := GlobalAlloc(HeapAllocFlags, Stream.Size);
    try
      if (Data <> 0) then
      begin
        Buffer := GlobalLock(Data);
        try
          // Copy the GIF data to the memory
          Move(Stream.Memory^, Buffer^, Stream.Size);
          // Put it all on the clipboard
          SetClipboardData(CF_GIF, Data);
        finally
          GlobalUnlock(Data);
        end;
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    Stream.Free;
  end;
end;
{$ELSE}
begin
  Error(sGIFToClipboard);
end;
{$ENDIF}

function TGIFImage.GetColorMap: TGIFColorMap;
begin
  Result := FHeader.ColorMap;
end;

function TGIFImage.GetDoDither: boolean;
begin
  Result := (goDither in DrawOptions) and
    (((goAutoDither in DrawOptions) and DoAutoDither) or
      not(goAutoDither in DrawOptions));
end;

{$IFDEF VER90}
procedure TGIFImage.Progress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
  if Assigned(FOnProgress) then
    FOnProgress(Sender, Stage, PercentDone, RedrawNow, R, Msg);
end;
{$ENDIF}

procedure TGIFImage.StopDraw;
var
  Msg			: TMsg;
begin
  if (FDrawPainter <> nil) then
  begin
    if (goAsync in FDrawPainter.DrawOptions) then
    begin
      while (FDrawPainter <> nil) do
      begin
        FDrawPainter.Stop;
        // Process Messages to make Synchronize work
        // (Instead of Application.ProcessMessages)
        while PeekMessage(Msg, 0, CM_EXECPROC, CM_EXECPROC, PM_REMOVE) do
        begin
          if (Msg.Message <> WM_QUIT) then
          begin
            TranslateMessage(Msg);
            DispatchMessage(Msg);
          end else
            exit;
        end;
      end;
      FreeBitmap;
    end else
      FDrawPainter.Stop;
  end else
end;

procedure TGIFImage.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  Canvas		: TCanvas;
  Msg			: TMsg;
  DestRect		: TRect;
begin
  // Prevent recursion(s(s(s)))
  if (IsDrawing) or (FImages.Count = 0) then
    exit;

  IsDrawing := True;
  try
    // Copy bitmap to canvas if we are already drawing
    // (or have drawn but are finished)
    if (FImages.Count = 1) or // Only one image
      (not (goAnimate in FDrawOptions)) then // Don't animate
    begin
      FImages[0].Draw(ACanvas, Rect, (goTransparent in FDrawOptions));
      exit;
    end else
    if (FBitmap <> nil) and not(goDirectDraw in FDrawOptions) then
    begin
      ACanvas.StretchDraw(Rect, Bitmap);
      exit;
    end;

    // If we are already painting on the canvas in goDirectDraw mode
    // and at the same location, just exit and let the painter do
    // its thing when it's ready
    if (FDrawPainter <> nil) and (FDrawPainter.Canvas = ACanvas) and
      EqualRect(FDrawPainter.Rect, Rect) then
      exit;

    StopDraw;

    if not(goDirectDraw in FDrawOptions) then
    begin
      // Create a bitmap to draw on
      NewBitmap;
      Canvas := FBitmap.Canvas;
      DestRect := Canvas.ClipRect;
      // Initialize bitmap canvas with background image
      Canvas.CopyRect(DestRect, ACanvas, Rect);
    end else
    begin
      Canvas := ACanvas;
      DestRect := Rect;
    end;

    // Create new paint thread
    InternalPaint(FDrawPainter, Canvas, DestRect, FDrawOptions);
//    InternalPaint(FDrawPainter, Canvas, Canvas.ClipRect, FDrawOptions);
    if (FDrawPainter <> nil) then
    begin
      // Launch thread
      FDrawPainter.Start;

      if not(goDirectDraw in FDrawOptions) then
      begin
        // Wait for thread to render first frame
        while (FDrawPainter <> nil) and (not FDrawPainter.Terminated) and
          (not FDrawPainter.Started) do
          // Process Messages to make Synchronize work
          // (Instead of Application.ProcessMessages)
          if PeekMessage(Msg, 0, CM_EXECPROC, CM_EXECPROC, PM_REMOVE) then
          begin
            if (Msg.Message <> WM_QUIT) then
            begin
              TranslateMessage(Msg);
              DispatchMessage(Msg);
            end else
              exit;
          end else
            Sleep(0); // Yield
        // Draw frame to destination
        ACanvas.StretchDraw(Rect, Bitmap);
      end;
    end;
  finally
    IsDrawing := False;
  end;
end;

// Internal pain(t) routine used by Draw()
function TGIFImage.InternalPaint(var Painter: TGifPainter; ACanvas: TCanvas;
  const Rect: TRect; Options: TGIFDrawOptions): TGIFPainter;
begin
  if (Empty) or (Rect.Left >= Rect.Right) or (Rect.Top >= Rect.Bottom) then
  begin
    Painter := nil;
    Result := Painter;
    exit;
  end;

  // Draw in main thread if only one image
  if (Images.Count = 1) then
    Options := Options - [goAsync];

  Painter := TGIFPainter.CreateRef(Painter, self, ACanvas, Rect, Options);
  FPainters.Add(Painter);
  Result := Painter;
  Painter.OnStartPaint := FOnStartPaint;
  Painter.OnPaint := FOnPaint;
  Painter.OnLoop := FOnLoop;
  Painter.OnEndPaint := FOnEndPaint;

  if not(goAsync in Options) then
  begin
    // Run in main thread
    Painter.Execute;
    // No need for thread anymore
    if (Painter <> nil) then
    begin
      // This shouldn't be nescesarry since the thread is deleted on exit
      // from Execute, but better safe than sorry...
      Painter.Free;
      Painter := nil;
    end;
    Result := Painter;
  end else
    Painter.Priority := FThreadPriority;
end;

function TGIFImage.Paint(ACanvas: TCanvas; const Rect: TRect;
  Options: TGIFDrawOptions): TGIFPainter;
begin
  Result := InternalPaint(Result, ACanvas, Rect, Options);
  if (Result <> nil) then
    // Run in separate thread
    Result.Start;
end;

procedure TGIFImage.PaintStart;
var
  i			: integer;
begin
  with FPainters.LockList do
    try
      for i := 0 to Count-1 do
        TGIFPainter(Items[i]).Start;
    finally
      FPainters.UnLockList;
    end;
end;

procedure TGIFImage.PaintStop;
var
  Ghosts		: integer;
  i			: integer;
  Msg			: TMsg;
begin
  try
    // Loop until all have died
    repeat
      with FPainters.LockList do
        try
          if (Count = 0) then
            exit;

          // Signal painters to terminate
          // Painters will attempt to remove them self from the
          // painter list when they die
          Ghosts := Count;
          for i := Ghosts-1 downto 0 do
          begin
            TGIFPainter(Items[i]).Stop;
            if not(goAsync in TGIFPainter(Items[i]).DrawOptions) then
              dec(Ghosts);
          end;
        finally
          FPainters.UnLockList;
        end;

      // If all painters where synchronous, there's no purpose waiting for them
      // to terminate, because they are running in the main thread.
      if (Ghosts = 0) then
        exit;

      // Process Messages to make TThread.Synchronize work
      // (Instead of Application.ProcessMessages)
      while PeekMessage(Msg, 0, CM_EXECPROC, CM_EXECPROC, PM_REMOVE) do
      begin
        if (Msg.Message <> WM_QUIT) then
        begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end else
          exit;
      end;
    until (False);
  finally
    FreeBitmap;
  end;
end;

procedure TGIFImage.PaintPause;
var
  i			: integer;
begin
  with FPainters.LockList do
    try
      for i := 0 to Count-1 do
        TGIFPainter(Items[i]).Suspend;
    finally
      FPainters.UnLockList;
    end;
end;

procedure TGIFImage.PaintResume;
var
  i			: integer;
begin
  with FPainters.LockList do
    try
      for i := 0 to Count-1 do
        TGIFPainter(Items[i]).Start;
    finally
      FPainters.UnLockList;
    end;
end;

procedure TGIFImage.Warning(Sender: TObject; Severity: TGIFSeverity; Message: string);
begin
  if (Assigned(FOnWarning)) then
    FOnWarning(Sender, Severity, Message);
end;

var
  DesktopDC: HDC;

initialization
{$IFDEF REGISTER_TGIFIMAGE}
  TPicture.RegisterFileFormat('GIF', sGIFImageFile, TGIFImage);
  CF_GIF := RegisterClipboardFormat(PChar(sGIFImageFile));
  TPicture.RegisterClipboardFormat(CF_GIF, TGIFImage);
{$ENDIF}
  DesktopDC := GetDC(0);
  try
    DoAutoDither := (GetDeviceCaps(DesktopDC, BITSPIXEL) * GetDeviceCaps(DesktopDC, PLANES) <= 8);
  finally
    ReleaseDC(0, DesktopDC);
  end;

{$IFDEF VER90}
  // Note: This doesn't return the same palette as the Delphi 3 system palette
  // since the true system palette contains 20 entries and the Delphi 3 system
  // palette only contains 16.
  // For our purpose this doesn't matter since we do not care about the actual
  // colors (or their number) in the palette.
  // Stock objects doesn't have to be deleted.
  SystemPalette16 := GetStockObject(DEFAULT_PALETTE);
{$ENDIF}

finalization
  ExtensionList.Free;
  AppExtensionList.Free;
{$IFNDEF VER90}
  {$IFDEF REGISTER_TGIFIMAGE}
    TPicture.UnregisterGraphicClass(TGIFImage);
  {$ENDIF}
  if (pf8BitBitmap <> nil) then
    pf8BitBitmap.Free;
{$ENDIF}
end.

