import SwiftUI
import Combine

/// 粒子模型
struct Particle: Identifiable {
    let id = UUID()
    var t: CGFloat           // 沿路径的位置 0~1
    let speed: CGFloat       // 每帧移动速度（增加显著提升可见性）
    let pathType: ParticlePathType  // 走哪条路径
}

/// 粒子路径类型
enum ParticlePathType {
    case main          // 主消化道（口腔→食道→胃→小肠→大肠）
    case liverBranch   // 小肠→肝脏（门静脉）
}

/// 粒子系统管理器
@MainActor
class ParticleSystem: ObservableObject {
    @Published var particles: [Particle] = []

    /// 粒子颜色，由当前选中的营养类型决定
    var particleColor: Color = Color(hex: "EF9F27")!

    init(count: Int = 8) {
        // 显著提升速度：0.005 → 0.025（5倍）
        particles = []

        // 主消化道路径粒子（口腔→食道→胃→小肠→大肠）
        for i in 0..<6 {
            particles.append(Particle(
                t: CGFloat(i) / 6.0,
                speed: 0.025 + CGFloat.random(in: 0...0.01),
                pathType: .main
            ))
        }

        // 门静脉分支粒子（小肠→肝脏）
        particles.append(Particle(
            t: CGFloat.random(in: 0.1...0.5),
            speed: 0.030 + CGFloat.random(in: 0...0.01),
            pathType: .liverBranch
        ))

    }

    /// 每帧更新粒子位置
    func update() {
        for i in particles.indices {
            particles[i].t += particles[i].speed
            if particles[i].t > 1.0 {
                particles[i].t = 0
            }
        }
    }

    /// 获取粒子在画布上的位置
    func position(for particle: Particle) -> CGPoint {
        switch particle.pathType {
        case .main:
            return DigestionPath.catmullRom(points: DigestionPath.points, t: particle.t)
        case .liverBranch:
            return DigestionPath.catmullRom(points: DigestionPath.liverBranchPoints, t: particle.t)
        }
    }

    /// 获取粒子朝向角度
    func angle(for particle: Particle) -> CGFloat {
        let aheadT = min(particle.t + 0.02, 1.0)
        let pos = position(for: particle)
        let aheadPos: CGPoint

        switch particle.pathType {
        case .main:
            aheadPos = DigestionPath.catmullRom(points: DigestionPath.points, t: aheadT)
        case .liverBranch:
            aheadPos = DigestionPath.catmullRom(points: DigestionPath.liverBranchPoints, t: aheadT)
        }

        return atan2(aheadPos.y - pos.y, aheadPos.x - pos.x)
    }

    /// 切换营养类型时更新粒子颜色
    func setNutrientType(_ type: NutrientType) {
        particleColor = Color(hex: type.colorHex)!
    }
}
