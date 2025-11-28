import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/appointment_service.dart';
import '../../auth/application/auth_controller.dart';

class AppointmentCreationState {
  const AppointmentCreationState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  AppointmentCreationState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppointmentCreationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static const initial = AppointmentCreationState();
}

class AppointmentCreationController
    extends StateNotifier<AppointmentCreationState> {
  AppointmentCreationController(
    this._appointmentService,
    this._authController,
  ) : super(AppointmentCreationState.initial);

  final AppointmentService _appointmentService;
  final AuthController _authController;

  Future<void> createAppointment({
    required String medecinId,
    required DateTime dateTime,
    String? motif,
    String? notes,
    String? centreMedicalId,
  }) async {
    final authState = _authController.state;
    final patient = authState.patient;

    if (patient == null) {
      state = state.copyWith(
        errorMessage: 'Vous devez être connecté pour créer un rendez-vous',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _appointmentService.createRendezVous(
        patientId: patient.id,
        medecinId: medecinId,
        dateTime: dateTime,
        motif: motif,
        notes: notes,
        centreMedicalId: centreMedicalId,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().contains('Erreur')
            ? e.toString()
            : 'Erreur lors de la création du rendez-vous: ${e.toString()}',
      );
      rethrow;
    }
  }
}

final appointmentCreationControllerProvider =
    StateNotifierProvider<AppointmentCreationController,
        AppointmentCreationState>((ref) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  final authController = ref.watch(authControllerProvider.notifier);
  return AppointmentCreationController(appointmentService, authController);
});

