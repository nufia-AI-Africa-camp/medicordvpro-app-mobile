import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../application/doctor_dashboard_controller.dart';
import '../application/doctor_appointments_controller.dart';
import '../application/doctor_schedule_controller.dart';
import '../application/doctor_unavailability_controller.dart';
import '../application/doctor_reminder_settings_controller.dart';
import '../../core/domain/rendez_vous.dart';
import '../../core/services/doctor_schedule_service.dart';
import '../../core/services/doctor_unavailability_service.dart';
import '../../core/services/doctor_appointment_service.dart';
import 'doctor_profile_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  static const routeName = 'doctor-dashboard';
  static const routePath = '/doctor/dashboard';

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);

    final tabs = const [
      _DoctorAgendaTab(),
      _DoctorAvailabilityTab(),
      _DoctorAppointmentsTab(),
      _DoctorStatsTab(),
      _DoctorAutoRemindersTab(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: const Text(
          'Espace médecin',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push(DoctorProfileScreen.routePath);
            },
            tooltip: 'Mon profil',
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Mon agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Disponibilités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Rendez-vous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_outlined),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_outlined),
            label: 'Rappels auto',
          ),
        ],
      ),
    );
  }
}

class _DoctorAgendaTab extends ConsumerStatefulWidget {
  const _DoctorAgendaTab();

  @override
  ConsumerState<_DoctorAgendaTab> createState() => _DoctorAgendaTabState();
}

class _DoctorAgendaTabState extends ConsumerState<_DoctorAgendaTab> {
  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = false;

  @override
  void initState() {
    super.initState();
    // Charger les données au montage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(doctorDashboardControllerProvider.notifier);
      controller.loadCurrentDoctor();
    });
  }

  Future<void> _loadAppointmentsForDate(DateTime date) async {
    final state = ref.read(doctorDashboardControllerProvider);
    if (state.doctor != null) {
      final controller = ref.read(doctorDashboardControllerProvider.notifier);
      // Recharger toutes les données pour avoir les rendez-vous à jour
      await controller.refresh(state.doctor!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4C1D95);
    const secondaryPurple = Color(0xFF7C3AED);
    const backgroundColor = Color(0xFFF5F7FF);

    final state = ref.watch(doctorDashboardControllerProvider);
    final controller = ref.read(doctorDashboardControllerProvider.notifier);

    if (state.isLoading && state.doctor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final doctor = state.doctor;
    final doctorName = doctor != null
        ? 'Dr. ${doctor.firstName} ${doctor.lastName}'
        : 'Dr. ...';

    // Filtrer les rendez-vous pour la date sélectionnée
    final selectedDateAppointments = state.allAppointments.where((rdv) {
      final rdvDate = DateTime(rdv.dateTime.year, rdv.dateTime.month, rdv.dateTime.day);
      final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      return rdvDate.isAtSameMomentAs(selectedDateOnly);
    }).toList();

    // Vérifier si la date sélectionnée est aujourd'hui
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          if (doctor != null) {
            await controller.refresh(doctor.id);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Bandeau violet avec stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPurple,
                    secondaryPurple,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour $doctorName 👨‍⚕️',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bienvenue sur votre espace médecin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _AgendaStatCard(
                          label: isToday ? "Aujourd'hui" : DateFormat('d MMM', 'fr_FR').format(_selectedDate),
                          value: selectedDateAppointments.length.toString(),
                          subtitle: 'rendez-vous',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AgendaStatCard(
                          label: 'À venir',
                          value: state.upcomingConfirmedCount.toString(),
                          subtitle: 'confirmés',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AgendaStatCard(
                          label: 'Complétés',
                          value: state.todayCompletedCount.toString(),
                          subtitle: "aujourd'hui",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ligne date + filtres jour / semaine
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                          _loadAppointmentsForDate(_selectedDate);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            locale: const Locale('fr', 'FR'),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                            _loadAppointmentsForDate(_selectedDate);
                          }
                        },
                        child: Text(
                          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                        style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                          _loadAppointmentsForDate(_selectedDate);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                      "Aujourd'hui",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                      _loadAppointmentsForDate(_selectedDate);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "Aujourd'hui",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isWeekView = false;
                    });
                  },
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _isWeekView ? Colors.white : const Color(0xFF1D5BFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                    child: Text(
                    'Jour',
                    style: TextStyle(
                      fontSize: 12,
                        color: _isWeekView ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isWeekView = true;
                    });
                    // TODO: Charger les rendez-vous de la semaine
                  },
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _isWeekView ? const Color(0xFF1D5BFF) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                    child: Text(
                    'Semaine',
                    style: TextStyle(
                      fontSize: 12,
                        color: _isWeekView ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Planning de la journée
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: selectedDateAppointments.isEmpty
                  ? Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _isWeekView ? 'Planning de la semaine' : 'Planning de la journée',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Icon(
                          Icons.event_busy_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucun rendez-vous',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vous n\'avez pas de rendez-vous ${isToday ? "aujourd'hui" : "pour cette journée"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWeekView ? 'Planning de la semaine' : 'Planning de la journée',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...selectedDateAppointments.map((rdv) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _AppointmentTimeSlot(rdv: rdv),
                            )),
                      ],
                    ),
            ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rendez-vous par statut
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rendez-vous par statut',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StatusLine(
                        color: const Color(0xFF22C55E),
                        label: 'Confirmés',
                        value: state.getCountByStatus(RendezVousStatus.confirme).toString(),
                      ),
                      _StatusLine(
                        color: const Color(0xFF3B82F6),
                        label: 'Terminés',
                        value: state.getCountByStatus(RendezVousStatus.termine).toString(),
                      ),
                      _StatusLine(
                        color: const Color(0xFFEAB308),
                        label: 'En attente',
                        value: state.getCountByStatus(RendezVousStatus.enAttente).toString(),
                      ),
                      _StatusLine(
                        color: const Color(0xFFEF4444),
                        label: 'Annulés',
                        value: state.getCountByStatus(RendezVousStatus.annule).toString(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Prochains rendez-vous
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prochains rendez-vous',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.upcomingAppointments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Aucun rendez-vous à venir',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                      ),
                          ),
                        )
                      else
                        ...state.upcomingAppointments.take(2).map((rdv) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _UpcomingAppointmentItem(
                                patientName: rdv.patient != null
                                    ? '${rdv.patient!.firstName} ${rdv.patient!.lastName}'
                                    : 'Patient',
                                dateLabel: DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(rdv.dateTime),
                      ),
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _DoctorAvailabilityTab extends ConsumerStatefulWidget {
  const _DoctorAvailabilityTab();

  @override
  ConsumerState<_DoctorAvailabilityTab> createState() => _DoctorAvailabilityTabState();
}

class _DoctorAvailabilityTabState extends ConsumerState<_DoctorAvailabilityTab> {
  int _selectedTab = 0; // 0: Horaires, 1: Pauses, 2: Congés
  
  // Mapping des noms de jours français vers les noms de la DB
  static const Map<String, String> _dayNameMapping = {
    'Lundi': 'lundi',
    'Mardi': 'mardi',
    'Mercredi': 'mercredi',
    'Jeudi': 'jeudi',
    'Vendredi': 'vendredi',
    'Samedi': 'samedi',
    'Dimanche': 'dimanche',
  };
  
  static const List<String> _daysOfWeek = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    // Charger les horaires au montage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  Future<void> _loadSchedules() async {
    final dashboardState = ref.read(doctorDashboardControllerProvider);
    if (dashboardState.doctor != null) {
      final controller = ref.read(doctorScheduleControllerProvider.notifier);
      await controller.load(dashboardState.doctor!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4C1D95);
    const secondaryPurple = Color(0xFF7C3AED);
    const backgroundColor = Color(0xFFF5F7FF);

    final scheduleState = ref.watch(doctorScheduleControllerProvider);
    final dashboardState = ref.watch(doctorDashboardControllerProvider);

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: _loadSchedules,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // En-tête gestion disponibilités
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPurple,
                    secondaryPurple,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestion de mes disponibilités',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Configurez votre agenda, vos pauses et vos congés',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: _AvailabilityTabChip(
                            label: 'Horaires',
                            isSelected: _selectedTab == 0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: _AvailabilityTabChip(
                            label: 'Pauses',
                            isSelected: _selectedTab == 1,
                            badgeColor: Colors.orangeAccent,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedTab = 2),
                          child: _AvailabilityTabChip(
                            label: 'Congés',
                            isSelected: _selectedTab == 2,
                            badgeColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_selectedTab == 0) ...[
              // Jours de la semaine pour les horaires
              if (scheduleState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ..._daysOfWeek.map(
                  (dayLabel) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AvailabilityDayCard(
                      dayLabel: dayLabel,
                      dayKey: _dayNameMapping[dayLabel]!,
                      medecinId: dashboardState.doctor?.id ?? '',
                      schedules: scheduleState.schedulesByDay[_dayNameMapping[dayLabel]] ?? [],
                      onScheduleChanged: () {
                        // Recharger les horaires après modification
                        _loadSchedules();
                      },
                    ),
                  ),
                ),
            ] else if (_selectedTab == 1) ...[
              // Onglet Pauses
              _PausesTab(medecinId: dashboardState.doctor?.id ?? ''),
            ] else if (_selectedTab == 2) ...[
              // Onglet Congés
              _CongesTab(medecinId: dashboardState.doctor?.id ?? ''),
            ],

            const SizedBox(height: 12),

            // Bloc informations importantes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFCD34D),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline,
                      color: Color(0xFF92400E),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations importantes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Les horaires définis seront visibles par tous les patients. '
                          'Les pauses bloquent automatiquement les créneaux concernés. '
                          'Les congés désactivent toute prise de rendez-vous sur les périodes choisies.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _DoctorAppointmentsTab extends ConsumerStatefulWidget {
  const _DoctorAppointmentsTab();

  @override
  ConsumerState<_DoctorAppointmentsTab> createState() => _DoctorAppointmentsTabState();
}

class _DoctorAppointmentsTabState extends ConsumerState<_DoctorAppointmentsTab> {
  int _selectedStatusIndex = 0;

  final List<String> _statuses = const [
    'Tous',
    'Confirmés',
    'Terminés',
    'Annulés',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardState = ref.read(doctorDashboardControllerProvider);
      if (dashboardState.doctor != null) {
        final controller = ref.read(doctorAppointmentsControllerProvider.notifier);
        controller.load(dashboardState.doctor!.id);
      }
    });
  }

  String _getStatusSubtitle(DoctorAppointmentsState state) {
    final count = state.filteredAppointments.length;
    switch (_selectedStatusIndex) {
      case 1:
        return '$count rendez-vous confirmés';
      case 2:
        return '$count rendez-vous terminés';
      case 3:
        return '$count rendez-vous annulés';
      default:
        return '$count rendez-vous trouvés';
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryBlue = Color(0xFF1D5BFF);

    final appointmentsState = ref.watch(doctorAppointmentsControllerProvider);
    final dashboardState = ref.watch(doctorDashboardControllerProvider);

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          if (dashboardState.doctor != null) {
            final controller = ref.read(doctorAppointmentsControllerProvider.notifier);
            await controller.refresh(dashboardState.doctor!.id);
          }
        },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes rendez-vous',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      _getStatusSubtitle(appointmentsState),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () {
                      // TODO: démarrer la création d'un nouveau rendez-vous
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Nouveau rendez-vous',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Carte filtres
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Filtrer par statut',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_statuses.length, (index) {
                      final selected = index == _selectedStatusIndex;

                      final Color bgColor;
                      final Color textColor;

                      if (index == 3 && selected) {
                        bgColor = const Color(0xFFEF4444);
                        textColor = Colors.white;
                      } else if (selected) {
                        bgColor = primaryBlue;
                        textColor = Colors.white;
                      } else {
                        bgColor = const Color(0xFFF4F4F6);
                        textColor = Colors.black87;
                      }

                      final String count;
                      switch (index) {
                        case 1:
                          count = appointmentsState.getCountByStatus(RendezVousStatus.confirme).toString();
                          break;
                        case 2:
                          count = appointmentsState.getCountByStatus(RendezVousStatus.termine).toString();
                          break;
                        case 3:
                          count = appointmentsState.getCountByStatus(RendezVousStatus.annule).toString();
                          break;
                        default:
                          count = appointmentsState.appointments.length.toString();
                      }

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _statuses.length - 1 ? 0 : 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatusIndex = index;
                            });
                            final controller = ref.read(doctorAppointmentsControllerProvider.notifier);
                            RendezVousStatus? status;
                            switch (index) {
                              case 1:
                                status = RendezVousStatus.confirme;
                                break;
                              case 2:
                                status = RendezVousStatus.termine;
                                break;
                              case 3:
                                status = RendezVousStatus.annule;
                                break;
                              default:
                                status = null;
                            }
                            controller.filterByStatus(status);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_statuses[index]} ($count)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (appointmentsState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (appointmentsState.filteredAppointments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: const [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucun rendez-vous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vous n\'avez pas de rendez-vous pour ce filtre',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...appointmentsState.filteredAppointments.map((rdv) {
              final patientName = rdv.patient != null
                  ? '${rdv.patient!.firstName} ${rdv.patient!.lastName}'
                  : 'Patient';
              final phone = rdv.patient?.phoneNumber ?? 'Non renseigné';
              final dateLabel = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(rdv.dateTime);
              final timeLabel = DateFormat('HH:mm', 'fr_FR').format(rdv.dateTime);
              
              Color statusColor;
              String statusLabel;
              switch (rdv.status) {
                case RendezVousStatus.confirme:
                  statusColor = const Color(0xFF16A34A);
                  statusLabel = 'Confirmé';
                  break;
                case RendezVousStatus.termine:
                  statusColor = const Color(0xFF3B82F6);
                  statusLabel = 'Terminé';
                  break;
                case RendezVousStatus.enAttente:
                  statusColor = const Color(0xFFEAB308);
                  statusLabel = 'En attente';
                  break;
                case RendezVousStatus.annule:
                  statusColor = const Color(0xFFEF4444);
                  statusLabel = 'Annulé';
                  break;
                case RendezVousStatus.absent:
                  statusColor = const Color(0xFF6B7280);
                  statusLabel = 'Absent';
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DoctorAppointmentCard(
                  appointment: rdv,
                  doctorName: dashboardState.doctor != null
                      ? 'Dr. ${dashboardState.doctor!.firstName} ${dashboardState.doctor!.lastName}'
                      : 'Dr.',
                  specialty: dashboardState.doctor?.speciality ?? 'Médecin',
                  dateLabel: dateLabel,
                  timeLabel: timeLabel,
                  patientName: patientName,
                  phone: phone,
                  statusLabel: statusLabel,
                  statusColor: statusColor,
                  motif: rdv.motifConsultation ?? 'Aucun motif',
                  notes: rdv.notesPatient ?? '',
                ),
              );
            }),
        ],
        ),
      ),
    );
  }
}

class _DoctorAppointmentCard extends ConsumerWidget {
  const _DoctorAppointmentCard({
    required this.appointment,
    required this.doctorName,
    required this.specialty,
    required this.dateLabel,
    required this.timeLabel,
    required this.patientName,
    required this.phone,
    required this.statusLabel,
    required this.statusColor,
    required this.motif,
    required this.notes,
  });

  final RendezVous appointment;
  final String doctorName;
  final String specialty;
  final String dateLabel;
  final String timeLabel;
  final String patientName;
  final String phone;
  final String statusLabel;
  final Color statusColor;
  final String motif;
  final String notes;

  Future<void> _showEditAppointmentDialog(
    BuildContext context,
    WidgetRef ref,
    RendezVous appointment,
    String medecinId,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditAppointmentDialog(appointment: appointment),
    );

    if (result != null) {
      final appointmentsController = ref.read(doctorAppointmentsControllerProvider.notifier);
      final appointmentService = ref.read(doctorAppointmentServiceProvider);

      try {
        // Mettre à jour la date/heure et la durée si modifiées
        if (result.containsKey('dateTime') || result.containsKey('duree')) {
          await appointmentService.updateAppointment(
            appointmentId: appointment.id,
            dateTime: result['dateTime'] as DateTime?,
            duree: result['duree'] as int?,
          );
        }

        // Mettre à jour les notes médecin si modifiées
        if (result.containsKey('notesMedecin')) {
          await appointmentService.updateAppointmentNotes(
            appointment.id,
            result['notesMedecin'] as String? ?? '',
          );
        }

        // Rafraîchir la liste
        if (medecinId.isNotEmpty) {
          await appointmentsController.refresh(medecinId);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rendez-vous modifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la modification: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryBlue = Color(0xFF1D5BFF);
    final appointmentsController = ref.read(doctorAppointmentsControllerProvider.notifier);
    final dashboardState = ref.read(doctorDashboardControllerProvider);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE4ECFF),
                  child: Icon(
                    Icons.person_outline,
                    color: primaryBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.schedule_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Divider(height: 1),

            const SizedBox(height: 10),

            Text(
              'Motif',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              motif,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notes,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (statusLabel != 'Terminé' && statusLabel != 'Annulé')
                OutlinedButton.icon(
                    onPressed: () async {
                      if (statusLabel == 'En attente') {
                        // Confirmer directement si en attente
                        await appointmentsController.confirmAppointment(appointment.id);
                        if (dashboardState.doctor != null) {
                          await appointmentsController.refresh(dashboardState.doctor!.id);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rendez-vous confirmé'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // Ouvrir le dialogue de modification
                        await _showEditAppointmentDialog(context, ref, appointment, dashboardState.doctor?.id ?? '');
                      }
                    },
                    icon: Icon(
                      statusLabel == 'En attente' ? Icons.check_circle_outline : Icons.edit_outlined,
                    size: 14,
                  ),
                    label: Text(
                      statusLabel == 'En attente' ? 'Confirmer' : 'Modifier',
                      style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                if (statusLabel != 'Terminé' && statusLabel != 'Annulé') ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Annuler le rendez-vous'),
                          content: const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Non'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Oui, annuler'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await appointmentsController.cancelAppointment(appointment.id);
                        if (dashboardState.doctor != null) {
                          await appointmentsController.refresh(dashboardState.doctor!.id);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rendez-vous annulé'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 14,
                  ),
                  label: const Text(
                    'Annuler',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(
                      color: Color(0xFFEF4444),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
                if (statusLabel == 'Confirmé') ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await appointmentsController.completeAppointment(appointment.id);
                      if (dashboardState.doctor != null) {
                        await appointmentsController.refresh(dashboardState.doctor!.id);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rendez-vous marqué comme terminé'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.check_circle,
                      size: 14,
                    ),
                    label: const Text(
                      'Terminer',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(
                        color: Color(0xFF3B82F6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorStatsTab extends ConsumerStatefulWidget {
  const _DoctorStatsTab();

  @override
  ConsumerState<_DoctorStatsTab> createState() => _DoctorStatsTabState();
}

class _DoctorStatsTabState extends ConsumerState<_DoctorStatsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardState = ref.read(doctorDashboardControllerProvider);
      if (dashboardState.doctor != null) {
        // Les statistiques sont déjà chargées dans le dashboard controller
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryGreen = Color(0xFF16A34A);
    const secondaryGreen = Color(0xFF22C55E);

    final dashboardState = ref.watch(doctorDashboardControllerProvider);
    final statistics = dashboardState.statistics;

    if (dashboardState.isLoading && statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          if (dashboardState.doctor != null) {
            final controller = ref.read(doctorDashboardControllerProvider.notifier);
            await controller.refresh(dashboardState.doctor!.id);
          }
        },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête Statistiques & Analytics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryGreen,
                  secondaryGreen,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
              child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Statistiques & Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                  const Text(
                    "Vue d'ensemble de votre activité médicale",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cartes KPI principales
            if (statistics != null) ...[
          Row(
                children: [
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.event_note_outlined,
                  label: 'Total rendez-vous',
                      value: statistics.totalAppointments.toString(),
                  trendIcon: Icons.trending_up,
                ),
              ),
                  const SizedBox(width: 8),
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.check_circle_outline,
                  label: 'Consultations terminées',
                      value: statistics.completedAppointments.toString(),
                      suffix: '${statistics.completionRate.toStringAsFixed(0)} %',
                  trendIcon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
                children: [
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.people_outline,
                  label: 'Patients uniques',
                      value: statistics.uniquePatients.toString(),
                  trendIcon: Icons.trending_up,
                ),
              ),
                  const SizedBox(width: 8),
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.attach_money_outlined,
                  label: 'Revenu estimé',
                      value: '${statistics.totalRevenue.toStringAsFixed(0)} €',
                  trendIcon: Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

              // Semaine / mois / taux d'annulation
          Row(
                children: [
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Cette semaine',
                      value: statistics.thisWeekAppointments.toString(),
                  subtitle: 'rendez-vous',
                ),
              ),
                  const SizedBox(width: 8),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.date_range_outlined,
                  label: 'Ce mois',
                      value: statistics.thisMonthAppointments.toString(),
                  subtitle: 'rendez-vous',
                ),
              ),
                  const SizedBox(width: 8),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.percent,
                      label: "Taux d'annulation",
                      value: '${statistics.cancellationRate.toStringAsFixed(0)}%',
                  subtitle: 'annulés',
                  valueColor: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Répartition par statut
          _StatSectionCard(
            title: 'Répartition par statut',
            child: Column(
                  children: [
                _ProgressStatLine(
                  label: 'Confirmés',
                      value: statistics.confirmedAppointments.toString(),
                      progress: statistics.totalAppointments > 0
                          ? statistics.confirmedAppointments / statistics.totalAppointments
                          : 0,
                      color: const Color(0xFF22C55E),
                ),
                _ProgressStatLine(
                  label: 'Terminés',
                      value: statistics.completedAppointments.toString(),
                      progress: statistics.totalAppointments > 0
                          ? statistics.completedAppointments / statistics.totalAppointments
                          : 0,
                      color: const Color(0xFF3B82F6),
                ),
                _ProgressStatLine(
                  label: 'En attente',
                      value: (statistics.totalAppointments - statistics.confirmedAppointments - statistics.completedAppointments - statistics.cancelledAppointments).toString(),
                      progress: statistics.totalAppointments > 0
                          ? (statistics.totalAppointments - statistics.confirmedAppointments - statistics.completedAppointments - statistics.cancelledAppointments) / statistics.totalAppointments
                          : 0,
                      color: const Color(0xFFEAB308),
                ),
                _ProgressStatLine(
                  label: 'Annulés',
                      value: statistics.cancelledAppointments.toString(),
                      progress: statistics.totalAppointments > 0
                          ? statistics.cancelledAppointments / statistics.totalAppointments
                          : 0,
                      color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Expanded(
                child: _StatSectionCard(
                  title: 'Indicateurs de performance',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KpiInlineLine(
                        label: 'Taux de complétion',
                            value: '${statistics.completionRate.toStringAsFixed(0)} %',
                        icon: Icons.check_circle_outline,
                            color: const Color(0xFF16A34A),
                      ),
                          const SizedBox(height: 8),
                      _KpiInlineLine(
                        label: 'Revenu moyen/patient',
                            value: '${statistics.averageRevenuePerPatient.toStringAsFixed(0)} €',
                        icon: Icons.euro_outlined,
                            color: const Color(0xFFF97316),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Aucune statistique disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatKpiCard extends StatelessWidget {
  const _StatKpiCard({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
    this.trendIcon,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? suffix;
  final IconData? trendIcon;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const Spacer(),
                if (trendIcon != null)
                  Icon(
                    trendIcon,
                    size: 16,
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  const _SmallMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor ?? Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatSectionCard extends StatelessWidget {
  const _StatSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProgressStatLine extends StatelessWidget {
  const _ProgressStatLine({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.small = false,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: small ? 11 : 12,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: small ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: small ? 4 : 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiInlineLine extends StatelessWidget {
  const _KpiInlineLine({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoctorAutoRemindersTab extends ConsumerStatefulWidget {
  const _DoctorAutoRemindersTab();

  @override
  ConsumerState<_DoctorAutoRemindersTab> createState() => _DoctorAutoRemindersTabState();
}

class _DoctorAutoRemindersTabState extends ConsumerState<_DoctorAutoRemindersTab> {
  double _reminderHoursSlider = 24.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardState = ref.read(doctorDashboardControllerProvider);
      if (dashboardState.doctor != null) {
        ref.read(doctorReminderSettingsControllerProvider.notifier)
            .loadSettings(dashboardState.doctor!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryRed = Color(0xFFDC2626);
    const secondaryOrange = Color(0xFFF97316);

    final reminderSettingsState = ref.watch(doctorReminderSettingsControllerProvider);
    final dashboardState = ref.watch(doctorDashboardControllerProvider);
    final settings = reminderSettingsState.settings;
    final doctor = dashboardState.doctor;

    // Calculer les statistiques de rappels
    final confirmedAppointments = dashboardState.upcomingAppointments
        .where((rdv) => rdv.status == RendezVousStatus.confirme)
        .toList();
    
    final now = DateTime.now();
    int remindersSent = 0;
    int remindersPending = 0;
    
    for (final rdv in confirmedAppointments) {
      if (settings != null && settings.enabled) {
        final reminderTime = rdv.dateTime.subtract(Duration(hours: settings.reminderHoursBefore));
        if (now.isAfter(reminderTime)) {
          remindersSent++;
        } else {
          remindersPending++;
        }
      }
    }

    // Initialiser le slider avec les settings
    if (settings != null && _reminderHoursSlider != settings.reminderHoursBefore.toDouble()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _reminderHoursSlider = settings.reminderHoursBefore.toDouble();
        });
      });
    }

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          if (doctor != null) {
            await ref.read(doctorReminderSettingsControllerProvider.notifier)
                .loadSettings(doctor.id);
            await ref.read(doctorDashboardControllerProvider.notifier)
                .refresh(doctor.id);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // En-tête rappels auto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryRed,
                    secondaryOrange,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestion des Rappels Automatiques',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Configurez les notifications automatiques envoyées à vos patients',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Paramètres des rappels
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paramètres des rappels',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Activer les rappels automatiques
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                          color: Color(0xFF1D5BFF),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Activer les rappels automatiques',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Envoyer automatiquement des rappels aux patients avant leurs rendez-vous',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settings?.enabled ?? true,
                          onChanged: doctor != null
                              ? (value) async {
                                  await ref
                                      .read(doctorReminderSettingsControllerProvider.notifier)
                                      .updateProperty(
                                        medecinId: doctor.id,
                                        enabled: value,
                                      );
                                }
                              : null,
                          activeColor: const Color(0xFF22C55E),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Divider(height: 1),

                    const SizedBox(height: 12),

                    const Text(
                      'Canaux de communication',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // SMS
                    _ReminderChannelRow(
                      icon: Icons.sms_outlined,
                      label: 'Rappel par SMS',
                      description: 'Envoyer un SMS au patient',
                      active: settings?.smsEnabled ?? true,
                      onChanged: doctor != null
                          ? (value) async {
                              await ref
                                  .read(doctorReminderSettingsControllerProvider.notifier)
                                  .updateProperty(
                                    medecinId: doctor.id,
                                    smsEnabled: value,
                                  );
                            }
                          : null,
                    ),
                    const SizedBox(height: 6),
                    // Email
                    _ReminderChannelRow(
                      icon: Icons.email_outlined,
                      label: 'Rappel par Email',
                      description: 'Envoyer un email au patient',
                      active: settings?.emailEnabled ?? true,
                      onChanged: doctor != null
                          ? (value) async {
                              await ref
                                  .read(doctorReminderSettingsControllerProvider.notifier)
                                  .updateProperty(
                                    medecinId: doctor.id,
                                    emailEnabled: value,
                                  );
                            }
                          : null,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Délai de rappel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Envoyer le rappel',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_reminderHoursSlider.toInt()}h avant',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _reminderHoursSlider,
                        onChanged: (value) {
                          setState(() {
                            _reminderHoursSlider = value;
                          });
                        },
                        min: 1,
                        max: 168, // 7 jours
                        divisions: 167,
                        label: '${_reminderHoursSlider.toInt()} heures',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Les patients recevront un rappel ${_reminderHoursSlider.toInt()} heures avant leur rendez-vous.',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: (reminderSettingsState.status == ReminderSettingsStatus.saving ||
                        doctor == null)
                    ? null
                    : () async {
                        if (settings != null) {
                          final updated = settings.copyWith(
                            reminderHoursBefore: _reminderHoursSlider.toInt(),
                          );
                          await ref
                              .read(doctorReminderSettingsControllerProvider.notifier)
                              .updateSettings(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Paramètres enregistrés avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                icon: reminderSettingsState.status == ReminderSettingsStatus.saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text(
                  'Enregistrer les paramètres',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stat petits blocs
            Row(
              children: [
                Expanded(
                  child: _SmallMetricCard(
                    icon: Icons.send_outlined,
                    label: 'Rappels envoyés',
                    value: remindersSent.toString(),
                    subtitle: 'Notifications déjà envoyées',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallMetricCard(
                    icon: Icons.schedule_send_outlined,
                    label: 'En attente',
                    value: remindersPending.toString(),
                    subtitle: 'À envoyer prochainement',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallMetricCard(
                    icon: Icons.check_circle_outline,
                    label: 'Total à venir',
                    value: confirmedAppointments.length.toString(),
                    subtitle: 'Rendez-vous confirmés',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Prochains rappels programmés
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prochains rappels programmés',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (confirmedAppointments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Aucun rendez-vous confirmé à venir',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ...confirmedAppointments.take(5).map((rdv) {
                        final patientName = rdv.patient != null
                            ? '${rdv.patient!.firstName} ${rdv.patient!.lastName}'
                            : 'Patient';
                        final dateLabel = DateFormat('EEEE d MMMM à HH:mm', 'fr_FR')
                            .format(rdv.dateTime);
                        final reminderTime = rdv.dateTime.subtract(
                          Duration(hours: settings?.reminderHoursBefore ?? 24),
                        );
                        final isReminderSent = now.isAfter(reminderTime);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isReminderSent
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isReminderSent
                                      ? Icons.check_circle_outline
                                      : Icons.notifications_active_outlined,
                                  size: 18,
                                  color: isReminderSent
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patientName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dateLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isReminderSent)
                                  Text(
                                    'Dans ${reminderTime.difference(now).inHours}h',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Comment ça fonctionne
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 18,
                        color: Color(0xFF1D5BFF),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Comment ça fonctionne ?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les rappels automatiques sont envoyés aux patients selon vos paramètres. '
                    'Chaque patient recevra :',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Une notification 24h avant leur rendez-vous\n'
                    '• Les informations complètes (date, heure, lieu)\n'
                    '• Un lien pour modifier ou annuler si nécessaire',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ReminderChannelRow extends StatelessWidget {
  const _ReminderChannelRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.active,
    this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool active;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF22C55E) : Colors.grey;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (onChanged != null)
          Switch(
            value: active,
            onChanged: onChanged,
            activeColor: const Color(0xFF22C55E),
          ),
      ],
    );
  }
}


class _AvailabilityTabChip extends StatelessWidget {
  const _AvailabilityTabChip({
    required this.label,
    required this.isSelected,
    this.badgeColor,
  });

  final String label;
  final bool isSelected;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D5BFF) : baseColor,
              ),
            ),
            if (badgeColor != null) ...[
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailabilityDayCard extends ConsumerStatefulWidget {
  const _AvailabilityDayCard({
    required this.dayLabel,
    required this.dayKey,
    required this.medecinId,
    required this.schedules,
    required this.onScheduleChanged,
  });

  final String dayLabel;
  final String dayKey; // Clé pour la DB (lundi, mardi, etc.)
  final String medecinId;
  final List<DoctorSchedule> schedules;
  final VoidCallback onScheduleChanged;

  @override
  ConsumerState<_AvailabilityDayCard> createState() => _AvailabilityDayCardState();
}

class _AvailabilityDayCardState extends ConsumerState<_AvailabilityDayCard> {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    // Le jour est activé s'il y a au moins un horaire
    _isEnabled = widget.schedules.isNotEmpty;
  }

  @override
  void didUpdateWidget(_AvailabilityDayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schedules != oldWidget.schedules) {
      _isEnabled = widget.schedules.isNotEmpty;
    }
  }

  Future<void> _toggleDay(bool enabled) async {
    if (!enabled && widget.schedules.isNotEmpty) {
      // Si on désactive, demander confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Désactiver ce jour ?'),
          content: const Text(
            'Tous les horaires de ce jour seront supprimés. Souhaitez-vous continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        return;
      }

      // Supprimer tous les horaires du jour
      final controller = ref.read(doctorScheduleControllerProvider.notifier);
      for (final schedule in widget.schedules) {
        await controller.deleteSchedule(schedule.id, widget.medecinId);
      }
    } else if (enabled && widget.schedules.isEmpty) {
      // Si on active et qu'il n'y a pas d'horaires, créer un horaire par défaut
      await _addDefaultSchedule();
    }

    setState(() {
      _isEnabled = enabled;
    });
    widget.onScheduleChanged();
  }

  Future<void> _addDefaultSchedule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ScheduleTimeDialog(
        existingSchedules: widget.schedules,
        dayKey: widget.dayKey,
      ),
    );

    if (result != null) {
      final controller = ref.read(doctorScheduleControllerProvider.notifier);
      final defaultSchedule = DoctorSchedule(
        id: '', // Sera généré par le service
        medecinId: widget.medecinId,
        jour: widget.dayKey,
        heureDebut: result['debut']!,
        heureFin: result['fin']!,
        dureeConsultation: result['duree'] as int? ?? 30,
        isAvailable: true,
      );
      await controller.createSchedule(defaultSchedule);
    }
  }

  Future<void> _addSchedule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ScheduleTimeDialog(
        existingSchedules: widget.schedules,
        dayKey: widget.dayKey,
      ),
    );

    if (result != null) {
      final controller = ref.read(doctorScheduleControllerProvider.notifier);
      final newSchedule = DoctorSchedule(
        id: '',
        medecinId: widget.medecinId,
        jour: widget.dayKey,
        heureDebut: result['debut']!,
        heureFin: result['fin']!,
        dureeConsultation: result['duree'] as int? ?? 30,
        isAvailable: true,
      );
      await controller.createSchedule(newSchedule);
      widget.onScheduleChanged();
    }
  }

  Future<void> _editSchedule(DoctorSchedule schedule) async {
    // Exclure l'horaire actuel de la liste pour la validation des chevauchements
    final otherSchedules = widget.schedules.where((s) => s.id != schedule.id).toList();
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ScheduleTimeDialog(
        initialDebut: schedule.heureDebut,
        initialFin: schedule.heureFin,
        initialDuree: schedule.dureeConsultation,
        existingSchedules: otherSchedules,
        dayKey: widget.dayKey,
      ),
    );

    if (result != null) {
      final controller = ref.read(doctorScheduleControllerProvider.notifier);
      final updatedSchedule = schedule.copyWith(
        heureDebut: result['debut']!,
        heureFin: result['fin']!,
        dureeConsultation: result['duree'] as int? ?? schedule.dureeConsultation,
      );
      await controller.updateSchedule(schedule.id, updatedSchedule);
      widget.onScheduleChanged();
    }
  }

  Future<void> _deleteSchedule(DoctorSchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet horaire ?'),
        content: Text(
          'Horaires: ${schedule.heureDebut} - ${schedule.heureFin}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = ref.read(doctorScheduleControllerProvider.notifier);
      await controller.deleteSchedule(schedule.id, widget.medecinId);
      
      // Si c'était le dernier horaire, désactiver le jour
      if (widget.schedules.length == 1) {
        setState(() {
          _isEnabled = false;
        });
      }
      widget.onScheduleChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !_isEnabled;
    final textColor = isDisabled ? Colors.grey : Colors.black87;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Switch.adaptive(
                    value: _isEnabled,
                    onChanged: _toggleDay,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.dayLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (_isEnabled)
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: _addSchedule,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Ajouter un horaire',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isEnabled) ...[
                if (widget.schedules.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Aucun horaire défini. Cliquez sur + pour ajouter.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...widget.schedules.map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TimeRangeRow(
                          schedule: schedule,
                          onEdit: () => _editSchedule(schedule),
                          onDelete: () => _deleteSchedule(schedule),
                        ),
                      )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  const _TimeRangeRow({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  final DoctorSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Normalise le format d'heure pour l'affichage (HH:MM:SS -> HH:MM)
  String _normalizeTimeDisplay(String time) {
    if (time.contains(':') && time.split(':').length >= 2) {
      final parts = time.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final debutDisplay = _normalizeTimeDisplay(schedule.heureDebut);
    final finDisplay = _normalizeTimeDisplay(schedule.heureFin);
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$debutDisplay - $finDisplay',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${schedule.dureeConsultation} min',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: const Color(0xFF1D5BFF),
            tooltip: 'Modifier',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.red,
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }
}

class _ScheduleTimeDialog extends StatefulWidget {
  const _ScheduleTimeDialog({
    this.initialDebut,
    this.initialFin,
    this.initialDuree,
    this.existingSchedules = const [],
    this.dayKey,
  });

  final String? initialDebut;
  final String? initialFin;
  final int? initialDuree;
  final List<DoctorSchedule> existingSchedules;
  final String? dayKey; // Pour valider les chevauchements

  @override
  State<_ScheduleTimeDialog> createState() => _ScheduleTimeDialogState();
}

class _ScheduleTimeDialogState extends State<_ScheduleTimeDialog> {
  late TextEditingController _debutController;
  late TextEditingController _finController;
  late TextEditingController _dureeController;

  /// Normalise le format d'heure pour l'affichage (supprime les secondes)
  String _normalizeInitialTime(String? time, String defaultValue) {
    if (time == null || time.isEmpty) return defaultValue;
    // Si c'est au format HH:MM:SS, prendre seulement HH:MM
    if (time.contains(':') && time.split(':').length >= 2) {
      final parts = time.split(':');
      final normalized = '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      return normalized.isEmpty ? defaultValue : normalized;
    }
    return time.isEmpty ? defaultValue : time;
  }

  @override
  void initState() {
    super.initState();
    // Normaliser les heures initiales pour l'affichage
    final debutNormalized = _normalizeInitialTime(widget.initialDebut, '08:00');
    final finNormalized = _normalizeInitialTime(widget.initialFin, '12:00');
    _debutController = TextEditingController(text: debutNormalized);
    _finController = TextEditingController(text: finNormalized);
    _dureeController = TextEditingController(
      text: widget.initialDuree?.toString() ?? '30',
    );
  }

  @override
  void dispose() {
    _debutController.dispose();
    _finController.dispose();
    _dureeController.dispose();
    super.dispose();
  }

  /// Normalise le format d'heure (supprime les secondes si présentes)
  String _normalizeTime(String time) {
    final trimmed = time.trim();
    // Si c'est au format HH:MM:SS, prendre seulement HH:MM
    if (trimmed.contains(':') && trimmed.split(':').length >= 2) {
      final parts = trimmed.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return trimmed;
  }

  bool _validateTime(String time) {
    final normalized = _normalizeTime(time);
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(normalized);
  }

  /// Convertit une heure HH:MM en minutes depuis minuit
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  /// Vérifie si deux plages horaires se chevauchent
  bool _hasOverlap(String debut1, String fin1, String debut2, String fin2) {
    final d1 = _timeToMinutes(debut1);
    final f1 = _timeToMinutes(fin1);
    final d2 = _timeToMinutes(debut2);
    final f2 = _timeToMinutes(fin2);
    
    // Chevauchement si : (d1 < f2) && (d2 < f1)
    return (d1 < f2) && (d2 < f1);
  }

  /// Valide qu'il n'y a pas de chevauchement avec les horaires existants
  String? _validateNoOverlap(String debut, String fin) {
    if (widget.dayKey == null) return null;
    
    for (final existing in widget.existingSchedules) {
      if (existing.jour != widget.dayKey) continue;
      
      if (_hasOverlap(debut, fin, existing.heureDebut, existing.heureFin)) {
        return 'Cet horaire chevauche avec ${existing.heureDebut} - ${existing.heureFin}';
      }
    }
    return null;
  }

  void _submit() {
    var debut = _debutController.text.trim();
    var fin = _finController.text.trim();
    final dureeStr = _dureeController.text.trim();

    // Normaliser les formats d'heure
    debut = _normalizeTime(debut);
    fin = _normalizeTime(fin);

    // Valider le format des heures
    if (!_validateTime(debut) || !_validateTime(fin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format invalide. Utilisez HH:MM (ex: 08:00)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier que l'heure de fin est après l'heure de début
    if (_timeToMinutes(fin) <= _timeToMinutes(debut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'heure de fin doit être après l\'heure de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Valider la durée
    final duree = int.tryParse(dureeStr);
    if (duree == null || duree < 5 || duree > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La durée doit être entre 5 et 180 minutes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier les chevauchements
    final overlapError = _validateNoOverlap(debut, fin);
    if (overlapError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(overlapError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'debut': debut,
      'fin': fin,
      'duree': duree,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialDebut == null ? 'Ajouter un horaire' : 'Modifier l\'horaire'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _debutController,
              decoration: const InputDecoration(
                labelText: 'Heure de début (HH:MM)',
                hintText: '08:00',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _finController,
              decoration: const InputDecoration(
                labelText: 'Heure de fin (HH:MM)',
                hintText: '12:00',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dureeController,
              decoration: const InputDecoration(
                labelText: 'Durée de consultation (minutes)',
                hintText: '30',
                border: OutlineInputBorder(),
                helperText: 'Entre 5 et 180 minutes',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _AgendaStatCard extends StatelessWidget {
  const _AgendaStatCard({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTimeSlot extends StatelessWidget {
  const _AppointmentTimeSlot({
    required this.rdv,
  });

  final RendezVous rdv;

  @override
  Widget build(BuildContext context) {
    final patientName = rdv.patient != null
        ? '${rdv.patient!.firstName} ${rdv.patient!.lastName}'
        : 'Patient';
    final timeLabel = DateFormat('HH:mm', 'fr_FR').format(rdv.dateTime);
    
    Color statusColor;
    String statusLabel;
    switch (rdv.status) {
      case RendezVousStatus.confirme:
        statusColor = const Color(0xFF22C55E);
        statusLabel = 'Confirmé';
        break;
      case RendezVousStatus.termine:
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Terminé';
        break;
      case RendezVousStatus.enAttente:
        statusColor = const Color(0xFFEAB308);
        statusLabel = 'En attente';
        break;
      case RendezVousStatus.annule:
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Annulé';
        break;
      case RendezVousStatus.absent:
        statusColor = const Color(0xFF6B7280);
        statusLabel = 'Absent';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                if (rdv.motifConsultation != null && rdv.motifConsultation!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    rdv.motifConsultation!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingAppointmentItem extends StatelessWidget {
  const _UpcomingAppointmentItem({
    required this.patientName,
    required this.dateLabel,
  });

  final String patientName;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            patientName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// COMPOSANTS POUR LES PAUSES ET CONGÉS
// =====================================================

class _PausesTab extends ConsumerStatefulWidget {
  const _PausesTab({required this.medecinId});

  final String medecinId;

  @override
  ConsumerState<_PausesTab> createState() => _PausesTabState();
}

class _PausesTabState extends ConsumerState<_PausesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.medecinId.isNotEmpty) {
        ref.read(doctorUnavailabilityControllerProvider.notifier).load(widget.medecinId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorUnavailabilityControllerProvider);
    final pauses = state.pauses;

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.medecinId.isNotEmpty) {
          await ref.read(doctorUnavailabilityControllerProvider.notifier).refresh(widget.medecinId);
        }
      },
      child: _UnavailabilityList(
        title: 'Mes Pauses',
        subtitle: 'Les pauses bloquent les créneaux sur une courte période (< 24h)',
        unavailabilities: pauses,
        medecinId: widget.medecinId,
        isPause: true,
        onAdd: () => _showAddPauseDialog(context),
      ),
    );
  }

  Future<void> _showAddPauseDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _UnavailabilityDialog(isPause: true),
    );

    if (result != null && widget.medecinId.isNotEmpty) {
      final controller = ref.read(doctorUnavailabilityControllerProvider.notifier);
      final unavailability = DoctorUnavailability(
        id: '',
        medecinId: widget.medecinId,
        dateDebut: result['debut'] as DateTime,
        dateFin: result['fin'] as DateTime,
        raison: result['raison'] as String?,
      );
      await controller.createUnavailability(unavailability);
    }
  }
}

class _CongesTab extends ConsumerStatefulWidget {
  const _CongesTab({required this.medecinId});

  final String medecinId;

  @override
  ConsumerState<_CongesTab> createState() => _CongesTabState();
}

class _CongesTabState extends ConsumerState<_CongesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.medecinId.isNotEmpty) {
        ref.read(doctorUnavailabilityControllerProvider.notifier).load(widget.medecinId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorUnavailabilityControllerProvider);
    final conges = state.conges;

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.medecinId.isNotEmpty) {
          await ref.read(doctorUnavailabilityControllerProvider.notifier).refresh(widget.medecinId);
        }
      },
      child: _UnavailabilityList(
        title: 'Mes Congés',
        subtitle: 'Les congés bloquent les créneaux sur une période longue (≥ 24h)',
        unavailabilities: conges,
        medecinId: widget.medecinId,
        isPause: false,
        onAdd: () => _showAddCongesDialog(context),
      ),
    );
  }

  Future<void> _showAddCongesDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _UnavailabilityDialog(isPause: false),
    );

    if (result != null && widget.medecinId.isNotEmpty) {
      final controller = ref.read(doctorUnavailabilityControllerProvider.notifier);
      final unavailability = DoctorUnavailability(
        id: '',
        medecinId: widget.medecinId,
        dateDebut: result['debut'] as DateTime,
        dateFin: result['fin'] as DateTime,
        raison: result['raison'] as String?,
      );
      await controller.createUnavailability(unavailability);
    }
  }
}

class _UnavailabilityList extends ConsumerWidget {
  const _UnavailabilityList({
    required this.title,
    required this.subtitle,
    required this.unavailabilities,
    required this.medecinId,
    required this.isPause,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final List<DoctorUnavailability> unavailabilities;
  final String medecinId;
  final bool isPause;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doctorUnavailabilityControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Ajouter ${isPause ? 'une pause' : 'des congés'}'),
          ),
        ),
        const SizedBox(height: 16),
        if (unavailabilities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    isPause ? Icons.pause_circle_outline : Icons.beach_access_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune ${isPause ? 'pause' : 'congé'} définie',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...unavailabilities.map((unavailability) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UnavailabilityCard(
                  unavailability: unavailability,
                  medecinId: medecinId,
                ),
              )),
      ],
    );
  }
}

class _UnavailabilityCard extends ConsumerWidget {
  const _UnavailabilityCard({
    required this.unavailability,
    required this.medecinId,
  });

  final DoctorUnavailability unavailability;
  final String medecinId;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UnavailabilityDialog(
        isPause: unavailability.isPause,
        initialDebut: unavailability.dateDebut,
        initialFin: unavailability.dateFin,
        initialRaison: unavailability.raison,
      ),
    );

    if (result != null) {
      final controller = ref.read(doctorUnavailabilityControllerProvider.notifier);
      final updated = unavailability.copyWith(
        dateDebut: result['debut'] as DateTime,
        dateFin: result['fin'] as DateTime,
        raison: result['raison'] as String?,
      );
      await controller.updateUnavailability(unavailability.id, updated);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${unavailability.isPause ? 'cette pause' : 'ces congés'} ?'),
        content: Text(
          'Du ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(unavailability.dateDebut)} '
          'au ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(unavailability.dateFin)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = ref.read(doctorUnavailabilityControllerProvider.notifier);
      await controller.deleteUnavailability(unavailability.id, medecinId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  unavailability.isPause ? Icons.pause_circle_outline : Icons.beach_access_outlined,
                  color: unavailability.isPause ? Colors.orange : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateFormat.format(unavailability.dateDebut),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _edit(context, ref),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: const Color(0xFF1D5BFF),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => _delete(context, ref),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Jusqu\'au ${dateFormat.format(unavailability.dateFin)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (unavailability.raison != null && unavailability.raison!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Raison: ${unavailability.raison}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnavailabilityDialog extends StatefulWidget {
  const _UnavailabilityDialog({
    required this.isPause,
    this.initialDebut,
    this.initialFin,
    this.initialRaison,
  });

  final bool isPause;
  final DateTime? initialDebut;
  final DateTime? initialFin;
  final String? initialRaison;

  @override
  State<_UnavailabilityDialog> createState() => _UnavailabilityDialogState();
}

class _UnavailabilityDialogState extends State<_UnavailabilityDialog> {
  late DateTime _dateDebut;
  late DateTime _dateFin;
  late TimeOfDay _heureDebut;
  late TimeOfDay _heureFin;
  late TextEditingController _raisonController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateDebut = widget.initialDebut ?? now;
    _dateFin = widget.initialFin ?? (widget.isPause ? now.add(const Duration(hours: 2)) : now.add(const Duration(days: 1)));
    _heureDebut = TimeOfDay.fromDateTime(_dateDebut);
    _heureFin = TimeOfDay.fromDateTime(_dateFin);
    _raisonController = TextEditingController(text: widget.initialRaison);
  }

  @override
  void dispose() {
    _raisonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateDebut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _dateDebut = DateTime(picked.year, picked.month, picked.day, _heureDebut.hour, _heureDebut.minute);
      });
    }
  }

  Future<void> _selectHeureDebut() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureDebut,
    );
    if (picked != null) {
      setState(() {
        _heureDebut = picked;
        _dateDebut = DateTime(_dateDebut.year, _dateDebut.month, _dateDebut.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> _selectDateFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFin,
      firstDate: _dateDebut,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _dateFin = DateTime(picked.year, picked.month, picked.day, _heureFin.hour, _heureFin.minute);
      });
    }
  }

  Future<void> _selectHeureFin() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureFin,
    );
    if (picked != null) {
      setState(() {
        _heureFin = picked;
        _dateFin = DateTime(_dateFin.year, _dateFin.month, _dateFin.day, picked.hour, picked.minute);
      });
    }
  }

  void _submit() {
    if (_dateFin.isBefore(_dateDebut) || _dateFin.isAtSameMomentAs(_dateDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'debut': _dateDebut,
      'fin': _dateFin,
      'raison': _raisonController.text.trim().isEmpty ? null : _raisonController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialDebut == null 
          ? 'Ajouter ${widget.isPause ? 'une pause' : 'des congés'}'
          : 'Modifier ${widget.isPause ? 'la pause' : 'les congés'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date de début'),
              subtitle: Text(DateFormat('dd/MM/yyyy', 'fr_FR').format(_dateDebut)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectDateDebut,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Heure de début'),
              subtitle: Text(_heureDebut.format(context)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectHeureDebut,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date de fin'),
              subtitle: Text(DateFormat('dd/MM/yyyy', 'fr_FR').format(_dateFin)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectDateFin,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Heure de fin'),
              subtitle: Text(_heureFin.format(context)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectHeureFin,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _raisonController,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnel)',
                hintText: 'Ex: Pause déjeuner, Congés annuels...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

// =====================================================
// DIALOGUE DE MODIFICATION DE RENDEZ-VOUS
// =====================================================

class _EditAppointmentDialog extends StatefulWidget {
  const _EditAppointmentDialog({required this.appointment});

  final RendezVous appointment;

  @override
  State<_EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<_EditAppointmentDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _dureeController;
  late TextEditingController _notesController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);
    _dureeController = TextEditingController(
      text: widget.appointment.duree?.toString() ?? '30',
    );
    _notesController = TextEditingController(
      text: widget.appointment.notesMedecin ?? '',
    );
  }

  @override
  void dispose() {
    _dureeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
        _hasChanges = true;
      });
    }
  }

  void _submit() {
    // Valider la durée
    final duree = int.tryParse(_dureeController.text.trim());
    if (duree == null || duree < 5 || duree > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La durée doit être entre 5 et 180 minutes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier que la date/heure n'est pas dans le passé
    if (_selectedDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date et l\'heure ne peuvent pas être dans le passé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> result = {};

    // Vérifier si la date/heure a changé
    if (!_selectedDate.isAtSameMomentAs(widget.appointment.dateTime)) {
      result['dateTime'] = _selectedDate;
    }

    // Vérifier si la durée a changé
    if (duree != widget.appointment.duree) {
      result['duree'] = duree;
    }

    // Vérifier si les notes ont changé
    final notes = _notesController.text.trim();
    if (notes != (widget.appointment.notesMedecin ?? '')) {
      result['notesMedecin'] = notes;
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.appointment.patient != null
        ? '${widget.appointment.patient!.firstName} ${widget.appointment.patient!.lastName}'
        : 'Patient';

    return AlertDialog(
      title: const Text('Modifier le rendez-vous'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations patient (lecture seule)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectDate,
            ),

            // Heure
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Heure'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectTime,
            ),

            const Divider(),

            // Durée
            TextField(
              controller: _dureeController,
              decoration: const InputDecoration(
                labelText: 'Durée (minutes)',
                hintText: '30',
                border: OutlineInputBorder(),
                helperText: 'Entre 5 et 180 minutes',
                prefixIcon: Icon(Icons.schedule),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _hasChanges = true),
            ),

            const SizedBox(height: 16),

            // Notes médecin
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes médecin',
                hintText: 'Ajoutez vos notes sur cette consultation...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 4,
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _hasChanges ? _submit : null,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

