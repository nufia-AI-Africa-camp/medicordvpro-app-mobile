import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour un horaire de médecin
class DoctorSchedule {
  const DoctorSchedule({
    required this.id,
    required this.medecinId,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    required this.dureeConsultation,
    required this.isAvailable,
    this.createdAt,
  });

  final String id;
  final String medecinId;
  final String jour; // lundi, mardi, etc.
  final String heureDebut; // Format HH:mm
  final String heureFin; // Format HH:mm
  final int dureeConsultation; // en minutes
  final bool isAvailable;
  final DateTime? createdAt;

  DoctorSchedule copyWith({
    String? id,
    String? medecinId,
    String? jour,
    String? heureDebut,
    String? heureFin,
    int? dureeConsultation,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return DoctorSchedule(
      id: id ?? this.id,
      medecinId: medecinId ?? this.medecinId,
      jour: jour ?? this.jour,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      dureeConsultation: dureeConsultation ?? this.dureeConsultation,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Service pour gérer les horaires des médecins
abstract class DoctorScheduleService {
  Future<List<DoctorSchedule>> getDoctorSchedules(String medecinId);
  
  Future<DoctorSchedule> createSchedule(DoctorSchedule schedule);
  
  Future<DoctorSchedule> updateSchedule(String scheduleId, DoctorSchedule schedule);
  
  Future<void> deleteSchedule(String scheduleId);
  
  Future<DoctorSchedule> toggleScheduleAvailability(String scheduleId, bool isAvailable);
}

/// Implémentation Supabase de DoctorScheduleService
class SupabaseDoctorScheduleService implements DoctorScheduleService {
  SupabaseDoctorScheduleService(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'horaires_medecins';

  @override
  Future<List<DoctorSchedule>> getDoctorSchedules(String medecinId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('medecin_utilisateur_id', medecinId)
          .order('jour')
          .order('heure_debut');

      return (response as List)
          .map((data) => _mapToSchedule(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching doctor schedules: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorScheduleService',
      );
      rethrow;
    }
  }

  @override
  Future<DoctorSchedule> createSchedule(DoctorSchedule schedule) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert({
            'medecin_utilisateur_id': schedule.medecinId,
            'jour': schedule.jour,
            'heure_debut': schedule.heureDebut,
            'heure_fin': schedule.heureFin,
            'duree_consultation': schedule.dureeConsultation,
            'is_available': schedule.isAvailable,
          })
          .select()
          .single();

      return _mapToSchedule(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error creating schedule: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorScheduleService',
      );
      rethrow;
    }
  }

  @override
  Future<DoctorSchedule> updateSchedule(String scheduleId, DoctorSchedule schedule) async {
    try {
      final response = await _client
          .from(_tableName)
          .update({
            'jour': schedule.jour,
            'heure_debut': schedule.heureDebut,
            'heure_fin': schedule.heureFin,
            'duree_consultation': schedule.dureeConsultation,
            'is_available': schedule.isAvailable,
          })
          .eq('id', scheduleId)
          .select()
          .single();

      return _mapToSchedule(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error updating schedule: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorScheduleService',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', scheduleId);
    } catch (error, stackTrace) {
      developer.log(
        'Error deleting schedule: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorScheduleService',
      );
      rethrow;
    }
  }

  @override
  Future<DoctorSchedule> toggleScheduleAvailability(String scheduleId, bool isAvailable) async {
    try {
      final response = await _client
          .from(_tableName)
          .update({'is_available': isAvailable})
          .eq('id', scheduleId)
          .select()
          .single();

      return _mapToSchedule(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error toggling schedule availability: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorScheduleService',
      );
      rethrow;
    }
  }

  DoctorSchedule _mapToSchedule(Map<String, dynamic> data) {
    // Parser l'heure de début et fin (format TIME de PostgreSQL)
    String heureDebut = '';
    String heureFin = '';
    
    // Fonction pour normaliser le format d'heure (HH:MM:SS -> HH:MM)
    String normalizeTime(dynamic timeValue) {
      if (timeValue == null) return '';
      
      if (timeValue is String) {
        // Si c'est au format HH:MM:SS, prendre seulement HH:MM
        if (timeValue.contains(':') && timeValue.split(':').length >= 2) {
          final parts = timeValue.split(':');
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
        return timeValue;
      } else if (timeValue is DateTime) {
        return '${timeValue.hour.toString().padLeft(2, '0')}:${timeValue.minute.toString().padLeft(2, '0')}';
      }
      return '';
    }
    
    final heureDebutValue = data['heure_debut'];
    heureDebut = normalizeTime(heureDebutValue);
    
    final heureFinValue = data['heure_fin'];
    heureFin = normalizeTime(heureFinValue);

    DateTime? createdAt;
    final createdAtValue = data['created_at'];
    if (createdAtValue != null) {
      if (createdAtValue is String) {
        createdAt = DateTime.tryParse(createdAtValue);
      } else if (createdAtValue is DateTime) {
        createdAt = createdAtValue;
      }
    }

    return DoctorSchedule(
      id: data['id']?.toString() ?? '',
      medecinId: data['medecin_utilisateur_id']?.toString() ?? '',
      jour: data['jour']?.toString() ?? '',
      heureDebut: heureDebut,
      heureFin: heureFin,
      dureeConsultation: data['duree_consultation'] as int? ?? 30,
      isAvailable: data['is_available'] as bool? ?? true,
      createdAt: createdAt,
    );
  }
}

/// Provider pour DoctorScheduleService
final doctorScheduleServiceProvider =
    Provider<DoctorScheduleService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorScheduleService(client);
});

