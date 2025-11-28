import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour une spécialité
class Specialite {
  const Specialite({
    required this.id,
    required this.nom,
    this.description,
    this.icone,
  });

  final String id;
  final String nom;
  final String? description;
  final String? icone;
}

/// Modèle pour un centre médical
class CentreMedical {
  const CentreMedical({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.ville,
    this.codePostal,
    this.telephone,
    this.email,
  });

  final String id;
  final String nom;
  final String adresse;
  final String ville;
  final String? codePostal;
  final String? telephone;
  final String? email;
}

/// Service pour récupérer les données de référence (spécialités, centres médicaux)
abstract class ReferenceDataService {
  Future<List<Specialite>> getSpecialites();
  Future<List<CentreMedical>> getCentresMedicaux();
}

/// Implémentation Supabase de ReferenceDataService
class SupabaseReferenceDataService implements ReferenceDataService {
  SupabaseReferenceDataService(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Specialite>> getSpecialites() async {
    try {
      final response = await _client
          .from('specialites')
          .select()
          .order('nom');

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((data) => Specialite(
                id: data['id']?.toString() ?? '',
                nom: data['nom']?.toString() ?? '',
                description: data['description']?.toString(),
                icone: data['icone']?.toString(),
              ))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching specialites: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseReferenceDataService',
      );
      rethrow;
    }
  }

  @override
  Future<List<CentreMedical>> getCentresMedicaux() async {
    try {
      final response = await _client
          .from('centres_medicaux')
          .select()
          .order('nom');

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((data) => CentreMedical(
                id: data['id']?.toString() ?? '',
                nom: data['nom']?.toString() ?? '',
                adresse: data['adresse']?.toString() ?? '',
                ville: data['ville']?.toString() ?? '',
                codePostal: data['code_postal']?.toString(),
                telephone: data['telephone']?.toString(),
                email: data['email']?.toString(),
              ))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Error fetching centres medicaux: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseReferenceDataService',
      );
      rethrow;
    }
  }
}

/// Provider pour ReferenceDataService
final referenceDataServiceProvider =
    Provider<ReferenceDataService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseReferenceDataService(client);
});

