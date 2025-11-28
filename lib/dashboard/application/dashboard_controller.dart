import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/rendez_vous.dart';
import '../../core/services/appointment_service.dart';

class DashboardState {
  const DashboardState({
    required this.allAppointments,
    required this.upcomingAppointments,
    this.isLoading = false,
  });

  final List<RendezVous> allAppointments;
  final List<RendezVous> upcomingAppointments;
  final bool isLoading;

  /// Rendez-vous confirmés (à venir)
  int get countUpcoming {
    return upcomingAppointments
        .where((rdv) => rdv.status == RendezVousStatus.confirme)
        .length;
  }

  /// Rendez-vous terminés
  int get countCompleted {
    return allAppointments
        .where((rdv) => rdv.status == RendezVousStatus.termine)
        .length;
  }

  /// Rendez-vous annulés
  int get countCancelled {
    return allAppointments
        .where((rdv) => rdv.status == RendezVousStatus.annule)
        .length;
  }

  /// Total de rendez-vous
  int get countTotal => allAppointments.length;

  /// Prochain rendez-vous (le plus proche dans le temps)
  RendezVous? get nextAppointment {
    if (upcomingAppointments.isEmpty) return null;
    return upcomingAppointments.first;
  }

  DashboardState copyWith({
    List<RendezVous>? allAppointments,
    List<RendezVous>? upcomingAppointments,
    bool? isLoading,
  }) {
    return DashboardState(
      allAppointments: allAppointments ?? this.allAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = DashboardState(
    allAppointments: [],
    upcomingAppointments: [],
  );
}

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._appointmentService) : super(DashboardState.empty);

  final AppointmentService _appointmentService;

  Future<void> load(String patientId) async {
    state = state.copyWith(isLoading: true);
    try {
      final allAppointments = await _appointmentService.getAllPatientAppointments(patientId);
      final upcoming = await _appointmentService.getUpcomingRendezVous(patientId);
      
      state = state.copyWith(
        allAppointments: allAppointments,
        upcomingAppointments: upcoming,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> refresh(String patientId) async {
    await load(patientId);
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return DashboardController(appointmentService);
});
