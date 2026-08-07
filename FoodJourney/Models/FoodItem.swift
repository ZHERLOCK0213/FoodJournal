import Foundation

/// 用户选择的食物项（食物 + 克重）
struct FoodItem: Identifiable {
    let id = UUID()
    let food: Food
    var grams: Double
    var isSelected: Bool = false

    /// 碳水克数（按实际克重换算）
    var carbGrams: Double {
        food.carbPer100g * grams / 100.0
    }

    /// 脂肪克数
    var fatGrams: Double {
        food.fatPer100g * grams / 100.0
    }

    /// 蛋白质克数
    var proteinGrams: Double {
        food.proteinPer100g * grams / 100.0
    }

    /// 热量（kcal）
    var calories: Double {
        food.caloriesPer100g * grams / 100.0
    }
}
