import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case historical = "Historical"
    case modern = "Modern"
    case nature = "Nature"
    case cuisine = "Cuisine"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .historical: return "🏛️"
        case .modern: return "🌆"
        case .nature: return "🏔️"
        case .cuisine: return "🍽️"
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
