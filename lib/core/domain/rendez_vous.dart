import 'medecin.dart';
import 'patient.dart';

/// Statut du rendez-vous correspondant à l'enum SQL appointment_status
enum RendezVousStatus {
  enAttente('en_attente'),
  confirme('confirmé'),
  annule('annulé'),
  termine('terminé'),
  absent('absent');

  const RendezVousStatus(this.value);
  final String value;

  static RendezVousStatus fromString(String value) {
    return RendezVousStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RendezVousStatus.enAttente,
    );
  }
}

/// Modèle RendezVous correspondant à la table rendez_vous de Supabase
class RendezVous {
  const RendezVous({
    required this.id,
    required this.patientId,
    required this.medecinId,
    required this.dateTime,
    required this.status,
    this.patient,
    this.medecin,
    this.centreMedicalId,
    this.duree,
    this.motifConsultation,
    this.notesPatient,
    this.notesMedecin,
    this.montant,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String medecinId;
  final DateTime dateTime;
  final RendezVousStatus status;
  
  // Relations (optionnelles, chargées séparément)
  final Patient? patient;
  final Medecin? medecin;
  
  // Champs supplémentaires de la table rendez_vous
  final String? centreMedicalId;
  final int? duree; // en minutes
  final String? motifConsultation;
  final String? notesPatient;
  final String? notesMedecin;
  final double? montant;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Crée une copie avec des valeurs modifiées
  RendezVous copyWith({
    String? id,
    String? patientId,
    String? medecinId,
    DateTime? dateTime,
    RendezVousStatus? status,
    Patient? patient,
    Medecin? medecin,
    String? centreMedicalId,
    int? duree,
    String? motifConsultation,
    String? notesPatient,
    String? notesMedecin,
    double? montant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RendezVous(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      medecinId: medecinId ?? this.medecinId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      patient: patient ?? this.patient,
      medecin: medecin ?? this.medecin,
      centreMedicalId: centreMedicalId ?? this.centreMedicalId,
      duree: duree ?? this.duree,
      motifConsultation: motifConsultation ?? this.motifConsultation,
      notesPatient: notesPatient ?? this.notesPatient,
      notesMedecin: notesMedecin ?? this.notesMedecin,
      montant: montant ?? this.montant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


