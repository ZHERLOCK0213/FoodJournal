import SwiftUI

/// 屏3：代谢总结页
struct MetabolismSummaryView: View {
    let meal: Meal

    @State private var viewModel: MetabolismViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(meal: Meal) {
        self.meal = meal
        self._viewModel = State(initialValue: MetabolismViewModel(meal: meal))
    }

    private var result: MetabolismResult { viewModel.result }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 能量代谢卡片
                EnergyMetabolismCardView(result: result)

                // 代谢物列表
                metabolitesCard

                // 饮食建议
                dietAdviceCard
            }
            .padding(16)
        }
        .background(AppTheme.background(scheme: colorScheme))
        .navigationTitle("代谢总结")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 代谢物列表

    private var metabolitesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("代谢产物")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))

            MetaboliteRowView(
                icon: "cloud",
                name: "二氧化碳",
                value: "\(String(format: "%.0f", result.co2Grams))g",
                progress: min(result.co2Grams / 300, 1.0),
                color: AppTheme.fatColor,
                status: co2Status
            )

            MetaboliteRowView(
                icon: "drop",
                name: "水",
                value: "\(String(format: "%.0f", result.waterGrams))g",
                progress: min(result.waterGrams / 200, 1.0),
                color: .blue,
                status: waterStatus
            )

            MetaboliteRowView(
                icon: "star",
                name: "尿酸",
                value: "\(String(format: "%.0f", result.uricAcidMg))mg",
                progress: min(result.uricAcidMg / 800, 1.0),
                color: AppTheme.carbColor,
                status: uricAcidStatus
            )
        }
        .padding(14)
        .background(AppTheme.surface(scheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow(scheme: colorScheme), radius: 8, y: 2)
    }

    // MARK: - 饮食建议

    private var dietAdviceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.carbColor)
                Text("饮食建议")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
            }

            Text(result.dietAdvice)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.surface(scheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow(scheme: colorScheme), radius: 8, y: 2)
    }

    // MARK: - 状态判断

    private var co2Status: String {
        result.co2Grams < 150 ? "正常" : result.co2Grams < 250 ? "中等" : "偏高"
    }

    private var waterStatus: String {
        result.waterGrams < 100 ? "正常" : result.waterGrams < 180 ? "中等" : "偏高"
    }

    private var uricAcidStatus: String {
        result.uricAcidMg < 400 ? "正常" : result.uricAcidMg < 600 ? "偏高" : "注意"
    }
}
