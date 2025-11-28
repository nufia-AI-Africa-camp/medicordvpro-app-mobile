import 'medecin.dart';

/// Modèle ConsultationHistory correspondant à la table historique_consultations de Supabase
class ConsultationHistory {
  const ConsultationHistory({
    required this.id,
    required this.rendezVousId,
    required this.patientId,
    required this.medecinId,
    required this.dateConsultation,
    this.medecin,
    this.diagnostic,
    this.traitement,
    this.ordonnance,
    this.notes,
    this.documentsJoints,
    this.createdAt,
  });

  final String id;
  final String rendezVousId;
  final String patientId;
  final String medecinId;
  final DateTime dateConsultation;
  
  // Relations (optionnelles, chargées séparément)
  final Medecin? medecin;
  
  // Champs de la consultation
  final String? diagnostic;
  final String? traitement;
  final String? ordonnance;
  final String? notes;
  final List<String>? documentsJoints; // URLs des documents
  final DateTime? createdAt;

  /// Crée une copie avec des valeurs modifiées
  ConsultationHistory copyWith({
    String? id,
    String? rendezVousId,
    String? patientId,
    String? medecinId,
    DateTime? dateConsultation,
    Medecin? medecin,
    String? diagnostic,
    String? traitement,
    String? ordonnance,
    String? notes,
    List<String>? documentsJoints,
    DateTime? createdAt,
  }) {
    return ConsultationHistory(
      id: id ?? this.id,
      rendezVousId: rendezVousId ?? this.rendezVousId,
      patientId: patientId ?? this.patientId,
      medecinId: medecinId ?? this.medecinId,
      dateConsultation: dateConsultation ?? this.dateConsultation,
      medecin: medecin ?? this.medecin,
      diagnostic: diagnostic ?? this.diagnostic,
      traitement: traitement ?? this.traitement,
      ordonnance: ordonnance ?? this.ordonnance,
      notes: notes ?? this.notes,
      documentsJoints: documentsJoints ?? this.documentsJoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

