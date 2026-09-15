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
    let catalogID: String
    let metadata: FoodMetadata?
    let compositionReference: FoodCompositionReference?
    let customID: UUID?
    let revision: Int
    var isCustom: Bool { customID != nil }
    /// A meal keeps the composition that was used at ingestion, even after an edit.
    var compositionID: String { isCustom ? "\(catalogID)@\(revision)" : catalogID }
    private let hasExplicitMacros: Bool
    let name: String
    let nutrients: [NutrientType]
    let description: String?

    // 每100g营养数据
    let carbPer100g: Double
    let fatPer100g: Double
    let proteinPer100g: Double
    let caloriesPer100g: Double

    // 不可吸收 / 慢代谢成分
    let fiberPer100g: Double      // 来源口径的纤维参考值；不保证为总膳食纤维，见 sourceName
    let lactosePer100g: Double    // 乳糖 → 乳糖酶不足时大肠残留
    let liverLoadFactor: Double   // 肝负荷倍数（氢化油/反式脂肪等 >1，体现慢代谢）
    let purinePer100g: Double     // 嘌呤 mg/100g → 肝代谢产尿酸（与蛋白无关）

    // 数据来源（报告注脚，有权威来源时填）
    let sourceName: String?
    let sourceURL: URL?

    init(
        name: String,
        nutrients: [NutrientType],
        description: String? = nil,
        carbPer100g: Double? = nil,
        fatPer100g: Double? = nil,
        proteinPer100g: Double? = nil,
        caloriesPer100g: Double? = nil,
        fiberPer100g: Double = 0,
        lactosePer100g: Double = 0,
        liverLoadFactor: Double = 1.0,
        purinePer100g: Double = 0,
        sourceName: String? = nil,
        sourceURL: URL? = nil,
        catalogID: String? = nil,
        metadata: FoodMetadata? = nil,
        compositionReference: FoodCompositionReference? = nil,
        customID: UUID? = nil,
        revision: Int = 1
    ) {
        self.catalogID = catalogID ?? name
        self.metadata = metadata
        self.compositionReference = compositionReference
        self.customID = customID
        self.revision = revision
        self.hasExplicitMacros = [carbPer100g, fatPer100g, proteinPer100g, caloriesPer100g].allSatisfy { $0 != nil }
        self.name = name
        self.nutrients = nutrients
        self.description = description
        self.carbPer100g = carbPer100g ?? 0
        self.fatPer100g = fatPer100g ?? 0
        self.proteinPer100g = proteinPer100g ?? 0
        self.caloriesPer100g = caloriesPer100g ?? 0
        self.fiberPer100g = compositionReference?.fiber?.amount ?? fiberPer100g
        self.lactosePer100g = compositionReference?.lactose?.amount ?? lactosePer100g
        self.liverLoadFactor = liverLoadFactor
        self.purinePer100g = compositionReference?.purine?.amount ?? purinePer100g
        self.sourceName = sourceName
        self.sourceURL = sourceURL
    }

    var canPreview: Bool {
        metadata?.kind != .pending && (metadata == nil || hasExplicitMacros) &&
        [carbPer100g, fatPer100g, proteinPer100g, caloriesPer100g].allSatisfy { $0.isFinite && $0 >= 0 }
    }

    // A legacy omitted zero is not evidence of a measured zero. Explicit metadata may record zero.
    var knownFiberPer100g: Double? {
        if let value = compositionReference?.fiber { return value.amount }
        if let metadata { return metadata.fiberPer100g }
        return fiberPer100g > 0 ? fiberPer100g : nil
    }
    var knownLactosePer100g: Double? {
        if let value = compositionReference?.lactose { return value.amount }
        if compositionReference?.lactoseIsTrace == true { return nil }
        if let metadata { return metadata.lactosePer100g }
        return lactosePer100g > 0 ? lactosePer100g : nil
    }
    var knownPurinePer100g: Double? {
        if let value = compositionReference?.purine { return value.amount }
        if let metadata { return metadata.purinePer100g }
        return purinePer100g > 0 ? purinePer100g : nil
    }

    var purineIsEstimated: Bool {
        if let value = compositionReference?.purine { return value.isEstimate }
        return metadata == nil && knownPurinePer100g != nil
    }
}
