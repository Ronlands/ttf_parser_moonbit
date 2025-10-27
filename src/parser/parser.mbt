/// TTF Font Parser - Table Parsing Module
/// Responsible for parsing various TTF table structures

// ==================== Table Parsing Module ====================

/// Find specified table
pub fn find_table(tables : @types.TableDirectory, tag : String) -> Option[@types.TableDirectoryEntry] {
  for i = 0; i < tables.entries.length(); i = i + 1 {
    if tables.entries[i].tag == tag {
      return Some(tables.entries[i])
    }
  }
  None
}

/// Parse font file header
pub fn[R : @reader.ByteReader] parse_font_header(reader : R) -> @types.ParseResult[@types.FontHeader] {
  reader.seek(0)
  
  if reader.length() < 12 {
    @types.make_error("File too small to contain valid font header")
  } else {
    match (
      @reader.read_u32_be(reader),
      @reader.read_u16_be(reader),
      @reader.read_u16_be(reader),
      @reader.read_u16_be(reader),
      @reader.read_u16_be(reader)
    ) {
      (Some(version), Some(num_tables), Some(search_range), Some(entry_selector), Some(range_shift)) => {
        @types.make_success(@types.make_font_header(version, num_tables, search_range, entry_selector, range_shift))
      }
      _ => @types.make_error("Unable to read font header data")
    }
  }
}

/// Parse single table directory entry
fn[R : @reader.ByteReader] parse_table_entry(reader : R) -> @types.ParseResult[@types.TableDirectoryEntry] {
  match (
    @reader.read_tag(reader),
    @reader.read_u32_be(reader),
    @reader.read_u32_be(reader),
    @reader.read_u32_be(reader)
  ) {
    (Some(tag), Some(checksum), Some(offset), Some(length)) => {
      @types.make_success(@types.make_table_entry(tag, checksum, offset, length))
    }
    _ => @types.make_error("Unable to read table directory entry data")
  }
}

/// Parse table directory
pub fn[R : @reader.ByteReader] parse_table_directory(reader : R) -> @types.ParseResult[@types.TableDirectory] {
  match parse_font_header(reader) {
    @types.Success(header) => {
      reader.seek(12)  // Skip file header
      
      let mut entries = []
      
      // Parse all table directory entries
      for i = 0; i < header.num_tables; i = i + 1 {
        match parse_table_entry(reader) {
          @types.Success(entry) => {
            entries = entries + [entry]
          }
          @types.Error(_) => {
            // If a table parsing fails, continue parsing other tables
            ()
          }
        }
      }
      
      @types.make_success(@types.make_table_directory(header, entries))
    }
    @types.Error(msg) => @types.make_error(msg)
  }
}

/// Parse head table
pub fn[R : @reader.ByteReader] parse_head_table(reader : R, table : @types.TableDirectoryEntry) -> @types.ParseResult[@types.HeadTable] {
  reader.seek(table.offset)
  
  match (
    @reader.read_u32_be(reader),  // version
    @reader.read_u32_be(reader),  // font_revision
    @reader.read_u32_be(reader),  // checksum_adjustment
    @reader.read_u32_be(reader),  // magic_number
    @reader.read_u16_be(reader),  // flags
    @reader.read_u16_be(reader),  // units_per_em
    @reader.read_u32_be(reader),  // created (high)
    @reader.read_u32_be(reader),  // created (low)
    @reader.read_u32_be(reader),  // modified (high)
    @reader.read_u32_be(reader),  // modified (low)
    @reader.read_u16_be(reader),  // x_min
    @reader.read_u16_be(reader),  // y_min
    @reader.read_u16_be(reader),  // x_max
    @reader.read_u16_be(reader),  // y_max
    @reader.read_u16_be(reader),  // mac_style
    @reader.read_u16_be(reader),  // lowest_rec_ppem
    @reader.read_u16_be(reader),  // font_direction_hint
    @reader.read_u16_be(reader),  // index_to_loc_format
    @reader.read_u16_be(reader)   // glyph_data_format
  ) {
    (
      Some(version), Some(font_revision), Some(checksum_adjustment), Some(magic_number),
      Some(flags), Some(units_per_em), Some(created_h), Some(_),
      Some(modified_h), Some(_), Some(x_min), Some(y_min),
      Some(x_max), Some(y_max), Some(mac_style), Some(lowest_rec_ppem),
      Some(font_direction_hint), Some(index_to_loc_format), Some(glyph_data_format)
    ) => {
      @types.make_success(@types.make_head_table(
        version, font_revision, checksum_adjustment, magic_number,
        flags, units_per_em, created_h, modified_h,
        x_min, y_min, x_max, y_max,
        mac_style, lowest_rec_ppem, font_direction_hint,
        index_to_loc_format, glyph_data_format
      ))
    }
    _ => @types.make_error("Unable to read head table data")
  }
}

/// Parse maxp table
pub fn[R : @reader.ByteReader] parse_maxp_table(reader : R, table : @types.TableDirectoryEntry) -> @types.ParseResult[@types.MaxpTable] {
  reader.seek(table.offset)
  
  match (
    @reader.read_u32_be(reader),  // version
    @reader.read_u16_be(reader)   // num_glyphs
  ) {
    (Some(version), Some(num_glyphs)) => {
      // Read more information (only exists in version 1.0)
      if version == 0x00010000 {
        match (
          @reader.read_u16_be(reader),  // max_points
          @reader.read_u16_be(reader),  // max_contours
          @reader.read_u16_be(reader),  // max_composite_points
          @reader.read_u16_be(reader)   // max_composite_contours
        ) {
          (Some(max_points), Some(max_contours), Some(max_composite_points), Some(max_composite_contours)) => {
            @types.make_success(@types.make_maxp_table(version, num_glyphs, max_points, max_contours, max_composite_points, max_composite_contours))
          }
          _ => @types.make_success(@types.make_maxp_table(version, num_glyphs, 0, 0, 0, 0))
        }
      } else {
        @types.make_success(@types.make_maxp_table(version, num_glyphs, 0, 0, 0, 0))
      }
    }
    _ => @types.make_error("Unable to read maxp table data")
  }
}

/// Parse hhea table for font metrics
pub fn[R : @reader.ByteReader] parse_hhea_table(reader : R, table : @types.TableDirectoryEntry) -> @types.ParseResult[@types.HheaTable] {
  reader.seek(table.offset)
  
  match (
    @reader.read_u32_be(reader),  // version
    @reader.read_u16_be(reader),  // ascender (signed)
    @reader.read_u16_be(reader),  // descender (signed)
    @reader.read_u16_be(reader),  // line_gap (signed)
    @reader.read_u16_be(reader),  // advance_width_max
    @reader.read_u16_be(reader),  // min_left_side_bearing (signed)
    @reader.read_u16_be(reader),  // min_right_side_bearing (signed)
    @reader.read_u16_be(reader),  // x_max_extent (signed)
    @reader.read_u16_be(reader),  // caret_slope_rise (signed)
    @reader.read_u16_be(reader),  // caret_slope_run (signed)
    @reader.read_u16_be(reader),  // caret_offset (signed)
    @reader.read_u16_be(reader),  // reserved1
    @reader.read_u16_be(reader),  // reserved2
    @reader.read_u16_be(reader),  // reserved3
    @reader.read_u16_be(reader),  // reserved4
    @reader.read_u16_be(reader),  // metric_data_format
    @reader.read_u16_be(reader)   // number_of_h_metrics
  ) {
    (
      Some(version), Some(ascender), Some(descender), Some(line_gap),
      Some(advance_width_max), Some(min_left_side_bearing), Some(min_right_side_bearing), Some(x_max_extent),
      Some(caret_slope_rise), Some(caret_slope_run), Some(caret_offset),
      Some(_), Some(_), Some(_), Some(_),  // reserved fields
      Some(metric_data_format), Some(number_of_h_metrics)
    ) => {
      // Convert unsigned to signed for metrics that can be negative
      let signed_ascender = if ascender > 32767 { ascender - 65536 } else { ascender }
      let signed_descender = if descender > 32767 { descender - 65536 } else { descender }
      let signed_line_gap = if line_gap > 32767 { line_gap - 65536 } else { line_gap }
      let signed_min_lsb = if min_left_side_bearing > 32767 { min_left_side_bearing - 65536 } else { min_left_side_bearing }
      let signed_min_rsb = if min_right_side_bearing > 32767 { min_right_side_bearing - 65536 } else { min_right_side_bearing }
      let signed_x_max_extent = if x_max_extent > 32767 { x_max_extent - 65536 } else { x_max_extent }
      let signed_caret_slope_rise = if caret_slope_rise > 32767 { caret_slope_rise - 65536 } else { caret_slope_rise }
      let signed_caret_slope_run = if caret_slope_run > 32767 { caret_slope_run - 65536 } else { caret_slope_run }
      let signed_caret_offset = if caret_offset > 32767 { caret_offset - 65536 } else { caret_offset }
      
      @types.make_success(@types.make_hhea_table(
        version, signed_ascender, signed_descender, signed_line_gap,
        advance_width_max, signed_min_lsb, signed_min_rsb, signed_x_max_extent,
        signed_caret_slope_rise, signed_caret_slope_run, signed_caret_offset,
        metric_data_format, number_of_h_metrics
      ))
    }
    _ => @types.make_error("Unable to read hhea table data")
  }
}

/// Parse name table for font names
pub fn[R : @reader.ByteReader] parse_name_table(reader : R, table : @types.TableDirectoryEntry) -> @types.ParseResult[@types.NameTable] {
  reader.seek(table.offset)
  
  match (
    @reader.read_u16_be(reader),  // format
    @reader.read_u16_be(reader),  // count
    @reader.read_u16_be(reader)   // string_offset
  ) {
    (Some(format), Some(count), Some(string_offset)) => {
      let mut records = []
      
      // Parse name records
      for i = 0; i < count; i = i + 1 {
        match (
          @reader.read_u16_be(reader),  // platform_id
          @reader.read_u16_be(reader),  // encoding_id
          @reader.read_u16_be(reader),  // language_id
          @reader.read_u16_be(reader),  // name_id
          @reader.read_u16_be(reader),  // length
          @reader.read_u16_be(reader)   // offset
        ) {
          (Some(platform_id), Some(encoding_id), Some(language_id), Some(name_id), Some(length), Some(offset)) => {
            // For now, create record with empty string - we'll read the actual string later
            let record = @types.make_name_record(platform_id, encoding_id, language_id, name_id, length, offset, "")
            records = records + [record]
          }
          _ => {
            // Skip invalid record
            ()
          }
        }
      }
      
      // Read actual string values for important name IDs
      let mut final_records = []
      for i = 0; i < records.length(); i = i + 1 {
        let record = records[i]
        let mut string_value = ""
        
        // Only read strings for common name IDs to avoid complexity
        if record.name_id == 1 || record.name_id == 2 || record.name_id == 4 || record.name_id == 6 {
          // Seek to string position
          let string_pos = table.offset + string_offset + record.offset
          if string_pos + record.length <= reader.length() {
            reader.seek(string_pos)
            
            // Read string bytes (simplified - assume ASCII for now)
            let mut bytes = []
            for j = 0; j < record.length; j = j + 1 {
              match reader.read_byte() {
                Some(byte) => bytes = bytes + [byte]
                None => break
              }
            }
            
            // Convert bytes to string (simplified ASCII conversion)
            for k = 0; k < bytes.length(); k = k + 1 {
              let byte = bytes[k]
              if byte >= 32 && byte <= 126 {
                string_value = string_value + Int::unsafe_to_char(byte).to_string()
              }
            }
          }
        }
        
        let final_record = @types.make_name_record(
          record.platform_id, record.encoding_id, record.language_id, 
          record.name_id, record.length, record.offset, string_value
        )
        final_records = final_records + [final_record]
      }
      
      @types.make_success(@types.make_name_table(format, count, string_offset, final_records))
    }
    _ => @types.make_error("Unable to read name table data")
  }
}