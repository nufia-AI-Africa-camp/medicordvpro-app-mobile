import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../core/domain/consultation_history.dart';
import '../application/history_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = 'history';
  static const subRoutePath = 'history';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Charger l'historique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      final patientId = authState.patient?.id;
      if (patientId != null) {
        ref.read(historyControllerProvider.notifier).load(patientId);
      }
    });
  }

  String _formatDate(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryPurple = Color(0xFF7C3AED);
    const secondaryPink = Color(0xFFEC4899);
    const primaryBlue = Color(0xFF1D5BFF);

    final state = ref.watch(historyControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final patientId = authState.patient?.id;

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          if (patientId != null) {
            await ref.read(historyControllerProvider.notifier).refresh(patientId);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // En-tête dossier médical
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPurple,
                    secondaryPink,
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dossier Médical',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Centralisez tous vos documents et historiques médicaux',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informations de santé
            const Text(
              'Informations de santé',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _HealthInfoCard(
                    title: 'Groupe sanguin',
                    value: 'Non renseigné',
                    icon: Icons.favorite_outline,
                    color: Color(0xFFF97373),
                    backgroundColor: Color(0xFFFFF1F2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _HealthInfoCard(
                    title: 'Allergies',
                    value: 'Non renseigné',
                    icon: Icons.warning_amber_outlined,
                    color: Color(0xFFF97316),
                    backgroundColor: Color(0xFFFFF7ED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final historyState = ref.watch(historyControllerProvider);
                return Row(
                  children: [
                    Expanded(
                      child: _HealthInfoCard(
                        title: 'Consultations',
                        value: historyState.isLoading
                            ? '...'
                            : historyState.totalConsultations.toString(),
                        icon: Icons.medical_services_outlined,
                        color: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFE0ECFF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HealthInfoCard(
                        title: 'Documents',
                        value: historyState.isLoading
                            ? '...'
                            : historyState.totalDocuments.toString(),
                        icon: Icons.description_outlined,
                        color: const Color(0xFF16A34A),
                        backgroundColor: const Color(0xFFE7F6EC),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Historique des consultations
            const Text(
              'Historique des consultations',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.consultationHistories.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0ECFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 32,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune consultation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Votre historique de consultations apparaîtra ici',
                        textAlign: TextAlign.center,
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
                  ...state.consultationHistories.map((consultationHistory) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ConsultationCard(
                      consultationHistory: consultationHistory,
                      formatDate: _formatDate,
                    ),
                  )),

            const SizedBox(height: 24),

            // Bandeau important
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFCD34D),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          'Important',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vos dossiers médicaux contiennent des informations confidentielles. '
                          'Assurez-vous de les conserver en sécurité et de les partager uniquement '
                          'avec les professionnels de santé autorisés.',
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

class _HealthInfoCard extends StatelessWidget {
  const _HealthInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({
    required this.consultationHistory,
    required this.formatDate,
  });

  final ConsultationHistory consultationHistory;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);

    final medecin = consultationHistory.medecin;
    final medecinName = medecin != null
        ? 'Dr. ${medecin.firstName} ${medecin.lastName}'
        : 'Médecin';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0ECFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
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
                        medecinName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(consultationHistory.dateConsultation),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (consultationHistory.documentsJoints != null &&
                    consultationHistory.documentsJoints!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implémenter le téléchargement des documents
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                      size: 16,
                    ),
                    label: const Text(
                      'Télécharger',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryBlue,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Diagnostic
            if (consultationHistory.diagnostic != null && consultationHistory.diagnostic!.isNotEmpty)
              _ConsultationSection(
                icon: Icons.analytics_outlined,
                title: 'Diagnostic',
                content: consultationHistory.diagnostic!,
              ),
            if (consultationHistory.diagnostic != null &&
                consultationHistory.diagnostic!.isNotEmpty &&
                (consultationHistory.traitement != null && consultationHistory.traitement!.isNotEmpty ||
                    consultationHistory.ordonnance != null && consultationHistory.ordonnance!.isNotEmpty ||
                    consultationHistory.notes != null && consultationHistory.notes!.isNotEmpty))
              const SizedBox(height: 12),

            // Traitement
            if (consultationHistory.traitement != null && consultationHistory.traitement!.isNotEmpty)
              _ConsultationSection(
                icon: Icons.medication_liquid_outlined,
                title: 'Traitement',
                content: consultationHistory.traitement!,
              ),
            if (consultationHistory.traitement != null &&
                consultationHistory.traitement!.isNotEmpty &&
                (consultationHistory.ordonnance != null && consultationHistory.ordonnance!.isNotEmpty ||
                    consultationHistory.notes != null && consultationHistory.notes!.isNotEmpty))
              const SizedBox(height: 12),

            // Ordonnance
            if (consultationHistory.ordonnance != null && consultationHistory.ordonnance!.isNotEmpty)
              _ConsultationSection(
                icon: Icons.medication_liquid_outlined,
                title: 'Prescription',
                content: consultationHistory.ordonnance!,
              ),
            if (consultationHistory.ordonnance != null &&
                consultationHistory.ordonnance!.isNotEmpty &&
                consultationHistory.notes != null &&
                consultationHistory.notes!.isNotEmpty)
              const SizedBox(height: 12),

            // Notes
            if (consultationHistory.notes != null && consultationHistory.notes!.isNotEmpty)
              _ConsultationSection(
                icon: Icons.sticky_note_2_outlined,
                title: 'Notes',
                content: consultationHistory.notes!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationSection extends StatelessWidget {
  const _ConsultationSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
