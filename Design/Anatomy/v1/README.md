# FoodJourney 独立器官素材 v1

2026-09-07。成年人体比例、朝右张口，器官采用圆润简化形状。不是儿童角色。

打开 `index.html` 查看全部素材；`assembled.png` / `assembled.svg` 是拼接预览。

## 文件与坐标

人体底图与 10 个器官图层分别提供 SVG 和透明 PNG：口腔、食管、胃、十二指肠、肝脏、胆囊、胰腺、双肾、小肠、大肠。双肾作为一个选择组。

所有 SVG 使用 `viewBox="0 0 320 440"`，PNG 为 640 × 880。保留透明空白是为了按相同原点叠加，不需手工猜位置。图层顺序与 `AnatomyArtwork.assets` 一致，肾脏在后层；选中时上层器官淡出，肾脏完整显现。

## 来源与编辑

原创矢量源：`FoodJourney/Models/AnatomyArtwork.swift`。App 使用同一组矢量路径实时渲染，PNG/SVG 是可交付导出，避免位图位置与动画不一致。SVG 基础填色、PNG 渐变预览与 App 的阴影高光可能略有不同，几何形状保持一致。

修改矢量源后重新导出：

```sh
swiftc FoodJourney/Models/AnatomyArtwork.swift scripts/export-anatomy.swift -o /private/tmp/foodjourney-export-anatomy
/private/tmp/foodjourney-export-anatomy "$PWD/Design/Anatomy/v1"
```

本版本命名可重复导出；需要保留历史时使用新的版本目录。

## 点击聚焦

- 直接触摸器官实际形状，或使用横向器官按钮选择。
- 选中器官保持 100% 图层不透明度，其余器官与消化道降为 13%。
- 选中图层出现轮廓、高光活动点和折线名称提示，下方显示“过程 / 结果”。
- 再次点击同一器官、点击空白处、点击“查看全貌”均退出。
- 选择器官不清空当前餐食，不重启进食动画。
- “减弱动态效果”关闭聚焦过渡与循环活动点。

说明卡提供通用生理过程与结果，未把未校准的个体排泄量作为事实展示。原餐食会话及报告计算仍沿用原逻辑。新版画布用聚焦说明卡替代旧的累积泡泡与残留标签；本轮未校准旧报告计算。

## 验证记录

2026-09-07，iPhone 16 / iOS 26.5：8 项单元测试通过；米饭预演至报告 UI 测试通过；器官聚焦测试经修正屏幕外按钮的滚动操作后通过。覆盖胃→肾切换、直接点击小肠和肝脏、再次点击退出、空白退出、“查看全貌”退出。最终说明卡关闭文字过渡后构建通过，并重新启动截图检查。

截图位于 `previews/`：`assembled-app.png`、`stomach-focus.png`、`kidneys-focus.png`。尚未覆盖其他屏幕尺寸的视觉验收。

## 科普资料

查阅日期：2026-09-07。

- [NIDDK 消化系统](https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works)：主消化道、肝胆胰功能、消化和吸收。
- [NIDDK 肾脏](https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work)：位置、过滤血液、水与电解质调节、尿液排出。

器官轮廓和肠道折数是交互科普简化；不是医学图谱。活动点用于提示器官正在参与过程，不代表每一种物质的真实运输轨迹。
