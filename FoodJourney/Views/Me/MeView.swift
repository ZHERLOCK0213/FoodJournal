import SwiftUI

struct MeView: View {
    @Bindable var prefs: UserPreferences
    let library: FoodLibrary
    @State private var showFoods = false

    var body: some View {
        List {
            Section { LearningFocusSection(prefs: prefs) }
            Section {
                Button { showFoods = true } label: {
                    Label("我的食物", systemImage: "fork.knife")
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }.accessibilityIdentifier("my-foods")
                NavigationLink("数据管理") { LocalDataView(library: library) }
                NavigationLink("关于与资料来源") { AboutFoodJourneyView() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AnatomyArtwork.color("0D1020"))
        .preferredColorScheme(.dark)
        .navigationTitle("我").navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFoods) { FoodCatalogView(library: library, personalOnly: true) }
    }
}

private struct LocalDataView: View {
    let library: FoodLibrary
    @State private var confirmClear = false
    @State private var errorMessage: String?
    var body: some View {
        List {
            Section {
                LabeledContent("自建食物", value: "\(library.personalFoods.count)种")
                Text("自建食物、最近使用、关注主题和饮水选项保存在本机，不跨设备同步。卸载可能导致数据丢失。")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text("重置本餐不会删除自建食物或最近使用。当前餐食不作为历史记录保存。")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Section {
                Button("清空最近使用", role: .destructive) { confirmClear = true }
                    .disabled(library.recentIDs.isEmpty)
            }
            if let message = library.storageMessage { Text(message).foregroundStyle(.orange) }
        }
        .navigationTitle("数据管理").navigationBarTitleDisplayMode(.inline)
        .alert("清空最近使用？", isPresented: $confirmClear) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                do { try library.clearRecent() } catch { errorMessage = error.localizedDescription }
            }
        } message: { Text("快捷栏将恢复常用食物，自建食物和当前餐食不变。") }
        .alert("未能完成", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("好") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}

private struct AboutFoodJourneyView: View {
    var body: some View {
        List {
            Section("食物旅行") {
                Text("食物成分与消化过程科普。数值按食物成分和份量计算，非个人吸收量或疾病风险评估。")
                LabeledContent("版本", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
            }
            Section("公共食物参考") {
                ForEach(FoodCompositionSource.allCases) { source in
                    Link(source.title, destination: source.url)
                }
                Text("来源适用于公共食物参考，不代表对自建成分的验证。")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("生理知识") {
                Link("消化与吸收 · NIDDK", destination: AnatomyPart.smallIntestine.source)
                Link("胰岛素与葡萄糖 · NIDDK", destination: PancreasRole.insulinSource)
                Link("嘌呤与尿酸 · MedlinePlus", destination: URL(string: "https://medlineplus.gov/gout.html")!)
            }
        }.navigationTitle("关于与资料来源").navigationBarTitleDisplayMode(.inline)
    }
}
