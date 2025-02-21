import SwiftUI

extension View {
    /// Adds a notification banner to the view that will be shown when the notification manager triggers a notification.
    /// - Parameter manager: The notification manager that controls when notifications are shown.
    /// - Returns: A view with notification banner support.
    func withNotifications(manager: NotificationManager) -> some View {
        modifier(NotificationContainer(notificationManager: manager))
    }
}
