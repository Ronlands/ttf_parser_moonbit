# 如何在 main.mbt 中读取真实 TTF 文件

## 🎯 完全可行！reader 模块已经准备就绪

你的 `@reader/` 模块完全可以处理文件数据！它只需要一个 `Array[Int]` 格式的字节数组。

## 📋 具体实现步骤

### 1. **获取文件字节数据**

你需要将 TTF 文件转换为 `Array[Int]` 格式。可以通过以下方式：

#### 方式A：使用 MoonBit 文件系统包
```moonbit
// 在 moon.mod.json 中添加依赖
{
  "deps": {
    "moonbitlang/x": "*"
  }
}

// 在代码中使用
fn read_ttf_file(path: String) -> Result[Array[Int], String] {
  try {
    let content = @fs.read_file_to_bytes(path)
    let mut result = []
    for i = 0; i < content.length(); i = i + 1 {
      result = result + [content[i].to_int()]
    }
    Ok(result)
  } catch {
    err => Err("读取失败: " + err.to_string())
  }
}
```

#### 方式B：使用平台特定的文件API
```moonbit
// 使用 JavaScript FFI (在浏览器或 Node.js 中)
external fn read_file_js(String) -> Array[Int] = "read_file"

// 使用原生 FFI
external fn read_file_native(String) -> Array[Int] = "read_file"
```

### 2. **使用 reader 模块处理数据**

一旦你有了 `Array[Int]` 格式的数据，就可以直接使用：

```moonbit
fn process_ttf_file(file_path: String) -> Unit {
  match read_ttf_file(file_path) {
    Ok(data) => {
      // 方法1：直接使用 API
      match @lib.parse_ttf_from_bytes(data) {
        @types.Success(info) => {
          println("字体名称: " + info.name)
          println("字体族: " + info.family)
          // ... 其他信息
        }
        @types.Error(msg) => println("解析失败: " + msg)
      }
      
      // 方法2：直接使用 reader 模块
      let reader = @reader.ArrayByteReader::new(data)
      match @reader.read_u32_be(reader) {
        Some(version) => println("TTF版本: 0x" + version.to_string())
        None => println("无法读取版本")
      }
    }
    Err(msg) => println("文件读取失败: " + msg)
  }
}
```

### 3. **完整示例**

```moonbit
fn main {
  // 读取你的字体文件
  let font_files = [
    "src/fonts/demo.ttf",
    "src/fonts/colr_1.ttf", 
    "src/fonts/colr_1_variable.ttf"
  ]
  
  for i = 0; i < font_files.length(); i = i + 1 {
    process_ttf_file(font_files[i])
  }
}
```

## 🔧 当前演示代码已展示

在当前的 `main.mbt` 中，你可以看到：

1. **Reader 模块演示** - 展示了 `@reader.ArrayByteReader` 的直接使用
2. **完整的处理流程** - 从数据到解析结果的完整过程
3. **错误处理** - 规范的错误处理方式

## ✅ 总结

- ✅ **reader 模块完全可用** - 只需要 `Array[Int]` 数据
- ✅ **解析器功能完整** - 支持所有 TTF 特性检测
- ✅ **模块化架构清晰** - 每个模块都有明确职责
- ⚠️ **唯一缺少的** - 将文件转换为 `Array[Int]` 的具体实现

你的架构设计是完全正确的！只需要添加文件读取的具体实现就可以处理真实的 TTF 文件了。
