import SwiftUI

/// 消化道 Canvas 绘制引擎
/// 将 HTML 原型的 Canvas 绘制逻辑翻译为 SwiftUI Canvas
struct DigestionCanvasRenderer {

    // MARK: - 颜色常量

    static let bgColor = Color(hex: "0d0d1a")!
    static let bodyOutlineColor = Color(hex: "1c1c38")!
    static let bodyStrokeColor = Color(hex: "2e2e55")!
    static let pipeColor = Color(hex: "2a2a55")!
    static let pipeInnerColor = Color(hex: "1a1a3a")!
    static let timeLineColor = Color(hex: "252545")!
    static let timeTextColor = Color(hex: "444466")!
    static let organStrokeColor = Color(hex: "2a2a4a")!

    // MARK: - 缩放工具

    /// 计算从 240×370 坐标系到实际尺寸的缩放变换
    static func scaleTransform(for size: CGSize) -> (scale: CGFloat, offset: CGPoint) {
        let scaleX = size.width / canvasWidth
        let scaleY = size.height / canvasHeight
        let scale = min(scaleX, scaleY)
        let offsetX = (size.width - canvasWidth * scale) / 2
        let offsetY = (size.height - canvasHeight * scale) / 2
        return (scale, CGPoint(x: offsetX, y: offsetY))
    }

    // MARK: - 画布尺寸

    static let canvasWidth: CGFloat = 240
    static let canvasHeight: CGFloat = 370

    // MARK: - 绘制人体轮廓（标准人体透明剖面，对称，半透明填充使脏器可见）

    static func drawBodyOutline(context: GraphicsContext) {
        // 以 x=120 为中轴对称；头部→颈→肩→躯干→髋→下身，240×370 坐标系
        let path = Path { p in
            p.move(to: CGPoint(x: 120, y: 6))
            // 头右侧 → 下颌
            p.addCurve(to: CGPoint(x: 138, y: 50),
                       control1: CGPoint(x: 134, y: 6), control2: CGPoint(x: 140, y: 28))
            // 颈
            p.addCurve(to: CGPoint(x: 132, y: 68),
                       control1: CGPoint(x: 136, y: 56), control2: CGPoint(x: 134, y: 62))
            // 肩
            p.addCurve(to: CGPoint(x: 184, y: 92),
                       control1: CGPoint(x: 138, y: 74), control2: CGPoint(x: 168, y: 80))
            // 躯干右侧 → 腰
            p.addCurve(to: CGPoint(x: 170, y: 214),
                       control1: CGPoint(x: 188, y: 150), control2: CGPoint(x: 178, y: 190))
            // 髋
            p.addCurve(to: CGPoint(x: 176, y: 292),
                       control1: CGPoint(x: 166, y: 240), control2: CGPoint(x: 174, y: 268))
            // 下身
            p.addCurve(to: CGPoint(x: 158, y: 362),
                       control1: CGPoint(x: 180, y: 330), control2: CGPoint(x: 172, y: 354))
            // 底部
            p.addLine(to: CGPoint(x: 82, y: 362))
            // 左侧镜像
            p.addCurve(to: CGPoint(x: 64, y: 292),
                       control1: CGPoint(x: 68, y: 354), control2: CGPoint(x: 60, y: 330))
            p.addCurve(to: CGPoint(x: 70, y: 214),
                       control1: CGPoint(x: 66, y: 268), control2: CGPoint(x: 74, y: 240))
            p.addCurve(to: CGPoint(x: 56, y: 92),
                       control1: CGPoint(x: 62, y: 190), control2: CGPoint(x: 52, y: 150))
            p.addCurve(to: CGPoint(x: 108, y: 68),
                       control1: CGPoint(x: 72, y: 80), control2: CGPoint(x: 102, y: 74))
            p.addCurve(to: CGPoint(x: 102, y: 50),
                       control1: CGPoint(x: 106, y: 62), control2: CGPoint(x: 104, y: 56))
            p.addCurve(to: CGPoint(x: 120, y: 6),
                       control1: CGPoint(x: 100, y: 28), control2: CGPoint(x: 106, y: 6))
            p.closeSubpath()
        }

        // 半透明填充：呈现"剖面"通透感，脏器在其上叠加绘制
        context.fill(path, with: .color(bodyOutlineColor.opacity(0.55)))
        context.stroke(path, with: .color(bodyStrokeColor), lineWidth: 1.0)

        // 颈部分隔细线（区分头与躯干的视觉提示）
        var neck = Path()
        neck.move(to: CGPoint(x: 104, y: 60))
        neck.addLine(to: CGPoint(x: 136, y: 60))
        context.stroke(neck, with: .color(bodyStrokeColor.opacity(0.5)),
                       style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
    }

    // MARK: - 绘制消化道路径

    static func drawPath(context: GraphicsContext) {
        // 主消化道管道
        let mainPoints = DigestionPath.points
        var mainPath = Path()
        mainPath.move(to: mainPoints[0])
        for i in 1..<mainPoints.count {
            mainPath.addLine(to: mainPoints[i])
        }

        // 外层管道
        context.stroke(
            mainPath,
            with: .color(pipeColor),
            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
        )
        // 内层管道
        context.stroke(
            mainPath,
            with: .color(pipeInnerColor),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )

        // 门静脉分支管道（小肠→肝脏）
        let liverBranch = DigestionPath.liverBranchPoints
        var branchPath = Path()
        branchPath.move(to: liverBranch[0])
        for i in 1..<liverBranch.count {
            branchPath.addLine(to: liverBranch[i])
        }
        context.stroke(
            branchPath,
            with: .color(pipeColor.opacity(0.7)),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [4, 3])
        )
        context.stroke(
            branchPath,
            with: .color(pipeInnerColor.opacity(0.7)),
            style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [4, 3])
        )

        // 肝脏回流管道
        let liverReturn = DigestionPath.liverReturnPoints
        var returnPath = Path()
        returnPath.move(to: liverReturn[0])
        for i in 1..<liverReturn.count {
            returnPath.addLine(to: liverReturn[i])
        }
        context.stroke(
            returnPath,
            with: .color(pipeColor.opacity(0.5)),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [3, 4])
        )
        context.stroke(
            returnPath,
            with: .color(pipeInnerColor.opacity(0.5)),
            style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [3, 4])
        )
    }

    // MARK: - 绘制器官

    static func drawOrgan(_ organ: Organ, isSelected: Bool, context: GraphicsContext) {
        let ellipseRect = CGRect(
            x: organ.cx - organ.rx,
            y: organ.cy - organ.ry,
            width: organ.rx * 2,
            height: organ.ry * 2
        )

        let path = Path(ellipseIn: ellipseRect)
        context.fill(path, with: .color(Color(hex: organ.color)!))

        if isSelected {
            context.stroke(
                path,
                with: .color(Color(hex: organ.highlightColor)!),
                style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
            )
        } else {
            context.stroke(path, with: .color(organStrokeColor), lineWidth: 0.5)
        }

        // 器官标签 — 选中时使用高亮色+白色描边确保可见
        if let label = organ.label {
            let textColor: Color
            if isSelected {
                // 选中时用白色确保在任何填充色上可见
                textColor = .white
            } else {
                textColor = Color(hex: "666688")!
            }
            context.draw(
                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                    .foregroundColor(textColor),
                at: CGPoint(x: organ.cx, y: organ.cy)
            )
        }
    }

    // MARK: - 绘制时间标注

    static func drawTimeAnnotation(_ organ: Organ, context: GraphicsContext) {
        guard let time = organ.time else { return }

        let tx: CGFloat = 195
        let ty = organ.cy

        // 虚线
        var line = Path()
        line.move(to: CGPoint(x: organ.cx + organ.rx + 3, y: organ.cy))
        line.addLine(to: CGPoint(x: tx - 2, y: ty))
        context.stroke(
            line,
            with: .color(timeLineColor),
            style: StrokeStyle(lineWidth: 0.5, dash: [2, 2])
        )

        // 时间文字
        context.draw(
            Text(time)
                .font(.system(size: 7))
                .foregroundColor(timeTextColor),
            at: CGPoint(x: tx, y: ty),
            anchor: .leading
        )
    }

    // MARK: - 绘制粒子

    static func drawParticle(_ particle: Particle, in system: ParticleSystem, context: GraphicsContext) {
        let pos = system.position(for: particle)
        let angle = system.angle(for: particle)

        let particlePath = Path { p in
            p.addEllipse(in: CGRect(
                x: -4, y: -2.5,
                width: 8, height: 5
            ))
        }

        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: pos.x, y: pos.y)
        transform = transform.rotated(by: angle)

        // 分支路径粒子稍小、稍透明
        let opacity: CGFloat
        let sizeScale: CGFloat
        switch particle.pathType {
        case .main:
            opacity = 0.9
            sizeScale = 1.0
        case .liverBranch:
            opacity = 0.75
            sizeScale = 0.8
        case .liverReturn:
            opacity = 0.6
            sizeScale = 0.7
        }

        var finalTransform = CGAffineTransform.identity
        finalTransform = finalTransform.translatedBy(x: pos.x, y: pos.y)
        finalTransform = finalTransform.rotated(by: angle)
        finalTransform = finalTransform.scaledBy(x: sizeScale, y: sizeScale)
        finalTransform = finalTransform.translatedBy(x: -pos.x, y: -pos.y)
        finalTransform = finalTransform.translatedBy(x: pos.x, y: pos.y)
        finalTransform = finalTransform.rotated(by: angle)

        context.fill(
            particlePath.applying(transform),
            with: .color(system.particleColor.opacity(opacity))
        )
    }
}

// MARK: - Color 扩展：十六进制解析

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 else { return nil }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
