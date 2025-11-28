import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/disponibilite.dart';
import '../domain/medecin.dart';
import '../domain/rendez_vous.dart';
import 'doctor_search_service.dart';

/// Contract for all appointment-related operations.
abstract class AppointmentService {
  Future<List<Medecin>> searchMedecins({
    String? name,
    String? speciality,
    String? centre,
  });

  Future<List<Disponibilite>> getDisponibilitesForMedecin(String medecinId);

  Future<RendezVous> createRendezVous({
    required String patientId,
    required String medecinId,
    required DateTime dateTime,
    String? motif,
    String? notes,
    String? centreMedicalId,
  });

  Future<RendezVous> modifyRendezVous({
    required String rendezVousId,
    required DateTime newDateTime,
    String? newMedecinId,
  });

  Future<void> cancelRendezVous(String rendezVousId);

  Future<List<RendezVous>> getUpcomingRendezVous(String patientId);

  Future<List<RendezVous>> getPastRendezVous(String patientId);

  Future<List<RendezVous>> getAllPatientAppointments(String patientId);
}

/// Provider pour DoctorSearchService
final doctorSearchServiceProvider = Provider<DoctorSearchService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorSearchService(client);
});

/// Implémentation Supabase de AppointmentService
class SupabaseAppointmentService implements AppointmentService {
  SupabaseAppointmentService(
    this._doctorSearchService,
    this._client,
  );

  final DoctorSearchService _doctorSearchService;
  final SupabaseClient _client;

  static const String _rendezVousTable = 'rendez_vous';

  @override
  Future<List<Medecin>> searchMedecins({
    String? name,
    String? speciality,
    String? centre,
  }) async {
    // Utiliser le service de recherche de médecins
    // Note: speciality est le nom de la spécialité, pas l'ID
    // Pour l'instant, on recherche par nom uniquement
    // TODO: Améliorer pour rechercher par nom de spécialité
    return await _doctorSearchService.searchDoctors(
      name: name,
      centreId: centre,
    );
  }

  @override
  Future<List<Disponibilite>> getDisponibilitesForMedecin(String medecinId) {
    // TODO: Implémenter la récupération des disponibilités
    throw UnimplementedError('getDisponibilitesForMedecin not implemented yet');
  }

  @override
  Future<RendezVous> createRendezVous({
    required String patientId,
    required String medecinId,
    required DateTime dateTime,
    String? motif,
    String? notes,
    String? centreMedicalId,
  }) async {
    return await _createRendezVousImpl(
      patientId: patientId,
      medecinId: medecinId,
      dateTime: dateTime,
      motif: motif,
      notes: notes,
      centreMedicalId: centreMedicalId,
    );
  }

  Future<RendezVous> _createRendezVousImpl({
    required String patientId,
    required String medecinId,
    required DateTime dateTime,
    String? motif,
    String? notes,
    String? centreMedicalId,
  }) async {
    try {
      // Vérifier l'utilisateur connecté
      final currentUser = _client.auth.currentUser;
      developer.log(
        'Creating appointment: patientId=$patientId, medecinId=$medecinId, dateTime=$dateTime',
        name: 'SupabaseAppointmentService',
      );
      developer.log(
        'Current auth user: ${currentUser?.id}, email: ${currentUser?.email}',
        name: 'SupabaseAppointmentService',
      );
      
      // Vérifier que le patientId correspond à l'utilisateur connecté
      final patientCheck = await _client
          .from('utilisateurs')
          .select('id, user_id, role')
          .eq('id', patientId)
          .maybeSingle();
      
      developer.log(
        'Patient check: $patientCheck',
        name: 'SupabaseAppointmentService',
      );
      
      if (patientCheck == null) {
        throw Exception('Patient non trouvé avec l\'ID: $patientId');
      }
      
      if (patientCheck['user_id'] != currentUser?.id) {
        developer.log(
          'WARNING: patientId user_id (${patientCheck['user_id']}) != currentUser.id (${currentUser?.id})',
          name: 'SupabaseAppointmentService',
        );
      }

      // Convertir le centreMedicalId en UUID si nécessaire
      String? centreId;
      if (centreMedicalId != null && centreMedicalId.isNotEmpty) {
        centreId = centreMedicalId;
      }

      // Insérer le rendez-vous dans la table rendez_vous
      final response = await _client.from(_rendezVousTable).insert({
        'patient_utilisateur_id': patientId,
        'medecin_utilisateur_id': medecinId,
        'date_heure': dateTime.toIso8601String(),
        'duree': 30, // Durée par défaut de 30 minutes
        'statut': 'en_attente',
        'motif_consultation': motif,
        'notes_patient': notes,
        if (centreId != null) 'centre_medical_id': centreId,
      }).select().single();

      developer.log(
        'Appointment created: ${response['id']}',
        name: 'SupabaseAppointmentService',
      );

      // Convertir la réponse en objet RendezVous
      return _mapToRendezVous(Map<String, dynamic>.from(response));
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error during appointment creation: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAppointmentService',
      );
      
      // Message d'erreur plus détaillé pour les erreurs 403
      if (error.code == '42501' || error.message.contains('403') || error.message.contains('permission')) {
        throw Exception(
          'Erreur de permissions (403): Vous n\'avez pas les droits pour créer ce rendez-vous. '
          'Vérifiez que vous êtes bien connecté et que votre compte patient est correctement configuré. '
          'Détails: ${error.message}',
        );
      }
      
      throw Exception(
        'Erreur lors de la création du rendez-vous: ${error.message}',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during appointment creation: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAppointmentService',
      );
      throw Exception(
        'Erreur inattendue lors de la création du rendez-vous: ${error.toString()}',
      );
    }
  }

  /// Convertit les données de la table rendez_vous en objet RendezVous
  RendezVous _mapToRendezVous(Map<String, dynamic> data) {
    // Parser la date
    final dateTimeValue = data['date_heure'];
    DateTime dateTime;
    if (dateTimeValue is String) {
      dateTime = DateTime.parse(dateTimeValue);
    } else if (dateTimeValue is DateTime) {
      dateTime = dateTimeValue;
    } else {
      throw Exception('Date invalide dans les données du rendez-vous');
    }

    // Parser le statut
    final statutValue = data['statut'] as String? ?? 'en_attente';
    final statut = RendezVousStatus.fromString(statutValue);

    // Parser le montant
    double? montant;
    final montantValue = data['montant'];
    if (montantValue != null) {
      if (montantValue is num) {
        montant = montantValue.toDouble();
      } else if (montantValue is String) {
        montant = double.tryParse(montantValue);
      }
    }

    // Parser les dates created_at et updated_at
    DateTime? createdAt;
    DateTime? updatedAt;
    if (data['created_at'] != null) {
      final createdAtValue = data['created_at'];
      if (createdAtValue is String) {
        createdAt = DateTime.tryParse(createdAtValue);
      } else if (createdAtValue is DateTime) {
        createdAt = createdAtValue;
      }
    }
    if (data['updated_at'] != null) {
      final updatedAtValue = data['updated_at'];
      if (updatedAtValue is String) {
        updatedAt = DateTime.tryParse(updatedAtValue);
      } else if (updatedAtValue is DateTime) {
        updatedAt = updatedAtValue;
      }
    }

    return RendezVous(
      id: data['id']?.toString() ?? '',
      patientId: data['patient_utilisateur_id']?.toString() ?? '',
      medecinId: data['medecin_utilisateur_id']?.toString() ?? '',
      dateTime: dateTime,
      status: statut,
      centreMedicalId: data['centre_medical_id']?.toString(),
      duree: data['duree'] as int?,
      motifConsultation: data['motif_consultation']?.toString(),
      notesPatient: data['notes_patient']?.toString(),
      notesMedecin: data['notes_medecin']?.toString(),
      montant: montant,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<RendezVous> modifyRendezVous({
    required String rendezVousId,
    required DateTime newDateTime,
    String? newMedecinId,
  }) {
    // TODO: Implémenter la modification de rendez-vous
    throw UnimplementedError('modifyRendezVous not implemented yet');
  }

  @override
  Future<void> cancelRendezVous(String rendezVousId) {
    // TODO: Implémenter l'annulation de rendez-vous
    throw UnimplementedError('cancelRendezVous not implemented yet');
  }

  @override
  Future<List<RendezVous>> getUpcomingRendezVous(String patientId) async {
    try {
      final now = DateTime.now().toUtc();
      
      final response = await _client
          .from(_rendezVousTable)
          .select()
          .eq('patient_utilisateur_id', patientId)
          .gte('date_heure', now.toIso8601String())
          .order('date_heure', ascending: true);

      developer.log(
        'Found ${response.length} upcoming appointments for patient $patientId',
        name: 'SupabaseAppointmentService',
      );

      return (response as List)
          .map((data) => _mapToRendezVous(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching upcoming appointments: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAppointmentService',
      );
      rethrow;
    }
  }

  @override
  Future<List<RendezVous>> getPastRendezVous(String patientId) async {
    try {
      final now = DateTime.now().toUtc();
      
      final response = await _client
          .from(_rendezVousTable)
          .select()
          .eq('patient_utilisateur_id', patientId)
          .lt('date_heure', now.toIso8601String())
          .order('date_heure', ascending: false);

      developer.log(
        'Found ${response.length} past appointments for patient $patientId',
        name: 'SupabaseAppointmentService',
      );

      return (response as List)
          .map((data) => _mapToRendezVous(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching past appointments: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAppointmentService',
      );
      rethrow;
    }
  }

  /// Récupère tous les rendez-vous d'un patient (pour les filtres)
  /// Inclut les informations du médecin via un JOIN
  Future<List<RendezVous>> getAllPatientAppointments(String patientId) async {
    try {
      // Requête avec JOIN pour récupérer les infos du médecin
      final response = await _client
          .from(_rendezVousTable)
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
          .order('date_heure', ascending: false);

      developer.log(
        'Found ${response.length} total appointments for patient $patientId',
        name: 'SupabaseAppointmentService',
      );

      return (response as List)
          .map((data) => _mapToRendezVousWithMedecin(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching all appointments: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAppointmentService',
      );
      rethrow;
    }
  }

  /// Convertit les données avec les infos du médecin
  RendezVous _mapToRendezVousWithMedecin(Map<String, dynamic> data) {
    final rendezVous = _mapToRendezVous(data);
    
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
        id: medecinMap['id']?.toString() ?? rendezVous.medecinId,
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
    
    return rendezVous.copyWith(medecin: medecin);
  }
}

/// Provider pour AppointmentService
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final doctorSearchService = ref.watch(doctorSearchServiceProvider);
  final client = Supabase.instance.client;
  return SupabaseAppointmentService(doctorSearchService, client);
});



