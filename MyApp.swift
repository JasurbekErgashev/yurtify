import SwiftUI

@main
struct MyApp: App {
    // MARK: - State Objects

    @StateObject private var dataService = DataService.shared
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var progressManager: UserProgressManager

    // MARK: - State

    @State private var errorMessage: String?

    // MARK: - Initialization

    init() {
        let notificationManager = NotificationManager()
        _notificationManager = StateObject(wrappedValue: notificationManager)
        _progressManager = StateObject(wrappedValue: UserProgressManager(notificationManager: notificationManager))
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    await loadInitialData()
                }
                .alert(
                    "Error Loading Data",
                    isPresented: .init(
                        get: { errorMessage != nil },
                        set: { if !$0 { errorMessage = nil } }
                    )
                ) {
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
                .withNotifications(manager: notificationManager)
        }
    }

    // MARK: - Private Methods

    private func loadInitialData() async {
        do {
            try await dataService.loadAllData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
