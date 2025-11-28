import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../core/domain/patient.dart';
import '../../core/services/appointment_service.dart';
import '../../core/services/patient_profile_service.dart';

enum ProfileStatus {
  idle,
  loading,
  updating,
  success,
  error,
}

class ProfileState {
  const ProfileState({
    required this.patient,
    this.status = ProfileStatus.idle,
    this.errorMessage,
    this.totalConsultations = 0,
    this.upcomingAppointments = 0,
  });

  final Patient patient;
  final ProfileStatus status;
  final String? errorMessage;
  final int totalConsultations;
  final int upcomingAppointments;

  ProfileState copyWith({
    Patient? patient,
    ProfileStatus? status,
    String? errorMessage,
    int? totalConsultations,
    int? upcomingAppointments,
  }) {
    return ProfileState(
      patient: patient ?? this.patient,
      status: status ?? this.status,
      errorMessage: errorMessage,
      totalConsultations: totalConsultations ?? this.totalConsultations,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(
    this._profileService,
    this._appointmentService,
    Patient initialPatient,
  ) : super(ProfileState(patient: initialPatient));

  final PatientProfileService _profileService;
  final AppointmentService _appointmentService;

  Future<void> loadProfile(String patientId) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final patient = await _profileService.getPatientProfile(patientId);
      
      // Charger les statistiques
      final allAppointments = await _appointmentService.getAllPatientAppointments(patientId);
      final upcoming = await _appointmentService.getUpcomingRendezVous(patientId);
      
      state = state.copyWith(
        patient: patient,
        status: ProfileStatus.idle,
        totalConsultations: allAppointments.length,
        upcomingAppointments: upcoming.length,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(status: ProfileStatus.updating);
    try {
      final updatedPatient = await _profileService.updatePatientProfile(
        state.patient.id,
        updates,
      );
      
      state = state.copyWith(
        patient: updatedPatient,
        status: ProfileStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      status: ProfileStatus.idle,
      errorMessage: null,
    );
  }
}

/// Provider pour ProfileController
/// Nécessite un patientId en paramètre
final profileControllerProvider = StateNotifierProvider.family<
    ProfileController, ProfileState, String>((ref, patientId) {
  final profileService = ref.watch(patientProfileServiceProvider);
  final appointmentService = ref.watch(appointmentServiceProvider);
  
  // Récupérer le patient initial depuis auth
  final authState = ref.watch(authControllerProvider);
  final initialPatient = authState.patient ?? Patient(
    id: patientId,
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
  );
  
  final controller = ProfileController(
    profileService,
    appointmentService,
    initialPatient,
  );
  
  // Charger le profil au démarrage
  controller.loadProfile(patientId);
  
  return controller;
});

