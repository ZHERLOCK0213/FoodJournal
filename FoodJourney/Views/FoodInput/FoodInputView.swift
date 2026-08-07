import SwiftUI

/// 屏1：今天午餐 — 食物输入页
struct FoodInputView: View {
    let meal: Meal
    let onProceed: () -> Void

    @State private var viewModel: FoodInputViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(meal: Meal, onProceed: @escaping () -> Void) {
        self.meal = meal
        self.onProceed = onProceed
        self._viewModel = State(initialValue: FoodInputViewModel(meal: meal))
    }

    var body: some View {
        VStack(spacing: 0) {
            navbar
            foodChips
            nutrientBars
            Spacer(minLength: 0)
            bottomArea
        }
        .background(AppTheme.background(scheme: colorScheme))
    }

    // MARK: - 导航栏

    private var navbar: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("今天午餐")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text("点击食物查看代谢路径")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.primaryLight.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.primary)
    }

    // MARK: - 食物 Chip 区域

    private var foodChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择食物")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                .padding(.horizontal, 16)

            FlowLayout(spacing: 8) {
                ForEach(viewModel.availableFoods) { food in
                    FoodChipView(
                        food: food,
                        isSelected: meal.isSelected(food),
                        grams: meal.items.first(where: { $0.food.id == food.id })?.grams ?? 0
                    ) {
                        viewModel.toggleFood(food)
                    }
                }
            }
            .padding(.horizontal, 16)

            // 克重调节（选中食物时显示）
            if let detail = viewModel.detailFood,
               let item = meal.items.first(where: { $0.food.id == detail.id }) {
                gramAdjuster(food: detail, currentGrams: item.grams)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - 克重调节器

    private func gramAdjuster(food: Food, currentGrams: Double) -> some View {
        HStack(spacing: 12) {
            Text(food.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))

            Spacer()

            Button(action: {
                meal.setGrams(max(25, currentGrams - 25), for: food.id)
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.primary)
            }
            .buttonStyle(.plain)

            Text("\(Int(currentGrams))g")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
                .frame(width: 50)

            Button(action: {
                meal.setGrams(min(500, currentGrams + 25), for: food.id)
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.surface(scheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }

    // MARK: - 营养素进度条

    private var nutrientBars: some View {
        VStack(spacing: 10) {
            NutrientProgressBarView(
                nutrient: .carb,
                grams: meal.totalCarbGrams,
                maxGrams: 80
            )
            NutrientProgressBarView(
                nutrient: .fat,
                grams: meal.totalFatGrams,
                maxGrams: 40
            )
            NutrientProgressBarView(
                nutrient: .protein,
                grams: meal.totalProteinGrams,
                maxGrams: 50
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - 底部区域

    private var bottomArea: some View {
        VStack(spacing: 0) {
            // 总热量栏
            HStack {
                Text("总热量")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                Spacer()
                Text("\(Int(meal.totalCalories)) kcal")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.surface(scheme: colorScheme))

            // 食物产出表现按钮（选中食物后出现）
            if meal.canProceed {
                Button(action: onProceed) {
                    HStack(spacing: 6) {
                        Text("食物产出表现")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.surface(scheme: colorScheme))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// MARK: - 流式布局

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(
                x: bounds.minX + position.x,
                y: bounds.minY + position.y
            ), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidthUsed: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxWidthUsed = max(maxWidthUsed, currentX)
        }

        return (CGSize(width: maxWidthUsed, height: currentY + rowHeight), positions)
    }
}
