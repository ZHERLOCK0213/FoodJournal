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
    var popProgress: Double = 0   // 弹出动画进度 0→1
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

    /// 本份之前已沉淀的残留数（这些始终显示；本份新增的残留按动画进度揭示）
    private(set) var settledResidueCount: Int = 0

    private var timer: Timer?
    private var lastTickDate = Date()

    var canEat: Bool { phase == .idle && selectedFood != nil }
    var canFinish: Bool { session.foodCount > 0 && phase == .idle }

    /// 吃进去：摄入一份（100g），启动动画；同时清掉上一份的临时泡泡
    func eatIn() {
        guard canEat, let food = selectedFood else { return }
        let item = FoodItem(food: food, grams: 100)
        settledResidueCount = session.residues.count   // 记录本份之前的沉淀量
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
            break
        case .descending:
            progress += dt / 1.2
            if progress >= 1 { phase = .digesting; progress = 0 }
        case .digesting:
            progress += dt / 3.5
            if progress >= 1 { progress = 1; phase = .idle }
        }
        // 泡泡随粒子到达脏器路径位置而弹（lead = 粒子前端 t 值）
        if phase == .digesting {
            let lead = 0.30 + progress * 0.65
            for i in bubbles.indices where !bubbles[i].hasPopped && lead >= bubbles[i].popThreshold {
                bubbles[i].hasPopped = true
            }
        }
        // 推进已弹泡泡的弹出动画（0→1，约 0.3s）
        for i in bubbles.indices where bubbles[i].hasPopped && bubbles[i].popProgress < 1 {
            bubbles[i].popProgress = min(1, bubbles[i].popProgress + dt / 0.3)
        }
        // 消化结束且所有泡泡动画跑完才停 timer
        if phase == .idle && bubbles.allSatisfy({ !$0.hasPopped || $0.popProgress >= 1 }) {
            stopTimer()
        }
    }

    deinit { timer?.invalidate() }

    func reset() {
        stopTimer()
        session.reset()
        bubbles = []
        settledResidueCount = 0
        phase = .idle
        progress = 0
    }

    /// 删除已吃入的某一份（点错重复时用）；重放后清掉临时泡泡
    func removeEaten(at index: Int) {
        stopTimer()
        session.remove(at: index)
        bubbles = []
        settledResidueCount = session.residues.count   // 重放后全部沉淀
        phase = .idle
        progress = 0
    }

    // MARK: - 生成产物泡泡（按产物出现顺序）

    private func makeBubbles(for result: FoodDigestionResult, food: Food) -> [OrganBubble] {
        var bs: [OrganBubble] = []
        let purine = food.purinePer100g
        let protein = food.proteinPer100g

        bs.append(OrganBubble(organ: .stomach, organLabel: "胃", text: "胃蛋白酶分解蛋白", side: .left, popThreshold: 0.30))

        // 小肠：展示实际吸收物（葡萄糖/氨基酸/脂肪酸，受吸收效率折减）
        bs.append(OrganBubble(organ: .smallIntestine, organLabel: "小肠",
            text: "吸收葡萄糖\(String(format: "%.1f", result.absorbedGlucoseG))g·氨基酸\(String(format: "%.1f", result.absorbedAminoAcidG))g·脂肪酸\(String(format: "%.1f", result.absorbedFattyAcidG))g",
            side: .left, popThreshold: 0.50))

        // 胰腺：碳水入血 → 胰岛素响应
        if result.bloodGlucoseMg > 100 {
            bs.append(OrganBubble(organ: .pancreas, organLabel: "胰腺",
                text: "分泌胰岛素·血糖+\(Int(result.bloodGlucoseMg))mg", side: .right, popThreshold: 0.55))
        }

        // 肝：脱氨产尿素（蛋白）+ 代谢嘌呤产尿酸（与蛋白无关）
        if protein > 1 || purine > 20 {
            var parts: [String] = []
            if result.ureaProducedMg > 1 { parts.append("产尿素\(Int(result.ureaProducedMg))mg") }
            if purine > 20 { parts.append("产尿酸\(Int(result.uricAcidProducedMg))mg") }
            if !parts.isEmpty {
                bs.append(OrganBubble(organ: .liver, organLabel: "肝脏",
                    text: parts.joined(separator: "·"), side: .right, popThreshold: 0.58))
            }
        }

        // 肾：排泄尿酸(嘌呤) + 尿素(蛋白)；滞留>0 追加
        if protein > 1 || purine > 20 {
            var parts: [String] = []
            if purine > 20 { parts.append("排泄尿酸\(Int(result.uricAcidExcretedMg))mg") }
            if result.ureaExcretedMg > 1 { parts.append("排泄尿素\(Int(result.ureaExcretedMg))mg") }
            if result.uricAcidRetainedMg > 1 { parts.append("尿酸滞留\(Int(result.uricAcidRetainedMg))mg") }
            if result.ureaRetainedMg > 1 { parts.append("尿素滞留\(Int(result.ureaRetainedMg))mg") }
            if !parts.isEmpty {
                bs.append(OrganBubble(organ: .kidney, organLabel: "肾",
                    text: parts.joined(separator: "·"), side: .right, popThreshold: 0.70))
            }
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
