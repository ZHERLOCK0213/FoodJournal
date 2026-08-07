import SwiftUI

/// 代谢物行视图
struct MetaboliteRowView: View {
    let icon: String
    let name: String
    let value: String
    let progress: Double   // 0~1
    let color: Color
    let status: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            // 名称 + 进度条
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppTheme.divider(scheme: colorScheme))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(progress), height: 6)
                    }
                }
                .frame(height: 6)
            }

            // 数值 + 状态
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary(scheme: colorScheme))
                Text(status)
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textTertiary(scheme: colorScheme))
            }
            .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }
}
