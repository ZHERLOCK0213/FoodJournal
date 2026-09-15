import Foundation

/// User-facing copy is deliberately separate from research/provenance working notes.
extension Food {
    var displayPreparation: String {
        if isCustom { return metadata?.preparation ?? "" }
        return Self.preparations[catalogID] ?? ""
    }
    var ownershipLabel: String { isCustom ? "自建" : "公共食物" }
    var portionSourceLabel: String { isCustom ? "自建 · 配方\(revision)" : "公共食物" }

    private static let preparations: [String: String] = [
        "米饭": "熟白米饭，无乳配料。", "馒头": "小麦粉蒸制，不加奶。",
        "面条": "熟小麦面条，不含肉汤或浇头。", "鸡胸肉": "去皮去骨熟鸡胸肉；嘌呤参考烤制样本。",
        "红烧肉": "五花肉红烧，不加奶、不含蔬菜配菜。", "三文鱼": "养殖大西洋三文鱼生鱼肉，不含酱汁。",
        "豆腐": "普通凝固豆腐，非油豆腐或冻干豆腐。", "鸡蛋": "全蛋可食部分，不加奶。",
        "西兰花": "水煮西兰花，不含奶酪或奶油酱。", "苹果": "带皮苹果可食部分。",
        "牛奶": "全脂牛奶，非无乳糖奶。", "香蕉": "去皮香蕉。",
        "pork-vegetable-dumplings": "熟菜肉水饺，不含蘸料或乳制品。",
        "egg-fried-rice": "外卖蛋炒饭参考，不含额外肉类浇头；乳糖为微量。",
        "beef-burger-reference": "白面包、牛肉饼和沙拉，不含芝士。",
        "french-fries": "植物油炸薯条，不含蘸料或含乳裹粉。",
        "fried-fine-rice-vermicelli": "熟炒米粉，无乳配料；用油和配菜随做法变化。",
        "soy-milk-reference": "豆浆，不加牛奶；按克计重，加糖情况未注明。",
        "fried-dough-stick": "油炸小麦面团，不加乳制品。",
        "millet-porridge": "小米与水煮粥；稠度影响每100g成分。",
        "wholemeal-bread": "全麦面包，无乳配方，不含额外涂抹物。",
        "roasted-peanuts": "去壳炒花生仁，不含糖衣或乳制品调味。",
        "shanghai-pork-xiaolongbao": "蒸猪肉小笼包，无乳配方，不含蘸料。",
        "shrimp-siu-mai": "广东式虾肉烧卖，无乳配方，不含蘸料。",
        "tofu-pudding-savory": "带卤嫩豆腐脑，不加奶，非甜豆花。",
        "yogurt-mean-reference": "原味全脂酸奶，不含果粒或谷物，非无乳糖酸奶。",
        "orange-edible": "去皮橙子，非橙汁。"
    ]
}
