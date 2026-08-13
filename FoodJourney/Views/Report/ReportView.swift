import SwiftUI

/// 报告页：累积代谢 + 不可吸收/残留 + 脏器过载（镜头重点） + 问卷分析 + 引用注脚
struct ReportView: View {
    let session: DigestionSession
    let prefs: UserPreferences
    @Environment(\.colorScheme) private var colorScheme
    @State private var showCapacityInfo = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                absorbedCard
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
        let kidneyHighlight = prefs.highlightedOrgans.contains(.kidney)
        return VStack(alignment: .leading, spacing: 10) {
            Text("累积代谢").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            row("食物份数", "\(session.foodCount)")
            row("摄入热量", "\(Int(session.totalCalories)) kcal")
            row("实际产 ATP", "\(String(format: "%.2f", session.totalATP)) mol")
            row("CO₂", "\(Int(session.totalCO2)) g")
            row("代谢水", "\(Int(session.totalWater)) g")
            Divider().background(Color(hex: "2a2a44")!).padding(.vertical, 1)
            // 尿酸（肝产嘌呤、肾排）
            Text("尿酸（嘌呤代谢）").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.primaryLight)
            row("肝产尿酸", "\(Int(session.totalUricAcidProducedMg)) mg", highlight: kidneyHighlight)
            row("尿酸滞留", "\(Int(session.totalUricAcidRetainedMg)) mg", highlight: kidneyHighlight)
            // 尿素（肝脱氨、肾排）
            Text("尿素（蛋白脱氨）").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.primaryLight)
            row("肝产尿素", "\(Int(session.totalUreaProducedMg)) mg", highlight: kidneyHighlight)
            row("尿素滞留", "\(Int(session.totalUreaRetainedMg)) mg", highlight: kidneyHighlight)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111128")!).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 吸收物（身体得到了什么）

    private var absorbedCard: some View {
        let pancreasHighlight = prefs.highlightedOrgans.contains(.pancreas)
        return VStack(alignment: .leading, spacing: 10) {
            Text("吸收物（身体得到）").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            row("葡萄糖入血", "\(String(format: "%.1f", session.totalAbsorbedGlucoseG)) g", highlight: pancreasHighlight)
            row("血糖负荷", "\(Int(session.totalBloodGlucoseMg)) mg", highlight: pancreasHighlight)
            row("胰岛素响应", "\(String(format: "%.1f", session.totalInsulinResponse))", highlight: pancreasHighlight)
            row("氨基酸入肝", "\(String(format: "%.1f", session.totalAbsorbedAminoAcidG)) g")
            row("脂肪酸入淋巴", "\(String(format: "%.1f", session.totalAbsorbedFattyAcidG)) g")
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

    // MARK: 内脏使用度

    private var overloadCard: some View {
        let events = session.results.flatMap { $0.overloads }
        let overloadByOrgan = Dictionary(grouping: events, by: \.organ)
            .mapValues { Array(Set($0.map(\.substance))).sorted() }
        let usageOrgans: [DigestiveOrgan] = [.stomach, .smallIntestine, .liver, .pancreas, .kidney]
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                Text("内脏使用度").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Button {
                    showCapacityInfo = true
                } label: {
                    Image(systemName: "info.circle").font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary(scheme: colorScheme))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showCapacityInfo) {
                    Text("本报告的内脏代谢能力条件为饮水充足、睡眠充足的前提下。")
                        .font(.system(size: 12))
                        .padding(12)
                        .frame(maxWidth: 240)
                        .presentationCompactAdaptation(.popover)
                }
            }
            // 各脏器本次进食使用度
            ForEach(usageOrgans, id: \.self) { organ in
                organUsageRow(organ, overloadByOrgan: overloadByOrgan)
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111128")!).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    /// 单脏器使用度行：名称 + 进度条 + 百分比；满载(100%)时整行转红并附滞留物质
    private func organUsageRow(_ organ: DigestiveOrgan,
                               overloadByOrgan: [DigestiveOrgan: [String]]) -> some View {
        let ratio = session.usageRatio(organ)
        let isMaxed = ratio >= 0.999            // 能力耗尽 = 100%
        let substances = overloadByOrgan[organ]
        let overloadLabel = substances?.joined(separator: "·") ?? organ.overloadSubstance
        let highlighted = prefs.highlightedOrgans.contains(organ)
        let barColor: Color = isMaxed ? Color(hex: "D85A30")!
            : (highlighted ? AppTheme.primaryLight : AppTheme.primary)
        return VStack(spacing: 4) {
            HStack {
                Text(organ.rawValue).font(.system(size: 12)).foregroundColor(.white)
                Spacer()
                Text("\(Int(ratio * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(isMaxed ? Color(hex: "D85A30")!
                        : (highlighted ? AppTheme.primaryLight : AppTheme.textSecondary(scheme: colorScheme)))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "2a2a44")!)
                    Capsule().fill(barColor).frame(width: geo.size.width * ratio)
                }
            }
            .frame(height: 5)
            if isMaxed {
                Text(overloadLabel)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "D85A30")!)
            }
        }
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
        // 高尿酸镜头：尿酸来自嘌呤（非蛋白），三文鱼/鸡胸肉/红烧肉为高嘌呤
        if prefs.highlightedOrgans.contains(.kidney) {
            if session.totalUricAcidRetainedMg > 0 {
                s += "你关注尿酸：本次尿酸滞留 \(Int(session.totalUricAcidRetainedMg))mg。尿酸由肝代谢嘌呤产生（与蛋白无关），三文鱼、鸡胸肉、红烧肉等嘌呤较高，建议避免连续大量摄入、多饮水促进肾排泄。"
            } else if session.totalUricAcidProducedMg > 0 {
                s += "你关注尿酸：本次产尿酸 \(Int(session.totalUricAcidProducedMg))mg，肾排泄正常无滞留。尿酸由肝代谢嘌呤产生，高嘌呤食物（三文鱼/鸡胸肉/红烧肉）连续摄入仍需留意。"
            }
        }
        // 高血糖/胰岛素镜头：碳水→血糖→胰腺胰岛素
        if prefs.highlightedOrgans.contains(.pancreas) {
            s += "你关注血糖：本次血糖负荷 \(Int(session.totalBloodGlucoseMg))mg，胰岛素响应 \(String(format: "%.1f", session.totalInsulinResponse))。连续高碳水加重胰腺负担，米饭/馒头/面条等精制碳水宜分散摄入。"
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
