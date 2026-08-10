import SwiftUI

/// live 会话画布渲染（复用 DigestionCanvasRenderer 的背景/路径/器官，新增动态层）
struct LiveSessionRenderer {
    // 胰腺、肾：prototypeOrgans 之外的脏器，位置在身体轮廓内（240×370 坐标）
    static let pancreasPos = (cx: CGFloat(78), cy: CGFloat(150))
    static let kidneyPos   = (cx: CGFloat(168), cy: CGFloat(170))

    /// live 会话额外脏器（与 prototypeOrgans 同用 drawOrgan 绘制，风格统一）
    static let liveExtraOrgans: [Organ] = [
        Organ(id: "pancreas", label: "胰腺", cx: pancreasPos.cx, cy: pancreasPos.cy, rx: 13, ry: 8,
              color: "#6a4a30", highlightColor: "#cc8855", time: nil,
              detailTitle: nil, detailDesc: nil, detailTags: nil),
        Organ(id: "kidney", label: "肾", cx: kidneyPos.cx, cy: kidneyPos.cy, rx: 11, ry: 14,
              color: "#4a2a3a", highlightColor: "#aa5577", time: nil,
              detailTitle: nil, detailDesc: nil, detailTags: nil),
    ]

    static let massColor     = Color(hex: "EF9F27")!
    static let flowColor     = AppTheme.carbColor
    static let bubbleBg      = Color(hex: "1a1a35")!
    static let bubbleStroke  = Color(hex: "3a3a66")!
    static let residueStruct = AppTheme.primaryLight
    static let residueOver   = Color(hex: "D85A30")!

    /// 食物团块（descending 阶段下滑）
    static func drawMass(at point: CGPoint, context: GraphicsContext) {
        let r = Path(ellipseIn: CGRect(x: point.x - 6, y: point.y - 4, width: 12, height: 8))
        context.fill(r, with: .color(massColor.opacity(0.92)))
        context.stroke(r, with: .color(massColor), lineWidth: 0.8)
    }

    /// 流动粒子（digesting 阶段沿主路径下行）；alpha 末端衰减模拟吸收消失
    static func drawFlowParticle(at point: CGPoint, alpha: Double = 1.0, context: GraphicsContext) {
        let r = Path(ellipseIn: CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5))
        context.fill(r, with: .color(flowColor.opacity(0.85 * alpha)))
    }

    /// 残留粒子 + 名称尾标 ●—[食物名]
    static func drawResidue(_ r: DigestionResidue, at point: CGPoint, context: GraphicsContext) {
        let dot = Path(ellipseIn: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6))
        let col: Color = r.kind == .structural ? residueStruct : residueOver
        context.fill(dot, with: .color(col))
        context.stroke(dot, with: .color(col.opacity(0.5)), lineWidth: 0.6)
        context.draw(
            Text("—[\(r.substance)]").font(.system(size: 7)).foregroundColor(Color(hex: "aaaacc")!),
            at: CGPoint(x: point.x + 7, y: point.y),
            anchor: .leading
        )
    }

    // MARK: 产物泡泡（画布两侧，连线指向脏器，文字折行）

    static let bubbleW: CGFloat = 62

    /// 把泡泡文本折成 1–2 行：优先在 "·" 处断开，否则按长度对半分。
    static func bubbleLines(_ text: String) -> [String] {
        if text.contains("·") {
            return text.split(separator: "·", omittingEmptySubsequences: false).map { String($0) }
        }
        let chars = Array(text)
        if chars.count <= 8 { return [text] }
        let mid = chars.count / 2
        return [String(chars.prefix(mid)), String(chars.suffix(chars.count - mid))]
    }

    /// 泡泡高度：标签行 + 文本行数 × 行高 + 内边距
    static func bubbleHeight(_ text: String) -> CGFloat {
        16 + CGFloat(bubbleLines(text).count) * 11 + 8
    }

    /// 为已弹出的泡泡分配矩形：按侧别纵向堆叠，高度自适应。
    static func layoutBubbles(_ bubbles: [OrganBubble]) -> [(OrganBubble, CGRect)] {
        var result: [(OrganBubble, CGRect)] = []
        var leftY: CGFloat = 26
        var rightY: CGFloat = 26
        let cw = DigestionCanvasRenderer.canvasWidth
        for b in bubbles {
            let h = bubbleHeight(b.text)
            let x: CGFloat = b.side == .left ? 2 : cw - 2 - bubbleW
            let y = b.side == .left ? leftY : rightY
            result.append((b, CGRect(x: x, y: y, width: bubbleW, height: h)))
            if b.side == .left { leftY += h + 5 } else { rightY += h + 5 }
        }
        return result
    }

    /// 从泡泡到脏器的连线（虚线 + 脏器端小圆点）；随泡泡弹出淡入
    static func drawConnection(from rect: CGRect, to organ: CGPoint, side: OrganBubble.Side, progress: Double, context: GraphicsContext) {
        let p = progress
        let start = side == .left
            ? CGPoint(x: rect.maxX, y: rect.midY)
            : CGPoint(x: rect.minX, y: rect.midY)
        var path = Path()
        path.move(to: start)
        path.addLine(to: organ)
        context.stroke(path, with: .color(AppTheme.primaryLight.opacity(0.7 * p)),
                       style: StrokeStyle(lineWidth: 0.9, dash: [3, 2]))
        let dot = Path(ellipseIn: CGRect(x: organ.x - 2, y: organ.y - 2, width: 4, height: 4))
        context.fill(dot, with: .color(AppTheme.primaryLight.opacity(p)))
    }

    /// 画泡泡本体（标签 + 折行文本）；按 popProgress 缩放+淡入弹出
    static func drawBubble(_ b: OrganBubble, rect: CGRect, context: GraphicsContext) {
        let p = b.popProgress
        let ease = 1 - pow(1 - p, 3)          // easeOutCubic
        let s = 0.5 + 0.5 * ease              // 0.5 → 1
        let alpha = p
        let w = rect.width * s, h = rect.height * s
        let scaled = CGRect(x: rect.midX - w / 2, y: rect.midY - h / 2, width: w, height: h)

        let path = Path(roundedRect: scaled, cornerRadius: 6)
        context.fill(path, with: .color(bubbleBg.opacity(0.95 * alpha)))
        context.stroke(path, with: .color(bubbleStroke.opacity(alpha)), lineWidth: 0.8)
        context.draw(
            Text(b.organLabel).font(.system(size: 8, weight: .bold)).foregroundColor(AppTheme.primaryLight.opacity(alpha)),
            at: CGPoint(x: scaled.midX, y: scaled.minY + 9)
        )
        let lines = bubbleLines(b.text)
        for (i, line) in lines.enumerated() {
            let y = scaled.minY + 22 + CGFloat(i) * 11
            context.draw(
                Text(line).font(.system(size: 7)).foregroundColor(Color(hex: "ccccdd")!.opacity(alpha)),
                at: CGPoint(x: scaled.midX, y: y)
            )
        }
    }
}
