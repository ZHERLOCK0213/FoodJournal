import SwiftUI

/// 根视图：未完成问卷 → 引导问卷；否则 → 底部三 Tab（消化预演 / 代谢报告 / 我）
struct ContentView: View {
    @State private var prefs = UserPreferences()
    @State private var liveVM = LiveSessionViewModel()
    @State private var selectedTab = 0

    var body: some View {
        if !prefs.hasCompletedOnboarding {
            OnboardingView(prefs: prefs)
        } else {
            TabView(selection: $selectedTab) {
                LiveSessionView(viewModel: liveVM, prefs: prefs, selectedTab: $selectedTab)
                    .tabItem { Label("消化预演", systemImage: "fork.knife") }
                    .tag(0)

                NavigationStack {
                    ReportView(session: liveVM.session, prefs: prefs)
                }
                .tabItem { Label("代谢报告", systemImage: "doc.text.magnifyingglass") }
                .tag(1)

                NavigationStack {
                    MeView(prefs: prefs, library: liveVM.library)
                }
                .tabItem { Label("我", systemImage: "person.crop.circle") }
                .tag(2)
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}
