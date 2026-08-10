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
                    if viewModel.session.results.isEmpty {
                        Text("尚未吃入食物")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                            .frame(maxWidth: .infinity).padding(.vertical, 40)
                    } else {
                        ForEach(Array(viewModel.session.results.enumerated()), id: \.element.id) { idx, r in
                            row(idx: idx, result: r)
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

    private func row(idx: Int, result: FoodDigestionResult) -> some View {
        HStack(spacing: 10) {
            Text("\(idx + 1)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.primaryLight)
                .frame(width: 22, height: 22)
                .background(Color(hex: "1a3a30")!)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(result.foodName).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text("\(Int(result.grams))g · \(Int(result.calories)) kcal")
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
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color(hex: "111128")!)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
