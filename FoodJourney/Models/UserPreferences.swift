import Foundation
import Observation

// MARK: - 慢性病标签

/// 慢性病标签（问卷第一问，可多选）
enum ChronicCondition: String, CaseIterable, Identifiable, Codable {
    case hypertension    = "高血压"
    case hyperglycemia   = "高血糖"
    case hyperlipidemia  = "高血脂"
    case hyperuricemia   = "高尿酸"

    var id: String { rawValue }

    /// 该病关联的脏器（报告额外重点提示）
    var relatedOrgan: DigestiveOrgan {
        switch self {
        case .hyperuricemia:  return .kidney       // 尿酸排泄
        case .hyperglycemia:  return .pancreas     // 胰岛素
        case .hyperlipidemia: return .liver        // 脂代谢
        case .hypertension:   return .kidney       // 简化关联肾
        }
    }
}

// MARK: - 健康关注镜头

/// 用户最在意的营养学指标（问卷第二问，单选）→ 报告呈现镜头
enum HealthFocus: String, CaseIterable, Identifiable, Codable {
    case bloodSugar = "血糖"
    case uricAcid   = "尿酸"
    case insulin    = "胰岛素"
    case calories   = "热量"

    var id: String { rawValue }

    /// 该镜头重点提示的脏器过载
    var focusOrgans: [DigestiveOrgan] {
        switch self {
        case .bloodSugar, .insulin: return [.pancreas]
        case .uricAcid:             return [.kidney]
        case .calories:             return [.liver, .smallIntestine]
        }
    }
}

// MARK: - 问卷答案（本地持久化）

/// 问卷答案：本地 UserDefaults 存储，不存个人身份；任意项改动自动持久化。
///
/// 报告页用 `highlightedOrgans` 决定哪些脏器过载需重点提示（镜头 + 慢性病）。
@Observable
final class UserPreferences {

    /// 是否已完成首屏问卷（决定是否展示问卷）
    var hasCompletedOnboarding: Bool {
        didSet { save() }
    }

    /// 是否患有慢性病（第一问分支）
    var hasChronicCondition: Bool {
        didSet { save() }
    }

    /// 慢性病病种（第一问若"是"则选，可多选）
    var conditions: Set<ChronicCondition> {
        didSet { save() }
    }

    /// 最在意的指标（第二问，呈现镜头）
    var focus: HealthFocus {
        didSet { save() }
    }

    private static let storageKey = "FoodJourney.UserPreferences.v1"

    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(Stored.self, from: data) {
            hasCompletedOnboarding = decoded.hasCompletedOnboarding
            hasChronicCondition = decoded.hasChronicCondition
            conditions = decoded.conditions
            focus = decoded.focus
        } else {
            hasCompletedOnboarding = false
            hasChronicCondition = false
            conditions = []
            focus = .calories
        }
    }

    /// 报告镜头：重点提示的脏器集合（关注指标 + 慢性病关联）
    var highlightedOrgans: [DigestiveOrgan] {
        let organs = focus.focusOrgans + conditions.map(\.relatedOrgan)
        return Array(Set(organs)).sorted { $0.rawValue < $1.rawValue }
    }

    // MARK: 持久化

    private struct Stored: Codable {
        let hasCompletedOnboarding: Bool
        let hasChronicCondition: Bool
        let conditions: Set<ChronicCondition>
        let focus: HealthFocus
    }

    private func save() {
        let stored = Stored(
            hasCompletedOnboarding: hasCompletedOnboarding,
            hasChronicCondition: hasChronicCondition,
            conditions: conditions,
            focus: focus
        )
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
