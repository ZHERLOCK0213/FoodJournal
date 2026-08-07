import SwiftUI

/// 能量代谢卡片
struct EnergyMetabolismCardView: View {
    let result: MetabolismResult

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 14) {
            // ATP 大数字
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", result.atpMoles))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.primary)
                Text("mol ATP")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            }

            Divider()
                .background(AppTheme.divider(scheme: colorScheme))

            // 指标行
            HStack(spacing: 0) {
                // 总热量
                metricItem(
                    value: "\(Int(result.totalCalories))",
                    unit: "kcal",
                    label: "总热量"
                )

                Spacer()

                // 血糖负荷
                metricBadge(
                    label: "血糖负荷",
                    level: result.glycemicLoad
                )

                Spacer()

                // 胰岛素响应
                metricBadge(
                    label: "胰岛素响应",
                    level: result.insulinResponse
                )
            }
        }
        .padding(16)
        .background(AppTheme.surface(scheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow(scheme: colorScheme), radius: 8, y: 2)
    }

    // MARK: - 指标项

    private func metricItem(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textTertiary(scheme: colorScheme))
        }
    }

    private func metricBadge(label: String, level: MetabolismResult.GlycemicLevel) -> some View {
        VStack(spacing: 4) {
            Text(level.rawValue)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: level.colorHex)!)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color(hex: level.colorHex)!.opacity(0.12))
                .clipShape(Capsule())
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textTertiary(scheme: colorScheme))
        }
    }
}
