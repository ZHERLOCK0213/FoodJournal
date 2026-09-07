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
            DigestionCanvasRenderer.drawBodyCutaway(context: context)

            // 后层辅助器官先绘制，避免胰腺像贴纸一样压在胃的最前面。
            for organ in LiveSessionRenderer.liveExtraOrgans {
                DigestionCanvasRenderer.drawOrgan(organ, isSelected: false, context: context)
            }
            if let liver = Organ.prototypeOrgans.first(where: { $0.id == "liver" }) {
                DigestionCanvasRenderer.drawOrgan(liver, isSelected: false, context: context)
            }

            DigestionCanvasRenderer.drawPath(context: context)

            // 主消化道器官和标签位于前层；肝脏已在后层绘制。
            for organ in Organ.prototypeOrgans where organ.id != "liver" {
                DigestionCanvasRenderer.drawOrgan(organ, isSelected: false, context: context)
            }

            // 残留粒子（累积，跨份保留）——
            // 已沉淀（本份之前）的始终显示；本份新增的按粒子是否到达该脏器路径位置揭示，
            // 避免一吃西兰花膳食纤维就立刻出现在大肠。
            let currentT: Double = {
                switch viewModel.phase {
                case .descending: return viewModel.progress * 0.3
                case .digesting:  return 0.30 + viewModel.progress * 0.65
                case .idle:       return 1.0
                }
            }()
            let allResidues = viewModel.session.residues
            let settled = viewModel.settledResidueCount
            let visible = allResidues.enumerated().filter { idx, r in
                idx < settled || currentT >= LiveSessionRenderer.organPathT(r.organ)
            }.map { $0.element }
            // 同脏器多份纵向居中铺开，避免标签重叠（仅在可见集合内计数）
            var counts: [DigestiveOrgan: Int] = [:]
            for r in visible { counts[r.organ, default: 0] += 1 }
            var seq: [DigestiveOrgan: Int] = [:]
            for r in visible {
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
                // 团块从口腔下滑到胃（路径 t: 0 → 0.3）
                let t = viewModel.progress * 0.3
                let pt = DigestionPath.catmullRom(points: DigestionPath.points, t: t)
                LiveSessionRenderer.drawMass(at: pt, context: context)
            case .digesting:
                // 团块到胃后分解成粒子，从胃(t=0.3)向末端流动；末端 alpha 衰减=吸收消失
                let lead = 0.30 + viewModel.progress * 0.65
                for i in 0..<6 {
                    let t = lead - Double(i) * 0.06
                    guard t > 0.30 else { continue }
                    let tt = min(t, 0.96)
                    let pt = DigestionPath.catmullRom(points: DigestionPath.points, t: tt)
                    let alpha = t > 0.90 ? max(0, 1 - (t - 0.90) / 0.10) : 1.0
                    LiveSessionRenderer.drawFlowParticle(at: pt, alpha: alpha, context: context)
                }
            case .idle:
                break
            }

            // 已弹出的产物泡泡：布局 → 连线 → 本体
            let popped = viewModel.bubbles.filter { $0.hasPopped }
            for (b, rect) in LiveSessionRenderer.layoutBubbles(popped) {
                LiveSessionRenderer.drawConnection(from: rect, to: organPoint(for: b.organ), side: b.side, progress: b.popProgress, context: context)
                LiveSessionRenderer.drawBubble(b, rect: rect, context: context)
            }
        }
    }

    /// 脏器中心点（240×370 坐标）
    private func organPoint(for organ: DigestiveOrgan) -> CGPoint {
        switch organ {
        case .stomach:        return CGPoint(x: 145, y: 126)
        case .smallIntestine: return CGPoint(x: 115, y: 215)
        case .liver:          return CGPoint(x: 82, y: 122)
        case .pancreas:       return CGPoint(x: LiveSessionRenderer.pancreasPos.cx, y: LiveSessionRenderer.pancreasPos.cy)
        case .kidney:         return CGPoint(x: LiveSessionRenderer.kidneyPos.cx, y: LiveSessionRenderer.kidneyPos.cy)
        case .largeIntestine: return CGPoint(x: 84, y: 220)
        }
    }
}
