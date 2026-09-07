import Foundation

/// Composition-driven educational narrative, deliberately independent of the legacy capacity model.
/// These are typical pathways, not measurements of an individual's digestion or metabolite output.
struct MealDigestionJourney: Identifiable {
    struct Outcome: Identifiable {
        let part: AnatomyPart
        let role: String
        let process: String
        let result: String
        let badge: String
        var id: AnatomyPart { part }
    }

    let id = UUID()
    let item: FoodItem
    let outcomes: [Outcome]
    var title: String { "\(item.food.name) · \(item.grams.formatted(.number.precision(.fractionLength(0))))g" }
    var composition: String {
        "成分示例：蛋白质 \(item.proteinGrams.formatted(.number.precision(.fractionLength(1))))g · 碳水 \(item.carbGrams.formatted(.number.precision(.fractionLength(1))))g · 脂肪 \(item.fatGrams.formatted(.number.precision(.fractionLength(1))))g"
    }
    func outcome(for part: AnatomyPart) -> Outcome? { outcomes.first { $0.part == part } }

    /// Input nutrient amounts, NOT measured amounts digested, secreted or excreted by an organ.
    func calloutData(for part: AnatomyPart) -> String {
        func grams(_ value: Double) -> String { value.formatted(.number.precision(.fractionLength(1))) + "g" }
        switch part {
        case .mouth, .esophagus: return "本份食物 \(grams(item.grams))"
        case .stomach: return "本份蛋白 \(grams(item.proteinGrams))"
        case .duodenum, .gallbladder: return "本份脂肪 \(grams(item.fatGrams))"
        case .smallIntestine: return "碳水 \(grams(item.carbGrams))\n蛋白 \(grams(item.proteinGrams))"
        case .largeIntestine: return "本份纤维 \(grams(item.fiberGrams))"
        case .pancreas: return "分泌量未估算"
        case .liver: return "产物量未估算"
        case .kidneys: return "排出量未估算"
        }
    }

    init(item: FoodItem) {
        self.item = item
        let protein = item.proteinGrams > 0
        let carb = item.carbGrams > 0
        let fat = item.fatGrams > 0
        let fiber = item.fiberGrams > 0
        let nutrients = [(protein, "蛋白质"), (carb, "碳水化合物"), (fat, "脂肪")]
            .filter { $0.0 }.map { $0.1 }.joined(separator: "、")
        let products = [(protein, "氨基酸"), (carb, "单糖"), (fat, "脂肪酸等")]
            .filter { $0.0 }.map { $0.1 }.joined(separator: "、")
        let bloodProducts = [(protein, "氨基酸"), (carb, "单糖")]
            .filter { $0.0 }.map { $0.1 }.joined(separator: "、")
        let transport = (bloodProducts.isEmpty ? "" : "\(bloodProducts)等进入血液。")
            + (fat ? "部分脂肪成分经淋巴运输。" : "")
        var results: [Outcome] = []
        func add(_ part: AnatomyPart, _ role: String, _ process: String, _ result: String, _ badge: String) {
            results.append(Outcome(part: part, role: role, process: process, result: result, badge: badge))
        }
        add(.mouth, "消化道", "咀嚼并与唾液混合。", carb ? "形成湿润、易吞咽的食团；若含淀粉，唾液酶开始分解淀粉。" : "形成湿润、易吞咽的食团。", "形成食团")
        add(.esophagus, "消化道", "蠕动推动这份食物向下移动。", "食团到达胃；这里主要负责输送，不额外产生消化液。", "输送食团")
        add(.stomach, "消化道", protein ? "混合食物与胃液，胃酸和酶开始参与这份食物的蛋白质消化。" : "收缩、搅拌食物，并与胃液混合。",
            protein ? "蛋白质开始分解；混合物成为食糜，逐步进入小肠。" : "形成食糜，逐步进入小肠。", protein ? "蛋白质初步分解" : "形成食糜")
        add(.duodenum, "消化道", fat ? "食糜在这里与胰液、胆汁等混合。" : "食糜在这里与胰液、肠液等混合。",
            nutrients.isEmpty ? "继续混合并向后续小肠移动。" : "\(nutrients)继续被消化，随后进入后续小肠。", "消化液混合")
        if !nutrients.isEmpty {
            add(.pancreas, "消化液协作", "将含消化酶的胰液送到小肠，参与\(nutrients)的分解。",
                "为进一步消化提供酶；食团不进入胰腺。", "提供消化酶")
        }
        if fat {
            add(.gallbladder, "消化液协作", "释放储存的胆汁到小肠，帮助这份食物中的脂肪消化。",
                "胆汁帮助脂肪消化；不是食物通过的通道。", "释放胆汁")
        }
        add(.smallIntestine, "消化与吸收", nutrients.isEmpty ? "继续混合肠道内容物并吸收水分。" : "继续分解\(nutrients)，经肠壁吸收营养。",
            products.isEmpty ? "水分等经肠壁被吸收，剩余内容物继续前行。" : "形成并吸收\(products)。\(transport)", products.isEmpty ? "吸收水分" : "吸收\(products)")
        if !nutrients.isEmpty {
            add(.liver, "吸收后处理", fat ? "制造帮助脂肪消化的胆汁；也处理肠道吸收后送来的营养。" : "接收并加工肠道吸收后由血液送来的营养物质。",
                "营养被加工、储存或分配，供身体使用；食团不进入肝脏。", "加工与分配营养")
        }
        add(.kidneys, "代谢延伸 · 持续发生", "营养被身体利用后，代谢废物随血液运输；肾脏持续过滤血液并回收需要的物质。",
            "部分代谢废物和多余水分成为尿液。这里不是食团通道，也不能由这份食物推算个人排出量。", "废物与水→尿液")
        add(.largeIntestine, "消化道", fiber ? "吸收剩余内容物中的水分，菌群可分解部分膳食纤维。" : "吸收剩余内容物中的水分；即使这份食物不含纤维，大肠仍有作用。",
            fiber ? "部分纤维经菌群分解，未消化残余等参与形成粪便；并非整份食物都变成粪便。" : "未消化残余、脱落细胞等参与形成粪便；并非整份食物都变成粪便。", "回收水分·形成粪便")
        outcomes = results
    }
}
