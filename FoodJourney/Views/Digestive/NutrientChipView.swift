import SwiftUI

/// 营养类型选择 Chip
struct NutrientChipView: View {
    let type: NutrientType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.system(size: 9))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(hex: type.bgColorHex))
                .foregroundColor(Color(hex: type.colorHex))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected
                                ? Color(hex: type.colorHex)!
                                : Color(hex: type.borderColorHex)!.opacity(0.5),
                            lineWidth: 1
                        )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
