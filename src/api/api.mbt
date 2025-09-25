/// TTF Font Parser - Advanced API Module
/// Provides simple and easy-to-use public interfaces

// ==================== Advanced API ====================

/// Parse TTF font from byte array
pub fn parse_ttf_from_bytes(data : Array[Int]) -> @types.ParseResult[@types.FontInfo] {
  let reader = @reader.ArrayByteReader::new(data)
  
  // Parse table directory
  match @parser.parse_table_directory(reader) {
    @types.Success(tables) => {
      // Extract font information
      @analyzer.extract_font_info(reader, tables)
    }
    @types.Error(msg) => @types.make_error("Table directory parsing failed: " + msg)
  }
}

/// Get font table directory information
pub fn get_table_directory(data : Array[Int]) -> @types.ParseResult[@types.TableDirectory] {
  let reader = @reader.ArrayByteReader::new(data)
  @parser.parse_table_directory(reader)
}

/// Get font file header information
pub fn get_font_header(data : Array[Int]) -> @types.ParseResult[@types.FontHeader] {
  let reader = @reader.ArrayByteReader::new(data)
  @parser.parse_font_header(reader)
}

/// Get font feature analysis
pub fn analyze_font_features_from_bytes(data : Array[Int]) -> @types.ParseResult[@types.FontFeatures] {
  let reader = @reader.ArrayByteReader::new(data)
  match @parser.parse_table_directory(reader) {
    @types.Success(tables) => {
      @types.make_success(@analyzer.analyze_font_features(tables))
    }
    @types.Error(msg) => @types.make_error(msg)
  }
}

/// Check if font supports color
pub fn is_color_font(data : Array[Int]) -> Bool {
  match analyze_font_features_from_bytes(data) {
    @types.Success(features) => features.has_color
    @types.Error(_) => false
  }
}

/// Check if font is variable font
pub fn is_variable_font(data : Array[Int]) -> Bool {
  match analyze_font_features_from_bytes(data) {
    @types.Success(features) => features.has_variable
    @types.Error(_) => false
  }
}

/// Check if font file is valid
pub fn is_valid_ttf(data : Array[Int]) -> Bool {
  match get_font_header(data) {
    @types.Success(header) => header.version == 0x00010000
    @types.Error(_) => false
  }
}

/// Get font format description
pub fn get_font_format(data : Array[Int]) -> String {
  match get_font_header(data) {
    @types.Success(header) => {
      match header.version {
        0x00010000 => "TrueType"
        0x4F54544F => "OpenType (CFF)"  // 'OTTO' 
        0x74727565 => "TrueType ('true')"
        0x74797031 => "Type 1"
        _ => "Unknown"
      }
    }
    @types.Error(_) => "Unknown"
  }
}

/// Get font usage recommendations
pub fn get_font_usage_recommendation(data : Array[Int]) -> String {
  match analyze_font_features_from_bytes(data) {
    @types.Success(features) => {
      if features.has_variable && features.has_color {
        "Suitable for modern web and mobile applications, supports dynamic styles and color display"
      } else if features.has_variable {
        "Suitable for responsive design, supports dynamic font weight and width adjustment"
      } else if features.has_color {
        "Suitable for emojis, icons and decorative text"
      } else if features.has_opentype_features {
        "Suitable for high-quality typography, supports advanced font features"
      } else {
        "Suitable for general text display"
      }
    }
    @types.Error(_) => "Unable to determine font usage"
  }
}

/// Get all test font data
pub fn get_all_test_fonts() -> Array[(String, Array[Int])] {
  @test_data.get_all_test_fonts()
}

/// Get test font description information
pub fn get_font_description(name : String) -> String {
  @test_data.get_font_description(name)
}

/// Check if table tag is a core table
pub fn is_core_table_check(tag : String) -> Bool {
  @analyzer.is_core_table_check(tag)
}