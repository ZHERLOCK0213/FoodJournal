import SwiftUI

/// 引导问卷：是否慢性病 →（是则选病种）→ 最在意指标 → 进入 live 会话
struct OnboardingView: View {
    @Bindable var prefs: UserPreferences
    @State private var step = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(hex: "0d0d1a")!.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 6) {
                    Text("食物旅行").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    Text("看懂一顿饭在体内如何代谢").font(.system(size: 13)).foregroundColor(AppTheme.primaryLight)
                }
                Spacer()
                card
                Spacer()
                // 步骤指示
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i == step ? AppTheme.primary : Color(hex: "333344")!)
                            .frame(width: 18, height: 4)
                    }
                }
            }
            .padding(24)
            .preferredColorScheme(.dark)
        }
    }

    @ViewBuilder private var card: some View {
        switch step {
        case 0:
            question("您是否患有慢性病？", subtitle: "决定报告重点提示的脏器") {
                VStack(spacing: 10) {
                    actionButton("是", primary: true) {
                        prefs.hasChronicCondition = true
                        step = 1
                    }
                    actionButton("否，跳过", primary: false) {
                        prefs.hasChronicCondition = false
                        prefs.conditions = []
                        step = 2
                    }
                }
            }
        case 1:
            question("请选择病种", subtitle: "可多选") {
                VStack(spacing: 16) {
                    FlowLayout(spacing: 8) {
                        ForEach(ChronicCondition.allCases) { c in
                            chip(c.rawValue, selected: prefs.conditions.contains(c)) {
                                if prefs.conditions.contains(c) { prefs.conditions.remove(c) }
                                else { prefs.conditions.insert(c) }
                            }
                        }
                    }
                    actionButton("下一步", primary: true) { step = 2 }
                }
            }
        default:
            question("您最在意哪项指标？", subtitle: "决定报告呈现的镜头") {
                VStack(spacing: 16) {
                    FlowLayout(spacing: 8) {
                        ForEach(HealthFocus.allCases) { f in
                            chip(f.rawValue, selected: prefs.focus == f) {
                                prefs.focus = f
                            }
                        }
                    }
                    actionButton("开始使用", primary: true) {
                        prefs.hasCompletedOnboarding = true
                    }
                }
            }
        }
    }

    private func question<S: View>(_ title: String, subtitle: String, @ViewBuilder content: () -> S) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 11)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            }
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "111128")!)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actionButton(_ title: String, primary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .foregroundColor(primary ? .white : AppTheme.primaryLight)
                .background(primary ? AppTheme.primary : Color(hex: "1a3a30")!)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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
