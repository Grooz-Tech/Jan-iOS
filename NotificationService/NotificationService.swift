import UserNotifications

/// Intercepts incoming remote notifications before they are displayed, giving a
/// short window to modify the payload (decrypt, download media, rewrite text).
class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Modify the notification content here.
        contentHandler(bestAttemptContent)
    }

    override func serviceExtensionTimeWillExpire() {
        // The system is about to terminate the extension; deliver the best effort.
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
