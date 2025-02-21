import SwiftUI

// MARK: - User Progress Manager Protocol

@MainActor
protocol UserProgressManaging {
    var progress: UserProgress { get }
    var nextRank: ExplorerRank? { get }
    var pointsToNextRank: Int { get }

    func recordVisit(to attractionId: String, points: Int)
    func recordCollectible(_ collectibleId: String, points: Int)
    func resetProgress()
}

// MARK: - User Progress Manager

@MainActor
final class UserProgressManager: ObservableObject, UserProgressManaging {
    // MARK: - Published Properties

    @Published private(set) var progress: UserProgress {
        didSet {
            save()
        }
    }

    // MARK: - Dependencies

    private let dataService: DataService
    private let notificationManager: NotificationManager

    // MARK: - Constants

    private enum Constants {
        static let saveKey = "UserProgress"
    }

    // MARK: - Initialization

    init(notificationManager: NotificationManager) {
        dataService = DataService.shared
        self.notificationManager = notificationManager
        progress = Self.loadSavedProgress()
    }

    // MARK: - Persistence

    private static func loadSavedProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: Constants.saveKey),
              let savedProgress = try? JSONDecoder().decode(UserProgress.self, from: data)
        else {
            return UserProgress()
        }
        return savedProgress
    }

    private func save() {
        guard let encoded = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(encoded, forKey: Constants.saveKey)
    }

    // MARK: - Rank Management

    var nextRank: ExplorerRank? {
        let currentIndex = ExplorerRank.allCases.firstIndex(of: progress.currentRank) ?? 0
        let nextIndex = currentIndex + 1
        return nextIndex < ExplorerRank.allCases.count ? ExplorerRank.allCases[nextIndex] : nil
    }

    var pointsToNextRank: Int {
        guard let next = nextRank else { return 0 }
        return max(0, next.requiredPoints - progress.totalPoints)
    }

    private func updateRank() {
        for rank in ExplorerRank.allCases.reversed() where progress.totalPoints >= rank.requiredPoints {
            progress.currentRank = rank
            break
        }
    }

    // MARK: - Progress Recording

    func recordVisit(to attractionId: String, points: Int) {
        guard !progress.visitedAttractions.contains(attractionId) else { return }

        progress.visitedAttractions.insert(attractionId)
        addPoints(points)
        checkAchievements()
    }

    func recordCollectible(_ collectibleId: String, points: Int) {
        guard !progress.collectedItems.contains(collectibleId) else { return }

        progress.collectedItems.insert(collectibleId)
        addPoints(points)
        checkAchievements()
    }

    // MARK: - Points Management

    private func addPoints(_ points: Int) {
        progress.totalPoints += points
        updateRank()
        checkAchievements()
    }

    // MARK: - Achievement Management

    private func checkAchievements() {
        for achievement in dataService.achievements {
            processAchievement(achievement)
        }
    }

    private func processAchievement(_ achievement: Achievement) {
        // Skip if already achieved
        guard !progress.achievements.contains(where: { $0.id == achievement.id }) else { return }

        let current = getCurrentProgress(for: achievement.requirementType)
        guard current >= achievement.requirementValue else { return }

        unlockAchievement(achievement)
    }

    private func getCurrentProgress(for requirementType: Achievement.RequirementType) -> Int {
        switch requirementType {
        case .visitAttractions:
            return progress.visitedAttractions.count
        case .collectItems:
            return progress.collectedItems.count
        case .earnPoints:
            return progress.totalPoints
        }
    }

    private func unlockAchievement(_ achievement: Achievement) {
        progress.achievements.append(achievement)
        progress.totalPoints += achievement.points
        updateRank()

        notificationManager.showNotification(
            message: "New Achievement: \(achievement.title)",
            icon: achievement.icon,
            points: achievement.points
        )
    }

    // MARK: - Reset

    func resetProgress() {
        progress = UserProgress()
        save()

        notificationManager.showNotification(
            message: "Progress Reset Successfully",
            icon: "🔄",
            points: nil
        )
    }
}
