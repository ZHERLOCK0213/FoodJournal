import SwiftUI
import Observation

/// 屏3 视图模型
@Observable
class MetabolismViewModel {
    let result: MetabolismResult

    init(meal: Meal) {
        self.result = MetabolismEngine.compute(for: meal)
    }
}
