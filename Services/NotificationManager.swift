import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    @Published var isShowingNotification = false
    @Published var notificationMessage = ""
    @Published var notificationIcon = ""
    @Published var notificationPoints: Int?
    
    private var task: Task<Void, Never>?
    
    func showNotification(message: String, icon: String, points: Int? = nil) {
        // Cancel any existing hide task
        task?.cancel()
        
        // Update notification content
        notificationMessage = message
        notificationIcon = icon
        notificationPoints = points
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isShowingNotification = true
        }
        
        // Auto-hide notification after 3 seconds
        task = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isShowingNotification = false
                }
            }
        }
    }
}

struct NotificationBanner: View {
    let message: String
    let icon: String
    let points: Int?
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji container with glowing effect
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .blue.opacity(0.8),
                                        .purple.opacity(0.5)
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                if let points = points {
                    Text("+\(points) XP")
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
            
            Spacer(minLength: 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                Color(uiColor: .systemBackground)
                    .opacity(0.7)
                    .blur(radius: 2)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                // Gradient border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .blue.opacity(0.7),
                                .purple.opacity(0.4),
                                .blue.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        .shadow(color: .blue.opacity(0.1), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct NotificationContainer: ViewModifier {
    @ObservedObject var notificationManager: NotificationManager
    @State private var offset: CGFloat = -100
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if notificationManager.isShowingNotification {
                NotificationBanner(
                    message: notificationManager.notificationMessage,
                    icon: notificationManager.notificationIcon,
                    points: notificationManager.notificationPoints
                )
                .offset(y: offset)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        offset = 0
                    }
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                }
                .onDisappear {
                    offset = -100
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: notificationManager.isShowingNotification)
    }
}

extension View {
    func withNotifications(manager: NotificationManager) -> some View {
        modifier(NotificationContainer(notificationManager: manager))
    }
}
