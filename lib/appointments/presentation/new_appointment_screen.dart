import 'package:flutter/material.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = const [
    'Tous',
    'Médecin Généraliste',
    'Cardiologue',
    'Dermatologue',
    'Pédiatre',
    'Ophtalmologue',
    'Dentiste',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const primaryBlue = Color(0xFF1D5BFF);
    const backgroundColor = Color(0xFFF5F7FF);

    final doctors = _mockDoctors;

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
                  ),
                  const SizedBox(height: 8),
                  TextField(
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
                  padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 8),
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
                    },
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${doctors.length} médecins trouvés',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 12),

          // Doctors list
          ...doctors.map(
            (doctor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DoctorCard(
                doctor: doctor,
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
    final primaryBlue = const Color(0xFF1D5BFF);

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

class _Doctor {
  const _Doctor({
    required this.name,
    required this.specialty,
    required this.address,
    required this.city,
    required this.phone,
    required this.rating,
    required this.reviewCount,
  });

  final String name;
  final String specialty;
  final String address;
  final String city;
  final String phone;
  final double rating;
  final int reviewCount;
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final _Doctor doctor;

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
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE4ECFF),
              child: Text(
                _initials(doctor.name),
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
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
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
                          '${doctor.address}, ${doctor.city}',
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFFFB020),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${doctor.reviewCount})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
                        doctor.phone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Infos cabinet (mock).'),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Médecin sélectionné : ${doctor.name} (mock).'),
                        ),
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
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

const List<_Doctor> _mockDoctors = [
  _Doctor(
    name: 'Dr. Sophie Martin',
    specialty: 'Médecin Généraliste',
    address: '18 rue du Marché',
    city: '75012 Paris',
    phone: '01 23 45 67 89',
    rating: 4.9,
    reviewCount: 43,
  ),
  _Doctor(
    name: 'Dr. Pierre Dubois',
    specialty: 'Cardiologue',
    address: '28 Avenue Victor Hugo',
    city: '75016 Paris',
    phone: '01 45 22 34 56',
    rating: 4.8,
    reviewCount: 31,
  ),
  _Doctor(
    name: 'Dr. Marie Lefebvre',
    specialty: 'Dermatologue',
    address: '42 Boulevard Saint-Germain',
    city: '75005 Paris',
    phone: '01 40 11 22 33',
    rating: 4.6,
    reviewCount: 27,
  ),
  _Doctor(
    name: 'Dr. Thomas Bernard',
    specialty: 'Pédiatre',
    address: '8 Rue des Écoles',
    city: '92100 Boulogne',
    phone: '01 46 45 67 21',
    rating: 4.7,
    reviewCount: 19,
  ),
  _Doctor(
    name: 'Dr. Claire Moreau',
    specialty: 'Médecin Généraliste',
    address: '35 Rue de Lyon',
    city: '75008 Paris',
    phone: '01 55 33 22 11',
    rating: 4.8,
    reviewCount: 36,
  ),
  _Doctor(
    name: 'Dr. Laurent Petit',
    specialty: 'Dentiste',
    address: '12 Place du Bourvil',
    city: '75019 Paris',
    phone: '01 49 30 12 34',
    rating: 4.5,
    reviewCount: 22,
  ),
];


