/// TTF 字体解析器 - 高级API模块
/// 提供简洁易用的公共接口

// ==================== 高级API ====================

/// 从字节数组解析 TTF 字体
pub fn parse_ttf_from_bytes(data : Array[Int]) -> @types.ParseResult[@types.FontInfo] {
  let reader = @reader.ArrayByteReader::new(data)
  
  // 解析表目录
  match @parser.parse_table_directory(reader) {
    @types.Success(tables) => {
      // 提取字体信息
      @analyzer.extract_font_info(reader, tables)
    }
    @types.Error(msg) => @types.make_error("表目录解析失败: " + msg)
  }
}

/// 获取字体表目录信息
pub fn get_table_directory(data : Array[Int]) -> @types.ParseResult[@types.TableDirectory] {
  let reader = @reader.ArrayByteReader::new(data)
  @parser.parse_table_directory(reader)
}

/// 获取字体文件头信息
pub fn get_font_header(data : Array[Int]) -> @types.ParseResult[@types.FontHeader] {
  let reader = @reader.ArrayByteReader::new(data)
  @parser.parse_font_header(reader)
}

/// 获取字体特性分析
pub fn analyze_font_features_from_bytes(data : Array[Int]) -> @types.ParseResult[@types.FontFeatures] {
  let reader = @reader.ArrayByteReader::new(data)
  match @parser.parse_table_directory(reader) {
    @types.Success(tables) => {
      @types.make_success(@analyzer.analyze_font_features(tables))
    }
    @types.Error(msg) => @types.make_error(msg)
  }
}

/// 检查字体是否支持彩色
pub fn is_color_font(data : Array[Int]) -> Bool {
  match analyze_font_features_from_bytes(data) {
    @types.Success(features) => features.has_color
    @types.Error(_) => false
  }
}

/// 检查字体是否为可变字体
pub fn is_variable_font(data : Array[Int]) -> Bool {
  match analyze_font_features_from_bytes(data) {
    @types.Success(features) => features.has_variable
    @types.Error(_) => false
  }
}

/// 检查字体文件是否有效
pub fn is_valid_ttf(data : Array[Int]) -> Bool {
  match get_font_header(data) {
    @types.Success(header) => header.version == 0x00010000
    @types.Error(_) => false
  }
}

/// 获取字体格式描述
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

/// 获取字体使用建议
pub fn get_font_usage_recommendation(data : Array[Int]) -> String {
  match analyze_font_features_from_bytes(data) {
    @types.Success(features) => {
      if features.has_variable && features.has_color {
        "适用于现代网页和移动应用，支持动态样式和彩色显示"
      } else if features.has_variable {
        "适用于响应式设计，支持动态字重和宽度调整"
      } else if features.has_color {
        "适用于表情符号、图标和装饰性文本"
      } else if features.has_opentype_features {
        "适用于高质量排版，支持高级字体特性"
      } else {
        "适用于一般文本显示"
      }
    }
    @types.Error(_) => "无法确定字体用途"
  }
}

/// 获取所有测试字体数据
pub fn get_all_test_fonts() -> Array[(String, Array[Int])] {
  @test_data.get_all_test_fonts()
}

/// 获取测试字体的描述信息
pub fn get_font_description(name : String) -> String {
  @test_data.get_font_description(name)
}

/// 检查表标签是否为核心表
pub fn is_core_table_check(tag : String) -> Bool {
  @analyzer.is_core_table_check(tag)
}