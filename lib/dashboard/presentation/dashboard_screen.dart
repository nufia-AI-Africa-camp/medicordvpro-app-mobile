import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../core/domain/patient.dart';
import '../../appointments/presentation/appointments_list_screen.dart';
import '../../appointments/presentation/new_appointment_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../application/dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = 'dashboard';
  static const routePath = '/dashboard';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final patient = authState.patient;

    final tabs = [
      _DashboardHomeTab(
        patient: patient,
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const NewAppointmentScreen(),
      const AppointmentsListScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace patient'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: NotificationsIconButton(),
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
            icon: Icon(Icons.dashboard_outlined),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Nouveau RDV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Mes RDV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            label: 'Dossier médical',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DashboardHomeTab extends ConsumerStatefulWidget {
  const _DashboardHomeTab({
    required this.patient,
    required this.onNavigateToTab,
  });

  final Patient? patient;
  final ValueChanged<int> onNavigateToTab;

  @override
  ConsumerState<_DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends ConsumerState<_DashboardHomeTab> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      final patientId = authState.patient?.id;
      if (patientId != null) {
        ref.read(dashboardControllerProvider.notifier).load(patientId);
      }
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    final days = difference.inDays;
    
    if (days < 0) {
      return 'Passé';
    } else if (days == 0) {
      return "Aujourd'hui";
    } else if (days == 1) {
      return 'Demain';
    } else {
      return '$days jours';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    const secondaryBlue = Color(0xFF3F7CFF);
    const backgroundColor = Color(0xFFF5F7FF);

    final authState = ref.watch(authControllerProvider);
    final patientId = authState.patient?.id;
    final dashboardState = patientId != null
        ? ref.watch(dashboardControllerProvider)
        : null;

    final firstName = (widget.patient?.firstName ?? '').isNotEmpty
        ? widget.patient!.firstName
        : 'Marie';

    final nextAppointment = dashboardState?.nextAppointment;
    final medecin = nextAppointment?.medecin;
    final medecinName = medecin != null
        ? 'Dr. ${medecin.firstName} ${medecin.lastName}'
        : null;

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          if (patientId != null) {
            await ref.read(dashboardControllerProvider.notifier).refresh(patientId);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          // Carte bleue de bienvenue + prochain rendez-vous
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryBlue,
                  secondaryBlue,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $firstName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bienvenue sur votre tableau de bord médical',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // Bloc prochain rendez-vous (résumé)
                if (nextAppointment != null && medecinName != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prochain rendez-vous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$medecinName • ${_formatDate(nextAppointment.dateTime)} à ${_formatTime(nextAppointment.dateTime)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getDaysUntil(nextAppointment.dateTime) == "Aujourd'hui"
                                    ? '0'
                                    : _getDaysUntil(nextAppointment.dateTime) == 'Demain'
                                        ? '1'
                                        : _getDaysUntil(nextAppointment.dateTime).split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDaysUntil(nextAppointment.dateTime) == "Aujourd'hui"
                                    ? "aujourd'hui"
                                    : _getDaysUntil(nextAppointment.dateTime) == 'Demain'
                                        ? 'jour'
                                        : 'jours',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prochain rendez-vous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Aucun rendez-vous à venir',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
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

          const SizedBox(height: 20),

          // Statistiques rapides
          const Text(
            'Statistiques rapides',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DashboardStatCard(
                  label: 'À venir',
                  value: dashboardState?.isLoading == true
                      ? '...'
                      : (dashboardState?.countUpcoming ?? 0).toString(),
                  subtitle: 'Rendez-vous confirmés',
                  icon: Icons.event_available_outlined,
                  iconColor: const Color(0xFF4C6FFF),
                  badgeColor: const Color(0xFFE4ECFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashboardStatCard(
                  label: 'Complétés',
                  value: dashboardState?.isLoading == true
                      ? '...'
                      : (dashboardState?.countCompleted ?? 0).toString(),
                  subtitle: 'Consultations terminées',
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF1CBF72),
                  badgeColor: const Color(0xFFE3F7ED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DashboardStatCard(
                  label: 'Annulés',
                  value: dashboardState?.isLoading == true
                      ? '...'
                      : (dashboardState?.countCancelled ?? 0).toString(),
                  subtitle: 'Rendez-vous annulés',
                  icon: Icons.cancel_outlined,
                  iconColor: const Color(0xFFF16063),
                  badgeColor: const Color(0xFFFDE4E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashboardStatCard(
                  label: 'Total',
                  value: dashboardState?.isLoading == true
                      ? '...'
                      : (dashboardState?.countTotal ?? 0).toString(),
                  subtitle: 'Tous les rendez-vous',
                  icon: Icons.insert_chart_outlined_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  badgeColor: const Color(0xFFEDE9FE),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Actions rapides
          const Text(
            '🧾 Actions rapides',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _DashboardActionCard(
            icon: Icons.add_circle_outline,
            title: 'Nouveau rendez-vous',
            subtitle: 'Réserver une consultation',
            onTap: () {
              // Naviguer vers l'onglet "Nouveau RDV" (index 1)
              widget.onNavigateToTab(1);
            },
          ),
          const SizedBox(height: 12),
          _DashboardActionCard(
            icon: Icons.event_note_outlined,
            title: 'Mes rendez-vous',
            subtitle: 'Voir l\'historique complet',
            onTap: () {
              // Naviguer vers l'onglet "Mes RDV" (index 2)
              widget.onNavigateToTab(2);
            },
          ),

          const SizedBox(height: 24),

          // Prochains rendez-vous (détail)
          const Text(
            'Prochains rendez-vous',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (dashboardState?.isLoading == true)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (dashboardState?.upcomingAppointments.isEmpty ?? true)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Aucun rendez-vous à venir',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...dashboardState!.upcomingAppointments.take(3).map((rdv) {
              final medecin = rdv.medecin;
              final medecinName = medecin != null
                  ? 'Dr. ${medecin.firstName} ${medecin.lastName}'
                  : 'Médecin';
              final specialite = medecin?.speciality ?? '';
              final initials = medecinName.length >= 2
                  ? medecinName.substring(3, 5).toUpperCase()
                  : 'M';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFE4ECFF),
                        backgroundImage: medecin?.photoProfil != null
                            ? NetworkImage(medecin!.photoProfil!)
                            : null,
                        child: medecin?.photoProfil == null
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medecinName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (specialite.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                specialite,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              '${_formatDate(rdv.dateTime)} • ${_formatTime(rdv.dateTime)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4ECFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _getDaysUntil(rdv.dateTime),
                          style: const TextStyle(
                            fontSize: 11,
                            color: primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
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
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE4ECFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1D5BFF),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsIconButton extends StatelessWidget {
  const NotificationsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NotificationsScreen(),
          ),
        );
      },
      icon: const Icon(Icons.notifications_outlined),
    );
  }
}


