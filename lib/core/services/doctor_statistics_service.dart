import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour les statistiques d'un médecin
class DoctorStatistics {
  const DoctorStatistics({
    required this.totalAppointments,
    required this.confirmedAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.uniquePatients,
    required this.totalRevenue,
    this.thisWeekAppointments = 0,
    this.thisMonthAppointments = 0,
    this.cancellationRate = 0.0,
  });

  final int totalAppointments;
  final int confirmedAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int uniquePatients;
  final double totalRevenue;
  final int thisWeekAppointments;
  final int thisMonthAppointments;
  final double cancellationRate;

  /// Taux de complétion (terminés / total)
  double get completionRate {
    if (totalAppointments == 0) return 0.0;
    return (completedAppointments / totalAppointments) * 100;
  }

  /// Revenu moyen par patient
  double get averageRevenuePerPatient {
    if (uniquePatients == 0) return 0.0;
    return totalRevenue / uniquePatients;
  }
}

/// Service pour gérer les statistiques des médecins
abstract class DoctorStatisticsService {
  Future<DoctorStatistics> getDoctorStatistics(
    String medecinId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Implémentation Supabase de DoctorStatisticsService
class SupabaseDoctorStatisticsService implements DoctorStatisticsService {
  SupabaseDoctorStatisticsService(this._client);

  final SupabaseClient _client;

  static const String _rendezVousTable = 'rendez_vous';

  @override
  Future<DoctorStatistics> getDoctorStatistics(
    String medecinId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from(_rendezVousTable)
          .select('statut, montant, patient_utilisateur_id, date_heure')
          .eq('medecin_utilisateur_id', medecinId);

      if (startDate != null) {
        query = query.gte('date_heure', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('date_heure', endDate.toIso8601String());
      }

      final response = await query;

      final appointments = (response as List)
          .map((data) => Map<String, dynamic>.from(data))
          .toList();

      // Calculer les statistiques
      int total = appointments.length;
      int confirmed = 0;
      int completed = 0;
      int cancelled = 0;
      double revenue = 0.0;
      final Set<String> uniquePatientIds = {};

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      int thisWeek = 0;
      int thisMonth = 0;

      for (final appointment in appointments) {
        final statut = appointment['statut']?.toString() ?? 'en_attente';
        
        if (statut == 'confirmé') {
          confirmed++;
        } else if (statut == 'terminé') {
          completed++;
        } else if (statut == 'annulé') {
          cancelled++;
        }

        // Revenu
        final montantValue = appointment['montant'];
        if (montantValue != null) {
          if (montantValue is num) {
            revenue += montantValue.toDouble();
          } else if (montantValue is String) {
            revenue += double.tryParse(montantValue) ?? 0.0;
          }
        }

        // Patients uniques
        final patientId = appointment['patient_utilisateur_id']?.toString();
        if (patientId != null) {
          uniquePatientIds.add(patientId);
        }

        // Cette semaine / ce mois
        final dateHeureValue = appointment['date_heure'];
        if (dateHeureValue != null) {
          DateTime? dateHeure;
          if (dateHeureValue is String) {
            dateHeure = DateTime.tryParse(dateHeureValue);
          } else if (dateHeureValue is DateTime) {
            dateHeure = dateHeureValue;
          }

          if (dateHeure != null) {
            if (dateHeure.isAfter(startOfWeek)) {
              thisWeek++;
            }
            if (dateHeure.isAfter(startOfMonth)) {
              thisMonth++;
            }
          }
        }
      }

      final cancellationRate = total > 0 ? (cancelled / total) * 100 : 0.0;

      return DoctorStatistics(
        totalAppointments: total,
        confirmedAppointments: confirmed,
        completedAppointments: completed,
        cancelledAppointments: cancelled,
        uniquePatients: uniquePatientIds.length,
        totalRevenue: revenue,
        thisWeekAppointments: thisWeek,
        thisMonthAppointments: thisMonth,
        cancellationRate: cancellationRate,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching doctor statistics: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorStatisticsService',
      );
      rethrow;
    }
  }
}

/// Provider pour DoctorStatisticsService
final doctorStatisticsServiceProvider =
    Provider<DoctorStatisticsService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDoctorStatisticsService(client);
});

