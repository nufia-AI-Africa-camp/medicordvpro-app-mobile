import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour une indisponibilité (pause ou congé)
class DoctorUnavailability {
  const DoctorUnavailability({
    required this.id,
    required this.medecinId,
    required this.dateDebut,
    required this.dateFin,
    this.raison,
    this.createdAt,
  });

  final String id;
  final String medecinId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? raison;
  final DateTime? createdAt;

  /// Vérifie si c'est une pause (durée < 24h) ou un congé (durée >= 24h)
  bool get isPause {
    final duration = dateFin.difference(dateDebut);
    return duration.inHours < 24;
  }

  /// Vérifie si c'est un congé (durée >= 24h)
  bool get isConges {
    return !isPause;
  }

  DoctorUnavailability copyWith({
    String? id,
    String? medecinId,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? raison,
    DateTime? createdAt,
  }) {
    return DoctorUnavailability(
      id: id ?? this.id,
      medecinId: medecinId ?? this.medecinId,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      raison: raison ?? this.raison,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Service pour gérer les indisponibilités (pauses et congés)
abstract class DoctorUnavailabilityService {
  Future<List<DoctorUnavailability>> getUnavailabilities(String medecinId);
  
  Future<List<DoctorUnavailability>> getPauses(String medecinId);
  
  Future<List<DoctorUnavailability>> getConges(String medecinId);
  
  Future<DoctorUnavailability> createUnavailability(DoctorUnavailability unavailability);
  
  Future<DoctorUnavailability> updateUnavailability(
    String unavailabilityId,
    DoctorUnavailability unavailability,
  );
  
  Future<void> deleteUnavailability(String unavailabilityId);
}

/// Implémentation Supabase de DoctorUnavailabilityService
class SupabaseDoctorUnavailabilityService implements DoctorUnavailabilityService {
  SupabaseDoctorUnavailabilityService(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'indisponibilites';

  @override
  Future<List<DoctorUnavailability>> getUnavailabilities(String medecinId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('medecin_utilisateur_id', medecinId)
          .order('date_debut', ascending: false);

      return (response as List)
          .map((data) => _mapToUnavailability(Map<String, dynamic>.from(data)))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching unavailabilities: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorUnavailabilityService',
      );
      rethrow;
    }
  }

  @override
  Future<List<DoctorUnavailability>> getPauses(String medecinId) async {
    final all = await getUnavailabilities(medecinId);
    return all.where((u) => u.isPause).toList();
  }

  @override
  Future<List<DoctorUnavailability>> getConges(String medecinId) async {
    final all = await getUnavailabilities(medecinId);
    return all.where((u) => u.isConges).toList();
  }

  @override
  Future<DoctorUnavailability> createUnavailability(
    DoctorUnavailability unavailability,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert({
            'medecin_utilisateur_id': unavailability.medecinId,
            'date_debut': unavailability.dateDebut.toIso8601String(),
            'date_fin': unavailability.dateFin.toIso8601String(),
            'raison': unavailability.raison,
          })
          .select()
          .single();

      return _mapToUnavailability(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error creating unavailability: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorUnavailabilityService',
      );
      rethrow;
    }
  }

  @override
  Future<DoctorUnavailability> updateUnavailability(
    String unavailabilityId,
    DoctorUnavailability unavailability,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .update({
            'date_debut': unavailability.dateDebut.toIso8601String(),
            'date_fin': unavailability.dateFin.toIso8601String(),
            'raison': unavailability.raison,
          })
          .eq('id', unavailabilityId)
          .select()
          .single();

      return _mapToUnavailability(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error updating unavailability: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorUnavailabilityService',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteUnavailability(String unavailabilityId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', unavailabilityId);
    } catch (error, stackTrace) {
      developer.log(
        'Error deleting unavailability: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorUnavailabilityService',
      );
      rethrow;
    }
  }

  DoctorUnavailability _mapToUnavailability(Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) throw Exception('Date manquante');
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      throw Exception('Format de date invalide');
    }

    DateTime? parseDateTimeOrNull(dynamic value) {
      if (value == null) return null;
      try {
        return parseDateTime(value);
      } catch (e) {
        return null;
      }
    }

    return DoctorUnavailability(
      id: data['id']?.toString() ?? '',
      medecinId: data['medecin_utilisateur_id']?.toString() ?? '',
      dateDebut: parseDateTime(data['date_debut']),
      dateFin: parseDateTime(data['date_fin']),
      raison: data['raison']?.toString(),
      createdAt: parseDateTimeOrNull(data['created_at']),
    );
  }
}

/// Provider pour DoctorUnavailabilityService
final doctorUnavailabilityServiceProvider =
    Provider<DoctorUnavailabilityService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorUnavailabilityService(client);
});

