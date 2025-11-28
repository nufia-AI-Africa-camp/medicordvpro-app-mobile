/// Modèle Médecin correspondant à la vue v_medecins de Supabase
class Medecin {
  const Medecin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.centre,
    required this.address,
    this.tarif,
    this.specialiteId,
    this.specialiteDescription,
    this.centreMedicalId,
    this.centreMedicalNom,
    this.centreMedicalAdresse,
    this.centreMedicalVille,
    this.centreMedicalTelephone,
    this.email,
    this.telephone,
    this.photoProfil,
    this.numeroOrdre,
    this.bio,
    this.anneesExperience,
    this.languesParlees,
    this.accepteNouveauxPatients,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String speciality;
  final String centre;
  final String address;
  final double? tarif;
  
  // Champs supplémentaires de la vue v_medecins
  final String? specialiteId;
  final String? specialiteDescription;
  final String? centreMedicalId;
  final String? centreMedicalNom;
  final String? centreMedicalAdresse;
  final String? centreMedicalVille;
  final String? centreMedicalTelephone;
  final String? email;
  final String? telephone;
  final String? photoProfil;
  final String? numeroOrdre;
  final String? bio;
  final int? anneesExperience;
  final List<String>? languesParlees;
  final bool? accepteNouveauxPatients;

  /// Nom complet du médecin
  String get fullName => '$firstName $lastName';
  
  /// Adresse complète du centre médical
  String get fullAddress {
    if (centreMedicalAdresse != null && centreMedicalVille != null) {
      return '$centreMedicalAdresse, $centreMedicalVille';
    }
    return address;
  }
}


