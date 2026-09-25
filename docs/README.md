# FoodJourney 文档目录

先看 [项目状态](project-status.md) 了解现在做到哪里，再按下面的职责查阅。产品行为、验证结果和历史记录分别维护，避免把旧方案或未运行的代码当作已交付能力。

## 常用文档

| 想了解什么 | 文档 | 维护范围 |
| --- | --- | --- |
| 为谁做、为什么做 | [项目概览](project-brief.md) | 人群、价值假设、学习目标与成本 |
| 功能应当怎样工作 | [产品规格](PRD.md) | 当前行为契约、数据边界和验收标准 |
| 做到哪、验证了什么、下一步做什么 | [项目状态](project-status.md) | 基线、验证证据、已知问题与近期顺序；已合并原路线图 |
| 为什么作出这些选择 | [设计决策](design-decisions.md) | 关键理由、代价和被替代的方案 |
| 如何开发、测试和管理版本 | [开发流程](development-workflow.md) | Dev → Stage → Live、架构、测试隔离与协作方法 |
| 距离发布还有什么门槛 | [发布准备](release-readiness.md) | 设备、隐私、内容、签名和商店材料 |
| 最近发生了什么变化 | [变更日志](CHANGELOG.md) | 日期、变化与详情链接 |

## 资料依据：reference

这些资料仍用于理解当前数据或资产，不因版本号较早而视为失效；具体字段仍需看来源与审阅状态。

- [食物成分记录](reference/food-composition-v8.md)：字段、单位、样本和来源。
- [扩展食物来源表](reference/food-expansion-v5-sources.md)：扩展目录的证据与缺项。
- [食物数据与尿酸内容审计](reference/food-data-and-urate-audit.md)：可信度问题与解释边界。
- [视觉方向](reference/visual-direction.md)：构图、形状、资产与解剖表达边界。

## 历史档案：history

保留当时的分支名、数据口径和测试结果；不代表当前完整验收。每份阶段说明顶部标注继续适用或已被替代的部分。

- [开发与验证记录](history/development-history.md)：日期、环境、结果与历史功能样例。
- [早期代谢模型研究](history/metabolism-research.md)：已退出主流程的模型及局限。
- 阶段实现：[v4 胰腺科普](history/iterations/pancreas-education-v4.md)、[v5 食物扩展](history/iterations/food-expansion-v5.md)、[v6 餐食矩阵](history/iterations/meal-matrix-v6.md)、[v7 偏好与器官小结](history/iterations/preferences-and-organ-summary-v7.md)、[v9 自建食物](history/iterations/personal-foods-v9.md)、[v10 整餐关注](history/iterations/meal-focus-v10.md)。
- 历史测试：[v4 胰腺](history/iterations/testing-pancreas-v4.md)、[v4 尿酸](history/iterations/testing-urate-v4.md)、[v5 食物扩展](history/iterations/testing-food-expansion-v5.md)。
- 视觉探索：[概念提示词](history/visual-concepts/prompts.md)、[v2 说明](history/visual-concepts/anatomy-direction-v2-notes.md)、[v3 说明](history/visual-concepts/anatomy-direction-v3-notes.md)。原概念图片保存在同一目录；应用素材和历史截图另见 [Design](../Design)。

## 学习练习：learning

- [五款山姆商品标签练习](learning/sams-label-pilot.md)：先理解单位、份量、缺项与换算，再进入 SQL。尚未接入应用或数据库，原始截图未收入仓库。

一次普通交互修改通常只需同步产品规格、项目状态和变更日志，其余文档在相关职责发生变化时更新。贡献方式见 [贡献指南](../CONTRIBUTING.md)。
