/// TTF 字体解析器 - 表解析模块
/// 负责解析各种TTF表结构

// ==================== 表解析模块 ====================

/// 查找指定的表
pub fn find_table(tables : @types.TableDirectory, tag : String) -> Option[@types.TableDirectoryEntry] {
  for i = 0; i < tables.entries.length(); i = i + 1 {
    if tables.entries[i].tag == tag {
      return Some(tables.entries[i])
    }
  }
  None
}

/// 解析字体文件头
pub fn[R : @reader.ByteReader] parse_font_header(reader : R) -> @types.ParseResult[@types.FontHeader] {
  reader.seek(0)
  
  if reader.length() < 12 {
    @types.make_error("文件太小，无法包含有效的字体头")
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
      _ => @types.make_error("无法读取字体头数据")
    }
  }
}

/// 解析单个表目录项
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
    _ => @types.make_error("无法读取表目录项数据")
  }
}

/// 解析表目录
pub fn[R : @reader.ByteReader] parse_table_directory(reader : R) -> @types.ParseResult[@types.TableDirectory] {
  match parse_font_header(reader) {
    @types.Success(header) => {
      reader.seek(12)  // 跳过文件头
      
      let mut entries = []
      
      // 解析所有表目录项
      for i = 0; i < header.num_tables; i = i + 1 {
        match parse_table_entry(reader) {
          @types.Success(entry) => {
            entries = entries + [entry]
          }
          @types.Error(_) => {
            // 如果某个表解析失败，继续解析其他表
            ()
          }
        }
      }
      
      @types.make_success(@types.make_table_directory(header, entries))
    }
    @types.Error(msg) => @types.make_error(msg)
  }
}

/// 解析 head 表
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
    _ => @types.make_error("无法读取 head 表数据")
  }
}

/// 解析 maxp 表
pub fn[R : @reader.ByteReader] parse_maxp_table(reader : R, table : @types.TableDirectoryEntry) -> @types.ParseResult[@types.MaxpTable] {
  reader.seek(table.offset)
  
  match (
    @reader.read_u32_be(reader),  // version
    @reader.read_u16_be(reader)   // num_glyphs
  ) {
    (Some(version), Some(num_glyphs)) => {
      // 读取更多信息（只在版本 1.0 中存在）
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
    _ => @types.make_error("无法读取 maxp 表数据")
  }
}
