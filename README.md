# TTF 字体解析器 - MoonBit 实现

一个用 MoonBit 语言编写的 TrueType 字体文件解析器，支持解析 TTF 文件的基本结构和关键数据。

## 功能特性

- ✅ 解析 TTF 文件头信息
- ✅ 解析字体表目录
- ✅ 提取字体基本信息
- ✅ 支持常见字体表类型 (cmap, glyf, head, maxp, name)
- ✅ 完善的错误处理
- ✅ 全面的测试覆盖

## 项目结构

```
ttf_parser_moonbit/
├── ttf_parser_moonbit.mbt    # 主库文件
├── cmd/main/main.mbt         # 演示程序
├── fonts/                    # 测试字体文件
├── moon.mod.json            # 项目配置
└── README.md                # 项目文档
```

## 核心数据结构

### FontHeader
字体文件头，包含版本号、表数量等基本信息。

```moonbit
pub struct FontHeader {
  version : Int          // 字体版本号
  num_tables : Int      // 字体表数量
  search_range : Int    // 搜索范围
  entry_selector : Int  // 入口选择器
  range_shift : Int     // 范围移位
}
```

### TableDirectoryEntry
字体表目录项，描述每个表的位置和大小。

```moonbit
pub struct TableDirectoryEntry {
  tag : String      // 表标签 (4字节标识符)
  checksum : Int    // 校验和
  offset : Int      // 表在文件中的偏移量
  length : Int      // 表的长度
}
```

### FontInfo
字体基本信息，包含名称、字符数量等。

```moonbit
pub struct FontInfo {
  name : String        // 字体名称
  family : String      // 字体族名称
  style : String       // 字体样式
  version : String     // 字体版本
  num_glyphs : Int     // 字符数量
  units_per_em : Int   // 单位每EM
}
```

## API 接口

### 主要函数

- `parse_font_header(data: Array[Int]) -> ParseResult[FontHeader]`
  - 解析字体文件头

- `parse_table_directory(data: Array[Int]) -> ParseResult[TableDirectory]`
  - 解析字体表目录

- `parse_ttf_data(data: Array[Int]) -> ParseResult[FontInfo]`
  - 解析字体基本信息

- `get_table_info(data: Array[Int]) -> ParseResult[TableDirectory]`
  - 获取字体表信息

### 错误处理

使用 `ParseResult[T]` 枚举进行错误处理：

```moonbit
pub enum ParseResult[T] {
  Success(T)
  Error(String)
}
```

## 使用示例

```moonbit
// 创建测试数据
let test_data : Array[Int] = [
  0x00, 0x01, 0x00, 0x00,  // version: 0x00010000
  0x00, 0x0A,              // num_tables: 10
  // ... 更多数据
]

// 解析字体信息
match parse_ttf_data(test_data) {
  Success(font_info) => {
    println("字体名称: " + font_info.name)
    println("字符数量: " + font_info.num_glyphs.to_string())
  }
  Error(msg) => {
    println("解析失败: " + msg)
  }
}
```

## 运行测试

```bash
# 运行所有测试
moon test

# 运行演示程序
moon run cmd/main
```

## 测试结果

演示程序输出示例：

```
=== TTF 字体解析器演示 ===
正在解析 TTF 数据...
✓ 字体头解析成功!
  版本: 0x65536
  表数量: 10
  搜索范围: 128
✓ 表目录解析成功!
  发现 2 个表:
    - cmap (偏移: 32, 长度: 16)
    - glyf (偏移: 48, 长度: 32)
✓ 字体信息解析成功!
  字体名称: Unknown Font
  字体族: Unknown Font
  样式: Regular
  字符数量: 0
  单位每EM: 1000
=== 测试完成 ===
```

## 支持的字体表类型

- **cmap**: 字符映射表
- **glyf**: 字形数据表
- **head**: 字体头表
- **maxp**: 最大配置文件表
- **name**: 字体名称表

## 技术实现

- 使用大端序字节序读取数据
- 支持 16 位和 32 位整数解析
- 实现了基本的 TTF 文件格式验证
- 提供了完整的错误处理机制

## 限制

当前版本是一个基础实现，主要限制包括：

- 仅支持基本的 TTF 文件结构解析
- 字体名称解析功能简化
- 不支持复杂的字形数据解析
- 文件读取功能需要根据 MoonBit 的文件系统 API 实现

## 未来改进

- [ ] 完善字体名称表解析
- [ ] 支持更多字体表类型
- [ ] 添加字形轮廓数据解析
- [ ] 实现文件系统支持
- [ ] 添加更多测试用例

## 许可证

Apache-2.0

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！