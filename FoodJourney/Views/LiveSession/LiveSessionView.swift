import SwiftUI

/// live 会话主屏：食物选择 → 画布动画 → "吃进去" / "我吃完了"（切到代谢报告 Tab）
struct LiveSessionView: View {
    let viewModel: LiveSessionViewModel
    let prefs: UserPreferences
    @Binding var selectedTab: Int
    @State private var showEatenList = false
    @State private var showResetConfirm = false
    @State private var showFoodCatalog = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            navbar
            foodChips
            AnatomyExplorerView(viewModel: viewModel, prefs: prefs)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomBar
        }
        .background(Color(hex: "0d0d1a")!)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showEatenList) {
            EatenItemsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showFoodCatalog) {
            FoodCatalogView(
                library: viewModel.library,
                selectedCatalogID: viewModel.selectedFood?.catalogID,
                select: { viewModel.selectedFood = $0 }
            )
        }
        .onChange(of: viewModel.library.revision) { _, _ in
            if let selected = viewModel.selectedFood {
                viewModel.selectedFood = viewModel.library.food(with: selected.catalogID)
            }
        }
        .alert("本机存储", isPresented: Binding(get: { viewModel.library.storageMessage != nil },
                                              set: { if !$0 { viewModel.library.storageMessage = nil } })) {
            Button("好") { viewModel.library.storageMessage = nil }
        } message: { Text(viewModel.library.storageMessage ?? "") }
        .alert("重置饮食", isPresented: $showResetConfirm) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) { viewModel.reset() }
        } message: {
            Text("将清空已吃入的 \(viewModel.session.foodCount) 份食物及代谢记录。")
        }
    }

    private var navbar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("消化预演").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                // 累积文本可点开已吃入列表（有份数时）
                Button {
                    showEatenList = true
                } label: {
                    HStack(spacing: 3) {
                        Text(viewModel.session.foodCount == 0
                             ? "选择食物，观察消化旅程"
                             : "已选 \(viewModel.session.distinctFoodCount)/10 种 · \(viewModel.session.foodCount) 份 · 查看记录")
                            .font(.system(size: 9)).foregroundColor(AppTheme.primaryLight.opacity(0.85))
                            .lineLimit(2)
                        if viewModel.session.foodCount > 0 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(AppTheme.primaryLight.opacity(0.6))
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.session.foodCount == 0)
                .accessibilityIdentifier("open-eaten-items")
            }
            Spacer()
            // 重置饮食：清空当前顿，回到空画布重新预演
            Button {
                showResetConfirm = true
            } label: {
                Text("重置饮食")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(viewModel.session.foodCount == 0
                                     ? Color(hex: "444466")!
                                     : Color(hex: "D85A30")!)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.session.foodCount == 0)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Color(hex: "111128")!)
    }

    private var foodChips: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6),
                                count: dynamicTypeSize.isAccessibilitySize ? 2 : 4), spacing: 6) {
            ForEach(viewModel.library.quickFoods, id: \.catalogID) { food in
                Button { viewModel.selectedFood = food } label: {
                    Text(food.name).font(.subheadline.weight(.medium)).lineLimit(1)
                        .frame(maxWidth: .infinity, minHeight: 44).padding(.horizontal, 5)
                        .background(viewModel.selectedFood?.catalogID == food.catalogID ? AppTheme.primary : Color.white.opacity(0.07), in: Capsule())
                }.buttonStyle(.plain)
                    .accessibilityLabel(food.name)
                    .accessibilityIdentifier("quick-food-\(food.catalogID)")
                    .accessibilityAddTraits(viewModel.selectedFood?.catalogID == food.catalogID ? .isSelected : [])
            }
            Button { showFoodCatalog = true } label: {
                Text("全部食物").font(.subheadline.weight(.semibold)).lineLimit(1)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .foregroundStyle(AppTheme.primaryLight)
                    .background(Color(hex: "1a3a30")!, in: Capsule())
            }.buttonStyle(.plain).accessibilityIdentifier("open-food-catalog")
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .disabled(viewModel.phase != .idle)
        .accessibilityIdentifier("food-picker")
        .background(Color(hex: "111128")!)
    }

    private var bottomBar: some View {
        VStack(spacing: 4) {
            if let reason = viewModel.selectionBlockReason {
                Label(reason, systemImage: viewModel.selectedFood?.canPreview == false ? "hourglass" : "exclamationmark.circle")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AnatomyArtwork.color("FFBE72"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier(viewModel.selectedFood?.canPreview == false ? "selected-food-pending" : "selection-block-reason")
            }
            HStack(spacing: 10) {
                Menu {
                    ForEach([50, 100, 200, 300, 500], id: \.self) { grams in
                        Button("\(grams)g") { viewModel.selectedGrams = Double(grams) }
                            .accessibilityIdentifier("portion-\(grams)")
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text("\(Int(viewModel.selectedGrams))g")
                        Image(systemName: "chevron.up.chevron.down").font(.system(size: 9))
                    }.font(.system(size: 12, weight: .medium)).frame(minWidth: 55, minHeight: 44)
                }
                .disabled(viewModel.phase != .idle)
                .accessibilityLabel("食物份量")
                .accessibilityValue("\(Int(viewModel.selectedGrams))g")
                .accessibilityIdentifier("portion-picker")
                // 选食物
                Button {
                    viewModel.eatIn()
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedFood?.name ?? "选食物").font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.down.circle.fill").font(.system(size: 13))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 12)
                    .background(viewModel.canEat ? AppTheme.primary : Color(hex: "333344")!)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canEat)
                .accessibilityIdentifier("eat-button")

                Spacer()

                // 查看报告 → 切到代谢报告 Tab
                Button {
                    selectedTab = 1
                } label: {
                    HStack(spacing: 4) {
                        Text("查看报告").font(.system(size: 13, weight: .bold))
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.primaryLight)
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(viewModel.canFinish ? Color(hex: "1a3a30")! : Color(hex: "222230")!)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canFinish)
                .accessibilityIdentifier("report-button")
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color(hex: "111128")!)
    }
}
