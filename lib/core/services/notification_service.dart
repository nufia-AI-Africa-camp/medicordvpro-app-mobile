import '../domain/notification_item.dart';

/// Contract for notification operations (local storage + remote sync if needed).
abstract class NotificationService {
  Future<List<NotificationItem>> getNotifications(String patientId);

  Future<void> markAsRead(String notificationId);
}


