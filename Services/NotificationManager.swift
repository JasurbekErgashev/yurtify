import SwiftUI

// MARK: - Notification Manager Protocol

@MainActor
protocol NotificationManaging {
    var isShowingNotification: Bool { get }
    var notificationMessage: String { get }
    var notificationIcon: String { get }
    var notificationPoints: Int? { get }

    func showNotification(message: String, icon: String, points: Int?)
}

// MARK: - Notification Manager

@MainActor
final class NotificationManager: ObservableObject, NotificationManaging {
    // Published Properties

    @Published private(set) var isShowingNotification = false
    @Published private(set) var notificationMessage = ""
    @Published private(set) var notificationIcon = ""
    @Published private(set) var notificationPoints: Int?

    // Private Properties

    private var task: Task<Void, Never>?

    // Constants

    private enum Constants {
        static let showDuration: UInt64 = 3_000_000_000 // 3 seconds in nanoseconds
        static let animationDuration = 0.5
        static let animationDamping = 0.7
    }

    // Public Methods

    func showNotification(message: String, icon: String, points: Int? = nil) {
        // Cancel any existing hide task
        task?.cancel()

        // Update notification content
        notificationMessage = message
        notificationIcon = icon
        notificationPoints = points

        withAnimation(.spring(
            response: Constants.animationDuration,
            dampingFraction: Constants.animationDamping
        )) {
            isShowingNotification = true
        }

        // Auto-hide notification
        task = Task {
            try? await Task.sleep(nanoseconds: Constants.showDuration)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.spring(
                    response: Constants.animationDuration,
                    dampingFraction: Constants.animationDamping
                )) {
                    isShowingNotification = false
                }
            }
        }
    }
}

// MARK: - Notification Banner View

struct NotificationBanner: View {
    // Properties

    let message: String
    let icon: String
    let points: Int?

    // Body

    var body: some View {
        HStack(spacing: 16) {
            iconView
            messageView
            Spacer(minLength: 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(bannerBackground)
    }

    // View Components

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .blue.opacity(0.8),
                                    .purple.opacity(0.5),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                        .blur(radius: 1)
                }
                .frame(width: 46, height: 46)

            Text(icon)
                .font(.title2)
        }
    }

    private var messageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)

            if let points = points {
                Text("+\(points.formattedWithSpaces) XP")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }

    private var bannerBackground: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .opacity(0.7)
                .blur(radius: 10)

            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            .blue.opacity(0.5),
                            .purple.opacity(0.3),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Notification Container Modifier

struct NotificationContainer: ViewModifier {
    // Properties

    @ObservedObject var notificationManager: NotificationManager

    // Body

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if notificationManager.isShowingNotification {
                NotificationBanner(
                    message: notificationManager.notificationMessage,
                    icon: notificationManager.notificationIcon,
                    points: notificationManager.notificationPoints
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}
