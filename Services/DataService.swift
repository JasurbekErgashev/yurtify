import SwiftUI

// MARK: - Data Service Errors

enum DataError: Error {
    case fileNotFound
    case decodingError
    case encodingError

    var description: String {
        switch self {
        case .fileNotFound: return "File not found in the bundle"
        case .decodingError: return "Failed to decode data"
        case .encodingError: return "Failed to encode data"
        }
    }
}

// MARK: - Data Service Protocol

@MainActor
protocol DataServiceProtocol {
    var countries: [Country] { get }
    var achievements: [Achievement] { get }
    var collectibles: [Collectible] { get }

    func loadAllData() async throws
}

// MARK: - Data Service

@MainActor
final class DataService: ObservableObject, DataServiceProtocol {
    // Singleton

    static let shared = DataService()

    // Published Properties

    @Published private(set) var countries: [Country] = []
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var collectibles: [Collectible] = []

    // Constants

    private enum Constants {
        static let countriesFile = "countries"
        static let achievementsFile = "achievements"
        static let collectiblesFile = "collectibles"
    }

    // Initialization

    private init() {}

    // Data Loading

    func loadAllData() async throws {
        async let countriesResult = loadResource(
            Constants.countriesFile,
            type: CountriesContainer.self,
            keyPath: \.countries
        )
        async let achievementsResult = loadResource(
            Constants.achievementsFile,
            type: AchievementsContainer.self,
            keyPath: \.achievements
        )
        async let collectiblesResult = loadResource(
            Constants.collectiblesFile,
            type: CollectiblesContainer.self,
            keyPath: \.collectibles
        )

        do {
            let (countries, achievements, collectibles) = try await (
                countriesResult,
                achievementsResult,
                collectiblesResult
            )

            self.countries = countries
            self.achievements = achievements
            self.collectibles = collectibles
        } catch {
            print("Error loading data: \(error.localizedDescription)")
            throw error
        }
    }

    // Private Helpers

    private func loadResource<T: Decodable, U>(_ filename: String, type _: T.Type, keyPath: KeyPath<T, U>) async throws -> U {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw DataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let container = try decoder.decode(T.self, from: data)
        return container[keyPath: keyPath]
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
