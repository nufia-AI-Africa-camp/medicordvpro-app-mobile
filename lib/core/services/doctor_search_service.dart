import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/medecin.dart';

/// Exception pour les erreurs de recherche de médecins
class DoctorSearchException implements Exception {
  const DoctorSearchException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Service pour rechercher et récupérer des informations sur les médecins
abstract class DoctorSearchService {
  /// Recherche des médecins avec filtres optionnels
  /// Utilise la vue v_medecins pour simplifier les requêtes
  Future<List<Medecin>> searchDoctors({
    String? name,
    String? specialityId,
    String? centreId,
    String? ville,
  });

  /// Récupère les détails complets d'un médecin
  Future<Medecin?> getDoctorDetails(String medecinId);

  /// Récupère tous les médecins (pour liste complète)
  Future<List<Medecin>> getAllDoctors();
}

/// Implémentation Supabase du service de recherche de médecins
class SupabaseDoctorSearchService implements DoctorSearchService {
  SupabaseDoctorSearchService(this._client);

  final SupabaseClient _client;

  static const String _vMedecinsView = 'v_medecins';

  @override
  Future<List<Medecin>> searchDoctors({
    String? name,
    String? specialityId,
    String? centreId,
    String? ville,
  }) async {
    try {
      developer.log(
        'Searching doctors: name=$name, specialityId=$specialityId, centreId=$centreId, ville=$ville',
        name: 'SupabaseDoctorSearchService',
      );

      // Construire la requête sur la vue v_medecins
      var query = _client.from(_vMedecinsView).select();

      // Filtrer par nom/prénom (recherche insensible à la casse)
      if (name != null && name.isNotEmpty) {
        query = query.or('nom.ilike.%$name%,prenom.ilike.%$name%');
      }

      // Filtrer par spécialité
      if (specialityId != null && specialityId.isNotEmpty) {
        query = query.eq('specialite_id', specialityId);
      }

      // Filtrer par centre médical
      if (centreId != null && centreId.isNotEmpty) {
        query = query.eq('centre_medical_id', centreId);
      }

      // Filtrer par ville (via le centre médical)
      if (ville != null && ville.isNotEmpty) {
        query = query.ilike('centre_medical_ville', '%$ville%');
      }

      // Filtrer uniquement les médecins qui acceptent de nouveaux patients
      query = query.eq('accepte_nouveaux_patients', true);

      // Trier par nom
      final response = await query.order('nom', ascending: true);

      developer.log(
        'Found ${response.length} doctors',
        name: 'SupabaseDoctorSearchService',
      );

      return (response as List<dynamic>)
          .map((data) => _mapToMedecin(Map<String, dynamic>.from(data)))
          .toList();
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error during doctor search: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorSearchService',
      );
      throw DoctorSearchException(
        'Erreur lors de la recherche de médecins: ${error.message}',
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during doctor search: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorSearchService',
      );
      throw DoctorSearchException(
        'Erreur inattendue lors de la recherche: ${error.toString()}',
        error,
      );
    }
  }

  @override
  Future<Medecin?> getDoctorDetails(String medecinId) async {
    try {
      developer.log(
        'Fetching doctor details: $medecinId',
        name: 'SupabaseDoctorSearchService',
      );

      final response = await _client
          .from(_vMedecinsView)
          .select()
          .eq('id', medecinId)
          .maybeSingle();

      if (response == null) {
        developer.log(
          'Doctor not found: $medecinId',
          name: 'SupabaseDoctorSearchService',
        );
        return null;
      }

      return _mapToMedecin(Map<String, dynamic>.from(response as Map));
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error fetching doctor details: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorSearchService',
      );
      throw DoctorSearchException(
        'Erreur lors de la récupération des détails: ${error.message}',
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error fetching doctor details: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorSearchService',
      );
      throw DoctorSearchException(
        'Erreur inattendue: ${error.toString()}',
        error,
      );
    }
  }

  @override
  Future<List<Medecin>> getAllDoctors() async {
    try {
      developer.log(
        'Fetching all doctors',
        name: 'SupabaseDoctorSearchService',
      );

      final response = await _client
          .from(_vMedecinsView)
          .select()
          .eq('accepte_nouveaux_patients', true)
          .order('nom', ascending: true);

      return (response as List<dynamic>)
          .map((data) => _mapToMedecin(Map<String, dynamic>.from(data)))
          .toList();
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error fetching all doctors: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorSearchService',
      );
      throw DoctorSearchException(
        'Erreur lors de la récupération des médecins: ${error.message}',
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error fetching all doctors: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseDoctorSearchService',
      );
      throw DoctorSearchException(
        'Erreur inattendue: ${error.toString()}',
        error,
      );
    }
  }

  /// Convertit les données de la vue v_medecins en objet Medecin
  Medecin _mapToMedecin(Map<String, dynamic> data) {
    // Convertir le tarif (peut être null ou un nombre)
    double? tarif;
    final tarifValue = data['tarif_consultation'];
    if (tarifValue != null) {
      if (tarifValue is num) {
        tarif = tarifValue.toDouble();
      } else if (tarifValue is String) {
        tarif = double.tryParse(tarifValue);
      }
    }

    // Convertir langues_parlees (array PostgreSQL)
    List<String>? languesParlees;
    final languesValue = data['langues_parlees'];
    if (languesValue != null && languesValue is List) {
      languesParlees = languesValue
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Construire l'adresse (utiliser centre_medical_adresse si disponible, sinon adresse du médecin)
    final address = data['centre_medical_adresse'] as String? ??
        data['adresse'] as String? ??
        '';

    // Construire le nom du centre (utiliser centre_medical_nom si disponible)
    final centre = data['centre_medical_nom'] as String? ?? '';

    return Medecin(
      id: data['id']?.toString() ?? '',
      firstName: data['prenom']?.toString() ?? '',
      lastName: data['nom']?.toString() ?? '',
      speciality: data['specialite_nom']?.toString() ?? '',
      centre: centre,
      address: address,
      tarif: tarif,
      specialiteId: data['specialite_id']?.toString(),
      specialiteDescription: data['specialite_description']?.toString(),
      centreMedicalId: data['centre_medical_id']?.toString(),
      centreMedicalNom: data['centre_medical_nom']?.toString(),
      centreMedicalAdresse: data['centre_medical_adresse']?.toString(),
      centreMedicalVille: data['centre_medical_ville']?.toString(),
      centreMedicalTelephone: data['centre_medical_telephone']?.toString(),
      email: data['email']?.toString(),
      telephone: data['telephone']?.toString(),
      photoProfil: data['photo_profil']?.toString(),
      numeroOrdre: data['numero_ordre']?.toString(),
      bio: data['bio']?.toString(),
      anneesExperience: data['annees_experience'] as int?,
      languesParlees: languesParlees,
      accepteNouveauxPatients: data['accepte_nouveaux_patients'] as bool?,
    );
  }
}

