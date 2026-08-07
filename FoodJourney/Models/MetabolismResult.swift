import Foundation

/// 代谢计算结果
struct MetabolismResult {
    let atpMoles: Double
    let totalCalories: Double
    let glycemicLoad: GlycemicLevel
    let insulinResponse: GlycemicLevel
    let co2Grams: Double
    let waterGrams: Double
    let uricAcidMg: Double
    let dietAdvice: String

    enum GlycemicLevel: String {
        case low    = "低"
        case medium = "中"
        case high   = "高"

        var colorHex: String {
            switch self {
            case .low:    return "#1D9E75"
            case .medium: return "#EF9F27"
            case .high:   return "#D85A30"
            }
        }
    }
}
