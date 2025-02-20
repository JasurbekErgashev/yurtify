import SwiftUI

struct ProgressSummaryCard: View {
    @EnvironmentObject private var progressManager: UserProgressManager

    var body: some View {
        NavigationLink {
            UserProgressView()
        } label: {
            VStack(spacing: 16) {
                // Current Rank and Points
                HStack {
                    VStack(alignment: .leading) {
                        Text(progressManager.progress.currentRank.icon + " " + progressManager.progress.currentRank.rawValue)
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("\(progressManager.progress.totalPoints) XP earned")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    NavigationLink {
                        UserProgressView()
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Progress to Next Rank
                if let nextRank = progressManager.nextRank {
                    VStack(alignment: .leading, spacing: 8) {
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.quaternary)
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.blue)
                                    .frame(width: calculateProgress(totalWidth: geometry.size.width), height: 8)
                            }
                        }
                        .frame(height: 8)

                        // Next Rank Info
                        HStack {
                            Text("\(progressManager.pointsToNextRank) XP to \(nextRank.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(nextRank.icon)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func calculateProgress(totalWidth: CGFloat) -> CGFloat {
        guard let nextRank = progressManager.nextRank else { return totalWidth }

        let currentPoints = progressManager.progress.totalPoints
        let currentRankPoints = progressManager.progress.currentRank.requiredPoints
        let nextRankPoints = nextRank.requiredPoints

        let progress = Double(currentPoints - currentRankPoints) / Double(nextRankPoints - currentRankPoints)
        return totalWidth * progress
    }
}
