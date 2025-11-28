import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  static const routeName = 'edit-profile';
  static const routePath = '/edit-profile';

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    final patient = authState.patient;
    
    _firstNameController = TextEditingController(text: patient?.firstName ?? '');
    _lastNameController = TextEditingController(text: patient?.lastName ?? '');
    _emailController = TextEditingController(text: patient?.email ?? '');
    _phoneController = TextEditingController(text: patient?.phoneNumber ?? '');
    _addressController = TextEditingController(text: patient?.address ?? '');
    _cityController = TextEditingController(text: patient?.city ?? '');
    _postalCodeController = TextEditingController(text: patient?.postalCode ?? '');
    _selectedBirthDate = patient?.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    final patientId = authState.patient?.id;
    if (patientId == null) return;

    final updates = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'postalCode': _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
      'birthDate': _selectedBirthDate,
    };

    final controller = ref.read(profileControllerProvider(patientId).notifier);
    await controller.updateProfile(updates);

    if (mounted) {
      final state = ref.read(profileControllerProvider(patientId));
      if (state.status == ProfileStatus.success) {
        // Rafraîchir le profil dans auth
        // TODO: Rafraîchir authController si nécessaire
        
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state.status == ProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${state.errorMessage ?? "Erreur inconnue"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    final authState = ref.watch(authControllerProvider);
    final patientId = authState.patient?.id;
    
    if (patientId == null) {
      return const Scaffold(
        body: Center(child: Text('Patient non connecté')),
      );
    }

    final profileState = ref.watch(profileControllerProvider(patientId));

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
            const SizedBox(height: 16),
            
            // Date de naissance
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day.toString().padLeft(2, '0')}/'
                          '${_selectedBirthDate!.month.toString().padLeft(2, '0')}/'
                          '${_selectedBirthDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _selectedBirthDate != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Adresse
            const Text(
              'Adresse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Code postal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Bouton de sauvegarde
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: profileState.status == ProfileStatus.updating
                    ? null
                    : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: profileState.status == ProfileStatus.updating
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

