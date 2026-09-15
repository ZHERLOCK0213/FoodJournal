import XCTest
@testable import FoodJourney

@MainActor
final class UrateEducationTests: XCTestCase {
    private func item(_ name: String) -> FoodItem {
        FoodItem(food: FoodDatabase.allFoods.first { $0.name == name }!, grams: 100)
    }

    func testUrateFocusShowsChickenEducationEvenWithZeroCarbohydrates() throws {
        let meal = MealEducationSummary(items: [item("鸡胸肉")])
        XCTAssertEqual(meal.carbs, 0)
        let education = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: meal))
        XCTAssertTrue(education.context.contains("368.6mg"))
        XCTAssertFalse(education.context.contains("尚不完整"))
        XCTAssertTrue(education.kidneyExplanation.contains("肠道也参与排出"))
        XCTAssertTrue(education.hydrationGuidance.contains("如需限水"))
        XCTAssertTrue(education.limitation.contains("不能直接换算"))
    }

    func testOtherFocusesAndEmptyMealsHaveNoMealSpecificUrateHint() {
        let meal = MealEducationSummary(items: [item("鸡胸肉")])
        for focus in HealthFocus.allCases where focus != .uricAcid {
            XCTAssertNil(UrateEducation(focus: focus, meal: meal))
        }
        XCTAssertNil(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: [])))
    }

    func testFoodNamesDoNotTriggerSeparateDietRules() throws {
        for name in ["鸡胸肉", "红烧肉", "豆腐", "西兰花", "鸡蛋", "牛奶"] {
            let education = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: [item(name)])))
            XCTAssertNil(education.dietGuidance)
            XCTAssertFalse(education.context.contains(name))
        }
    }

    func testCapturedEducationSurvivesSelectionChangesAndResetRemovesNewHint() throws {
        let meal = Meal()
        meal.items = [item("鸡胸肉")]
        let captured = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: meal.items)))
        meal.items = [item("馒头")]
        let updated = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: meal.items)))
        XCTAssertTrue(captured.context.contains("368.6mg"))
        XCTAssertNotEqual(captured.context, updated.context)
        meal.items.removeAll()
        XCTAssertNil(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: meal.items)))
    }

    func testEducationDoesNotTurnPortionSizeIntoPersonalUrateOutput() throws {
        let small = item("鸡胸肉")
        var large = small
        large.grams = 500
        let first = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: [small])))
        let second = try XCTUnwrap(UrateEducation(focus: .uricAcid, meal: MealEducationSummary(items: [large])))
        XCTAssertTrue(first.context.contains("368.6mg"))
        XCTAssertTrue(second.context.contains((368.6 * 5).formatted(.number.precision(.fractionLength(1))) + "mg"))
        XCTAssertTrue(second.limitation.contains("不能直接换算"))
        XCTAssertEqual(first.kidneyExplanation, second.kidneyExplanation)
        XCTAssertEqual(first.sources.count, Set(first.sources.map(\.id)).count)
        XCTAssertTrue(first.sources.allSatisfy { $0.url.scheme == "https" })
    }
}
