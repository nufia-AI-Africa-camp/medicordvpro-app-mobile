import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/rendez_vous.dart';
import '../../core/services/doctor_appointment_service.dart';

class DoctorAppointmentsState {
  const DoctorAppointmentsState({
    this.appointments = const [],
    this.selectedStatus,
    this.isLoading = false,
    this.error,
  });

  final List<RendezVous> appointments;
  final RendezVousStatus? selectedStatus;
  final bool isLoading;
  final String? error;

  /// Rendez-vous filtrés par statut
  List<RendezVous> get filteredAppointments {
    if (selectedStatus == null) {
      return appointments;
    }
    return appointments.where((rdv) => rdv.status == selectedStatus).toList();
  }

  /// Compte par statut
  int getCountByStatus(RendezVousStatus status) {
    return appointments.where((rdv) => rdv.status == status).length;
  }

  DoctorAppointmentsState copyWith({
    List<RendezVous>? appointments,
    RendezVousStatus? selectedStatus,
    bool? isLoading,
    String? error,
  }) {
    return DoctorAppointmentsState(
      appointments: appointments ?? this.appointments,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const empty = DoctorAppointmentsState();
}

class DoctorAppointmentsController
    extends StateNotifier<DoctorAppointmentsState> {
  DoctorAppointmentsController(this._doctorAppointmentService)
      : super(DoctorAppointmentsState.empty);

  final DoctorAppointmentService _doctorAppointmentService;

  /// Charge tous les rendez-vous d'un médecin
  Future<void> load(String medecinId, {RendezVousStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appointments = await _doctorAppointmentService.getDoctorAppointments(
        medecinId,
        status: status,
      );

      state = state.copyWith(
        appointments: appointments,
        selectedStatus: status,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filtre par statut
  void filterByStatus(RendezVousStatus? status) {
    state = state.copyWith(selectedStatus: status);
  }

  /// Confirme un rendez-vous
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _doctorAppointmentService.confirmAppointment(appointmentId);
      // Recharger les rendez-vous
      // Note: On devrait avoir le medecinId dans le state, mais pour l'instant on recharge tout
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Annule un rendez-vous
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _doctorAppointmentService.cancelAppointment(appointmentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Marque comme terminé
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _doctorAppointmentService.completeAppointment(appointmentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Marque comme absent
  Future<void> markAbsent(String appointmentId) async {
    try {
      await _doctorAppointmentService.markAbsent(appointmentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Rafraîchit les rendez-vous
  Future<void> refresh(String medecinId) async {
    await load(medecinId, status: state.selectedStatus);
  }
}

final doctorAppointmentsControllerProvider =
    StateNotifierProvider<DoctorAppointmentsController, DoctorAppointmentsState>(
  (ref) {
    final doctorAppointmentService = ref.watch(doctorAppointmentServiceProvider);
    return DoctorAppointmentsController(doctorAppointmentService);
  },
);

