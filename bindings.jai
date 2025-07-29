//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



MD_FLAG_COLLAPSEWHITESPACE :: 0x0001;
MD_FLAG_PERMISSIVEATXHEADERS :: 0x0002;
MD_FLAG_PERMISSIVEURLAUTOLINKS :: 0x0004;
MD_FLAG_PERMISSIVEEMAILAUTOLINKS :: 0x0008;
MD_FLAG_NOINDENTEDCODEBLOCKS :: 0x0010;
MD_FLAG_NOHTMLBLOCKS :: 0x0020;
MD_FLAG_NOHTMLSPANS :: 0x0040;
MD_FLAG_TABLES :: 0x0100;
MD_FLAG_STRIKETHROUGH :: 0x0200;
MD_FLAG_PERMISSIVEWWWAUTOLINKS :: 0x0400;
MD_FLAG_TASKLISTS :: 0x0800;
MD_FLAG_LATEXMATHSPANS :: 0x1000;
MD_FLAG_WIKILINKS :: 0x2000;
MD_FLAG_UNDERLINE :: 0x4000;
MD_FLAG_HARD_SOFT_BREAKS :: 0x8000;

MD_FLAG_PERMISSIVEAUTOLINKS :: MD_FLAG_PERMISSIVEEMAILAUTOLINKS | MD_FLAG_PERMISSIVEURLAUTOLINKS | MD_FLAG_PERMISSIVEWWWAUTOLINKS;
MD_FLAG_NOHTML :: MD_FLAG_NOHTMLBLOCKS | MD_FLAG_NOHTMLSPANS;

MD_DIALECT_COMMONMARK :: 0;
MD_DIALECT_GITHUB :: MD_FLAG_PERMISSIVEAUTOLINKS | MD_FLAG_TABLES | MD_FLAG_STRIKETHROUGH | MD_FLAG_TASKLISTS;

MD_HTML_FLAG_DEBUG :: 0x0001;
MD_HTML_FLAG_VERBATIM_ENTITIES :: 0x0002;
MD_HTML_FLAG_SKIP_UTF8_BOM :: 0x0004;
MD_HTML_FLAG_XHTML :: 0x0008;

MD_CHAR :: u8;

MD_SIZE :: u32;
MD_OFFSET :: u32;

/* Block represents a part of document hierarchy structure like a paragraph
* or list item.
*/
MD_BLOCKTYPE :: enum s32 {
    DOC   :: 0;

    QUOTE :: 1;

    UL    :: 2;

    OL    :: 3;

    LI    :: 4;

    HR    :: 5;

    H     :: 6;

    CODE  :: 7;

    HTML  :: 8;

    P     :: 9;

    TABLE :: 10;
    THEAD :: 11;
    TBODY :: 12;
    TR    :: 13;
    TH    :: 14;
    TD    :: 15;

    MD_BLOCK_DOC   :: DOC;

    MD_BLOCK_QUOTE :: QUOTE;

    MD_BLOCK_UL    :: UL;

    MD_BLOCK_OL    :: OL;

    MD_BLOCK_LI    :: LI;

    MD_BLOCK_HR    :: HR;

    MD_BLOCK_H     :: H;

    MD_BLOCK_CODE  :: CODE;

    MD_BLOCK_HTML  :: HTML;

    MD_BLOCK_P     :: P;

    MD_BLOCK_TABLE :: TABLE;
    MD_BLOCK_THEAD :: THEAD;
    MD_BLOCK_TBODY :: TBODY;
    MD_BLOCK_TR    :: TR;
    MD_BLOCK_TH    :: TH;
    MD_BLOCK_TD    :: TD;
}

/* Span represents an in-line piece of a document which should be rendered with
* the same font, color and other attributes. A sequence of spans forms a block
* like paragraph or list item. */
MD_SPANTYPE :: enum s32 {
    EM                :: 0;

    STRONG            :: 1;

    A                 :: 2;

    IMG               :: 3;

    CODE              :: 4;

    DEL               :: 5;

    LATEXMATH         :: 6;
    LATEXMATH_DISPLAY :: 7;

    WIKILINK          :: 8;

    U                 :: 9;

    MD_SPAN_EM                :: EM;

    MD_SPAN_STRONG            :: STRONG;

    MD_SPAN_A                 :: A;

    MD_SPAN_IMG               :: IMG;

    MD_SPAN_CODE              :: CODE;

    MD_SPAN_DEL               :: DEL;

    MD_SPAN_LATEXMATH         :: LATEXMATH;
    MD_SPAN_LATEXMATH_DISPLAY :: LATEXMATH_DISPLAY;

    MD_SPAN_WIKILINK          :: WIKILINK;

    MD_SPAN_U                 :: U;
}

/* Text is the actual textual contents of span. */
MD_TEXTTYPE :: enum s32 {
    NORMAL    :: 0;

    NULLCHAR  :: 1;

    BR        :: 2;
    SOFTBR    :: 3;

    ENTITY    :: 4;

    CODE      :: 5;

    HTML      :: 6;

    LATEXMATH :: 7;

    MD_TEXT_NORMAL    :: NORMAL;

    MD_TEXT_NULLCHAR  :: NULLCHAR;

    MD_TEXT_BR        :: BR;
    MD_TEXT_SOFTBR    :: SOFTBR;

    MD_TEXT_ENTITY    :: ENTITY;

    MD_TEXT_CODE      :: CODE;

    MD_TEXT_HTML      :: HTML;

    MD_TEXT_LATEXMATH :: LATEXMATH;
}

/* Alignment enumeration. */
MD_ALIGN :: enum s32 {
    DEFAULT :: 0;
    LEFT    :: 1;
    CENTER  :: 2;
    RIGHT   :: 3;

    MD_ALIGN_DEFAULT :: DEFAULT;
    MD_ALIGN_LEFT    :: LEFT;
    MD_ALIGN_CENTER  :: CENTER;
    MD_ALIGN_RIGHT   :: RIGHT;
}

/* String attribute.
*
* This wraps strings which are outside of a normal text flow and which are
* propagated within various detailed structures, but which still may contain
* string portions of different types like e.g. entities.
*
* So, for example, lets consider this image:
*
*     ![image alt text](http://example.org/image.png 'foo &quot; bar')
*
* The image alt text is propagated as a normal text via the MD_PARSER::text()
* callback. However, the image title ('foo &quot; bar') is propagated as
* MD_ATTRIBUTE in MD_SPAN_IMG_DETAIL::title.
*
* Then the attribute MD_SPAN_IMG_DETAIL::title shall provide the following:
*  -- [0]: "foo "   (substr_types[0] == MD_TEXT_NORMAL; substr_offsets[0] == 0)
*  -- [1]: "&quot;" (substr_types[1] == MD_TEXT_ENTITY; substr_offsets[1] == 4)
*  -- [2]: " bar"   (substr_types[2] == MD_TEXT_NORMAL; substr_offsets[2] == 10)
*  -- [3]: (n/a)    (n/a                              ; substr_offsets[3] == 14)
*
* Note that these invariants are always guaranteed:
*  -- substr_offsets[0] == 0
*  -- substr_offsets[LAST+1] == size
*  -- Currently, only MD_TEXT_NORMAL, MD_TEXT_ENTITY, MD_TEXT_NULLCHAR
*     substrings can appear. This could change only of the specification
*     changes.
*/
MD_ATTRIBUTE :: struct {
    text:           *MD_CHAR;
    size:           MD_SIZE;
    substr_types:   *MD_TEXTTYPE;
    substr_offsets: *MD_OFFSET;
}

/* Detailed info for MD_BLOCK_UL. */
MD_BLOCK_UL_DETAIL :: struct {
    is_tight: s32; /* Non-zero if tight list, zero if loose. */
    mark:     MD_CHAR; /* Item bullet character in MarkDown source of the list, e.g. '-', '+', '*'. */
}

/* Detailed info for MD_BLOCK_OL. */
MD_BLOCK_OL_DETAIL :: struct {
    start:          u32; /* Start index of the ordered list. */
    is_tight:       s32; /* Non-zero if tight list, zero if loose. */
    mark_delimiter: MD_CHAR; /* Character delimiting the item marks in MarkDown source, e.g. '.' or ')' */
}

/* Detailed info for MD_BLOCK_LI. */
MD_BLOCK_LI_DETAIL :: struct {
    is_task:          s32; /* Can be non-zero only with MD_FLAG_TASKLISTS */
    task_mark:        MD_CHAR; /* If is_task, then one of 'x', 'X' or ' '. Undefined otherwise. */
    task_mark_offset: MD_OFFSET; /* If is_task, then offset in the input of the char between '[' and ']'. */
}

/* Detailed info for MD_BLOCK_H. */
MD_BLOCK_H_DETAIL :: struct {
    level: u32; /* Header level (1 - 6) */
}

/* Detailed info for MD_BLOCK_CODE. */
MD_BLOCK_CODE_DETAIL :: struct {
    info:       MD_ATTRIBUTE;
    lang:       MD_ATTRIBUTE;
    fence_char: MD_CHAR; /* The character used for fenced code block; or zero for indented code block. */
}

/* Detailed info for MD_BLOCK_TABLE. */
MD_BLOCK_TABLE_DETAIL :: struct {
    col_count:      u32; /* Count of columns in the table. */
    head_row_count: u32; /* Count of rows in the table header (currently always 1) */
    body_row_count: u32; /* Count of rows in the table body */
}

/* Detailed info for MD_BLOCK_TH and MD_BLOCK_TD. */
MD_BLOCK_TD_DETAIL :: struct {
    align: MD_ALIGN;
}

/* Detailed info for MD_SPAN_A. */
MD_SPAN_A_DETAIL :: struct {
    href:        MD_ATTRIBUTE;
    title:       MD_ATTRIBUTE;
    is_autolink: s32; /* nonzero if this is an autolink */
}

/* Detailed info for MD_SPAN_IMG. */
MD_SPAN_IMG_DETAIL :: struct {
    src:   MD_ATTRIBUTE;
    title: MD_ATTRIBUTE;
}

/* Detailed info for MD_SPAN_WIKILINK. */
MD_SPAN_WIKILINK :: struct {
    target: MD_ATTRIBUTE;
}

/* Detailed info for MD_SPAN_WIKILINK. */
MD_SPAN_WIKILINK_DETAIL :: MD_SPAN_WIKILINK;

/* Parser structure.
*/
MD_PARSER :: struct {
    /* Reserved. Set to zero.
    */
    abi_version: u32;

    /* Dialect options. Bitmask of MD_FLAG_xxxx values.
    */
    flags:       u32;

    enter_block: #type (unknown0: MD_BLOCKTYPE, unknown1: *void, unknown2: *void) -> s32 #c_call; /*type*/
    leave_block: #type (unknown0: MD_BLOCKTYPE, unknown1: *void, unknown2: *void) -> s32 #c_call; /*type*/

    enter_span:  #type (unknown0: MD_SPANTYPE, unknown1: *void, unknown2: *void) -> s32 #c_call; /*type*/
    leave_span:  #type (unknown0: MD_SPANTYPE, unknown1: *void, unknown2: *void) -> s32 #c_call; /*type*/

    text:        #type (unknown0: MD_TEXTTYPE, unknown1: *MD_CHAR, unknown2: MD_SIZE, unknown3: *void) -> s32 #c_call; /*type*/

    debug_log:   #type (unknown0: *u8, unknown1: *void) -> void #c_call; /*msg*/

    /* Reserved. Set to NULL.
    */
    syntax:      #type () -> void #c_call;
}

/* For backward compatibility. Do not use in new code.
*/
MD_RENDERER :: MD_PARSER;

/* Parse the Markdown document stored in the string 'text' of size 'size'.
* The parser provides callbacks to be called during the parsing so the
* caller can render the document on the screen or convert the Markdown
* to another format.
*
* Zero is returned on success. If a runtime error occurs (e.g. a memory
* fails), -1 is returned. If the processing is aborted due any callback
* returning non-zero, the return value of the callback is returned.
*/
md_parse :: (text: *MD_CHAR, size: MD_SIZE, parser: *MD_PARSER, userdata: *void) -> s32 #foreign md4c;

/* Render Markdown into HTML.
*
* Note only contents of <body> tag is generated. Caller must generate
* HTML header/footer manually before/after calling md_html().
*
* Params input and input_size specify the Markdown input.
* Callback process_output() gets called with chunks of HTML output.
* (Typical implementation may just output the bytes to a file or append to
* some buffer).
* Param userdata is just propagated back to process_output() callback.
* Param parser_flags are flags from md4c.h propagated to md_parse().
* Param render_flags is bitmask of MD_HTML_FLAG_xxxx.
*
* Returns -1 on error (if md_parse() fails.)
* Returns 0 on success.
*/
md_html :: (input: *MD_CHAR, input_size: MD_SIZE, process_output: #type (unknown0: *MD_CHAR, unknown1: MD_SIZE, unknown2: *void) -> void #c_call, userdata: *void, parser_flags: u32, renderer_flags: u32) -> s32 #foreign md4c_html;

/* Most entities are formed by single Unicode codepoint, few by two codepoints.
* Single-codepoint entities have codepoints[1] set to zero. */
ENTITY :: ENTITY_tag;
ENTITY_tag :: struct {
    name:       *u8;
    codepoints: [2] u32;
}

entity_lookup :: (name: *u8, name_size: u64) -> *ENTITY #foreign md4c_html;

#scope_file

md4c :: #library "windows/md4c";
md4c_html :: #library "windows/md4c-html";
