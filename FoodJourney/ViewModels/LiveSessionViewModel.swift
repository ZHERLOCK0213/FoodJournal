import SwiftUI
import Observation

struct OrganBubble: Identifiable {
    let id = UUID()
    let organ: DigestiveOrgan   // 连线指向的脏器
    let organLabel: String
    let text: String
    let side: Side
    let popThreshold: Double
    var hasPopped: Bool = false
    enum Side { case left, right }
}

/// live 会话编排：串行状态机 + 串接 DigestionSession
///
/// 状态推进放在 Timer 里（不在 Canvas 渲染期改被观察属性，否则触发重渲染死循环）。
/// session 在多处共享（消化预演 Tab + 代谢报告 Tab），由 ContentView 持有本 VM。
@Observable
final class LiveSessionViewModel {
    let session = DigestionSession()

    let foods: [Food] = FoodDatabase.allFoods
    var selectedFood: Food?

    enum Phase: Equatable { case idle, descending, digesting }
    var phase: Phase = .idle
    var progress: Double = 0

    var bubbles: [OrganBubble] = []

    private var timer: Timer?
    private var lastTickDate = Date()

    var canEat: Bool { phase == .idle && selectedFood != nil }
    var canFinish: Bool { session.foodCount > 0 && phase == .idle }

    /// 吃进去：摄入一份（100g），启动动画；同时清掉上一份的临时泡泡
    func eatIn() {
        guard canEat, let food = selectedFood else { return }
        let item = FoodItem(food: food, grams: 100)
        let result = session.ingest(item)
        bubbles = makeBubbles(for: result, food: food)
        phase = .descending
        progress = 0
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        lastTickDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.advance()
        }
    }

    private func stopTimer() { timer?.invalidate(); timer = nil }

    /// 每帧推进（由 Timer 驱动，不在 Canvas 渲染期执行）
    private func advance() {
        let now = Date()
        let dt = now.timeIntervalSince(lastTickDate)
        lastTickDate = now
        switch phase {
        case .idle:
            stopTimer(); return
        case .descending:
            progress += dt / 1.2
            if progress >= 1 { phase = .digesting; progress = 0 }
        case .digesting:
            progress += dt / 3.5
            if progress >= 1 { progress = 1; phase = .idle; stopTimer() }
        }
        // 泡泡随粒子到达脏器路径位置而弹（lead = 粒子前端 t 值）
        if phase == .digesting {
            let lead = 0.30 + progress * 0.65
            for i in bubbles.indices where !bubbles[i].hasPopped && lead >= bubbles[i].popThreshold {
                bubbles[i].hasPopped = true
            }
        }
    }

    deinit { timer?.invalidate() }

    func reset() {
        stopTimer()
        session.reset()
        bubbles = []
        phase = .idle
        progress = 0
    }

    /// 删除已吃入的某一份（点错重复时用）；重放后清掉临时泡泡
    func removeEaten(at index: Int) {
        stopTimer()
        session.remove(at: index)
        bubbles = []
        phase = .idle
        progress = 0
    }

    // MARK: - 生成产物泡泡（按产物出现顺序）

    private func makeBubbles(for result: FoodDigestionResult, food: Food) -> [OrganBubble] {
        var bs: [OrganBubble] = []
        let carb = food.carbPer100g, fat = food.fatPer100g, protein = food.proteinPer100g

        bs.append(OrganBubble(organ: .stomach, organLabel: "胃", text: "胃蛋白酶分解蛋白", side: .left, popThreshold: 0.30))
        bs.append(OrganBubble(organ: .smallIntestine, organLabel: "小肠", text: "吸收糖/氨基酸/脂肪酸", side: .left, popThreshold: 0.50))
        if carb > 1 {
            bs.append(OrganBubble(organ: .pancreas, organLabel: "胰腺", text: "分泌胰岛素·碳水\(Int(carb))g", side: .right, popThreshold: 0.55))
        }
        if fat > 1 || protein > 1 {
            bs.append(OrganBubble(organ: .liver, organLabel: "肝脏", text: "代谢脂肪/蛋白→ATP", side: .right, popThreshold: 0.58))
        }
        // 肾：蛋白代谢必产尿酸——始终展示本份产生量；滞留>0时追加滞留量
        if protein > 1 {
            let produced = result.uricAcidProducedMg
            let retained = produced - result.uricAcidClearedMg
            var txt = "产生尿酸\(Int(produced))mg"
            if retained > 1 { txt += "·滞留\(Int(retained))mg" }
            bs.append(OrganBubble(organ: .kidney, organLabel: "肾", text: txt, side: .right, popThreshold: 0.70))
        }
        if food.fiberPer100g > 0 || food.lactosePer100g > 0 {
            var parts: [String] = []
            if food.fiberPer100g > 0 { parts.append("纤维\(Int(food.fiberPer100g))g") }
            if food.lactosePer100g > 0 { parts.append("乳糖\(Int(food.lactosePer100g))g") }
            bs.append(OrganBubble(organ: .largeIntestine, organLabel: "大肠", text: parts.joined(separator: "/") + "残留", side: .left, popThreshold: 0.88))
        }
        return bs
    }
}
