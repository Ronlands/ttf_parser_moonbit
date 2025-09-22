/// TTF 字体解析器 - 二进制读取模块
/// 提供字节流读取功能

// ==================== 二进制读取模块 ====================

/// 字节流读取器接口
pub trait ByteReader {
  /// 读取一个字节
  read_byte(Self) -> Option[Int]
  /// 获取当前位置
  position(Self) -> Int
  /// 设置位置
  seek(Self, Int) -> Unit
  /// 获取总长度
  length(Self) -> Int
}

/// 数组字节读取器实现
pub struct ArrayByteReader {
  data : Array[Int]
  mut pos : Int
} derive(Show)

/// 创建数组字节读取器
pub fn ArrayByteReader::new(data : Array[Int]) -> ArrayByteReader {
  { data: data, pos: 0 }
}

/// 为 ArrayByteReader 实现 ByteReader trait
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

/// 从字节读取器中读取大端序 32 位整数
pub fn[R : ByteReader] read_u32_be(reader : R) -> Option[Int] {
  match (reader.read_byte(), reader.read_byte(), reader.read_byte(), reader.read_byte()) {
    (Some(b0), Some(b1), Some(b2), Some(b3)) => {
      Some((b0 << 24) | (b1 << 16) | (b2 << 8) | b3)
    }
    _ => None
  }
}

/// 从字节读取器中读取大端序 16 位整数
pub fn[R : ByteReader] read_u16_be(reader : R) -> Option[Int] {
  match (reader.read_byte(), reader.read_byte()) {
    (Some(b0), Some(b1)) => {
      Some((b0 << 8) | b1)
    }
    _ => None
  }
}

/// 从字节读取器中读取 4 字符标签
pub fn[R : ByteReader] read_tag(reader : R) -> Option[String] {
  match (reader.read_byte(), reader.read_byte(), reader.read_byte(), reader.read_byte()) {
    (Some(b0), Some(b1), Some(b2), Some(b3)) => {
      Some(bytes_to_tag_string(b0, b1, b2, b3))
    }
    _ => None
  }
}

/// 将字节转换为标签字符串
pub fn bytes_to_tag_string(b0 : Int, b1 : Int, b2 : Int, b3 : Int) -> String {
  // 根据字节值返回对应的标签字符串
  if b0 == 0x63 && b1 == 0x6D && b2 == 0x61 && b3 == 0x70 {
    "cmap"
  } else if b0 == 0x67 && b1 == 0x6C && b2 == 0x79 && b3 == 0x66 {
    "glyf"
  } else if b0 == 0x68 && b1 == 0x65 && b2 == 0x61 && b3 == 0x64 {
    "head"
  } else if b0 == 0x68 && b1 == 0x68 && b2 == 0x65 && b3 == 0x61 {
    "hhea"
  } else if b0 == 0x68 && b1 == 0x6D && b2 == 0x74 && b3 == 0x78 {
    "hmtx"
  } else if b0 == 0x6C && b1 == 0x6F && b2 == 0x63 && b3 == 0x61 {
    "loca"
  } else if b0 == 0x6D && b1 == 0x61 && b2 == 0x78 && b3 == 0x70 {
    "maxp"
  } else if b0 == 0x6E && b1 == 0x61 && b2 == 0x6D && b3 == 0x65 {
    "name"
  } else if b0 == 0x4F && b1 == 0x53 && b2 == 0x2F && b3 == 0x32 {
    "OS/2"
  } else if b0 == 0x70 && b1 == 0x6F && b2 == 0x73 && b3 == 0x74 {
    "post"
  } else if b0 == 0x43 && b1 == 0x4F && b2 == 0x4C && b3 == 0x52 {
    "COLR"
  } else if b0 == 0x43 && b1 == 0x50 && b2 == 0x41 && b3 == 0x4C {
    "CPAL"
  } else if b0 == 0x48 && b1 == 0x56 && b2 == 0x41 && b3 == 0x52 {
    "HVAR"
  } else if b0 == 0x53 && b1 == 0x54 && b2 == 0x41 && b3 == 0x54 {
    "STAT"
  } else if b0 == 0x66 && b1 == 0x76 && b2 == 0x61 && b3 == 0x72 {
    "fvar"
  } else if b0 == 0x67 && b1 == 0x76 && b2 == 0x61 && b3 == 0x72 {
    "gvar"
  } else {
    // 如果无法识别，返回原始字节的ASCII表示
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
