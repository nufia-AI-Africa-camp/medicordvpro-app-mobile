import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/medecin.dart';
import '../../core/domain/rendez_vous.dart';
import '../../core/services/appointment_service.dart';

enum AppointmentDetailStatus { idle, submitting, success, error }

class AppointmentDetailState {
  const AppointmentDetailState({
    this.selectedMedecin,
    this.selectedDateTime,
    this.createdRendezVous,
    this.status = AppointmentDetailStatus.idle,
  });

  final Medecin? selectedMedecin;
  final DateTime? selectedDateTime;
  final RendezVous? createdRendezVous;
  final AppointmentDetailStatus status;

  AppointmentDetailState copyWith({
    Medecin? selectedMedecin,
    DateTime? selectedDateTime,
    RendezVous? createdRendezVous,
    AppointmentDetailStatus? status,
  }) {
    return AppointmentDetailState(
      selectedMedecin: selectedMedecin ?? this.selectedMedecin,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      createdRendezVous: createdRendezVous ?? this.createdRendezVous,
      status: status ?? this.status,
    );
  }

  static const initial = AppointmentDetailState();
}

class AppointmentDetailController
    extends StateNotifier<AppointmentDetailState> {
  AppointmentDetailController(this._service)
      : super(AppointmentDetailState.initial);

  final AppointmentService _service;

  void selectMedecin(Medecin medecin) {
    state = state.copyWith(selectedMedecin: medecin);
  }

  void selectDateTime(DateTime dateTime) {
    state = state.copyWith(selectedDateTime: dateTime);
  }

  Future<void> confirm(String patientId) async {
    if (state.selectedMedecin == null || state.selectedDateTime == null) {
      return;
    }
    state = state.copyWith(status: AppointmentDetailStatus.submitting);
    try {
      final rdv = await _service.createRendezVous(
        patientId: patientId,
        medecinId: state.selectedMedecin!.id,
        dateTime: state.selectedDateTime!,
      );
      state = state.copyWith(
        status: AppointmentDetailStatus.success,
        createdRendezVous: rdv,
      );
    } catch (e) {
      state = state.copyWith(status: AppointmentDetailStatus.error);
    }
  }
}

final appointmentDetailControllerProvider =
    StateNotifierProvider<AppointmentDetailController, AppointmentDetailState>(
        (ref) {
  final service = ref.watch(appointmentServiceProvider);
  return AppointmentDetailController(service);
});


