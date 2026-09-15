import XCTest
@testable import FoodJourney

@MainActor
final class FoodMetadataTests: XCTestCase {
    private func food(_ name: String, kind: FoodMetadata.Kind = .direct, fiber: Double? = nil) -> Food {
        Food(name: name, nutrients: [.carb], carbPer100g: 20, fatPer100g: 0,
             proteinPer100g: 2, caloriesPer100g: 88,
             metadata: FoodMetadata(kind: kind, preparation: "熟制示例", fiberPer100g: fiber))
    }

    func testMissingAndExplicitZeroAreDifferentAndScaleWithPortion() {
        let missing = FoodItem(food: food("未提供"), grams: 200)
        let zero = FoodItem(food: food("明确为零", fiber: 0), grams: 200)
        let known = FoodItem(food: food("已提供", fiber: 1.5), grams: 200)
        XCTAssertNil(missing.knownFiberGrams)
        XCTAssertNil(missing.knownPurineMg)
        XCTAssertNil(missing.knownLactoseGrams)
        XCTAssertEqual(zero.knownFiberGrams, 0)
        XCTAssertEqual(known.knownFiberGrams, 3)
        let partial = MealEducationSummary(items: [known, missing])
        XCTAssertEqual(partial.fiber, 3)
        XCTAssertFalse(partial.fiberIsComplete)
        XCTAssertEqual(partial.missingFiberFoods, ["未提供"])
        XCTAssertTrue(partial.fiberText.contains("已知小计"))
        XCTAssertEqual(MealEducationSummary(items: [missing]).fiberText, "未提供")
        XCTAssertTrue(MealEducationSummary(items: [zero]).fiberIsComplete)
        let journey = MealDigestionJourney(item: missing)
        XCTAssertEqual(journey.calloutData(for: .largeIntestine), "纤维未提供")
        XCTAssertFalse(journey.outcome(for: .largeIntestine)!.process.contains("不含纤维"))
    }

    func testPendingOrIncompleteMacrosCannotEnterEducationalSession() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = food("待查配方", kind: .pending)
        XCTAssertFalse(vm.canEat)
        vm.eatIn()
        XCTAssertTrue(vm.session.items.isEmpty)
        XCTAssertNil(vm.journey)
        let incomplete = Food(name: "缺宏量数据", nutrients: [], metadata: FoodMetadata(kind: .reference, preparation: "待补充"))
        XCTAssertFalse(incomplete.canPreview)
        XCTAssertFalse(vm.session.recordEducation(FoodItem(food: incomplete, grams: 100)))
    }

    func testEducationWithUnknownPurineNeverRunsLegacyEngineAndRemovalDoesNotReplayIt() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = food("嘌呤未提供")
        vm.eatIn()
        vm.advance(by: 8)
        vm.selectedGrams = 200
        vm.eatIn()
        vm.advance(by: 8)
        XCTAssertEqual(vm.session.foodCount, 2)
        XCTAssertTrue(vm.session.results.isEmpty)
        XCTAssertTrue(vm.session.residues.isEmpty)
        XCTAssertTrue(vm.bubbles.isEmpty)
        XCTAssertEqual(vm.session.usageRatio(.kidney), 0)
        vm.removeEaten(at: 0)
        XCTAssertEqual(vm.session.items.map(\.grams), [200])
        XCTAssertTrue(vm.session.results.isEmpty)
        vm.replay()
        XCTAssertEqual(vm.session.foodCount, 1)
        vm.reset()
        XCTAssertEqual(vm.session.foodCount, 0)
    }

    func testInvalidAuxiliaryDataIsUnknownAndReferenceExplanationIsRetained() {
        let metadata = FoodMetadata(kind: .reference, recordID: "record-1", preparation: "熟制",
                                    referenceDescription: "相近食物参考，配方不同", fiberBasis: "原始结果ND未检出",
                                    fiberPer100g: -.infinity, lactosePer100g: -1, purinePer100g: .nan)
        XCTAssertNil(metadata.fiberPer100g)
        XCTAssertNil(metadata.lactosePer100g)
        XCTAssertNil(metadata.purinePer100g)
        XCTAssertEqual(metadata.recordID, "record-1")
        XCTAssertEqual(metadata.referenceDescription, "相近食物参考，配方不同")
        XCTAssertEqual(metadata.fiberBasis, "原始结果ND未检出")
    }
}
