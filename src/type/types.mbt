/// TTF Font Parser - Data Type Definitions Module
/// Defines all data structures used for font parsing

// ==================== Data Type Definitions Module ====================

/// Parse result
pub enum ParseResult[T] {
  Success(T)
  Error(String)
} derive(Show)

/// Font file header structure
pub struct FontHeader {
  /// Font version number (usually 0x00010000)
  version : Int
  /// Number of font tables
  num_tables : Int
  /// Search range
  search_range : Int
  /// Entry selector
  entry_selector : Int
  /// Range shift
  range_shift : Int
} derive(Show)

/// Font table directory entry
pub struct TableDirectoryEntry {
  /// Table tag (4-byte identifier)
  tag : String
  /// Checksum
  checksum : Int
  /// Table offset in file
  offset : Int
  /// Table length
  length : Int
} derive(Show)

/// Font table directory
pub struct TableDirectory {
  /// Font header
  header : FontHeader
  /// List of table directory entries
  entries : Array[TableDirectoryEntry]
} derive(Show)

/// head table structure
pub struct HeadTable {
  /// Table version
  version : Int
  /// Font revision version
  font_revision : Int
  /// Checksum adjustment
  checksum_adjustment : Int
  /// Magic number (should be 0x5F0F3CF5)
  magic_number : Int
  /// Flags
  flags : Int
  /// Units per EM
  units_per_em : Int
  /// Creation time
  created : Int
  /// Modification time
  modified : Int
  /// Minimum x coordinate
  x_min : Int
  /// Minimum y coordinate
  y_min : Int
  /// Maximum x coordinate
  x_max : Int
  /// Maximum y coordinate
  y_max : Int
  /// Font style
  mac_style : Int
  /// Minimum readable pixel size
  lowest_rec_ppem : Int
  /// Font direction hint
  font_direction_hint : Int
  /// Index to location format
  index_to_loc_format : Int
  /// Glyph data format
  glyph_data_format : Int
} derive(Show)

/// maxp table structure
pub struct MaxpTable {
  /// Table version
  version : Int
  /// Number of glyphs
  num_glyphs : Int
  /// Maximum points
  max_points : Int
  /// Maximum contours
  max_contours : Int
  /// Maximum composite points
  max_composite_points : Int
  /// Maximum composite contours
  max_composite_contours : Int
} derive(Show)

/// Basic font information
pub struct FontInfo {
  /// Font name
  name : String
  /// Font family name
  family : String
  /// Font style
  style : String
  /// Font version
  version : String
  /// Number of characters
  num_glyphs : Int
  /// Units per EM
  units_per_em : Int
  /// Ascender height
  ascender : Int
  /// Descender height
  descender : Int
  /// Line gap
  line_gap : Int
} derive(Show)

/// Font feature analysis
pub struct FontFeatures {
  /// Whether supports color fonts
  has_color : Bool
  /// Whether supports variable fonts
  has_variable : Bool
  /// Whether has OpenType features
  has_opentype_features : Bool
  /// Number of tables
  table_count : Int
  /// Supported table types
  supported_tables : Array[String]
} derive(Show)

// ==================== Constructors ====================

/// Create parse success result
pub fn[T] make_success(value : T) -> ParseResult[T] {
  ParseResult::Success(value)
}

/// Create parse error result
pub fn[T] make_error(msg : String) -> ParseResult[T] {
  ParseResult::Error(msg)
}

/// Create font header structure
pub fn make_font_header(version : Int, num_tables : Int, search_range : Int, entry_selector : Int, range_shift : Int) -> FontHeader {
  FontHeader::{
    version: version,
    num_tables: num_tables, 
    search_range: search_range,
    entry_selector: entry_selector,
    range_shift: range_shift
  }
}

/// Create table directory entry
pub fn make_table_entry(tag : String, checksum : Int, offset : Int, length : Int) -> TableDirectoryEntry {
  TableDirectoryEntry::{
    tag: tag,
    checksum: checksum,
    offset: offset,
    length: length
  }
}

/// Create table directory
pub fn make_table_directory(header : FontHeader, entries : Array[TableDirectoryEntry]) -> TableDirectory {
  TableDirectory::{
    header: header,
    entries: entries
  }
}

/// Create head table
pub fn make_head_table(version : Int, font_revision : Int, checksum_adjustment : Int, magic_number : Int,
                       flags : Int, units_per_em : Int, created : Int, modified : Int,
                       x_min : Int, y_min : Int, x_max : Int, y_max : Int,
                       mac_style : Int, lowest_rec_ppem : Int, font_direction_hint : Int,
                       index_to_loc_format : Int, glyph_data_format : Int) -> HeadTable {
  HeadTable::{
    version: version,
    font_revision: font_revision,
    checksum_adjustment: checksum_adjustment,
    magic_number: magic_number,
    flags: flags,
    units_per_em: units_per_em,
    created: created,
    modified: modified,
    x_min: x_min,
    y_min: y_min,
    x_max: x_max,
    y_max: y_max,
    mac_style: mac_style,
    lowest_rec_ppem: lowest_rec_ppem,
    font_direction_hint: font_direction_hint,
    index_to_loc_format: index_to_loc_format,
    glyph_data_format: glyph_data_format
  }
}

/// Create maxp table
pub fn make_maxp_table(version : Int, num_glyphs : Int, max_points : Int, max_contours : Int,
                       max_composite_points : Int, max_composite_contours : Int) -> MaxpTable {
  MaxpTable::{
    version: version,
    num_glyphs: num_glyphs,
    max_points: max_points,
    max_contours: max_contours,
    max_composite_points: max_composite_points,
    max_composite_contours: max_composite_contours
  }
}

/// Create font feature analysis result
pub fn make_font_features(has_color : Bool, has_variable : Bool, has_opentype_features : Bool, 
                          table_count : Int, supported_tables : Array[String]) -> FontFeatures {
  FontFeatures::{
    has_color: has_color,
    has_variable: has_variable,
    has_opentype_features: has_opentype_features,
    table_count: table_count,
    supported_tables: supported_tables
  }
}

/// Create font information
pub fn make_font_info(name : String, family : String, style : String, version : String,
                      num_glyphs : Int, units_per_em : Int, ascender : Int, descender : Int, line_gap : Int) -> FontInfo {
  FontInfo::{
    name: name,
    family: family,
    style: style,
    version: version,
    num_glyphs: num_glyphs,
    units_per_em: units_per_em,
    ascender: ascender,
    descender: descender,
    line_gap: line_gap
  }
}