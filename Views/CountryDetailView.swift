import SwiftUI

struct CountryDetailView: View {
    let country: Country
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategories: Set<Category> = []

    private var filteredAttractions: [Attraction] {
        if selectedCategories.isEmpty {
            return country.attractions
        }
        return country.attractions.filter { selectedCategories.contains($0.category) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .top, spacing: 16) {
                    Text(country.flagEmoji)
                        .font(.system(size: 60))
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .frame(width: 80, height: 80)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Capital: \(country.capital)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(country.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)

                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(country.categories, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                toggleCategory(category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Divider()
                    .padding(.horizontal)

                // Attractions
                LazyVStack(spacing: 0) {
                    ForEach(filteredAttractions) { attraction in
                        AttractionCard(attraction: attraction)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
