import SwiftUI

/// Shared focus card used by the live journey and the meal report.
struct UrateEducationView: View {
    let education: UrateEducation
    let scope: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(education.title, systemImage: "drop.circle")
                .font(.headline)
                .foregroundStyle(AnatomyArtwork.asset(.kidneys).color)
            Text(scope)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(education.context)
                .font(.subheadline)
                .lineSpacing(3)
            educationSection("肾脏如何参与", education.kidneyExplanation)
            if let dietGuidance = education.dietGuidance {
                educationSection("肉类份量提示", dietGuidance)
            }
            Text(education.limitation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
            VStack(alignment: .leading, spacing: 7) {
                Text("资料来源").font(.caption.weight(.semibold))
                ForEach(education.sources.filter { $0.id == "purines" || $0.id == "excretion" }) { source in
                    Link("\(source.title) ↗", destination: source.url)
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(
            AnatomyArtwork.asset(.kidneys).color.opacity(0.35)
        ))
        .accessibilityIdentifier("urate-education-card")
    }

    private func educationSection(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(text).font(.subheadline).lineSpacing(3)
        }
    }
}
