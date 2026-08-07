import Foundation

/// 硬编码食物数据库（常见中国食物，每100g营养数据）
enum FoodDatabase {
    static let allFoods: [Food] = [
        Food(
            name: "米饭",
            nutrients: [.carb],
            description: "精白米饭，主要成分为淀粉，消化后迅速转化为葡萄糖",
            carbPer100g: 28.0, fatPer100g: 0.3, proteinPer100g: 2.7, caloriesPer100g: 130
        ),
        Food(
            name: "馒头",
            nutrients: [.carb],
            description: "小麦粉发酵蒸制，碳水化合物含量高，GI值约88",
            carbPer100g: 47.0, fatPer100g: 1.1, proteinPer100g: 7.0, caloriesPer100g: 223
        ),
        Food(
            name: "面条",
            nutrients: [.carb],
            description: "小麦粉制成的面条，消化速度较快",
            carbPer100g: 24.0, fatPer100g: 0.5, proteinPer100g: 4.5, caloriesPer100g: 120
        ),
        Food(
            name: "鸡胸肉",
            nutrients: [.protein],
            description: "高蛋白低脂肪肉类，适合增肌减脂",
            carbPer100g: 0.0, fatPer100g: 1.9, proteinPer100g: 31.0, caloriesPer100g: 142
        ),
        Food(
            name: "红烧肉",
            nutrients: [.fat, .protein],
            description: "五花肉红烧，脂肪含量较高，蛋白质中等",
            carbPer100g: 3.0, fatPer100g: 30.0, proteinPer100g: 15.0, caloriesPer100g: 350
        ),
        Food(
            name: "三文鱼",
            nutrients: [.protein, .fat],
            description: "富含Omega-3脂肪酸，优质蛋白来源",
            carbPer100g: 0.0, fatPer100g: 13.0, proteinPer100g: 20.0, caloriesPer100g: 200
        ),
        Food(
            name: "豆腐",
            nutrients: [.protein, .fat],
            description: "大豆制品，植物蛋白与异黄酮的良好来源",
            carbPer100g: 2.0, fatPer100g: 5.0, proteinPer100g: 8.0, caloriesPer100g: 82
        ),
        Food(
            name: "鸡蛋",
            nutrients: [.protein, .fat],
            description: "全蛋含优质蛋白和卵磷脂，营养全面",
            carbPer100g: 1.5, fatPer100g: 9.0, proteinPer100g: 13.0, caloriesPer100g: 140
        ),
        Food(
            name: "西兰花",
            nutrients: [.carb, .protein],
            description: "低热量高纤维蔬菜，含维生素C和萝卜硫素",
            carbPer100g: 5.0, fatPer100g: 0.4, proteinPer100g: 3.5, caloriesPer100g: 35
        ),
        Food(
            name: "苹果",
            nutrients: [.carb],
            description: "含果糖和膳食纤维，GI值中等约36",
            carbPer100g: 14.0, fatPer100g: 0.2, proteinPer100g: 0.3, caloriesPer100g: 57
        ),
        Food(
            name: "牛奶",
            nutrients: [.carb, .protein, .fat],
            description: "全脂牛奶，含乳糖、乳蛋白和乳脂肪",
            carbPer100g: 5.0, fatPer100g: 3.2, proteinPer100g: 3.3, caloriesPer100g: 64
        ),
        Food(
            name: "香蕉",
            nutrients: [.carb],
            description: "高钾水果，含快速消化的淀粉和糖分",
            carbPer100g: 23.0, fatPer100g: 0.3, proteinPer100g: 1.1, caloriesPer100g: 96
        ),
    ]
}
