import Foundation

/// 消化道器官模型
struct Organ: Identifiable, Equatable {
    let id: String
    let label: String?
    let cx: CGFloat
    let cy: CGFloat
    let rx: CGFloat
    let ry: CGFloat
    let color: String          // 十六进制颜色
    let highlightColor: String // 选中时高亮颜色
    let time: String?          // 消化时间范围

    /// 点击后展示的详情
    let detailTitle: String?
    let detailDesc: String?
    let detailTags: [OrganTag]?

    var hasDetail: Bool { detailTitle != nil }

    static func == (lhs: Organ, rhs: Organ) -> Bool {
        lhs.id == rhs.id
    }
}

struct OrganTag {
    let text: String
    let style: TagStyle

    enum TagStyle {
        case enzyme    // 酶/化学物质 — 紫色
        case product   // 产物 — 绿色
        case timing    // 时间/过程 — 橙色
    }
}

// MARK: - 原型数据

extension Organ {
    /// 从 HTML 原型翻译的器官数据（基于 240×370 画布）
    static let prototypeOrgans: [Organ] = [
        Organ(
            id: "mouth", label: "口腔", cx: 120, cy: 28, rx: 30, ry: 12,
            color: "#7F77DD", highlightColor: "#7F77DD", time: "0–2 min",
            detailTitle: "口腔 · 0–2 分钟",
            detailDesc: "唾液淀粉酶将约15%的支链淀粉初步分解为麦芽糖。咀嚼增大酶接触面积。",
            detailTags: [
                OrganTag(text: "酶：唾液淀粉酶", style: .enzyme),
                OrganTag(text: "产物：麦芽糖", style: .product),
                OrganTag(text: "过程：咀嚼混合", style: .timing),
            ]
        ),
        Organ(
            id: "esophagus", label: nil, cx: 120, cy: 58, rx: 6, ry: 18,
            color: "#2a2a5a", highlightColor: "#2a2a5a", time: nil,
            detailTitle: nil, detailDesc: nil, detailTags: nil
        ),
        Organ(
            id: "stomach", label: "胃", cx: 103, cy: 112, rx: 38, ry: 34,
            color: "#533a6a", highlightColor: "#9977cc", time: "15–30m",
            detailTitle: "胃 · 15–30 分钟",
            detailDesc: "胃酸（pH 2）使淀粉酶失活，暂停淀粉消化。胃蛋白酶开始分解蛋白质为多肽。蠕动研磨食糜为细颗粒。",
            detailTags: [
                OrganTag(text: "酶：胃蛋白酶", style: .enzyme),
                OrganTag(text: "环境：pH 约2", style: .timing),
                OrganTag(text: "产物：多肽", style: .product),
                OrganTag(text: "过程：蠕动混合", style: .timing),
            ]
        ),
        Organ(
            id: "liver", label: "肝脏", cx: 155, cy: 100, rx: 22, ry: 20,
            color: "#6a3a20", highlightColor: "#cc8855", time: nil,
            detailTitle: "肝脏 · 吸收后处理",
            detailDesc: "门静脉将葡萄糖送达肝脏。肝脏决定：合成糖原储存、转脂肪，或释放入血。同时分泌胆汁辅助脂肪乳化。",
            detailTags: [
                OrganTag(text: "产物：糖原", style: .product),
                OrganTag(text: "功能：血糖调节", style: .enzyme),
                OrganTag(text: "分泌：胆汁", style: .enzyme),
                OrganTag(text: "产物：VLDL脂蛋白", style: .product),
            ]
        ),
        Organ(
            id: "small", label: "小肠", cx: 112, cy: 192, rx: 44, ry: 40,
            color: "#1D4a35", highlightColor: "#5DCAA5", time: "30–90m",
            detailTitle: "小肠 · 30–90 分钟",
            detailDesc: "胰淀粉酶彻底分解淀粉为葡萄糖。胰蛋白酶分解蛋白质为氨基酸。胆汁乳化脂肪为微粒。肠绒毛经载体主动吸收入血。",
            detailTags: [
                OrganTag(text: "酶：胰淀粉酶", style: .enzyme),
                OrganTag(text: "酶：胰蛋白酶", style: .enzyme),
                OrganTag(text: "产物：葡萄糖", style: .product),
                OrganTag(text: "产物：氨基酸", style: .product),
                OrganTag(text: "过程：主动转运吸收", style: .timing),
                OrganTag(text: "标志：血糖峰值", style: .timing),
            ]
        ),
        Organ(
            id: "large", label: "大肠", cx: 112, cy: 262, rx: 52, ry: 36,
            color: "#1a2a10", highlightColor: "#639922", time: "2–10h",
            detailTitle: "大肠 · 2–10 小时",
            detailDesc: "膳食纤维经菌群发酵产生短链脂肪酸（丁酸、丙酸）。水分重吸收，残渣成型。未吸收的胆汁色素赋予粪便颜色。",
            detailTags: [
                OrganTag(text: "过程：菌群发酵", style: .timing),
                OrganTag(text: "产物：短链脂肪酸", style: .product),
                OrganTag(text: "过程：水分重吸收", style: .timing),
            ]
        ),
    ]
}
