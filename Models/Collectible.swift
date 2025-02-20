import SwiftUI

struct Collectible: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: CollectibleCategory
    let rarity: Rarity
    let points: Int

    enum CollectibleCategory: String, Codable, CaseIterable {
        case historical = "Historical Item"
        case modern = "Modern Item"
        case nature = "Natural Item"
        case cuisine = "Culinary Item"

        var icon: String {
            switch self {
            case .historical: return "🏺"
            case .modern: return "🎨"
            case .nature: return "🌿"
            case .cuisine: return "🍲"
            }
        }

        var color: Color {
            switch self {
            case .historical: return .brown
            case .modern: return .blue
            case .nature: return .green
            case .cuisine: return .orange
            }
        }
    }

    enum Rarity: String, Codable, CaseIterable {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case legendary = "Legendary"

        var color: Color {
            switch self {
            case .common: return .gray
            case .uncommon: return .green
            case .rare: return .blue
            case .legendary: return .purple
            }
        }
    }
}
