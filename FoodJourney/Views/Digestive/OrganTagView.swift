import SwiftUI

/// 器官代谢标签
struct OrganTagView: View {
    let tag: OrganTag

    var body: some View {
        Text(tag.text)
            .font(.system(size: 10))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tag.backgroundColor)
            .foregroundColor(tag.foregroundColor)
            .clipShape(Capsule())
    }
}

extension OrganTag {
    var backgroundColor: Color {
        switch style {
        case .enzyme:  return Color(hex: "1a1030")!
        case .product: return Color(hex: "0e1f18")!
        case .timing:  return Color(hex: "2a1f0a")!
        }
    }

    var foregroundColor: Color {
        switch style {
        case .enzyme:  return Color(hex: "AFA9EC")!
        case .product: return Color(hex: "5DCAA5")!
        case .timing:  return Color(hex: "EF9F27")!
        }
    }
}
