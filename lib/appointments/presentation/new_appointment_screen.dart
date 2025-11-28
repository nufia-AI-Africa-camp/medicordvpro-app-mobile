import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/medecin.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../application/appointment_search_controller.dart';
import 'select_date_time_screen.dart';

class NewAppointmentScreen extends ConsumerStatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  ConsumerState<NewAppointmentScreen> createState() =>
      _NewAppointmentScreenState();
}

class _NewAppointmentScreenState
    extends ConsumerState<NewAppointmentScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final List<String> _categories = const [
    'Tous',
    'Médecin Généraliste',
    'Cardiologie',
    'Dermatologie',
    'Pédiatrie',
    'Ophtalmologie',
    'Dentiste',
  ];

  @override
  void initState() {
    super.initState();
    // Charger tous les médecins au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentSearchControllerProvider.notifier).search();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final controller = ref.read(appointmentSearchControllerProvider.notifier);
    controller.updateQuery(_searchController.text);
    controller.search();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(appointmentSearchControllerProvider);

    const primaryBlue = Color(0xFF1D5BFF);
    const backgroundColor = Color(0xFFF5F7FF);

    return Container(
      color: backgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stepper header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StepItem(
                  label: 'Médecin',
                  isActive: true,
                  isCompleted: true,
                  index: 1,
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                  ),
                ),
                _StepItem(
                  label: 'Date & heure',
                  isActive: false,
                  isCompleted: false,
                  index: 2,
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                  ),
                ),
                _StepItem(
                  label: 'Confirmation',
                  isActive: false,
                  isCompleted: false,
                  index: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search fields
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Rechercher un médecin ou une spécialité...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.place_outlined),
                      hintText: 'Filtrer par localisation (ville, arrondissement...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: searchState.isLoading ? null : _performSearch,
                      child: searchState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Rechercher'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_categories.length, (index) {
                final selected = index == _selectedCategoryIndex;
                return Padding(
                  padding: EdgeInsets.only(
                      right: index == _categories.length - 1 ? 0 : 8),
                  child: ChoiceChip(
                    label: Text(
                      _categories[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: selected,
                    selectedColor: primaryBlue,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected ? primaryBlue : const Color(0xFFE0E0E0),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                      // TODO: Filtrer par spécialité
                      _performSearch();
                    },
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Error message
          if (searchState.errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        searchState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (searchState.errorMessage != null) const SizedBox(height: 12),

          // Results count
          Text(
            '${searchState.results.length} médecin${searchState.results.length > 1 ? 's' : ''} trouvé${searchState.results.length > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 12),

          // Loading indicator
          if (searchState.isLoading && searchState.results.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),

          // Doctors list
          if (!searchState.isLoading || searchState.results.isNotEmpty)
            ...searchState.results.map(
              (doctor) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DoctorCard(
                  doctor: doctor,
                ),
              ),
            ),

          // Empty state
          if (!searchState.isLoading &&
              searchState.results.isEmpty &&
              searchState.errorMessage == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun médecin trouvé',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Essayez de modifier vos critères de recherche',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
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

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.label,
    required this.index,
    required this.isActive,
    required this.isCompleted,
  });

  final String label;
  final int index;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);

    Color circleColor;
    Color textColor;

    if (isCompleted || isActive) {
      circleColor = primaryBlue;
      textColor = primaryBlue;
    } else {
      circleColor = Colors.grey.shade300;
      textColor = Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: circleColor,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final Medecin doctor;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE4ECFF),
              backgroundImage: doctor.photoProfil != null
                  ? NetworkImage(doctor.photoProfil!)
                  : null,
              child: doctor.photoProfil == null
                  ? Text(
                      _initials(doctor.fullName),
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
                    'Dr. ${doctor.fullName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.speciality,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor.bio!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.fullAddress,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (doctor.tarif != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.euro,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.tarif!.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (doctor.telephone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_in_talk_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.telephone!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Afficher les détails du cabinet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Infos cabinet: ${doctor.centre}'),
                      ),
                    );
                  },
                  child: const Text(
                    'Infos cabinet',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      // Naviguer vers la sélection de date/heure
                      context.push(
                        '${DashboardScreen.routePath}${SelectDateTimeScreen.subRoutePath}',
                        extra: doctor,
                      );
                    },
                    child: const Text('Choisir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
