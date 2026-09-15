import XCTest
@testable import FoodJourney

@MainActor
final class PersonalFoodTests: XCTestCase {
    private func record(_ name: String = "我的米饭") -> PersonalFood {
        PersonalFood(id: UUID(), revision: 1, name: name, preparation: "熟制",
                     carbs: 25, protein: 3, fat: 1, calories: 121,
                     fiber: nil, lactose: nil, purine: nil)
    }

    func testOnlyCompletePublicFoodsAreSelectableAndCopiesHaveIndependentIdentity() throws {
        let library = FoodLibrary(storageURL: nil)
        XCTAssertEqual(library.foods.count, 27)
        XCTAssertTrue(library.foods.allSatisfy(\.canPreview))
        let rice = try XCTUnwrap(library.foods.first { $0.name == "米饭" })
        let copy = PersonalFood.copy(of: rice)
        let custom = try library.save(copy, editingID: nil)
        XCTAssertNotEqual(custom.catalogID, rice.catalogID)
        XCTAssertTrue(custom.isCustom)
        XCTAssertFalse(rice.isCustom)
        XCTAssertThrowsError(try library.delete(id: rice.id))
        XCTAssertEqual(library.food(with: rice.catalogID)?.carbPer100g, rice.carbPer100g)
        XCTAssertThrowsError(try library.save(copy, editingID: UUID()))
    }

    func testOptionalMissingZeroAndTraceCopyStayDistinct() throws {
        let library = FoodLibrary(storageURL: nil)
        var draft = record()
        let missing = try library.save(draft, editingID: nil)
        XCTAssertNil(missing.knownLactosePer100g)
        XCTAssertNil(missing.knownPurinePer100g)
        draft.lactose = 0
        draft.purine = 0
        let known = try library.save(draft, editingID: draft.id)
        XCTAssertEqual(known.knownLactosePer100g, 0)
        XCTAssertEqual(known.knownPurinePer100g, 0)
        let mixed = MealNutrientMatrix(items: [FoodItem(food: missing, grams: 100), FoodItem(food: known, grams: 100)])
        XCTAssertEqual(mixed.rows.count, 2)
        XCTAssertEqual(mixed.totals.lactose, 0)
        XCTAssertFalse(mixed.totals.lactoseIsComplete)
        let trace = try XCTUnwrap(library.foods.first { $0.catalogID == "egg-fried-rice" })
        XCTAssertNil(PersonalFood.copy(of: trace).lactose)
    }

    func testEditingAndDeletingNeverRewriteMealSnapshotsAndVersionsCountAsOneFood() throws {
        let library = FoodLibrary(storageURL: nil)
        let session = DigestionSession()
        var draft = record()
        let first = try library.save(draft, editingID: nil)
        XCTAssertTrue(session.recordEducation(FoodItem(food: first, grams: 100)))
        draft.carbs = 40
        let second = try library.save(draft, editingID: draft.id)
        XCTAssertTrue(session.recordEducation(FoodItem(food: second, grams: 100)))
        XCTAssertThrowsError(try library.save(draft, editingID: draft.id), "Stale editors must not overwrite a newer version")
        try library.delete(id: draft.id)
        let meal = MealEducationSummary(items: session.items)
        XCTAssertEqual(meal.carbs, 65)
        XCTAssertEqual(meal.distinctFoodCount, 1)
        XCTAssertEqual(session.distinctFoodCount, 1)
        XCTAssertEqual(meal.matrix.rows.map(\.carbs), [25, 40])
        XCTAssertEqual(meal.matrix.rows.map(\.food.revision), [1, 2])
        XCTAssertNil(library.food(with: first.catalogID))
    }

    func testRecentsUpdateOnlyOnIngestionAndSurviveMealReset() throws {
        let library = FoodLibrary(storageURL: nil)
        let vm = LiveSessionViewModel(library: library)
        let custom = try library.save(record(), editingID: nil)
        vm.selectedFood = custom
        XCTAssertTrue(library.recentIDs.isEmpty)
        vm.eatIn()
        vm.advance(by: 8)
        let expected = [custom.catalogID]
        XCTAssertEqual(library.recentIDs, expected)
        vm.replay()
        vm.advance(by: 8)
        XCTAssertEqual(library.recentIDs, expected)
        vm.reset()
        XCTAssertEqual(library.recentIDs, expected)
        XCTAssertEqual(library.personalFoods.count, 1)
        try library.delete(id: try XCTUnwrap(custom.customID))
        XCTAssertTrue(library.recentIDs.isEmpty)
        XCTAssertEqual(library.quickFoods.count, 3)
    }

    func testPersistenceAndCorruptFilesAreNotOverwritten() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("FoodJourneyTest-\(UUID().uuidString)")
        let url = folder.appendingPathComponent("foods.json")
        defer { try? FileManager.default.removeItem(at: folder) }
        let library = FoodLibrary(storageURL: url)
        let custom = try library.save(record(), editingID: nil)
        library.recordUse(custom)
        let reloaded = FoodLibrary(storageURL: url)
        XCTAssertEqual(reloaded.personalFoods.first?.id, custom.customID)
        XCTAssertEqual(reloaded.recentIDs, [custom.catalogID])
        let damaged = Data("invalid-json".utf8)
        try damaged.write(to: url)
        let corrupt = FoodLibrary(storageURL: url)
        XCTAssertNotNil(corrupt.storageMessage)
        XCTAssertThrowsError(try corrupt.save(record(), editingID: nil))
        XCTAssertEqual(try Data(contentsOf: url), damaged)
    }

    func testRejectsInvalidAmountsAndNamesWithoutSaving() {
        let library = FoodLibrary(storageURL: nil)
        var invalid = record(" ")
        XCTAssertThrowsError(try library.save(invalid, editingID: nil))
        invalid.name = "食物"
        invalid.carbs = .infinity
        XCTAssertThrowsError(try library.save(invalid, editingID: nil))
        invalid.carbs = 99
        invalid.fat = 20
        XCTAssertThrowsError(try library.save(invalid, editingID: nil))
        invalid.carbs = 20
        invalid.fat = 1
        invalid.lactose = -1
        XCTAssertThrowsError(try library.save(invalid, editingID: nil))
        XCTAssertTrue(library.personalFoods.isEmpty)
    }

    func testLegacyPreferencesDropDiseasesAndUnsupportedFocus() throws {
        let suite = "FoodJourneyPreferencesTest-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let legacy: [String: Any] = ["hasCompletedOnboarding": true, "hasChronicCondition": true,
                                     "conditions": ["胃食管反流病"], "focus": "反流与进食"]
        defaults.set(try JSONSerialization.data(withJSONObject: legacy), forKey: "FoodJourney.UserPreferences.v1")
        let prefs = UserPreferences(defaults: defaults)
        XCTAssertTrue(prefs.hasCompletedOnboarding)
        XCTAssertEqual(prefs.focus, .general)
        XCTAssertNil(defaults.data(forKey: "FoodJourney.UserPreferences.v1"))
        let data = try XCTUnwrap(defaults.data(forKey: "FoodJourney.UserPreferences.v2"))
        let stored = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(stored.keys), ["hasCompletedOnboarding", "focus"])
        XCTAssertFalse(HealthFocus.available.contains(.reflux))
        XCTAssertFalse(HealthFocus.available.contains(.sodium))
        XCTAssertEqual(HealthFocus.insulin.supported, .bloodSugar)
    }
}
