import Foundation

/// A preference-driven explanation of meal inputs, independent of legacy metabolism estimates.
/// Captures its text from a value snapshot so a later selection cannot rewrite an active preview.
struct UrateEducation {
    struct Source: Identifiable {
        let id: String
        let title: String
        let url: URL
    }

    let title = "嘌呤与尿酸"
    let context: String
    let dietGuidance: String?
    let kidneyExplanation = "食物中的嘌呤经分解可形成尿酸。尿酸随血液到达肾脏，可经尿液排出；肠道也参与排出。食物本身不会进入肾脏。"
    let hydrationGuidance = "若未被医护人员要求限水，可在日常中规律饮水；如需限水，请遵循医护建议。"
    let limitation = "食物嘌呤含量不能直接换算为个人血尿酸或排泄量。"
    let sources = [
        Source(id: "purines", title: "NIH MedlinePlus · 嘌呤与尿酸",
               url: URL(string: "https://medlineplus.gov/gout.html")!),
        Source(id: "excretion", title: "NIH MedlinePlus · 尿酸排出途径",
               url: URL(string: "https://medlineplus.gov/genetics/condition/gout/")!),
        Source(id: "hydration", title: "NHS · 饮水与限水提醒",
               url: URL(string: "https://www.nhs.uk/conditions/gout/")!),
        Source(id: "diet", title: "NHS 莱斯特大学医院 · 痛风饮食与份量",
               url: URL(string: "https://yourhealth.leicestershospitals.nhs.uk/library/csi/dietetics/2590-diet-and-nutrition-advice-when-you-have-gout/file")!),
        Source(id: "dietScope", title: "国家卫健委 · 成人高尿酸血症与痛风食养指南问答（2024）",
               url: URL(string: "https://www.nhc.gov.cn/cms-search/downFiles/5d8a03a81dd949158e7d66283c0f1849.pdf")!)
    ]

    init?(focus: HealthFocus, meal: MealEducationSummary) {
        let matrix = meal.matrix
        guard focus == .uricAcid, !matrix.rows.isEmpty else { return nil }
        let purineContext: String
        if let purine = matrix.totals.purine {
            purineContext = "本餐已记录的嘌呤合计 \(purine.formatted(.number.precision(.fractionLength(1))))mg\(matrix.totals.purineQualifier)，仅为食物成分参考。"
        } else {
            purineContext = "本餐食物暂无嘌呤含量记录；未记录不等于不含。"
        }
        context = purineContext
        dietGuidance = nil
    }
}
