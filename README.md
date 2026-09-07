# 食物旅行 · FoodJourney

一款使用 SwiftUI 构建的 iOS 互动科普 App：选择食物与份量，观察食物沿消化道移动，并了解不同器官在消化、吸收与代谢中的作用。

> 开发中的教育演示项目，尚非正式发布版本。仓库名为 **FoodJournal**，Xcode 工程与 App 内部名称为 **FoodJourney**。
>
> 本项目不是医疗工具，不提供个人血糖预测、器官功能评估、诊断或治疗建议。报告页仍包含待重构的历史示意模型，不能将其中的“内脏使用度”、胰岛素响应或代谢产物量理解为真实测量。

## 界面预览

<p>
  <img src="Design/Anatomy/v3/previews/installed-app.png" alt="中央消化道与左右器官气泡" width="280" />
  <img src="Design/Anatomy/v3/previews/chicken200g-callouts.png" alt="鸡胸肉 200g 预演完成后的器官说明" width="280" />
</p>

当前视觉基线：中央消化道、10 个器官气泡、横向折线连接，以及可点击聚焦的独立器官。截图来自 iPhone 17 Pro 模拟器。

## 已实现功能

- **食物与份量选择**：内置常见食物，支持 50g、100g、200g、300g 单份预演。
- **消化旅程动画**：食物沿消化道运动，逐份串行播放；聚焦器官时仍可观察下游食物轨迹。
- **器官交互**：点击器官、左右气泡或器官名称，查看对应的过程、结果与资料来源。
- **本份结果**：预演完成后在画布显示成分与典型去向，完整小结可手动打开；重播不会重复计入食物。
- **连续进食会话**：支持食物记录、删除与重置，保留消化预演、代谢报告、我三个页面。
- **本地偏好**：首次引导与关注主题保存在设备本地。

## 开发环境

| 项目 | 当前配置 |
| --- | --- |
| 开发工具 | Xcode 26.5 |
| 部署目标 | iOS 26.5 |
| 语言与界面 | Swift（Swift 5 语言模式）、SwiftUI、Canvas |
| 主要结构 | MVVM，Observation；部分旧页面保留 Combine 写法 |
| 测试 | XCTest 单元测试与 UI 自动化 |
| 已验证设备 | iPhone 17 Pro 模拟器，iOS 26.5 |

部署目标以 `FoodJourney.xcodeproj` 为准；部分历史文档提到 iOS 17，目前尚未完成低版本兼容验证。

## 本地运行

1. 安装 Xcode 26.5 与 iOS 26.5 Simulator Runtime。
2. 使用有仓库访问权限的 GitHub 账号克隆项目：

   ```sh
   git clone https://github.com/ZHERLOCK0213/FoodJournal.git
   cd FoodJournal
   open FoodJourney.xcodeproj
   ```

3. 在 Xcode 中选择 **FoodJourney** Scheme 和 **iPhone 17 Pro** 模拟器，按 `⌘R` 运行。
4. 如需运行到真机，在 **Signing & Capabilities** 中选择自己的开发团队，并按需调整 Bundle Identifier。

无需后端服务或 API Key。首次普通启动会显示引导问卷；UI 测试使用 `-uiTesting` 启动参数跳过引导，不读取或改写设备上已有的偏好。

## 构建与测试

在仓库根目录执行：

```sh
xcodebuild -project FoodJourney.xcodeproj -scheme FoodJourney \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

xcodebuild -project FoodJourney.xcodeproj -scheme FoodJourney \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

如果安装了多个同名模拟器，可使用 `xcrun simctl list devices available` 查找设备，并将 destination 改为 `platform=iOS Simulator,id=<设备 UUID>`。

**基线验证记录（2026-09-07）**：v3 版本在 iPhone 17 Pro 模拟器上通过 22 项测试（19 项单元测试、3 项 UI 测试）。覆盖器官点击与布局、折线连接、份量数据、预演完成、重播、聚焦切换及报告导航。该记录不代表生理模型经过医学验证，也不是当前仓库的持续集成状态。

## 目录结构

```text
FoodJourney.xcodeproj/    Xcode 工程
FoodJourney/
  Models/                食物、器官素材、气泡布局与本份科普结果
  ViewModels/            会话状态与动画推进
  Views/                 消化预演、报告、引导与设置等界面
  Services/              食物数据库、动画与历史代谢引擎
  Assets.xcassets/        App 图标与资源
  Resources/             主题
FoodJourneyTests/        单元测试
FoodJourneyUITests/      UI 自动化
Design/                  版本化矢量素材、PNG 与截图
docs/                    产品、设计决策与研究记录
scripts/                 器官与图标素材导出脚本
```

## 内容与数据边界

- 新画布中的食物、蛋白质、脂肪等克数来自内置食物数据与所选份量，**不等于实际消化、吸收或分泌量**。
- 肝脏产物量、胰腺分泌量和肾脏排出量目前明确显示“未估算”。
- 当前气泡说明面向**最后一份食物**，还不是整餐混合食物的动态生理模型。
- 胰腺内分泌作用、整餐协作过程、旧报告指标及食物数据来源仍待完善；已收到“红烧肉＋馒头后胰腺数值未变化”的反馈，原因尚待复现定位。
- 科普内容优先参考 [NIDDK 消化系统说明](https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works) 与 [NIDDK 肾脏说明](https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work)。外部参考图片不作为项目原创素材。

## 隐私与开发方向

当前无账号系统、后端、云同步或 HealthKit 接入。现有引导包含健康关注与慢性病选项，答案通过 `UserDefaults` 存在设备本地；问卷措辞和历史报告的个人化表述仍需收敛到科普用途。

接下来优先完善器官协作与胰腺作用展示、核查报告数值，并逐步补齐食物数据来源、小屏幕适配、无障碍与真机体验验证。

## 项目文档

- [项目驾驶舱与下一步](docs/project-dashboard.md)
- [项目书](docs/project-brief.md)
- [视觉方向](docs/visual-direction.md)
- [v3 器官与气泡实现说明](Design/Anatomy/v3/README.md)
- [设计决策](docs/design-decisions.md)
- [历史开发日志](docs/CHANGELOG.md)

历史文档可能保留早期方案，当前功能与限制以本 README、最新驾驶舱及实际代码为准。
