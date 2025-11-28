import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/reference_data_service.dart';
import '../application/doctor_profile_controller.dart';

class EditDoctorProfileScreen extends ConsumerStatefulWidget {
  const EditDoctorProfileScreen({super.key});

  static const routeName = 'edit-doctor-profile';
  static const routePath = '/doctor/edit-profile';

  @override
  ConsumerState<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState
    extends ConsumerState<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _numeroOrdreController;
  late TextEditingController _tarifController;
  late TextEditingController _bioController;
  late TextEditingController _anneesExperienceController;
  late TextEditingController _languesParleesController;

  String? _selectedSpecialiteId;
  String? _selectedCentreMedicalId;
  bool _accepteNouveauxPatients = true;

  List<Specialite> _specialites = [];
  List<CentreMedical> _centresMedicaux = [];
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    final profileState = ref.read(doctorProfileControllerProvider);
    final doctor = profileState.doctor;

    _firstNameController = TextEditingController(text: doctor?.firstName ?? '');
    _lastNameController = TextEditingController(text: doctor?.lastName ?? '');
    _emailController = TextEditingController(text: doctor?.email ?? '');
    _phoneController = TextEditingController(text: doctor?.telephone ?? '');
    _numeroOrdreController = TextEditingController(text: doctor?.numeroOrdre ?? '');
    _tarifController = TextEditingController(
      text: doctor?.tarif != null ? doctor!.tarif!.toStringAsFixed(2) : '',
    );
    _bioController = TextEditingController(text: doctor?.bio ?? '');
    _anneesExperienceController = TextEditingController(
      text: doctor?.anneesExperience?.toString() ?? '',
    );
    _languesParleesController = TextEditingController(
      text: doctor?.languesParlees?.join(', ') ?? '',
    );
    _selectedSpecialiteId = doctor?.specialiteId;
    _selectedCentreMedicalId = doctor?.centreMedicalId;
    _accepteNouveauxPatients = doctor?.accepteNouveauxPatients ?? true;

    // Charger les données de référence
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    try {
      final service = ref.read(referenceDataServiceProvider);
      final specialites = await service.getSpecialites();
      final centres = await service.getCentresMedicaux();

      setState(() {
        _specialites = specialites;
        _centresMedicaux = centres;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _numeroOrdreController.dispose();
    _tarifController.dispose();
    _bioController.dispose();
    _anneesExperienceController.dispose();
    _languesParleesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updates = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'numeroOrdre': _numeroOrdreController.text.trim().isEmpty
          ? null
          : _numeroOrdreController.text.trim(),
      'tarifConsultation': _tarifController.text.trim().isEmpty
          ? null
          : double.tryParse(_tarifController.text.trim().replaceAll(',', '.')),
      'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      'anneesExperience': _anneesExperienceController.text.trim().isEmpty
          ? null
          : int.tryParse(_anneesExperienceController.text.trim()),
      'languesParlees': _languesParleesController.text.trim().isEmpty
          ? null
          : _languesParleesController.text
              .trim()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      'specialiteId': _selectedSpecialiteId,
      'centreMedicalId': _selectedCentreMedicalId,
      'accepteNouveauxPatients': _accepteNouveauxPatients,
    };

    try {
      await ref.read(doctorProfileControllerProvider.notifier).updateProfile(updates);

      if (mounted) {
        final state = ref.read(doctorProfileControllerProvider);
        if (state.status == DoctorProfileStatus.success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == DoctorProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${state.errorMessage ?? "Erreur inconnue"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    final profileState = ref.watch(doctorProfileControllerProvider);

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le profil'),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations personnelles
            const Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le prénom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est requis';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le téléphone est requis';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Informations professionnelles
            const Text(
              'Informations professionnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Spécialité
            DropdownButtonFormField<String>(
              value: _selectedSpecialiteId,
              decoration: const InputDecoration(
                labelText: 'Spécialité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: _specialites.map((specialite) {
                return DropdownMenuItem<String>(
                  value: specialite.id,
                  child: Text(specialite.nom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecialiteId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La spécialité est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Centre médical
            DropdownButtonFormField<String>(
              value: _selectedCentreMedicalId,
              decoration: const InputDecoration(
                labelText: 'Centre médical',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Aucun'),
                ),
                ..._centresMedicaux.map((centre) {
                  return DropdownMenuItem<String>(
                    value: centre.id,
                    child: Text(centre.nom),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCentreMedicalId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _numeroOrdreController,
              decoration: const InputDecoration(
                labelText: 'Numéro d\'ordre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tarifController,
              decoration: const InputDecoration(
                labelText: 'Tarif consultation (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final tarif = double.tryParse(value.trim().replaceAll(',', '.'));
                  if (tarif == null || tarif < 0) {
                    return 'Tarif invalide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _anneesExperienceController,
              decoration: const InputDecoration(
                labelText: 'Années d\'expérience',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_outline),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final annees = int.tryParse(value.trim());
                  if (annees == null || annees < 0) {
                    return 'Nombre d\'années invalide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _languesParleesController,
              decoration: const InputDecoration(
                labelText: 'Langues parlées (séparées par des virgules)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language_outlined),
                helperText: 'Ex: Français, Anglais, Espagnol',
              ),
            ),
            const SizedBox(height: 16),

            // Accepte nouveaux patients
            SwitchListTile(
              title: const Text('Accepte nouveaux patients'),
              subtitle: const Text('Autoriser les nouveaux patients à prendre rendez-vous'),
              value: _accepteNouveauxPatients,
              onChanged: (value) {
                setState(() {
                  _accepteNouveauxPatients = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // Biographie
            const Text(
              'Biographie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Biographie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 32),

            // Bouton de sauvegarde
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: profileState.status == DoctorProfileStatus.updating
                    ? null
                    : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: profileState.status == DoctorProfileStatus.updating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Enregistrer les modifications',
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

