import SwiftUI

/// 报告页：累积代谢 + 不可吸收/残留 + 脏器过载（镜头重点） + 问卷分析 + 引用注脚
struct ReportView: View {
    let session: DigestionSession
    let prefs: UserPreferences
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                residuesCard
                overloadCard
                adviceCard
            }
            .padding(16)
        }
        .background(Color(hex: "0d0d1a")!)
        .preferredColorScheme(.dark)
        .navigationTitle("代谢报告").navigationBarTitleDisplayMode(.inline)
    }

    // MARK: 累积代谢

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("累积代谢").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            row("食物份数", "\(session.foodCount)")
            row("摄入热量", "\(Int(session.totalCalories)) kcal")
            row("实际产 ATP", "\(String(format: "%.2f", session.totalATP)) mol")
            row("CO₂", "\(Int(session.totalCO2)) g")
            row("代谢水", "\(Int(session.totalWater)) g")
            row("尿酸滞留", "\(Int(session.totalUricAcidRetainedMg)) mg",
                highlight: prefs.highlightedOrgans.contains(.kidney))
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111128")!).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 残留

    private var residuesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("不可吸收 / 残留产物").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
            if session.residues.isEmpty {
                Text("无残留，代谢完整").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            } else {
                ForEach(session.residues) { r in
                    HStack {
                        Text(r.foodName).font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.primaryLight)
                        Text("· \(r.organ.rawValue)").font(.system(size: 11)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                        Spacer()
                        Text("\(r.substance) \(String(format: "%.1f", r.amount))g")
                            .font(.system(size: 11))
                            .foregroundColor(r.kind == .structural ? AppTheme.primaryLight : Color(hex: "D85A30")!)
                    }
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111128")!).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 过载

    private var overloadCard: some View {
        let events = session.results.flatMap { $0.overloads }
        return VStack(alignment: .leading, spacing: 8) {
            Text("脏器过载").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
            if events.isEmpty {
                Text("各脏器能力充足").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            } else {
                ForEach(events) { e in
                    let highlighted = prefs.highlightedOrgans.contains(e.organ)
                    return HStack {
                        Text(e.foodName).font(.system(size: 12)).foregroundColor(.white)
                        Spacer()
                        Text("\(e.organ.rawValue)过载·\(e.substance)")
                            .font(.system(size: 11))
                            .foregroundColor(highlighted ? Color(hex: "D85A30")! : AppTheme.textSecondary(scheme: colorScheme))
                    }
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111128")!).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 问卷分析

    private var adviceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill").foregroundColor(AppTheme.carbColor)
                Text("基于你的关注（\(prefs.focus.rawValue)）").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
            }
            Text(advice).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme)).lineSpacing(4)
            Divider().background(Color(hex: "2a2a44")!).padding(.vertical, 2)
            Text("营养数据来源：将接入权威数据库（USDA FoodData Central / 中国食物成分表）作为引用注脚。")
                .font(.system(size: 9)).foregroundColor(AppTheme.textTertiary(scheme: colorScheme))
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111128")!).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var advice: String {
        var s = "本次共吃入 \(session.foodCount) 份。"
        if prefs.highlightedOrgans.contains(.kidney) && session.totalUricAcidRetainedMg > 0 {
            s += "肾排泄尿酸能力受限，尿酸滞留 \(Int(session.totalUricAcidRetainedMg))mg，建议减少高蛋白连续摄入、多饮水。"
        }
        if prefs.highlightedOrgans.contains(.pancreas) {
            s += "你关注血糖：连续高碳水会加重胰腺负担，注意分散碳水摄入。"
        }
        if prefs.highlightedOrgans.contains(.liver) {
            s += "高脂食物加重肝脏代谢负荷，留意脂肪堆积。"
        }
        if session.residues.contains(where: { $0.organ == .largeIntestine && $0.kind == .structural }) {
            s += "部分纤维/乳糖在大肠残留，属正常生理现象。"
        }
        return s
    }

    private func row(_ label: String, _ value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
            Spacer()
            Text(value).font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(highlight ? Color(hex: "D85A30")! : .white)
        }
    }
}
