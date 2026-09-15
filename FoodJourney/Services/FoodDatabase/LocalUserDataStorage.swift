import Foundation

/// Inject a storage instance belonging to one owner. No account or network is assumed here.
protocol FoodLibraryStorage {
    func load() throws -> Data?
    func save(_ data: Data) throws
}

struct FileFoodLibraryStorage: FoodLibraryStorage {
    let url: URL
    func load() throws -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try Data(contentsOf: url)
    }
    func save(_ data: Data) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
}

final class MemoryFoodLibraryStorage: FoodLibraryStorage {
    private var data: Data?
    func load() throws -> Data? { data }
    func save(_ data: Data) throws { self.data = data }
}

/// A future account-scoped cache can replace UserDefaults without changing preference rules.
protocol LearningPreferencesStorage {
    func data(forKey key: String) -> Data?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: LearningPreferencesStorage {}
