import SwiftUI

/// 可选食物 Chip
struct FoodChipView: View {
    let food: Food
    let isSelected: Bool
    let grams: Double
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(food.name)
                    .font(.system(size: 13, weight: .medium))
                if isSelected {
                    Text("\(Int(grams))g")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.primaryLight)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? AppTheme.primary
                    : AppTheme.surface(scheme: colorScheme)
            )
            .foregroundColor(
                isSelected
                    ? .white
                    : AppTheme.textPrimary(scheme: colorScheme)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected
                            ? AppTheme.primary
                            : AppTheme.divider(scheme: colorScheme),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("food-chip-\(food.name)")
    }
}
