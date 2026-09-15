import Foundation

/// One row per stable catalog record, in first-added order. Original portions remain in the session.
struct MealNutrientMatrix {
    struct Values {
        let grams: Double
        let carbs: Double
        let protein: Double
        let fat: Double
        let calories: Double
        let fiber: Double?
        let lactose: Double?
        /// Available subtotal; legacy purine estimates are included and labelled separately.
        let purine: Double?
        let lactoseIsComplete: Bool
        let lactoseHasTrace: Bool
        let lactoseIncludesEstimates: Bool
        let purineIsComplete: Bool
        let purineIncludesEstimates: Bool
        var lactoseQualifier: String {
            let labels = [lactoseIncludesEstimates ? "估算" : nil,
                          lactoseIsComplete ? nil : "已记录小计"].compactMap { $0 }
            return labels.isEmpty ? "" : "（\(labels.joined(separator: "，"))）"
        }
        var lactoseText: String {
            if let lactose {
                return MealEducationSummary.gramsText(lactose) + (lactoseHasTrace ? "＋微量" : "") + lactoseQualifier
            }
            return lactoseHasTrace ? "微量（未量化）" + lactoseQualifier : "暂无记录"
        }
        var purineQualifier: String {
            let labels = [purineIncludesEstimates ? "估算" : nil,
                          purineIsComplete ? nil : "已记录小计"].compactMap { $0 }
            return labels.isEmpty ? "" : "（\(labels.joined(separator: "，"))）"
        }

        init(items: [FoodItem]) {
            grams = items.reduce(0) { $0 + $1.grams }
            carbs = items.reduce(0) { $0 + $1.carbGrams }
            protein = items.reduce(0) { $0 + $1.proteinGrams }
            fat = items.reduce(0) { $0 + $1.fatGrams }
            calories = items.reduce(0) { $0 + $1.calories }
            fiber = Self.completeSum(items.map(\.knownFiberGrams))
            let lactoseAmounts = items.map(\.knownLactoseGrams)
            let purineAmounts = items.map { item in
                item.food.knownPurinePer100g.map { $0 * item.grams / 100 }
            }
            lactose = Self.availableSum(lactoseAmounts)
            purine = Self.availableSum(purineAmounts)
            lactoseHasTrace = items.contains { $0.food.compositionReference?.lactoseIsTrace == true }
            lactoseIncludesEstimates = items.contains { $0.food.compositionReference?.lactose?.isEstimate == true }
            lactoseIsComplete = !items.isEmpty && items.allSatisfy {
                $0.knownLactoseGrams != nil || $0.food.compositionReference?.lactoseIsTrace == true
            }
            purineIsComplete = !items.isEmpty && purineAmounts.allSatisfy { $0 != nil }
            purineIncludesEstimates = items.contains {
                $0.food.purineIsEstimated
            }
        }

        private static func availableSum(_ amounts: [Double?]) -> Double? {
            let known = amounts.compactMap { $0 }
            return known.isEmpty ? nil : known.reduce(0, +)
        }

        private static func completeSum(_ amounts: [Double?]) -> Double? {
            guard !amounts.isEmpty, amounts.allSatisfy({ $0 != nil }) else { return nil }
            return amounts.compactMap { $0 }.reduce(0, +)
        }
    }

    struct Row: Identifiable {
        let id: String
        let food: Food
        let portionCount: Int
        let values: Values
        var grams: Double { values.grams }
        var carbs: Double { values.carbs }
        var protein: Double { values.protein }
        var fat: Double { values.fat }
        var calories: Double { values.calories }
        var fiber: Double? { values.fiber }
        var lactose: Double? { values.lactose }
        var purine: Double? { values.purine }
    }

    let rows: [Row]
    let totals: Values

    init(items: [FoodItem]) {
        var order: [String] = []
        var groups: [String: [FoodItem]] = [:]
        for item in items {
            let key = item.food.compositionID
            if groups[key] == nil { order.append(key) }
            groups[key, default: []].append(item)
        }
        rows = order.compactMap { key in
            guard let portions = groups[key], let first = portions.first else { return nil }
            return Row(id: key, food: first.food, portionCount: portions.count, values: Values(items: portions))
        }
        totals = Values(items: items)
    }
}
