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



/// 分析并显示字体文件信息
fn analyze_font(name : String, data : Array[Int]) -> Unit {
  println("=== 分析字体文件: " + name + " ===")
  println("数据大小: " + data.length().to_string() + " 字节")
  println("描述: " + @lib.get_font_description(name))
  
  // 显示解析进度
  if data.length() > 500000 {
    println("解析进度: █")
  }
  
  // 检查字体文件有效性
  if !@lib.is_valid_ttf(data) {
    println("✗ 无效的TTF文件!")
    return
  }
  
  if data.length() > 500000 {
    println("解析进度: ██")
  }
  
  // 获取字体格式
  let format = @lib.get_font_format(data)
  println("✓ 字体格式: " + format)
  
  // 解析字体文件头
  if data.length() > 500000 {
    println("解析进度: ███")
  }
  
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
  
  if data.length() > 500000 {
    println("解析进度: ████")
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
  
  if data.length() > 500000 {
    println("解析进度: █████")
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
  
  if data.length() > 500000 {
    println("解析进度: ██████")
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
  
  // 完成进度条
  if data.length() > 500000 {
    println("解析进度: ████████████████████ 100%")
    println("大文件解析完成!")
  }
  
  println("")
}

/// 分析字体文件
fn analyze_real_font(file_path : String) -> Unit {
  println("=== 尝试读取字体文件: " + file_path + " ===")
  
  // 一次性读取文件并检查大小
  try {
    let content = @fs.read_file_to_bytes(file_path)
    let file_size = content.length()
    
    // 显示文件大小信息
    if file_size > 1000000 {
      println("文件大小: " + (file_size / 1024 / 1024).to_string() + "MB")
    } else if file_size > 1000 {
      println("文件大小: " + (file_size / 1024).to_string() + "KB")
    } else {
      println("文件大小: " + file_size.to_string() + "B")
    }
    
    // 显示处理进度
    if file_size > 500000 {
      println("正在处理大文件，请稍候...")
      println("读取文件: ████████████████████ 100%")
    }
    
    // 直接使用已读取的内容，避免重复读取
    // 对于大文件，跳过详细的转换过程，只做基本分析
    let mut result = []
    
    if file_size > 1000000 {
      // 超大文件：只读取前100KB进行分析
      println("文件过大，只分析前100KB数据...")
      let sample_size = 100000
      for i = 0; i < sample_size && i < content.length(); i = i + 1 {
        result = result + [content[i].to_int()]
      }
    } else if file_size > 100000 {
      // 大文件：分批转换
      let batch_size = 100000
      let total_batches = (file_size + batch_size - 1) / batch_size
      println("转换数据格式: 0/" + total_batches.to_string() + " 批次")
      
      for batch = 0; batch < total_batches; batch = batch + 1 {
        let start = batch * batch_size
        let end = if start + batch_size > file_size { file_size } else { start + batch_size }
        
        for i = start; i < end; i = i + 1 {
          result = result + [content[i].to_int()]
        }
        
        // 显示进度
        if batch % 2 == 0 || batch == total_batches - 1 {
          println("转换数据格式: " + (batch + 1).to_string() + "/" + total_batches.to_string() + " 批次")
        }
      }
    } else {
      // 小文件：直接转换
      for i = 0; i < content.length(); i = i + 1 {
        result = result + [content[i].to_int()]
      }
    }
    
    // 简单提取文件名（从路径中）
    let mut file_name = file_path
    let path_parts = file_path.split("/")
    // 将迭代器转换为数组
    let parts_array = path_parts.to_array()
    if parts_array.length() > 0 {
      file_name = parts_array[parts_array.length() - 1].to_string()
    }
    
    analyze_font(file_name, result)
  } catch {
    _ => {
      println("✗ 无法读取文件: " + file_path)
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
  
  // 尝试读取字体文件
  let font_files = [
    "src/fonts/demo.ttf", 
    "src/fonts/colr_1.ttf", 
    "src/fonts/colr_1_variable.ttf",
    "src/fonts/xixian.ttf",
    "src/fonts/yahei.ttf", 
    "src/fonts/kaiti.ttf",
    "src/fonts/keshi.ttf",
    "src/fonts/kaiti2.ttf",
    "src/fonts/fseng.ttf",
    "src/fonts/marker.ttf"
  ]
  
  println("尝试读取字体文件 (使用 @x.fs.read_file_to_bytes)...")
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