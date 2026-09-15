import XCTest
@testable import FoodJourney

@MainActor
final class FoodDatabaseExpansionTests: XCTestCase {
    func testCatalogAddsTwentyUniqueFoodsAndKeepsPendingRecipesExplicit() {
        XCTAssertEqual(FoodDatabase.allFoods.count, 32)
        XCTAssertEqual(FoodDatabaseExpansion.foods.count, 20)
        XCTAssertEqual(Set(FoodDatabase.allFoods.map(\.catalogID)).count, 32)
        XCTAssertEqual(Set(FoodDatabase.allFoods.map(\.name)).count, 32)
        XCTAssertEqual(FoodDatabaseExpansion.foods.filter(\.canPreview).count, 15)
        let pending = Set(FoodDatabaseExpansion.foods.filter { !$0.canPreview }.map(\.name))
        XCTAssertEqual(pending, Set(["肉末茄子盖饭", "牛肉粿条", "鸡公煲", "原味鸡", "新疆炒米粉"]))
    }

    func testEveryAvailableAdditionHasTraceableSourceAndNoInventedPurine() throws {
        for food in FoodDatabaseExpansion.foods {
            let metadata = try XCTUnwrap(food.metadata)
            if let purine = food.knownPurinePer100g {
                XCTAssertEqual(food.compositionReference?.purine?.amount, purine)
                XCTAssertFalse(try XCTUnwrap(food.compositionReference?.purine?.record).isEmpty)
            }
            XCTAssertFalse(metadata.preparation.isEmpty)
            if food.canPreview {
                XCTAssertTrue(food.knownLactosePer100g != nil || food.compositionReference?.lactoseIsTrace == true)
                XCTAssertEqual(food.sourceURL?.scheme, "https")
                XCTAssertFalse(try XCTUnwrap(food.sourceName).isEmpty)
                XCTAssertFalse(try XCTUnwrap(metadata.recordID).isEmpty)
                for number in [food.carbPer100g, food.proteinPer100g, food.fatPer100g, food.caloriesPer100g] {
                    XCTAssertTrue(number.isFinite && number >= 0)
                }
                if metadata.kind == .reference {
                    XCTAssertFalse(try XCTUnwrap(metadata.referenceDescription).isEmpty)
                }
            } else {
                XCTAssertEqual(metadata.kind, .pending)
                XCTAssertNil(food.knownPurinePer100g)
                XCTAssertNil(food.knownLactosePer100g)
            }
        }
    }

    func testVerifiedDumplingScalesAndMixedMissingFiberIsOnlyKnownSubtotal() throws {
        let dumpling = try XCTUnwrap(FoodDatabaseExpansion.foods.first { $0.name == "水饺" })
        let porridge = try XCTUnwrap(FoodDatabaseExpansion.foods.first { $0.name == "小米粥" })
        let item = FoodItem(food: dumpling, grams: 200)
        XCTAssertEqual(item.carbGrams, 28, accuracy: 0.001)
        XCTAssertEqual(item.proteinGrams, 11.6, accuracy: 0.001)
        XCTAssertEqual(item.fatGrams, 18.4, accuracy: 0.001)
        XCTAssertEqual(item.calories, 320, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(item.knownFiberGrams), 2.8, accuracy: 0.001)
        XCTAssertNil(porridge.knownFiberPer100g)
        XCTAssertTrue(porridge.metadata?.fiberBasis?.contains("ND") == true)
        let meal = MealEducationSummary(items: [item, FoodItem(food: porridge, grams: 100)])
        XCTAssertFalse(meal.fiberIsComplete)
        XCTAssertEqual(meal.fiber, 2.8, accuracy: 0.001)
        XCTAssertTrue(meal.fiberText.contains("已知小计"))
    }
}
