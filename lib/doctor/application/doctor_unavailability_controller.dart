import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/doctor_unavailability_service.dart';

class DoctorUnavailabilityState {
  const DoctorUnavailabilityState({
    this.unavailabilities = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DoctorUnavailability> unavailabilities;
  final bool isLoading;
  final String? error;

  /// Pauses uniquement (durée < 24h)
  List<DoctorUnavailability> get pauses {
    return unavailabilities.where((u) => u.isPause).toList();
  }

  /// Congés uniquement (durée >= 24h)
  List<DoctorUnavailability> get conges {
    return unavailabilities.where((u) => u.isConges).toList();
  }

  DoctorUnavailabilityState copyWith({
    List<DoctorUnavailability>? unavailabilities,
    bool? isLoading,
    String? error,
  }) {
    return DoctorUnavailabilityState(
      unavailabilities: unavailabilities ?? this.unavailabilities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const empty = DoctorUnavailabilityState();
}

class DoctorUnavailabilityController
    extends StateNotifier<DoctorUnavailabilityState> {
  DoctorUnavailabilityController(this._service) : super(DoctorUnavailabilityState.empty);

  final DoctorUnavailabilityService _service;

  /// Charge toutes les indisponibilités
  Future<void> load(String medecinId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final unavailabilities = await _service.getUnavailabilities(medecinId);
      state = state.copyWith(
        unavailabilities: unavailabilities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Crée une indisponibilité
  Future<void> createUnavailability(DoctorUnavailability unavailability) async {
    try {
      await _service.createUnavailability(unavailability);
      // Recharger les indisponibilités
      await load(unavailability.medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Met à jour une indisponibilité
  Future<void> updateUnavailability(
    String unavailabilityId,
    DoctorUnavailability unavailability,
  ) async {
    try {
      await _service.updateUnavailability(unavailabilityId, unavailability);
      // Recharger les indisponibilités
      await load(unavailability.medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Supprime une indisponibilité
  Future<void> deleteUnavailability(String unavailabilityId, String medecinId) async {
    try {
      await _service.deleteUnavailability(unavailabilityId);
      // Recharger les indisponibilités
      await load(medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Rafraîchit les indisponibilités
  Future<void> refresh(String medecinId) async {
    await load(medecinId);
  }
}

final doctorUnavailabilityControllerProvider =
    StateNotifierProvider<DoctorUnavailabilityController, DoctorUnavailabilityState>(
  (ref) {
    final service = ref.watch(doctorUnavailabilityServiceProvider);
    return DoctorUnavailabilityController(service);
  },
);

