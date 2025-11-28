import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../core/domain/rendez_vous.dart';
import '../application/appointments_list_controller.dart';

class AppointmentsListScreen extends ConsumerStatefulWidget {
  const AppointmentsListScreen({super.key});

  static const routeName = 'appointments';
  static const subRoutePath = 'appointments';

  @override
  ConsumerState<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

class _AppointmentsListScreenState
    extends ConsumerState<AppointmentsListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les rendez-vous au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      final patientId = authState.patient?.id;
      if (patientId != null) {
        ref.read(appointmentsListControllerProvider.notifier).load(patientId);
      }
    });
  }

  String _getEmptySubtitle(AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.confirmes:
        return 'Aucun rendez-vous confirmé';
      case AppointmentFilter.termines:
        return 'Aucun rendez-vous terminé';
      case AppointmentFilter.annules:
        return 'Aucun rendez-vous annulé';
      case AppointmentFilter.tous:
        return 'Aucun rendez-vous trouvé';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    const backgroundColor = Color(0xFFF5F7FF);

    final state = ref.watch(appointmentsListControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final patientId = authState.patient?.id;

    final statuses = const [
      'Tous',
      'Confirmés',
      'Terminés',
      'Annulés',
    ];

    return Container(
      color: backgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: RefreshIndicator(
            onRefresh: () async {
              if (patientId != null) {
                await ref
                    .read(appointmentsListControllerProvider.notifier)
                    .refresh(patientId);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                  '${state.filteredAppointments.length} rendez-vous trouvés',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Carte filtres
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Filtrer par statut',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(statuses.length, (index) {
                            final filter = AppointmentFilter.values[index];
                            final selected = state.selectedFilter == filter;

                            final Color bgColor;
                            final Color textColor;

                            if (index == 3 && selected) {
                              bgColor = Colors.red;
                              textColor = Colors.white;
                            } else if (selected) {
                              bgColor = primaryBlue;
                              textColor = Colors.white;
                            } else {
                              bgColor = const Color(0xFFF4F4F6);
                              textColor = Colors.black87;
                            }

                            int count;
                            switch (filter) {
                              case AppointmentFilter.confirmes:
                                count = state.countConfirmes;
                                break;
                              case AppointmentFilter.termines:
                                count = state.countTermines;
                                break;
                              case AppointmentFilter.annules:
                                count = state.countAnnules;
                                break;
                              case AppointmentFilter.tous:
                                count = state.countTotal;
                            }

                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == statuses.length - 1 ? 0 : 8,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(
                                          appointmentsListControllerProvider
                                              .notifier)
                                      .setFilter(filter);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${statuses[index]} ($count)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
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

                // Liste des rendez-vous ou carte vide
                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.filteredAppointments.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.event_note_outlined,
                              size: 32,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun rendez-vous',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getEmptySubtitle(state.selectedFilter),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () {
                                // Navigation gérée par le dashboard
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Prendre un rendez-vous'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.filteredAppointments.map((rdv) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AppointmentCard(rendezVous: rdv),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.rendezVous});

  final RendezVous rendezVous;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);

    final medecin = rendezVous.medecin;
    final medecinName = medecin != null
        ? 'Dr. ${medecin.firstName} ${medecin.lastName}'
        : 'Médecin';
    final specialite = medecin?.speciality ?? '';

    // Formatage des dates sans intl
    final dateLabel = '${rendezVous.dateTime.day.toString().padLeft(2, '0')}/'
        '${rendezVous.dateTime.month.toString().padLeft(2, '0')}/'
        '${rendezVous.dateTime.year}';
    final timeLabel = '${rendezVous.dateTime.hour.toString().padLeft(2, '0')}:'
        '${rendezVous.dateTime.minute.toString().padLeft(2, '0')}';

    // Calculer le nombre de jours jusqu'au rendez-vous
    final now = DateTime.now();
    final difference = rendezVous.dateTime.difference(now);
    final daysUntil = difference.inDays;
    String daysLabel;
    if (daysUntil < 0) {
      daysLabel = 'Passé';
    } else if (daysUntil == 0) {
      daysLabel = "Aujourd'hui";
    } else if (daysUntil == 1) {
      daysLabel = 'Demain';
    } else {
      daysLabel = 'Dans $daysUntil jours';
    }

    // Couleur et label du statut
    Color statusColor;
    String statusLabel;
    switch (rendezVous.status) {
      case RendezVousStatus.confirme:
        statusColor = const Color(0xFF16A34A);
        statusLabel = 'Confirmé';
        break;
      case RendezVousStatus.termine:
        statusColor = const Color(0xFF1D5BFF);
        statusLabel = 'Terminé';
        break;
      case RendezVousStatus.annule:
        statusColor = Colors.red;
        statusLabel = 'Annulé';
        break;
      case RendezVousStatus.enAttente:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'En attente';
        break;
      case RendezVousStatus.absent:
        statusColor = Colors.grey;
        statusLabel = 'Absent';
        break;
    }

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
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE4ECFF),
                  child: medecin?.photoProfil != null
                      ? ClipOval(
                          child: Image.network(
                            medecin!.photoProfil!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              medecinName.isNotEmpty
                                  ? medecinName[0].toUpperCase()
                                  : 'M',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          medecinName.isNotEmpty
                              ? medecinName[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        '$dateLabel • $timeLabel',
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
                    daysLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (rendezVous.motifConsultation != null &&
                rendezVous.motifConsultation!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              const Text(
                'Motif',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rendezVous.motifConsultation!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
