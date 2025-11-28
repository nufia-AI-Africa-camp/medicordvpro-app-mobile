import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/consultation_history.dart';
import '../../core/services/consultation_history_service.dart';

class HistoryState {
  const HistoryState({
    required this.consultationHistories,
    this.isLoading = false,
  });

  final List<ConsultationHistory> consultationHistories;
  final bool isLoading;

  /// Nombre total de consultations
  int get totalConsultations => consultationHistories.length;

  /// Nombre total de documents joints
  int get totalDocuments {
    return consultationHistories
        .where((h) => h.documentsJoints != null && h.documentsJoints!.isNotEmpty)
        .fold<int>(0, (sum, h) => sum + (h.documentsJoints?.length ?? 0));
  }

  HistoryState copyWith({
    List<ConsultationHistory>? consultationHistories,
    bool? isLoading,
  }) {
    return HistoryState(
      consultationHistories: consultationHistories ?? this.consultationHistories,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = HistoryState(consultationHistories: []);
}

class HistoryController extends StateNotifier<HistoryState> {
  HistoryController(this._service) : super(HistoryState.empty);

  final ConsultationHistoryService _service;

  Future<void> load(String patientId) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.getPatientMedicalHistory(patientId);
      state = state.copyWith(
        consultationHistories: items,
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

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>((ref) {
  final service = ref.watch(consultationHistoryServiceProvider);
  return HistoryController(service);
});
