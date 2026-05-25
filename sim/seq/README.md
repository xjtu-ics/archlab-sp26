# SEQ 与 SEQ+ 模拟器

本目录包含用于构建 SEQ、SEQ+ 及其变体模拟器的代码。

## 构建模拟器

### 版本选择

| 可执行文件 | `VERSION` | HCL 文件 | 说明 |
| --- | --- | --- | --- |
| `ssim` | `std` | `seq-std.hcl` | SEQ 标准模拟器 |
| `ssim` | `full` | `seq-full.hcl` | 用于向 SEQ 添加 `iaddq` |
| `ssim+` | `std` | `seq+-std.hcl` | SEQ+ 标准模拟器 |

### 界面模式

| 模式 | 说明 |
| --- | --- |
| TTY | 在终端中打印运行信息，适合自动化测试且无需安装图形组件 |
| GUI | 使用图形界面，适合可视化和调试，但要求系统安装 Tcl/Tk |

Makefile 包含构建 TTY 或 GUI 版本的配置说明。TTY 构建仅支持 TTY 模式；GUI 构建可根据命令行参数在 TTY 与 GUI 模式间选择。

### 构建命令

构建指定版本：

```sh
make clean; make ssim VERSION=xxx
```

例如，基于 `seq-std.hcl` 构建 SEQ 标准版本：

```sh
make clean; make ssim VERSION=std
```

也可以在 Makefile 中设置 `VERSION` 以减少输入。

## 使用模拟器

### 调用形式

```text
Usage: ssim [-htg] [-l m] [-v n] file.yo
```

GUI 模式下必须提供 `file.yo`；TTY 模式下可省略，默认从标准输入读取。

### 命令行参数

| 参数 | 说明 |
| --- | --- |
| `-h` | 打印帮助信息 |
| `-g` | 使用 GUI 模式而不是 TTY 模式（默认 TTY） |
| `-l m` | 设置指令执行上限为 `m`，仅适用于 TTY 模式（默认 10000） |
| `-v n` | 设置详细输出级别，`0 <= n <= 2`，仅适用于 TTY 模式（默认 2） |
| `-t` | 将结果与指令级模拟器 `yis` 对比，仅适用于 TTY 模式 |

## 文件

### 构建与模拟器源代码

| 文件 | 说明 |
| --- | --- |
| `Makefile` | 构建 SEQ 与 SEQ+ 模拟器 |
| `Makefile-sim` | 学生分发版本所用 Makefile |
| `README.md` | 本文件 |
| `seq+.tcl` | SEQ+ GUI 版本使用的 Tcl 脚本 |
| `seq.tcl` | SEQ GUI 版本使用的 Tcl 脚本 |
| `ssim.c` | 顺序模拟器主体代码 |
| `sim.h` | 模拟器头文件 |

### HCL 文件

| 文件 | 说明 |
| --- | --- |
| `seq-std.hcl` | SEQ 标准控制逻辑 |
| `seq+-std.hcl` | SEQ+ 标准控制逻辑 |
| `seq-full.hcl` | `iaddq` 练习模板 |
| `seq-full-ans.hcl` | `iaddq` 参考版本（完整源目录使用） |
