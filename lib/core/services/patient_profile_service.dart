import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/patient.dart';

/// Service pour gérer le profil patient
abstract class PatientProfileService {
  Future<Patient> getPatientProfile(String patientId);
  
  Future<Patient> updatePatientProfile(
    String patientId,
    Map<String, dynamic> updates,
  );
}

/// Implémentation Supabase de PatientProfileService
class SupabasePatientProfileService implements PatientProfileService {
  SupabasePatientProfileService(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'utilisateurs';

  @override
  Future<Patient> getPatientProfile(String patientId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', patientId)
          .eq('role', 'patient')
          .maybeSingle();

      if (response == null) {
        throw Exception('Profil patient non trouvé');
      }

      return _mapToPatient(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching patient profile: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabasePatientProfileService',
      );
      rethrow;
    }
  }

  @override
  Future<Patient> updatePatientProfile(
    String patientId,
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
        // Note: Si l'email change, il faudrait aussi mettre à jour auth.users
        // Pour l'instant, on met juste à jour la table utilisateurs
      }
      if (updates.containsKey('phoneNumber')) {
        dbUpdates['telephone'] = updates['phoneNumber'];
      }
      if (updates.containsKey('birthDate')) {
        final birthDate = updates['birthDate'] as DateTime?;
        dbUpdates['date_naissance'] = birthDate?.toIso8601String().split('T')[0];
      }
      if (updates.containsKey('avatarUrl')) {
        dbUpdates['photo_profil'] = updates['avatarUrl'];
      }
      if (updates.containsKey('address')) {
        dbUpdates['adresse'] = updates['address'];
      }
      if (updates.containsKey('city')) {
        dbUpdates['ville'] = updates['city'];
      }
      if (updates.containsKey('postalCode')) {
        dbUpdates['code_postal'] = updates['postalCode'];
      }

      final response = await _client
          .from(_tableName)
          .update(dbUpdates)
          .eq('id', patientId)
          .select()
          .single();

      developer.log(
        'Patient profile updated successfully',
        name: 'SupabasePatientProfileService',
      );

      return _mapToPatient(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error updating patient profile: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabasePatientProfileService',
      );
      rethrow;
    }
  }

  /// Convertit les données de la table utilisateurs en objet Patient
  Patient _mapToPatient(Map<String, dynamic> data) {
    // Parser la date de naissance
    DateTime? birthDate;
    final dateNaissanceValue = data['date_naissance'];
    if (dateNaissanceValue != null) {
      if (dateNaissanceValue is String) {
        birthDate = DateTime.tryParse(dateNaissanceValue);
      } else if (dateNaissanceValue is DateTime) {
        birthDate = dateNaissanceValue;
      }
    }

    return Patient(
      id: data['id']?.toString() ?? '',
      firstName: data['prenom']?.toString() ?? '',
      lastName: data['nom']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['telephone']?.toString() ?? '',
      birthDate: birthDate,
      avatarUrl: data['photo_profil']?.toString(),
      address: data['adresse']?.toString(),
      city: data['ville']?.toString(),
      postalCode: data['code_postal']?.toString(),
    );
  }
}

/// Provider pour PatientProfileService
final patientProfileServiceProvider =
    Provider<PatientProfileService>((ref) {
  final client = Supabase.instance.client;
  return SupabasePatientProfileService(client);
});

