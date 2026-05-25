# Y86-64 示例程序

本目录包含扩展名为 `.ys` 的 Y86-64 汇编程序示例。

## 汇编单个程序

给定汇编文件 `file.ys`，执行：

```sh
make file.yo
```

该命令生成目标代码格式的文件。

## 运行模拟器测试

首先在 `pipe/` 目录构建 `psim`，并在 `seq/` 目录构建 `ssim` 与 `ssim+`。随后运行对应测试：

### PIPE

```sh
make testpsim
```

### SEQ 与 SEQ+

```sh
make testssim
make testssim+
```

这些命令会汇编并运行多个程序。测试过程中会打印较多信息；对每个通过的程序，应看到 `ISA Check Succeeds` 消息。
