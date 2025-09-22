/// TTF 字体解析器演示程序
/// 使用模块化的 MoonBit TTF 解析器

fn demo_reader_usage(data : Array[Int]) -> Unit {
  
  // 使用 reader 模块创建字节读取器
  let reader = @reader.ArrayByteReader::new(data)
  
  println("  数据长度: " + reader.length().to_string() + " 字节")
  println("  当前位置: " + reader.position().to_string())
  
  // 演示读取 TTF 文件头（版本号）
  match @reader.read_u32_be(reader) {
    Some(version) => {
      println("  文件版本: 0x" + version.to_string())
      if version == 0x00010000 {
        println("  ✓ 这是有效的 TTF 文件")
      } else {
        println("  ⚠ 可能不是标准 TTF 文件")
      }
    }
    None => println("  ✗ 无法读取文件版本")
  }
  
  // 重置位置
  reader.seek(0)
  println("  位置重置为: " + reader.position().to_string())
  println("")
}

/// 读取字体文件的字节数据 - 使用 MoonBit 官方文件系统库
fn read_font_file(file_path : String) -> Result[Array[Int], String] {
  try {
    // 使用 MoonBit 官方 fs 库读取文件
    let content = @fs.read_file_to_bytes(file_path)
    let mut result = []
    
    // 将 Bytes 转换为 Array[Int]
    for i = 0; i < content.length(); i = i + 1 {
      result = result + [content[i].to_int()]
    }
    
    Ok(result)
  } catch {
    err => {
      // 如果文件读取失败，提供详细的错误信息和备选方案
      let error_msg = "文件读取失败: " + err.to_string() + "\n" +
                     "文件路径: " + file_path + "\n" +
                     "可能的原因:\n" +
                     "  • 文件不存在\n" +
                     "  • 权限不足\n" +
                     "  • 路径错误\n" +
                     "备选方案: 使用内嵌测试数据进行演示"
      Err(error_msg)
    }
  }
}


/// 分析并显示字体文件信息
fn analyze_font(name : String, data : Array[Int]) -> Unit {
  println("=== 分析字体文件: " + name + " ===")
  println("数据大小: " + data.length().to_string() + " 字节")
  println("描述: " + @lib.get_font_description(name))
  
  // 检查字体文件有效性
  if !@lib.is_valid_ttf(data) {
    println("✗ 无效的TTF文件!")
    return
  }
  
  // 获取字体格式
  let format = @lib.get_font_format(data)
  println("✓ 字体格式: " + format)
  
  // 解析字体文件头
  match @lib.get_font_header(data) {
    @types.Success(header) => {
      println("✓ 字体头解析成功!")
      println("  版本: 0x" + header.version.to_string())
      println("  表数量: " + header.num_tables.to_string())
      println("  搜索范围: " + header.search_range.to_string())
      println("  入口选择器: " + header.entry_selector.to_string())
      println("  范围移位: " + header.range_shift.to_string())
    }
    @types.Error(msg) => {
      println("✗ 字体头解析失败: " + msg)
      return
    }
  }
  
  // 解析表目录
  match @lib.get_table_directory(data) {
    @types.Success(tables) => {
      println("✓ 表目录解析成功!")
      println("  发现 " + tables.entries.length().to_string() + " 个表:")
      
      // 显示所有表的信息
      for i = 0; i < tables.entries.length(); i = i + 1 {
        let entry = tables.entries[i]
        let size_kb = if entry.length > 1024 { 
          " (" + (entry.length / 1024).to_string() + "KB)" 
        } else { 
          " (" + entry.length.to_string() + "B)" 
        }
        println("    " + (i + 1).to_string() + ". " + entry.tag + " - 偏移: " + entry.offset.to_string() + ", 长度: " + entry.length.to_string() + size_kb)
      }
    }
    @types.Error(msg) => {
      println("✗ 表目录解析失败: " + msg)
      return
    }
  }
  
  // 分析字体特性
  match @lib.analyze_font_features_from_bytes(data) {
    @types.Success(features) => {
      println("✓ 字体特性分析:")
      println("    表数量: " + features.table_count.to_string())
      
      let mut core_table_count = 0
      for i = 0; i < features.supported_tables.length(); i = i + 1 {
        if @lib.is_core_table_check(features.supported_tables[i]) {
          core_table_count = core_table_count + 1
        }
      }
      println("    核心表: " + core_table_count.to_string() + "/5 个")
      
      if features.has_color {
        println("    ✓ 支持彩色字体")
      }
      if features.has_variable {
        println("    ✓ 支持可变字体")
      }
      if features.has_opentype_features {
        println("    ✓ 支持OpenType特性")
      }
      if !features.has_color && !features.has_variable {
        println("    - 标准单色字体")
      }
      
      // 显示使用建议
      let recommendation = @lib.get_font_usage_recommendation(data)
      println("    建议用途: " + recommendation)
    }
    @types.Error(msg) => {
      println("✗ 字体特性分析失败: " + msg)
    }
  }
  
  // 解析字体基本信息
  match @lib.parse_ttf_from_bytes(data) {
    @types.Success(info) => {
      println("✓ 字体信息解析成功!")
      println("  字体名称: " + info.name)
      println("  字体族: " + info.family)
      println("  字体样式: " + info.style)
      println("  字体版本: " + info.version)
      println("  字符数量: " + info.num_glyphs.to_string())
      println("  单位每EM: " + info.units_per_em.to_string())
      println("  上升高度: " + info.ascender.to_string())
      println("  下降高度: " + info.descender.to_string())
      println("  行间距: " + info.line_gap.to_string())
      
      // 显示字体度量信息
      let font_size = 16
      println("  " + font_size.to_string() + "px字号基本度量:")
      println("    上升高度: " + (info.ascender * font_size / info.units_per_em).to_string() + "px")
      println("    下降高度: " + (info.descender * font_size / info.units_per_em).to_string() + "px") 
      let line_height = (info.ascender - info.descender + info.line_gap) * font_size / info.units_per_em
      println("    行高: " + line_height.to_string() + "px")
    }
    @types.Error(msg) => {
      println("✗ 字体信息解析失败: " + msg)
    }
  }
  
  println("")
}

/// 分析真实的字体文件
fn analyze_real_font(file_path : String) -> Unit {
  println("=== 尝试读取真实字体文件: " + file_path + " ===")
  
  match read_font_file(file_path) {
    Ok(data) => {
      // 简单提取文件名（从路径中）
      let mut file_name = file_path
      let path_parts = file_path.split("/")
      // 将迭代器转换为数组
      let parts_array = path_parts.to_array()
      if parts_array.length() > 0 {
        file_name = parts_array[parts_array.length() - 1].to_string()
      }
      analyze_font(file_name, data)
    }
    Err(msg) => {
      println("✗ " + msg)
      println("")
      println("回退到测试数据演示...")
      // 作为备选方案，使用对应的测试数据
      if file_path.contains("demo.ttf") {
        let (name, data) = @lib.get_all_test_fonts()[0]
        analyze_font(name + " (测试数据)", data)
      } else if file_path.contains("colr_1.ttf") && !file_path.contains("variable") {
        let (name, data) = @lib.get_all_test_fonts()[1]
        analyze_font(name + " (测试数据)", data)
      } else if file_path.contains("colr_1_variable.ttf") {
        let (name, data) = @lib.get_all_test_fonts()[2]
        analyze_font(name + " (测试数据)", data)
      }
      println("")
    }
  }
}

fn main { 
  let test_fonts = @lib.get_all_test_fonts()
  if test_fonts.length() > 0 {
    let (_, sample_data) = test_fonts[0]
    demo_reader_usage(sample_data)
  }
  
  // 尝试读取真实字体文件
  let font_files = ["src/fonts/demo.ttf", "src/fonts/colr_1.ttf", "src/fonts/colr_1_variable.ttf"]
  
  println("尝试读取真实字体文件 (使用 @x.fs.read_file_to_bytes)...")
  println("")
  
  for i = 0; i < font_files.length(); i = i + 1 {
    analyze_real_font(font_files[i])
  }
  
  println("========================================")
  println("           使用内嵌测试数据")
  println("========================================")
  println("")
  
  // 使用模块化的测试数据进行完整演示
  for i = 0; i < test_fonts.length(); i = i + 1 {
    let (name, data) = test_fonts[i]
    analyze_font(name, data)
  }
}