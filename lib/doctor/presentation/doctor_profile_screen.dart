import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../application/doctor_profile_controller.dart';
import 'edit_doctor_profile_screen.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  static const routeName = 'doctor-profile';
  static const routePath = '/doctor/profile';
  static const subRoutePath = 'profile';

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Charger le profil au montage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorProfileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FF);
    const primaryBlue = Color(0xFF1D5BFF);
    const secondaryBlue = Color(0xFF3B82F6);

    final profileState = ref.watch(doctorProfileControllerProvider);
    final doctor = profileState.doctor;

    if (profileState.status == DoctorProfileStatus.loading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Mon profil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (doctor == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Mon profil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                profileState.errorMessage ?? 'Profil non trouvé',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(doctorProfileControllerProvider.notifier).loadProfile();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final fullName = doctor.fullName;
    final email = doctor.email ?? 'Email non renseigné';
    final phone = doctor.telephone ?? 'Téléphone non renseigné';
    final speciality = doctor.speciality;
    final centre = doctor.centreMedicalNom ?? 'Non renseigné';
    final tarif = doctor.tarif != null
        ? '${doctor.tarif!.toStringAsFixed(2)} €'
        : 'Non renseigné';
    final anneesExperience = doctor.anneesExperience != null
        ? '${doctor.anneesExperience} ans'
        : 'Non renseigné';
    final numeroOrdre = doctor.numeroOrdre ?? 'Non renseigné';
    final bio = doctor.bio ?? 'Aucune biographie';
    final languesParlees = doctor.languesParlees?.join(', ') ?? 'Non renseigné';
    final accepteNouveauxPatients = doctor.accepteNouveauxPatients ?? true;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mon profil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(doctorProfileControllerProvider.notifier).loadProfile();
        },
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
                        child: doctor.photoProfil != null
                            ? ClipOval(
                                child: Image.network(
                                  doctor.photoProfil!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
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
                              speciality,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
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
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute<bool>(
                              builder: (_) => const EditDoctorProfileScreen(),
                            ),
                          );
                          if (result == true) {
                            // Rafraîchir le profil après modification
                            await ref
                                .read(doctorProfileControllerProvider.notifier)
                                .loadProfile();
                          }
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Carte informations professionnelles
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
                      'Informations professionnelles',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _ProfileInfoRow(
                      leftIcon: Icons.medical_services_outlined,
                      leftLabel: 'Spécialité',
                      leftValue: speciality,
                      rightIcon: Icons.location_on_outlined,
                      rightLabel: 'Centre médical',
                      rightValue: centre,
                    ),
                    const SizedBox(height: 16),

                    _ProfileInfoRow(
                      leftIcon: Icons.badge_outlined,
                      leftLabel: 'Numéro d\'ordre',
                      leftValue: numeroOrdre,
                      rightIcon: Icons.euro_outlined,
                      rightLabel: 'Tarif consultation',
                      rightValue: tarif,
                    ),
                    const SizedBox(height: 16),

                    _ProfileInfoRow(
                      leftIcon: Icons.work_outline,
                      leftLabel: 'Années d\'expérience',
                      leftValue: anneesExperience,
                      rightIcon: Icons.people_outline,
                      rightLabel: 'Nouveaux patients',
                      rightValue: accepteNouveauxPatients ? 'Oui' : 'Non',
                    ),
                    const SizedBox(height: 16),

                    _ProfileInfoRow(
                      leftIcon: Icons.language_outlined,
                      leftLabel: 'Langues parlées',
                      leftValue: languesParlees,
                      rightIcon: null,
                      rightLabel: '',
                      rightValue: '',
                    ),
                  ],
                ),
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

                    _ProfileInfoRow(
                      leftIcon: Icons.person_outline,
                      leftLabel: 'Nom complet',
                      leftValue: fullName,
                      rightIcon: Icons.phone_outlined,
                      rightLabel: 'Téléphone',
                      rightValue: phone,
                    ),
                    const SizedBox(height: 16),

                    _ProfileInfoRow(
                      leftIcon: Icons.email_outlined,
                      leftLabel: 'Email',
                      leftValue: email,
                      rightIcon: null,
                      rightLabel: '',
                      rightValue: '',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Carte biographie
            if (bio.isNotEmpty)
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
                        'Biographie',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          'Vos informations professionnelles sont protégées et ne sont partagées '
                          'qu\'avec les patients autorisés.',
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

            const SizedBox(height: 20),

            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Afficher une boîte de dialogue de confirmation
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?',
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
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    try {
                      await ref.read(authControllerProvider.notifier).logout();
                      // Le router redirigera automatiquement vers la page de login
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout_outlined),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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

