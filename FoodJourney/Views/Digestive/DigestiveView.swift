import SwiftUI

/// 消化道主视图 — 还原 HTML 原型的完整交互
struct DigestiveView: View {
    let meal: Meal
    let onComplete: () -> Void

    @StateObject private var viewModel: DigestionViewModel

    init(meal: Meal, onComplete: @escaping () -> Void) {
        self.meal = meal
        self.onComplete = onComplete
        self._viewModel = StateObject(wrappedValue: DigestionViewModel(meal: meal))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            navbar

            // 营养类型 Chip 行
            chipRow

            // 消化道 Canvas（带粒子动画）
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { _ in
                DigestiveCanvasView(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 底部详情面板
            detailPanel
        }
        .background(Color(hex: "0d0d1a")!)
        .preferredColorScheme(.dark)
    }

    // MARK: - 导航栏

    private var navbar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("消化路径")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "e8e8f0")!)
                Text("\(meal.foodNamesText) · 点击器官查看详情")
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: "5555aa")!)
            }
            Spacer()
            Text("进行中")
                .font(.system(size: 8))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color(hex: "0F6E56")!)
                .foregroundColor(Color(hex: "9FE1CB")!)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hex: "111128")!)
    }

    // MARK: - 营养类型 Chip

    private var chipRow: some View {
        HStack(spacing: 5) {
            ForEach(NutrientType.allCases) { type in
                NutrientChipView(
                    type: type,
                    isSelected: viewModel.selectedNutrient == type
                ) {
                    viewModel.selectNutrient(type)
                }
            }

            Spacer()

            // 查看总结按钮
            Button(action: onComplete) {
                HStack(spacing: 3) {
                    Text("查看总结")
                        .font(.system(size: 9, weight: .medium))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundColor(Color(hex: "9FE1CB")!)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "0F6E56")!)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: "111128")!)
    }

    // MARK: - 详情面板

    private var detailPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.detailTitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "c0c0e8")!)

            Text(viewModel.detailDesc)
                .font(.system(size: 9))
                .foregroundColor(viewModel.selectedOrganId != nil
                    ? Color(hex: "9999bb")!
                    : Color(hex: "444466")!)
                .lineSpacing(2)

            if !viewModel.detailTags.isEmpty {
                HStack(spacing: 3) {
                    ForEach(viewModel.detailTags, id: \.text) { tag in
                        OrganTagView(tag: tag)
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: "111128")!)
    }
}

#Preview {
    DigestiveView(meal: Meal()) {}
}
