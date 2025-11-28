import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour les préférences de rappels d'un médecin
class DoctorReminderSettings {
  const DoctorReminderSettings({
    required this.medecinId,
    this.enabled = true,
    this.smsEnabled = true,
    this.emailEnabled = true,
    this.reminderHoursBefore = 24,
    this.createdAt,
    this.updatedAt,
  });

  final String medecinId;
  final bool enabled;
  final bool smsEnabled;
  final bool emailEnabled;
  final int reminderHoursBefore; // Nombre d'heures avant le RDV
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorReminderSettings copyWith({
    String? medecinId,
    bool? enabled,
    bool? smsEnabled,
    bool? emailEnabled,
    int? reminderHoursBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorReminderSettings(
      medecinId: medecinId ?? this.medecinId,
      enabled: enabled ?? this.enabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      reminderHoursBefore: reminderHoursBefore ?? this.reminderHoursBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Service pour gérer les préférences de rappels des médecins
abstract class DoctorReminderSettingsService {
  Future<DoctorReminderSettings?> getReminderSettings(String medecinId);
  Future<DoctorReminderSettings> updateReminderSettings(
    DoctorReminderSettings settings,
  );
  Future<DoctorReminderSettings> createReminderSettings(
    DoctorReminderSettings settings,
  );
}

/// Implémentation Supabase de DoctorReminderSettingsService
class SupabaseDoctorReminderSettingsService
    implements DoctorReminderSettingsService {
  SupabaseDoctorReminderSettingsService(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'medecin_rappels_settings';

  @override
  Future<DoctorReminderSettings?> getReminderSettings(
    String medecinId,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('medecin_utilisateur_id', medecinId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapToSettings(Map<String, dynamic>.from(response));
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching reminder settings: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorReminderSettingsService',
      );
      rethrow;
    }
  }

  @override
  Future<DoctorReminderSettings> updateReminderSettings(
    DoctorReminderSettings settings,
  ) async {
    try {
      await _client
          .from(_tableName)
          .update({
            'enabled': settings.enabled,
            'sms_enabled': settings.smsEnabled,
            'email_enabled': settings.emailEnabled,
            'reminder_hours_before': settings.reminderHoursBefore,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('medecin_utilisateur_id', settings.medecinId);

      // Récupérer les settings mis à jour
      final updated = await getReminderSettings(settings.medecinId);
      if (updated == null) {
        throw Exception('Failed to retrieve updated settings');
      }
      return updated;
    } catch (error, stackTrace) {
      developer.log(
        'Error updating reminder settings: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorReminderSettingsService',
      );
      rethrow;
    }
  }

  @override
  Future<DoctorReminderSettings> createReminderSettings(
    DoctorReminderSettings settings,
  ) async {
    try {
      await _client.from(_tableName).insert({
        'medecin_utilisateur_id': settings.medecinId,
        'enabled': settings.enabled,
        'sms_enabled': settings.smsEnabled,
        'email_enabled': settings.emailEnabled,
        'reminder_hours_before': settings.reminderHoursBefore,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Récupérer les settings créés
      final created = await getReminderSettings(settings.medecinId);
      if (created == null) {
        throw Exception('Failed to retrieve created settings');
      }
      return created;
    } catch (error, stackTrace) {
      developer.log(
        'Error creating reminder settings: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorReminderSettingsService',
      );
      rethrow;
    }
  }

  DoctorReminderSettings _mapToSettings(Map<String, dynamic> data) {
    return DoctorReminderSettings(
      medecinId: data['medecin_utilisateur_id']?.toString() ?? '',
      enabled: data['enabled'] as bool? ?? true,
      smsEnabled: data['sms_enabled'] as bool? ?? true,
      emailEnabled: data['email_enabled'] as bool? ?? true,
      reminderHoursBefore: data['reminder_hours_before'] as int? ?? 24,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'].toString())
          : null,
    );
  }
}

/// Provider pour DoctorReminderSettingsService
final doctorReminderSettingsServiceProvider =
    Provider<DoctorReminderSettingsService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorReminderSettingsService(client);
});

