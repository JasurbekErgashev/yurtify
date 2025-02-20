import SwiftUI

@main
struct MyApp: App {
    @StateObject private var dataService = DataService.shared
    @StateObject private var progressManager = UserProgressManager()
    @State private var errorMessage: String?

    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    do {
                        try await dataService.loadAllData()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                .alert("Error Loading Data", isPresented: .init(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )) {
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
                .environmentObject(dataService)
                .environmentObject(progressManager)
        }
    }
}
