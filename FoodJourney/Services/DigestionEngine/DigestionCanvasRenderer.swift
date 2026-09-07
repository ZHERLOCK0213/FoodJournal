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

    // 肠道分段配色（小肠细而亮、大肠粗而暗 + 结肠袋纹，使二者一眼可辨）
    static let smallIntestineOuter = Color(hex: "3a7a55")!
    static let smallIntestineInner = Color(hex: "1d4030")!
    static let largeIntestineOuter = Color(hex: "2a3d18")!
    static let largeIntestineInner = Color(hex: "16280e")!

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

    // MARK: - 绘制人体轮廓（右侧面头部 + 近正面透明剖视躯干）

    static func drawBodyOutline(context: GraphicsContext) {
        // 头部侧向右方并在嘴部留出入口；躯干回到近正面以保留器官可读性。
        let path = Path { p in
            p.move(to: CGPoint(x: 102, y: 10))
            p.addCurve(to: CGPoint(x: 142, y: 8),
                       control1: CGPoint(x: 114, y: 2), control2: CGPoint(x: 132, y: 2))
            p.addCurve(to: CGPoint(x: 157, y: 22),
                       control1: CGPoint(x: 151, y: 11), control2: CGPoint(x: 156, y: 16))
            p.addCurve(to: CGPoint(x: 174, y: 31),
                       control1: CGPoint(x: 160, y: 25), control2: CGPoint(x: 168, y: 27))
            p.addCurve(to: CGPoint(x: 166, y: 38),
                       control1: CGPoint(x: 176, y: 34), control2: CGPoint(x: 172, y: 37))
            // 张开的上下唇形成向右的清晰食物入口。
            p.addCurve(to: CGPoint(x: 171, y: 42),
                       control1: CGPoint(x: 164, y: 39), control2: CGPoint(x: 166, y: 41))
            p.addCurve(to: CGPoint(x: 164, y: 47),
                       control1: CGPoint(x: 169, y: 45), control2: CGPoint(x: 166, y: 46))
            p.addCurve(to: CGPoint(x: 158, y: 57),
                       control1: CGPoint(x: 166, y: 51), control2: CGPoint(x: 163, y: 55))
            p.addCurve(to: CGPoint(x: 141, y: 66),
                       control1: CGPoint(x: 153, y: 62), control2: CGPoint(x: 146, y: 64))
            p.addCurve(to: CGPoint(x: 135, y: 73),
                       control1: CGPoint(x: 140, y: 69), control2: CGPoint(x: 138, y: 71))
            p.addCurve(to: CGPoint(x: 184, y: 92),
                       control1: CGPoint(x: 151, y: 76), control2: CGPoint(x: 173, y: 82))
            p.addCurve(to: CGPoint(x: 170, y: 214),
                       control1: CGPoint(x: 188, y: 150), control2: CGPoint(x: 178, y: 190))
            p.addCurve(to: CGPoint(x: 176, y: 292),
                       control1: CGPoint(x: 166, y: 240), control2: CGPoint(x: 174, y: 268))
            p.addCurve(to: CGPoint(x: 158, y: 362),
                       control1: CGPoint(x: 180, y: 330), control2: CGPoint(x: 172, y: 354))
            p.addLine(to: CGPoint(x: 82, y: 362))
            p.addCurve(to: CGPoint(x: 64, y: 292),
                       control1: CGPoint(x: 68, y: 354), control2: CGPoint(x: 60, y: 330))
            p.addCurve(to: CGPoint(x: 70, y: 214),
                       control1: CGPoint(x: 66, y: 268), control2: CGPoint(x: 74, y: 240))
            p.addCurve(to: CGPoint(x: 56, y: 92),
                       control1: CGPoint(x: 62, y: 190), control2: CGPoint(x: 52, y: 150))
            p.addCurve(to: CGPoint(x: 103, y: 69),
                       control1: CGPoint(x: 72, y: 80), control2: CGPoint(x: 92, y: 76))
            p.addCurve(to: CGPoint(x: 98, y: 57),
                       control1: CGPoint(x: 102, y: 65), control2: CGPoint(x: 99, y: 61))
            p.addCurve(to: CGPoint(x: 90, y: 37),
                       control1: CGPoint(x: 92, y: 51), control2: CGPoint(x: 89, y: 44))
            p.addCurve(to: CGPoint(x: 102, y: 10),
                       control1: CGPoint(x: 89, y: 25), control2: CGPoint(x: 93, y: 16))
            p.closeSubpath()
        }

        // 半透明填充：呈现"剖面"通透感，脏器在其上叠加绘制
        context.fill(path, with: .color(bodyOutlineColor.opacity(0.55)))
        context.stroke(path, with: .color(bodyStrokeColor), lineWidth: 1.0)

        // 眼眶与下颌线只提供朝向提示，不画写实五官。
        context.stroke(Path(ellipseIn: CGRect(x: 150, y: 25, width: 3, height: 2)),
                       with: .color(bodyStrokeColor.opacity(0.8)), lineWidth: 0.6)
        var jaw = Path()
        jaw.move(to: CGPoint(x: 157, y: 56))
        jaw.addCurve(to: CGPoint(x: 137, y: 64),
                     control1: CGPoint(x: 151, y: 61), control2: CGPoint(x: 144, y: 63))
        context.stroke(jaw, with: .color(bodyStrokeColor.opacity(0.55)), lineWidth: 0.6)

        // 耳廓帮助小尺寸轮廓仍被识别为人类侧脸。
        context.stroke(Path(ellipseIn: CGRect(x: 105, y: 30, width: 13, height: 18)),
                       with: .color(bodyStrokeColor.opacity(0.62)), lineWidth: 0.65)
        var earFold = Path()
        earFold.move(to: CGPoint(x: 110, y: 35))
        earFold.addCurve(to: CGPoint(x: 110, y: 43),
                         control1: CGPoint(x: 116, y: 35), control2: CGPoint(x: 116, y: 42))
        context.stroke(earFold, with: .color(bodyStrokeColor.opacity(0.45)), lineWidth: 0.5)
    }

    /// 半透明胸腹腔和中线，为器官提供剖面层级；旧页与 live 页共用。
    static func drawBodyCutaway(context: GraphicsContext) {
        let cavity = Path { p in
            p.move(to: CGPoint(x: 82, y: 88))
            p.addCurve(to: CGPoint(x: 158, y: 88),
                       control1: CGPoint(x: 101, y: 76), control2: CGPoint(x: 139, y: 76))
            p.addCurve(to: CGPoint(x: 166, y: 212),
                       control1: CGPoint(x: 171, y: 126), control2: CGPoint(x: 170, y: 180))
            p.addCurve(to: CGPoint(x: 158, y: 320),
                       control1: CGPoint(x: 161, y: 246), control2: CGPoint(x: 169, y: 286))
            p.addCurve(to: CGPoint(x: 82, y: 320),
                       control1: CGPoint(x: 140, y: 333), control2: CGPoint(x: 100, y: 333))
            p.addCurve(to: CGPoint(x: 74, y: 212),
                       control1: CGPoint(x: 71, y: 286), control2: CGPoint(x: 79, y: 246))
            p.addCurve(to: CGPoint(x: 82, y: 88),
                       control1: CGPoint(x: 70, y: 180), control2: CGPoint(x: 69, y: 126))
            p.closeSubpath()
        }
        context.fill(cavity, with: .color(Color(hex: "14142a")!.opacity(0.50)))
        context.stroke(cavity, with: .color(bodyStrokeColor.opacity(0.42)), lineWidth: 0.55)

        var midline = Path()
        midline.move(to: CGPoint(x: 120, y: 78))
        midline.addCurve(to: CGPoint(x: 120, y: 320),
                         control1: CGPoint(x: 117, y: 154), control2: CGPoint(x: 123, y: 246))
        context.stroke(midline, with: .color(Color(hex: "2a2a48")!.opacity(0.45)),
                       style: StrokeStyle(lineWidth: 0.7, dash: [1, 3]))
    }

    // MARK: - 绘制消化道路径

    static func drawPath(context: GraphicsContext, showAbsorptionPath: Bool = false) {
        // 分段绘制（共享端点保证连续）：食管+胃+十二指肠 / 小肠 / 大肠
        // 三段粗细+配色不同，使小肠(细亮)与大肠(粗暗+结肠袋纹)一眼可辨。
        let upperPts  = DigestionPath.upperPoints
        let smallPts  = DigestionPath.smallIntestinePoints
        let largePts  = DigestionPath.largeIntestinePoints

        // 1) 上段：细暗紫管（胃形覆盖其上，仅食管/十二指肠可见）
        strokeSegment(DigestionPath.smoothPath(through: upperPts),
                      outer: pipeColor, outerW: 3.5,
                      inner: pipeInnerColor, innerW: 1.6, context: context)

        // 2) 小肠：细亮绿，平滑盘曲
        strokeSegment(DigestionPath.smoothPath(through: smallPts),
                      outer: smallIntestineOuter, outerW: 3.0,
                      inner: smallIntestineInner, innerW: 1.2, context: context)

        // 3) 大肠：粗暗绿棕管 + 结肠袋纹（haustra pinches）
        let largePath = DigestionPath.smoothPath(through: largePts)
        strokeSegment(largePath,
                      outer: largeIntestineOuter, outerW: 8.0,
                      inner: largeIntestineInner, innerW: 5.0, context: context)
        drawHaustra(largePts, context: context)

        // 门静脉是吸收后的营养运输支线，不属于食物直接经过的消化道；仅在解释该主题时显示。
        if showAbsorptionPath {
            let branchPath = DigestionPath.smoothPath(through: DigestionPath.liverBranchPoints, samples: 60)
            context.stroke(
                branchPath,
                with: .color(pipeColor.opacity(0.45)),
                style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round, dash: [4, 3])
            )
            context.stroke(
                branchPath,
                with: .color(pipeInnerColor.opacity(0.45)),
                style: StrokeStyle(lineWidth: 0.8, lineCap: .round, lineJoin: .round, dash: [4, 3])
            )
        }

    }

    /// 双描边一段管道：外粗色 + 内细色，圆头圆角
    private static func strokeSegment(_ path: Path, outer: Color, outerW: CGFloat,
                                      inner: Color, innerW: CGFloat, context: GraphicsContext) {
        context.stroke(path, with: .color(outer),
                       style: StrokeStyle(lineWidth: outerW, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(inner),
                       style: StrokeStyle(lineWidth: innerW, lineCap: .round, lineJoin: .round))
    }

    /// 在大肠路径上画垂直短“掐痕”，模拟结肠袋（haustra）分段外观
    private static func drawHaustra(_ largePts: [CGPoint], context: GraphicsContext) {
        let pinches: [CGFloat] = [0.06, 0.16, 0.27, 0.38, 0.49, 0.60, 0.71, 0.82, 0.92]
        let half: CGFloat = 4.6
        for tp in pinches {
            let c = DigestionPath.catmullRom(points: largePts, t: tp)
            let a = DigestionPath.catmullRom(points: largePts, t: max(tp - 0.015, 0))
            let b = DigestionPath.catmullRom(points: largePts, t: min(tp + 0.015, 1))
            let dx = b.x - a.x, dy = b.y - a.y
            let len = max((dx * dx + dy * dy).squareRoot(), 0.001)
            let nx = -dy / len, ny = dx / len
            var line = Path()
            line.move(to: CGPoint(x: c.x - nx * half, y: c.y - ny * half))
            line.addLine(to: CGPoint(x: c.x + nx * half, y: c.y + ny * half))
            context.stroke(line, with: .color(bgColor), lineWidth: 1.6)
        }
    }

    // MARK: - 绘制器官

    static func drawOrgan(_ organ: Organ, isSelected: Bool, context: GraphicsContext) {
        // 按 id 画脏器矢量形；小肠/大肠由管道本身呈现，此处仅绘标签
        let shape: Path? = {
            switch organ.id {
            case "mouth":     return mouthPath(cx: organ.cx, cy: organ.cy)
            case "stomach":   return stomachShape()
            case "liver":     return liverShape()
            case "pancreas":  return pancreasShape()
            case "kidney":
                // 双肾：右肾(organ.cx, 不镜像, 门朝左/脊柱) + 左肾(镜像, 门朝右/脊柱)
                var kp = kidneyBeanShape(cx: organ.cx, cy: organ.cy, mirrored: false)
                kp.addPath(kidneyBeanShape(cx: 240 - organ.cx, cy: organ.cy, mirrored: true))
                return kp
            case "esophagus": return nil   // 管道已绘
            case "small", "large": return nil  // 管道即其形
            default:          return Path(ellipseIn: CGRect(x: organ.cx - organ.rx, y: organ.cy - organ.ry,
                                                            width: organ.rx * 2, height: organ.ry * 2))
            }
        }()

        if let path = shape {
            context.fill(path, with: .color(Color(hex: organ.color)!.opacity(organ.id == "kidney" ? 0.55 : 1.0)))
            if isSelected {
                context.stroke(path, with: .color(Color(hex: organ.highlightColor)!),
                               style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            } else {
                context.stroke(path, with: .color(organStrokeColor), lineWidth: 0.6)
            }
        }

        // 胆囊属于胆道辅助结构，不是食物经过的主路径；作为肝脏的次级层显示。
        if organ.id == "liver" {
            let gallbladder = gallbladderShape()
            context.fill(gallbladder, with: .color(Color(hex: "6B8E23")!.opacity(0.85)))
            context.stroke(gallbladder, with: .color(Color(hex: "A8C95F")!.opacity(0.7)), lineWidth: 0.55)
        }

        // 器官标签
        if let label = organ.label {
            let textColor: Color = isSelected ? .white : Color(hex: "666688")!
            context.draw(
                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                    .foregroundColor(textColor),
                at: CGPoint(x: organ.cx, y: organ.cy)
            )
        }
    }

    // MARK: - 脏器矢量形（240×370 坐标）

    /// 嘴的侧剖图：上唇/下唇 + 口腔腔体 + 舌 + 齿列
    private static func mouthPath(cx: CGFloat, cy: CGFloat) -> Path {
        var p = Path()
        // 右侧张口的口腔切面：右端是入口，左端收束到咽部。
        p.move(to: CGPoint(x: cx + 13, y: cy - 3))
        p.addCurve(to: CGPoint(x: cx - 15, y: cy - 3),
                   control1: CGPoint(x: cx + 7, y: cy - 7),
                   control2: CGPoint(x: cx - 7, y: cy - 6))
        p.addCurve(to: CGPoint(x: cx - 18, y: cy + 1),
                   control1: CGPoint(x: cx - 18, y: cy - 2),
                   control2: CGPoint(x: cx - 19, y: cy))
        p.addCurve(to: CGPoint(x: cx + 12, y: cy + 4),
                   control1: CGPoint(x: cx - 7, y: cy + 6),
                   control2: CGPoint(x: cx + 4, y: cy + 7))
        p.addCurve(to: CGPoint(x: cx + 13, y: cy - 3),
                   control1: CGPoint(x: cx + 10, y: cy + 2),
                   control2: CGPoint(x: cx + 11, y: cy))
        p.closeSubpath()
        return p
    }

    /// 胃位于人体左上腹（正面剖视时在画面右侧）；贲门接食管，幽门向画面左侧接十二指肠。
    private static func stomachShape() -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 132, y: 94))
        p.addCurve(to: CGPoint(x: 158, y: 99),
                   control1: CGPoint(x: 140, y: 91), control2: CGPoint(x: 153, y: 93))
        p.addCurve(to: CGPoint(x: 169, y: 124),
                   control1: CGPoint(x: 167, y: 105), control2: CGPoint(x: 171, y: 115))
        p.addCurve(to: CGPoint(x: 159, y: 149),
                   control1: CGPoint(x: 169, y: 135), control2: CGPoint(x: 166, y: 143))
        p.addCurve(to: CGPoint(x: 143, y: 161),
                   control1: CGPoint(x: 154, y: 156), control2: CGPoint(x: 149, y: 160))
        p.addCurve(to: CGPoint(x: 119, y: 154),
                   control1: CGPoint(x: 134, y: 162), control2: CGPoint(x: 127, y: 158))
        p.addCurve(to: CGPoint(x: 130, y: 144),
                   control1: CGPoint(x: 120, y: 150), control2: CGPoint(x: 126, y: 148))
        p.addCurve(to: CGPoint(x: 134, y: 120),
                   control1: CGPoint(x: 136, y: 136), control2: CGPoint(x: 138, y: 127))
        p.addCurve(to: CGPoint(x: 132, y: 94),
                   control1: CGPoint(x: 132, y: 111), control2: CGPoint(x: 129, y: 101))
        p.closeSubpath()
        return p
    }

    /// 肝位于人体右上腹；正面剖视中位于画面左侧，宽阔楔形覆盖胃的少量上缘。
    private static func liverShape() -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 49, y: 119))
        p.addCurve(to: CGPoint(x: 76, y: 98),
                   control1: CGPoint(x: 56, y: 105), control2: CGPoint(x: 66, y: 99))
        p.addCurve(to: CGPoint(x: 111, y: 107),
                   control1: CGPoint(x: 90, y: 97), control2: CGPoint(x: 104, y: 101))
        p.addCurve(to: CGPoint(x: 114, y: 126),
                   control1: CGPoint(x: 115, y: 113), control2: CGPoint(x: 116, y: 120))
        p.addCurve(to: CGPoint(x: 96, y: 143),
                   control1: CGPoint(x: 111, y: 136), control2: CGPoint(x: 104, y: 142))
        p.addCurve(to: CGPoint(x: 70, y: 145),
                   control1: CGPoint(x: 87, y: 145), control2: CGPoint(x: 78, y: 146))
        p.addCurve(to: CGPoint(x: 50, y: 133),
                   control1: CGPoint(x: 59, y: 143), control2: CGPoint(x: 52, y: 139))
        p.addCurve(to: CGPoint(x: 49, y: 119),
                   control1: CGPoint(x: 48, y: 128), control2: CGPoint(x: 48, y: 123))
        p.closeSubpath()
        return p
    }

    private static func gallbladderShape() -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 91, y: 130))
        p.addCurve(to: CGPoint(x: 96, y: 140),
                   control1: CGPoint(x: 97, y: 132), control2: CGPoint(x: 98, y: 137))
        p.addCurve(to: CGPoint(x: 91, y: 147),
                   control1: CGPoint(x: 95, y: 144), control2: CGPoint(x: 93, y: 147))
        p.addCurve(to: CGPoint(x: 87, y: 139),
                   control1: CGPoint(x: 87, y: 146), control2: CGPoint(x: 86, y: 142))
        p.addCurve(to: CGPoint(x: 91, y: 130),
                   control1: CGPoint(x: 87, y: 135), control2: CGPoint(x: 89, y: 132))
        p.closeSubpath()
        return p
    }

    /// 胰腺位于胃后下方；头部靠近画面左侧的十二指肠，尾部向画面右侧渐细。
    private static func pancreasShape() -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 95, y: 147))
        p.addCurve(to: CGPoint(x: 143, y: 145),
                   control1: CGPoint(x: 111, y: 142), control2: CGPoint(x: 132, y: 143))
        p.addCurve(to: CGPoint(x: 150, y: 148),
                   control1: CGPoint(x: 147, y: 145), control2: CGPoint(x: 150, y: 146))
        p.addCurve(to: CGPoint(x: 143, y: 151),
                   control1: CGPoint(x: 150, y: 150), control2: CGPoint(x: 147, y: 151))
        p.addCurve(to: CGPoint(x: 96, y: 155),
                   control1: CGPoint(x: 128, y: 154), control2: CGPoint(x: 109, y: 157))
        p.addCurve(to: CGPoint(x: 91, y: 151),
                   control1: CGPoint(x: 92, y: 155), control2: CGPoint(x: 90, y: 153))
        p.addCurve(to: CGPoint(x: 95, y: 147),
                   control1: CGPoint(x: 91, y: 149), control2: CGPoint(x: 93, y: 148))
        p.closeSubpath()
        return p
    }

    /// 肾豆形（由 kidney.svg 轮廓翻译，中心化坐标 + 平移/镜像）。
    /// 凹缘（肾门）默认朝 -x；右肾不镜像(门朝左/脊柱)，左肾镜像(门朝右/脊柱)。半透明绘于肠后。
    private static func kidneyBeanShape(cx: CGFloat, cy: CGFloat, mirrored: Bool) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 8.15, y: -7.65))
        p.addCurve(to: CGPoint(x: 8.18, y: -2.78), control1: CGPoint(x: 8.89, y: -6.10), control2: CGPoint(x: 8.85, y: -4.33))
        p.addCurve(to: CGPoint(x: 6.86, y: 1.74), control1: CGPoint(x: 6.37, y: -2.03), control2: CGPoint(x: 5.75, y: 0.17))
        p.addCurve(to: CGPoint(x: 7.82, y: 2.62), control1: CGPoint(x: 7.11, y: 2.10), control2: CGPoint(x: 7.43, y: 2.40))
        p.addCurve(to: CGPoint(x: 8.14, y: 8.19), control1: CGPoint(x: 8.82, y: 4.31), control2: CGPoint(x: 9.00, y: 6.39))
        p.addCurve(to: CGPoint(x: 0.85, y: 12.79), control1: CGPoint(x: 6.79, y: 11.02), control2: CGPoint(x: 3.97, y: 12.79))
        p.addCurve(to: CGPoint(x: -6.27, y: 8.50), control1: CGPoint(x: -2.09, y: 12.79), control2: CGPoint(x: -4.86, y: 11.17))
        p.addCurve(to: CGPoint(x: -6.28, y: -7.92), control1: CGPoint(x: -9.00, y: 3.37), control2: CGPoint(x: -9.00, y: -2.78))
        p.addLine(to: CGPoint(x: -6.27, y: -7.95))
        p.addCurve(to: CGPoint(x: 2.44, y: -12.09), control1: CGPoint(x: -4.60, y: -11.11), control2: CGPoint(x: -1.05, y: -12.79))
        p.addCurve(to: CGPoint(x: 8.15, y: -7.65), control1: CGPoint(x: 5.08, y: -11.56), control2: CGPoint(x: 7.10, y: -9.84))
        p.closeSubpath()
        let m: CGFloat = mirrored ? -1 : 1
        return p.applying(CGAffineTransform(scaleX: m, y: 1))
                .applying(CGAffineTransform(translationX: cx, y: cy))
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
