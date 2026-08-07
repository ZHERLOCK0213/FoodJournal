import SwiftUI

/// 营养素进度条
struct NutrientProgressBarView: View {
    let nutrient: NutrientType
    let grams: Double
    let maxGrams: Double  // 参考最大值（用于进度计算）

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard maxGrams > 0 else { return 0 }
        return CGFloat(min(grams / maxGrams, 1.0))
    }

    var body: some View {
        HStack(spacing: 8) {
            // 营养素名称
            Text(nutrient.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
                .frame(width: 36, alignment: .leading)

            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.divider(scheme: colorScheme))
                        .frame(height: 8)

                    // 填充
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.color(for: nutrient))
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)

            // 克数
            Text("\(Int(grams))g")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(AppTheme.color(for: nutrient))
                .frame(width: 40, alignment: .trailing)
        }
    }
}
