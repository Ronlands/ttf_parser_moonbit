# TTF Font Parser - MoonBit Implementation

A TrueType font file parser written in MoonBit language that supports parsing TTF file structures and key data. Features modular architecture design with integrated file system support.

## Project Structure

```
ttf_parser_moonbit/
├── src/
│   ├── cmd/                  # Main program entry
│   │   ├── main.mbt         # Demo program
│   │   └── moon.pkg.json    # Package configuration
│   ├── api/                 # Unified API interface
│   ├── type/                # Data type definitions
│   ├── reader/              # Binary data reading
│   ├── parser/              # Table parser
│   ├── analyzer/            # Font feature analysis
│   ├── test_data/           # Test data
│   └── fonts/               # Test font files
├── moon.mod.json            # Project configuration
└── README.md                # Project documentation
```

## Core Data Structures

### FontHeader
Font file header containing basic information like version number and table count.

```moonbit
pub struct FontHeader {
  version : Int          // Font version number
  num_tables : Int      // Number of font tables
  search_range : Int    // Search range
  entry_selector : Int  // Entry selector
  range_shift : Int     // Range shift
}
```

### TableDirectoryEntry
Font table directory entry describing the position and size of each table.

```moonbit
pub struct TableDirectoryEntry {
  tag : String      // Table tag (4-byte identifier)
  checksum : Int    // Checksum
  offset : Int      // Table offset in file
  length : Int      // Table length
}
```

### FontInfo
Basic font information including name, character count, etc.

```moonbit
pub struct FontInfo {
  name : String        // Font name
  family : String      // Font family name
  style : String       // Font style
  version : String     // Font version
  num_glyphs : Int     // Number of characters
  units_per_em : Int   // Units per EM
}
```

## Modular Architecture

### Core Modules

- **type**: Data type definitions
  - `FontHeader` - Font file header
  - `TableDirectoryEntry` - Table directory entry
  - `FontInfo` - Basic font information
  - `ParseResult[T]` - Parse result enumeration

- **reader**: Binary data reading
  - `ArrayByteReader` - Byte array reader
  - Support big-endian/little-endian reading
  - Provide position control and boundary checking

- **parser**: Table parser
  - Parse various TTF table types
  - Support cmap, glyf, head, maxp, name tables

- **analyzer**: Font feature analysis
  - Detect color font support
  - Detect variable font support
  - Analyze OpenType features

- **api**: Unified interface
  - Provide high-level API functions
  - Integrate all module functionality
  - Simplify usage workflow

## API Interface

### Main Functions

- `@lib.parse_ttf_from_bytes(data: Array[Int]) -> ParseResult[FontInfo]`
  - Parse basic font information

- `@lib.get_font_header(data: Array[Int]) -> ParseResult[FontHeader]`
  - Parse font file header

- `@lib.get_table_directory(data: Array[Int]) -> ParseResult[TableDirectory]`
  - Parse font table directory

- `@lib.analyze_font_features_from_bytes(data: Array[Int]) -> ParseResult[FontFeatures]`
  - Analyze font features

- `@lib.is_valid_ttf(data: Array[Int]) -> Bool`
  - Validate TTF file validity

### File System Support

- `@fs.read_file_to_bytes(path: String) -> Bytes raise IOError`
  - Read file as byte array

- `@fs.read_file_to_string(path: String, encoding?: String) -> String raise IOError`
  - Read file as string

- `@fs.path_exists(path: String) -> Bool`
  - Check if file exists

### Error Handling

Use `ParseResult[T]` enumeration for error handling:

```moonbit
pub enum ParseResult[T] {
  Success(T)
  Error(String)
}
```

## Usage Examples

### Basic Usage

```moonbit
// Use test data
let test_fonts = @lib.get_all_test_fonts()
let (name, data) = test_fonts[0]

// Parse font information
match @lib.parse_ttf_from_bytes(data) {
  @types.Success(font_info) => {
    println("Font name: " + font_info.name)
    println("Character count: " + font_info.num_glyphs.to_string())
  }
  @types.Error(msg) => {
    println("Parse failed: " + msg)
  }
}
```

### File Reading Example

```moonbit
// Read real font file
fn read_font_file(file_path : String) -> Result[Array[Int], String] {
  try {
    let content = @fs.read_file_to_bytes(file_path)
    let mut result = []
    
    // Convert Bytes to Array[Int]
    for i = 0; i < content.length(); i = i + 1 {
      result = result + [content[i].to_int()]
    }
    
    Ok(result)
  } catch {
    err => Err("File read failed: " + err.to_string())
  }
}

// Use file data
match read_font_file("fonts/demo.ttf") {
  Ok(data) => {
    // Parse font
    match @lib.parse_ttf_from_bytes(data) {
      @types.Success(info) => println("Parse successful: " + info.name)
      @types.Error(msg) => println("Parse failed: " + msg)
    }
  }
  Err(msg) => println("File read failed: " + msg)
}
```

### Font Feature Analysis

```moonbit
// Analyze font features
match @lib.analyze_font_features_from_bytes(data) {
  @types.Success(features) => {
    if features.has_color {
      println("Supports color fonts")
    }
    if features.has_variable {
      println("Supports variable fonts")
    }
    println("Core table count: " + features.core_table_count.to_string())
  }
  @types.Error(msg) => println("Feature analysis failed: " + msg)
}
```

## Running Tests

```bash
# Check code
moon check

# Run demo program
moon run src/cmd/main

# Build project
moon build
```

## Demo Program Output

The program will attempt to read real font files, falling back to test data if it fails:

```
Attempting to read real font files (using @fs.read_file_to_bytes)...
=== Analyzing font file: demo.ttf ===
Data size: 1234 bytes
Description: Test font file
✓ Font format: TTF
✓ Font header parsing successful!
  Version: 0x10000
  Table count: 10
  Search range: 128
  Entry selector: 3
  Range shift: 16
✓ Table directory parsing successful!
  Found 10 tables:
    1. cmap - Offset: 32, Length: 1024 (1KB)
    2. glyf - Offset: 1056, Length: 2048 (2KB)
    ...
✓ Font feature analysis:
    Table count: 10
    Core tables: 5/5
    ✓ Supports color fonts
    ✓ Supports variable fonts
    Recommended use: Modern web fonts
✓ Font information parsing successful!
  Font name: Demo Font
  Font family: Demo
  Font style: Regular
  Character count: 256
  Units per EM: 1000
  16px font size basic metrics:
    Ascender: 12px
    Descender: -4px
    Line height: 16px
```

## Supported Font Table Types

- **cmap**: Character mapping table
- **glyf**: Glyph data table
- **head**: Font header table
- **maxp**: Maximum profile table
- **name**: Font name table
- **COLR**: Color font table
- **fvar**: Variable font table

## Technical Implementation

- Use big-endian byte order for data reading
- Support 16-bit and 32-bit integer parsing
- Implemented basic TTF file format validation
- Provided comprehensive error handling mechanism
- Integrated MoonBit official file system library
- Support real file reading and test data fallback
- Modular architecture design for easy extension

## Dependencies

- `moonbitlang/x/fs`: File system support
- `moonbitlang/x/json5`: JSON5 parsing (optional)

## Feature Support

- ✅ Basic TTF file parsing
- ✅ Color font (COLR) support
- ✅ Variable font support
- ✅ OpenType feature detection
- ✅ File system integration
- ✅ Error handling and fallback options
- ✅ Modular architecture

## Future Improvements

- [ ] Improve font name table parsing
- [ ] Support more font table types
- [ ] Add glyph outline data parsing
- [ ] Support WOFF/WOFF2 formats
- [ ] Add more test cases
- [ ] Performance optimization

## License

Apache-2.0

## Contributing

Issues and Pull Requests are welcome to improve this project!