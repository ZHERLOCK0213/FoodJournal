import SwiftUI

/// live 会话主屏：食物选择 → 画布动画 → "吃进去" / "我吃完了"（切到代谢报告 Tab）
struct LiveSessionView: View {
    let viewModel: LiveSessionViewModel
    @Binding var selectedTab: Int
    @State private var showEatenList = false
    @State private var showResetConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            navbar
            foodChips
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                LiveSessionCanvasView(viewModel: viewModel, date: timeline.date)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomBar
        }
        .background(Color(hex: "0d0d1a")!)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showEatenList) {
            EatenItemsSheet(viewModel: viewModel)
        }
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
                        Text(viewModel.session.cumulativeReportText)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.foods) { food in
                    FoodChipView(food: food,
                                 isSelected: viewModel.selectedFood?.id == food.id,
                                 grams: 100) {
                        viewModel.selectedFood = food
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
        }
        .background(Color(hex: "111128")!)
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            // 选食物
            Button {
                viewModel.eatIn()
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.selectedFood?.name ?? "选食物").font(.system(size: 13, weight: .semibold))
                    Image(systemName: "arrow.down.circle.fill").font(.system(size: 13))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(viewModel.canEat ? AppTheme.primary : Color(hex: "333344")!)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canEat)

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
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color(hex: "111128")!)
    }
}
