import Foundation
import Observation

enum HealthFocus: String, CaseIterable, Identifiable, Codable {
    // Raw values remain stable for migration; display titles do not imply clinical predictions.
    case general = "一般了解"
    case bloodSugar = "血糖"
    case uricAcid = "尿酸"
    case insulin = "胰岛素"
    case calories = "热量"
    case sodium = "钠与血压"
    case lipids = "脂肪与血脂"
    case reflux = "反流与进食"
    case lactose = "乳糖消化"

    var id: String { rawValue }
    static var available: [HealthFocus] { [.general, .bloodSugar, .lipids, .calories, .lactose, .uricAcid] }
    var supported: HealthFocus {
        switch self {
        case .sodium, .reflux: .general
        case .insulin: .bloodSugar
        default: self
        }
    }
    var title: String {
        switch supported {
        case .general: "无特别关注"
        case .bloodSugar: "碳水消化"
        case .lipids: "脂肪消化"
        case .uricAcid: "嘌呤与尿酸"
        default: supported.rawValue
        }
    }
    var metricID: String? {
        switch supported {
        case .bloodSugar: "carbs"
        case .lipids: "fat"
        case .calories: "calories"
        case .lactose: "lactose"
        case .uricAcid: "purine"
        default: nil
        }
    }
    var focusOrgans: [DigestiveOrgan] {
        switch supported {
        case .bloodSugar: [.pancreas]
        case .uricAcid: [.kidney]
        case .calories, .lipids: [.liver, .smallIntestine]
        case .lactose: [.smallIntestine, .largeIntestine]
        default: []
        }
    }
}

/// Local learning preferences only. The v1 disease-selection payload is removed after migration.
@Observable
final class UserPreferences {
    var hasCompletedOnboarding: Bool { didSet { save() } }
    var focus: HealthFocus { didSet { save() } }
    var hydration: DailyHydration { didSet { save() } }
    private let defaults: any LearningPreferencesStorage
    private static let storageKey = "FoodJourney.UserPreferences.v2"
    private static let legacyKey = "FoodJourney.UserPreferences.v1"

    init(defaults: any LearningPreferencesStorage = UserDefaults.standard) {
        self.defaults = defaults
        if ProcessInfo.processInfo.arguments.contains("-uiTesting") {
            hasCompletedOnboarding = true
            focus = .general
            hydration = .unknown
            return
        }
        // The decoder ignores all other legacy fields; health selections are not read into the model.
        let data = defaults.data(forKey: Self.storageKey) ?? defaults.data(forKey: Self.legacyKey)
        let stored = data.flatMap { try? JSONDecoder().decode(Stored.self, from: $0) }
        hasCompletedOnboarding = stored?.hasCompletedOnboarding ?? false
        focus = stored?.focus.supported ?? .general
        hydration = stored?.hydration ?? .unknown
        save()
    }

    func toggleFocus(_ topic: HealthFocus) {
        focus = focus == topic.supported ? .general : topic.supported
    }
    var highlightedOrgans: [DigestiveOrgan] { focus.focusOrgans }

    private struct Stored: Codable {
        let hasCompletedOnboarding: Bool
        let focus: HealthFocus
        let hydration: DailyHydration?
    }
    private func save() {
        guard !ProcessInfo.processInfo.arguments.contains("-uiTesting") else { return }
        let stored = Stored(hasCompletedOnboarding: hasCompletedOnboarding, focus: focus.supported,
                            hydration: hydration == .unknown ? nil : hydration)
        guard let data = try? JSONEncoder().encode(stored) else { return }
        defaults.set(data, forKey: Self.storageKey)
        defaults.removeObject(forKey: Self.legacyKey)
    }
}
