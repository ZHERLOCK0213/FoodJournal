import SwiftUI

/// live 会话画布：TimelineView 每帧推进 VM，再渲染背景/脏器/团块/粒子/残留/泡泡
struct LiveSessionCanvasView: View {
    let viewModel: LiveSessionViewModel
    let date: Date

    var body: some View {
        Canvas { context, size in

            let (scale, offset) = DigestionCanvasRenderer.scaleTransform(for: size)
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: offset.x, y: offset.y)
            transform = transform.scaledBy(x: scale, y: scale)
            context.concatenate(transform)

            // 背景
            context.fill(
                Path(CGRect(origin: .zero,
                            size: CGSize(width: DigestionCanvasRenderer.canvasWidth,
                                         height: DigestionCanvasRenderer.canvasHeight))),
                with: .color(DigestionCanvasRenderer.bgColor)
            )
            DigestionCanvasRenderer.drawBodyOutline(context: context)
            DigestionCanvasRenderer.drawPath(context: context)
            for organ in Organ.prototypeOrgans {
                DigestionCanvasRenderer.drawOrgan(organ, isSelected: false, context: context)
            }
            LiveSessionRenderer.drawExtraOrgans(context: context)

            // 残留粒子（累积，跨份保留）——同脏器多份纵向居中铺开，避免标签重叠
            var counts: [DigestiveOrgan: Int] = [:]
            for r in viewModel.session.residues { counts[r.organ, default: 0] += 1 }
            var seq: [DigestiveOrgan: Int] = [:]
            for r in viewModel.session.residues {
                let i = seq[r.organ, default: 0]; seq[r.organ] = i + 1
                let total = counts[r.organ]!
                let base = organPoint(for: r.organ)
                let startY = base.y - CGFloat(total - 1) * 6.5
                let pt = CGPoint(x: base.x, y: startY + CGFloat(i) * 13)
                LiveSessionRenderer.drawResidue(r, at: pt, context: context)
            }

            // 动画元素
            switch viewModel.phase {
            case .descending:
                let t = viewModel.progress * 0.3
                let pt = DigestionPath.catmullRom(points: DigestionPath.points, t: t)
                LiveSessionRenderer.drawMass(at: pt, context: context)
            case .digesting:
                for i in 0..<5 {
                    let off = Double(i) * 0.1
                    let t = min(max(viewModel.progress + off, 0), 1)
                    let pt = DigestionPath.catmullRom(points: DigestionPath.points, t: t)
                    LiveSessionRenderer.drawFlowParticle(at: pt, context: context)
                }
            case .idle:
                break
            }

            // 已弹出的产物泡泡：布局 → 连线 → 本体
            let popped = viewModel.bubbles.filter { $0.hasPopped }
            for (b, rect) in LiveSessionRenderer.layoutBubbles(popped) {
                LiveSessionRenderer.drawConnection(from: rect, to: organPoint(for: b.organ), side: b.side, context: context)
                LiveSessionRenderer.drawBubble(b, rect: rect, context: context)
            }
        }
    }

    /// 脏器中心点（240×370 坐标）
    private func organPoint(for organ: DigestiveOrgan) -> CGPoint {
        switch organ {
        case .stomach:        return CGPoint(x: 103, y: 112)
        case .smallIntestine: return CGPoint(x: 112, y: 192)
        case .liver:          return CGPoint(x: 155, y: 100)
        case .pancreas:       return CGPoint(x: LiveSessionRenderer.pancreas.cx, y: LiveSessionRenderer.pancreas.cy)
        case .kidney:         return CGPoint(x: LiveSessionRenderer.kidney.cx, y: LiveSessionRenderer.kidney.cy)
        case .largeIntestine: return CGPoint(x: 112, y: 262)
        }
    }
}
