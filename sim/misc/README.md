# 杂项工具与指令级模拟器

本目录包含汇编器、指令级模拟器和 HCL 转换器的源文件。

## 工具

| 程序 | 说明 |
| --- | --- |
| `yas` | Y86-64 汇编器 |
| `yis` | Y86-64 指令级模拟器 |
| `hcl2c` | HCL 到 C 的转换器 |
| `hcl2v` | HCL 到 Verilog 的转换器 |

## 构建

```sh
make clean
make
```

## 文件

### 构建与示例

| 文件 | 说明 |
| --- | --- |
| `Makefile` | 构建 `yas`、`yis`、`hcl2c` 与 `hcl2v` |
| `Makefile-sim` | 学生分发版本使用的 Makefile |
| `README.md` | 本文件 |
| `examples.c` | A 部分三个 Y86-64 函数的 C 语言版本 |
| `ans-copy.ys` | `copy` 函数参考版本（完整源目录使用） |
| `ans-sum.ys` | `sum` 函数参考版本（完整源目录使用） |
| `ans-rsum.ys` | `rsum` 函数参考版本（完整源目录使用） |

### ISA 与汇编器

| 文件 | 说明 |
| --- | --- |
| `isa.c`、`isa.h` | 各模拟器共用的指令级模拟代码 |
| `yas` | YAS 可执行文件 |
| `yas.c`、`yas.h` | 汇编器源文件与头文件 |
| `yas-grammar.lex` | Y86-64 词法扫描器定义 |
| `yas-grammar.c` | 由词法定义生成的扫描器代码 |
| `yis`、`yis.c` | YIS 可执行文件与源文件 |

### HCL 转换器

| 文件 | 说明 |
| --- | --- |
| `hcl2c` | HCL2C 可执行文件 |
| `node.c`、`node.h` | 辅助例程及头文件 |
| `hcl.lex`、`lex.yy.c` | HCL 词法定义及生成代码 |
| `hcl.y`、`hcl.tab.c`、`hcl.tab.h` | HCL 语法定义、解析器代码及记号定义 |

### HCL 示例

| 文件 | 说明 |
| --- | --- |
| `frag.{hcl,c}` | HCL 示例程序 |
| `mux4.{hcl,c}` | HCL 示例程序 |
| `reg-file.{hcl,c}` | HCL 示例程序 |
