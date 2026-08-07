import Foundation
import Observation

/// 用户的一餐（共享可变状态，跨三屏传递）
@Observable
class Meal {
    var items: [FoodItem] = []

    // MARK: - 总营养素

    var totalCarbGrams: Double {
        items.reduce(0) { $0 + $1.carbGrams }
    }

    var totalFatGrams: Double {
        items.reduce(0) { $0 + $1.fatGrams }
    }

    var totalProteinGrams: Double {
        items.reduce(0) { $0 + $1.proteinGrams }
    }

    var totalCalories: Double {
        items.reduce(0) { $0 + $1.calories }
    }

    // MARK: - 操作

    /// 添加/移除食物
    func toggleFood(_ food: Food, defaultGrams: Double = 200) {
        if let index = items.firstIndex(where: { $0.food.id == food.id }) {
            items.remove(at: index)
        } else {
            items.append(FoodItem(food: food, grams: defaultGrams, isSelected: true))
        }
    }

    /// 修改克重
    func setGrams(_ grams: Double, for foodId: UUID) {
        if let index = items.firstIndex(where: { $0.food.id == foodId }) {
            items[index].grams = grams
        }
    }

    /// 是否已选中某食物
    func isSelected(_ food: Food) -> Bool {
        items.contains(where: { $0.food.id == food.id })
    }

    /// 是否有选中的食物（可否进入屏2）
    var canProceed: Bool {
        !items.isEmpty
    }

    /// 食物名称列表（用于屏2导航栏副标题）
    var foodNamesText: String {
        if items.isEmpty { return "点击上方器官查看代谢详情" }
        let names = items.map(\.food.name)
        if names.count <= 3 { return names.joined(separator: " · ") }
        return names.prefix(3).joined(separator: " · ") + "等"
    }

    /// 主要营养类型（用于屏2默认粒子颜色）
    var dominantNutrient: NutrientType {
        let carb = totalCarbGrams
        let fat = totalFatGrams
        let protein = totalProteinGrams
        if carb >= fat && carb >= protein { return .carb }
        if fat >= carb && fat >= protein { return .fat }
        return .protein
    }
}
