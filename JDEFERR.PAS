Unit JdefErr;

{ This file defines the error and message codes for the cjpeg/djpeg
  applications.  These strings are not needed as part of the JPEG library
  proper.
  Edit this file to add new codes, or to translate the message strings to
  some other language. }

{ Original cderror.h  ; Copyright (C) 1994, Thomas G. Lane.  }

interface

{ To define the enum list of message codes, include this file without
  defining macro JMESSAGE.  To create a message string table, include it
  again with a suitable JMESSAGE definition (see jerror.c for an example). }

{ Original: jversion.h ; Copyright (C) 1991-1996, Thomas G. Lane. }
{ This file contains software version identification. }

const
  JVERSION   = '6a  7-Feb-96';

  {JCOPYRIGHT = 'Copyright (C) 1997, Vedran Rodic'; { I really don't now who to credit :-) }

  JCOPYRIGHT = ' ' ;
{ Create the message string table.
  We do this from the master message list in jerror.h by re-reading
  jerror.h with a suitable definition for macro JMESSAGE.
  The message table is made an external symbol just in case any applications
  want to refer to it directly. }

type
  J_MESSAGE_CODE  =(
    JMSG_NOMESSAGE,
    JERR_ARITH_NOTIMPL,
    JERR_BAD_ALIGN_TYPE,
    JERR_BAD_ALLOC_CHUNK,
    JERR_BAD_BUFFER_MODE,
    JERR_BAD_COMPONENT_ID,
    JERR_BAD_DCTSIZE,
    JERR_BAD_IN_COLORSPACE,
    JERR_BAD_J_COLORSPACE,
    JERR_BAD_LENGTH,
    JERR_BAD_LIB_VERSION,
    JERR_BAD_MCU_SIZE,
    JERR_BAD_POOL_ID,
    JERR_BAD_PRECISION,
    JERR_BAD_PROGRESSION,
    JERR_BAD_PROG_SCRIPT,
    JERR_BAD_SAMPLING,
    JERR_BAD_SCAN_SCRIPT,
    JERR_BAD_STATE,
    JERR_BAD_STRUCT_SIZE,
    JERR_BAD_VIRTUAL_ACCESS,
    JERR_BUFFER_SIZE,
    JERR_CANT_SUSPEND,
    JERR_CCIR601_NOTIMPL,
    JERR_COMPONENT_COUNT,
    JERR_CONVERSION_NOTIMPL,
    JERR_DAC_INDEX,
    JERR_DAC_VALUE,
    JERR_DHT_COUNTS,
    JERR_DHT_INDEX,
    JERR_DQT_INDEX,
    JERR_EMPTY_IMAGE,
    JERR_EOI_EXPECTED,
    JERR_FILE_READ,
    JERR_FILE_WRITE,
    JERR_FRACT_SAMPLE_NOTIMPL,
    JERR_HUFF_CLEN_OVERFLOW,
    JERR_HUFF_MISSING_CODE,
    JERR_IMAGE_TOO_BIG,
    JERR_INPUT_EMPTY,
    JERR_INPUT_EOF,
    JERR_MISMATCHED_QUANT_TABLE,
    JERR_MISSING_DATA,
    JERR_MODE_CHANGE,
    JERR_NOTIMPL,
    JERR_NOT_COMPILED,
    JERR_NO_BACKING_STORE,
    JERR_NO_HUFF_TABLE,
    JERR_NO_IMAGE,
    JERR_NO_QUANT_TABLE,
    JERR_NO_SOI,
    JERR_OUT_OF_MEMORY,
    JERR_QUANT_COMPONENTS,
    JERR_QUANT_FEW_COLORS,
    JERR_QUANT_MANY_COLORS,
    JERR_SOF_DUPLICATE,
    JERR_SOF_NO_SOS,
    JERR_SOF_UNSUPPORTED,
    JERR_SOI_DUPLICATE,
    JERR_SOS_NO_SOF,
    JERR_TFILE_CREATE,
    JERR_TFILE_READ,
    JERR_TFILE_SEEK,
    JERR_TFILE_WRITE,
    JERR_TOO_LITTLE_DATA,
    JERR_UNKNOWN_MARKER,
    JERR_VIRTUAL_BUG,
    JERR_WIDTH_OVERFLOW,
    JMSG_COPYRIGHT, 
    JMSG_VERSION, 
    JTRC_16BIT_TABLES,
    JTRC_ADOBE,
    JTRC_APP0,
    JTRC_APP14,
    JTRC_DAC,
    JTRC_DHT,
    JTRC_DQT,
    JTRC_DRI,
    JTRC_EOI,
    JTRC_HUFFBITS,
    JTRC_JFIF,
    JTRC_JFIF_BADTHUMBNAILSIZE,
    JTRC_JFIF_MINOR,
    JTRC_JFIF_THUMBNAIL,
    JTRC_MISC_MARKER,
    JTRC_PARMLESS_MARKER,
    JTRC_QUANTVALS,
    JTRC_QUANT_3_NCOLORS,
    JTRC_QUANT_NCOLORS,
    JTRC_QUANT_SELECTED,
    JTRC_RECOVERY_ACTION,
    JTRC_RST,
    JTRC_SMOOTH_NOTIMPL,
    JTRC_SOF,
    JTRC_SOF_COMPONENT,
    JTRC_SOI,
    JTRC_SOS,
    JTRC_SOS_COMPONENT,
    JTRC_SOS_PARAMS,
    JTRC_TFILE_CLOSE,
    JTRC_TFILE_OPEN,
    JTRC_UNKNOWN_IDS,
    JWRN_ADOBE_XFORM,
    JWRN_BOGUS_PROGRESSION,
    JWRN_EXTRANEOUS_DATA,
    JWRN_HIT_MARKER,
    JWRN_HUFF_BAD_CODE,
    JWRN_JFIF_MAJOR,
    JWRN_JPEG_EOF,
    JWRN_MUST_RESYNC,
    JWRN_NOT_SEQUENTIAL,
    JWRN_TOO_MUCH_DATA,
     JMSG_FIRSTADDONCODE,  { Must be first entry! }
     JERR_BAD_CMAP_FILE,
	    { Color map file is invalid or of unsupported format }
     JERR_TOO_MANY_COLORS,
	    { Output file format cannot handle %d colormap entries }
     JERR_UNGETC_FAILED,  { ungetc failed }
     JERR_UNKNOWN_FORMAT,  { Unrecognized input file format }
     JERR_UNSUPPORTED_FORMAT,  { Unsupported output file format }
     JMSG_LASTADDONCODE
   );


const
  JMSG_LASTMSGCODE : J_MESSAGE_CODE = JMSG_LASTADDONCODE;

type
  msg_table = Array[J_MESSAGE_CODE] of string[80];
const
  jpeg_std_message_table : msg_table = (

  { JMSG_NOMESSAGE } 'Bogus message code %d', { Must be first entry! }

{ For maintenance convenience, list is alphabetical by message code name }
  { JERR_ARITH_NOTIMPL }
	 'Sorry, there are legal restrictions on arithmetic coding',
  { JERR_BAD_ALIGN_TYPE } 'ALIGN_TYPE is wrong, please fix',
  { JERR_BAD_ALLOC_CHUNK } 'MAX_ALLOC_CHUNK is wrong, please fix',
  { JERR_BAD_BUFFER_MODE } 'Bogus buffer control mode',
  { JERR_BAD_COMPONENT_ID } 'Invalid component ID %d in SOS',
  { JERR_BAD_DCTSIZE } 'IDCT output block size %d not supported',
  { JERR_BAD_IN_COLORSPACE } 'Bogus input colorspace',
  { JERR_BAD_J_COLORSPACE } 'Bogus JPEG colorspace',
  { JERR_BAD_LENGTH } 'Bogus marker length',
  { JERR_BAD_LIB_VERSION }
	 'Wrong JPEG library version: library is %d, caller expects %d',
  { JERR_BAD_MCU_SIZE } 'Sampling factors too large for interleaved scan',
  { JERR_BAD_POOL_ID } 'Invalid memory pool code %d',
  { JERR_BAD_PRECISION } 'Unsupported JPEG data precision %d',
  { JERR_BAD_PROGRESSION }
	 'Invalid progressive parameters Ss=%d Se=%d Ah=%d Al=%d',
  { JERR_BAD_PROG_SCRIPT }
	 'Invalid progressive parameters at scan script entry %d',
  { JERR_BAD_SAMPLING } 'Bogus sampling factors',
  { JERR_BAD_SCAN_SCRIPT } 'Invalid scan script at entry %d',
  { JERR_BAD_STATE } 'Improper call to JPEG library in state %d',
  { JERR_BAD_STRUCT_SIZE }
	 'JPEG parameter struct mismatch: library thinks size is %d, caller expects %d',
  { JERR_BAD_VIRTUAL_ACCESS } 'Bogus virtual array access',
  { JERR_BUFFER_SIZE } 'Buffer passed to JPEG library is too small',
  { JERR_CANT_SUSPEND } 'Suspension not allowed here',
  { JERR_CCIR601_NOTIMPL } 'CCIR601 sampling not implemented yet',
  { JERR_COMPONENT_COUNT } 'Too many color components: %d, max %d',
  { JERR_CONVERSION_NOTIMPL } 'Unsupported color conversion request',
  { JERR_DAC_INDEX } 'Bogus DAC index %d',
  { JERR_DAC_VALUE } 'Bogus DAC value $%x',
  { JERR_DHT_COUNTS } 'Bogus DHT counts',
  { JERR_DHT_INDEX } 'Bogus DHT index %d',
  { JERR_DQT_INDEX } 'Bogus DQT index %d',
  { JERR_EMPTY_IMAGE } 'Empty JPEG image (DNL not supported)',
  { JERR_EOI_EXPECTED } 'Didn''t expect more than one scan',
  { JERR_FILE_READ } 'Input file read error',
  { JERR_FILE_WRITE } 'Output file write error --- out of disk space?',
  { JERR_FRACT_SAMPLE_NOTIMPL } 'Fractional sampling not implemented yet',
  { JERR_HUFF_CLEN_OVERFLOW } 'Huffman code size table overflow',
  { JERR_HUFF_MISSING_CODE } 'Missing Huffman code table entry',
  { JERR_IMAGE_TOO_BIG } 'Maximum supported image dimension is %d pixels',
  { JERR_INPUT_EMPTY } 'Empty input file',
  { JERR_INPUT_EOF } 'Premature end of input file',
  { JERR_MISMATCHED_QUANT_TABLE }
	 'Cannot transcode due to multiple use of quantization table %d',
  { JERR_MISSING_DATA } 'Scan script does not transmit all data',
  { JERR_MODE_CHANGE } 'Invalid color quantization mode change',
  { JERR_NOTIMPL } 'Not implemented yet',
  { JERR_NOT_COMPILED } 'Requested feature was omitted at compile time',
  { JERR_NO_BACKING_STORE } 'Backing store not supported',
  { JERR_NO_HUFF_TABLE } 'Huffman table $%02x was not defined',
  { JERR_NO_IMAGE } 'JPEG datastream contains no image',
  { JERR_NO_QUANT_TABLE } 'Quantization table $%02x was not defined',
  { JERR_NO_SOI } 'Not a JPEG file: starts with $%02x $%02x',
  { JERR_OUT_OF_MEMORY } 'Insufficient memory (case %d)',
  { JERR_QUANT_COMPONENTS }
	 'Cannot quantize more than %d color components',
  { JERR_QUANT_FEW_COLORS } 'Cannot quantize to fewer than %d colors',
  { JERR_QUANT_MANY_COLORS } 'Cannot quantize to more than %d colors',
  { JERR_SOF_DUPLICATE } 'Invalid JPEG file structure: two SOF markers',
  { JERR_SOF_NO_SOS } 'Invalid JPEG file structure: missing SOS marker',
  { JERR_SOF_UNSUPPORTED } 'Unsupported JPEG process: SOF type $%02x',
  { JERR_SOI_DUPLICATE } 'Invalid JPEG file structure: two SOI markers',
  { JERR_SOS_NO_SOF } 'Invalid JPEG file structure: SOS before SOF',
  { JERR_TFILE_CREATE } 'Failed to create temporary file %s',
  { JERR_TFILE_READ } 'Read failed on temporary file',
  { JERR_TFILE_SEEK } 'Seek failed on temporary file',
  { JERR_TFILE_WRITE }
	 'Write failed on temporary file --- out of disk space?',
  { JERR_TOO_LITTLE_DATA } 'Application transferred too few scanlines',
  { JERR_UNKNOWN_MARKER } 'Unsupported marker type $%02x',
  { JERR_VIRTUAL_BUG } 'Virtual array controller messed up',
  { JERR_WIDTH_OVERFLOW } 'Image too wide for this implementation',
  { JMSG_COPYRIGHT }  JCOPYRIGHT,
  { JMSG_VERSION } JVERSION,
  { JTRC_16BIT_TABLES }
	 'Caution: quantization tables are too coarse for baseline JPEG',
  { JTRC_ADOBE }
	 'Adobe APP14 marker: version %d, flags $%04x $%04x, transform %d',
  { JTRC_APP0 } 'Unknown APP0 marker (not JFIF), length %d',
  { JTRC_APP14 } 'Unknown APP14 marker (not Adobe), length %d',
  { JTRC_DAC } 'Define Arithmetic Table $%02x: $%02x',
  { JTRC_DHT } 'Define Huffman Table $%02x',
  { JTRC_DQT } 'Define Quantization Table %d  precision %d',
  { JTRC_DRI } 'Define Restart Interval %d',
  { JTRC_EOI } 'End Of Image',
  { JTRC_HUFFBITS } '        %3d %3d %3d %3d %3d %3d %3d %3d',
  { JTRC_JFIF } 'JFIF APP0 marker, density %dx%d  %d',
  { JTRC_JFIF_BADTHUMBNAILSIZE }
	 'Warning: thumbnail image size does not match data length %d',
  { JTRC_JFIF_MINOR } 'Unknown JFIF minor revision number %d.%02d',
  { JTRC_JFIF_THUMBNAIL } '    with %d x %d thumbnail image',
  { JTRC_MISC_MARKER } 'Skipping marker $%02x, length %d',
  { JTRC_PARMLESS_MARKER } 'Unexpected marker $%02x',
  { JTRC_QUANTVALS } '        %4d %4d %4d %4d %4d %4d %4d %4d',
  { JTRC_QUANT_3_NCOLORS } 'Quantizing to %d = %d*%d*%d colors',
  { JTRC_QUANT_NCOLORS } 'Quantizing to %d colors',
  { JTRC_QUANT_SELECTED } 'Selected %d colors for quantization',
  { JTRC_RECOVERY_ACTION } 'At marker $%02x, recovery action %d',
  { JTRC_RST } 'RST%d',
  { JTRC_SMOOTH_NOTIMPL }
	 'Smoothing not supported with nonstandard sampling ratios',
  { JTRC_SOF } 'Start Of Frame $%02x: width=%d, height=%d, components=%d',
  { JTRC_SOF_COMPONENT } '    Component %d: %dhx%dv q=%d',
  { JTRC_SOI } 'Start of Image',
  { JTRC_SOS } 'Start Of Scan: %d components',
  { JTRC_SOS_COMPONENT } '    Component %d: dc=%d ac=%d',
  { JTRC_SOS_PARAMS } '  Ss=%d, Se=%d, Ah=%d, Al=%d',
  { JTRC_TFILE_CLOSE } 'Closed temporary file %s',
  { JTRC_TFILE_OPEN } 'Opened temporary file %s',
  { JTRC_UNKNOWN_IDS }
	 'Unrecognized component IDs %d %d %d, assuming YCbCr',
  { JWRN_ADOBE_XFORM } 'Unknown Adobe color transform code %d',
  { JWRN_BOGUS_PROGRESSION }
	 'Inconsistent progression sequence for component %d coefficient %d',
  { JWRN_EXTRANEOUS_DATA }
	 'Corrupt JPEG data: %d extraneous bytes before marker $%02x',
  { JWRN_HIT_MARKER } 'Corrupt JPEG data: premature end of data segment',
  { JWRN_HUFF_BAD_CODE } 'Corrupt JPEG data: bad Huffman code',
  { JWRN_JFIF_MAJOR } 'Warning: unknown JFIF revision number %d.%02d',
  { JWRN_JPEG_EOF } 'Premature end of JPEG file',
  { JWRN_MUST_RESYNC }
	 'Corrupt JPEG data: found marker $%02x instead of RST%d',
  { JWRN_NOT_SEQUENTIAL } 'Invalid SOS parameters for sequential JPEG',
  { JWRN_TOO_MUCH_DATA } 'Application transferred too many scanlines',

  { JMSG_FIRSTADDONCODE }  '', { Must be first entry! }
  { JERR_BAD_CMAP_FILE }
	 'Color map file is invalid or of unsupported format',
  { JERR_TOO_MANY_COLORS }
	 'Output file format cannot handle %d colormap entries',
  { JERR_UNGETC_FAILED } 'ungetc failed',
  { JERR_UNKNOWN_FORMAT } 'Unrecognized input file format',
  { JERR_UNSUPPORTED_FORMAT } 'Unsupported output file format',


  { JMSG_LASTADDONCODE } '');

implementation

end.