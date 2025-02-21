import SwiftUI

@MainActor
class UserProgressManager: ObservableObject {
    @Published var progress: UserProgress {
        didSet {
            save()
        }
    }
    
    private let saveKey = "UserProgress"
    @Published private(set) var dataService: DataService
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.dataService = DataService.shared
        self.notificationManager = notificationManager
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
            checkAchievements()
            objectWillChange.send()
        }
    }

    func recordCollectible(_ collectibleId: String, points: Int) {
        if !progress.collectedItems.contains(collectibleId) {
            progress.collectedItems.insert(collectibleId)
            addPoints(points)
            checkAchievements()
            objectWillChange.send()
        }
    }

    private func addPoints(_ points: Int) {
        progress.totalPoints += points
        updateRank()
        checkAchievements()
    }
    
    private func checkAchievements() {
        for achievement in dataService.achievements {
            // Skip if already achieved
            if progress.achievements.contains(where: { $0.id == achievement.id }) {
                continue
            }
            
            let current: Int
            switch achievement.requirementType {
            case .visitAttractions:
                current = progress.visitedAttractions.count
            case .collectItems:
                current = progress.collectedItems.count
            case .earnPoints:
                current = progress.totalPoints
            }
            
            if current >= achievement.requirementValue {
                // Add achievement
                progress.achievements.append(achievement)
                
                // Add achievement points
                progress.totalPoints += achievement.points
                updateRank()
                
                // Show notification
                notificationManager.showNotification(
                    message: "New Achievement: \(achievement.title)",
                    icon: achievement.icon,
                    points: achievement.points
                )
            }
        }
    }
    
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
