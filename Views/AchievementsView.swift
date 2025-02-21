import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var progressManager: UserProgressManager
    @EnvironmentObject private var dataService: DataService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(dataService.achievements) { achievement in
                    HStack(spacing: 16) {
                        // Achievement Icon
                        ZStack {
                            Circle()
                                .fill(isUnlocked(achievement) ? .blue.opacity(0.2) : .gray.opacity(0.1))
                                .frame(width: 50, height: 50)

                            if isUnlocked(achievement) {
                                Text(achievement.icon)
                                    .font(.title2)
                            } else {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Achievement Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .font(.headline)

                            Text(achievement.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if !isUnlocked(achievement) {
                                // Progress Text
                                Text(progressText(for: achievement))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if isUnlocked(achievement) {
                            Text("+\(achievement.points) XP")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 8)
                }

                Text("Complete achievements to earn points and unlock new ranks!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func isUnlocked(_ achievement: Achievement) -> Bool {
        let current: Int
        switch achievement.requirementType {
        case .visitAttractions:
            current = progressManager.progress.visitedAttractions.count
        case .collectItems:
            current = progressManager.progress.collectedItems.count
        case .earnPoints:
            current = progressManager.progress.totalPoints
        }
        return current >= achievement.requirementValue
    }

    private func progressText(for achievement: Achievement) -> String {
        let current: Int
        switch achievement.requirementType {
        case .visitAttractions:
            current = progressManager.progress.visitedAttractions.count
        case .collectItems:
            current = progressManager.progress.collectedItems.count
        case .earnPoints:
            current = progressManager.progress.totalPoints
        }
        return "\(current.formattedWithSpaces)/\(achievement.requirementValue.formattedWithSpaces)"
    }
}
