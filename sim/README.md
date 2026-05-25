# Y86-64 模拟器工具

本目录包含体系结构实验使用的学生分发版本工具。

## 工具

| 程序 | 说明 |
| --- | --- |
| `yas` | Y86-64 汇编器 |
| `yis` | Y86-64 指令级（ISA）模拟器 |
| `hcl2c` | HCL 到 C 的转换器 |
| `hcl2v` | HCL 到 Verilog 的转换器 |
| `ssim` | SEQ 模拟器 |
| `ssim+` | SEQ+ 模拟器 |
| `psim` | PIPE 模拟器 |

## 构建工具

### 界面模式

Y86-64 模拟器可配置为支持 TTY 或 GUI 界面。TTY 模式在终端中打印运行信息，适合自动化测试且无需安装图形组件。GUI 模式适合可视化和调试，但要求系统安装 Tcl/Tk。

### 配置 Makefile

如果分发版本已经由教师配置好，可直接进入构建步骤。否则，请选择 TTY 或 GUI 模式并修改本目录的 `./Makefile`。其中的设置会覆盖 `seq/` 和 `pipe/` 子目录 Makefile 中的同名值。

| 变量 | GUI 构建中的作用 |
| --- | --- |
| `GUIMODE=-DHAS_GUI` | 启用 GUI 支持代码 |
| `TKLIBS` | 指定 Tcl/Tk 库文件位置 |
| `TKINC` | 指定 Tcl/Tk 头文件位置 |

未安装 Tcl/Tk 时，请注释掉这三个变量以构建 TTY 版本。

### 执行构建

```sh
make clean; make
```

## 目录结构

### 顶层文件

| 路径 | 说明 |
| --- | --- |
| `Makefile` | 构建 Y86-64 工具 |
| `README.md` | 本文件 |

### 模拟器与测试目录

| 路径 | 说明 |
| --- | --- |
| `misc/` | `yas`、`yis`、HCL 转换工具及 ISA 校验支持文件 |
| `seq/` | SEQ 与 SEQ+ 模拟器代码及 HCL 文件 |
| `pipe/` | PIPE 模拟器代码及 HCL 文件 |
| `y86-code/` | Y86-64 示例 `.ys` 文件及基准测试脚本 |
| `ptest/` | 处理器设计的自动化回归测试脚本 |
