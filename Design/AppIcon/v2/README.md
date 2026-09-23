# 胃形 App Icon v2

2026-09-07 的图标设计将品牌符号从抽象深蓝形状调整为胃形：短食管入口、胃底隆起、凹入的小弯、圆润大弯和向左的幽门出口。保留浅蓝背景与深蓝渐变风格。

- [图标](icon_1024.png)：1024 × 1024，不带透明通道，用于 AppIcon。
- [可编辑矢量源](stomach.svg)。
- [替换前原图](previous-icon.png)：保留，可恢复。

## 导出

在安装 Xcode 命令行工具的 macOS 上，从仓库根目录执行：

```sh
mkdir -p build
swiftc FoodJourney/Models/AnatomyArtwork.swift scripts/export-app-icon.swift -o build/export-app-icon
build/export-app-icon "$PWD"
```

脚本会更新本目录的 SVG、PNG 以及 AppIcon 中的 PNG；仅在 `previous-icon.png` 不存在时备份原图。重新导出使用当前脚本内容，不保证重现历史版本。

图标是品牌化胃形符号，不是医学解剖图。本目录不包含完整的小尺寸识别测试报告。资产文件也不能代表当前应用界面的全部视觉状态，项目进展见 [项目状态](../../../docs/project-status.md)。
