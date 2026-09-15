import Foundation

/// Usual full-day drinking water, not today's progress or total water from food.
enum DailyHydration: String, CaseIterable, Codable, Identifiable {
    case unknown, belowOneLiter, oneToTwoLiters, atLeastTwoLiters, medicallyRestricted
    var id: String { rawValue }
    var title: String {
        switch self {
        case .unknown: "未填写"
        case .belowOneLiter: "少于 1 L／天"
        case .oneToTwoLiters: "1 L 至不足 2 L／天"
        case .atLeastTwoLiters: "至少 2 L／天"
        case .medicallyRestricted: "医生要求限制饮水"
        }
    }
    var guidance: String {
        switch self {
        case .unknown: "未填写平日饮水量，不假定饮水充足。"
        case .belowOneLiter, .oneToTwoLiters:
            "若有高尿酸或痛风且心肾功能正常，可与医生核对每日饮水安排。饮水不能抵消本餐嘌呤。"
        case .atLeastTwoLiters:
            "此记录不代表个人饮水已达标，也不能降低本餐嘌呤估算或保证尿酸正常。"
        case .medicallyRestricted:
            "按医生规定的饮水量执行，不按一般饮水建议自行增加。"
        }
    }
}
