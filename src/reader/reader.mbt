/// TTF Font Parser - Binary Reading Module
/// Provides byte stream reading functionality

// ==================== Binary Reading Module ====================

/// Byte stream reader interface
pub trait ByteReader {
  /// Read one byte
  read_byte(Self) -> Option[Int]
  /// Get current position
  position(Self) -> Int
  /// Set position
  seek(Self, Int) -> Unit
  /// Get total length
  length(Self) -> Int
}

/// Array byte reader implementation
pub struct ArrayByteReader {
  data : Array[Int]
  mut pos : Int
} derive(Show)

/// Create array byte reader
pub fn ArrayByteReader::new(data : Array[Int]) -> ArrayByteReader {
  { data: data, pos: 0 }
}

/// Implement ByteReader trait for ArrayByteReader
pub impl ByteReader for ArrayByteReader with read_byte(self) {
  if self.pos < self.data.length() {
    let byte = self.data[self.pos]
    self.pos = self.pos + 1
    Some(byte)
  } else {
    None
  }
}

pub impl ByteReader for ArrayByteReader with position(self) { self.pos }
pub impl ByteReader for ArrayByteReader with seek(self, pos) { self.pos = pos }
pub impl ByteReader for ArrayByteReader with length(self) { self.data.length() }

/// Read big-endian 32-bit integer from byte reader
pub fn[R : ByteReader] read_u32_be(reader : R) -> Option[Int] {
  match (reader.read_byte(), reader.read_byte(), reader.read_byte(), reader.read_byte()) {
    (Some(b0), Some(b1), Some(b2), Some(b3)) => {
      Some((b0 << 24) | (b1 << 16) | (b2 << 8) | b3)
    }
    _ => None
  }
}

/// Read big-endian 16-bit integer from byte reader
pub fn[R : ByteReader] read_u16_be(reader : R) -> Option[Int] {
  match (reader.read_byte(), reader.read_byte()) {
    (Some(b0), Some(b1)) => {
      Some((b0 << 8) | b1)
    }
    _ => None
  }
}

/// Read 4-character tag from byte reader
pub fn[R : ByteReader] read_tag(reader : R) -> Option[String] {
  match (reader.read_byte(), reader.read_byte(), reader.read_byte(), reader.read_byte()) {
    (Some(b0), Some(b1), Some(b2), Some(b3)) => {
      Some(bytes_to_tag_string(b0, b1, b2, b3))
    }
    _ => None
  }
}

/// Convert bytes to tag string
pub fn bytes_to_tag_string(b0 : Int, b1 : Int, b2 : Int, b3 : Int) -> String {
  // Return corresponding tag string based on byte values
  match (b0, b1, b2, b3) {
    (0x63, 0x6D, 0x61, 0x70) => "cmap"
    (0x67, 0x6C, 0x79, 0x66) => "glyf"
    (0x68, 0x65, 0x61, 0x64) => "head"
    (0x68, 0x68, 0x65, 0x61) => "hhea"
    (0x68, 0x6D, 0x74, 0x78) => "hmtx"
    (0x6C, 0x6F, 0x63, 0x61) => "loca"
    (0x6D, 0x61, 0x78, 0x70) => "maxp"
    (0x6E, 0x61, 0x6D, 0x65) => "name"
    (0x4F, 0x53, 0x2F, 0x32) => "OS/2"
    (0x70, 0x6F, 0x73, 0x74) => "post"
    (0x43, 0x4F, 0x4C, 0x52) => "COLR"
    (0x43, 0x50, 0x41, 0x4C) => "CPAL"
    (0x48, 0x56, 0x41, 0x52) => "HVAR"
    (0x53, 0x54, 0x41, 0x54) => "STAT"
    (0x66, 0x76, 0x61, 0x72) => "fvar"
    (0x67, 0x76, 0x61, 0x72) => "gvar"
    _ => {
      // If unrecognized, return ASCII representation of original bytes
      let mut result = ""
      let bytes = [b0, b1, b2, b3]
      for i = 0; i < 4; i = i + 1 {
        let byte = bytes[i]
        if byte >= 32 && byte <= 126 { 
          result = result + Int::unsafe_to_char(byte).to_string() 
        } else { 
          result = result + "?" 
        }
      }
      result
    }
  }
}
