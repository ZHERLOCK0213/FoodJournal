import SwiftUI
import Combine

/// 消化道视图状态管理
@MainActor
class DigestionViewModel: ObservableObject {
    @Published var selectedOrganId: String? = nil
    @Published var selectedNutrient: NutrientType = .carb
    @Published var detailTitle: String = "点击上方器官查看代谢详情"
    @Published var detailDesc: String = "食物在消化道各部位逐步分解，点击器官了解代谢过程。"
    @Published var detailTags: [OrganTag] = []

    let organs = Organ.prototypeOrgans
    let particleSystem: ParticleSystem
    let meal: Meal

    init(meal: Meal) {
        self.meal = meal
        self.particleSystem = ParticleSystem(count: 6)

        // 根据餐食主营养类型设置默认
        selectedNutrient = meal.dominantNutrient
        particleSystem.setNutrientType(meal.dominantNutrient)

        // 更新默认描述
        updateDefaultDescription()
    }

    /// 处理画布点击
    func handleTap(at point: CGPoint, canvasSize: CGSize) {
        let scaleX = DigestionCanvasRenderer.canvasWidth / canvasSize.width
        let scaleY = DigestionCanvasRenderer.canvasHeight / canvasSize.height
        let mx = point.x * scaleX
        let my = point.y * scaleY

        // 只检测有详情的器官
        let clickableOrgans = organs.filter { $0.hasDetail }

        for organ in clickableOrgans {
            let dx = (mx - organ.cx) / organ.rx
            let dy = (my - organ.cy) / organ.ry
            if dx * dx + dy * dy <= 1 {
                selectOrgan(organ)
                return
            }
        }

        // 点击空白处取消选中
        deselectOrgan()
    }

    func selectOrgan(_ organ: Organ) {
        selectedOrganId = organ.id
        if let title = organ.detailTitle {
            detailTitle = title
        }
        if let desc = organ.detailDesc {
            detailDesc = desc
        }
        detailTags = organ.detailTags ?? []
    }

    func deselectOrgan() {
        selectedOrganId = nil
        updateDefaultDescription()
        detailTags = []
    }

    /// 切换营养类型
    func selectNutrient(_ type: NutrientType) {
        selectedNutrient = type
        particleSystem.setNutrientType(type)
    }

    // MARK: - 私有方法

    private func updateDefaultDescription() {
        if meal.items.isEmpty {
            detailTitle = "点击上方器官查看代谢详情"
            detailDesc = "食物在消化道各部位逐步分解，点击器官了解代谢过程。"
        } else {
            detailTitle = "消化路径 · \(meal.foodNamesText)"
            detailDesc = "\(meal.foodNamesText)的\(selectedNutrient.rawValue)在消化道各部位逐步分解，点击器官了解代谢过程。"
        }
    }
}
