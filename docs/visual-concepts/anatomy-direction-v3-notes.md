# 人体概念图 v3：Q 版与后层肾脏

日期：2026-09-06

后续纠正：用户明确否决本图的儿童比例。“Q 版”仅指圆润简化的形状，必须保留成年人的头身比例。当前实现见 `Design/Anatomy/v1`。

输出：[Q 版人体概念图](anatomy-direction-v3-chibi.png)

生成方式：Codex 内置 ImageGen；以 v2 图片为编辑对象。原版保留。本轮没有修改 App 代码。

## 用户明确的设计方向

- 人体可以 Q 版，优先让用户识别各个器官。
- 肾脏必须位于人体内，使用区别于肠道的颜色，合理表现前后遮挡。
- 用折线引出器官中发生的代谢过程说明。
- 保留上一轮简化肠道方向：圆角 90° 转向，大肠两折，小肠四折。

## 解剖依据与设计表达

肾脏位于肋骨下方、脊柱两侧，靠近腹部后壁，属于腹膜后器官。正面科普图可由肠道部分遮挡；不能为了显示肾脏将其移到腰部外侧或下腹部。

- [NIDDK：肾脏的位置与功能](https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work)
- [腹膜后空间影像解剖研究](https://pubmed.ncbi.nlm.nih.gov/25547251/)

v3 用蓝色豆形表达肾脏，在胃、肝下方后层显示部分轮廓。卡片“过滤血液 · 排出废物”说明功能；引线仅用于标注，不代表食物运输管道。

## 视觉检查与待修正

- 人体已改成大头、短躯干和圆润四肢。
- 两颗肾脏位于躯干内部，并上移到上腹部后层。
- 已有肝脏、肾脏、小肠三张折线说明卡。
- 小肠连接仍存在生成瑕疵，未可靠满足四个转角和单一连续管道要求；大肠表面仍有起伏纹理。
- 小肠引线端点未精确落在管道上。
- 这张图用于确认角色、颜色、遮挡和标注风格，不是最终动画路径或解剖连接图。

## 最终编辑提示词

```text
Use case: style-transfer.
Asset: FoodJourney educational anatomy concept v3.
Input image is the edit target. Rework it into a CHARMING CHIBI stylized educational app illustration, while keeping the concept: head in right-facing profile with open mouth ready to accept one food dot, front-facing cutaway torso, recognizable organs, dark navy background. Portrait 2:3 composition.

Make the person gender-neutral, larger round head, short wide rounded torso, tiny relaxed arms, friendly minimal facial features, soft translucent indigo body. Premium softly shaded 2.5D vector-like design. No realistic nasal cavities, muscle fibers, vessels or organ textures; no gore. Organs have simple recognizable silhouettes and consistent soft shading, not faces.

CRITICAL CORRECTION: BOTH kidneys must be fully INSIDE the torso, medial and high, close to either side of the spine, just below the rib area. They belong in a BACK layer behind upper intestinal loops, below/behind liver and stomach, NOT beside the outside of the waist and NOT at pelvic level. Viewer-left kidney slightly lower than viewer-right. Use distinct periwinkle BLUE for both bean-shaped kidneys, concave inner sides facing the spine. Partially occlude kidneys with foreground digestive organs and show their remaining contours with reduced opacity; clearly communicate depth. No floating or external kidneys.

Foreground organs: muted terracotta liver viewer-left upper abdomen, coral J-shaped stomach viewer-right, tiny green gallbladder under liver, small golden elongated pancreas below/behind stomach. Small intestine mint, large intestine darker teal. Keep simplified smooth tubing: large intestine has two principal rounded 90-degree bends forming an inverted U around the small intestine; small intestine has four rounded 90-degree turns forming a simple open angular S, three horizontal runs. No closed loops or branches. Connect stomach via duodenum to small intestine, small intestine terminal to viewer-left cecum, colon to rectal outlet. Keep colon smooth, no bead-like texture.

Add THREE elegant small Chinese explanation cards in the side margins, connected by THIN ANGULAR ELBOW LEADER LINES with one bend and a small endpoint dot directly on the relevant organ. They are annotation lines, clearly different from internal digestive tubes; no flow arrows suggesting food goes into kidneys. Keep lines out of labels, avoid crossings, leave generous readable space. Exact Chinese card text:
Left upper card, leader to liver: "肝脏" and below "加工营养物质"
Right mid card, leader to visible blue kidney: "肾脏" and below "过滤血液 · 排出废物"
Left lower card, leader to small intestine: "小肠" and below "吸收营养"
Clear contemporary Chinese sans-serif typography. Small subtle footer "消化与代谢示意".
The food dot and mouth-to-stomach trace can have restrained warm golden light. Simplify everything for approachable mobile-app legibility. No title, no phone frame, no additional labels, no watermarks.
```
