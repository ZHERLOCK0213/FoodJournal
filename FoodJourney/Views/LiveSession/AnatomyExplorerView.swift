import SwiftUI

struct AnatomyExplorerView: View {
    let viewModel: LiveSessionViewModel
    let prefs: UserPreferences
    @State private var selected: AnatomyPart?
    // Carry the scope and journey together, instead of opening a Boolean sheet
    // whose content may capture an earlier (nil/all-organs) selection.
    private struct JourneySummaryPresentation: Identifiable {
        let id = UUID()
        let journey: MealDigestionJourney
        let part: AnatomyPart?
    }
    @State private var summaryPresentation: JourneySummaryPresentation?
    @State private var showPancreasProcess = false
    @State private var showUrateEducation = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func select(_ part: AnatomyPart?) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            selected = selected == part ? nil : part
        }
    }

    private func dismissMealSheets() {
        summaryPresentation = nil
        showPancreasProcess = false
        showUrateEducation = false
    }

    /// The live hint is deliberately built from the captured journey item, not the current picker.
    private var urateEducation: UrateEducation? {
        let meal = MealEducationSummary(items: viewModel.journey.map { [$0.item] } ?? [])
        return UrateEducation(focus: prefs.focus, meal: meal)
    }

    var body: some View {
        GeometryReader { available in
          ScrollView(.vertical) {
           VStack(spacing: 0) {
            stage.frame(height: max(424, available.size.height - 154))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(AnatomyPart.allCases) { part in
                        Button { select(part) } label: {
                            HStack(spacing: 5) {
                                Circle().fill(AnatomyArtwork.asset(part).color).frame(width: 6, height: 6)
                                Text(part.label).font(.system(size: 12, weight: .medium))
                            }
                            .padding(.horizontal, 12).frame(minHeight: 44)
                            .background(selected == part ? Color.white.opacity(0.13) : Color.white.opacity(0.035),
                                        in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected == part ? AnatomyArtwork.asset(part).color : .clear, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("organ-choice-\(part.rawValue)")
                        .accessibilityAddTraits(selected == part ? .isSelected : [])
                    }
                }.padding(.horizontal, 14)
            }
            .frame(height: 48)
            .accessibilityIdentifier("organ-picker")

            detailPanel
                .transaction { $0.animation = nil }
                .frame(height: selected == nil ? 94 : 154)
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 6)
           }
          }.accessibilityIdentifier("anatomy-explorer-scroll")
        }
        .foregroundStyle(Color.white.opacity(0.93))
        .background(AnatomyArtwork.color("0D1020"))
        .onChange(of: viewModel.session.foodCount) { _, count in
            if count == 0 {
                selected = nil
                dismissMealSheets()
            }
        }
        .onChange(of: prefs.focus) { _, focus in
            if focus != .uricAcid { showUrateEducation = false }
        }
        .onChange(of: viewModel.completedJourneyID) { _, id in
            // Completion reveals the on-canvas results; do not cover them with a modal sheet.
            if id == nil { dismissMealSheets() }
        }
        .sheet(item: $summaryPresentation) { presentation in
            MealJourneySummaryView(journey: presentation.journey, selectedPart: presentation.part) { part in
                selected = part
                summaryPresentation = nil
            } close: {
                summaryPresentation = nil
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPancreasProcess) {
            PancreasProcessView(
                meal: MealEducationSummary(items: viewModel.journey.map { [$0.item] } ?? []),
                scope: viewModel.journey.map { "本份 · \($0.title)" } ?? "一般生理机制")
        }
        .sheet(isPresented: $showUrateEducation) {
            if let education = urateEducation, let journey = viewModel.journey {
                NavigationStack {
                    ScrollView {
                        UrateEducationView(education: education, scope: "本份 · \(journey.title)")
                            .padding(16)
                    }
                    .background(AnatomyArtwork.color("0D1020"))
                    .navigationTitle("尿酸科普")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("关闭") { showUrateEducation = false }
                                .accessibilityIdentifier("close-urate-education")
                        }
                    }
                }
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var stage: some View {
        GeometryReader { geometry in
            let layout = AnatomyCalloutLayout(size: geometry.size)
            ZStack {
                Canvas { context, _ in
                    for part in AnatomyPart.allCases {
                        let color = AnatomyArtwork.asset(part).color
                        context.stroke(layout.leader(part), with: .color(color.opacity(selected == nil || selected == part ? 0.65 : 0.22)),
                                       style: StrokeStyle(lineWidth: selected == part ? 1.4 : 0.8, lineCap: .round, lineJoin: .round))
                    }
                }.allowsHitTesting(false)
                ZStack {
                    bodyLayer(layout.transform)
                    ForEach(AnatomyArtwork.assets) { asset in
                        organLayer(asset, transform: layout.transform)
                            .opacity(selected == nil || selected == asset.part ? 1
                                     : (viewModel.phase == .idle ? 0.13 : 0.32))
                    }
                    if let selected {
                        organLayer(AnatomyArtwork.asset(selected), transform: layout.transform)
                    }
                    TimelineView(.animation(minimumInterval: 1.0 / 30,
                                             paused: reduceMotion || (selected == nil && viewModel.phase == .idle))) { timeline in
                        Canvas { context, _ in
                            context.concatenate(layout.transform)
                            drawActivity(context, date: timeline.date)
                        }
                    }.allowsHitTesting(false)
                    Canvas { context, _ in
                        for part in AnatomyPart.allCases {
                            let anchor = layout.anchor(part)
                            context.fill(Path(ellipseIn: CGRect(x: anchor.x - 1.7, y: anchor.y - 1.7, width: 3.4, height: 3.4)),
                                         with: .color(AnatomyArtwork.asset(part).color.opacity(selected == nil || selected == part ? 1 : 0.2)))
                        }
                        let end = CGPoint(x: 160, y: 388).applying(layout.transform)
                        context.draw(Text("肛门").font(.system(size: 9)).foregroundColor(.secondary), at: end)
                    }.allowsHitTesting(false)
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    select(AnatomyArtwork.hitTest(location.applying(layout.transform.inverted())))
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("消化系统画布")
                .accessibilityValue(selected?.label ?? "全部器官")
                .accessibilityHint("点击左右气泡或下方器官名称查看")
                .accessibilityIdentifier("anatomy-canvas")
                ForEach(AnatomyPart.allCases) { part in
                    let rect = layout.cardRect(part)
                    callout(part)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }

    private func callout(_ part: AnatomyPart) -> some View {
        let completed = viewModel.completedJourneyID != nil
        let outcome = completed ? viewModel.journey?.outcome(for: part) : nil
        let urate = part == .kidneys ? urateEducation : nil
        let color = AnatomyArtwork.asset(part).color
        return Button { select(part) } label: {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Circle().fill(color).frame(width: 5, height: 5)
                    Text(part.label).font(.system(size: 12, weight: .semibold))
                    Spacer(minLength: 0)
                }
                if let urate {
                    Text(urate.title)
                        .font(.system(size: 10, weight: .medium)).lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.white.opacity(0.92))
                    Text("点按查看重点说明")
                        .font(.system(size: 10)).foregroundStyle(color).lineLimit(1)
                } else if completed, let journey = viewModel.journey {
                    Text(journey.calloutData(for: part))
                        .font(.system(size: 10, weight: .medium)).lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.white.opacity(0.9))
                    Text(outcome?.badge ?? "一般功能")
                        .font(.system(size: 10)).foregroundStyle(color).lineLimit(part == .smallIntestine ? 1 : 2)
                } else if selected == nil, part == .pancreas, let role = viewModel.pancreasRoleDuringPreview {
                    Text(role.title).font(.system(size: 10, weight: .medium))
                    Text(role.subtitle).font(.system(size: 10)).foregroundStyle(color).lineLimit(2)
                } else {
                    Text(viewModel.phase == .idle ? "点击查看功能" : "正在预演…")
                        .font(.system(size: 10)).foregroundStyle(.secondary)
                    Text(viewModel.phase == .idle ? "进食后显示本份结果" : "结束后显示本份结果")
                        .font(.system(size: 10)).foregroundStyle(color.opacity(0.85)).lineLimit(2)
                }
            }
            .padding(7).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(color.opacity(selected == part ? 0.14 : 0.055), in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(color.opacity(selected == part ? 0.95 : 0.35), lineWidth: selected == part ? 1.2 : 0.7))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("organ-callout-\(part.rawValue)")
        .accessibilityValue(urate.map { "\($0.title)。\($0.kidneyExplanation)" }
            ?? (completed ? viewModel.journey?.calloutData(for: part) ?? "" : "等待预演"))
        .accessibilityAddTraits(selected == part ? .isSelected : [])
        .transaction { $0.animation = nil }
    }

    private func bodyLayer(_ transform: CGAffineTransform) -> some View {
        Canvas { context, _ in
            context.concatenate(transform)
            context.stroke(AnatomyArtwork.parse(AnatomyArtwork.cutawayData),
                           with: .color(AnatomyArtwork.color("93A5C6").opacity(0.4)),
                           style: StrokeStyle(lineWidth: 0.9, lineCap: .round, lineJoin: .round))
        }.allowsHitTesting(false)
    }

    private func organLayer(_ asset: AnatomyAsset, transform: CGAffineTransform) -> some View {
        Canvas { context, _ in
            context.concatenate(transform)
            let bounds = asset.path.boundingRect
            context.drawLayer { shadow in
                shadow.addFilter(.shadow(color: asset.color.opacity(0.2), radius: selected == asset.part ? 8 : 3))
                shadow.fill(asset.path, with: .linearGradient(
                    Gradient(colors: [asset.color, asset.color.opacity(0.72)]),
                    startPoint: CGPoint(x: bounds.midX, y: bounds.minY), endPoint: CGPoint(x: bounds.midX, y: bounds.maxY)))
            }
            context.stroke(asset.path, with: .color(asset.color.opacity(0.9)), lineWidth: 0.7)
            if selected == asset.part {
                context.stroke(asset.path, with: .color(Color.white.opacity(0.7)), lineWidth: 1)
            }
            // Small, independent highlights give the rounded artwork depth without noisy textures.
            var shine = context
            shine.clip(to: asset.path)
            if asset.strokeWidth > 0 {
                shine.stroke(AnatomyArtwork.parse(asset.data).applying(CGAffineTransform(translationX: -1.5, y: -2)),
                             with: .color(Color.white.opacity(0.20)),
                             style: StrokeStyle(lineWidth: 1.3, lineCap: .round, lineJoin: .round))
            } else if asset.part != .kidneys {
                shine.fill(Path(ellipseIn: CGRect(x: bounds.midX - 8, y: bounds.minY + 5, width: 16, height: 4)),
                           with: .color(Color.white.opacity(0.20)))
            }
        }.allowsHitTesting(false)
    }

    private func drawActivity(_ context: GraphicsContext, date: Date) {
        // Manual organ focus takes priority over automatic pancreas lesson accents.
        // Otherwise the two narrative windows repeatedly brighten/change its outline.
        if selected == nil, let role = viewModel.pancreasRoleDuringPreview {
            let color = AnatomyArtwork.asset(role == .digestion ? .pancreas : .smallIntestine).color
            context.stroke(AnatomyArtwork.asset(.pancreas).path, with: .color(color), lineWidth: 1.8)
            if role == .digestion {
                // Short schematic secretion route. These markers are not food or secretion units.
                var route = Path()
                route.move(to: CGPoint(x: 170, y: 235))
                route.addLine(to: CGPoint(x: 137, y: 236))
                context.stroke(route, with: .color(color), style: StrokeStyle(lineWidth: 1.6, dash: [3, 2]))
                let t = reduceMotion ? 0.5 : date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 0.8) / 0.8
                let point = CGPoint(x: 170 - 33 * t, y: 235 + t)
                context.fill(Path(ellipseIn: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)), with: .color(.white))
            }
        }
        if let selected {
            let asset = AnatomyArtwork.asset(selected)
            let bounds = asset.path.boundingRect
            var clipped = context
            clipped.clip(to: asset.path)
            // Educational activity highlight, not a simulated blood/food route through accessory organs.
            let phase = reduceMotion ? 0.45 : date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.5) / 2.5
            for i in 0..<3 {
                let x = bounds.minX + bounds.width * (phase + Double(i) / 3).truncatingRemainder(dividingBy: 1)
                clipped.fill(Path(ellipseIn: CGRect(x: x - 2, y: asset.anchor.y - 2, width: 4, height: 4)),
                             with: .color(.white.opacity(0.85)))
            }
        }
        guard viewModel.phase != .idle else { return }
        // Food remains visible along the WHOLE tract, even when another organ is in focus.
        for point in viewModel.foodParticlePositions {
            let radius: CGFloat = viewModel.phase == .descending ? 3.6 : 2
            context.fill(Path(ellipseIn: CGRect(x: point.x - radius * 2, y: point.y - radius * 2,
                                              width: radius * 4, height: radius * 4)),
                         with: .color(AnatomyArtwork.color("FFDA91").opacity(0.2)))
            context.fill(Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)),
                         with: .color(AnatomyArtwork.color("FFDA91")))
        }
    }

    private var detailPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let selected {
                HStack {
                    Circle().fill(AnatomyArtwork.asset(selected).color).frame(width: 8, height: 8)
                    Text(selected.label).font(.system(size: 16, weight: .semibold))
                    Spacer()
                    if selected == .pancreas {
                        Button("作用讲解 ↗") { showPancreasProcess = true }
                            .font(.system(size: 12)).frame(minHeight: 32)
                            .accessibilityIdentifier("open-pancreas-process")
                    }
                    if selected == .kidneys, urateEducation != nil {
                        Button("尿酸重点 ↗") { showUrateEducation = true }
                            .font(.system(size: 12)).frame(minHeight: 32)
                            .accessibilityIdentifier("open-urate-education")
                    }
                    Button("查看全貌") { select(nil) }
                        .font(.system(size: 12)).frame(minHeight: 32)
                        .accessibilityIdentifier("clear-organ-focus")
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if let journey = viewModel.journey, viewModel.completedJourneyID != nil {
                            Button {
                                summaryPresentation = JourneySummaryPresentation(journey: journey, part: selected)
                            } label: {
                                Text("\(journey.title) · 查看\(selected.label)小结 ↗")
                            }.font(.system(size: 11)).accessibilityIdentifier("open-journey-summary")
                        }
                        let outcome = viewModel.completedJourneyID == nil ? nil : viewModel.journey?.outcome(for: selected)
                        Text("过程  \(outcome?.process ?? selected.explanation.process)")
                        Text("结果  \(outcome?.result ?? selected.explanation.result)")
                            .foregroundStyle(AnatomyArtwork.asset(selected).color)
                        if viewModel.completedJourneyID != nil && outcome == nil {
                            Text("一般生理功能。")
                                .font(.system(size: 10)).foregroundStyle(.secondary)
                        }
                        if selected == .kidneys, let education = urateEducation {
                            Text(education.context)
                                .font(.system(size: 11)).foregroundStyle(AnatomyArtwork.asset(.kidneys).color)
                                .accessibilityIdentifier("urate-kidney-hint")
                        }
                        Link("科普示意 · 来源 NIDDK ↗", destination: selected.source)
                            .font(.system(size: 10)).foregroundStyle(.secondary)
                        if selected == .pancreas {
                            Link("胰岛素说明 · NIDDK ↗", destination: PancreasRole.insulinSource)
                                .font(.system(size: 10)).foregroundStyle(.secondary)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.system(size: 12)).lineSpacing(3)
                .accessibilityIdentifier("organ-detail-\(selected.rawValue)")
            } else if let journey = viewModel.journey, viewModel.completedJourneyID != nil {
                HStack {
                    Text("\(journey.title) · 预演完成").font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Button("重播") { viewModel.replay() }
                        .font(.system(size: 12)).frame(minHeight: 32)
                        .accessibilityIdentifier("replay-journey")
                }
                Button {
                    summaryPresentation = JourneySummaryPresentation(journey: journey, part: nil)
                } label: {
                    HStack {
                        Text("查看 \(journey.outcomes.count) 个器官的过程与结果")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }.font(.system(size: 12, weight: .medium)).frame(minHeight: 24)
                }.accessibilityIdentifier("open-journey-summary")
                Text("典型生理过程示意 · 非个人代谢测量")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
            } else {
                HStack {
                    Image(systemName: "hand.tap").foregroundStyle(AnatomyArtwork.color("93D6C5"))
                    Text("轻点器官，看它如何参与消化与代谢")
                        .font(.system(size: 13, weight: .medium))
                }
                Text("点选气泡查看过程；数值为食物成分。")
                    .font(.system(size: 12)).foregroundStyle(.secondary).lineSpacing(3)
                Text(viewModel.phase == .idle ? "消化与代谢示意 · NIDDK 资料参考" : "正在预演食物旅程 · 可随时聚焦器官")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
    }
}
