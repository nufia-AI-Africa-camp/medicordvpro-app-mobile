import 'package:flutter/material.dart';

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

class _DoctorAgendaTab extends StatelessWidget {
  const _DoctorAgendaTab();

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4C1D95);
    const secondaryPurple = Color(0xFF7C3AED);
    const backgroundColor = Color(0xFFF5F7FF);

    return Container(
      color: backgroundColor,
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
                const Text(
                  'Bonjour Dr. Sophie Martin 👨‍⚕️',
                  style: TextStyle(
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
                  children: const [
                    Expanded(
                      child: _AgendaStatCard(
                        label: "Aujourd'hui",
                        value: '0',
                        subtitle: 'rendez-vous',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _AgendaStatCard(
                        label: 'À venir',
                        value: '2',
                        subtitle: 'confirmés',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _AgendaStatCard(
                        label: 'Complétés',
                        value: '0',
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
                  children: const [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Mercredi 26 Novembre 2025',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Aujourd’hui',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D5BFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Jour',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Semaine',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
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
            child: Column(
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Planning de la journée',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Icon(
                  Icons.event_busy_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucun rendez-vous',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vous n’avez pas de rendez-vous pour cette journée',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12),
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
                      const _StatusLine(
                        color: Color(0xFF22C55E),
                        label: 'Confirmés',
                        value: '2',
                      ),
                      const _StatusLine(
                        color: Color(0xFF3B82F6),
                        label: 'Terminés',
                        value: '1',
                      ),
                      const _StatusLine(
                        color: Color(0xFFEAB308),
                        label: 'En attente',
                        value: '0',
                      ),
                      const _StatusLine(
                        color: Color(0xFFEF4444),
                        label: 'Annulés',
                        value: '0',
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
                    children: const [
                      Text(
                        'Prochains rendez-vous',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      _UpcomingAppointmentItem(
                        patientName: 'Marie Dubois',
                        dateLabel: '28/11/2025 à 10:00',
                      ),
                      SizedBox(height: 8),
                      _UpcomingAppointmentItem(
                        patientName: 'Jean Dupont',
                        dateLabel: '05/12/2025 à 09:00',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorAvailabilityTab extends StatelessWidget {
  const _DoctorAvailabilityTab();

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4C1D95);
    const secondaryPurple = Color(0xFF7C3AED);
    const backgroundColor = Color(0xFFF5F7FF);

    final enabledDays = <String, bool>{
      'Lundi': true,
      'Mardi': true,
      'Mercredi': true,
      'Jeudi': true,
      'Vendredi': true,
      'Samedi': false,
      'Dimanche': false,
    };

    return Container(
      color: backgroundColor,
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
                      _AvailabilityTabChip(
                        label: 'Horaires',
                        isSelected: true,
                      ),
                      _AvailabilityTabChip(
                        label: 'Pauses',
                        isSelected: false,
                        badgeColor: Colors.orangeAccent,
                      ),
                      _AvailabilityTabChip(
                        label: 'Congés',
                        isSelected: false,
                        badgeColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bouton enregistrer
          SizedBox(
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D5BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                // TODO: sauvegarder les disponibilités
              },
              child: const Text(
                'Enregistrer toutes les modifications',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Jours de la semaine
          ...enabledDays.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AvailabilityDayCard(
                dayLabel: entry.key,
                enabled: entry.value,
              ),
            ),
          ),

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
    );
  }
}

class _DoctorAppointmentsTab extends StatefulWidget {
  const _DoctorAppointmentsTab();

  @override
  State<_DoctorAppointmentsTab> createState() => _DoctorAppointmentsTabState();
}

class _DoctorAppointmentsTabState extends State<_DoctorAppointmentsTab> {
  int _selectedStatusIndex = 0;

  final List<String> _statuses = const [
    'Tous',
    'Confirmés',
    'Terminés',
    'Annulés',
  ];

  String get _statusSubtitle {
    switch (_selectedStatusIndex) {
      case 1:
        return '2 rendez-vous confirmés';
      case 2:
        return '1 rendez-vous terminé';
      case 3:
        return '0 rendez-vous annulés';
      default:
        return '3 rendez-vous trouvés';
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryBlue = Color(0xFF1D5BFF);

    return Container(
      color: backgroundColor,
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
                    _statusSubtitle,
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
                    // TODO: démarrer la création d’un nouveau rendez-vous
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
                          count = '2';
                          break;
                        case 2:
                          count = '1';
                          break;
                        case 3:
                          count = '0';
                          break;
                        default:
                          count = '3';
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

          const _DoctorAppointmentCard(
            doctorName: 'Dr. Sophie Martin',
            specialty: 'Médecin Généraliste',
            dateLabel: 'Vendredi 05 Décembre 2025',
            timeLabel: '09:00',
            patientName: 'Jean Dupont',
            phone: '06 23 45 67 89',
            statusLabel: 'Confirmé',
            statusColor: Color(0xFF16A34A),
            motif: 'Suivi médical annuel',
            notes: 'Apporter les résultats sanguins',
          ),
          const SizedBox(height: 12),
          const _DoctorAppointmentCard(
            doctorName: 'Dr. Sophie Martin',
            specialty: 'Médecin Généraliste',
            dateLabel: 'Vendredi 28 Novembre 2025',
            timeLabel: '10:00',
            patientName: 'Marie Dubois',
            phone: '06 12 34 56 78',
            statusLabel: 'Confirmé',
            statusColor: Color(0xFF16A34A),
            motif: 'Consultation générale - Douleurs abdominales',
            notes: 'Première consultation',
          ),
          const SizedBox(height: 12),
          const _DoctorAppointmentCard(
            doctorName: 'Dr. Marie Lefebvre',
            specialty: 'Dermatologue',
            dateLabel: 'Samedi 15 Novembre 2025',
            timeLabel: '14:30',
            patientName: 'Marie Dubois',
            phone: '06 12 34 56 78',
            statusLabel: 'Terminé',
            statusColor: Color(0xFF3B82F6),
            motif: 'Contrôle annuel peau',
            notes: '',
          ),
        ],
      ),
    );
  }
}

class _DoctorAppointmentCard extends StatelessWidget {
  const _DoctorAppointmentCard({
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

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);

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
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: modifier le rendez-vous
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                  ),
                  label: const Text(
                    'Modifier',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: annuler le rendez-vous
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorStatsTab extends StatelessWidget {
  const _DoctorStatsTab();

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryGreen = Color(0xFF16A34A);
    const secondaryGreen = Color(0xFF22C55E);

    return Container(
      color: backgroundColor,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Statistiques & Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vue d’ensemble de votre activité médicale',
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
          Row(
            children: const [
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.event_note_outlined,
                  label: 'Total rendez-vous',
                  value: '3',
                  trendIcon: Icons.trending_up,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.check_circle_outline,
                  label: 'Consultations terminées',
                  value: '1',
                  suffix: '33 %',
                  trendIcon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.people_outline,
                  label: 'Patients uniques',
                  value: '2',
                  trendIcon: Icons.trending_up,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatKpiCard(
                  icon: Icons.attach_money_outlined,
                  label: 'Revenu estimé',
                  value: r'$ 25',
                  trendIcon: Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Semaine / mois / taux d’annulation
          Row(
            children: const [
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Cette semaine',
                  value: '1',
                  subtitle: 'rendez-vous',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.date_range_outlined,
                  label: 'Ce mois',
                  value: '2',
                  subtitle: 'rendez-vous',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.percent,
                  label: 'Taux d’annulation',
                  value: '0%',
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
              children: const [
                _ProgressStatLine(
                  label: 'Confirmés',
                  value: '2',
                  progress: 2 / 3,
                  color: Color(0xFF22C55E),
                ),
                _ProgressStatLine(
                  label: 'Terminés',
                  value: '1',
                  progress: 1 / 3,
                  color: Color(0xFF3B82F6),
                ),
                _ProgressStatLine(
                  label: 'En attente',
                  value: '0',
                  progress: 0,
                  color: Color(0xFFEAB308),
                ),
                _ProgressStatLine(
                  label: 'Annulés',
                  value: '0',
                  progress: 0,
                  color: Color(0xFFEF4444),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _StatSectionCard(
                  title: 'Consultations par spécialité',
                  child: Column(
                    children: [
                      _ProgressStatLine(
                        label: 'Médecin Généraliste',
                        value: '2 consultations',
                        progress: 2 / 3,
                        color: Color(0xFF4C6FFF),
                        small: true,
                      ),
                      _ProgressStatLine(
                        label: 'Dermatologue',
                        value: '1 consultation',
                        progress: 1 / 3,
                        color: Color(0xFFEC4899),
                        small: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatSectionCard(
                  title: 'Distribution par jour',
                  child: Column(
                    children: [
                      _ProgressStatLine(
                        label: 'Vendredi',
                        value: '2',
                        progress: 2 / 3,
                        color: Color(0xFF8B5CF6),
                        small: true,
                      ),
                      _ProgressStatLine(
                        label: 'Samedi',
                        value: '1',
                        progress: 1 / 3,
                        color: Color(0xFFEC4899),
                        small: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _StatSectionCard(
                  title: 'Distribution horaire',
                  child: Column(
                    children: [
                      _ProgressStatLine(
                        label: 'Matin (8h–12h)',
                        value: '2 consultations',
                        progress: 2 / 3,
                        color: Color(0xFFF97316),
                        small: true,
                      ),
                      _ProgressStatLine(
                        label: 'Après-midi (14h–18h)',
                        value: '1 consultation',
                        progress: 1 / 3,
                        color: Color(0xFFFB923C),
                        small: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatSectionCard(
                  title: 'Indicateurs de performance',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KpiInlineLine(
                        label: 'Taux de complétion',
                        value: '33 %',
                        icon: Icons.check_circle_outline,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(height: 8),
                      _KpiInlineLine(
                        label: 'Patients fidèles',
                        value: '67 %',
                        icon: Icons.people_outline,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(height: 8),
                      _KpiInlineLine(
                        label: 'Revenu moyen/patient',
                        value: '13 €',
                        icon: Icons.euro_outlined,
                        color: Color(0xFFF97316),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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

class _DoctorAutoRemindersTab extends StatelessWidget {
  const _DoctorAutoRemindersTab();

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryRed = Color(0xFFDC2626);
    const secondaryOrange = Color(0xFFF97316);

    return Container(
      color: backgroundColor,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
                        value: true,
                        onChanged: null, // mock pour l’instant
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
                    active: true,
                  ),
                  const SizedBox(height: 6),
                  // Email
                  _ReminderChannelRow(
                    icon: Icons.email_outlined,
                    label: 'Rappel par Email',
                    description: 'Envoyer un email au patient',
                    active: true,
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
                        child: const Text(
                          '24h avant',
                          style: TextStyle(
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
                      value: 0.5,
                      onChanged: null, // mock
                      min: 0,
                      max: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Les patients recevront un rappel 24 heures avant leur rendez-vous.',
                    style: TextStyle(
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
              onPressed: () {
                // TODO: enregistrer les paramètres
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text(
                'Enregistrer les paramètres',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stat petits blocs
          Row(
            children: const [
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.send_outlined,
                  label: 'Rappels envoyés',
                  value: '1',
                  subtitle: 'Notifications déjà envoyées',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.schedule_send_outlined,
                  label: 'En attente',
                  value: '1',
                  subtitle: 'À envoyer prochainement',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.check_circle_outline,
                  label: 'Total à venir',
                  value: '2',
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jean Dupont',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Vendredi 5 Décembre à 09:00',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: voir le détail
                          },
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: Color(0xFF1D5BFF),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: annuler le rappel
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    );
  }
}

class _ReminderChannelRow extends StatelessWidget {
  const _ReminderChannelRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool active;

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
        Switch(
          value: active,
          onChanged: null, // mock
          activeColor: color,
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

class _AvailabilityDayCard extends StatelessWidget {
  const _AvailabilityDayCard({
    required this.dayLabel,
    required this.enabled,
  });

  final String dayLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled;
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
                    value: enabled,
                    onChanged: (_) {
                      // TODO: rendre interactif plus tard
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TimeRangeRow(label: 'Matin', isDisabled: isDisabled),
              const SizedBox(height: 8),
              _TimeRangeRow(label: 'Après-midi', isDisabled: isDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  const _TimeRangeRow({
    required this.label,
    required this.isDisabled,
  });

  final String label;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(
      fontSize: 12,
      color: isDisabled ? Colors.grey[400] : Colors.grey[600],
    );

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDisabled ? Colors.grey : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            enabled: !isDisabled,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              hintText: '08:00 - 12:00',
              hintStyle: hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
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

