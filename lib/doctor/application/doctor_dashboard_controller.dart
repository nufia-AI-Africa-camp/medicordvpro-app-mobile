import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/medecin.dart';
import '../../core/domain/rendez_vous.dart';
import '../../core/services/doctor_appointment_service.dart';
import '../../core/services/doctor_profile_service.dart';
import '../../core/services/doctor_statistics_service.dart';

class DoctorDashboardState {
  const DoctorDashboardState({
    this.doctor,
    this.todayAppointments = const [],
    this.upcomingAppointments = const [],
    this.allAppointments = const [],
    this.statistics,
    this.isLoading = false,
    this.error,
  });

  final Medecin? doctor;
  final List<RendezVous> todayAppointments;
  final List<RendezVous> upcomingAppointments;
  final List<RendezVous> allAppointments;
  final DoctorStatistics? statistics;
  final bool isLoading;
  final String? error;

  /// Nombre de rendez-vous aujourd'hui
  int get todayCount => todayAppointments.length;

  /// Nombre de rendez-vous confirmés à venir
  int get upcomingConfirmedCount {
    return upcomingAppointments
        .where((rdv) => rdv.status == RendezVousStatus.confirme)
        .length;
  }

  /// Nombre de rendez-vous complétés aujourd'hui
  int get todayCompletedCount {
    return todayAppointments
        .where((rdv) => rdv.status == RendezVousStatus.termine)
        .length;
  }

  /// Nombre de rendez-vous par statut
  int getCountByStatus(RendezVousStatus status) {
    return allAppointments
        .where((rdv) => rdv.status == status)
        .length;
  }

  DoctorDashboardState copyWith({
    Medecin? doctor,
    List<RendezVous>? todayAppointments,
    List<RendezVous>? upcomingAppointments,
    List<RendezVous>? allAppointments,
    DoctorStatistics? statistics,
    bool? isLoading,
    String? error,
  }) {
    return DoctorDashboardState(
      doctor: doctor ?? this.doctor,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      allAppointments: allAppointments ?? this.allAppointments,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const empty = DoctorDashboardState();
}

class DoctorDashboardController extends StateNotifier<DoctorDashboardState> {
  DoctorDashboardController(
    this._doctorProfileService,
    this._doctorAppointmentService,
    this._doctorStatisticsService,
  ) : super(DoctorDashboardState.empty);

  final DoctorProfileService _doctorProfileService;
  final DoctorAppointmentService _doctorAppointmentService;
  final DoctorStatisticsService _doctorStatisticsService;

  /// Charge toutes les données du dashboard
  Future<void> load(String medecinId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Charger le profil
      final doctor = await _doctorProfileService.getDoctorProfile(medecinId);

      // Charger les rendez-vous d'aujourd'hui
      final today = DateTime.now();
      final todayAppointments = await _doctorAppointmentService.getDaySchedule(
        medecinId,
        today,
      );

      // Charger les rendez-vous à venir
      final upcomingAppointments = await _doctorAppointmentService
          .getDoctorAppointments(
        medecinId,
        startDate: today,
        status: RendezVousStatus.confirme,
      );

      // Charger tous les rendez-vous
      final allAppointments = await _doctorAppointmentService
          .getDoctorAppointments(medecinId);

      // Charger les statistiques
      final statistics = await _doctorStatisticsService.getDoctorStatistics(
        medecinId,
      );

      state = state.copyWith(
        doctor: doctor,
        todayAppointments: todayAppointments,
        upcomingAppointments: upcomingAppointments,
        allAppointments: allAppointments,
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charge le profil du médecin connecté
  Future<void> loadCurrentDoctor() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doctor = await _doctorProfileService.getCurrentDoctorProfile();
      if (doctor != null) {
        await load(doctor.id);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Aucun profil médecin trouvé',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rafraîchit les données
  Future<void> refresh(String medecinId) async {
    await load(medecinId);
  }
}

final doctorDashboardControllerProvider =
    StateNotifierProvider<DoctorDashboardController, DoctorDashboardState>(
  (ref) {
    final doctorProfileService = ref.watch(doctorProfileServiceProvider);
    final doctorAppointmentService = ref.watch(doctorAppointmentServiceProvider);
    final doctorStatisticsService = ref.watch(doctorStatisticsServiceProvider);
    return DoctorDashboardController(
      doctorProfileService,
      doctorAppointmentService,
      doctorStatisticsService,
    );
  },
);

