import Foundation
import SwiftUI

/// 消化道路径控制点（从 HTML 原型翻译）
/// 基于 240×370 画布坐标
enum DigestionPath {
    /// 头部采用右侧面；路径从画面右侧的张口进入，再向后汇入居中的食管。
    static let upperPoints: [CGPoint] = [
        CGPoint(x: 170, y: 42),
        CGPoint(x: 158, y: 43),
        CGPoint(x: 145, y: 47),
        CGPoint(x: 132, y: 56),
        CGPoint(x: 124, y: 70),
        CGPoint(x: 120, y: 86),
        CGPoint(x: 132, y: 96),
        CGPoint(x: 155, y: 103),
        CGPoint(x: 158, y: 125),
        CGPoint(x: 150, y: 145),
        CGPoint(x: 134, y: 154),
        CGPoint(x: 118, y: 154),
    ]

    /// 小肠用多回环表达长度与盘曲，点间距保持均匀以获得稳定的粒子速度。
    static let smallIntestinePoints: [CGPoint] = [
        CGPoint(x: 118, y: 154),
        CGPoint(x: 108, y: 166),
        CGPoint(x: 112, y: 181),
        CGPoint(x: 124, y: 190),
        CGPoint(x: 100, y: 190),
        CGPoint(x: 91, y: 199),
        CGPoint(x: 101, y: 208),
        CGPoint(x: 132, y: 207),
        CGPoint(x: 141, y: 217),
        CGPoint(x: 130, y: 226),
        CGPoint(x: 98, y: 224),
        CGPoint(x: 89, y: 234),
        CGPoint(x: 101, y: 243),
        CGPoint(x: 133, y: 241),
        CGPoint(x: 141, y: 250),
        CGPoint(x: 129, y: 259),
        CGPoint(x: 104, y: 257),
        CGPoint(x: 94, y: 264),
        CGPoint(x: 86, y: 262),
    ]

    /// 大肠自然包围小肠：盲肠、升结肠、横结肠、降结肠、乙状结肠、直肠。
    static let largeIntestinePoints: [CGPoint] = [
        CGPoint(x: 86, y: 262),
        CGPoint(x: 81, y: 247),
        CGPoint(x: 80, y: 224),
        CGPoint(x: 81, y: 201),
        CGPoint(x: 85, y: 183),
        CGPoint(x: 94, y: 174),
        CGPoint(x: 111, y: 169),
        CGPoint(x: 130, y: 169),
        CGPoint(x: 147, y: 174),
        CGPoint(x: 155, y: 184),
        CGPoint(x: 158, y: 202),
        CGPoint(x: 158, y: 224),
        CGPoint(x: 156, y: 246),
        CGPoint(x: 152, y: 259),
        CGPoint(x: 142, y: 270),
        CGPoint(x: 128, y: 276),
        CGPoint(x: 116, y: 286),
        CGPoint(x: 120, y: 304),
    ]

    /// 主消化道路径（口腔→食道→胃J→小肠盘曲→大肠框→肛门）
    /// 解剖中心线：粒子/团块沿此走，加粗管道沿此绘，粒子自然落在管道内。
    /// 坐标 240×370，中轴 x=120；t≈i/(n-1) 与 catmullRom 分段一致（organPathT 据此取值）。
    static let points: [CGPoint] = upperPoints
        + smallIntestinePoints.dropFirst()
        + largeIntestinePoints.dropFirst()

    /// 门静脉分支路径（小肠→肝脏）
    /// 模拟营养素被小肠吸收后经门静脉进入肝脏
    static let liverBranchPoints: [CGPoint] = [
        CGPoint(x: 115, y: 210),   // 小肠中段
        CGPoint(x: 108, y: 190),
        CGPoint(x: 98, y: 165),
        CGPoint(x: 90, y: 140),
        CGPoint(x: 82, y: 120),   // 肝脏
    ]

    /// Catmull-Rom 样条插值
    /// - Parameters:
    ///   - points: 控制点数组
    ///   - t: 0~1 之间的参数
    /// - Returns: 插值后的坐标
    static func catmullRom(points: [CGPoint], t: CGFloat) -> CGPoint {
        let n = points.count
        let seg = min(Int(t * CGFloat(n - 1)), n - 2)
        let lt = t * CGFloat(n - 1) - CGFloat(seg)

        let p0 = points[max(seg - 1, 0)]
        let p1 = points[seg]
        let p2 = points[min(seg + 1, n - 1)]
        let p3 = points[min(seg + 2, n - 1)]

        let x = 0.5 * ((2 * p1.x)
            + (-p0.x + p2.x) * lt
            + (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * lt * lt
            + (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * lt * lt * lt)

        let y = 0.5 * ((2 * p1.y)
            + (-p0.y + p2.y) * lt
            + (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * lt * lt
            + (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * lt * lt * lt)

        return CGPoint(x: x, y: y)
    }

    /// 用 catmullRom 在控制点上细密采样，生成平滑 Path——
    /// 管道沿此绘，粒子沿 catmullRom 走，两者完全重合（粒子落在管道内）。
    static func smoothPath(through points: [CGPoint], samples: Int = 240) -> Path {
        var p = Path()
        guard points.count >= 2 else { return p }
        p.move(to: catmullRom(points: points, t: 0))
        for i in 1...samples {
            let t = CGFloat(i) / CGFloat(samples)
            p.addLine(to: catmullRom(points: points, t: t))
        }
        return p
    }
}
