# FoodJourney 开发日志

> 按时间倒序。每轮记录改动内容，设计决策理由见 `design-decisions.md`。

## 2026-09-09 · v6 餐食矩阵与10种上限

- 同目录食品合并为统一成分表，报告读取矩阵合计；原始逐次记录保留供删除。每餐最多合并后10种，已有种类可追加，删完一种后释放名额。
- 加入500g选项，报告先展示成分再讲解；来源折叠、热量注明kcal。尿酸文案去除重复菜名与食物名称白名单，未知嘌呤不使用旧估值替代。
- 胰腺步骤改为静态三步，移除仅切换高亮的点击与播放，保留两种作用和来源，不增加器官放大动画。
- 52项均有通过记录：全量51通过，旧鸡胸肉重播等待超时1项定向复测通过；44单元＋8界面。截图已核验，普通构建安装到17Pro并保留偏好。证据与手动步骤见 [v6验收](meal-matrix-v6.md)。未提交、推送、签名或发布。

## 2026-09-08 · v5 食物库扩展（目录与来源阶段）

- 食物目录扩展至 **32 种**：原有 12 种保留，新增 20 种；目录与来源边界见 [`food-expansion-v5.md`](food-expansion-v5.md) 和 [`food-expansion-v5-sources.md`](food-expansion-v5-sources.md)。
- 20 种新增食物中，**14 种已有可用数值来源**；**6 种仍待来源/做法口径确认**：肉末茄子盖饭、蛋炒饭、牛肉粿条、鸡公煲、原味鸡、新疆炒米粉。不能将目录完成表述为 32 种食物的数值资料均已核实。
- 2026-09-09验证完成：全量41单元＋5界面通过，修正另2项控件类型断言后定向复测2项通过，期间App代码未变；共48项均有通过记录。中文搜索、来源链接、待补充禁用、餐记录与报告通过验证。截图已检查，已安装并普通启动iPhone17Pro，未重置偏好。新增混合纤维/碳水来源口径说明，教育记录不触发旧尿酸/器官容量估算。证据见 [续接记录](continuation.md)。本轮未进行Git提交、GitHub推送、TestFlight、签名或外部发布。

## 2026-09-08 · 尿酸科普焦点与食物数据审计

**尿酸焦点**：
- live 画布与代谢报告新增“关注尿酸”入口，解释食物嘌呤形成尿酸、肾脏经尿液排出以及肠道参与排出的定性路径；“食物本身不会进入肾脏”。
- 报告加入来源链接与边界说明：不把蛋白质克数当作嘌呤，不预测个人血尿酸或肾脏排泄量；饮水建议保留“无医护限水要求”等条件，不给固定个人处方。
- 依据 [MedlinePlus 痛风说明](https://medlineplus.gov/gout.html)、[MedlinePlus Genetics](https://medlineplus.gov/genetics/condition/gout/)、[国家卫健委《成人高尿酸血症与痛风食养指南（2024年版）》问答](https://www.nhc.gov.cn/cms-search/downFiles/5d8a03a81dd949158e7d66283c0f1849.pdf)；详细边界见 `food-data-and-urate-audit.md`。

**馒头数据核对**：
- CFS 营养资料查询系统中，记录 `0501070114040`（100g 可食部）标注资料来源为中国疾病预防控制中心营养与食品安全所 CFC2002Ed2；脂肪 **1.1g/100g** 的代码值与该记录一致，换算 600g 为 **6.6g**。
- CFS 的 **1.3g/100g** 已作为不溶性纤维来源口径完成校正，不等同于总膳食纤维；报告标注该口径，合计不称为总膳食纤维。当前馒头嘌呤值仍未声称已由 CFS 核实。
- 最终自动化验收：iPhone 17 Pro / iOS 26.5 通过 **39 项**测试（34 项单元测试、5 项 UI 测试），**0 失败、0 跳过**。手动验收清单见 [`testing-urate-v4.md`](testing-urate-v4.md)，后续衔接见 [`continuation.md`](continuation.md)。

## 2026-09-07 · v4 胰腺协作与整餐教育报告

- 报告改为整餐食物成分汇总与器官协作说明；胰腺提供“帮助消化”和“血糖调节”两种独立讲解，不展示旧模型的内脏使用度、个人胰岛素响应或未经验证的产物量。
- v4 初始验收在 iPhone 17 Pro / iOS 26.5 模拟器通过 32 项测试；随后与尿酸焦点合并完成最终 **39 项**自动化测试（34 项单元测试、5 项 UI 测试），覆盖红烧肉＋馒头成分累加、来源口径、尿酸焦点、旧容量上限诊断、胰腺双入口和报告交互；用户体验、真机与兼容性检查仍待完成。
- 本轮仅记录开发状态；未进行 TestFlight、App Store 提审或其他外部发布操作。发布范围以 `docs/release-readiness.md` 为准。

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
# 2026-09-15 · v10 整餐关注分析

- 关注主题新增整餐合计、主要来源、份量与追加提示；四方向不作为医学风险分级，未有依据的档位不启用。
- 脂肪按明确的成人全天标签参考量对照，不冒充单餐上限；嘌呤、乳糖不推测个人风险。
- 独立可选平日全天饮水背景，默认未知，包含限水选项；不修改嘌呤数值或等级。
- 食物及偏好持久化接口可注入，保留本机路径与旧数据；未上线账号或云端。
- 详见 [v10 规则与检查](meal-focus-v10.md)。新增测试源码未执行，不沿用历史通过记录。
