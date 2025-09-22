# TTF字体解析器 - 模块化结构

## 📁 模块概览

本项目已成功重构为模块化架构，将原本的单一大文件拆分为清晰的功能模块：

```
src/
├── type/          # 数据类型定义模块
├── reader/        # 二进制读取模块  
├── parser/        # 表解析模块
├── analyzer/      # 字体分析模块
├── api/           # 高级API模块
├── test_data/     # 测试数据模块
└── cmd/           # 主程序入口
```

## 🔧 模块详情

### 1. **type模块** (`src/type/`)
- **文件**: `types.mbt`, `moon.pkg.json`
- **职责**: 定义所有核心数据结构
- **导出**:
  - `ParseResult[T]` - 解析结果枚举
  - `FontHeader` - 字体文件头
  - `TableDirectoryEntry` - 表目录项
  - `TableDirectory` - 表目录
  - `HeadTable` - head表结构
  - `MaxpTable` - maxp表结构
  - `FontInfo` - 字体基本信息
  - `FontFeatures` - 字体特性分析
- **依赖**: 无

### 2. **reader模块** (`src/reader/`)
- **文件**: `reader.mbt`, `moon.pkg.json`  
- **职责**: 提供字节流读取功能
- **导出**:
  - `ByteReader` trait - 字节读取器接口
  - `ArrayByteReader` - 数组字节读取器实现
  - `read_u32_be()`, `read_u16_be()`, `read_tag()` - 读取函数
  - `bytes_to_tag_string()` - 标签转换
- **依赖**: 无

### 3. **parser模块** (`src/parser/`)
- **文件**: `parser.mbt`, `moon.pkg.json`
- **职责**: 解析TTF表结构
- **导出**:
  - `find_table()` - 查找表
  - `parse_font_header()` - 解析字体头
  - `parse_table_directory()` - 解析表目录
  - `parse_head_table()` - 解析head表
  - `parse_maxp_table()` - 解析maxp表
- **依赖**: `type`, `reader`

### 4. **analyzer模块** (`src/analyzer/`)
- **文件**: `analyzer.mbt`, `moon.pkg.json`
- **职责**: 分析字体特性和功能
- **导出**:
  - `is_core_table_check()` - 核心表检查
  - `analyze_font_features()` - 特性分析
  - `extract_font_info()` - 提取字体信息
- **依赖**: `type`, `reader`, `parser`

### 5. **api模块** (`src/api/`)
- **文件**: `api.mbt`, `moon.pkg.json`
- **职责**: 提供简洁的高级API
- **导出**:
  - `parse_ttf_from_bytes()` - 解析TTF字体
  - `get_table_directory()` - 获取表目录
  - `get_font_header()` - 获取字体头
  - `analyze_font_features_from_bytes()` - 特性分析
  - `is_color_font()`, `is_variable_font()` - 快速检查
  - `is_valid_ttf()` - 有效性验证
  - `get_font_format()` - 格式识别
  - `get_font_usage_recommendation()` - 使用建议
  - `get_all_test_fonts()` - 测试数据
  - `get_font_description()` - 字体描述
- **依赖**: `type`, `reader`, `parser`, `analyzer`, `test_data`

### 6. **test_data模块** (`src/test_data/`)
- **文件**: `test_data.mbt`, `moon.pkg.json`
- **职责**: 提供测试字体数据
- **导出**:
  - `demo_ttf_data` - 基础字体数据
  - `colr1_ttf_data` - 彩色字体数据
  - `colr1_var_ttf_data` - 可变彩色字体数据
  - `get_all_test_fonts()` - 获取所有测试字体
  - `get_font_description()` - 获取字体描述
- **依赖**: 无

### 7. **cmd模块** (`src/cmd/`)
- **文件**: `main.mbt`, `moon.pkg.json`
- **职责**: 演示程序入口
- **导入**: `api` (作为 `lib` 别名)
- **依赖**: `api`

## 🔄 依赖关系图

```
cmd ← api ← analyzer ← parser ← reader
 ↑      ↑       ↑        ↑
 └─ api ← test_data   type ←┘
```

## ✨ 模块化优势

1. **清晰的职责分离**: 每个模块都有明确的功能边界
2. **可维护性**: 便于独立开发和测试各个模块
3. **可扩展性**: 易于添加新功能或替换特定模块
4. **重用性**: 各模块可以独立重用
5. **依赖控制**: 明确的依赖关系，避免循环依赖

## 🚀 使用方法

主要通过 `api` 模块提供的高级接口使用：

```moonbit
// 解析字体
match @lib.parse_ttf_from_bytes(font_data) {
  @lib.Success(info) => println("字体名称: " + info.name)
  @lib.Error(msg) => println("解析失败: " + msg)
}

// 检查字体特性
if @lib.is_color_font(font_data) {
  println("这是彩色字体")
}
```

## 📝 注意事项

- 所有模块都采用 `@alias` 导入方式
- 类型构造通过各模块内部的辅助函数完成
- WASM导出配置在 `api` 模块中统一管理
- 测试数据独立模块化，便于维护和扩展
