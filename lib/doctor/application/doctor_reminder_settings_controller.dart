import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/doctor_reminder_settings_service.dart';

enum ReminderSettingsStatus {
  idle,
  loading,
  success,
  saving,
  error,
}

class DoctorReminderSettingsState {
  const DoctorReminderSettingsState({
    this.settings,
    this.status = ReminderSettingsStatus.idle,
    this.errorMessage,
  });

  final DoctorReminderSettings? settings;
  final ReminderSettingsStatus status;
  final String? errorMessage;

  DoctorReminderSettingsState copyWith({
    DoctorReminderSettings? settings,
    ReminderSettingsStatus? status,
    String? errorMessage,
  }) {
    return DoctorReminderSettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static const initial = DoctorReminderSettingsState();
}

class DoctorReminderSettingsController
    extends StateNotifier<DoctorReminderSettingsState> {
  DoctorReminderSettingsController(this._service)
      : super(DoctorReminderSettingsState.initial);

  final DoctorReminderSettingsService _service;

  /// Charge les préférences de rappels pour un médecin
  Future<void> loadSettings(String medecinId) async {
    state = state.copyWith(status: ReminderSettingsStatus.loading);
    try {
      var settings = await _service.getReminderSettings(medecinId);

      // Si aucune préférence n'existe, créer des préférences par défaut
      if (settings == null) {
        settings = DoctorReminderSettings(
          medecinId: medecinId,
          enabled: true,
          smsEnabled: true,
          emailEnabled: true,
          reminderHoursBefore: 24,
        );
        settings = await _service.createReminderSettings(settings);
      }

      state = state.copyWith(
        settings: settings,
        status: ReminderSettingsStatus.success,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: ReminderSettingsStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Met à jour les préférences de rappels
  Future<void> updateSettings(DoctorReminderSettings settings) async {
    state = state.copyWith(status: ReminderSettingsStatus.saving);
    try {
      final updated = await _service.updateReminderSettings(settings);
      state = state.copyWith(
        settings: updated,
        status: ReminderSettingsStatus.success,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: ReminderSettingsStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  /// Met à jour une seule propriété
  Future<void> updateProperty({
    required String medecinId,
    bool? enabled,
    bool? smsEnabled,
    bool? emailEnabled,
    int? reminderHoursBefore,
  }) async {
    final currentSettings = state.settings;
    if (currentSettings == null) {
      await loadSettings(medecinId);
      return;
    }

    final updated = currentSettings.copyWith(
      enabled: enabled,
      smsEnabled: smsEnabled,
      emailEnabled: emailEnabled,
      reminderHoursBefore: reminderHoursBefore,
    );

    await updateSettings(updated);
  }
}

/// Provider pour le controller de préférences de rappels
final doctorReminderSettingsControllerProvider =
    StateNotifierProvider<DoctorReminderSettingsController,
        DoctorReminderSettingsState>((ref) {
  final service = ref.watch(doctorReminderSettingsServiceProvider);
  return DoctorReminderSettingsController(service);
});

