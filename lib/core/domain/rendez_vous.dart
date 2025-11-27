import 'medecin.dart';
import 'patient.dart';

enum RendezVousStatus { pending, confirmed, cancelled, completed }

class RendezVous {
  const RendezVous({
    required this.id,
    required this.patient,
    required this.medecin,
    required this.dateTime,
    required this.status,
    this.type,
    this.notesFromMedecin,
  });

  final String id;
  final Patient patient;
  final Medecin medecin;
  final DateTime dateTime;
  final RendezVousStatus status;
  final String? type;
  final String? notesFromMedecin;
}


