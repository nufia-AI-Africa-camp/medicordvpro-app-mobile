import 'package:flutter/material.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  static const routeName = 'appointments';
  static const subRoutePath = 'appointments';

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  int _selectedStatusIndex = 0;

  final List<String> _statuses = const [
    'Tous',
    'Confirmés',
    'Terminés',
    'Annulés',
  ];

  String get _emptySubtitle {
    switch (_selectedStatusIndex) {
      case 1:
        return 'Aucun rendez-vous confirmé';
      case 2:
        return 'Aucun rendez-vous terminé';
      case 3:
        return 'Aucun rendez-vous annulé';
      default:
        return 'Aucun rendez-vous trouvé';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    const backgroundColor = Color(0xFFF5F7FF);

    return Container(
      color: backgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
          const Text(
            '0 rendez-vous trouvés',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Bouton "Nouveau rendez-vous"
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: rediriger vers le flux de prise de rendez-vous
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau rendez-vous'),
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
                  Row(
                    children: const [
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
                    children: List.generate(_statuses.length, (index) {
                      final selected = index == _selectedStatusIndex;

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

                      const String count = '0';

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
                                  '${_statuses[index]} ($count)',
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

          // Carte vide
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
                    _emptySubtitle,
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
                        // TODO: rediriger vers le flux de prise de rendez-vous
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Prendre un rendez-vous'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}


