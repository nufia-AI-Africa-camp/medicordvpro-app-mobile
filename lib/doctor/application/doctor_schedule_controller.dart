import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/doctor_schedule_service.dart';

class DoctorScheduleState {
  const DoctorScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DoctorSchedule> schedules;
  final bool isLoading;
  final String? error;

  /// Horaires groupés par jour
  Map<String, List<DoctorSchedule>> get schedulesByDay {
    final Map<String, List<DoctorSchedule>> grouped = {};
    for (final schedule in schedules) {
      if (!grouped.containsKey(schedule.jour)) {
        grouped[schedule.jour] = [];
      }
      grouped[schedule.jour]!.add(schedule);
    }
    return grouped;
  }

  DoctorScheduleState copyWith({
    List<DoctorSchedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return DoctorScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const empty = DoctorScheduleState();
}

class DoctorScheduleController extends StateNotifier<DoctorScheduleState> {
  DoctorScheduleController(this._doctorScheduleService)
      : super(DoctorScheduleState.empty);

  final DoctorScheduleService _doctorScheduleService;

  /// Charge les horaires d'un médecin
  Future<void> load(String medecinId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final schedules = await _doctorScheduleService.getDoctorSchedules(medecinId);
      state = state.copyWith(
        schedules: schedules,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Crée un nouvel horaire
  Future<void> createSchedule(DoctorSchedule schedule) async {
    try {
      await _doctorScheduleService.createSchedule(schedule);
      // Recharger les horaires
      await load(schedule.medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Met à jour un horaire
  Future<void> updateSchedule(String scheduleId, DoctorSchedule schedule) async {
    try {
      await _doctorScheduleService.updateSchedule(scheduleId, schedule);
      // Recharger les horaires
      await load(schedule.medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Supprime un horaire
  Future<void> deleteSchedule(String scheduleId, String medecinId) async {
    try {
      await _doctorScheduleService.deleteSchedule(scheduleId);
      // Recharger les horaires
      await load(medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Active/désactive un horaire
  Future<void> toggleAvailability(String scheduleId, bool isAvailable, String medecinId) async {
    try {
      await _doctorScheduleService.toggleScheduleAvailability(scheduleId, isAvailable);
      // Recharger les horaires
      await load(medecinId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Rafraîchit les horaires
  Future<void> refresh(String medecinId) async {
    await load(medecinId);
  }
}

final doctorScheduleControllerProvider =
    StateNotifierProvider<DoctorScheduleController, DoctorScheduleState>(
  (ref) {
    final doctorScheduleService = ref.watch(doctorScheduleServiceProvider);
    return DoctorScheduleController(doctorScheduleService);
  },
);

