import SwiftUI

// MARK: - Data Service Errors

enum DataError: Error {
    case fileNotFound
    case decodingError
    case encodingError
    case savingError

    var description: String {
        switch self {
        case .fileNotFound: return "File not found in the bundle"
        case .decodingError: return "Failed to decode data"
        case .encodingError: return "Failed to encode data"
        case .savingError: return "Failed to save data"
        }
    }
}

// MARK: - Data Service

@MainActor
class DataService: ObservableObject {
    static let shared = DataService()

    @Published private(set) var countries: [Country] = []
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var collectibles: [Collectible] = []
    @Published private(set) var userProgress: UserProgress

    private init() {
        // Initialize with empty user progress
        userProgress = UserProgress()
    }

    // MARK: - Loading Data

    func loadAllData() async throws {
        async let countriesResult = loadCountries()
        async let achievementsResult = loadAchievements()
        async let collectiblesResult = loadCollectibles()
        async let userProgressResult = loadUserProgress()

        do {
            let (countries, achievements, collectibles, progress) = try await (
                countriesResult,
                achievementsResult,
                collectiblesResult,
                userProgressResult
            )

            self.countries = countries
            self.achievements = achievements
            self.collectibles = collectibles
            userProgress = progress
        } catch {
            print("Error loading data: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Individual Loaders

    private func loadCountries() async throws -> [Country] {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            throw DataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let container = try decoder.decode(CountriesContainer.self, from: data)
        return container.countries
    }

    private func loadAchievements() async throws -> [Achievement] {
        guard let url = Bundle.main.url(forResource: "achievements", withExtension: "json") else {
            throw DataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let container = try decoder.decode(AchievementsContainer.self, from: data)
        return container.achievements
    }

    private func loadCollectibles() async throws -> [Collectible] {
        guard let url = Bundle.main.url(forResource: "collectibles", withExtension: "json") else {
            throw DataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let container = try decoder.decode(CollectiblesContainer.self, from: data)
        return container.collectibles
    }

    private func loadUserProgress() async throws -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: "userProgress") {
            let decoder = JSONDecoder()
            return try decoder.decode(UserProgress.self, from: data)
        }
        return UserProgress() // Return new progress if none exists
    }

    // MARK: - Saving Data

    func saveUserProgress() throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(userProgress)
            UserDefaults.standard.set(data, forKey: "userProgress")
        } catch {
            throw DataError.savingError
        }
    }

    // MARK: - Update Methods

    func updateProgress(for achievement: Achievement) async throws {
        userProgress.achievements.append(achievement)
        try saveUserProgress()
    }

    func addVisitedAttraction(_ attractionId: String) async throws {
        userProgress.visitedAttractions.insert(attractionId)
        try saveUserProgress()
    }

    func addCollectedItem(_ itemId: String) async throws {
        userProgress.collectedItems.insert(itemId)
        try saveUserProgress()
    }
}

// MARK: - JSON Container Structures

private struct CountriesContainer: Codable {
    let countries: [Country]
}

private struct AchievementsContainer: Codable {
    let achievements: [Achievement]
}

private struct CollectiblesContainer: Codable {
    let collectibles: [Collectible]
}
