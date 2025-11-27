import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';
  static const subRoutePath = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryBlue = Color(0xFF1D5BFF);
    const secondaryBlue = Color(0xFF3B82F6);

    final authState = ref.watch(authControllerProvider);
    final patient = authState.patient;

    final fullName = patient != null
        ? '${patient.firstName} ${patient.lastName}'
        : 'Patient';
    final email = patient?.email ?? 'Email non renseigné';
    final phone = patient?.phoneNumber ?? 'Téléphone non renseigné';

    String ageLabel = 'Âge non renseigné';
    String birthDateLabel = 'Non renseignée';

    final birthDate = patient?.birthDate;
    if (birthDate != null) {
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      final hadBirthdayThisYear = DateTime(
            now.year,
            birthDate.month,
            birthDate.day,
          ).isBefore(now) ||
          DateTime(
            now.year,
            birthDate.month,
            birthDate.day,
          ).isAtSameMomentAs(now);
      if (!hadBirthdayThisYear) {
        age--;
      }

      age = age.clamp(0, 130);

      ageLabel = '$age ans';

      final day = birthDate.day.toString().padLeft(2, '0');
      final month = birthDate.month.toString().padLeft(2, '0');
      birthDateLabel = '$day/$month/${birthDate.year} ($age ans)';
    }

    // TODO: connecter ces statistiques au backend de rendez-vous
    const consultationsCount = '0';
    const upcomingCount = '0';

    return Container(
      color: backgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bandeau haut profil
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        // TODO: implémenter la modification du profil
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                      ),
                      label: const Text(
                        'Modifier',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    const _ProfileStatChip(
                      label: 'Consultations',
                      value: consultationsCount,
                    ),
                    const SizedBox(width: 10),
                    const _ProfileStatChip(
                      label: 'À venir',
                      value: upcomingCount,
                    ),
                    const SizedBox(width: 10),
                    _ProfileStatChip(
                      label: 'Âge',
                      value: ageLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Carte informations personnelles
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1ère ligne
                  _ProfileInfoRow(
                    leftIcon: Icons.person_outline,
                    leftLabel: 'Nom complet',
                    leftValue: fullName,
                    rightIcon: Icons.event_outlined,
                    rightLabel: 'Date de naissance',
                    rightValue: birthDateLabel,
                  ),
                  const SizedBox(height: 16),

                  // 2ème ligne
                  _ProfileInfoRow(
                    leftIcon: Icons.email_outlined,
                    leftLabel: 'Email',
                    leftValue: email,
                    rightIcon: Icons.phone_outlined,
                    rightLabel: 'Téléphone',
                    rightValue: phone,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bandeau confidentialité
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
                    Icons.lock_outline,
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
                        'Confidentialité et sécurité',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vos informations personnelles sont protégées et ne sont partagées '
                        'qu’avec les professionnels de santé autorisés.',
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

class _ProfileStatChip extends StatelessWidget {
  const _ProfileStatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.leftIcon,
    required this.leftLabel,
    required this.leftValue,
    required this.rightIcon,
    required this.rightLabel,
    required this.rightValue,
  });

  final IconData? leftIcon;
  final String leftLabel;
  final String leftValue;
  final IconData? rightIcon;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ProfileInfoItem(
            icon: leftIcon,
            label: leftLabel,
            value: leftValue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: rightIcon == null && rightLabel.isEmpty && rightValue.isEmpty
              ? const SizedBox.shrink()
              : _ProfileInfoItem(
                  icon: rightIcon,
                  label: rightLabel,
                  value: rightValue,
                ),
        ),
      ],
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData? icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
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
              color: const Color(0xFF4B5CF6),
            ),
          ),
        if (icon != null) const SizedBox(width: 10),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

