import SwiftUI

struct AttractionCard: View {
    let attraction: Attraction

    var body: some View {
        NavigationLink {
            AttractionDetailView(attraction: attraction)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                imageSection
                contentSection
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var imageSection: some View {
        Group {
            if let firstImage = attraction.images.first {
                // Main Image
                Image(firstImage.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } else {
                // Placeholder
                ZStack {
                    Rectangle()
                        .fill(.gray.opacity(0.05))
                        .frame(height: 200)

                    VStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray.opacity(0.3))
                            .symbolEffect(.pulse)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Points
            HStack {
                Text(attraction.name)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("\(attraction.explorationPoints) XP")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }

            // Description
            Text(attraction.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Location
            if !attraction.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.caption)
                    Text(attraction.location)
                        .font(.caption)
                        .lineLimit(2)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}
