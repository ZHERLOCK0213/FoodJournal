import Foundation

/// The catalog distinguishes measured/reference composition from unresolved dishes.
struct FoodMetadata {
    enum Kind: String { case direct, reference, pending }
    let kind: Kind
    let recordID: String?
    let preparation: String
    let referenceDescription: String?
    let fiberBasis: String?
    let fiberPer100g: Double?
    let lactosePer100g: Double?
    let purinePer100g: Double?

    init(kind: Kind, recordID: String? = nil, preparation: String, referenceDescription: String? = nil,
         fiberBasis: String? = nil, fiberPer100g: Double? = nil,
         lactosePer100g: Double? = nil, purinePer100g: Double? = nil) {
        self.kind = kind
        self.recordID = recordID
        self.preparation = preparation
        self.referenceDescription = referenceDescription
        self.fiberBasis = fiberBasis
        self.fiberPer100g = Self.validAmount(fiberPer100g)
        self.lactosePer100g = Self.validAmount(lactosePer100g)
        self.purinePer100g = Self.validAmount(purinePer100g)
    }

    private static func validAmount(_ amount: Double?) -> Double? {
        guard let amount, amount.isFinite, amount >= 0 else { return nil }
        return amount
    }
}
