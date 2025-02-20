import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var dataService: DataService
    @State private var showAchievements = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Progress Summary
                    ProgressSummaryCard()
                        .padding(.horizontal)

                    // Countries List
                    ForEach(dataService.countries) { country in
                        CountryCard(country: country)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Explore Central Asia")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAchievements.toggle()
                    } label: {
                        Label("Achievements", systemImage: "trophy.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DataService.shared)
}
