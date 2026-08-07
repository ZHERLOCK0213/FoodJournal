import SwiftUI

struct ContentView: View {
    @State private var meal = Meal()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            FoodInputView(meal: meal) {
                navigationPath.append(Screen.digestion)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .foodInput:
                    FoodInputView(meal: meal) {
                        navigationPath.append(Screen.digestion)
                    }
                case .digestion:
                    DigestiveView(meal: meal) {
                        navigationPath.append(Screen.summary)
                    }
                case .summary:
                    MetabolismSummaryView(meal: meal)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
