import SwiftUI

/// "我" Tab：展示并修改问卷答案（慢性病 + 关注指标）。
/// 答案本地存储、不记录身份；慢性病好转或选错可随时改。
struct MeView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                chronicCard
                focusCard
                noteCard
            }
            .padding(16)
        }
        .background(Color(hex: "0d0d1a")!)
        .navigationTitle("我").navigationBarTitleDisplayMode(.inline)
    }

    // MARK: 慢性病

    private var chronicCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("慢性病").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            Toggle(isOn: $prefs.hasChronicCondition) {
                Text("是否患有慢性病").font(.system(size: 13)).foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
            }
            .tint(AppTheme.primary)

            if prefs.hasChronicCondition {
                VStack(alignment: .leading, spacing: 8) {
                    Text("病种（可多选）").font(.system(size: 11)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                    FlowLayout(spacing: 8) {
                        ForEach(ChronicCondition.allCases) { c in
                            chip(c.rawValue, selected: prefs.conditions.contains(c)) {
                                if prefs.conditions.contains(c) { prefs.conditions.remove(c) }
                                else { prefs.conditions.insert(c) }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: "111128")!)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 关注指标

    private var focusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最在意的指标").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            Text("决定代谢报告的呈现镜头").font(.system(size: 11)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            FlowLayout(spacing: 8) {
                ForEach(HealthFocus.allCases) { f in
                    chip(f.rawValue, selected: prefs.focus == f) {
                        prefs.focus = f
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: "111128")!)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 说明

    private var noteCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lock.shield.fill").foregroundColor(AppTheme.primaryLight).font(.system(size: 13))
            Text("答案仅保存在本机，不记录个人身份；慢性病好转或选错时可随时在此修改。")
                .font(.system(size: 11)).foregroundColor(AppTheme.textTertiary(scheme: colorScheme)).lineSpacing(3)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: "111128")!)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .foregroundColor(selected ? .white : AppTheme.textPrimary(scheme: colorScheme))
                .background(selected ? AppTheme.primary : AppTheme.surface(scheme: colorScheme))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
