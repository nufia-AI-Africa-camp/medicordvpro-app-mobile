import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/rendez_vous.dart';
import '../../core/services/appointment_service.dart';

enum AppointmentFilter {
  tous,
  confirmes,
  termines,
  annules,
}

class AppointmentsListState {
  const AppointmentsListState({
    required this.allAppointments,
    this.isLoading = false,
    this.selectedFilter = AppointmentFilter.tous,
  });

  final List<RendezVous> allAppointments;
  final bool isLoading;
  final AppointmentFilter selectedFilter;

  List<RendezVous> get filteredAppointments {
    switch (selectedFilter) {
      case AppointmentFilter.confirmes:
        return allAppointments
            .where((rdv) => rdv.status == RendezVousStatus.confirme)
            .toList();
      case AppointmentFilter.termines:
        return allAppointments
            .where((rdv) => rdv.status == RendezVousStatus.termine)
            .toList();
      case AppointmentFilter.annules:
        return allAppointments
            .where((rdv) => rdv.status == RendezVousStatus.annule)
            .toList();
      case AppointmentFilter.tous:
        return allAppointments;
    }
  }

  int get countConfirmes {
    return allAppointments
        .where((rdv) => rdv.status == RendezVousStatus.confirme)
        .length;
  }

  int get countTermines {
    return allAppointments
        .where((rdv) => rdv.status == RendezVousStatus.termine)
        .length;
  }

  int get countAnnules {
    return allAppointments
        .where((rdv) => rdv.status == RendezVousStatus.annule)
        .length;
  }

  int get countTotal => allAppointments.length;

  AppointmentsListState copyWith({
    List<RendezVous>? allAppointments,
    bool? isLoading,
    AppointmentFilter? selectedFilter,
  }) {
    return AppointmentsListState(
      allAppointments: allAppointments ?? this.allAppointments,
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  static const empty = AppointmentsListState(allAppointments: []);
}

class AppointmentsListController
    extends StateNotifier<AppointmentsListState> {
  AppointmentsListController(this._service) : super(AppointmentsListState.empty);

  final AppointmentService _service;

  Future<void> load(String patientId) async {
    state = state.copyWith(isLoading: true);
    try {
      final appointments = await _service.getAllPatientAppointments(patientId);
      state = state.copyWith(
        allAppointments: appointments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void setFilter(AppointmentFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> refresh(String patientId) async {
    await load(patientId);
  }
}

final appointmentsListControllerProvider =
    StateNotifierProvider<AppointmentsListController, AppointmentsListState>(
        (ref) {
  final service = ref.watch(appointmentServiceProvider);
  return AppointmentsListController(service);
});

