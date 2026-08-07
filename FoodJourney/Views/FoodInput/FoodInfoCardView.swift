import SwiftUI

/// 食物详情底部卡
struct FoodInfoCardView: View {
    let food: Food
    let grams: Double
    let onDismiss: () -> Void
    let onProceed: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var carb: Double { food.carbPer100g * grams / 100 }
    private var fat: Double { food.fatPer100g * grams / 100 }
    private var protein: Double { food.proteinPer100g * grams / 100 }
    private var cal: Double { food.caloriesPer100g * grams / 100 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 标题行
            HStack {
                Text(food.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                }
            }

            // 描述
            if let desc = food.description {
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                    .lineSpacing(2)
            }

            // 营养素小标签
            HStack(spacing: 8) {
                nutrientBadge("碳水 \(Int(carb))g", color: AppTheme.carbColor)
                nutrientBadge("脂肪 \(Int(fat))g", color: AppTheme.fatColor)
                nutrientBadge("蛋白 \(Int(protein))g", color: AppTheme.proteinColor)
                Spacer()
                Text("\(Int(cal)) kcal")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.primary)
            }

            // 吃进去按钮
            Button(action: onProceed) {
                HStack {
                    Spacer()
                    Text("吃进去")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(AppTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(AppTheme.surface(scheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow(scheme: colorScheme), radius: 8, y: -2)
    }

    private func nutrientBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
