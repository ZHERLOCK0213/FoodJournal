import SwiftUI

struct PersonalFoodEditor: View {
    let library: FoodLibrary
    private let original: PersonalFood?
    private let editing: Bool
    private let copiedTrace: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var preparation: String
    @State private var carbs: String
    @State private var protein: String
    @State private var fat: String
    @State private var calories: String
    @State private var fiber: String
    @State private var lactose: String
    @State private var purine: String
    @State private var errorMessage: String?
    @State private var confirmDiscard = false

    init(library: FoodLibrary, initial: PersonalFood? = nil, editing: Bool = false, copiedTrace: Bool = false) {
        self.library = library
        self.original = initial
        self.editing = editing
        self.copiedTrace = copiedTrace
        _name = State(initialValue: initial?.name ?? "")
        _preparation = State(initialValue: initial?.preparation ?? "")
        _carbs = State(initialValue: Self.number(initial?.carbs))
        _protein = State(initialValue: Self.number(initial?.protein))
        _fat = State(initialValue: Self.number(initial?.fat))
        _calories = State(initialValue: Self.number(initial?.calories))
        _fiber = State(initialValue: Self.number(initial?.fiber))
        _lactose = State(initialValue: Self.number(initial?.lactose))
        _purine = State(initialValue: Self.number(initial?.purine))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("名称（必填）", text: $name).accessibilityIdentifier("personal-food-name")
                    TextField("生熟状态、配方或品牌（可选）", text: $preparation, axis: .vertical).lineLimit(2...4)
                }
                Section {
                    amount("碳水化合物", text: $carbs, unit: "g", id: "carbs")
                    amount("蛋白质", text: $protein, unit: "g", id: "protein")
                    amount("脂肪", text: $fat, unit: "g", id: "fat")
                    amount("热量", text: $calories, unit: "kcal", id: "calories")
                } header: { Text("每100g可食部分 · 必填") }
                  footer: { Text("按营养标签或对应配方填写，热量单位为kcal，不是kJ。重量不含骨、皮等不可食部分。") }
                Section {
                    amount("纤维", text: $fiber, unit: "g", id: "fiber")
                    amount("乳糖", text: $lactose, unit: "g", id: "lactose")
                    amount("嘌呤", text: $purine, unit: "mg", id: "purine")
                } header: { Text("每100g可食部分 · 可选") }
                  footer: { Text("不知道的成分留空；只有明确为零时才填0。") }
                if original != nil && !editing {
                    Section {
                        Text("已预填公共参考值，保存后属于自建记录。请核对实际配方。")
                        if copiedTrace { Text("原记录乳糖为微量，无法换算成具体克数，复制后留空。") }
                    }.font(.caption).foregroundStyle(.secondary)
                }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red).accessibilityIdentifier("personal-food-error") }
            }
            .navigationTitle(editing ? "编辑食物" : "新增食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { if hasChanges { confirmDiscard = true } else { dismiss() } }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save).accessibilityIdentifier("save-personal-food")
                }
            }
            .confirmationDialog("放弃未保存的修改？", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("放弃修改", role: .destructive) { dismiss() }
                Button("继续编辑", role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(hasChanges)
    }

    private static func number(_ value: Double?) -> String { value.map { String($0) } ?? "" }

    private var hasChanges: Bool {
        name != (original?.name ?? "") || preparation != (original?.preparation ?? "") ||
        carbs != Self.number(original?.carbs) || protein != Self.number(original?.protein) ||
        fat != Self.number(original?.fat) || calories != Self.number(original?.calories) ||
        fiber != Self.number(original?.fiber) || lactose != Self.number(original?.lactose) ||
        purine != Self.number(original?.purine)
    }

    private func amount(_ label: String, text: Binding<String>, unit: String, id: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("未填写", text: text).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .frame(minWidth: 60).accessibilityLabel(label).accessibilityIdentifier("personal-food-\(id)")
            Text(unit).foregroundStyle(.secondary)
        }
    }

    private func parse(_ text: String, name: String, required: Bool = false) throws -> Double? {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty {
            if required { throw FoodLibrary.LibraryError.message("请填写\(name)，明确不含时填0。") }
            return nil
        }
        guard let amount = Double(value), amount.isFinite, amount >= 0 else {
            throw FoodLibrary.LibraryError.message("请核对\(name)，使用大于或等于0的数字，小数点用“.”。")
        }
        return amount
    }

    private func save() {
        do {
            let record = PersonalFood(id: original?.id ?? UUID(), revision: original?.revision ?? 1,
                name: name, preparation: preparation,
                carbs: try parse(carbs, name: "碳水化合物", required: true)!,
                protein: try parse(protein, name: "蛋白质", required: true)!,
                fat: try parse(fat, name: "脂肪", required: true)!,
                calories: try parse(calories, name: "热量", required: true)!,
                fiber: try parse(fiber, name: "纤维"), lactose: try parse(lactose, name: "乳糖"),
                purine: try parse(purine, name: "嘌呤"))
            try library.save(record, editingID: editing ? original?.id : nil)
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}
