import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/rendez_vous.dart';
import '../../core/services/appointment_service.dart';

class HistoryState {
  const HistoryState({
    required this.pastRendezVous,
    this.isLoading = false,
  });

  final List<RendezVous> pastRendezVous;
  final bool isLoading;

  HistoryState copyWith({
    List<RendezVous>? pastRendezVous,
    bool? isLoading,
  }) {
    return HistoryState(
      pastRendezVous: pastRendezVous ?? this.pastRendezVous,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = HistoryState(pastRendezVous: []);
}

class HistoryController extends StateNotifier<HistoryState> {
  HistoryController(this._service) : super(HistoryState.empty);

  final AppointmentService _service;

  Future<void> load(String patientId) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.getPastRendezVous(patientId);
      state = state.copyWith(pastRendezVous: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>((ref) {
  final service = ref.watch(appointmentServiceProvider);
  return HistoryController(service);
});


