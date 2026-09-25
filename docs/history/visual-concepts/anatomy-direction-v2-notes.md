# 人体概念图 v2：简化肠道

日期：2026-09-06

使用 ImageGen 编辑 v1，探索右侧张口、完整器官展示与透明质感。此文件记录历史概念探索，不代表当前 App 资产或界面；后续实现见 [器官素材 v3](../../../Design/Anatomy/v3/README.md)，项目状态见 [项目状态](../../project-status.md)。

输出：[简化肠道概念图](anatomy-direction-v2-simplified.png)

设计目标：大肠两折、小肠四折，转向采用圆滑的 90° 弯角。此版将“折”按主要 90° 转向计数；入口与出口连接不计入中段折数。这是简化几何的风格约束，不是人体肠道折数的解剖结论。

历史视觉检查：大肠表面已简化为光滑管道，小肠中段为三个横段、四处圆角转向。底部仍存在多余连接与汇合的生成瑕疵，不能作为最终解剖连接图或直接用作动画路径。该阶段仅探索概念图，没有更改 App 代码或正式图标；本次文档整理未重新生成或验证图片。

## 历史编辑提示词

以下保留生成意图，不能据此认定图像满足全部要求。

```text
Edit the original supplied anatomy picture. Preserve all anatomy above the intestine area, all other organs, body, head, pose, colors, lighting and framing. Replace the intestines with VERY SIMPLE smooth rounded plumbing geometry.
The LARGE intestine is one thick smooth teal upside-down U: left vertical, rounded top-left 90 degree corner, horizontal top, rounded top-right 90 degree corner, right vertical, then an outlet toward rectum. NO bumpy or segmented surface.
The SMALL intestine MUST be a single thin mint open zigzag tube with EXACTLY FOUR rounded 90-DEGREE CORNERS TOTAL. Just THREE horizontal strokes and TWO short vertical strokes. Route: from upper left go RIGHT, bend DOWN (corner 1), bend LEFT (corner 2), bend DOWN (corner 3), bend RIGHT (corner 4). The result is a simple angular S with rounded corners. Only three spaced horizontal rows, connected at alternate ends. Absolutely NO closed oval rings, NO disconnected loops, NO additional coiling. Large empty gaps between rows. Inlet connects from duodenum and terminal outlet connects to cecum with a subdued connector. Use the minimum necessary geometry. Keep the glowing gold food trace in the esophagus and stomach; do NOT add glowing lines inside intestines so the tube geometry is unambiguous. No text.
```
