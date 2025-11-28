import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/medecin.dart';
import '../../core/services/doctor_profile_service.dart';

enum DoctorProfileStatus {
  idle,
  loading,
  success,
  updating,
  error,
}

class DoctorProfileState {
  const DoctorProfileState({
    this.doctor,
    this.status = DoctorProfileStatus.idle,
    this.errorMessage,
  });

  final Medecin? doctor;
  final DoctorProfileStatus status;
  final String? errorMessage;

  DoctorProfileState copyWith({
    Medecin? doctor,
    DoctorProfileStatus? status,
    String? errorMessage,
  }) {
    return DoctorProfileState(
      doctor: doctor ?? this.doctor,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static const initial = DoctorProfileState();
}

class DoctorProfileController extends StateNotifier<DoctorProfileState> {
  DoctorProfileController(this._service) : super(DoctorProfileState.initial);

  final DoctorProfileService _service;

  /// Charge le profil du médecin connecté
  Future<void> loadProfile() async {
    state = state.copyWith(status: DoctorProfileStatus.loading);
    try {
      final doctor = await _service.getCurrentDoctorProfile();
      if (doctor == null) {
        state = state.copyWith(
          status: DoctorProfileStatus.error,
          errorMessage: 'Profil médecin non trouvé',
        );
        return;
      }
      state = state.copyWith(
        doctor: doctor,
        status: DoctorProfileStatus.success,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: DoctorProfileStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Met à jour le profil du médecin
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final currentDoctor = state.doctor;
    if (currentDoctor == null) {
      state = state.copyWith(
        status: DoctorProfileStatus.error,
        errorMessage: 'Aucun profil à mettre à jour',
      );
      return;
    }

    state = state.copyWith(status: DoctorProfileStatus.updating);
    try {
      final updatedDoctor = await _service.updateDoctorProfile(
        currentDoctor.id,
        updates,
      );
      state = state.copyWith(
        doctor: updatedDoctor,
        status: DoctorProfileStatus.success,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: DoctorProfileStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }
}

/// Provider pour le controller de profil médecin
final doctorProfileControllerProvider =
    StateNotifierProvider<DoctorProfileController, DoctorProfileState>((ref) {
  final service = ref.watch(doctorProfileServiceProvider);
  return DoctorProfileController(service);
});

