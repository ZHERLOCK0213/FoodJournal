import SwiftUI

/// A short, static three-step explanation with a user-controlled role switch.
struct PancreasProcessView: View {
    let meal: MealEducationSummary
    let scope: String
    @State var role: PancreasRole = .digestion
    @Environment(\.dismiss) private var dismiss

    private var tint: Color { role == .digestion ? AnatomyArtwork.asset(.pancreas).color : AnatomyArtwork.asset(.smallIntestine).color }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(scope).font(.subheadline).foregroundStyle(.secondary)
                    HStack(spacing: 10) {
                        ForEach(PancreasRole.allCases) { option in
                            Button {
                                role = option
                            } label: {
                                Text(option.title).font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(role == option ? tint.opacity(0.2) : .white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(role == option ? tint : .clear))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("pancreas-role-\(option.rawValue)")
                            .accessibilityAddTraits(role == option ? .isSelected : [])
                        }
                    }
                    Text(role.context(for: meal)).font(.subheadline).lineSpacing(3)
                    Text(role.subtitle).font(.headline).foregroundStyle(tint)
                    ForEach(role.steps) { step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(step.id + 1)")
                                .font(.headline.monospacedDigit())
                                .frame(width: 30, height: 30)
                                .background(tint.opacity(0.14), in: Circle())
                            VStack(alignment: .leading, spacing: 6) {
                                Text(step.title).font(.headline)
                                Text(step.detail).font(.subheadline).foregroundStyle(.secondary).lineSpacing(3)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08)))
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("pancreas-step-\(step.id)")
                    }
                    Text("各过程可同时发生。")
                        .font(.caption).foregroundStyle(.secondary)
                        .accessibilityIdentifier("pancreas-static-steps-note")
                    Text("过程示意，不模拟个人分泌量、血糖曲线或器官负担。")
                        .font(.caption).foregroundStyle(.secondary)
                    Link("来源：NIDDK · \(role == .digestion ? "消化系统" : "胰岛素与葡萄糖") ↗", destination: role.source)
                        .font(.footnote)
                }.padding(18)
            }
            .accessibilityIdentifier("pancreas-process-scroll")
            .background(AnatomyArtwork.color("0D1020"))
            .navigationTitle("胰腺的两种作用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }.accessibilityIdentifier("close-pancreas-process")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
