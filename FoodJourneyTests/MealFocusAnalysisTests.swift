import XCTest
@testable import FoodJourney

@MainActor
final class MealFocusAnalysisTests: XCTestCase {
    private func food(_ name: String) throws -> Food {
        try XCTUnwrap(FoodDatabase.allFoods.first { $0.name == name })
    }

    func testUserExampleUsesEveryPortionAndRanksFatContributors() throws {
        let items = try [("红烧肉", 300.0), ("米饭", 300), ("小笼包（猪肉）", 200), ("炒花生", 100)]
            .map { FoodItem(food: try food($0.0), grams: $0.1) }
        let analysis = try XCTUnwrap(MealFocusAnalysis(items: items, focus: .lipids))
        XCTAssertEqual(try XCTUnwrap(analysis.total), 166.9, accuracy: 0.001)
        XCTAssertEqual(analysis.attention, .stopAdding)
        XCTAssertEqual(analysis.contributors.count, 4)
        for (actual, expected) in zip(analysis.contributors.map(\.amount), [90.0, 48, 28, 0.9]) {
            XCTAssertEqual(actual, expected, accuracy: 0.001)
        }
        XCTAssertTrue(analysis.reference?.contains("／日") == true)
        XCTAssertTrue(analysis.action.contains("无需停止所有进食"))
    }

    func testNoInventedLowRiskOrNearUpperLimitBands() throws {
        let source = try food("红烧肉")
        for fat in [0.0, 1, 56, 69.9] {
            let analysis = try XCTUnwrap(MealFocusAnalysis(items: [FoodItem(food: source, grams: fat / source.fatPer100g * 100)], focus: .lipids))
            XCTAssertEqual(analysis.attention, .ungraded)
        }
        let boundary = try XCTUnwrap(MealFocusAnalysis(items: [FoodItem(food: source, grams: 70 / source.fatPer100g * 100)], focus: .lipids))
        XCTAssertEqual(boundary.attention, .stopAdding)
        XCTAssertNil(MealFocusAnalysis(items: [], focus: .lipids))
        XCTAssertNil(MealFocusAnalysis(items: [FoodItem(food: source, grams: 100)], focus: .general))
    }

    func testMissingPurinesNeverBecomeZeroOrSafe() throws {
        let missing = PersonalFood(id: UUID(), revision: 1, name: "未填写食物", preparation: "",
                                   carbs: 10, protein: 10, fat: 10, calories: 170,
                                   fiber: nil, lactose: nil, purine: nil).food
        let empty = try XCTUnwrap(MealFocusAnalysis(items: [FoodItem(food: missing, grams: 100)], focus: .uricAcid))
        XCTAssertNil(empty.total)
        XCTAssertEqual(empty.attention, .ungraded)
        let items = [FoodItem(food: missing, grams: 100), FoodItem(food: try food("红烧肉"), grams: 100)]
        let partial = try XCTUnwrap(MealFocusAnalysis(items: items, focus: .uricAcid))
        XCTAssertEqual(partial.missingFoods, ["未填写食物"])
        XCTAssertTrue(partial.totalText.contains("已记录小计"))
        XCTAssertEqual(partial.attention, .ungraded)
    }

    func testLactoseTraceAndZeroRemainDistinctAndUngraded() throws {
        let trace = try XCTUnwrap(FoodDatabase.allFoods.first { $0.catalogID == "egg-fried-rice" })
        let analysis = try XCTUnwrap(MealFocusAnalysis(items: [FoodItem(food: trace, grams: 100)], focus: .lactose))
        XCTAssertTrue(analysis.hasTrace)
        XCTAssertTrue(analysis.totalText.contains("微量"))
        XCTAssertTrue(analysis.missingFoods.isEmpty)
        XCTAssertEqual(analysis.attention, .ungraded)
    }

    func testPreferenceMigrationHydrationPersistenceAndIndependentAssessment() throws {
        let suite = "FoodJourneyHydrationTest-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(Data(#"{"hasCompletedOnboarding":true,"focus":"尿酸"}"#.utf8),
                     forKey: "FoodJourney.UserPreferences.v2")
        let prefs = UserPreferences(defaults: defaults)
        XCTAssertEqual(prefs.hydration, .unknown)
        let items = [FoodItem(food: try food("红烧肉"), grams: 100)]
        let baseline = try XCTUnwrap(MealFocusAnalysis(items: items, focus: prefs.focus))
        for hydration in DailyHydration.allCases {
            prefs.hydration = hydration
            XCTAssertEqual(UserPreferences(defaults: defaults).hydration, hydration)
            let next = try XCTUnwrap(MealFocusAnalysis(items: items, focus: prefs.focus))
            XCTAssertEqual(next.total, baseline.total)
            XCTAssertEqual(next.attention, baseline.attention)
        }
        XCTAssertTrue(DailyHydration.medicallyRestricted.guidance.contains("不按一般饮水建议自行增加"))
    }

    func testInjectedStoresAreIsolatedAndSaveFailuresDoNotCommit() throws {
        let firstStore = MemoryFoodLibraryStorage()
        let first = FoodLibrary(storage: firstStore)
        let second = FoodLibrary(storage: MemoryFoodLibraryStorage())
        let record = PersonalFood.copy(of: try food("米饭"))
        try first.save(record, editingID: nil)
        XCTAssertEqual(FoodLibrary(storage: firstStore).personalFoods.count, 1)
        XCTAssertTrue(second.personalFoods.isEmpty)
        let failing = FoodLibrary(storage: RejectingStorage())
        XCTAssertThrowsError(try failing.save(record, editingID: nil))
        XCTAssertTrue(failing.personalFoods.isEmpty)
    }

    private struct RejectingStorage: FoodLibraryStorage {
        func load() throws -> Data? { nil }
        func save(_ data: Data) throws { throw CocoaError(.fileWriteOutOfSpace) }
    }
}
