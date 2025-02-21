import Foundation

struct Country: Identifiable, Codable {
    let id: String
    let name: String
    let flagEmoji: String
    let description: String
    let capital: String
    let attractions: [Attraction]
    let categories: [Category]
}
