import SwiftUI

struct MealFocusAnalysisView: View {
    let analysis: MealFocusAnalysis
    let hydration: DailyHydration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本餐分析 · \(analysis.focus.title)").font(.headline)
            Text(analysis.totalText).font(.title3.weight(.semibold)).monospacedDigit()
                .accessibilityIdentifier("focus-analysis-total")
            Label(analysis.attention.rawValue,
                  systemImage: analysis.attention == .stopAdding ? "exclamationmark.circle" : "info.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(analysis.attention == .stopAdding ? Color.orange : Color.secondary)
                .accessibilityIdentifier("focus-analysis-direction")
            Text(analysis.finding).font(.subheadline)
            if !analysis.contributors.isEmpty {
                Text("主要来源（按已记录含量，前 3 项）").font(.caption).foregroundStyle(.secondary)
                ForEach(Array(analysis.contributors.prefix(3))) { row in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.name)
                            Text("本餐 \(MealEducationSummary.gramsText(row.portionGrams))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(row.text).monospacedDigit()
                    }.font(.subheadline).accessibilityElement(children: .combine)
                }
            }
            if !analysis.missingFoods.isEmpty {
                Text("未提供：\(analysis.missingFoods.joined(separator: "、"))。未提供不等于 0。")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Text(analysis.action).font(.subheadline)
                .accessibilityIdentifier("focus-analysis-action")
            if analysis.focus == .uricAcid {
                Divider()
                Text("平日饮水 · \(hydration.title)").font(.subheadline.weight(.medium))
                Text(hydration.guidance).font(.caption).foregroundStyle(.secondary)
                    .accessibilityIdentifier("focus-hydration-guidance")
                Link("饮水建议适用范围 · 国家卫健委 ↗", destination: MealFocusAnalysis.hydrationSource)
                    .font(.caption)
            }
            DisclosureGroup("判断依据与适用范围") {
                VStack(alignment: .leading, spacing: 8) {
                    if let reference = analysis.reference { Text(reference) }
                    Text(analysis.limitation)
                    Text("按食物参考成分与所选份量计算；配方差异会影响结果。自建食物依据填写值。")
                    Link("参考资料 ↗", destination: analysis.source)
                    if analysis.focus == .lipids {
                        Link("脂肪种类与饮食搭配 · WHO ↗", destination: MealFocusAnalysis.dietSource)
                    }
                }.font(.caption).foregroundStyle(.secondary).padding(.top, 8)
            }.font(.caption)
            // Show the daily scope next to the comparison, even when the disclosure is collapsed.
            if let reference = analysis.reference {
                Text(reference).font(.caption).foregroundStyle(.secondary)
            }
        }.accessibilityElement(children: .contain)
            .accessibilityIdentifier("meal-focus-analysis")
    }
}
