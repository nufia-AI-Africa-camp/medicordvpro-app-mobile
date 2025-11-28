import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/medecin.dart';

/// Service pour gérer le profil médecin
abstract class DoctorProfileService {
  Future<Medecin> getDoctorProfile(String medecinId);
  
  Future<Medecin> updateDoctorProfile(
    String medecinId,
    Map<String, dynamic> updates,
  );
  
  /// Récupère le profil du médecin connecté
  Future<Medecin?> getCurrentDoctorProfile();
}

/// Implémentation Supabase de DoctorProfileService
class SupabaseDoctorProfileService implements DoctorProfileService {
  SupabaseDoctorProfileService(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'utilisateurs';
  static const String _viewName = 'v_medecins';

  @override
  Future<Medecin> getDoctorProfile(String medecinId) async {
    try {
      final response = await _client
          .from(_viewName)
          .select()
          .eq('id', medecinId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Profil médecin non trouvé');
      }

      return _mapToMedecin(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching doctor profile: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorProfileService',
      );
      rethrow;
    }
  }

  @override
  Future<Medecin?> getCurrentDoctorProfile() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final response = await _client
          .from(_viewName)
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapToMedecin(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching current doctor profile: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorProfileService',
      );
      return null;
    }
  }

  @override
  Future<Medecin> updateDoctorProfile(
    String medecinId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Préparer les mises à jour (mapping des noms de champs)
      final Map<String, dynamic> dbUpdates = {};
      
      if (updates.containsKey('firstName')) {
        dbUpdates['prenom'] = updates['firstName'];
      }
      if (updates.containsKey('lastName')) {
        dbUpdates['nom'] = updates['lastName'];
      }
      if (updates.containsKey('email')) {
        dbUpdates['email'] = updates['email'];
      }
      if (updates.containsKey('phoneNumber')) {
        dbUpdates['telephone'] = updates['phoneNumber'];
      }
      if (updates.containsKey('avatarUrl')) {
        dbUpdates['photo_profil'] = updates['avatarUrl'];
      }
      if (updates.containsKey('specialiteId')) {
        dbUpdates['specialite_id'] = updates['specialiteId'];
      }
      if (updates.containsKey('centreMedicalId')) {
        dbUpdates['centre_medical_id'] = updates['centreMedicalId'];
      }
      if (updates.containsKey('numeroOrdre')) {
        dbUpdates['numero_ordre'] = updates['numeroOrdre'];
      }
      if (updates.containsKey('tarifConsultation')) {
        dbUpdates['tarif_consultation'] = updates['tarifConsultation'];
      }
      if (updates.containsKey('bio')) {
        dbUpdates['bio'] = updates['bio'];
      }
      if (updates.containsKey('anneesExperience')) {
        dbUpdates['annees_experience'] = updates['anneesExperience'];
      }
      if (updates.containsKey('languesParlees')) {
        dbUpdates['langues_parlees'] = updates['languesParlees'];
      }
      if (updates.containsKey('accepteNouveauxPatients')) {
        dbUpdates['accepte_nouveaux_patients'] = updates['accepteNouveauxPatients'];
      }

      await _client
          .from(_tableName)
          .update(dbUpdates)
          .eq('id', medecinId);

      developer.log(
        'Doctor profile updated successfully',
        name: 'SupabaseDoctorProfileService',
      );

      // Récupérer le profil mis à jour via la vue
      return await getDoctorProfile(medecinId);
    } catch (error, stackTrace) {
      developer.log(
        'Error updating doctor profile: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorProfileService',
      );
      rethrow;
    }
  }

  /// Convertit les données de la vue v_medecins en objet Medecin
  Medecin _mapToMedecin(Map<String, dynamic> data) {
    // Parser le tarif
    double? tarif;
    final tarifValue = data['tarif_consultation'];
    if (tarifValue != null) {
      if (tarifValue is num) {
        tarif = tarifValue.toDouble();
      } else if (tarifValue is String) {
        tarif = double.tryParse(tarifValue);
      }
    }

    // Parser les langues parlées
    List<String>? languesParlees;
    final languesValue = data['langues_parlees'];
    if (languesValue != null && languesValue is List) {
      languesParlees = languesValue.map((e) => e.toString()).toList();
    }

    return Medecin(
      id: data['id']?.toString() ?? '',
      firstName: data['prenom']?.toString() ?? '',
      lastName: data['nom']?.toString() ?? '',
      speciality: data['specialite_nom']?.toString() ?? 'Médecin',
      centre: data['centre_medical_id']?.toString() ?? '',
      address: data['centre_medical_adresse']?.toString() ?? '',
      tarif: tarif,
      specialiteId: data['specialite_id']?.toString(),
      specialiteDescription: data['specialite_description']?.toString(),
      centreMedicalId: data['centre_medical_id']?.toString(),
      centreMedicalNom: data['centre_medical_nom']?.toString(),
      centreMedicalAdresse: data['centre_medical_adresse']?.toString(),
      centreMedicalVille: data['centre_medical_ville']?.toString(),
      centreMedicalTelephone: data['centre_medical_telephone']?.toString(),
      email: data['email']?.toString(),
      telephone: data['telephone']?.toString(),
      photoProfil: data['photo_profil']?.toString(),
      numeroOrdre: data['numero_ordre']?.toString(),
      bio: data['bio']?.toString(),
      anneesExperience: data['annees_experience'] as int?,
      languesParlees: languesParlees,
      accepteNouveauxPatients: data['accepte_nouveaux_patients'] as bool?,
    );
  }
}

/// Provider pour DoctorProfileService
final doctorProfileServiceProvider =
    Provider<DoctorProfileService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorProfileService(client);
});

