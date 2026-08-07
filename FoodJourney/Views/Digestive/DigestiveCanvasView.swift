import SwiftUI

/// 消化道剖面图 Canvas 视图
struct DigestiveCanvasView: View {
    @ObservedObject var viewModel: DigestionViewModel

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // 每帧驱动粒子动画
                viewModel.particleSystem.update()

                // 计算缩放变换
                let (scale, offset) = DigestionCanvasRenderer.scaleTransform(for: size)

                // 应用缩放 + 偏移
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: offset.x, y: offset.y)
                transform = transform.scaledBy(x: scale, y: scale)
                context.concatenate(transform)

                // 背景
                context.fill(
                    Path(CGRect(origin: .zero, size: CGSize(
                        width: DigestionCanvasRenderer.canvasWidth,
                        height: DigestionCanvasRenderer.canvasHeight
                    ))),
                    with: .color(DigestionCanvasRenderer.bgColor)
                )

                // 人体轮廓
                DigestionCanvasRenderer.drawBodyOutline(context: context)

                // 消化道路径
                DigestionCanvasRenderer.drawPath(context: context)

                // 器官
                for organ in viewModel.organs {
                    DigestionCanvasRenderer.drawOrgan(
                        organ,
                        isSelected: viewModel.selectedOrganId == organ.id,
                        context: context
                    )
                }

                // 时间标注
                for organ in viewModel.organs {
                    DigestionCanvasRenderer.drawTimeAnnotation(organ, context: context)
                }

                // 粒子
                for particle in viewModel.particleSystem.particles {
                    DigestionCanvasRenderer.drawParticle(
                        particle,
                        in: viewModel.particleSystem,
                        context: context
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                let (scale, offset) = DigestionCanvasRenderer.scaleTransform(for: geometry.size)

                // 逆变换：将屏幕坐标映射回 240×370 坐标系
                let canvasPoint = CGPoint(
                    x: (location.x - offset.x) / scale,
                    y: (location.y - offset.y) / scale
                )
                let canvasSize = CGSize(
                    width: DigestionCanvasRenderer.canvasWidth,
                    height: DigestionCanvasRenderer.canvasHeight
                )
                viewModel.handleTap(at: canvasPoint, canvasSize: canvasSize)
            }
        }
    }
}