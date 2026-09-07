import XCTest
@testable import FoodJourney

@MainActor
final class DigestionSessionTests: XCTestCase {

    func testIngestAccumulatesFoodAndConsumesCapacity() throws {
        let rice = try food(named: "米饭")
        let session = DigestionSession()

        let result = session.ingest(FoodItem(food: rice, grams: 100))

        XCTAssertEqual(session.foodCount, 1)
        XCTAssertEqual(session.totalCalories, 130, accuracy: 0.001)
        XCTAssertEqual(result.absorbedGlucoseG, 28, accuracy: 0.001)
        XCTAssertEqual(session.usageRatio(.stomach), 0.3, accuracy: 0.001)
        XCTAssertEqual(session.usageRatio(.smallIntestine), 0.155, accuracy: 0.001)
        XCTAssertTrue(session.capacities.values.allSatisfy { $0 >= 0 })
    }

    func testRemovingItemReplaysRemainingItemsFromFreshSession() throws {
        let rice = try food(named: "米饭")
        let salmon = try food(named: "三文鱼")
        let session = DigestionSession()
        _ = session.ingest(FoodItem(food: rice, grams: 100))
        _ = session.ingest(FoodItem(food: salmon, grams: 100))

        session.remove(at: 0)

        let expected = DigestionSession()
        let expectedResult = expected.ingest(FoodItem(food: salmon, grams: 100))
        XCTAssertEqual(session.foodCount, 1)
        XCTAssertEqual(session.items.map(\.food.name), ["三文鱼"])
        XCTAssertEqual(session.totalCalories, expectedResult.calories, accuracy: 0.001)
        XCTAssertEqual(session.totalUricAcidProducedMg, expectedResult.uricAcidProducedMg, accuracy: 0.001)
        for organ in DigestiveOrgan.allCases where organ.initialCapacity > 0 {
            let actualCapacity = try XCTUnwrap(session.capacities[organ])
            let expectedCapacity = try XCTUnwrap(expected.capacities[organ])
            XCTAssertEqual(actualCapacity, expectedCapacity, accuracy: 0.001)
        }
    }

    func testResetClearsAccumulatedSessionState() throws {
        let chicken = try food(named: "鸡胸肉")
        let session = DigestionSession()
        _ = session.ingest(FoodItem(food: chicken, grams: 100))

        session.reset()

        XCTAssertEqual(session.foodCount, 0)
        XCTAssertTrue(session.items.isEmpty)
        XCTAssertTrue(session.results.isEmpty)
        XCTAssertTrue(session.residues.isEmpty)
        for organ in DigestiveOrgan.allCases where organ.initialCapacity > 0 {
            let capacity = try XCTUnwrap(session.capacities[organ])
            XCTAssertEqual(capacity, organ.initialCapacity, accuracy: 0.001)
        }
    }

    func testFiberCreatesStructuralResidueInLargeIntestine() throws {
        let broccoli = try food(named: "西兰花")
        let session = DigestionSession()

        let result = session.ingest(FoodItem(food: broccoli, grams: 100))

        let fiber = try XCTUnwrap(result.residues.first { $0.substance == "膳食纤维" })
        XCTAssertEqual(fiber.organ, .largeIntestine)
        guard case .structural = fiber.kind else {
            return XCTFail("膳食纤维应为结构性残留")
        }
        XCTAssertEqual(fiber.amount, 2.6, accuracy: 0.001)
    }

    func testUricAcidUsesPurineInsteadOfProteinAmount() throws {
        let salmon = try food(named: "三文鱼")
        let chicken = try food(named: "鸡胸肉")
        let salmonResult = DigestionSession().ingest(FoodItem(food: salmon, grams: 100))
        let chickenResult = DigestionSession().ingest(FoodItem(food: chicken, grams: 100))

        XCTAssertLessThan(salmon.proteinPer100g, chicken.proteinPer100g)
        XCTAssertGreaterThan(salmon.purinePer100g, chicken.purinePer100g)
        XCTAssertGreaterThan(salmonResult.uricAcidProducedMg, chickenResult.uricAcidProducedMg)
    }

    private func food(named name: String) throws -> Food {
        try XCTUnwrap(FoodDatabase.allFoods.first { $0.name == name }, "缺少测试食物：\(name)")
    }
}
