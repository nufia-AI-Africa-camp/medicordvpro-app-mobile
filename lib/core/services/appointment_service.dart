import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/disponibilite.dart';
import '../domain/medecin.dart';
import '../domain/rendez_vous.dart';

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
    String? type,
  });

  Future<RendezVous> modifyRendezVous({
    required String rendezVousId,
    required DateTime newDateTime,
    String? newMedecinId,
  });

  Future<void> cancelRendezVous(String rendezVousId);

  Future<List<RendezVous>> getUpcomingRendezVous(String patientId);

  Future<List<RendezVous>> getPastRendezVous(String patientId);
}

/// Temporary provider and mock implementation for early development.
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  // Replace with a real implementation when the backend is ready.
  throw UnimplementedError('AppointmentService not implemented yet');
});



