import Foundation

/// Field-level references supplement a food without implying that every nutrient
/// was measured in the same sample. Units: fibre/lactose g, total purine bases mg, per 100g.
struct FoodCompositionReference {
    struct Value {
        let amount: Double
        let source: FoodCompositionSource
        let record: String
        let isEstimate: Bool

        init(_ amount: Double, source: FoodCompositionSource, record: String, isEstimate: Bool = false) {
            precondition(amount.isFinite && amount >= 0)
            self.amount = amount
            self.source = source
            self.record = record
            self.isEstimate = isEstimate
        }
    }

    let fiber: Value?
    let lactose: Value?
    let purine: Value?
    /// CoFID Tr is not a numeric zero, nor an absent record.
    let lactoseIsTrace: Bool
    let note: String

    init(fiber: Value? = nil, lactose: Value? = nil, purine: Value? = nil,
         lactoseIsTrace: Bool = false, note: String) {
        self.fiber = fiber
        self.lactose = lactose
        self.purine = purine
        self.lactoseIsTrace = lactoseIsTrace
        self.note = note
    }
}

enum FoodCompositionSource: String, CaseIterable, Identifiable {
    case cfs, cofid, afcd, usdaPurine
    var id: String { rawValue }
    var title: String {
        switch self {
        case .cfs: "香港食安中心 · 中式食品成分"
        case .cofid: "英国 CoFID · 乳糖与纤维"
        case .afcd: "澳新 FSANZ · 食物成分"
        case .usdaPurine: "USDA / NIH · 嘌呤数据库"
        }
    }
    var url: URL {
        switch self {
        case .cfs: URL(string: "https://www.cfs.gov.hk/tc_chi/nutrient/presearch3.php")!
        case .cofid: URL(string: "https://www.gov.uk/government/publications/composition-of-foods-integrated-dataset-cofid")!
        case .afcd: URL(string: "https://www.foodstandards.gov.au/science-data/food-nutrient-databases")!
        case .usdaPurine: URL(string: "https://www.ars.usda.gov/northeast-area/beltsville-md-bhnrc/beltsville-human-nutrition-research-center/methods-and-application-of-food-composition-laboratory/mafcl-site-pages/purine-content-of-foods/")!
        }
    }
}
