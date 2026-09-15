import Foundation
import Observation

@Observable
final class FoodLibrary {
    private(set) var personalFoods: [PersonalFood] = []
    private(set) var recentIDs: [String] = []
    private(set) var revision = 0
    var storageMessage: String?
    private var loadFailed = false
    private let storage: any FoodLibraryStorage

    private struct Stored: Codable {
        var version = 1
        let foods: [PersonalFood]
        let recentIDs: [String]
    }

    /// nil storage is an isolated in-memory library, also used by UI tests.
    convenience init(storageURL: URL? = FoodLibrary.defaultStorageURL) {
        if let storageURL {
            self.init(storage: FileFoodLibraryStorage(url: storageURL))
        } else {
            self.init(storage: MemoryFoodLibraryStorage())
        }
    }

    init(storage: any FoodLibraryStorage) {
        self.storage = storage
        do {
            guard let data = try storage.load() else { return }
            let stored = try JSONDecoder().decode(Stored.self, from: data)
            guard stored.version == 1,
                  Set(stored.foods.map(\.id)).count == stored.foods.count,
                  stored.foods.allSatisfy({ $0.validationError == nil }) else { throw LibraryError.invalid }
            personalFoods = stored.foods
            var seen = Set<String>()
            recentIDs = stored.recentIDs.filter { seen.insert($0).inserted }
        } catch {
            loadFailed = true
            storageMessage = "本机食物数据无法读取，原文件未改动。公共食物仍可使用。"
        }
    }

    static var defaultStorageURL: URL? {
        guard !ProcessInfo.processInfo.arguments.contains("-uiTesting") else { return nil }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("FoodJourney", isDirectory: true).appendingPathComponent("personal-foods.json")
    }

    var foods: [Food] { FoodDatabase.allFoods.filter(\.canPreview) + personalFoods.map(\.food) }
    func food(with id: String) -> Food? { foods.first { $0.catalogID == id } }
    func personalFood(id: UUID) -> PersonalFood? { personalFoods.first { $0.id == id } }
    var quickFoods: [Food] {
        let recent = recentIDs.compactMap { food(with: $0) }
        // Fill unused slots only; actual recent foods are always first.
        let fallback = FoodDatabase.allFoods.filter { $0.canPreview && !recentIDs.contains($0.catalogID) }
        return Array((recent + fallback).prefix(3))
    }

    @discardableResult
    func save(_ proposed: PersonalFood, editingID: UUID?) throws -> Food {
        if let message = proposed.validationError { throw LibraryError.message(message) }
        var next = personalFoods
        var record = proposed
        record.name = record.name.trimmingCharacters(in: .whitespacesAndNewlines)
        record.preparation = record.preparation.trimmingCharacters(in: .whitespacesAndNewlines)
        if let editingID {
            // Only an existing personal UUID may be edited. Public IDs cannot enter this path.
            guard record.id == editingID, let index = next.firstIndex(where: { $0.id == editingID }) else { throw LibraryError.invalid }
            guard record.revision == next[index].revision, record.revision < Int.max else {
                throw LibraryError.message("这项食物已更新，请重新打开后编辑。")
            }
            record.revision += 1
            next[index] = record
        } else {
            guard !next.contains(where: { $0.id == record.id }) else { throw LibraryError.invalid }
            record.revision = 1
            next.append(record)
        }
        try persist(foods: next, recents: recentIDs)
        personalFoods = next
        revision += 1
        return record.food
    }

    func delete(id: UUID) throws {
        guard let existing = personalFood(id: id) else { throw LibraryError.invalid }
        let next = personalFoods.filter { $0.id != id }
        let recents = recentIDs.filter { $0 != existing.food.catalogID }
        try persist(foods: next, recents: recents)
        personalFoods = next
        recentIDs = recents
        revision += 1
    }

    func recordUse(_ food: Food) {
        guard self.food(with: food.catalogID) != nil else { return }
        let next = Array(([food.catalogID] + recentIDs.filter { $0 != food.catalogID }).prefix(3))
        do {
            try persist(foods: personalFoods, recents: next)
            recentIDs = next
        } catch { storageMessage = error.localizedDescription }
    }

    func clearRecent() throws {
        try persist(foods: personalFoods, recents: [])
        recentIDs = []
    }

    private func persist(foods: [PersonalFood], recents: [String]) throws {
        guard !loadFailed else { throw LibraryError.message("本机食物数据无法读取。为保护原文件，未保存改动。") }
        do {
            let data = try JSONEncoder().encode(Stored(foods: foods, recentIDs: recents))
            try storage.save(data)
        } catch { throw LibraryError.message("未能保存到本机，请检查可用存储空间后重试。") }
    }

    enum LibraryError: LocalizedError {
        case invalid, message(String)
        var errorDescription: String? {
            switch self {
            case .invalid: "食物记录无效，无法保存。"
            case .message(let text): text
            }
        }
    }
}
