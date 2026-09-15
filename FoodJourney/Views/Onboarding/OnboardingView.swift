import SwiftUI

/// Optional onboarding shares controls with settings; no forced health declaration.
struct OnboardingView: View {
    @Bindable var prefs: UserPreferences
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("食物旅行").font(.largeTitle.bold())
                Text("看懂食物的消化与吸收。")
                    .foregroundStyle(.secondary)
                Button("跳过") {
                    prefs.focus = .general
                    prefs.hasCompletedOnboarding = true
                }.buttonStyle(.bordered)
                LearningFocusSection(prefs: prefs)
                Button("开始使用") { prefs.hasCompletedOnboarding = true }
                    .buttonStyle(.borderedProminent).tint(AppTheme.primary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                Text("生理过程示意，非个人代谢测量。")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(24)
        }
        .background(AnatomyArtwork.color("0D1020"))
        .preferredColorScheme(.dark)
    }
}
