import SwiftUI

struct UserProgressView: View {
    @EnvironmentObject private var progressManager: UserProgressManager

    var body: some View {
        List {
            // Current Rank Section
            Section {
                HStack {
                    Text(progressManager.progress.currentRank.icon)
                        .font(.system(size: 40))

                    VStack(alignment: .leading) {
                        Text(progressManager.progress.currentRank.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let nextRank = progressManager.nextRank {
                            Text("\(progressManager.pointsToNextRank) XP to \(nextRank.rawValue)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Current Rank")
            }

            // Points Section
            Section {
                HStack {
                    Label {
                        Text("Total Points Earned")
                    } icon: {
                        Image(systemName: "star.circle.fill")
                            .foregroundStyle(.yellow)
                    }

                    Spacer()

                    Text("\(progressManager.progress.totalPoints) XP")
                        .fontWeight(.medium)
                }
            } header: {
                Text("Points")
            }

            // Progress Section
            Section {
                HStack {
                    Label {
                        Text("Attractions Visited")
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                    }

                    Spacer()

                    Text("\(progressManager.progress.visitedAttractions.count)")
                        .fontWeight(.medium)
                }

                HStack {
                    Label {
                        Text("Items Collected")
                    } icon: {
                        Image(systemName: "cube.fill")
                            .foregroundStyle(.blue)
                    }

                    Spacer()

                    Text("\(progressManager.progress.collectedItems.count)")
                        .fontWeight(.medium)
                }
            } header: {
                Text("Progress")
            }

            // Rank Progress Section
            Section {
                ForEach(ExplorerRank.allCases, id: \.self) { rank in
                    HStack {
                        Text(rank.icon)
                        Text(rank.rawValue)
                        Spacer()
                        if progressManager.progress.currentRank == rank {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        Text("\(rank.requiredPoints) XP")
                            .foregroundStyle(.secondary)
                    }
                    .fontWeight(progressManager.progress.currentRank == rank ? .bold : .regular)
                }
            } header: {
                Text("Ranks")
            }
        }
        .navigationTitle("Your Progress")
    }
}
