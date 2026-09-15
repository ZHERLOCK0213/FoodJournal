import XCTest
@testable import FoodJourney

@MainActor
final class MealEducationSummaryTests: XCTestCase {
    private func item(_ name: String, _ grams: Double = 100) -> FoodItem {
        FoodItem(food: FoodDatabase.allFoods.first { $0.name == name }!, grams: grams)
    }

    func testPorkAndBunReportSummarizesInputsInsteadOfHormoneOutput() {
        let meal = MealEducationSummary(items: [item("红烧肉"), item("馒头")])
        XCTAssertEqual(meal.foodCount, 2)
        XCTAssertEqual(meal.grams, 200)
        XCTAssertEqual(meal.carbs, 50, accuracy: 0.001)
        XCTAssertEqual(meal.protein, 22, accuracy: 0.001)
        XCTAssertEqual(meal.fat, 31.1, accuracy: 0.001)
        XCTAssertEqual(meal.fiber, 1.3, accuracy: 0.001)
        XCTAssertEqual(meal.calories, 573, accuracy: 0.001)
        XCTAssertTrue(PancreasRole.glucose.context(for: meal).contains("50.0g"))
        XCTAssertTrue(PancreasRole.glucose.context(for: meal).contains("不是血糖升幅"))
    }

    func testSixHundredGramBunUsesVerifiedFatAndInsolubleFiberInputs() {
        let meal = MealEducationSummary(items: [item("馒头", 600)])
        XCTAssertEqual(meal.fat, 6.6, accuracy: 0.001)
        XCTAssertEqual(meal.fiber, 7.8, accuracy: 0.001)
    }

    func testReportDoesNotPlateauAtLegacyCapacityAndRecomputesAfterRemoval() {
        let session = DigestionSession()
        for _ in 0..<3 { session.ingest(item("馒头", 300)) }
        XCTAssertEqual(session.usageRatio(.pancreas), 1)
        XCTAssertEqual(MealEducationSummary(items: session.items).carbs, 423, accuracy: 0.001)
        session.remove(at: 0)
        XCTAssertEqual(MealEducationSummary(items: session.items).carbs, 282, accuracy: 0.001)
        session.reset()
        XCTAssertEqual(MealEducationSummary(items: session.items).carbs, 0)
    }

    func testZeroCarbChickenStillHasDigestionAndDoesNotClaimZeroInsulin() {
        let meal = MealEducationSummary(items: [item("鸡胸肉", 200)])
        XCTAssertTrue(meal.hasDigestibleNutrients)
        XCTAssertEqual(meal.carbs, 0)
        XCTAssertTrue(PancreasRole.digestion.context(for: meal).contains("蛋白质"))
        XCTAssertTrue(PancreasRole.glucose.context(for: meal).contains("不等于胰岛素分泌为零"))
        let journey = MealDigestionJourney(item: item("鸡胸肉", 200))
        XCTAssertTrue(journey.outcome(for: .pancreas)!.result.contains("分泌量未估算"))
    }

    func testEmptySummaryDoesNotPresentMealSpecificResponse() {
        let meal = MealEducationSummary(items: [])
        XCTAssertEqual(meal.foodCount, 0)
        XCTAssertFalse(meal.hasDigestibleNutrients)
        XCTAssertEqual(meal.calories, 0)
        for role in PancreasRole.allCases {
            XCTAssertTrue(role.context(for: meal).contains("一般机制"))
        }
    }

    func testBothRolesHaveThreeDistinctStepsAndHTTPSPrimarySources() {
        for role in PancreasRole.allCases {
            XCTAssertEqual(role.steps.map(\.id), [0, 1, 2])
            XCTAssertEqual(Set(role.steps.map(\.title)).count, 3)
            XCTAssertEqual(role.source.scheme, "https")
            XCTAssertEqual(role.source.host, "www.niddk.nih.gov")
        }
        XCTAssertTrue(PancreasRole.digestion.steps[1].detail.contains("食团不进入胰腺"))
        XCTAssertTrue(PancreasRole.glucose.steps[1].detail.contains("血液"))
    }

    func testNarrativeWindowsUseCapturedMealAndClearAtCompletion() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = item("馒头").food
        vm.eatIn()
        XCTAssertNil(vm.pancreasRoleDuringPreview)
        vm.advance(by: 1.2 + 6 * 0.2)
        XCTAssertEqual(vm.pancreasRoleDuringPreview, .digestion)
        vm.selectedFood = item("鸡胸肉").food
        vm.advance(by: 6 * 0.3)
        XCTAssertEqual(vm.pancreasRoleDuringPreview, .glucose)
        vm.advance(by: 6)
        XCTAssertNil(vm.pancreasRoleDuringPreview)
        vm.replay()
        vm.advance(by: 1.2 + 6 * 0.5)
        XCTAssertEqual(vm.pancreasRoleDuringPreview, .glucose)
        XCTAssertEqual(vm.session.foodCount, 1)
        vm.reset()
        XCTAssertNil(vm.pancreasRoleDuringPreview)
    }

    func testChickenDoesNotAutomaticallyReplayCarbAbsorptionNarration() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = item("鸡胸肉").food
        vm.eatIn()
        vm.advance(by: 1.2 + 6 * 0.2)
        XCTAssertEqual(vm.pancreasRoleDuringPreview, .digestion)
        vm.advance(by: 6 * 0.3)
        XCTAssertNil(vm.pancreasRoleDuringPreview)
        vm.reset()
    }
}
