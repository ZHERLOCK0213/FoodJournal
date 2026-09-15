import Foundation

/// Intake directions, never disease severity. Only activate a level with an explicit rule.
enum IntakeAttention: String {
    case withinReference = "参考范围内"
    case nearReference = "接近参考上限"
    case aboveReference = "超过参考上限"
    case stopAdding = "建议不再追加该类食物"
    case ungraded = "暂不分档"
}

/// Pure whole-meal calculation. Hydration deliberately is not an input to this assessment.
struct MealFocusAnalysis {
    static let ruleVersion = "meal-focus-v1-2026-09-15"
    static let referenceSource = URL(string: "https://mydiabetesmyway.scot.nhs.uk/resources/internal/food-labels/")!
    static let dietSource = URL(string: "https://www.who.int/news-room/fact-sheets/detail/healthy-diet")!
    static let lactoseSource = URL(string: "https://www.niddk.nih.gov/health-information/digestive-diseases/lactose-intolerance/eating-diet-nutrition")!
    static let purineSource = URL(string: "https://www.nice.org.uk/guidance/ng219/chapter/Recommendations")!
    static let hydrationSource = URL(string: "https://www.nhc.gov.cn/cms-search/downFiles/5d8a03a81dd949158e7d66283c0f1849.pdf")!

    struct Contributor: Identifiable {
        let id: String
        let name: String
        let amount: Double
        let portionGrams: Double
        let unit: String
        var text: String { MealFocusAnalysis.amountText(amount, unit: unit) }
    }

    let focus: HealthFocus
    let total: Double?
    let totalText: String
    let contributors: [Contributor]
    let missingFoods: [String]
    let hasTrace: Bool
    let attention: IntakeAttention
    let finding: String
    let action: String
    let limitation: String
    let reference: String?
    let source: URL

    init?(items: [FoodItem], focus: HealthFocus) {
        let focus = focus.supported
        guard !items.isEmpty, focus != .general else { return nil }
        self.focus = focus
        let matrix = MealNutrientMatrix(items: items)
        let unit = focus == .uricAcid ? "mg" : focus == .calories ? "kcal" : "g"
        func value(_ values: MealNutrientMatrix.Values) -> Double? {
            switch focus {
            case .lipids: values.fat
            case .bloodSugar: values.carbs
            case .calories: values.calories
            case .lactose: values.lactose
            case .uricAcid: values.purine
            default: nil
            }
        }
        total = value(matrix.totals)
        hasTrace = focus == .lactose && matrix.totals.lactoseHasTrace
        missingFoods = matrix.rows.filter {
            value($0.values) == nil && !(focus == .lactose && $0.values.lactoseHasTrace)
        }.map(\.food.name)
        contributors = matrix.rows.compactMap { row in
            guard let amount = value(row.values), amount > 0 else { return nil }
            return Contributor(id: row.id, name: row.food.name + (row.food.isCustom ? " · 自建 v\(row.food.revision)" : ""),
                               amount: amount, portionGrams: row.grams, unit: unit)
        }.sorted { $0.amount == $1.amount ? $0.id < $1.id : $0.amount > $1.amount }
        if focus == .lactose {
            totalText = matrix.totals.lactoseText
        } else if focus == .uricAcid {
            totalText = total.map { Self.amountText($0, unit: unit) + matrix.totals.purineQualifier } ?? "暂无记录"
        } else {
            totalText = total.map { Self.amountText($0, unit: unit) + "（估算）" } ?? "暂无记录"
        }
        let first = contributors.first?.name
        let reduction = first.map { "若希望减少本餐摄入，可先缩小\($0)的追加份量。" }
        switch focus {
        case .lipids:
            // RI is a daily food-label comparator, NOT a personal allowance or single-meal limit.
            // No invented 80%/120% clinical bands; the other three directions remain inactive.
            let fat = matrix.totals.fat
            attention = fat >= 70 ? .stopAdding : .ungraded
            finding = "本餐脂肪约为成人标签每日参考量的 \(Self.percent(fat / 70))%。"
            action = fat >= 70
                ? "本餐已达到或超过该全天参考量，建议不再追加高脂食物。仍需进食时，可考虑少油的搭配；无需停止所有进食。"
                : (reduction ?? "本餐记录的脂肪为 0；这不代表整餐营养均衡。")
            reference = "对照：成人标签参考量 70 g／日（2,000 kcal 背景），不是单餐限额或个人目标。"
            limitation = "未计入其他餐次。低于此参考量不代表可放心追加；总脂肪不能区分饱和与不饱和脂肪，也不能预测血脂。儿童、孕哺期及有特殊营养需求者不宜据此判断个人摄入。"
            source = Self.referenceSource
        case .bloodSugar:
            attention = .ungraded
            finding = "本餐碳水约为成人标签每日参考量的 \(Self.percent(matrix.totals.carbs / 260))%。"
            action = reduction ?? "本餐记录的碳水为 0；仍需结合完整饮食安排。"
            reference = "对照：成人标签参考量 260 g／日（2,000 kcal 背景），不是摄入上限或个人目标。"
            limitation = "碳水克数不等于糖含量或血糖升幅；尚不足以判断个人血糖反应。"
            source = Self.referenceSource
        case .calories:
            attention = .ungraded
            finding = "本餐热量约为成人标签每日参考量的 \(Self.percent(matrix.totals.calories / 2_000))%。"
            action = reduction ?? "请核对食物份量及热量记录。"
            reference = "对照：成人标签参考量 2,000 kcal／日，不是单餐限额或个人能量需求。"
            limitation = "未计入其他餐次与活动消耗，不能据此判断全天能量盈余。"
            source = Self.referenceSource
        case .lactose:
            attention = .ungraded
            finding = missingFoods.isEmpty ? "按本餐全部份量汇总；乳糖耐受量因人而异。" : "仅汇总有记录的乳糖，不能代表本餐全部含量。"
            action = reduction.map { $0 + "如已有乳糖不耐受，可按既往耐受情况选择无乳糖替代。" }
                ?? (hasTrace ? "存在未量化的微量乳糖，不能按完全不含乳糖处理。" : "数值不能替代个人耐受判断；追加前核对产品乳糖信息。")
            reference = nil
            limitation = "不使用统一克数划分个人症状风险；微量和未提供均不当作 0。"
            source = Self.lactoseSource
        case .uricAcid:
            attention = .ungraded
            finding = missingFoods.isEmpty ? "按本餐全部份量汇总食物嘌呤，不换算成血尿酸。" : "仅汇总有记录的嘌呤，不能代表本餐全部含量。"
            action = reduction ?? "追加前先核对食物嘌呤信息；暂无记录不代表低嘌呤。"
            reference = nil
            limitation = "不能仅凭单餐嘌呤划分痛风发作风险。饮水不抵消嘌呤，饮食调整不替代降尿酸治疗。"
            source = Self.purineSource
        default:
            return nil
        }
    }

    static func amountText(_ value: Double, unit: String) -> String {
        if value > 0 && value < 0.1 { return "<0.1 \(unit)" }
        return value.formatted(.number.precision(.fractionLength(1))) + " " + unit
    }
    private static func percent(_ ratio: Double) -> String {
        if ratio > 0 && ratio < 0.001 { return "<0.1" }
        return (ratio * 100).formatted(.number.precision(.fractionLength(1)))
    }
}
