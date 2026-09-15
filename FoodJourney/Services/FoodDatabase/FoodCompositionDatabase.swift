import Foundation

/// Checked 2026-09-10. Exact worksheet rows and rejected mappings are retained in
/// docs/food-composition-v8.md. These are food references, not personal intake measurements.
enum FoodCompositionDatabase {
    private typealias Value = FoodCompositionReference.Value

    private static func uk(_ amount: Double, _ record: String, estimate: Bool = false) -> Value {
        Value(amount, source: .cofid, record: "CoFID 2021 / 1.3 Proximates / \(record)", isEstimate: estimate)
    }
    private static func purine(_ amount: Double, _ record: String, estimate: Bool = false) -> Value {
        Value(amount, source: .usdaPurine, record: "Release 2 (2025) / \(record)", isEstimate: estimate)
    }

    static let entries: [String: FoodCompositionReference] = [
        "米饭": .init(lactose: uk(0, "11-862"), purine: purine(5.9, "Table1 row30, cooked white rice"),
                    note: "按无乳配料的熟白米饭参考；嘌呤采用熟饭记录，不使用生大米数值。"),
        "馒头": .init(lactose: uk(0, "11-886, wheat flour; flour/water recipe", estimate: true),
                    note: "乳糖按不加奶的小麦粉、水和酵母配方估算为0；奶香馒头不适用。嘌呤仍为待校准的旧估值。"),
        "面条": .init(lactose: uk(0, "11-941, boiled egg noodles"),
                    purine: purine(12.1, "Table2 row45, udon wheat noodles", estimate: true),
                    note: "按无乳配料的熟小麦面条参考；嘌呤借用乌冬面条目估算，不包含肉汤或浇头。"),
        "鸡胸肉": .init(fiber: uk(0, "18-323"), lactose: uk(0, "18-323"),
                     purine: purine(368.6, "Table1 row116, boneless skinless cooked; USDA 2024"),
                     note: "去皮去骨、无乳配料熟鸡胸肉。嘌呤按USDA烤制样本参考；水煮、卤制或不同含水量不等同于此值。"),
        "红烧肉": .init(fiber: uk(0, "18-555, pork belly; meat-only approximation", estimate: true),
                     lactose: uk(0, "18-555, pork belly; dairy-free recipe", estimate: true),
                     note: "按不加奶、不含蔬菜配菜、去除整块香料的红烧肉参考。纤维按猪肉主体近似为0，少量调料纤维未量化；嘌呤仍是旧估值。"),
        "三文鱼": .init(fiber: Value(0, source: .afcd, record: "F007828, plain salmon flesh"),
                     lactose: Value(0, source: .afcd, record: "F007828, plain salmon flesh"),
                     purine: purine(249.9, "Table1 row58, Atlantic farmed raw; USDA 2024"),
                     note: "嘌呤按养殖大西洋三文鱼生鱼肉参考；纤维、乳糖的0参考无添加鱼肉。煎烤后应另核熟重，不含奶油或酱汁。"),
        "豆腐": .init(lactose: uk(0, "13-570"), purine: purine(31.1, "Table2 row183, tofu raw nigari"),
                    note: "普通凝固豆腐参考，不是油豆腐、冻干豆腐或奶制甜点。含水量和凝固工艺会影响数值。"),
        "鸡蛋": .init(fiber: uk(0, "12-940"), lactose: uk(0, "12-940"),
                    purine: purine(0, "Table2 row51, whole chicken egg, reported total 0"),
                    note: "不加奶的全蛋参考；嘌呤0为数据库所报全蛋参考值，不表示任何检测方法下都绝对不存在。"),
        "西兰花": .init(lactose: uk(0, "13-503"), purine: purine(51.82, "Table2 row254, broccoli boiled"),
                     note: "按水煮、无奶酪或奶油酱的西兰花参考；嘌呤使用熟制条目。"),
        "苹果": .init(lactose: uk(0, "14-319"),
                    note: "带皮苹果可食部分的乳糖参考为0；嘌呤尚保留旧估值。"),
        "牛奶": .init(fiber: uk(0, "12-320"), lactose: uk(4.8, "12-320"),
                    purine: purine(0, "Table2 row54, milk, reported total 0"),
                    note: "乳糖按全脂UHT牛奶参考；不适用于无乳糖奶。嘌呤0为所采用来源的报告值，不代表所有奶样绝对为零。"),
        "香蕉": .init(lactose: uk(0, "14-318"), purine: purine(3, "Table2 row157, banana raw"),
                    note: "按去皮香蕉可食部分参考。"),
        "pork-vegetable-dumplings": .init(lactose: uk(0, "11-886 + 18-605; dairy-free pork/vegetable recipe", estimate: true),
                    note: "乳糖按不加乳制品的菜肉水饺配方估算为0；含奶配方和特定品牌应另核。"),
        "egg-fried-rice": .init(lactoseIsTrace: true,
                    note: "CoFID 11-444为外卖蛋炒饭参考；乳糖原始值Tr（微量），保留微量标记，不改写为0。"),
        "beef-burger-reference": .init(lactose: uk(0, "19-556, grilled beef burger with bun", estimate: true),
                    note: "乳糖按无芝士、无乳配方面包的牛肉汉堡参考估算为0；不是任意品牌汉堡的保证值。"),
        "french-fries": .init(lactose: uk(0, "13-026, fine-cut fries in corn oil"),
                    note: "乳糖按无乳裹粉、植物油炸薯条参考，不包含奶酪酱。"),
        "fried-fine-rice-vermicelli": .init(lactose: uk(0, "11-725; dairy-free fried rice-noodle recipe", estimate: true),
                    note: "乳糖按米粉、植物油与无乳配料估算为0；嘌呤需按具体配菜补充。"),
        "soy-milk-reference": .init(lactose: uk(0, "12-523 / 12-524, soy drink"),
                    purine: purine(21.91, "Table2 row172, soy milk"),
                    note: "纯豆浆不含牛奶；乳糖参考为0。嘌呤采用豆浆样本，浓度与品牌不同会有差异。"),
        "fried-dough-stick": .init(lactose: uk(0, "11-886; dairy-free flour/oil/water recipe", estimate: true),
                    note: "乳糖按不加乳制品的油条配方估算为0；嘌呤尚待对应成品资料。"),
        "millet-porridge": .init(lactose: uk(0, "11-016, millet flour; millet/water recipe", estimate: true),
                    note: "乳糖按小米和水的配方参考为0。纤维来源为ND（未检出），无检测限资料，不伪造具体克数。"),
        "wholemeal-bread": .init(lactose: uk(0, "11-981, wholemeal bread average"),
                    note: "乳糖按全麦面包参考记录为0；含奶粉或奶油的配方应以标签为准。"),
        "roasted-peanuts": .init(lactose: uk(0, "14-878, dry roasted peanuts"),
                    note: "无乳制品调味的花生参考，不包含奶香或巧克力裹衣；未用生花生嘌呤替代炒制值。"),
        "shanghai-pork-xiaolongbao": .init(lactose: uk(0, "11-886 + 18-605; dairy-free flour/pork recipe", estimate: true),
                    note: "乳糖按无乳配方猪肉小笼包估算为0；嘌呤需核面皮、馅料和汤汁比例。"),
        "shrimp-siu-mai": .init(lactose: uk(0, "11-886; dairy-free shrimp/meat/wrapper recipe", estimate: true),
                    note: "乳糖按无乳配方虾肉烧卖估算为0；不是含奶面皮或特定品牌的检测值。"),
        "tofu-pudding-savory": .init(lactose: uk(0, "13-570; dairy-free tofu/sauce recipe", estimate: true),
                    note: "乳糖按不加奶的带卤豆腐脑估算为0；未以普通豆腐嘌呤直接代替带卤整碗。"),
        "yogurt-mean-reference": .init(fiber: uk(0, "12-184"), lactose: uk(4.7, "12-184"),
                    purine: purine(5.2, "Table2 row55, yogurt not further specified", estimate: true),
                    note: "采用原味全脂酸奶参考，不含果粒、谷物或额外糖；嘌呤借用通用酸奶样本估算。希腊酸奶、无乳糖或加料产品需另核。"),
        "orange-edible": .init(lactose: uk(0, "14-327"),
                    note: "去皮橙子可食部分的乳糖参考为0；没有把橘子或柚子的嘌呤当作橙子。")
    ]
}
