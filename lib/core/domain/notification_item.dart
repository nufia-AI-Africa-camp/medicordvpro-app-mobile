enum NotificationType {
  confirmation,
  cancellation,
  modification,
  reminder,
  message,
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.date,
    this.isRead = false,
    this.relatedRendezVousId,
  });

  final String id;
  final NotificationType type;
  final String message;
  final DateTime date;
  final bool isRead;
  final String? relatedRendezVousId;
}


