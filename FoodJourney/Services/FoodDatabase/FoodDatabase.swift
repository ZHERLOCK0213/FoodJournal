import Foundation

/// 硬编码食物数据库（常见中国食物，每100g营养数据 + 不可吸收成分）
///
/// fiber/lactose 为结构性不可吸收成分（到大肠残留）；
/// liverLoadFactor 体现氢化油等慢代谢对肝的额外负荷（默认 1.0）。
/// 嘌呤为四种嘌呤碱基总量mg/100g，不是尿酸换算量。
/// FoodCompositionDatabase优先补充/校正辅助成分；没有校正的旧估值仍明确标为估算。
/// 宏量成分与辅助成分可能来自不同参考样本，详见集中来源及逐项核对文档。
enum FoodDatabase {
    static let allFoods: [Food] = [
        Food(
            name: "米饭",
            nutrients: [.carb],
            description: "精白米饭，主要成分为淀粉，消化后迅速转化为葡萄糖",
            carbPer100g: 28.0, fatPer100g: 0.3, proteinPer100g: 2.7, caloriesPer100g: 130,
            fiberPer100g: 0.4, purinePer100g: 2.1,
            compositionReference: FoodCompositionDatabase.entries["米饭"]
        ),
        Food(
            name: "馒头",
            nutrients: [.carb],
            description: "小麦粉发酵蒸制。采用馒头均值；不同配方会有差异。纤维按来源中的不溶性纤维口径。",
            carbPer100g: 47.0, fatPer100g: 1.1, proteinPer100g: 7.0, caloriesPer100g: 223,
            // CFS / CFC2002Ed2 0501070114040：纤维为不溶性口径，不是总膳食纤维。
            // 下方来源仅核对能量、三大营养素与不溶性纤维；嘌呤 4.1 仍待核。
            fiberPer100g: 1.3, purinePer100g: 4.1,
            sourceName: "香港食安中心 / 中国疾控 CFC2002Ed2 · 馒头(均值) 0501070114040；能量、三大营养素及不溶性纤维，不含嘌呤",
            sourceURL: URL(string: "https://www.cfs.gov.hk/tc_chi/nutrient/presearch3.php"),
            compositionReference: FoodCompositionDatabase.entries["馒头"]
        ),
        Food(
            name: "面条",
            nutrients: [.carb],
            description: "小麦粉制成的面条，消化速度较快",
            carbPer100g: 24.0, fatPer100g: 0.5, proteinPer100g: 4.5, caloriesPer100g: 120,
            fiberPer100g: 1.2, purinePer100g: 3.6,
            compositionReference: FoodCompositionDatabase.entries["面条"]
        ),
        Food(
            name: "鸡胸肉",
            nutrients: [.protein],
            description: "高蛋白低脂肪肉类，适合增肌减脂",
            carbPer100g: 0.0, fatPer100g: 1.9, proteinPer100g: 31.0, caloriesPer100g: 142,
            purinePer100g: 137,
            compositionReference: FoodCompositionDatabase.entries["鸡胸肉"]
        ),
        Food(
            name: "红烧肉",
            nutrients: [.fat, .protein],
            description: "五花肉红烧，脂肪含量较高，蛋白质中等",
            carbPer100g: 3.0, fatPer100g: 30.0, proteinPer100g: 15.0, caloriesPer100g: 350,
            purinePer100g: 150,
            compositionReference: FoodCompositionDatabase.entries["红烧肉"]
        ),
        Food(
            name: "三文鱼",
            nutrients: [.protein, .fat],
            description: "富含Omega-3脂肪酸，优质蛋白来源",
            carbPer100g: 0.0, fatPer100g: 13.0, proteinPer100g: 20.0, caloriesPer100g: 200,
            purinePer100g: 175, // 历史估值；当前由明确物种与状态的辅助成分参考覆盖。
            compositionReference: FoodCompositionDatabase.entries["三文鱼"]
        ),
        Food(
            name: "豆腐",
            nutrients: [.protein, .fat],
            description: "大豆制品，植物蛋白与异黄酮的良好来源",
            carbPer100g: 2.0, fatPer100g: 5.0, proteinPer100g: 8.0, caloriesPer100g: 82,
            fiberPer100g: 0.5, purinePer100g: 60,
            compositionReference: FoodCompositionDatabase.entries["豆腐"]
        ),
        Food(
            name: "鸡蛋",
            nutrients: [.protein, .fat],
            description: "全蛋含优质蛋白和卵磷脂，营养全面",
            carbPer100g: 1.5, fatPer100g: 9.0, proteinPer100g: 13.0, caloriesPer100g: 140,
            purinePer100g: 6,
            compositionReference: FoodCompositionDatabase.entries["鸡蛋"]
        ),
        Food(
            name: "西兰花",
            nutrients: [.carb, .protein],
            description: "低热量高纤维蔬菜，含维生素C和萝卜硫素",
            carbPer100g: 5.0, fatPer100g: 0.4, proteinPer100g: 3.5, caloriesPer100g: 35,
            fiberPer100g: 2.6, purinePer100g: 2.8,
            compositionReference: FoodCompositionDatabase.entries["西兰花"]
        ),
        Food(
            name: "苹果",
            nutrients: [.carb],
            description: "含果糖和膳食纤维，GI值中等约36",
            carbPer100g: 14.0, fatPer100g: 0.2, proteinPer100g: 0.3, caloriesPer100g: 57,
            fiberPer100g: 2.4, purinePer100g: 1.8,
            compositionReference: FoodCompositionDatabase.entries["苹果"]
        ),
        Food(
            name: "牛奶",
            nutrients: [.carb, .protein, .fat],
            description: "全脂牛奶，含乳糖、乳蛋白和乳脂肪",
            carbPer100g: 5.0, fatPer100g: 3.2, proteinPer100g: 3.3, caloriesPer100g: 64,
            lactosePer100g: 4.8, purinePer100g: 1.4,
            compositionReference: FoodCompositionDatabase.entries["牛奶"]
        ),
        Food(
            name: "香蕉",
            nutrients: [.carb],
            description: "高钾水果，含快速消化的淀粉和糖分",
            carbPer100g: 23.0, fatPer100g: 0.3, proteinPer100g: 1.1, caloriesPer100g: 96,
            fiberPer100g: 2.6, purinePer100g: 3.4,
            compositionReference: FoodCompositionDatabase.entries["香蕉"]
        ),
    ] + FoodDatabaseExpansion.foods
}
