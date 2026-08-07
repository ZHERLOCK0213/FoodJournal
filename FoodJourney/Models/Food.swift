import Foundation

/// 营养类型
enum NutrientType: String, CaseIterable, Identifiable {
    case carb      = "碳水"
    case fat       = "脂肪"
    case protein   = "蛋白质"

    var id: String { rawValue }

    var colorHex: String {
        switch self {
        case .carb:    return "#EF9F27"
        case .fat:     return "#D85A30"
        case .protein: return "#1D9E75"
        }
    }

    var bgColorHex: String {
        switch self {
        case .carb:    return "#2a1f0a"
        case .fat:     return "#1f0a0a"
        case .protein: return "#0a1f15"
        }
    }

    var borderColorHex: String {
        switch self {
        case .carb:    return "#BA7517"
        case .fat:     return "#A33F1F"
        case .protein: return "#0F6E56"
        }
    }
}

/// 食物模型（含每100g营养数据）
struct Food: Identifiable {
    let id = UUID()
    let name: String
    let nutrients: [NutrientType]
    let description: String?

    // 每100g营养数据
    let carbPer100g: Double
    let fatPer100g: Double
    let proteinPer100g: Double
    let caloriesPer100g: Double

    init(
        name: String,
        nutrients: [NutrientType],
        description: String? = nil,
        carbPer100g: Double = 0,
        fatPer100g: Double = 0,
        proteinPer100g: Double = 0,
        caloriesPer100g: Double = 0
    ) {
        self.name = name
        self.nutrients = nutrients
        self.description = description
        self.carbPer100g = carbPer100g
        self.fatPer100g = fatPer100g
        self.proteinPer100g = proteinPer100g
        self.caloriesPer100g = caloriesPer100g
    }
}
