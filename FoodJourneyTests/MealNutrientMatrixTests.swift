import XCTest
@testable import FoodJourney

@MainActor
final class MealNutrientMatrixTests: XCTestCase {
    private func food(_ id: String, name: String = "同名食品", fiber: Double? = nil, purine: Double? = nil) -> Food {
        Food(name: name, nutrients: [.carb], carbPer100g: 20, fatPer100g: 3,
             proteinPer100g: 5, caloriesPer100g: 127, purinePer100g: 999,
             catalogID: id, metadata: FoodMetadata(kind: .direct, preparation: "熟制",
                                                   fiberPer100g: fiber, purinePer100g: purine))
    }

    func testRepeatedPortionsMergeByStableRecordAndTotalsMatchRawItems() {
        let dumplings = food("dumpling", name: "水饺", fiber: 1)
        var items = (0..<10).map { _ in FoodItem(food: dumplings, grams: 100) }
        items.append(FoodItem(food: food("different-record", name: "水饺"), grams: 500))
        let meal = MealEducationSummary(items: items)
        XCTAssertEqual(meal.foodCount, 11)
        XCTAssertEqual(meal.distinctFoodCount, 2)
        XCTAssertEqual(meal.matrix.rows.map(\.id), ["dumpling", "different-record"])
        XCTAssertEqual(meal.matrix.rows[0].portionCount, 10)
        XCTAssertEqual(meal.matrix.rows[0].grams, 1000)
        XCTAssertEqual(meal.matrix.rows[1].grams, 500)
        XCTAssertEqual(meal.grams, 1500)
        XCTAssertEqual(meal.carbs, items.reduce(0) { $0 + $1.carbGrams })
        XCTAssertEqual(meal.protein, items.reduce(0) { $0 + $1.proteinGrams })
        XCTAssertEqual(meal.fat, items.reduce(0) { $0 + $1.fatGrams })
        XCTAssertEqual(meal.calories, items.reduce(0) { $0 + $1.calories })
        XCTAssertNil(meal.matrix.totals.fiber)
        XCTAssertEqual(meal.fiber, 10)
    }

    func testTenDistinctCapAllowsExistingAndReleasesSlotOnlyAfterLastPortionRemoved() {
        let vm = LiveSessionViewModel()
        let foods = (0..<11).map { food("food-\($0)") }
        for food in foods.prefix(10) {
            XCTAssertTrue(vm.session.recordEducation(FoodItem(food: food, grams: 100)))
        }
        vm.selectedFood = foods[10]
        XCTAssertFalse(vm.canEat)
        XCTAssertNotNil(vm.selectionBlockReason)
        XCTAssertFalse(vm.session.recordEducation(FoodItem(food: foods[10], grams: 100)))
        vm.selectedFood = foods[0]
        XCTAssertTrue(vm.canEat)
        XCTAssertNil(vm.selectionBlockReason)
        XCTAssertTrue(vm.session.recordEducation(FoodItem(food: foods[0], grams: 200)))
        vm.removeEaten(at: 0)
        XCTAssertEqual(vm.session.distinctFoodCount, 10)
        vm.selectedFood = foods[10]
        XCTAssertFalse(vm.canEat)
        vm.removeEaten(at: 9)
        XCTAssertEqual(vm.session.distinctFoodCount, 9)
        XCTAssertTrue(vm.canEat)
        XCTAssertTrue(vm.session.recordEducation(FoodItem(food: foods[10], grams: 100)))
        XCTAssertEqual(vm.session.distinctFoodCount, 10)
        XCTAssertTrue(vm.session.results.isEmpty)
    }

    func testUnknownPurineDoesNotUseLegacyEstimateAndZeroRemainsKnown() throws {
        let known = FoodItem(food: food("known", fiber: 0, purine: 0), grams: 100)
        let missing = FoodItem(food: food("missing"), grams: 100)
        let complete = MealEducationSummary(items: [known])
        XCTAssertEqual(complete.matrix.totals.purine, 0)
        XCTAssertEqual(complete.matrix.totals.fiber, 0)
        let partial = MealEducationSummary(items: [known, missing, missing])
        XCTAssertEqual(partial.matrix.totals.purine, 0)
        XCTAssertFalse(partial.matrix.totals.purineIsComplete)
        XCTAssertNil(partial.matrix.rows[1].purine)
        XCTAssertEqual(partial.matrix.rows.count, 2)
        let education = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: partial))
        XCTAssertTrue(education.context.contains("嘌呤合计 0.0mg"))
        XCTAssertTrue(education.context.contains("已记录小计"))
        XCTAssertFalse(education.context.contains("999"))
        XCTAssertFalse(education.context.contains("同名食品"))
        let legacy = Food(name: "旧估值", nutrients: [], purinePer100g: 999)
        let legacyValues = MealNutrientMatrix(items: [FoodItem(food: legacy, grams: 100)]).totals
        XCTAssertEqual(legacyValues.purine, 999)
        XCTAssertTrue(legacyValues.purineIncludesEstimates)
    }

    func testCompositionReferencesAndTraceRemainDistinctFromMissingData() throws {
        let milk = try XCTUnwrap(FoodDatabase.allFoods.first { $0.name == "牛奶" })
        let egg = try XCTUnwrap(FoodDatabase.allFoods.first { $0.name == "鸡蛋" })
        let rice = try XCTUnwrap(FoodDatabase.allFoods.first { $0.catalogID == "egg-fried-rice" })
        let known = MealNutrientMatrix(items: [FoodItem(food: milk, grams: 200), FoodItem(food: egg, grams: 100)]).totals
        XCTAssertEqual(try XCTUnwrap(known.lactose), 9.6, accuracy: 0.001)
        XCTAssertEqual(known.purine, 0)
        XCTAssertTrue(known.lactoseIsComplete)
        XCTAssertFalse(known.purineIncludesEstimates)
        let trace = MealNutrientMatrix(items: [FoodItem(food: rice, grams: 100)]).totals
        XCTAssertNil(trace.lactose)
        XCTAssertTrue(trace.lactoseHasTrace)
        XCTAssertEqual(trace.lactoseText, "微量（未量化）")
        let mixed = MealNutrientMatrix(items: [FoodItem(food: rice, grams: 100), FoodItem(food: milk, grams: 100)]).totals
        XCTAssertEqual(mixed.lactose, 4.8)
        XCTAssertTrue(mixed.lactoseText.contains("＋微量"))
    }

    func testLegacyMealUsesUpdatedReferencesAndRetainsRecipeEstimateLabel() throws {
        let names = ["面条", "红烧肉", "鸡胸肉"]
        let items = try names.map { name in
            FoodItem(food: try XCTUnwrap(FoodDatabase.allFoods.first { $0.name == name }), grams: 100)
        }
        let meal = MealEducationSummary(items: items)
        XCTAssertEqual(try XCTUnwrap(meal.matrix.totals.purine), 530.7, accuracy: 0.001)
        XCTAssertTrue(meal.matrix.totals.purineIncludesEstimates)
        XCTAssertEqual(meal.matrix.totals.lactose, 0)
        XCTAssertTrue(meal.fiberIsComplete)
        XCTAssertTrue(meal.fiberText.contains("含估算"))
    }
}
