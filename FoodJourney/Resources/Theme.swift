import SwiftUI

/// 自适应色彩系统
enum AppTheme {
    // MARK: - 主色
    static let primary = Color(hex: "0F6E56")!
    static let primaryLight = Color(hex: "9FE1CB")!

    // MARK: - 营养素颜色（固定，不自适应）
    static let carbColor = Color(hex: "EF9F27")!
    static let fatColor = Color(hex: "D85A30")!
    static let proteinColor = Color(hex: "1D9E75")!

    // MARK: - 自适应颜色（light / dark）

    /// 主背景色：浅色 #F1EFE8，深色 #0d0d1a
    static func background(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "0d0d1a")!
            : Color(hex: "F1EFE8")!
    }

    /// 表面/卡片背景
    static func surface(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "111128")!
            : Color(hex: "FFFFFF")!
    }

    /// 导航栏背景
    static func navbar(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "111128")!
            : Color(hex: "0F6E56")!
    }

    /// 主文字颜色
    static func textPrimary(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "e8e8f0")!
            : Color(hex: "1a1a2e")!
    }

    /// 副文字颜色
    static func textSecondary(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "5555aa")!
            : Color(hex: "6B7280")!
    }

    /// 次要文字
    static func textTertiary(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "444466")!
            : Color(hex: "9CA3AF")!
    }

    /// 分隔线
    static func divider(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "1e1e3a")!
            : Color(hex: "E5E7EB")!
    }

    /// 卡片阴影
    static func cardShadow(scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.clear
            : Color.black.opacity(0.06)
    }

    /// 营养素颜色辅助
    static func color(for nutrient: NutrientType) -> Color {
        switch nutrient {
        case .carb:    return carbColor
        case .fat:     return fatColor
        case .protein: return proteinColor
        }
    }
}
