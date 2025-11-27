import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/notification_item.dart';
import '../../core/domain/rendez_vous.dart';

class DashboardState {
  const DashboardState({
    required this.upcomingRendezVous,
    required this.latestNotifications,
    this.isLoading = false,
  });

  final List<RendezVous> upcomingRendezVous;
  final List<NotificationItem> latestNotifications;
  final bool isLoading;

  DashboardState copyWith({
    List<RendezVous>? upcomingRendezVous,
    List<NotificationItem>? latestNotifications,
    bool? isLoading,
  }) {
    return DashboardState(
      upcomingRendezVous: upcomingRendezVous ?? this.upcomingRendezVous,
      latestNotifications: latestNotifications ?? this.latestNotifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = DashboardState(
    upcomingRendezVous: [],
    latestNotifications: [],
  );
}

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController() : super(DashboardState.empty);

  Future<void> refresh(String patientId) async {
    state = state.copyWith(isLoading: true);
    // TODO: plug AppointmentService and NotificationService here.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false);
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController();
});


