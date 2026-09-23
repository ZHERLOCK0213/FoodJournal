# FoodJourney 早期概念图与生成提示词

生成方式：ImageGen 图像生成。

日期：2026-09-04。

说明：两张图是早期视觉探索，不是医学图谱，也没有直接作为 App 内资产。这些历史提示词保留当时的风格与产品措辞，其中的健康记录定位和侧身人物方向不代表当前产品要求。当前项目状态见 [项目状态](../project-status.md)，后续矢量资产见 [器官素材 v3](../../Design/Anatomy/v3/README.md) 与 [胃形图标 v2](../../Design/AppIcon/v2/README.md)。

提示词记录生成意图，不保证模型输出严格满足解剖连接、尺寸或小尺寸识别要求；生成图也不构成这些要求已通过验证的证据。

## 人体消化视觉方向 v1

输出：`anatomy-direction-v1.png`（1024 × 1536）

```text
Create an original vertical 2:3 visual-direction concept for an iOS app called FoodJourney. Use case: scientific educational wellness animation, not a diagnosis tool. Show one adult, gender-neutral human head and torso in a clear RIGHT-FACING SIDE PROFILE, with the face pointing to the right edge. The mouth is visibly open in a relaxed “ready to receive food” pose. The outer body is a graceful semi-transparent indigo cutaway silhouette, non-gory and calm.

Inside, depict a meaningful, anatomically coherent digestive system as a stylized layered-vector illustration: a continuous readable route from open mouth to pharynx, esophagus, stomach, duodenum, smoothly coiled small intestine, large intestine framing the small intestine, sigmoid colon and rectum. Include the liver in the right upper abdomen, a small gallbladder beneath it, and an elongated pancreas behind/below the stomach, connected conceptually toward the duodenum. Keep kidneys faint and secondary if shown. Respect anatomical relative positions while choosing a slightly three-quarter cutaway projection so every key organ remains readable. The colon must have soft organic curves and rounded haustra, never a rectangular tube; the small intestine must use many elegant smooth coils, never a crude S-shape.

Create an obvious luminous digestion path beginning at the open mouth and flowing through the organs, suitable as the foundation for motion design. Visual style: premium scientific editorial illustration, precise smooth Bézier contours, gentle depth, subtle translucent overlaps, dark midnight-navy background, deep-indigo body, warm coral stomach, muted burgundy liver, golden pancreas, mint/teal intestines, small lime food particle, restrained soft glow. Sophisticated, reassuring, memorable, slightly futuristic, suitable for a serious health-journaling app and Xiaohongshu demo. Avoid childish cartoon style, medical horror, photorealism, gore, exaggerated anatomy, front-facing head, detached floating organs, hard geometric intestine corners, labels, typography, UI controls, mock phone frames, logos, signatures, and watermarks.
```

## App Icon v1

输出：`app-icon-concept-v1.png`（1254 × 1254）

```text
Create an original premium iOS app icon concept for a health-journaling app named FoodJourney. Square 1024x1024, full-bleed opaque artwork; do not draw an outer rounded-square border because iOS applies its own mask.

The icon must remain unmistakable at 32px. Use one bold, elegant RIGHT-FACING SIDE-PROFILE silhouette that combines a human head and a minimal upper torso. The mouth is clearly open toward the right edge. A single small lime-gold food dot is just entering the mouth, and one continuous luminous warm-coral line flows from the mouth down through the neck, ending in a highly simplified, friendly stomach-shaped curve with one subtle intestinal loop. This should communicate “food journey through the body” in one glance, not just “stomach” and not a generic medical cross.

Visual language: deep midnight-navy to indigo full background, clean vector-like geometric silhouette, smooth Bézier curves, restrained coral/gold/teal highlights, gentle glow only around the journey line, high contrast, generous negative space, sophisticated and calm, modern Apple-platform wellness aesthetic, original symbol. Limit the design to 3–4 main colors and very few shapes. No text, letters, monogram, label, border, gradients that become muddy, photorealism, gore, detailed organs, brain, ribs, face details, front-facing person, detached body parts, childish mascot, medical cross, heartbeat line, plate, fork, spoon, watermark, or signature.
```
