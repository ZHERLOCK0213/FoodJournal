import Foundation

/// Input composition only. This deliberately does not read the legacy capacity/absorption model.
struct MealEducationSummary {
    let items: [FoodItem]
    let matrix: MealNutrientMatrix

    init(items: [FoodItem]) {
        self.items = items
        self.matrix = MealNutrientMatrix(items: items)
    }

    var foodCount: Int { items.count }
    var distinctFoodCount: Int { Set(items.map(\.food.catalogID)).count }
    var grams: Double { matrix.totals.grams }
    var carbs: Double { matrix.totals.carbs }
    var protein: Double { matrix.totals.protein }
    var fat: Double { matrix.totals.fat }
    /// Known subtotal only; never label this as a complete meal total without checking completeness.
    var fiber: Double { matrix.rows.compactMap(\.fiber).reduce(0, +) }
    var missingFiberFoods: [String] { matrix.rows.filter { $0.fiber == nil }.map(\.food.name) }
    var fiberIsComplete: Bool { missingFiberFoods.isEmpty }
    var fiberText: String {
        if matrix.rows.allSatisfy({ $0.fiber == nil }) { return "未提供" }
        let estimated = items.contains { $0.food.compositionReference?.fiber?.isEstimate == true }
        return Self.gramsText(fiber) + (fiberIsComplete ? "" : "（已知小计）") + (estimated ? "（含估算）" : "")
    }
    var calories: Double { matrix.totals.calories }
    var hasDigestibleNutrients: Bool { carbs > 0 || protein > 0 || fat > 0 }

    var nutrientNames: String {
        [(carbs > 0, "碳水化合物"), (protein > 0, "蛋白质"), (fat > 0, "脂肪")]
            .filter { $0.0 }.map { $0.1 }.joined(separator: "、")
    }

    static func gramsText(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1))) + "g"
    }

    func explanation(for part: AnatomyPart) -> String {
        switch part {
        case .mouth: "咀嚼并与唾液混合，形成易于吞咽的食团。"
        case .esophagus: "通过蠕动将食团输送到胃。"
        case .stomach: protein > 0 ? "混合食物与胃液，开始参与蛋白质消化。" : "搅拌食物、形成食糜，逐步送入小肠。"
        case .duodenum: "食糜在这里与胰液等消化液混合。"
        case .pancreas: "胰液中的酶帮助消化；胰岛素等激素参与血糖调节。这是两种不同的作用。"
        case .liver: carbs > 0 ? "接收和处理吸收后的营养，参与葡萄糖的利用、储存与血糖调节。" : "处理、储存和分配营养；也制造帮助脂肪消化的胆汁。"
        case .gallbladder: fat > 0 ? "储存并释放肝脏制造的胆汁，帮助脂肪消化。" : "本餐未标注脂肪；这里介绍胆囊储存、释放胆汁的一般功能。"
        case .smallIntestine: "继续消化并吸收营养；糖、氨基酸等经血液运输，部分脂肪经淋巴运输。"
        case .largeIntestine: fiber > 0 ? "回收水分，菌群分解部分纤维，剩余内容物参与形成粪便。" : "回收水分，参与粪便形成。"
        case .kidneys: "持续过滤血液、调节水和电解质，排出部分代谢废物；不能据此推算这餐的个人排泄量。"
        }
    }
}

enum PancreasRole: String, CaseIterable, Identifiable {
    case digestion, glucose
    var id: String { rawValue }
    var title: String { self == .digestion ? "帮助消化" : "血糖调节" }
    var subtitle: String { self == .digestion ? "胰液送往小肠" : "胰岛素经血液发挥作用" }
    var source: URL {
        self == .digestion ? AnatomyPart.pancreas.source : Self.insulinSource
    }
    static let insulinSource = URL(string: "https://www.niddk.nih.gov/health-information/diabetes/overview/what-is-diabetes")!

    struct Step: Identifiable {
        let id: Int
        let title: String
        let detail: String
    }

    var steps: [Step] {
        switch self {
        case .digestion:
            [Step(id: 0, title: "食糜到达十二指肠", detail: "胃将食物与胃液混合，逐步把食糜送入小肠。"),
             Step(id: 1, title: "胰液经导管进入小肠", detail: "胰腺提供含消化酶的胰液。食团不进入胰腺。"),
             Step(id: 2, title: "继续分解食物成分", detail: "胰液中的酶参与碳水化合物、蛋白质和脂肪的消化，帮助后续吸收。")]
        case .glucose:
            [Step(id: 0, title: "葡萄糖吸收入血", detail: "食物中的部分碳水化合物经消化形成葡萄糖，并被吸收。"),
             Step(id: 1, title: "胰岛素参与餐后调节", detail: "胰腺中的胰岛 β 细胞释放胰岛素，通过血液传递调节信号。"),
             Step(id: 2, title: "帮助细胞利用葡萄糖", detail: "胰岛素帮助身体细胞利用葡萄糖，并参与营养储存的调节；不是在胰腺里把糖消化掉。")]
        }
    }

    func context(for meal: MealEducationSummary) -> String {
        guard meal.foodCount > 0 else { return "先了解一般机制；选择食物后可以查看对应成分。" }
        switch self {
        case .digestion:
            return meal.hasDigestibleNutrients
                ? "这份选择含有\(meal.nutrientNames)，可了解胰液中的消化酶如何协作。"
                : "胰液中的消化酶参与食物分解。"
        case .glucose:
            return meal.carbs > 0
                ? "所选食物合计含碳水 \(MealEducationSummary.gramsText(meal.carbs))，可了解餐后血糖调节。这个克数不是血糖升幅或胰岛素分泌量。"
                : "当前食物标注碳水为 0g，不等于胰岛素分泌为零。下面讲解一般机制，不表示这份食物引发了相同反应。"
        }
    }
}
