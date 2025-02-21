import Foundation

struct UserProgress: Codable {
    var totalPoints: Int
    var visitedAttractions: Set<String>
    var collectedItems: Set<String>
    var achievements: [Achievement]
    var currentRank: ExplorerRank

    init() {
        totalPoints = 0
        visitedAttractions = []
        collectedItems = []
        achievements = []
        currentRank = .beginner
    }
}

enum ExplorerRank: String, Codable, CaseIterable {
    case beginner = "Beginner Explorer"
    case adventurer = "Adventurer"
    case expert = "Expert Explorer"
    case master = "Master Explorer"
    case legend = "Legendary Explorer"

    var requiredPoints: Int {
        switch self {
        case .beginner: return 0
        case .adventurer: return 1000
        case .expert: return 5000
        case .master: return 10000
        case .legend: return 18000
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "🌱"
        case .adventurer: return "🌟"
        case .expert: return "⭐️"
        case .master: return "👑"
        case .legend: return "🏆"
        }
    }
}
