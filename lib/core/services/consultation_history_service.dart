import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/consultation_history.dart';
import '../domain/medecin.dart';

/// Service pour gérer l'historique des consultations
abstract class ConsultationHistoryService {
  Future<List<ConsultationHistory>> getPatientMedicalHistory(String patientId);
  
  Future<List<ConsultationHistory>> getHistoryWithDoctor(
    String patientId,
    String medecinId,
  );
  
  Future<ConsultationHistory?> getConsultationDetails(String historyId);
}

/// Implémentation Supabase de ConsultationHistoryService
class SupabaseConsultationHistoryService implements ConsultationHistoryService {
  SupabaseConsultationHistoryService(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'historique_consultations';

  @override
  Future<List<ConsultationHistory>> getPatientMedicalHistory(
    String patientId,
  ) async {
    try {
      // Requête avec JOIN pour récupérer les infos du médecin
      final response = await _client
          .from(_tableName)
          .select('''
            *,
            medecin:medecin_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil,
              specialite_id,
              specialites:specialite_id(nom)
            )
          ''')
          .eq('patient_utilisateur_id', patientId)
          .order('date_consultation', ascending: false);

      developer.log(
        'Found ${response.length} consultation histories for patient $patientId',
        name: 'SupabaseConsultationHistoryService',
      );

      return (response as List)
          .map((data) => _mapToConsultationHistory(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching consultation history: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseConsultationHistoryService',
      );
      rethrow;
    }
  }

  @override
  Future<List<ConsultationHistory>> getHistoryWithDoctor(
    String patientId,
    String medecinId,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('''
            *,
            medecin:medecin_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil,
              specialite_id,
              specialites:specialite_id(nom)
            )
          ''')
          .eq('patient_utilisateur_id', patientId)
          .eq('medecin_utilisateur_id', medecinId)
          .order('date_consultation', ascending: false);

      return (response as List)
          .map((data) => _mapToConsultationHistory(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching consultation history with doctor: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseConsultationHistoryService',
      );
      rethrow;
    }
  }

  @override
  Future<ConsultationHistory?> getConsultationDetails(String historyId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('''
            *,
            medecin:medecin_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil,
              specialite_id,
              specialites:specialite_id(nom)
            )
          ''')
          .eq('id', historyId)
          .maybeSingle();

      if (response == null) return null;

      return _mapToConsultationHistory(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching consultation details: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseConsultationHistoryService',
      );
      rethrow;
    }
  }

  /// Convertit les données de la table historique_consultations en objet ConsultationHistory
  ConsultationHistory _mapToConsultationHistory(Map<String, dynamic> data) {
    // Parser la date
    final dateValue = data['date_consultation'];
    DateTime dateConsultation;
    if (dateValue is String) {
      dateConsultation = DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      dateConsultation = dateValue;
    } else {
      throw Exception('Date invalide dans les données de consultation');
    }

    // Parser created_at
    DateTime? createdAt;
    if (data['created_at'] != null) {
      final createdAtValue = data['created_at'];
      if (createdAtValue is String) {
        createdAt = DateTime.tryParse(createdAtValue);
      } else if (createdAtValue is DateTime) {
        createdAt = createdAtValue;
      }
    }

    // Extraire les infos du médecin si présentes
    final medecinData = data['medecin'];
    Medecin? medecin;
    
    if (medecinData != null && medecinData is Map) {
      final medecinMap = Map<String, dynamic>.from(medecinData);
      final specialiteData = medecinMap['specialites'];
      final specialiteNom = specialiteData != null && specialiteData is Map
          ? specialiteData['nom']?.toString() ?? 'Médecin'
          : 'Médecin';
      
      medecin = Medecin(
        id: medecinMap['id']?.toString() ?? '',
        firstName: medecinMap['prenom']?.toString() ?? '',
        lastName: medecinMap['nom']?.toString() ?? '',
        speciality: specialiteNom,
        centre: medecinMap['centre_medical_id']?.toString() ?? '',
        address: '',
        email: medecinMap['email']?.toString(),
        telephone: medecinMap['telephone']?.toString(),
        photoProfil: medecinMap['photo_profil']?.toString(),
        specialiteId: medecinMap['specialite_id']?.toString(),
      );
    }

    // Parser documents_joints (array)
    List<String>? documentsJoints;
    final documentsValue = data['documents_joints'];
    if (documentsValue != null) {
      if (documentsValue is List) {
        documentsJoints = documentsValue
            .map((e) => e?.toString())
            .whereType<String>()
            .toList();
      }
    }

    return ConsultationHistory(
      id: data['id']?.toString() ?? '',
      rendezVousId: data['rendez_vous_id']?.toString() ?? '',
      patientId: data['patient_utilisateur_id']?.toString() ?? '',
      medecinId: data['medecin_utilisateur_id']?.toString() ?? '',
      dateConsultation: dateConsultation,
      medecin: medecin,
      diagnostic: data['diagnostic']?.toString(),
      traitement: data['traitement']?.toString(),
      ordonnance: data['ordonnance']?.toString(),
      notes: data['notes']?.toString(),
      documentsJoints: documentsJoints,
      createdAt: createdAt,
    );
  }
}

/// Provider pour ConsultationHistoryService
final consultationHistoryServiceProvider =
    Provider<ConsultationHistoryService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseConsultationHistoryService(client);
});

