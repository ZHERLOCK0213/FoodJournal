import SwiftUI
import Observation

/// 屏1 视图模型
@Observable
class FoodInputViewModel {
    let meal: Meal
    let availableFoods: [Food] = FoodDatabase.allFoods

    /// 当前展开详情的食物
    var detailFood: Food? = nil

    init(meal: Meal) {
        self.meal = meal
    }

    /// 点击食物 chip
    func toggleFood(_ food: Food) {
        meal.toggleFood(food, defaultGrams: defaultGrams(for: food))
    }

    /// 显示食物详情
    func showDetail(for food: Food) {
        detailFood = food
    }

    /// 关闭详情
    func dismissDetail() {
        detailFood = nil
    }

    /// 是否可进入屏2
    var canProceed: Bool {
        meal.canProceed
    }

    /// 默认克重（根据食物类型）
    private func defaultGrams(for food: Food) -> Double {
        if food.name.contains("牛奶") { return 250 }
        if food.name.contains("鸡蛋") { return 60 }
        if food.name.contains("苹果") || food.name.contains("香蕉") { return 150 }
        return 200
    }
}
