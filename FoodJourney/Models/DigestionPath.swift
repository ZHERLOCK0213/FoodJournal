import Foundation

/// 消化道路径控制点（从 HTML 原型翻译）
/// 基于 240×370 画布坐标
enum DigestionPath {
    /// 主消化道路径（口腔→食道→胃→小肠→大肠）
    static let points: [CGPoint] = [
        CGPoint(x: 120, y: 16),
        CGPoint(x: 120, y: 28),
        CGPoint(x: 119, y: 42),
        CGPoint(x: 118, y: 56),
        CGPoint(x: 116, y: 70),
        CGPoint(x: 112, y: 82),
        CGPoint(x: 106, y: 94),
        CGPoint(x: 100, y: 108),
        CGPoint(x: 97, y: 122),
        CGPoint(x: 98, y: 136),
        CGPoint(x: 102, y: 148),
        CGPoint(x: 107, y: 158),
        CGPoint(x: 111, y: 168),
        CGPoint(x: 113, y: 180),
        CGPoint(x: 113, y: 192),
        CGPoint(x: 112, y: 205),
        CGPoint(x: 111, y: 218),
        CGPoint(x: 112, y: 230),
        CGPoint(x: 113, y: 242),
        CGPoint(x: 114, y: 254),
        CGPoint(x: 113, y: 266),
        CGPoint(x: 112, y: 278),
        CGPoint(x: 113, y: 298),
        CGPoint(x: 113, y: 315),
    ]

    /// 门静脉分支路径（小肠→肝脏）
    /// 模拟营养素被小肠吸收后经门静脉进入肝脏
    static let liverBranchPoints: [CGPoint] = [
        CGPoint(x: 113, y: 192),   // 小肠起点
        CGPoint(x: 120, y: 178),
        CGPoint(x: 130, y: 158),
        CGPoint(x: 140, y: 138),
        CGPoint(x: 148, y: 118),
        CGPoint(x: 153, y: 105),
        CGPoint(x: 155, y: 100),   // 肝脏终点
    ]

    /// 肝脏回流路径（肝脏→返回小肠区域）
    /// 模拟肝脏处理后营养素重新进入血液循环
    static let liverReturnPoints: [CGPoint] = [
        CGPoint(x: 155, y: 100),   // 肝脏起点
        CGPoint(x: 158, y: 115),
        CGPoint(x: 162, y: 140),
        CGPoint(x: 165, y: 165),
        CGPoint(x: 160, y: 190),
        CGPoint(x: 145, y: 200),   // 回到小肠附近
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
}
