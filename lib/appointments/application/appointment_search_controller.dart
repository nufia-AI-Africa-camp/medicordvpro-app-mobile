import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/medecin.dart';
import '../../core/services/appointment_service.dart';

class AppointmentSearchState {
  const AppointmentSearchState({
    required this.results,
    this.query = '',
    this.speciality,
    this.centre,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Medecin> results;
  final String query;
  final String? speciality;
  final String? centre;
  final bool isLoading;
  final String? errorMessage;

  AppointmentSearchState copyWith({
    List<Medecin>? results,
    String? query,
    String? speciality,
    String? centre,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppointmentSearchState(
      results: results ?? this.results,
      query: query ?? this.query,
      speciality: speciality ?? this.speciality,
      centre: centre ?? this.centre,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static const empty = AppointmentSearchState(results: []);
}

class AppointmentSearchController
    extends StateNotifier<AppointmentSearchState> {
  AppointmentSearchController(this._service)
      : super(AppointmentSearchState.empty);

  final AppointmentService _service;

  /// Met à jour la requête de recherche
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Met à jour le filtre de spécialité
  void updateSpeciality(String? speciality) {
    state = state.copyWith(speciality: speciality);
  }

  /// Met à jour le filtre de centre
  void updateCentre(String? centre) {
    state = state.copyWith(centre: centre);
  }

  /// Lance la recherche avec les filtres actuels
  Future<void> search() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final medecins = await _service.searchMedecins(
        name: state.query.isEmpty ? null : state.query,
        speciality: state.speciality,
        centre: state.centre,
      );
      state = state.copyWith(results: medecins, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().contains('Erreur')
            ? e.toString()
            : 'Erreur lors de la recherche: ${e.toString()}',
      );
    }
  }

  /// Réinitialise la recherche
  void reset() {
    state = AppointmentSearchState.empty;
  }
}

final appointmentSearchControllerProvider =
    StateNotifierProvider<AppointmentSearchController, AppointmentSearchState>(
        (ref) {
  final service = ref.watch(appointmentServiceProvider);
  return AppointmentSearchController(service);
});


