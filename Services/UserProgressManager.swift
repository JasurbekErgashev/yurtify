import SwiftUI

@MainActor
class UserProgressManager: ObservableObject {
    @Published var progress: UserProgress {
        didSet {
            save()
        }
    }

    private let saveKey = "UserProgress"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let savedProgress = try? JSONDecoder().decode(UserProgress.self, from: data)
        {
            progress = savedProgress
        } else {
            progress = UserProgress()
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    var nextRank: ExplorerRank? {
        let currentIndex = ExplorerRank.allCases.firstIndex(of: progress.currentRank) ?? 0
        let nextIndex = currentIndex + 1
        return nextIndex < ExplorerRank.allCases.count ? ExplorerRank.allCases[nextIndex] : nil
    }

    var pointsToNextRank: Int {
        guard let next = nextRank else { return 0 }
        return max(0, next.requiredPoints - progress.totalPoints)
    }

    func updateRank() {
        for rank in ExplorerRank.allCases.reversed() {
            if progress.totalPoints >= rank.requiredPoints {
                progress.currentRank = rank
                break
            }
        }
    }

    func recordVisit(to attractionId: String, points: Int) {
        if !progress.visitedAttractions.contains(attractionId) {
            progress.visitedAttractions.insert(attractionId)
            addPoints(points)
            objectWillChange.send()
        }
    }

    func recordCollectible(_ collectibleId: String, points: Int) {
        if !progress.collectedItems.contains(collectibleId) {
            progress.collectedItems.insert(collectibleId)
            addPoints(points)
            objectWillChange.send()
        }
    }

    private func addPoints(_ points: Int) {
        progress.totalPoints += points
        updateRank()
    }
}
