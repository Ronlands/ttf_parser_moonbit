/// TTF Font Parser Demo Program
/// Using modular MoonBit TTF parser

fn demo_reader_usage(data : Array[Int]) -> Unit {
  
  // Use reader module to create byte reader
  let reader = @reader.ArrayByteReader::new(data)
  
  println("  Data length: " + reader.length().to_string() + " bytes")
  println("  Current position: " + reader.position().to_string())
  
  // Demo reading TTF file header (version number)
  match @reader.read_u32_be(reader) {
    Some(version) => {
      println("  File version: 0x" + version.to_string())
      if version == 0x00010000 {
        println("  ✓ This is a valid TTF file")
      } else {
        println("  ⚠ May not be a standard TTF file")
      }
    }
    None => println("  ✗ Unable to read file version")
  }
  
  // Reset position
  reader.seek(0)
  println("  Position reset to: " + reader.position().to_string())
  println("")
}



/// Analyze and display font file information
fn analyze_font(name : String, data : Array[Int]) -> Unit {
  println("=== Analyzing font file: " + name + " ===")
  println("Data size: " + data.length().to_string() + " bytes")
  println("Description: " + @lib.get_font_description(name))
  
  // Show parsing progress
  if data.length() > 500000 {
    println("Parsing progress: █")
  }
  
  // Check font file validity
  if !@lib.is_valid_ttf(data) {
    println("✗ Invalid TTF file!")
    return
  }
  
  if data.length() > 500000 {
    println("Parsing progress: ██")
  }
  
  // Get font format
  let format = @lib.get_font_format(data)
  println("✓ Font format: " + format)
  
  // Parse font file header
  if data.length() > 500000 {
    println("Parsing progress: ███")
  }
  
  match @lib.get_font_header(data) {
    @types.Success(header) => {
      println("✓ Font header parsing successful!")
      println("  Version: 0x" + header.version.to_string())
      println("  Number of tables: " + header.num_tables.to_string())
      println("  Search range: " + header.search_range.to_string())
      println("  Entry selector: " + header.entry_selector.to_string())
      println("  Range shift: " + header.range_shift.to_string())
    }
    @types.Error(msg) => {
      println("✗ Font header parsing failed: " + msg)
      return
    }
  }
  
  if data.length() > 500000 {
    println("Parsing progress: ████")
  }
  
  // Parse table directory
  
  match @lib.get_table_directory(data) {
    @types.Success(tables) => {
      println("✓ Table directory parsing successful!")
      println("  Found " + tables.entries.length().to_string() + " tables:")
      
      // Display information for all tables
      for i = 0; i < tables.entries.length(); i = i + 1 {
        let entry = tables.entries[i]
        let size_kb = if entry.length > 1024 { 
          " (" + (entry.length / 1024).to_string() + "KB)" 
        } else { 
          " (" + entry.length.to_string() + "B)" 
        }
        println("    " + (i + 1).to_string() + ". " + entry.tag + " - Offset: " + entry.offset.to_string() + ", Length: " + entry.length.to_string() + size_kb)
      }
    }
    @types.Error(msg) => {
      println("✗ Table directory parsing failed: " + msg)
      return
    }
  }
  
  if data.length() > 500000 {
    println("Parsing progress: █████")
  }
  
  // Analyze font features
  
  match @lib.analyze_font_features_from_bytes(data) {
    @types.Success(features) => {
      println("✓ Font feature analysis:")
      println("    Table count: " + features.table_count.to_string())
      
      let mut core_table_count = 0
      for i = 0; i < features.supported_tables.length(); i = i + 1 {
        if @lib.is_core_table_check(features.supported_tables[i]) {
          core_table_count = core_table_count + 1
        }
      }
      println("    Core tables: " + core_table_count.to_string() + "/5")
      
      if features.has_color {
        println("    ✓ Supports color fonts")
      }
      if features.has_variable {
        println("    ✓ Supports variable fonts")
      }
      if features.has_opentype_features {
        println("    ✓ Supports OpenType features")
      }
      if !features.has_color && !features.has_variable {
        println("    - Standard monochrome font")
      }
      
      // Show usage recommendations
      let recommendation = @lib.get_font_usage_recommendation(data)
      println("    Recommended usage: " + recommendation)
    }
    @types.Error(msg) => {
      println("✗ Font feature analysis failed: " + msg)
    }
  }
  
  if data.length() > 500000 {
    println("Parsing progress: ██████")
  }
  
  // Parse basic font information
  
  match @lib.parse_ttf_from_bytes(data) {
    @types.Success(info) => {
      println("✓ Font information parsing successful!")
      println("  Font name: " + info.name)
      println("  Font family: " + info.family)
      println("  Font style: " + info.style)
      println("  Font version: " + info.version)
      println("  Number of characters: " + info.num_glyphs.to_string())
      println("  Units per EM: " + info.units_per_em.to_string())
      println("  Ascender: " + info.ascender.to_string())
      println("  Descender: " + info.descender.to_string())
      println("  Line gap: " + info.line_gap.to_string())
      
      // Display font metrics information
      let font_size = 16
      println("  " + font_size.to_string() + "px font size basic metrics:")
      println("    Ascender: " + (info.ascender * font_size / info.units_per_em).to_string() + "px")
      println("    Descender: " + (info.descender * font_size / info.units_per_em).to_string() + "px") 
      let line_height = (info.ascender - info.descender + info.line_gap) * font_size / info.units_per_em
      println("    Line height: " + line_height.to_string() + "px")
    }
    @types.Error(msg) => {
      println("✗ Font information parsing failed: " + msg)
    }
  }
  
  // Complete progress bar
  if data.length() > 500000 {
    println("Parsing progress: ████████████████████ 100%")
    println("Large file parsing completed!")
  }
  
  println("")
}

/// Analyze font file
fn analyze_real_font(file_path : String) -> Unit {
  println("=== Attempting to read font file: " + file_path + " ===")
  
  // Read file once and check size
  try {
    let content = @fs.read_file_to_bytes(file_path)
    let file_size = content.length()
    
    // Display file size information
    if file_size > 1000000 {
      println("File size: " + (file_size / 1024 / 1024).to_string() + "MB")
    } else if file_size > 1000 {
      println("File size: " + (file_size / 1024).to_string() + "KB")
    } else {
      println("File size: " + file_size.to_string() + "B")
    }
    
    // Show processing progress
    if file_size > 500000 {
      println("Processing large file, please wait...")
      println("Reading file: ████████████████████ 100%")
    }
    
    // Use the already read content directly, avoid re-reading
    // For large files, skip detailed conversion process, only do basic analysis
    let mut result = []
    
    if file_size > 1000000 {
      // Very large file: only read first 100KB for analysis
      println("File too large, analyzing only first 100KB of data...")
      let sample_size = 100000
      for i = 0; i < sample_size && i < content.length(); i = i + 1 {
        result = result + [content[i].to_int()]
      }
    } else if file_size > 100000 {
      // Large file: convert in batches
      let batch_size = 100000
      let total_batches = (file_size + batch_size - 1) / batch_size
      println("Converting data format: 0/" + total_batches.to_string() + " batches")
      
      for batch = 0; batch < total_batches; batch = batch + 1 {
        let start = batch * batch_size
        let end = if start + batch_size > file_size { file_size } else { start + batch_size }
        
        for i = start; i < end; i = i + 1 {
          result = result + [content[i].to_int()]
        }
        
        // Show progress
        if batch % 2 == 0 || batch == total_batches - 1 {
          println("Converting data format: " + (batch + 1).to_string() + "/" + total_batches.to_string() + " batches")
        }
      }
    } else {
      // Small file: direct conversion
      for i = 0; i < content.length(); i = i + 1 {
        result = result + [content[i].to_int()]
      }
    }
    
    // Simple filename extraction (from path)
    let mut file_name = file_path
    let path_parts = file_path.split("/")
    // Convert iterator to array
    let parts_array = path_parts.to_array()
    if parts_array.length() > 0 {
      file_name = parts_array[parts_array.length() - 1].to_string()
    }
    
    analyze_font(file_name, result)
  } catch {
    _ => {
      println("✗ Unable to read file: " + file_path)
      println("")
      println("Falling back to test data demo...")
      // As fallback, use corresponding test data
      if file_path.contains("demo.ttf") {
        let (name, data) = @lib.get_all_test_fonts()[0]
        analyze_font(name + " (test data)", data)
      } else if file_path.contains("colr_1.ttf") && !file_path.contains("variable") {
        let (name, data) = @lib.get_all_test_fonts()[1]
        analyze_font(name + " (test data)", data)
      } else if file_path.contains("colr_1_variable.ttf") {
        let (name, data) = @lib.get_all_test_fonts()[2]
        analyze_font(name + " (test data)", data)
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
  
  // Try to read font files
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
  
  println("Attempting to read font files (using @x.fs.read_file_to_bytes)...")
  println("")
  
  for i = 0; i < font_files.length(); i = i + 1 {
    analyze_real_font(font_files[i])
  }
  
  println("========================================")
  println("           Using embedded test data")
  println("========================================")
  println("")
  
  // Use modular test data for complete demonstration
  for i = 0; i < test_fonts.length(); i = i + 1 {
    let (name, data) = test_fonts[i]
    analyze_font(name, data)
  }
}