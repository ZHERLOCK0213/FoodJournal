import Foundation

/// User-owned composition, stored separately from the immutable bundled catalog.
struct PersonalFood: Codable, Identifiable {
    let id: UUID
    var revision: Int
    var name: String
    var preparation: String
    var carbs: Double
    var protein: Double
    var fat: Double
    var calories: Double
    var fiber: Double?
    var lactose: Double?
    var purine: Double?

    var validationError: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || name.count > 60 {
            return "名称需为1至60个字符。"
        }
        if preparation.count > 200 { return "配方说明最多200个字符。" }
        if revision < 1 { return "食物记录无法读取。" }
        let amounts = [carbs, protein, fat, calories] + [fiber, lactose, purine].compactMap { $0 }
        if amounts.contains(where: { !$0.isFinite || $0 < 0 }) { return "成分须为大于或等于0的有效数值。" }
        if carbs > 100 || protein > 100 || fat > 100 || (fiber ?? 0) > 100 || (lactose ?? 0) > 100 {
            return "每100g食物中的单项克数不能超过100g。"
        }
        if carbs + protein + fat > 100.5 { return "每100g的碳水、蛋白质和脂肪合计不能超过100g（允许少量标签舍入差异）。" }
        if calories > 1000 || (purine ?? 0) > 100_000 { return "数值超出每100g食物的范围，请核对单位。" }
        return nil
    }

    var food: Food {
        Food(name: name, nutrients: [(carbs > 0, NutrientType.carb), (protein > 0, .protein), (fat > 0, .fat)]
            .filter { $0.0 }.map { $0.1 },
             carbPer100g: carbs, fatPer100g: fat, proteinPer100g: protein, caloriesPer100g: calories,
             fiberPer100g: fiber ?? 0, lactosePer100g: lactose ?? 0, purinePer100g: purine ?? 0,
             catalogID: "custom-\(id.uuidString)",
             metadata: FoodMetadata(kind: .reference, preparation: preparation,
                                    fiberPer100g: fiber, lactosePer100g: lactose, purinePer100g: purine),
             customID: id, revision: revision)
    }

    static func copy(of food: Food) -> PersonalFood {
        PersonalFood(id: UUID(), revision: 1, name: food.name, preparation: food.displayPreparation,
                     carbs: food.carbPer100g, protein: food.proteinPer100g, fat: food.fatPer100g,
                     calories: food.caloriesPer100g, fiber: food.knownFiberPer100g,
                     lactose: food.knownLactosePer100g, purine: food.knownPurinePer100g)
    }
}
