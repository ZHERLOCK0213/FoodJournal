import SwiftUI

/// Automatically presented once each run finishes. Individual results remain available afterward.
struct MealJourneySummaryView: View {
    let journey: MealDigestionJourney
    let focus: (AnatomyPart) -> Void
    let close: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(journey.title).font(.title3.weight(.semibold))
                            .accessibilityIdentifier("journey-meal-title")
                        Text(journey.composition).font(.caption).foregroundStyle(.secondary)
                        Text("按内置食物成分演示典型过程，不是个人代谢测量。动画压缩了时间，各器官在现实中会协同工作。成分数据仍待统一校核。")
                            .font(.caption).foregroundStyle(.secondary)
                    }.padding(.bottom, 4)
                    ForEach(journey.outcomes) { outcome in
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                Circle().fill(AnatomyArtwork.asset(outcome.part).color).frame(width: 8, height: 8)
                                Text(outcome.part.label).font(.headline)
                                Text(outcome.role).font(.caption2).foregroundStyle(.secondary)
                                Spacer()
                                Button("定位") { focus(outcome.part) }
                                    .font(.caption).frame(minWidth: 44, minHeight: 44)
                                    .accessibilityLabel("定位\(outcome.part.label)")
                                    .accessibilityIdentifier("result-focus-\(outcome.part.rawValue)")
                            }
                            Text("过程  \(outcome.process)")
                            Text("结果  \(outcome.result)")
                                .foregroundStyle(AnatomyArtwork.asset(outcome.part).color)
                            Link("资料参考 · NIDDK ↗", destination: outcome.part.source)
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        .font(.subheadline).lineSpacing(3)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.07)))
                        .accessibilityElement(children: .contain)
                    }
                }.padding(16)
            }
            .accessibilityIdentifier("journey-summary-list")
            .background(AnatomyArtwork.color("0D1020"))
            .navigationTitle("本份消化小结")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AnatomyArtwork.color("0D1020"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成", action: close).accessibilityIdentifier("close-journey-summary")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
