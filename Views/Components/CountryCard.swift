import SwiftUI

struct CountryCard: View {
    let country: Country

    var body: some View {
        NavigationLink(destination: CountryDetailView(country: country)) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with flag and name
                HStack {
                    Text(country.flagEmoji)
                        .font(.system(size: 40))

                    VStack(alignment: .leading) {
                        Text(country.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(country.capital)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }

                // Description
                Text(country.description)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)

                // Stats
                HStack(spacing: 16) {
                    StatView(icon: "building.2.fill",
                             value: "\(country.attractions.count)",
                             label: "Places")

                    StatView(icon: "star.fill",
                             value: country.attractions.reduce(0) { $0 + $1.explorationPoints }.formattedWithSpaces,
                             label: "XP")
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            }
        }
        .buttonStyle(.plain)
    }
}
