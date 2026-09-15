import SwiftUI

struct LearningFocusSection: View {
    @Bindable var prefs: UserPreferences

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("关注主题（可选）").font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(HealthFocus.available) { topic in
                    Button { prefs.toggleFocus(topic) } label: {
                        Text(topic.title).font(.subheadline)
                            .padding(.horizontal, 12).frame(minHeight: 44)
                            .foregroundStyle(prefs.focus == topic ? Color.white : Color.primary)
                            .background(prefs.focus == topic ? AppTheme.primary : Color.white.opacity(0.07), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("focus-\(topic.metricID ?? "general")")
                    .accessibilityAddTraits(prefs.focus == topic ? .isSelected : [])
                }
            }
            Text("查看本餐合计、主要来源与进食提示。再次点选可取消。")
                .font(.caption).foregroundStyle(.secondary)
            if prefs.focus.supported == .uricAcid {
                Picker("平日每日饮水量（可选）", selection: $prefs.hydration) {
                    ForEach(DailyHydration.allCases) { value in
                        Text(value.title).tag(value)
                    }
                }.accessibilityIdentifier("hydration-picker")
                Text("指平日一整天喝的水，不含食物中的水；不是今天截至此刻的饮水量。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
