import SwiftUI

struct AttractionDetailView: View {
    let attraction: Attraction
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressManager: UserProgressManager
    @State private var selectedImageIndex = 0
    @State private var randomCollectible: Collectible?
    @State private var isCollectibleCollected = false
    @State private var hasRecordedVisit = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image Section with Carousel
                TabView(selection: $selectedImageIndex) {
                    ForEach(Array(attraction.images.enumerated()), id: \.offset) { index, image in
                        Image(image.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .tag(index)
                    }
                }
                .frame(height: 300)
                .tabViewStyle(.page)

                // Content Section
                VStack(alignment: .leading, spacing: 24) {
                    // Image Credit
                    Text("Photo: \(attraction.images[selectedImageIndex].credit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    // Title and Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text(attraction.name)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack {
                            CategoryPill(category: attraction.category)
                            Spacer()
                            Text("\(attraction.explorationPoints) XP")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)

                    // Location and Year Built
                    HStack(spacing: 16) {
                        // Location
                        VStack(alignment: .leading, spacing: 4) {
                            Label(attraction.location, systemImage: "mappin.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            if let yearBuilt = attraction.yearBuilt {
                                Label(yearBuilt, systemImage: "calendar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(attraction.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Interesting Facts
                    if !attraction.funFacts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interesting Facts")
                                .font(.title2)
                                .fontWeight(.bold)

                            ForEach(attraction.funFacts, id: \.self) { fact in
                                InterestingFactCard(fact: fact)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottomTrailing) {
            if let collectible = randomCollectible, !isCollectibleCollected {
                FloatingCollectibleButton(
                    collectible: collectible,
                    isCollected: $isCollectibleCollected
                )
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Show uncollected collectible with 1/3 chance
            if !attraction.collectibles.isEmpty {
                let uncollectedCollectibles = attraction.collectibles.filter { collectible in
                    !progressManager.progress.collectedItems.contains(collectible.id)
                }

                if !uncollectedCollectibles.isEmpty && Double.random(in: 0 ... 1) <= 0.33 {
                    randomCollectible = uncollectedCollectibles.randomElement()
                }
            }

            // Start timer to track visit duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [attraction] in
                Task { @MainActor in
                    if !hasRecordedVisit {
                        hasRecordedVisit = true
                        progressManager.recordVisit(to: attraction.id, points: attraction.explorationPoints)
                    }
                }
            }
        }
        .onDisappear {
            hasRecordedVisit = false
        }
    }
}
