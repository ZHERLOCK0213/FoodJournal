import Foundation
import Observation

// MARK: - 脏器

/// 代谢脏器。大肠为残渣堆积地（无能力值），其余五个有能力值。
enum DigestiveOrgan: String, CaseIterable, Identifiable {
    case stomach        = "胃"
    case smallIntestine = "小肠"
    case liver          = "肝脏"
    case pancreas       = "胰腺"
    case largeIntestine = "大肠"
    case kidney         = "肾"

    var id: String { rawValue }

    /// 能力初值（大肠不参与能力消耗）
    var initialCapacity: Double {
        switch self {
        case .stomach, .smallIntestine, .liver, .pancreas, .kidney: return 100
        case .largeIntestine: return 0
        }
    }

    /// 过载时残留物名称
    var overloadSubstance: String {
        switch self {
        case .stomach:        return "未消化食物"
        case .smallIntestine: return "未吸收营养"
        case .liver:          return "脂肪"
        case .pancreas:       return "多余糖分"
        case .kidney:         return "尿酸/尿素"
        case .largeIntestine: return "残渣"
        }
    }
}

// MARK: - 残留 / 过载

/// 残留粒子：卡在脏器的不可吸收物（画布上以名称尾标显示，跨份保留）
struct DigestionResidue: Identifiable {
    let id = UUID()
    let foodName: String        // 名称尾标用
    let organ: DigestiveOrgan   // 卡在哪
    let substance: String       // 膳食纤维/乳糖/脂肪/尿酸…
    let amount: Double          // 量（抽象点数，可调）
    let kind: Kind

    enum Kind { case structural, overload }
}

/// 单脏器过载事件（报告标注用）
struct OverloadEvent: Identifiable {
    let id = UUID()
    let foodName: String
    let organ: DigestiveOrgan
    let substance: String
    let unmetAmount: Double
}

// MARK: - 单份代谢结果

struct FoodDigestionResult: Identifiable {
    let id = UUID()
    let foodName: String
    let grams: Double
    let calories: Double          // 摄入热量（输入）
    let atpMoles: Double          // 实际产 ATP（已按效率折减）
    let co2Grams: Double
    let waterGrams: Double

    // 吸收物（身体得到什么；小肠吸收后入血/淋巴）
    let absorbedGlucoseG: Double    // 葡萄糖入血（来自碳水）
    let absorbedAminoAcidG: Double  // 氨基酸入肝（来自蛋白）
    let absorbedFattyAcidG: Double  // 脂肪酸入淋巴/血（来自脂肪）
    let bloodGlucoseMg: Double      // 葡萄糖入血总量（mg，用于血糖负荷展示）
    let insulinResponse: Double     // 胰岛素响应（相对值，胰腺效率折减）

    // 氮废物（肝产、肾排）
    let ureaProducedMg: Double      // 肝脱氨产尿素
    let ureaExcretedMg: Double      // 肾排泄尿素
    let ureaRetainedMg: Double      // 尿素滞留（肾过载时）
    let uricAcidProducedMg: Double  // 肝代谢嘌呤产尿酸（与蛋白无关）
    let uricAcidExcretedMg: Double  // 肾(70%)+肠(30%)排泄尿酸
    let uricAcidRetainedMg: Double  // 尿酸滞留（肾过载时）

    let residues: [DigestionResidue]
    let overloads: [OverloadEvent]
}

// MARK: - 能力状态机

/// live 会话的代谢核心：逐份摄入、脏器能力单调递减、过载产残留、累积报告。
///
/// 严格串行——调用方负责门控（上一份动画完成前不可摄入下一份）。
/// 一顿会话内能力不恢复；`reset()` 开启下一顿。
@Observable
final class DigestionSession {

    /// 各脏器剩余能力（大肠不在其中）
    private(set) var capacities: [DigestiveOrgan: Double] = [:]

    /// 逐份结果
    private(set) var results: [FoodDigestionResult] = []

    /// 逐份摄入的原始 FoodItem（删除某份后重放用）
    private(set) var items: [FoodItem] = []

    /// 累积残留（跨份保留，画布显示）
    private(set) var residues: [DigestionResidue] = []

    // MARK: 累积总量

    var foodCount: Int { results.count }

    /// 本次进食某脏器使用度（0~1）：已消耗能力 / 初始能力。大肠无能力值返回 0。
    func usageRatio(_ organ: DigestiveOrgan) -> Double {
        guard organ.initialCapacity > 0 else { return 0 }
        let remaining = capacities[organ] ?? organ.initialCapacity
        return max(0, (organ.initialCapacity - remaining) / organ.initialCapacity)
    }
    var totalCalories: Double { results.reduce(0) { $0 + $1.calories } }
    var totalATP: Double { results.reduce(0) { $0 + $1.atpMoles } }
    var totalCO2: Double { results.reduce(0) { $0 + $1.co2Grams } }
    var totalWater: Double { results.reduce(0) { $0 + $1.waterGrams } }

    // 吸收物累积（身体得到的）
    var totalAbsorbedGlucoseG: Double { results.reduce(0) { $0 + $1.absorbedGlucoseG } }
    var totalAbsorbedAminoAcidG: Double { results.reduce(0) { $0 + $1.absorbedAminoAcidG } }
    var totalAbsorbedFattyAcidG: Double { results.reduce(0) { $0 + $1.absorbedFattyAcidG } }
    var totalBloodGlucoseMg: Double { results.reduce(0) { $0 + $1.bloodGlucoseMg } }
    var totalInsulinResponse: Double { results.reduce(0) { $0 + $1.insulinResponse } }

    // 尿素累积（肝产、肾排）
    var totalUreaProducedMg: Double { results.reduce(0) { $0 + $1.ureaProducedMg } }
    var totalUreaRetainedMg: Double { results.reduce(0) { $0 + $1.ureaRetainedMg } }

    // 尿酸累积（肝产嘌呤、肾排）
    var totalUricAcidProducedMg: Double { results.reduce(0) { $0 + $1.uricAcidProducedMg } }
    var totalUricAcidRetainedMg: Double { results.reduce(0) { $0 + $1.uricAcidRetainedMg } }

    /// 消耗与产率常数（可调，跑起来再校准）
    enum Constants {
        // 能力消耗（每克宏量营养消耗的能力点）
        static let stomachLoadPerGram       = 0.3   // 总克数 → 胃
        static let smallIntestineLoadPerGram = 0.5  // 吸收性宏量 → 小肠
        static let liverFatLoad             = 1.0   // 脂肪 × liverLoadFactor → 肝
        static let liverProteinLoad         = 0.6   // 蛋白（脱氨产尿素）→ 肝
        static let liverPurineLoad          = 0.0006// 嘌呤 mg（代谢产尿酸）→ 肝
        static let pancreasCarbLoad         = 0.8   // 碳水 → 胰
        static let kidneyProteinLoad        = 0.5   // 蛋白（尿素排泄）→ 肾
        static let kidneyPurineLoad         = 0.002 // 嘌呤 mg（尿酸排泄）→ 肾
        // 产率
        static let atpCarb = 0.105, atpFat = 0.237, atpProtein = 0.085
        static let co2Carb = 1.07,  co2Fat = 2.8,   co2Protein = 0.8
        static let waterCarb = 0.6, waterFat = 1.07, waterProtein = 0.4
        // 氮废物产率
        static let ureaPerProteinMg     = 340.0  // 蛋白 g → 尿素 mg（肝脱氨，1g蛋白≈340mg尿素）
        static let uricAcidPerPurineMg  = 1.0    // 嘌呤 mg → 尿酸 mg（肝代谢产尿酸，与蛋白无关）
        static let uricAcidRenalFraction = 0.70  // 尿酸经肾排泄比例（余 30% 肠道）
    }

    init() { resetCapacities() }

    /// 重置（下一顿会话）
    func reset() {
        resetCapacities()
        results.removeAll()
        residues.removeAll()
        items.removeAll()
    }

    /// 删除第 index 份：移除后重放剩余项，能力/残留/累积量全部重算
    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        let saved = items
        resetCapacities()
        results.removeAll()
        residues.removeAll()
        for it in saved { _ingest(it) }
    }

    private func resetCapacities() {
        capacities.removeAll()
        for organ in DigestiveOrgan.allCases where organ.initialCapacity > 0 {
            capacities[organ] = organ.initialCapacity
        }
    }

    /// 摄入一份食物，计算代谢
    @discardableResult
    func ingest(_ item: FoodItem) -> FoodDigestionResult {
        items.append(item)
        return _ingest(item)
    }

    /// 纯计算（不追加 items），供 ingest 与重放共用
    @discardableResult
    private func _ingest(_ item: FoodItem) -> FoodDigestionResult {
        let carb = item.carbGrams
        let fat = item.fatGrams
        let protein = item.proteinGrams
        let mass = item.grams
        let absorbable = carb + fat + protein
        let liverLoad = item.food.liverLoadFactor

        // 1. 各脏器能力需求
        let purine = item.purineMg
        let stomachNeed = Constants.stomachLoadPerGram * mass
        let smallIntestineNeed = Constants.smallIntestineLoadPerGram * absorbable
        let liverNeed = Constants.liverFatLoad * fat * liverLoad
                        + Constants.liverProteinLoad * protein
                        + Constants.liverPurineLoad * purine
        let pancreasNeed = Constants.pancreasCarbLoad * carb
        // 肾排泄两类氮废物：尿素(蛋白) + 尿酸(嘌呤)
        let kidneyNeed = Constants.kidneyProteinLoad * protein
                       + Constants.kidneyPurineLoad * purine

        // 2. 消耗能力，返回 (效率, 未满足量)
        func consume(_ organ: DigestiveOrgan, _ need: Double) -> (eff: Double, unmet: Double) {
            guard need > 0 else { return (1, 0) }
            let remaining = capacities[organ] ?? 0
            let consumed = min(remaining, need)
            capacities[organ] = remaining - consumed
            return (consumed / need, need - consumed)
        }

        let stomach   = consume(.stomach, stomachNeed)
        let smallInt  = consume(.smallIntestine, smallIntestineNeed)
        let liver     = consume(.liver, liverNeed)
        let pancreas  = consume(.pancreas, pancreasNeed)
        let kidney    = consume(.kidney, kidneyNeed)

        // 3. 吸收效率（胃 + 小肠）决定多少宏量进入系统
        let absorptionEff = min(stomach.eff, smallInt.eff)
        let aCarb = carb * absorptionEff
        let aFat = fat * absorptionEff
        let aProtein = protein * absorptionEff

        // 4. 吸收物（身体得到什么）
        let absorbedGlucose = aCarb          // 葡萄糖入血
        let absorbedAminoAcid = aProtein     // 氨基酸入肝
        let absorbedFattyAcid = aFat         // 脂肪酸入淋巴/血
        let bloodGlucoseMg = aCarb * 1000    // 葡萄糖入血总量(mg)
        // 胰岛素响应：随碳水上升，胰腺过载则分泌不足
        let insulinResponse = aCarb * pancreas.eff

        // 5. 代谢产物（按相关脏器效率折减：碳水→胰、脂肪/蛋白→肝）
        let atp = aCarb * Constants.atpCarb * pancreas.eff
                + aFat * Constants.atpFat * liver.eff
                + aProtein * Constants.atpProtein * liver.eff
        let co2 = aCarb * Constants.co2Carb * pancreas.eff
                + aFat * Constants.co2Fat * liver.eff
                + aProtein * Constants.co2Protein * liver.eff
        let water = aCarb * Constants.waterCarb * pancreas.eff
                  + aFat * Constants.waterFat * liver.eff
                  + aProtein * Constants.waterProtein * liver.eff

        // 6. 尿素（肝脱氨产，肾排泄；肝效率影响脱氨，肾效率影响排泄）
        let ureaProduced = aProtein * Constants.ureaPerProteinMg * liver.eff
        let ureaExcreted = ureaProduced * kidney.eff
        let ureaRetained = ureaProduced - ureaExcreted

        // 7. 尿酸（肝代谢嘌呤产，与蛋白无关；肾排70%+肠排30%）
        let uricAcidProduced = purine * Constants.uricAcidPerPurineMg
        let renalShare = uricAcidProduced * Constants.uricAcidRenalFraction
        let uricAcidExcreted = (uricAcidProduced - renalShare) + renalShare * kidney.eff
        let uricAcidRetained = renalShare * (1 - kidney.eff)

        // 8. 残留
        var residues: [DigestionResidue] = []
        var overloads: [OverloadEvent] = []

        // 结构性（fiber/lactose → 大肠，不受能力影响）
        if item.fiberGrams > 0 {
            residues.append(DigestionResidue(foodName: item.food.name, organ: .largeIntestine,
                                             substance: "膳食纤维", amount: item.fiberGrams, kind: .structural))
        }
        if item.lactoseGrams > 0 {
            residues.append(DigestionResidue(foodName: item.food.name, organ: .largeIntestine,
                                             substance: "乳糖", amount: item.lactoseGrams, kind: .structural))
        }
        // 吸收不良（胃/小肠过载 → 大肠）
        if absorptionEff < 1 {
            let lost = absorbable * (1 - absorptionEff)
            if lost > 0.01 {
                residues.append(DigestionResidue(foodName: item.food.name, organ: .largeIntestine,
                                                 substance: "未吸收营养", amount: lost, kind: .overload))
            }
        }
        // 脏器过载残留
        func addOverload(_ organ: DigestiveOrgan, _ unmet: Double, substance: String? = nil) {
            guard unmet > 0.01 else { return }
            let sub = substance ?? organ.overloadSubstance
            residues.append(DigestionResidue(foodName: item.food.name, organ: organ,
                                             substance: sub, amount: unmet, kind: .overload))
            overloads.append(OverloadEvent(foodName: item.food.name, organ: organ,
                                           substance: sub, unmetAmount: unmet))
        }
        addOverload(.liver, liver.unmet)
        addOverload(.pancreas, pancreas.unmet)
        // 肾过载：尿酸与尿素分别滞留
        if uricAcidRetained > 0.5 {
            addOverload(.kidney, uricAcidRetained, substance: "尿酸滞留")
        }
        if ureaRetained > 0.5 {
            addOverload(.kidney, ureaRetained, substance: "尿素滞留")
        }

        let result = FoodDigestionResult(
            foodName: item.food.name,
            grams: item.grams,
            calories: item.calories,
            atpMoles: atp,
            co2Grams: co2,
            waterGrams: water,
            absorbedGlucoseG: absorbedGlucose,
            absorbedAminoAcidG: absorbedAminoAcid,
            absorbedFattyAcidG: absorbedFattyAcid,
            bloodGlucoseMg: bloodGlucoseMg,
            insulinResponse: insulinResponse,
            ureaProducedMg: ureaProduced,
            ureaExcretedMg: ureaExcreted,
            ureaRetainedMg: ureaRetained,
            uricAcidProducedMg: uricAcidProduced,
            uricAcidExcretedMg: uricAcidExcreted,
            uricAcidRetainedMg: uricAcidRetained,
            residues: residues,
            overloads: overloads
        )
        results.append(result)
        self.residues.append(contentsOf: residues)
        return result
    }

    /// 累积报告简版文本（画布累积信息泡泡用；详细分析在报告页结合问卷做）
    var cumulativeReportText: String {
        guard !results.isEmpty else { return "尚未吃入食物" }
        return "已吃入 \(results.count) 份，累计 \(Int(totalCalories)) kcal、"
             + "\(String(format: "%.2f", totalATP)) mol ATP、产尿酸 \(Int(totalUricAcidProducedMg)) mg"
             + (totalUricAcidRetainedMg > 0.5 ? "（滞留 \(Int(totalUricAcidRetainedMg)) mg）" : "）") + "。"
    }
}
