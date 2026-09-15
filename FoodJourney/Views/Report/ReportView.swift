import SwiftUI

/// Whole-meal intake analysis and qualitative organ roles. No capacity-derived clinical outputs.
struct ReportView: View {
    let session: DigestionSession
    let prefs: UserPreferences
    @State private var selectedRole: PancreasRole?
    private var meal: MealEducationSummary { MealEducationSummary(items: session.items) }
    private var urateEducation: UrateEducation? { UrateEducation(focus: prefs.focus, meal: meal) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if meal.foodCount == 0 {
                    ContentUnavailableView("还没有预演食物", systemImage: "fork.knife",
                                           description: Text("先回到消化预演，选择一份食物。"))
                        .accessibilityIdentifier("report-empty")
                } else {
                    compositionCard
                    if let analysis = MealFocusAnalysis(items: session.items, focus: prefs.focus) {
                        MealFocusAnalysisView(analysis: analysis, hydration: prefs.hydration).reportCard()
                    }
                    foodsCard
                    if let urateEducation {
                        DisclosureGroup("嘌呤与尿酸") {
                            UrateEducationView(education: urateEducation, scope: mealScope)
                        }.accessibilityIdentifier("report-urate-toggle").reportCard()
                    }
                    pancreasCard
                    organCard
                    sourceCard
                }
            }
            .padding(16).padding(.bottom, 88)
        }
        .accessibilityIdentifier("meal-report-scroll")
        .background(AnatomyArtwork.color("0D1020"))
        .preferredColorScheme(.dark)
        .navigationTitle("代谢报告").navigationBarTitleDisplayMode(.inline)
        .onChange(of: session.foodCount) { _, count in
            if count == 0 { selectedRole = nil }
        }
        .sheet(item: $selectedRole) { role in
            PancreasProcessView(meal: meal, scope: mealScope, role: role)
        }
    }

    private var mealScope: String {
        "本餐合计 · \(meal.distinctFoodCount) 种 · \(meal.foodCount) 份记录"
    }

    private var compositionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本餐食物成分").font(.headline)
            Text("\(meal.distinctFoodCount) 种 · \(meal.foodCount) 份记录 · 合计 \(MealEducationSummary.gramsText(meal.grams))")
                .font(.subheadline).foregroundStyle(.secondary)
            metric("碳水化合物", meal.carbs, id: "carbs")
            metric("蛋白质", meal.protein, id: "protein")
            metric("脂肪", meal.fat, id: "fat")
            metric("纤维", meal.fiberText, id: "fiber")
            if !meal.fiberIsComplete {
                Text("未提供纤维：\(meal.missingFiberFoods.joined(separator: "、"))。")
                    .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
                    .accessibilityIdentifier("report-fiber-scope")
            }
            metric("乳糖", meal.matrix.totals.lactoseText, id: "lactose")
            metric("嘌呤", optionalMilligrams(meal.matrix.totals.purine) + (meal.matrix.totals.purine == nil ? "" : meal.matrix.totals.purineQualifier), id: "purine")
            metric("食物热量", "\(meal.calories.formatted(.number.precision(.fractionLength(0)))) kcal", id: "calories")
            Text("食物成分参考，非个人吸收量。")
                .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
        }.reportCard()
    }

    private var pancreasCard: some View {
        DisclosureGroup("胰腺作用") {
            ForEach(PancreasRole.allCases) { role in
                Button { selectedRole = role } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(role.title).font(.subheadline.weight(.semibold))
                            Text(role.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(12).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("report-pancreas-\(role.rawValue)")
            }
        }.accessibilityIdentifier("report-pancreas-toggle").reportCard()
    }

    private var foodsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("食物成分矩阵").font(.headline)
            Text("相同食物与配方合并显示。")
                .font(.caption).foregroundStyle(.secondary)
            ForEach(meal.matrix.rows) { row in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(row.food.name).font(.subheadline.weight(.semibold))
                            .accessibilityIdentifier("report-food-row-\(row.id)")
                        Spacer()
                        if row.portionCount > 1 {
                            Text("合并 \(row.portionCount) 份").font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.primaryLight)
                                .accessibilityIdentifier("report-merged-count-\(row.id)")
                        }
                    }
                    if row.food.isCustom {
                        Text(row.food.portionSourceLabel).font(.caption).foregroundStyle(AppTheme.primaryLight)
                    }
                    nutrientMatrix(for: row)
                    Text(auxiliaryText(for: row))
                        .font(.caption2).foregroundStyle(.secondary)
                        .accessibilityIdentifier("report-auxiliary-\(row.id)")
                    if !row.food.displayPreparation.isEmpty {
                        DisclosureGroup {
                            Text(row.food.displayPreparation)
                                .font(.caption).foregroundStyle(.secondary).padding(.top, 4)
                        } label: {
                            Text("配方说明")
                                .accessibilityIdentifier("report-source-toggle-\(row.id)")
                        }.font(.caption)
                    }
                }
                .padding(12)
                .background(.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 12))
            }
            Divider()
            if meal.items.contains(where: { !$0.food.isCustom }) {
                Text("公共食物参考网站").font(.subheadline.weight(.medium))
                ForEach(FoodCompositionSource.allCases) { source in
                    Link(source.title + " ↗", destination: source.url)
                        .font(.caption)
                        .accessibilityIdentifier("report-composition-source-\(source.id)")
                }
            }
            if meal.items.contains(where: { $0.food.isCustom }) {
                Text("自建食物使用你填写的成分，不属于公共来源的验证范围。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }.reportCard()
    }

    private var organCard: some View {
        DisclosureGroup("其他器官如何协作") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(AnatomyPart.allCases.filter { $0 != .pancreas }) { part in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(part.label).font(.subheadline.weight(.semibold)).foregroundStyle(AnatomyArtwork.asset(part).color)
                        Text(meal.explanation(for: part)).font(.subheadline).lineSpacing(3)
                        Link("NIDDK 来源 ↗", destination: part.source).font(.caption)
                    }
                }
            }.padding(.top, 12)
        }.font(.headline).reportCard()
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            DisclosureGroup("数据与来源说明") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("数值按可食部分与份量换算。未提供不等于0；部分记录显示小计，微量不换算为具体克数。")
                    Text("公共成分可能来自不同样本；品牌、配方与生熟状态影响数值。纤维可能采用总膳食纤维或不溶性纤维口径，不能视为统一口径的总膳食纤维。")
                        .accessibilityIdentifier("report-nutrient-basis")
                    Text("消化过程为生理示意，不能据此预测个人血糖、血尿酸或器官功能。")
                    Link("消化与吸收 · NIDDK ↗", destination: AnatomyPart.smallIntestine.source)
                    Link("胰岛素与葡萄糖 · NIDDK ↗", destination: PancreasRole.insulinSource)
                }.padding(.top, 8)
            }
        }.font(.footnote).reportCard()
    }

    private func metric(_ label: String, _ amount: Double, id: String) -> some View {
        metric(label, MealEducationSummary.gramsText(amount), id: id)
    }

    private func metric(_ label: String, _ value: String, id: String) -> some View {
        HStack {
            Text(label)
            if prefs.focus.metricID == id {
                Image(systemName: "bookmark.fill").font(.caption).accessibilityLabel("关注成分")
            }
            Spacer()
            Text(value).monospacedDigit().multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .fontWeight(prefs.focus.metricID == id ? .semibold : .regular)
        .foregroundStyle(prefs.focus.metricID == id ? AppTheme.primaryLight : Color.primary)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("report-total-\(id)")
        .accessibilityValue(value)
    }

    private func nutrientMatrix(for row: MealNutrientMatrix.Row) -> some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 4) {
            GridRow {
                ForEach(["克重", "碳水", "蛋白", "脂肪", "热量(kcal)"], id: \.self) { label in
                    Text(label).frame(maxWidth: .infinity)
                }
            }.font(.caption2).foregroundStyle(.secondary)
            GridRow {
                Text(MealEducationSummary.gramsText(row.grams))
                Text(MealEducationSummary.gramsText(row.carbs))
                Text(MealEducationSummary.gramsText(row.protein))
                Text(MealEducationSummary.gramsText(row.fat))
                Text("\(row.calories.formatted(.number.precision(.fractionLength(0))))")
            }.font(.caption.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("report-primary-\(row.id)")
        .accessibilityValue("克重 \(MealEducationSummary.gramsText(row.grams))，碳水 \(MealEducationSummary.gramsText(row.carbs))，蛋白 \(MealEducationSummary.gramsText(row.protein))，脂肪 \(MealEducationSummary.gramsText(row.fat))，热量 \(row.calories.formatted(.number.precision(.fractionLength(0)))) kcal")
    }

    private func auxiliaryText(for row: MealNutrientMatrix.Row) -> String {
        var known: [String] = []
        if let fiber = row.fiber { known.append("纤维 \(MealEducationSummary.gramsText(fiber))") }
        if row.lactose != nil || row.values.lactoseHasTrace { known.append("乳糖 \(row.values.lactoseText)") }
        if let purine = row.purine { known.append("嘌呤 \(purine.formatted(.number.precision(.fractionLength(1))))mg\(row.values.purineQualifier)") }
        return known.isEmpty ? "纤维、乳糖、嘌呤未提供" : known.joined(separator: " · ") + (known.count < 3 ? " · 其余未提供" : "")
    }

    private func optionalMilligrams(_ value: Double?) -> String {
        value.map { $0.formatted(.number.precision(.fractionLength(1))) + "mg" } ?? "暂无记录"
    }

}

private extension View {
    func reportCard() -> some View {
        self.padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.07)))
    }
}
