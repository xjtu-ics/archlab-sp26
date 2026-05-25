# 本地评分脚本

这些脚本用于在 handout 目录中运行本地检查。

## 执行命令

```sh
./grader/grade-archlaba.pl
./grader/grade-archlabb.pl
./grader/grade-archlabc.pl
```

脚本会自动定位相邻 `sim/` 目录中的模拟器树，也可以使用 `-s <simdir>` 显式指定该目录。

## 默认检测目标

| Part | 默认目标 | 自定义参数 |
| --- | --- | --- |
| A | `sim/misc/sum.ys`、`sim/misc/rsum.ys`、`sim/misc/copy.ys` | `-f <prefix>` 指定一组文件前缀 |
| B | `sim/seq/seq-full.hcl` | `-f <file>` 指定文件 |
| C | `sim/pipe/pipe-full.hcl`、`sim/pipe/ncopy.ys` | `-f <prefix>` 读取相应 HCL 和 YS 文件 |

Part B 与 Part C 部分脚本在 `/tmp` 下的临时目录中构建和测试，不会用生成文件覆盖学生当前的模拟器工作目录。
