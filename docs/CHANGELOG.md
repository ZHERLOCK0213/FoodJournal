# FoodJourney 开发日志

> 按时间倒序。每轮记录改动内容，设计决策理由见 `design-decisions.md`。

## 2026-08-12 · 代谢模型重构 (`72a2f3d`)

**问题**：4 处代谢模型事实错误（详见 `metabolism-research.md`），最严重是尿酸按蛋白算且挂在肾「产生」——得出鸡胸肉产尿酸高于三文鱼，与生理事实相反。

**改动**：
- `Food`/`FoodItem`：加 `purinePer100g` / `purineMg`（嘌呤 mg，肝代谢产尿酸，与蛋白无关）
- `FoodDatabase`：12 种食物补嘌呤值（三文鱼 250 / 红烧肉 150 / 鸡胸肉 137 / 豆腐 60 …）
- `DigestionSession`：
  - 尿酸改肝产（`purine * uricAcidPerPurineMg`，不挂 liver.eff），肾排 70% + 肠排 30%
  - 新增尿素（蛋白→肝脱氨，`ureaPerProteinMg=340`），肾排泄，过载滞留
  - 新增吸收物：葡萄糖入血/血糖负荷/胰岛素响应/氨基酸/脂肪酸
  - `Constants` 加 `liverPurineLoad`/`kidneyPurineLoad`/`ureaPerProteinMg`/`uricAcidPerPurineMg`/`uricAcidRenalFraction`，删 `uricAcidPerProteinMg`
  - 肾过载分别产「尿酸滞留」「尿素滞留」残留
- `LiveSessionViewModel.makeBubbles`：小肠显示吸收物、胰腺显示血糖+胰岛素、肝显示产尿素·产尿酸、肾显示排泄+滞留
- `ReportView`：新增「吸收物」卡，summary 加尿酸/尿素产生·滞留行，高尿酸镜头改提嘌呤

**效果**：三文鱼产尿酸 250mg > 鸡胸肉 137mg，方向正确；尿素/吸收物维度可视化。常数标待运行时校准。

## 2026-08-12 · 文档补全 (`0009d86`)

新增 `docs/CHANGELOG.md` / `design-decisions.md` / `metabolism-research.md`，更新 `CLAUDE.md` 状态。新增 `docs/PRD.md`（v0.1，含 3 张 Mermaid 流程图）。

## 2026-08-11 · 残留时序修复 (`a92dba3`)

**问题**：吃西兰花时，膳食纤维残留（大肠）在粒子还在胃部就已画出，不符合逻辑。

**改动**：
- `LiveSessionViewModel`：新增 `settledResidueCount`，`eatIn` 前记录已沉淀残留数；`reset`/`removeEaten` 同步重置
- `LiveSessionRenderer`：新增 `organPathT(_:)` 脏器→路径 t 映射（胃0.30/小肠0.50/胰0.55/肝0.58/肾0.70/大肠0.88）
- `LiveSessionCanvasView`：按当前相位算粒子前端 `currentT`，仅画「已沉淀 或 粒子已到达该脏器」的残留

**效果**：本份新增残留按粒子到达脏器位置逐个揭示；之前已沉淀的始终显示。用户已确认生效。

## 2026-08-10 · 画布打磨第二轮 (`86c420b`)

**问题**：①折线不够显眼、泡泡非弹出动画；②`[西兰花]` 这类食物名标签会误导（残留应标物质而非食物）；③吸收不良物语义不清

**改动**：
- 连线：`drawConnection` 加 `progress` 参数，线宽 0.9、虚线 [3,2]、脏器端加大圆点，随泡泡淡入
- 泡泡：`OrganBubble.popProgress` 驱动 easeOutCubic 缩放(0.5→1)+淡入弹出动画
- 残留标签：`drawResidue` 改用 `r.substance`（膳食纤维/乳糖/尿酸）而非食物名
- 物质名重命名：「吸收不良物」→「未吸收营养」（小肠过载 + 吸收不足残留两处）

**未改（用户选 C）**：吸收不良数值真实性（豆腐第4份 67% 不吸收失真）——留到数据库轮连同营养分解物一起校准。

## 2026-08-10 · 画布打磨第一轮 (`af07261`)

**改动**：
- 脏器风格统一：胰腺/肾从独立 `drawExtraOrgans` 改为 `liveExtraOrgans: [Organ]`，与原型 6 脏器同用 `drawOrgan`，位置 pancreasPos=(78,150)、kidneyPos=(168,170)
- 剖面层次：躯干腔体微亮填充 + 脊柱暗示虚线，营造解剖图纵深
- 动画贴设计链：`drawFlowParticle` 加 `alpha` 参数，末端粒子 alpha 衰减模拟吸收消失

## 2026-08-10 · 第二顿：重置饮食 (`8e0c925`)

**改动**：消化预演 navbar 右上加「重置饮食」按钮（带确认弹窗），清空当前顿重开。代谢报告仍只反映当前顿。

**决策**：用户选「单顿滚动+重置」，不做跨顿累积、不留历史。详见 `design-decisions.md`。

## 2026-08-10 · live 会话核心 (`72f4ab2`)

从三屏线性流程重构为 live 累积会话（产品北极星落地）。

**新增核心层**：
- `DigestionSession`（@Observable）：脏器能力单调递减、过载产残留、尿酸产生+清除、`remove(at:)` 重放
- `LiveSessionViewModel`（@Observable）：串行状态机 idle→descending→digesting→idle，Timer 1/60s 驱动（不在 Canvas 渲染期改被观察属性）
- `UserPreferences`（@Observable）：问卷 UserDefaults 持久化

**新增视图**：`OnboardingView`/`LiveSessionView`/`LiveSessionCanvasView`/`LiveSessionRenderer`/`ReportView`/`MeView`/`EatenItemsSheet`

**用户 5 条修改意见逐条落地**：
1. 尿酸泡泡：肾泡泡蛋白>1 时显示「产生尿酸 Xmg」，滞留>0 追加「·滞留Ymg」
2. 泡泡连线 + 文字按「·」/长度折行
3. 人体轮廓改标准剖面图（`DigestionCanvasRenderer.drawBodyOutline` 重绘）
4. 底部 Tab：消化预演/代谢报告/我；session VM 提升到 ContentView 共享
5. 「我吃完了」切报告 Tab

**2 个优化**：①「已吃入N份」可展开删单份 ②同脏器多份残渣纵向铺开不重叠

## 2026-08-07 · 三屏版基线 (`03753a9`)

消化道可视化 + 代谢计算 + 清理转型后冗余代码（LoginView/ProfileView/UserProfile/SupabaseService/HealthKitService）+ 修复蛋白质 ATP 系数（0.05→0.085）。

> 此版本的三屏流程（FoodInputView/DigestiveView/Summary）在 live 会话落地后已不可达，待清理。

## 2026-06-23 · Initial Commit (`10fd2a0`)

项目初始化（早期带用户体系的健康工具版本，后转型为纯教育科普）。
