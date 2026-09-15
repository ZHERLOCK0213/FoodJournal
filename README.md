# 食物旅行 · FoodJourney

一款使用 SwiftUI 构建的 iOS 互动科普 App：选择食物与份量，观察食物沿消化道移动，并了解不同器官在消化、吸收与代谢中的作用。

**当前工作区（2026-09-15）**：[v10整餐关注分析](docs/meal-focus-v10.md)。报告汇总本餐全部份量并展示主要贡献来源与追加提示；饮水为独立可选背景，不推算血尿酸，也不强造四档单餐风险。保留[v9私人食物与产品收敛](docs/personal-foods-v9.md)：公共库只读，自建食物本机增改删，最近3种加完整目录，无疾病问卷。存储接口已分离，尚无账号或云同步。支持基线为iOS26.5；下文v4～v7测试数仅为历史记录，本轮未运行自动化测试。

> 开发中的教育演示项目，尚非正式发布版本。仓库名为 **FoodJournal**，Xcode 工程与 App 内部名称为 **FoodJourney**。
>
> 本项目不是医疗工具，不提供个人血糖预测、器官功能评估、诊断或治疗建议。v4 已将报告改为食物成分汇总与器官参与说明，不展示旧模型的“内脏使用度”、个人胰岛素响应或代谢产物量。

当前开发分支已完成 [v4 胰腺协作与整餐报告](docs/pancreas-education-v4.md) 与尿酸焦点的最终自动化验收：iPhone 17 Pro / iOS 26.5 共通过 39 项测试（34 项单元测试、5 项 UI 测试），0 失败、0 跳过，仍待用户体验确认。2026-09-08 新增“关注尿酸”画布入口与报告焦点，说明嘌呤、肾脏排泄及饮水边界，并为馒头数据建立来源审计；这不表示全部食物数据已核实或项目已经发布。相关清单见 [尿酸科普与馒头来源口径](docs/testing-urate-v4.md) 与 [后续工作记录](docs/continuation.md)。以下画布截图保留 v3 视觉基线；[v4 报告](Design/Anatomy/v4/previews/pork-bun-report.png)、[作用讲解](Design/Anatomy/v4/previews/pancreas-process.png)、[胰腺入口](Design/Anatomy/v4/previews/pancreas-focus.png) 与 [尿酸数据审计](docs/food-data-and-urate-audit.md) 可单独查看。

当前v5食物库保留原有12种并新增20种，共32项目录；新增14种具备可用数值来源，另6种（肉末茄子盖饭、蛋炒饭、牛肉粿条、鸡公煲、原味鸡、新疆炒米粉）仍待精确来源或做法确认，禁止数值预演。新增中文搜索、来源与参考边界、未知数据提示。2026-09-09共48项测试均有通过记录（41单元、7界面；全量46通过加修正后2项定向复测，App代码未变），已安装iPhone17Pro并检查截图。详见 [扩展检查点](docs/food-expansion-v5.md)、[来源表](docs/food-expansion-v5-sources.md) 与 [手动验收](docs/testing-food-expansion-v5.md)。这不表示20项新增食品的营养资料全部完成，也不代表已发布。

## 界面预览

当前工作区另含 [v7可选学习主题与器官小结](docs/preferences-and-organ-summary-v7.md)，已修改代码、尚未构建或运行验收。按用户约定由用户运行测试，下面v6验证记录只是历史基线。

v6 [餐食矩阵与10种上限](docs/meal-matrix-v6.md) 已验证并安装iPhone17Pro：52项均有通过记录（全量51通过，1项重播等待超时后单项复测通过；44单元＋8界面）。可查看 [合并水饺成分表](Design/Anatomy/v6/previews/dumplings-1000g-merged-matrix.png) 与 [静态胰腺说明](Design/Anatomy/v6/previews/pancreas-static-three-steps.png)。用户体验仍待确认。

<p>
  <img src="Design/Anatomy/v3/previews/installed-app.png" alt="中央消化道与左右器官气泡" width="280" />
  <img src="Design/Anatomy/v3/previews/chicken200g-callouts.png" alt="鸡胸肉 200g 预演完成后的器官说明" width="280" />
</p>

当前视觉基线：中央消化道、10 个器官气泡、横向折线连接，以及可点击聚焦的独立器官。截图来自 iPhone 17 Pro 模拟器。

## 已实现功能

- **食物与份量选择**：内置常见食物，支持50g、100g、200g、300g、500g单份预演；每餐最多合并后10种食品，已有种类可继续追加。
- **消化旅程动画**：食物沿消化道运动，逐份串行播放；聚焦器官时仍可观察下游食物轨迹。
- **器官交互**：点击器官、左右气泡或器官名称，查看对应的过程、结果与资料来源。
- **本份结果**：预演完成后在画布显示成分与典型去向，完整小结可手动打开；重播不会重复计入食物。
- **连续进食会话**：支持食物记录、删除与重置，保留消化预演、代谢报告、我三个页面。
- **本地偏好**：首次引导与关注主题保存在设备本地。
- **矩阵报告**：同一目录食品的多次加入合并为一张成分表，原始记录仍可逐次删除；报告基于矩阵合计解释营养物质，不逐菜套用规则。
- **胰腺作用讲解**：帮助消化、血糖调节两种入口，静态三步阅读；移除只轮换高亮的播放按钮，不再以器官百分比表示个人代谢能力。
- **尿酸教育焦点**：从画布和报告进入嘌呤—尿酸—肾脏排泄的定性说明；引用 MedlinePlus、国家卫健委等资料，不把食物成分换算为个人血尿酸或固定排泄量。

## 开发环境

| 项目 | 当前配置 |
| --- | --- |
| 开发工具 | Xcode 26.5 |
| 部署目标 | iOS 26.5 |
| 语言与界面 | Swift（Swift 5 语言模式）、SwiftUI、Canvas |
| 主要结构 | MVVM，Observation；部分旧页面保留 Combine 写法 |
| 测试 | XCTest 单元测试与 UI 自动化 |
| 已验证设备 | iPhone 17 Pro 模拟器，iOS 26.5 |

部署目标为iOS26.5；本轮不支持更低版本，历史文档中的iOS17不是当前承诺。模拟器运行成功不等同于全部真机、iPad和大字体验收。

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

**验证记录（2026-09-08）**：v3 基线通过 22 项测试；v4 与尿酸焦点最终在 iPhone 17 Pro / iOS 26.5 通过 39 项测试（34 项单元测试、5 项 UI 测试），0 失败、0 跳过，覆盖红烧肉＋馒头的成分累加、来源口径、尿酸教育焦点、旧容量上限诊断、两种胰腺作用和报告交互。该记录不代表生理模型经过医学验证，也不是当前仓库的持续集成状态。

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
- 肝脏产物量和肾脏排出量显示“未估算”；胰腺气泡介绍消化酶与胰岛素，详细说明明确不估算个人分泌量。
- 当前气泡说明面向**最后一份食物**，还不是整餐混合食物的动态生理模型。
- 已复现旧模型达到容量上限后数值停止增加；新报告直接汇总食物输入，不受这一上限影响。仍不能断言上限是用户原反馈的唯一原因。详细混合餐生理模拟及食物数据来源仍待完善。
- 科普内容优先参考 [NIDDK 消化系统说明](https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works) 与 [NIDDK 肾脏说明](https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work)；尿酸焦点另见 [馒头数据与尿酸科普审计](docs/food-data-and-urate-audit.md)，其中记录了 [CFS 营养资料查询系统](https://www.cfs.gov.hk/tc_chi/nutrient/) 对中国疾控中心营养与食品安全所 CFC2002Ed2 数据的出处。外部参考图片不作为项目原创素材。

## 隐私与开发方向

当前无账号系统、后端、云同步或 HealthKit 接入。现有引导包含健康关注与慢性病选项，答案通过 `UserDefaults` 存在设备本地；问卷措辞和历史报告的个人化表述仍需收敛到科普用途。

接下来先完成 v4 用户验收，再补齐食物数据来源、隐私材料、兼容性与真机体验验证。发布准备条件见 [发布门槛清单](docs/release-readiness.md)，当前未提审。

## 项目文档

- [项目驾驶舱与下一步](docs/project-dashboard.md)
- [项目书](docs/project-brief.md)
- [视觉方向](docs/visual-direction.md)
- [v3 器官与气泡实现说明](Design/Anatomy/v3/README.md)
- [设计决策](docs/design-decisions.md)
- [历史开发日志](docs/CHANGELOG.md)

历史文档可能保留早期方案，当前功能与限制以本 README、最新驾驶舱及实际代码为准。
