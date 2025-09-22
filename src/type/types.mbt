/// TTF 字体解析器 - 数据类型定义模块
/// 定义所有用于字体解析的数据结构

// ==================== 数据类型定义模块 ====================

/// 解析结果
pub enum ParseResult[T] {
  Success(T)
  Error(String)
} derive(Show)

/// 字体文件头结构
pub struct FontHeader {
  /// 字体版本号 (通常是 0x00010000)
  version : Int
  /// 字体表数量
  num_tables : Int
  /// 搜索范围
  search_range : Int
  /// 入口选择器
  entry_selector : Int
  /// 范围移位
  range_shift : Int
} derive(Show)

/// 字体表目录项
pub struct TableDirectoryEntry {
  /// 表标签 (4字节标识符)
  tag : String
  /// 校验和
  checksum : Int
  /// 表在文件中的偏移量
  offset : Int
  /// 表的长度
  length : Int
} derive(Show)

/// 字体表目录
pub struct TableDirectory {
  /// 字体头
  header : FontHeader
  /// 表目录项列表
  entries : Array[TableDirectoryEntry]
} derive(Show)

/// head 表结构
pub struct HeadTable {
  /// 表版本
  version : Int
  /// 字体修订版本
  font_revision : Int
  /// 校验和调整
  checksum_adjustment : Int
  /// 魔术数字（应为 0x5F0F3CF5）
  magic_number : Int
  /// 标志
  flags : Int
  /// 单位每EM
  units_per_em : Int
  /// 创建时间
  created : Int
  /// 修改时间
  modified : Int
  /// 最小x坐标
  x_min : Int
  /// 最小y坐标
  y_min : Int
  /// 最大x坐标
  x_max : Int
  /// 最大y坐标
  y_max : Int
  /// 字体样式
  mac_style : Int
  /// 最小可读像素大小
  lowest_rec_ppem : Int
  /// 字体方向提示
  font_direction_hint : Int
  /// 索引到位置格式
  index_to_loc_format : Int
  /// 字形数据格式
  glyph_data_format : Int
} derive(Show)

/// maxp 表结构
pub struct MaxpTable {
  /// 表版本
  version : Int
  /// 字形数量
  num_glyphs : Int
  /// 最大点数
  max_points : Int
  /// 最大轮廓数
  max_contours : Int
  /// 最大组合点数
  max_composite_points : Int
  /// 最大组合轮廓数
  max_composite_contours : Int
} derive(Show)

/// 字体基本信息
pub struct FontInfo {
  /// 字体名称
  name : String
  /// 字体族名称
  family : String
  /// 字体样式
  style : String
  /// 字体版本
  version : String
  /// 字符数量
  num_glyphs : Int
  /// 单位每EM
  units_per_em : Int
  /// 上升高度
  ascender : Int
  /// 下降高度
  descender : Int
  /// 行间距
  line_gap : Int
} derive(Show)

/// 字体特性分析
pub struct FontFeatures {
  /// 是否支持彩色字体
  has_color : Bool
  /// 是否支持可变字体
  has_variable : Bool
  /// 是否有OpenType特性
  has_opentype_features : Bool
  /// 表的数量
  table_count : Int
  /// 支持的表类型
  supported_tables : Array[String]
} derive(Show)

// ==================== 构造函数 ====================

/// 创建解析成功结果
pub fn[T] make_success(value : T) -> ParseResult[T] {
  ParseResult::Success(value)
}

/// 创建解析错误结果  
pub fn[T] make_error(msg : String) -> ParseResult[T] {
  ParseResult::Error(msg)
}

/// 创建字体头结构
pub fn make_font_header(version : Int, num_tables : Int, search_range : Int, entry_selector : Int, range_shift : Int) -> FontHeader {
  FontHeader::{
    version: version,
    num_tables: num_tables, 
    search_range: search_range,
    entry_selector: entry_selector,
    range_shift: range_shift
  }
}

/// 创建表目录项
pub fn make_table_entry(tag : String, checksum : Int, offset : Int, length : Int) -> TableDirectoryEntry {
  TableDirectoryEntry::{
    tag: tag,
    checksum: checksum,
    offset: offset,
    length: length
  }
}

/// 创建表目录
pub fn make_table_directory(header : FontHeader, entries : Array[TableDirectoryEntry]) -> TableDirectory {
  TableDirectory::{
    header: header,
    entries: entries
  }
}

/// 创建 head 表
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

/// 创建 maxp 表
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

/// 创建字体特性分析结果
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

/// 创建字体信息
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