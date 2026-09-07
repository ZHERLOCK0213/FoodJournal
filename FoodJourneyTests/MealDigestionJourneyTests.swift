import XCTest
@testable import FoodJourney

@MainActor
final class MealDigestionJourneyTests: XCTestCase {
    private var chicken: Food { FoodDatabase.allFoods.first { $0.name == "鸡胸肉" }! }

    func testChicken200IncludesPancreasAndLargeIntestineWithoutCarbsOrFiber() {
        let journey = MealDigestionJourney(item: FoodItem(food: chicken, grams: 200))
        XCTAssertEqual(journey.item.proteinGrams, chicken.proteinPer100g * 2)
        XCTAssertEqual(journey.item.carbGrams, 0)
        XCTAssertNotNil(journey.outcome(for: .pancreas))
        XCTAssertNotNil(journey.outcome(for: .largeIntestine))
        XCTAssertTrue(journey.outcome(for: .smallIntestine)!.result.contains("氨基酸"))
        XCTAssertFalse(journey.outcome(for: .smallIntestine)!.result.contains("吸收单糖"))
        XCTAssertTrue(journey.outcome(for: .kidneys)!.result.contains("不是食团通道"))
        XCTAssertEqual(Set(journey.outcomes.map(\.part)).count, journey.outcomes.count)
    }

    func testPureCarbDoesNotClaimProteinDigestionOrBileResult() {
        let journey = MealDigestionJourney(item: FoodItem(food: Food(name: "淀粉示例", nutrients: [.carb], carbPer100g: 100), grams: 50))
        XCTAssertEqual(journey.item.carbGrams, 50)
        XCTAssertFalse(journey.outcome(for: .stomach)!.process.contains("蛋白质"))
        XCTAssertNil(journey.outcome(for: .gallbladder))
        XCTAssertEqual(journey.outcome(for: .smallIntestine)!.badge, "吸收单糖")
    }

    func testCompletionSnapshotAndReplayDoNotIngestTwice() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = chicken; vm.selectedGrams = 200
        vm.eatIn()
        XCTAssertNil(vm.completedJourneyID)
        XCTAssertEqual(vm.journey?.item.grams, 200)
        vm.selectedGrams = 50
        vm.selectedFood = FoodDatabase.allFoods.first
        vm.advance(by: 7.3)
        XCTAssertEqual(vm.phase, .idle)
        XCTAssertEqual(vm.completedJourneyID, vm.journey?.id)
        XCTAssertEqual(vm.journey?.item.grams, 200)
        XCTAssertEqual(vm.journey?.item.food.name, "鸡胸肉")
        vm.replay()
        XCTAssertNil(vm.completedJourneyID)
        XCTAssertEqual(vm.session.foodCount, 1)
        vm.advance(by: 7.3)
        XCTAssertNotNil(vm.completedJourneyID)
        XCTAssertEqual(vm.session.foodCount, 1)
        vm.reset()
        XCTAssertNil(vm.journey)
        XCTAssertNil(vm.completedJourneyID)
        XCTAssertTrue(vm.foodParticlePositions.isEmpty)
    }

    func testFoodParticlesReachIntestinesIndependentlyOfFocus() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = chicken; vm.selectedGrams = 200; vm.eatIn()
        vm.advance(by: 1.2 + 6 * 0.55)
        XCTAssertEqual(vm.phase, .digesting)
        XCTAssertFalse(vm.foodParticlePositions.isEmpty)
        XCTAssertTrue(vm.foodParticlePositions.contains { AnatomyArtwork.asset(.smallIntestine).path.contains($0) })
        XCTAssertFalse(vm.foodParticlePositions.contains { AnatomyArtwork.asset(.stomach).path.contains($0) })
        vm.advance(by: 6 * 0.3)
        XCTAssertTrue(vm.foodParticlePositions.contains { AnatomyArtwork.asset(.largeIntestine).path.contains($0) })
        vm.reset()
    }

    func testNextMealAndRemovalClearStaleSummary() {
        let vm = LiveSessionViewModel()
        vm.selectedFood = chicken; vm.eatIn(); vm.advance(by: 8)
        let first = vm.completedJourneyID
        vm.selectedGrams = 200; vm.eatIn()
        XCTAssertNil(vm.completedJourneyID)
        XCTAssertNotEqual(vm.journey?.id, first)
        XCTAssertEqual(vm.journey?.item.grams, 200)
        vm.removeEaten(at: 0)
        XCTAssertNil(vm.journey)
        XCTAssertNil(vm.completedJourneyID)
        XCTAssertEqual(vm.phase, .idle)
    }
}
