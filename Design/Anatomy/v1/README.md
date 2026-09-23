# FoodJourney 独立器官素材 v1

2026-09-07 的历史设计版本。成年人体比例、朝右张口，器官采用圆润简化形状。不是儿童角色。本目录资产与截图保留该阶段设计，不代表当前应用界面；最新状态见 [项目状态](../../../docs/project-status.md)。

打开 `index.html` 查看全部素材；`assembled.png` / `assembled.svg` 是拼接预览。

## 文件与坐标

人体底图与 10 个器官图层分别提供 SVG 和透明 PNG：口腔、食管、胃、十二指肠、肝脏、胆囊、胰腺、双肾、小肠、大肠。双肾作为一个选择组。

所有 SVG 使用 `viewBox="0 0 320 440"`，PNG 为 640 × 880。保留透明空白是为了按相同原点叠加，不需手工猜位置。图层顺序与 `AnatomyArtwork.assets` 一致，肾脏在后层；选中时上层器官淡出，肾脏完整显现。

## 来源与编辑

矢量源：`FoodJourney/Models/AnatomyArtwork.swift`。该阶段 App 与导出使用同一组矢量路径。SVG 基础填色、PNG 渐变预览与 App 的阴影高光可能略有不同。源代码后续已有演进，本目录保存的历史资产不保证与最新源码相同。

在安装 Xcode 命令行工具的 macOS 上，从仓库根目录导出当前源码到独立目录：

```sh
mkdir -p build
swiftc FoodJourney/Models/AnatomyArtwork.swift scripts/export-anatomy.swift -o build/export-anatomy
build/export-anatomy "$PWD/Design/Anatomy/generated"
```

该命令导出当前源码，不重建 v1 历史快照；输出目录使用独立名称以保留版本资产。

## 该阶段点击聚焦设计

- 直接触摸器官实际形状，或使用横向器官按钮选择。
- 选中器官保持 100% 图层不透明度，其余器官与消化道降为 13%。
- 选中图层出现轮廓、高光活动点和折线名称提示，下方显示“过程 / 结果”。
- 再次点击同一器官、点击空白处、点击“查看全貌”均退出。
- 选择器官不清空当前餐食，不重启进食动画。
- “减弱动态效果”关闭聚焦过渡与循环活动点。

说明卡提供通用生理过程与结果，未把未校准的个体排泄量作为事实展示。该阶段餐食会话及报告计算仍沿用旧逻辑，画布先以聚焦说明卡替代累积泡泡与残留标签；当时未校准旧报告计算。后续变化见 [开发历史](../../../docs/development-history.md)。

## 验证记录

历史记录（2026-09-07，iPhone 16 / iOS 26.5 模拟器）：8 项单元测试通过；米饭预演至报告 UI 测试通过；器官聚焦测试经修正屏幕外按钮的滚动操作后通过。覆盖胃→肾切换、直接点击小肠和肝脏、再次点击退出、空白退出、“查看全貌”退出。说明卡关闭文字过渡后构建通过，并进行了截图检查。这些结果仅适用于当时版本，本次文档整理未重新执行测试。

历史截图位于 `previews/`：`assembled-app.png`、`stomach-focus.png`、`kidneys-focus.png`。该记录未覆盖其他屏幕尺寸的视觉验收，不是当前版本截图。

## 科普资料

查阅日期：2026-09-07。

- [NIDDK 消化系统](https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works)：主消化道、肝胆胰功能、消化和吸收。
- [NIDDK 肾脏](https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work)：位置、过滤血液、水与电解质调节、尿液排出。

器官轮廓和肠道折数是交互科普简化；不是医学图谱。活动点用于提示器官正在参与过程，不代表每一种物质的真实运输轨迹。
