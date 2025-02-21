import SwiftUI

extension View {
    // Adds a banner to the view that will be shown when the notification manager triggers a notification.
    func withNotifications(manager: NotificationManager) -> some View {
        modifier(NotificationContainer(notificationManager: manager))
    }
}
