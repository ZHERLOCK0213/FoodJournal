import SwiftUI

/// 已吃入列表：展开查看各份食物，可删除单份（点错重复时用）
struct EatenItemsSheet: View {
    let viewModel: LiveSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    if viewModel.session.items.isEmpty {
                        Text("尚未吃入食物")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                            .frame(maxWidth: .infinity).padding(.vertical, 40)
                    } else {
                        ForEach(Array(viewModel.session.items.enumerated()), id: \.element.id) { idx, item in
                            row(idx: idx, item: item)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "0d0d1a")!)
            .preferredColorScheme(.dark)
            .navigationTitle("已吃入 \(viewModel.session.foodCount) 份")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }.foregroundColor(AppTheme.primaryLight)
                }
            }
        }
    }

    private func row(idx: Int, item: FoodItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
          HStack(spacing: 10) {
            Text("\(idx + 1)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.primaryLight)
                .frame(width: 22, height: 22)
                .background(Color(hex: "1a3a30")!)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.food.name).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .accessibilityIdentifier("eaten-item-\(item.food.catalogID)")
                Text("\(Int(item.grams))g · \(Int(item.calories)) kcal · \(item.food.portionSourceLabel)")
                    .font(.system(size: 11)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            }
            Spacer()

            Button {
                viewModel.removeEaten(at: idx)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "D85A30")!)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("remove-eaten-\(item.food.catalogID)")
          }
          if !item.food.displayPreparation.isEmpty {
              Text(item.food.displayPreparation)
                  .font(.system(size: 10)).foregroundStyle(.secondary)
          }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color(hex: "111128")!)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

}
