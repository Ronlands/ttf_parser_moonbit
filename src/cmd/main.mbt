/// TTF Font Parser Demo Program
/// Using modular MoonBit TTF parser

// File size thresholds
let large_file_threshold = 500000
let smart_analysis_threshold = 100000
let header_read_size = 2048
let fallback_sample_size = 10240
// Maximum data to read for large files
let max_smart_read_size = 51200
// Fast mode for very large files
let fast_mode_threshold = 500000
let fast_mode_read_size = 8192

fn demo_reader_usage(data : Array[Int]) -> Unit {
  let reader = @reader.ArrayByteReader::new(data)
  
  println("  Data length: " + reader.length().to_string() + " bytes")
  println("  Current position: " + reader.position().to_string())
  
  match @reader.read_u32_be(reader) {
    Some(version) => {
      println("  File version: 0x" + version.to_string())
      if version == 0x00010000 {
        println("  Valid TTF file")
      } else {
        println("  May not be a standard TTF file")
      }
    }
    None => println("  Unable to read file version")
  }
  
  reader.seek(0)
  println("  Position reset to: " + reader.position().to_string())
  println("")
}



fn analyze_font(name : String, data : Array[Int]) -> Unit {
  println("=== Analyzing font file: " + name + " ===")
  println("Data size: " + data.length().to_string() + " bytes")
  println("Description: " + @lib.get_font_description(name))
  
  show_progress(1, data.length())
  
  match @lib.validate_ttf_structure(data) {
    @types.Success(msg) => {
      println("Font validation: " + msg)
    }
    @types.Error(msg) => {
      println("Font validation failed: " + msg)
      return
    }
  }
  
  show_progress(2, data.length())
  
  let format = @lib.get_font_format(data)
  println("Font format: " + format)
  
  show_progress(3, data.length())
  
  match @lib.get_font_header(data) {
    @types.Success(header) => {
      println("Font header parsing successful")
      println("  Version: 0x" + header.version.to_string())
      println("  Number of tables: " + header.num_tables.to_string())
      println("  Search range: " + header.search_range.to_string())
      println("  Entry selector: " + header.entry_selector.to_string())
      println("  Range shift: " + header.range_shift.to_string())
    }
    @types.Error(msg) => {
      println("Font header parsing failed: " + msg)
      return
    }
  }
  
  show_progress(4, data.length())
  
  match @lib.get_table_directory(data) {
    @types.Success(tables) => {
      println("Table directory parsing successful")
      println("  Found " + tables.entries.length().to_string() + " tables:")
      
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
      println("Table directory parsing failed: " + msg)
      return
    }
  }
  
  show_progress(5, data.length())
  
  match @lib.analyze_font_features_from_bytes(data) {
    @types.Success(features) => {
      println("Font feature analysis:")
      println("    Table count: " + features.table_count.to_string())
      
      let mut core_table_count = 0
      for i = 0; i < features.supported_tables.length(); i = i + 1 {
        if @lib.is_core_table_check(features.supported_tables[i]) {
          core_table_count = core_table_count + 1
        }
      }
      println("    Core tables: " + core_table_count.to_string() + "/5")
      
      if features.has_color {
        println("    Supports color fonts")
      }
      if features.has_variable {
        println("    Supports variable fonts")
      }
      if features.has_opentype_features {
        println("    Supports OpenType features")
      }
      if !features.has_color && !features.has_variable {
        println("    Standard monochrome font")
      }
      
      let recommendation = @lib.get_font_usage_recommendation(data)
      println("    Recommended usage: " + recommendation)
    }
    @types.Error(msg) => {
      println("Font feature analysis failed: " + msg)
    }
  }
  
  if data.length() > 500000 {
    println("Parsing progress: ██████")
  }
  match @lib.parse_ttf_from_bytes(data) {
    @types.Success(info) => {
      println("Font information parsing successful")
      println("  Font name: " + info.name)
      println("  Font family: " + info.family)
      println("  Font style: " + info.style)
      println("  Font version: " + info.version)
      println("  Number of characters: " + info.num_glyphs.to_string())
      println("  Units per EM: " + info.units_per_em.to_string())
      println("  Ascender: " + info.ascender.to_string())
      println("  Descender: " + info.descender.to_string())
      println("  Line gap: " + info.line_gap.to_string())
      
      let font_size = 16
      println("  " + font_size.to_string() + "px font size basic metrics:")
      println("    Ascender: " + (info.ascender * font_size / info.units_per_em).to_string() + "px")
      println("    Descender: " + (info.descender * font_size / info.units_per_em).to_string() + "px") 
      let line_height = (info.ascender - info.descender + info.line_gap) * font_size / info.units_per_em
      println("    Line height: " + line_height.to_string() + "px")
    }
    @types.Error(msg) => {
      println("Font information parsing failed: " + msg)
    }
  }
  
  if data.length() > large_file_threshold {
    println("Parsing progress: ████████████████████ 100%")
    println("Large file parsing completed")
  }
  
  println("")
}

/// Extract filename from file path
fn extract_filename(file_path : String) -> String {
  let path_parts = file_path.split("/")
  let parts_array = path_parts.to_array()
  if parts_array.length() > 0 {
    parts_array[parts_array.length() - 1].to_string()
  } else {
    file_path
  }
}

fn format_file_size(size : Int) -> String {
  if size > 1000000 {
    "File size: " + (size / 1024 / 1024).to_string() + "MB"
  } else if size > 1000 {
    "File size: " + (size / 1024).to_string() + "KB"
  } else {
    "File size: " + size.to_string() + "B"
  }
}

fn estimate_processing_time(file_size : Int) -> String {
  if file_size > 5000000 {
    "Estimated processing time: 5-10s"
  } else if file_size > 1000000 {
    "Estimated processing time: 2-5s"
  } else if file_size > 100000 {
    "Estimated processing time: 1-2s"
  } else {
    "Estimated processing time: <1s"
  }
}

fn should_use_optimization(file_size : Int) -> Bool {
  file_size > smart_analysis_threshold
}

struct FontAnalysisStats {
  total_files : Int
  successful_parses : Int
  failed_parses : Int
  total_size_bytes : Int
  largest_file_size : Int
  smallest_file_size : Int
} derive(Show)

fn new_stats() -> FontAnalysisStats {
  { total_files: 0, successful_parses: 0, failed_parses: 0, 
    total_size_bytes: 0, largest_file_size: 0, smallest_file_size: 999999999 }
}

fn update_stats(stats : FontAnalysisStats, file_size : Int, success : Bool) -> FontAnalysisStats {
  {
    total_files: stats.total_files + 1,
    successful_parses: if success { stats.successful_parses + 1 } else { stats.successful_parses },
    failed_parses: if success { stats.failed_parses } else { stats.failed_parses + 1 },
    total_size_bytes: stats.total_size_bytes + file_size,
    largest_file_size: if file_size > stats.largest_file_size { file_size } else { stats.largest_file_size },
    smallest_file_size: if file_size < stats.smallest_file_size { file_size } else { stats.smallest_file_size }
  }
}

fn show_stats(stats : FontAnalysisStats) -> Unit {
  println("Font File Analysis Statistics")
  println("========================================")
  println("Total files: " + stats.total_files.to_string())
  println("Successful parses: " + stats.successful_parses.to_string())
  println("Failed parses: " + stats.failed_parses.to_string())
  
  if stats.total_files > 0 {
    let success_rate = stats.successful_parses * 100 / stats.total_files
    println("Success rate: " + success_rate.to_string() + "%")
  }
  
  if stats.total_size_bytes > 0 {
    println("Total data: " + format_file_size(stats.total_size_bytes))
    if stats.total_files > 1 {
      println("Largest file: " + format_file_size(stats.largest_file_size))
      println("Smallest file: " + format_file_size(stats.smallest_file_size))
    }
  }
  println("========================================")
}

fn show_progress(current_step : Int, data_size : Int) -> Unit {
  if data_size > large_file_threshold {
    let progress_chars = ["█", "██", "███", "████", "█████", "██████"]
    if current_step <= progress_chars.length() {
      println("Parsing progress: " + progress_chars[current_step - 1])
    }
  }
}

fn bytes_to_int_array(content : Bytes) -> Array[Int] {
  let mut result = []
  for i = 0; i < content.length(); i = i + 1 {
    result = result + [content[i].to_int()]
  }
  result
}

fn bytes_to_int_array_limited(content : Bytes, max_size : Int) -> Array[Int] {
  let read_size = if content.length() > max_size { max_size } else { content.length() }
  let mut result = []
  for i = 0; i < read_size; i = i + 1 {
    result = result + [content[i].to_int()]
  }
  result
}

fn analyze_real_font_smart(file_path : String, content : Bytes) -> Unit {
  let file_size = content.length()
  
  if file_size > fast_mode_threshold {
    println("Large file detected - using fast mode")
    let fast_data = bytes_to_int_array_limited(content, fast_mode_read_size)
    let file_name = extract_filename(file_path)
    println("Fast mode: reading first " + (fast_mode_read_size / 1024).to_string() + "KB data")
    analyze_font(file_name + " (fast mode)", fast_data)
    return
  }
  
  println("Step 1: Analyzing file structure...")
  
  let header_size = if file_size > header_read_size { header_read_size } else { file_size }
  let header_data = bytes_to_int_array_limited(content, header_size)
  
  match @lib.get_table_directory(header_data) {
    @types.Success(tables) => {
      println("Found " + tables.entries.length().to_string() + " tables")
      
      let key_tables = ["head", "hhea", "maxp", "name"]
      let mut max_needed_offset = header_size
      let mut found_tables = []
      
      for table_name in key_tables {
        let mut table_found = false
        for i = 0; i < tables.entries.length(); i = i + 1 {
          if tables.entries[i].tag == table_name {
            let table_end = tables.entries[i].offset + tables.entries[i].length
            if table_end <= max_smart_read_size && table_end > max_needed_offset {
              max_needed_offset = table_end
            }
            found_tables = found_tables + [table_name]
            table_found = true
            break
          }
        }
        if !table_found {
          println("  - " + table_name + " table not found")
        }
      }
      
      if max_needed_offset > max_smart_read_size {
        max_needed_offset = max_smart_read_size
        println("  Limited read size to " + (max_smart_read_size / 1024).to_string() + "KB for performance")
      }
      
      println("Step 2: Reading essential table data...")
      
      let read_size = if max_needed_offset > file_size { file_size } else { max_needed_offset }
      
      println("  Smart read " + (read_size / 1024).to_string() + "KB data (skipping " + ((file_size - read_size) / 1024).to_string() + "KB)")
      
      let complete_data = bytes_to_int_array_limited(content, read_size)
      
      println("  Successfully read " + found_tables.length().to_string() + " key tables")
      
      let file_name = extract_filename(file_path)
      
      println("Step 3: Parsing font information...")
      analyze_font(file_name, complete_data)
    }
    @types.Error(msg) => {
      println("Table directory parsing failed: " + msg)
      println("Fallback to simple parsing mode...")
      
      let sample_size = if file_size > fallback_sample_size { fallback_sample_size } else { file_size }
      println("  Fallback mode: reading first " + (sample_size / 1024).to_string() + "KB data")
      let limited_data = bytes_to_int_array_limited(content, sample_size)
      
      let file_name = extract_filename(file_path)
      
      analyze_font(file_name + " (partial parsing)", limited_data)
    }
  }
}

fn analyze_real_font_with_stats(file_path : String, stats : FontAnalysisStats) -> FontAnalysisStats {
  println("=== Analyzing font file: " + file_path + " ===")
  
  try {
    let content = @fs.read_file_to_bytes(file_path)
    let file_size = content.length()
    
    println(format_file_size(file_size))
    println(estimate_processing_time(file_size))
    
    if should_use_optimization(file_size) {
      println("Large file detected, using optimization strategy")
    }
    
    if should_use_optimization(file_size) {
      analyze_real_font_smart(file_path, content)
    } else {
      println("Small file - complete read")
      let complete_data = bytes_to_int_array(content)
      let file_name = extract_filename(file_path)
      analyze_font(file_name, complete_data)
    }
    
    println("")
    update_stats(stats, file_size, true)
  } catch {
    IOError(msg) => {
      println("File read failed: " + msg)
      
      if msg.contains("No such file") {
        println("Reason: File does not exist - " + file_path)
        println("Suggestion: Check file path")
      } else if msg.contains("Permission denied") {
        println("Reason: No file read permission")
        println("Suggestion: Check file permissions")
      } else {
        println("Unknown error, please check file status")
      }
      
      println("Fallback to test data demo...")
      
      let test_fonts = @lib.get_all_test_fonts()
      if test_fonts.length() > 0 {
        let fallback_index = if file_path.contains("demo.ttf") { 0 } else { 0 }
        let (name, data) = test_fonts[fallback_index]
        analyze_font(name + " (test data fallback)", data)
      } else {
        println("Unable to load test data")
      }
      
      println("")
      update_stats(stats, 0, false)
    }
  }
}


fn main { 
  println("TTF Font Parser Demo Program")
  println("========================================")
  println("")
  
  let test_fonts = @lib.get_all_test_fonts()
  if test_fonts.length() > 0 {
    println("Demonstrating byte reader functionality...")
    let (_, sample_data) = test_fonts[0]
    demo_reader_usage(sample_data)
  }
  
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
  
  println("Starting real font file analysis... (" + font_files.length().to_string() + " files)")
  println("")
  
  let mut stats = new_stats()
  for i = 0; i < font_files.length(); i = i + 1 {
    println("[Progress " + (i + 1).to_string() + "/" + font_files.length().to_string() + "]")
    stats = analyze_real_font_with_stats(font_files[i], stats)
  }
  
  show_stats(stats)
  
  println("========================================")
  println("Complete Test Data Demonstration")
  println("========================================")
  println("")
  
  for i = 0; i < test_fonts.length(); i = i + 1 {
    let (name, data) = test_fonts[i]
    println("[Test Data " + (i + 1).to_string() + "/" + test_fonts.length().to_string() + "]")
    analyze_font(name, data)
  }
  
  println("All font file parsing completed!")
}