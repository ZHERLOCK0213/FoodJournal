import Foundation

/// 代谢计算引擎
enum MetabolismEngine {

    /// 根据餐食计算代谢结果
    static func compute(for meal: Meal) -> MetabolismResult {
        let carb = meal.totalCarbGrams
        let fat = meal.totalFatGrams
        let protein = meal.totalProteinGrams
        let calories = meal.totalCalories

        // ATP 产量（简化估算）
        // 碳水: ~0.105 mol ATP/g (葡萄糖氧化产生约38 ATP/mol)
        // 脂肪: ~0.237 mol ATP/g (棕榈酸β氧化)
        // 蛋白质: ~0.085 mol ATP/g (4 kcal/g，脱氨损耗约 20-30%，净产与碳水/脂肪每 kcal 产 ATP 一致)
        let atpMoles = carb * 0.105 + fat * 0.237 + protein * 0.085

        // CO₂ 产出
        // 碳水 ~1.07g/g, 脂肪 ~2.8g/g, 蛋白质 ~0.8g/g
        let co2Grams = carb * 1.07 + fat * 2.8 + protein * 0.8

        // 水产出
        // 碳水 ~0.6g/g, 脂肪 ~1.07g/g, 蛋白质 ~0.4g/g
        let waterGrams = carb * 0.6 + fat * 1.07 + protein * 0.4

        // 尿酸（仅来自蛋白质代谢，约50mg/g蛋白质）
        let uricAcidMg = protein * 50.0

        // 血糖负荷等级
        let glycemicLoad: MetabolismResult.GlycemicLevel
        if carb < 20 {
            glycemicLoad = .low
        } else if carb < 50 {
            glycemicLoad = .medium
        } else {
            glycemicLoad = .high
        }

        // 胰岛素响应等级（综合碳水+脂肪比例）
        let insulinResponse: MetabolismResult.GlycemicLevel
        let carbRatio = carb / max(carb + fat + protein, 1)
        if carbRatio > 0.6 || carb > 60 {
            insulinResponse = .high
        } else if carbRatio > 0.4 || carb > 30 {
            insulinResponse = .medium
        } else {
            insulinResponse = .low
        }

        // 饮食建议
        let dietAdvice = generateAdvice(carb: carb, fat: fat, protein: protein, calories: calories)

        return MetabolismResult(
            atpMoles: atpMoles,
            totalCalories: calories,
            glycemicLoad: glycemicLoad,
            insulinResponse: insulinResponse,
            co2Grams: co2Grams,
            waterGrams: waterGrams,
            uricAcidMg: uricAcidMg,
            dietAdvice: dietAdvice
        )
    }

    // MARK: - 饮食建议生成

    private static func generateAdvice(carb: Double, fat: Double, protein: Double, calories: Double) -> String {
        var parts: [String] = []

        // 热量评估
        if calories > 800 {
            parts.append("这顿饭热量偏高（\(Int(calories))kcal），建议适当控制分量")
        } else if calories < 300 {
            parts.append("这顿饭热量偏低（\(Int(calories))kcal），注意补充足够营养")
        }

        // 碳水评估
        let total = carb + fat + protein
        let carbRatio = carb / max(total, 1)
        if carbRatio > 0.65 {
            parts.append("碳水占比偏高，建议晚餐减少主食，增加蔬菜和优质蛋白")
        } else if carbRatio < 0.3 {
            parts.append("碳水摄入偏低，适量补充全谷物可维持血糖稳定")
        }

        // 脂肪评估
        let fatRatio = fat / max(total, 1)
        if fatRatio > 0.5 {
            parts.append("脂肪比例较高，可考虑用蒸煮替代煎炸烹饪方式")
        }

        // 蛋白质评估
        let proteinRatio = protein / max(total, 1)
        if proteinRatio < 0.15 {
            parts.append("蛋白质偏少，建议搭配鸡蛋、鱼虾或豆制品")
        }

        if parts.isEmpty {
            parts.append("这顿饭营养搭配较为均衡，继续保持！")
        }

        return parts.joined(separator: "。") + "。"
    }
}
