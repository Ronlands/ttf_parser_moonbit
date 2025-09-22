/// TTF 字体解析器 - 字体分析模块
/// 负责分析字体特性和功能

// ==================== 字体分析模块 ====================

/// 判断表标签是否为核心表
fn is_core_table(tag : String) -> Bool {
  tag == "cmap" || tag == "glyf" || tag == "head" || tag == "maxp" || tag == "name"
}

/// 公开的核心表检查函数
pub fn is_core_table_check(tag : String) -> Bool {
  is_core_table(tag)
}

/// 判断表标签是否为彩色字体相关
fn is_color_table(tag : String) -> Bool {
  tag == "COLR" || tag == "CPAL" || tag == "CBDT" || tag == "CBLC"
}

/// 判断表标签是否为可变字体相关
fn is_variable_table(tag : String) -> Bool {
  tag == "fvar" || tag == "gvar" || tag == "HVAR" || tag == "MVAR" || tag == "STAT" || tag == "avar"
}

/// 分析字体特性
pub fn analyze_font_features(tables : @types.TableDirectory) -> @types.FontFeatures {
  let mut has_color = false
  let mut has_variable = false
  let mut has_opentype_features = false
  let mut supported_tables = []
  
  // 分析每个表
  for i = 0; i < tables.entries.length(); i = i + 1 {
    let tag = tables.entries[i].tag
    supported_tables = supported_tables + [tag]
    
    // 检查彩色字体支持
    if is_color_table(tag) {
      has_color = true
    }
    
    // 检查可变字体支持
    if is_variable_table(tag) {
      has_variable = true
    }
    
    // 检查OpenType特性
    if tag == "GSUB" || tag == "GPOS" || tag == "GDEF" {
      has_opentype_features = true
    }
  }
  
  @types.make_font_features(has_color, has_variable, has_opentype_features, tables.entries.length(), supported_tables)
}

/// 从表目录中提取完整的字体信息
pub fn[R : @reader.ByteReader] extract_font_info(reader : R, tables : @types.TableDirectory) -> @types.ParseResult[@types.FontInfo] {
  // 默认值
  let mut name = "Unknown Font"
  let mut family = "Unknown Family"
  let mut style = "Regular"
  let mut version = "1.0"
  let mut num_glyphs = 0
  let mut units_per_em = 1000
  let ascender = 0
  let descender = 0
  let line_gap = 0
  
  // 解析 head 表
  match @parser.find_table(tables, "head") {
    Some(head_table) => {
      match @parser.parse_head_table(reader, head_table) {
        @types.Success(head) => {
          units_per_em = head.units_per_em
          // 检查魔术数字
          if head.magic_number != 0x5F0F3CF5 {
            return @types.make_error("非法的 TTF 文件：魔术数字不匹配")
          }
        }
        @types.Error(_) => {
          // 如果 head 表解析失败，使用默认值
          ()
        }
      }
    }
    None => {
      // 没有 head 表，使用默认值
      ()
    }
  }
  
  // 解析 maxp 表
  match @parser.find_table(tables, "maxp") {
    Some(maxp_table) => {
      match @parser.parse_maxp_table(reader, maxp_table) {
        @types.Success(maxp) => {
          num_glyphs = maxp.num_glyphs
        }
        @types.Error(_) => {
          // 如果 maxp 表解析失败，使用默认值
          ()
        }
      }
    }
    None => {
      // 没有 maxp 表，使用默认值
      ()
    }
  }
  
  // 基于表特征设置字体信息
  let features = analyze_font_features(tables)
  
  if features.has_color {
    if features.has_variable {
      family = "Variable Color Font"
      style = "Variable"
    } else {
      family = "Color Font"
      style = "Color"
    }
  } else if features.has_variable {
    family = "Variable Font" 
    style = "Variable"
  } else {
    family = "Standard Font"
  }
  
  // 基于表数量估算版本
  if features.table_count > 15 {
    version = "2.0"
  } else if features.table_count > 10 {
    version = "1.5"
  }
  
  name = family + " " + style
  
  @types.make_success(@types.make_font_info(name, family, style, version, num_glyphs, units_per_em, ascender, descender, line_gap))
}
