import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/notification_item.dart';
import '../../core/services/notification_service.dart';

class NotificationsState {
  const NotificationsState({
    required this.items,
    this.isLoading = false,
  });

  final List<NotificationItem> items;
  final bool isLoading;

  NotificationsState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = NotificationsState(items: []);
}

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._service) : super(NotificationsState.empty);

  final NotificationService _service;

  Future<void> load(String patientId) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.getNotifications(patientId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Replace with a real implementation when the backend is ready.
  throw UnimplementedError('NotificationService not implemented yet');
});

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationsController(service);
});


