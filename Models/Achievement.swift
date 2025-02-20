import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let points: Int
    let requirementType: RequirementType
    let requirementValue: Int
    var isUnlocked: Bool

    enum RequirementType: String, Codable {
        case visitAttractions
        case collectItems
        case earnPoints
    }
}
