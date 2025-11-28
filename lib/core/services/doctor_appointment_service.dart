import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/patient.dart';
import '../domain/rendez_vous.dart';

/// Service pour gérer les rendez-vous du côté médecin
abstract class DoctorAppointmentService {
  /// Récupère tous les rendez-vous d'un médecin
  Future<List<RendezVous>> getDoctorAppointments(
    String medecinId, {
    DateTime? startDate,
    DateTime? endDate,
    RendezVousStatus? status,
  });

  /// Récupère les rendez-vous du jour pour un médecin
  Future<List<RendezVous>> getDaySchedule(String medecinId, DateTime date);

  /// Récupère les rendez-vous de la semaine pour un médecin
  Future<List<RendezVous>> getWeekSchedule(String medecinId, DateTime weekStart);

  /// Récupère les détails d'un rendez-vous avec les infos du patient
  Future<RendezVous> getAppointmentDetails(String appointmentId);

  /// Confirme un rendez-vous
  Future<RendezVous> confirmAppointment(String appointmentId);

  /// Annule un rendez-vous
  Future<RendezVous> cancelAppointment(String appointmentId);

  /// Marque un rendez-vous comme terminé
  Future<RendezVous> completeAppointment(String appointmentId);

  /// Marque un rendez-vous comme absent
  Future<RendezVous> markAbsent(String appointmentId);

  /// Met à jour les notes du médecin
  Future<RendezVous> updateAppointmentNotes(String appointmentId, String notes);

  /// Modifie un rendez-vous (date/heure, durée)
  Future<RendezVous> updateAppointment({
    required String appointmentId,
    DateTime? dateTime,
    int? duree,
  });
}

/// Implémentation Supabase de DoctorAppointmentService
class SupabaseDoctorAppointmentService implements DoctorAppointmentService {
  SupabaseDoctorAppointmentService(this._client);

  final SupabaseClient _client;

  static const String _rendezVousTable = 'rendez_vous';

  @override
  Future<List<RendezVous>> getDoctorAppointments(
    String medecinId, {
    DateTime? startDate,
    DateTime? endDate,
    RendezVousStatus? status,
  }) async {
    try {
      var query = _client
          .from(_rendezVousTable)
          .select('''
            *,
            patient:patient_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil
            )
          ''')
          .eq('medecin_utilisateur_id', medecinId);

      if (startDate != null) {
        query = query.gte('date_heure', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('date_heure', endDate.toIso8601String());
      }
      if (status != null) {
        query = query.eq('statut', status.value);
      }

      final response = await query.order('date_heure', ascending: false);

      return (response as List)
          .map((data) => _mapToRendezVousWithPatient(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching doctor appointments: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  @override
  Future<List<RendezVous>> getDaySchedule(String medecinId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getDoctorAppointments(
        medecinId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching day schedule: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  @override
  Future<List<RendezVous>> getWeekSchedule(String medecinId, DateTime weekStart) async {
    try {
      final endOfWeek = weekStart.add(const Duration(days: 7));

      return await getDoctorAppointments(
        medecinId,
        startDate: weekStart,
        endDate: endOfWeek,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching week schedule: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  @override
  Future<RendezVous> getAppointmentDetails(String appointmentId) async {
    try {
      final response = await _client
          .from(_rendezVousTable)
          .select('''
            *,
            patient:patient_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil,
              date_naissance
            )
          ''')
          .eq('id', appointmentId)
          .single();

      return _mapToRendezVousWithPatient(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching appointment details: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  @override
  Future<RendezVous> confirmAppointment(String appointmentId) async {
    return await _updateAppointmentStatus(appointmentId, RendezVousStatus.confirme);
  }

  @override
  Future<RendezVous> cancelAppointment(String appointmentId) async {
    return await _updateAppointmentStatus(appointmentId, RendezVousStatus.annule);
  }

  @override
  Future<RendezVous> completeAppointment(String appointmentId) async {
    return await _updateAppointmentStatus(appointmentId, RendezVousStatus.termine);
  }

  @override
  Future<RendezVous> markAbsent(String appointmentId) async {
    return await _updateAppointmentStatus(appointmentId, RendezVousStatus.absent);
  }

  @override
  Future<RendezVous> updateAppointmentNotes(String appointmentId, String notes) async {
    try {
      final response = await _client
          .from(_rendezVousTable)
          .update({'notes_medecin': notes})
          .eq('id', appointmentId)
          .select('''
            *,
            patient:patient_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil
            )
          ''')
          .single();

      return _mapToRendezVousWithPatient(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error updating appointment notes: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  @override
  Future<RendezVous> updateAppointment({
    required String appointmentId,
    DateTime? dateTime,
    int? duree,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (dateTime != null) {
        updates['date_heure'] = dateTime.toIso8601String();
      }
      if (duree != null) {
        updates['duree'] = duree;
      }

      final response = await _client
          .from(_rendezVousTable)
          .update(updates)
          .eq('id', appointmentId)
          .select('''
            *,
            patient:patient_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil
            )
          ''')
          .single();

      return _mapToRendezVousWithPatient(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error updating appointment: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  Future<RendezVous> _updateAppointmentStatus(
    String appointmentId,
    RendezVousStatus status,
  ) async {
    try {
      final response = await _client
          .from(_rendezVousTable)
          .update({'statut': status.value})
          .eq('id', appointmentId)
          .select('''
            *,
            patient:patient_utilisateur_id(
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil
            )
          ''')
          .single();

      return _mapToRendezVousWithPatient(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error updating appointment status: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorAppointmentService',
      );
      rethrow;
    }
  }

  RendezVous _mapToRendezVousWithPatient(Map<String, dynamic> data) {
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

    // Extraire les infos du patient
    Patient? patient;
    final patientData = data['patient'];
    if (patientData != null && patientData is Map) {
      final patientMap = Map<String, dynamic>.from(patientData);
      
      DateTime? birthDate;
      final dateNaissanceValue = patientMap['date_naissance'];
      if (dateNaissanceValue != null) {
        if (dateNaissanceValue is String) {
          birthDate = DateTime.tryParse(dateNaissanceValue);
        } else if (dateNaissanceValue is DateTime) {
          birthDate = dateNaissanceValue;
        }
      }

      patient = Patient(
        id: patientMap['id']?.toString() ?? '',
        firstName: patientMap['prenom']?.toString() ?? '',
        lastName: patientMap['nom']?.toString() ?? '',
        email: patientMap['email']?.toString() ?? '',
        phoneNumber: patientMap['telephone']?.toString() ?? '',
        birthDate: birthDate,
        avatarUrl: patientMap['photo_profil']?.toString(),
      );
    }

    return RendezVous(
      id: data['id']?.toString() ?? '',
      patientId: data['patient_utilisateur_id']?.toString() ?? '',
      medecinId: data['medecin_utilisateur_id']?.toString() ?? '',
      dateTime: dateTime,
      status: statut,
      patient: patient,
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
}

/// Provider pour DoctorAppointmentService
final doctorAppointmentServiceProvider =
    Provider<DoctorAppointmentService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorAppointmentService(client);
});

