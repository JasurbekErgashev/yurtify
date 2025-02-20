import Foundation

struct Attraction: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: Category
    let images: [ImageAsset]
    let funFacts: [String]
    let yearBuilt: String?
    let location: String
    let collectibles: [Collectible]
    let explorationPoints: Int
}
