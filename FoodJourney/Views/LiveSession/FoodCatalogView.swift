import SwiftUI

struct FoodCatalogView: View {
    let library: FoodLibrary
    var selectedCatalogID: String? = nil
    var select: ((Food) -> Void)? = nil
    var personalOnly = false
    @State private var query = ""
    @State private var showPersonal = false
    @State private var showEditor = false
    @State private var detailID: String?
    @Environment(\.dismiss) private var dismiss

    private var filteredFoods: [Food] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return library.foods.filter { food in
            (!(personalOnly || showPersonal) || food.isCustom) &&
            (needle.isEmpty || food.name.localizedCaseInsensitiveContains(needle) ||
             food.displayPreparation.localizedCaseInsensitiveContains(needle))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !personalOnly {
                    Picker("食物范围", selection: $showPersonal) {
                        Text("全部").tag(false)
                        Text("我的食物").tag(true)
                    }.pickerStyle(.segmented).listRowBackground(Color.clear)
                }
                ForEach(filteredFoods, id: \.catalogID) { food in
                    HStack(spacing: 12) {
                        if let select {
                            Button {
                                select(food)
                                dismiss()
                            } label: { rowLabel(food) }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("catalog-select-\(food.catalogID)")
                            Button { detailID = food.catalogID } label: {
                                Image(systemName: "info.circle").frame(minWidth: 44, minHeight: 44)
                            }.buttonStyle(.borderless).fixedSize()
                                .accessibilityLabel("\(food.name)详情")
                        } else {
                            NavigationLink { FoodDetailView(library: library, food: food) } label: { rowLabel(food) }
                        }
                    }.listRowBackground(Color.white.opacity(0.035))
                }
                if filteredFoods.isEmpty {
                    ContentUnavailableView(
                        query.isEmpty ? "还没有自建食物" : "没有匹配的食物",
                        systemImage: "fork.knife",
                        description: Text(query.isEmpty ? "点击右上角新增。" : "尝试其他名称，或新增自己的食物。"))
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AnatomyArtwork.color("0D1020"))
            .navigationTitle(personalOnly ? "我的食物" : "全部食物")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索食物")
            .accessibilityIdentifier("food-catalog")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }.accessibilityIdentifier("close-food-catalog")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("新增", systemImage: "plus") { showEditor = true }
                        .accessibilityIdentifier("new-personal-food")
                }
            }
            .sheet(isPresented: $showEditor) { PersonalFoodEditor(library: library) }
            .navigationDestination(item: $detailID) { id in
                if let food = library.food(with: id) { FoodDetailView(library: library, food: food) }
            }
        }.preferredColorScheme(.dark)
    }

    private func rowLabel(_ food: Food) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(food.name).font(.headline).foregroundStyle(.primary)
                if food.isCustom { Text("自建").font(.caption).foregroundStyle(AppTheme.primaryLight) }
                if selectedCatalogID == food.catalogID { Image(systemName: "checkmark").foregroundStyle(AppTheme.primaryLight) }
            }
            if !food.displayPreparation.isEmpty {
                Text(food.displayPreparation).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Text("每100g · \(food.caloriesPer100g.formatted(.number.precision(.fractionLength(0)))) kcal")
                .font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, minHeight: 52, alignment: .leading).contentShape(Rectangle())
    }
}

struct FoodDetailView: View {
    let library: FoodLibrary
    let food: Food
    @State private var editorRequest: EditorRequest?
    @State private var confirmDelete = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    private var current: Food { library.food(with: food.catalogID) ?? food }

    private struct EditorRequest: Identifiable {
        let id = UUID()
        let record: PersonalFood
        let editing: Bool
        let copiedTrace: Bool
    }

    var body: some View {
        List {
            Section {
                Text(current.name).font(.title3.bold())
                Text(current.portionSourceLabel).font(.caption).foregroundStyle(.secondary)
                if !current.displayPreparation.isEmpty { Text(current.displayPreparation) }
            }
            Section("每100g可食部分") {
                nutrient("热量", current.caloriesPer100g, unit: "kcal")
                nutrient("碳水化合物", current.carbPer100g)
                nutrient("蛋白质", current.proteinPer100g)
                nutrient("脂肪", current.fatPer100g)
                nutrient(current.compositionReference?.fiber?.isEstimate == true ? "纤维（估算）" : "纤维", current.knownFiberPer100g)
                if current.compositionReference?.lactoseIsTrace == true {
                    LabeledContent("乳糖", value: "微量")
                } else {
                    nutrient(current.compositionReference?.lactose?.isEstimate == true ? "乳糖（估算）" : "乳糖", current.knownLactosePer100g)
                }
                nutrient(current.purineIsEstimated ? "嘌呤（估算）" : "嘌呤", current.knownPurinePer100g, unit: "mg")
            }
            Section {
                if let id = current.customID, let record = library.personalFood(id: id) {
                    Button("编辑食物") { editorRequest = EditorRequest(record: record, editing: true, copiedTrace: false) }
                        .accessibilityIdentifier("edit-personal-food")
                    Button("删除食物", role: .destructive) { confirmDelete = true }
                        .accessibilityIdentifier("delete-personal-food")
                    Text("自建成分由你填写；编辑不改变已加入餐食的数据。")
                        .font(.caption).foregroundStyle(.secondary)
                } else if !current.isCustom {
                    Button("复制为我的食物") {
                        editorRequest = EditorRequest(record: .copy(of: current), editing: false,
                                                      copiedTrace: current.compositionReference?.lactoseIsTrace == true)
                    }.accessibilityIdentifier("copy-personal-food")
                    Text("公共食物不可修改。不同品牌、配方和生熟状态的成分会有差异。")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("食物详情").navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editorRequest) { request in
            PersonalFoodEditor(library: library, initial: request.record, editing: request.editing,
                               copiedTrace: request.copiedTrace)
        }
        .alert("删除\(current.name)？", isPresented: $confirmDelete) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                guard let id = current.customID else { return }
                do { try library.delete(id: id); dismiss() }
                catch { errorMessage = error.localizedDescription }
            }
        } message: { Text("将从我的食物和最近使用中移除，无法撤销。已加入餐食的数据保留。") }
        .alert("未能完成", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("好") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func nutrient(_ name: String, _ value: Double?, unit: String = "g") -> some View {
        LabeledContent(name, value: value.map { $0.formatted(.number.precision(.fractionLength(1))) + unit } ?? "未提供")
    }
}
