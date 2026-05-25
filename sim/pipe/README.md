# PIPE 模拟器

本目录包含用于构建 PIPE 及其变体模拟器的代码。

## 构建模拟器

### 版本选择

处理不同练习时，可让 PIPE 模拟器使用不同的 HCL 文件进行构建。

| 可执行文件 | `VERSION` | HCL 文件 | 说明 |
| --- | --- | --- | --- |
| `psim` | `std` | `pipe-std.hcl` | 标准模拟器（默认） |
| `psim` | `broken` | `pipe-broken.hcl` | 不处理任何冒险 |
| `psim` | `full` | `pipe-full.hcl` | 用于添加 `iaddq` |
| `psim` | `nobypass` | `pipe-nobypass.hcl` | 用于实现无旁路 PIPE |
| `psim` | `lf` | `pipe-lf.hcl` | 用于实现 load forwarding |
| `psim` | `nt` | `pipe-nt.hcl` | 用于实现 NT 分支预测 |
| `psim` | `btfnt` | `pipe-btfnt.hcl` | 用于实现 BTFNT 分支预测 |
| `psim` | `1w` | `pipe-1w.hcl` | 用于实现单写端口 |
| `psim` | `super` | `pipe-super.hcl` | 已实现 `iaddq` 与 load forwarding |

### 界面模式

Makefile 可配置为构建支持 GUI 和/或 TTY 界面的模拟器。TTY 模式适合自动化测试且不依赖图形组件；GUI 模式适合可视化和调试，但要求系统安装 Tcl/Tk。

### 构建命令

构建指定版本：

```sh
make clean; make psim VERSION=xxx
```

也可直接在 Makefile 中设置 `VERSION`。例如修改 `pipe-full.hcl` 时，可设置 `VERSION=full` 后执行：

```sh
make clean; make psim
```

## 使用模拟器

### 调用形式

```text
Usage: psim [-htg] [-l m] [-v n] file.yo
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
| `Makefile` | 构建模拟器 |
| `Makefile-sim` | 学生分发版本所用 Makefile |
| `README.md` | 本文件 |
| `psim.c` | 模拟器主体代码 |
| `sim.h`、`pipeline.h`、`stages.h` | PIPE 头文件 |
| `pipe.tcl` | PIPE GUI 版本使用的 Tcl 脚本 |

### 性能优化与测试脚本

| 文件 | 说明 |
| --- | --- |
| `ncopy.ys` | 学生优化的 `ncopy` 默认版本 |
| `ncopy.c` | 定义 `ncopy` 语义的 C 语言版本 |
| `sdriver.ys` | 在短数组（4 个元素）上调用 `ncopy.ys` 的驱动程序 |
| `ldriver.ys` | 在较长数组（63 个元素）上调用 `ncopy.ys` 的驱动程序 |
| `gen-driver.pl` | 为任意 `ncopy` 实现生成驱动程序 |
| `benchmark.pl` | 在长度 1 至 64 的数组上运行 `ncopy` 并计算 CPE |
| `correctness.pl` | 在多个数组长度上检查 `ncopy` 正确性 |
| `check-len.pl` | 确定 `.yo` 中 `ncopy` 函数所占的字节数 |
| `gen-ncopy.pl` | 生成不同优化策略基准程序版本的参考脚本（完整源目录使用） |

执行 `make drivers` 可生成 `sdriver.ys` 与 `ldriver.ys`。

### HCL 模板

| 文件 | 说明 |
| --- | --- |
| `pipe-std.hcl` | 标准 PIPE 处理器 |
| `pipe-broken.hcl` | 不检测或处理冒险的模拟器 |
| `pipe-nobypass.hcl` | 无旁路 PIPE 模板 |
| `pipe-full.hcl` | 向 PIPE 添加 `iaddq` 的模板 |
| `pipe-nt.hcl` | 不跳转预测策略模板 |
| `pipe-btfnt.hcl` | 后向跳转、前向不跳转预测策略模板 |
| `pipe-lf.hcl` | Load forwarding 模板 |
| `pipe-1w.hcl` | 单端口寄存器文件模板 |

### HCL 参考版本

| 文件 | 说明 |
| --- | --- |
| `pipe-nobypass-ans.hcl` | 无旁路 PIPE 参考版本 |
| `pipe-full-ans.hcl` | `iaddq` 参考版本 |
| `pipe-nt-ans.hcl` | 不跳转预测参考版本 |
| `pipe-btfnt-ans.hcl` | BTFNT 分支预测参考版本 |
| `pipe-lf-ans.hcl` | Load forwarding 参考版本 |
| `pipe-1w-ans.hcl` | 单写端口参考版本 |
| `pipe-super.hcl` | 性能较高的组合优化版本 |
