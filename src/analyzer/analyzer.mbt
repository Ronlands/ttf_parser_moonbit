/// TTF Font Parser - Font Analysis Module
/// Responsible for analyzing font features and functionality

// ==================== Font Analysis Module ====================

/// Check if table tag is a core table
fn is_core_table(tag : String) -> Bool {
  tag == "cmap" || tag == "glyf" || tag == "head" || tag == "maxp" || tag == "name"
}

/// Public core table check function
pub fn is_core_table_check(tag : String) -> Bool {
  is_core_table(tag)
}

/// Check if table tag is color font related
fn is_color_table(tag : String) -> Bool {
  tag == "COLR" || tag == "CPAL" || tag == "CBDT" || tag == "CBLC"
}

/// Check if table tag is variable font related
fn is_variable_table(tag : String) -> Bool {
  tag == "fvar" || tag == "gvar" || tag == "HVAR" || tag == "MVAR" || tag == "STAT" || tag == "avar"
}

/// Analyze font features
pub fn analyze_font_features(tables : @types.TableDirectory) -> @types.FontFeatures {
  let mut has_color = false
  let mut has_variable = false
  let mut has_opentype_features = false
  let mut supported_tables = []
  
  // Analyze each table
  for i = 0; i < tables.entries.length(); i = i + 1 {
    let tag = tables.entries[i].tag
    supported_tables = supported_tables + [tag]
    
    // Check color font support
    if is_color_table(tag) {
      has_color = true
    }
    
    // Check variable font support
    if is_variable_table(tag) {
      has_variable = true
    }
    
    // Check OpenType features
    if tag == "GSUB" || tag == "GPOS" || tag == "GDEF" {
      has_opentype_features = true
    }
  }
  
  @types.make_font_features(has_color, has_variable, has_opentype_features, tables.entries.length(), supported_tables)
}

/// Extract complete font information from table directory
pub fn[R : @reader.ByteReader] extract_font_info(reader : R, tables : @types.TableDirectory) -> @types.ParseResult[@types.FontInfo] {
  // Default values
  let mut name = "Unknown Font"
  let mut family = "Unknown Family"
  let mut style = "Regular"
  let mut version = "1.0"
  let mut num_glyphs = 0
  let mut units_per_em = 1000
  let ascender = 0
  let descender = 0
  let line_gap = 0
  
  // Parse head table
  match @parser.find_table(tables, "head") {
    Some(head_table) => {
      match @parser.parse_head_table(reader, head_table) {
        @types.Success(head) => {
          units_per_em = head.units_per_em
          // Check magic number
          if head.magic_number != 0x5F0F3CF5 {
            return @types.make_error("Invalid TTF file: magic number mismatch")
          }
        }
        @types.Error(_) => {
          // If head table parsing fails, use default values
          ()
        }
      }
    }
    None => {
      // No head table, use default values
      ()
    }
  }
  
  // Parse maxp table
  match @parser.find_table(tables, "maxp") {
    Some(maxp_table) => {
      match @parser.parse_maxp_table(reader, maxp_table) {
        @types.Success(maxp) => {
          num_glyphs = maxp.num_glyphs
        }
        @types.Error(_) => {
          // If maxp table parsing fails, use default values
          ()
        }
      }
    }
    None => {
      // No maxp table, use default values
      ()
    }
  }
  
  // Set font information based on table features
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
  
  // Estimate version based on table count
  if features.table_count > 15 {
    version = "2.0"
  } else if features.table_count > 10 {
    version = "1.5"
  }
  
  name = family + " " + style
  
  @types.make_success(@types.make_font_info(name, family, style, version, num_glyphs, units_per_em, ascender, descender, line_gap))
}
