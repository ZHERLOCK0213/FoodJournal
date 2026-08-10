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

/// 食物模型（含每100g营养数据 + 不可吸收成分 + 数据来源）
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

    // 不可吸收 / 慢代谢成分
    let fiberPer100g: Double      // 膳食纤维 → 大肠残留
    let lactosePer100g: Double    // 乳糖 → 乳糖酶不足时大肠残留
    let liverLoadFactor: Double   // 肝负荷倍数（氢化油/反式脂肪等 >1，体现慢代谢）

    // 数据来源（报告注脚，有权威来源时填）
    let sourceName: String?
    let sourceURL: URL?

    init(
        name: String,
        nutrients: [NutrientType],
        description: String? = nil,
        carbPer100g: Double = 0,
        fatPer100g: Double = 0,
        proteinPer100g: Double = 0,
        caloriesPer100g: Double = 0,
        fiberPer100g: Double = 0,
        lactosePer100g: Double = 0,
        liverLoadFactor: Double = 1.0,
        sourceName: String? = nil,
        sourceURL: URL? = nil
    ) {
        self.name = name
        self.nutrients = nutrients
        self.description = description
        self.carbPer100g = carbPer100g
        self.fatPer100g = fatPer100g
        self.proteinPer100g = proteinPer100g
        self.caloriesPer100g = caloriesPer100g
        self.fiberPer100g = fiberPer100g
        self.lactosePer100g = lactosePer100g
        self.liverLoadFactor = liverLoadFactor
        self.sourceName = sourceName
        self.sourceURL = sourceURL
    }
}
