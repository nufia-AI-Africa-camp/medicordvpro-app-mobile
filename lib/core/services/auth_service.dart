import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/patient.dart';
import '../domain/user_role.dart';

/// Exception utilisée pour remonter proprement les erreurs d'authentification.
class AuthFailure implements Exception {
  const AuthFailure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Résultat de la connexion avec détection automatique du rôle
class LoginResult {
  const LoginResult({
    required this.patient,
    required this.role,
  });

  final Patient patient;
  final UserRole role;
}

/// Contract for authentication operations.
abstract class AuthService {
  Future<Patient?> login({
    required String email,
    required String password,
    required UserRole role,
  });

  /// Connexion avec détection automatique du rôle
  Future<LoginResult?> loginAuto({
    required String email,
    required String password,
  });

  Future<Patient> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<void> logout();
}

/// Temporary in-memory implementation used during early development / MVP.
class MockAuthService implements AuthService {
  Patient? _current;

  static const String _patientEmail = 'patient@demo.fr';
  static const String _medecinEmail = 'medecin@demo.fr';
  static const String _demoPassword = 'demo1234';

  @override
  Future<Patient?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // In a real app, call the backend API here.
    // Ici on force deux comptes de démonstration uniquement.

    final isPatientCredentials =
        email == _patientEmail && password == _demoPassword;
    final isMedecinCredentials =
        email == _medecinEmail && password == _demoPassword;

    if (role == UserRole.medecin && isMedecinCredentials) {
      _current = Patient(
        id: 'mock-medecin',
        firstName: 'Dr. Sophie',
        lastName: 'Martin',
        email: email,
        phoneNumber: '06 12 34 56 78',
        birthDate: DateTime(1985, 5, 15),
        avatarUrl: null,
      );
    } else if (role == UserRole.patient && isPatientCredentials) {
      _current = Patient(
        id: 'mock-patient',
        firstName: 'Marie',
        lastName: 'Dubois',
        email: email,
        phoneNumber: '06 98 76 54 32',
        birthDate: DateTime(1990, 5, 15),
        avatarUrl: null,
      );
    } else {
      _current = null;
      return null;
    }
    return _current;
  }

  @override
  Future<LoginResult?> loginAuto({
    required String email,
    required String password,
  }) async {
    // Détection automatique du rôle basée sur l'email
    final isMedecinCredentials =
        email == _medecinEmail && password == _demoPassword;
    final isPatientCredentials =
        email == _patientEmail && password == _demoPassword;

    if (isMedecinCredentials) {
      _current = Patient(
        id: 'mock-medecin',
        firstName: 'Dr. Sophie',
        lastName: 'Martin',
        email: email,
        phoneNumber: '06 12 34 56 78',
        birthDate: DateTime(1985, 5, 15),
        avatarUrl: null,
      );
      return LoginResult(patient: _current!, role: UserRole.medecin);
    } else if (isPatientCredentials) {
      _current = Patient(
        id: 'mock-patient',
        firstName: 'Marie',
        lastName: 'Dubois',
        email: email,
        phoneNumber: '06 98 76 54 32',
        birthDate: DateTime(1990, 5, 15),
        avatarUrl: null,
      );
      return LoginResult(patient: _current!, role: UserRole.patient);
    }
    return null;
  }

  @override
  Future<Patient> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    // In a real app, call the backend API here.
    _current = Patient(
      id: 'mock-patient',
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      birthDate: null,
      avatarUrl: null,
    );
    return _current!;
  }

  @override
  Future<void> logout() async {
    _current = null;
  }
}

/// Implémentation réelle connectée à Supabase.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  static const _utilisateursTable = 'utilisateurs';

  @override
  Future<Patient?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;

      if (user == null) {
        throw const AuthFailure(
          "Impossible de récupérer l'utilisateur connecté.",
        );
      }

      // Récupérer le profil dans la table utilisateurs avec le rôle demandé
      final roleString = role == UserRole.medecin ? 'medecin' : 'patient';
      Map<String, dynamic>? profile = await _client
          .from(_utilisateursTable)
          .select()
          .eq('user_id', user.id)
          .eq('role', roleString)
          .maybeSingle();

      if (profile == null) {
        // Vérifier si l'utilisateur existe avec un autre rôle
        final existingProfile = await _client
            .from(_utilisateursTable)
            .select('role')
            .eq('user_id', user.id)
            .maybeSingle();

        if (existingProfile != null) {
          final existingRole = existingProfile['role'];
          throw AuthFailure(
            existingRole == 'medecin'
                ? 'Ce compte est enregistré en tant que médecin. Veuillez vous connecter avec le rôle Médecin.'
                : 'Ce compte est enregistré en tant que patient. Veuillez vous connecter avec le rôle Patient.',
          );
        }

        // Aucun profil trouvé
        throw const AuthFailure(
          'Aucun profil associé à ce compte. Veuillez créer un compte.',
        );
      }

      // Récupérer le rôle depuis la base de données pour confirmer
      final dbRole = profile['role'] as String?;
      if (dbRole != roleString) {
        throw AuthFailure(
          'Le rôle du compte ne correspond pas au rôle demandé.',
        );
      }

      return _mapProfileToPatient(profile, fallbackEmail: user.email ?? email);
    } on AuthException catch (error, stackTrace) {
      developer.log(
        'Auth error during login',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure(
        _messageOrFallback(error.message, 'Connexion impossible.'),
        error,
      );
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error during login',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure(
        _messageOrFallback(error.message, 'Erreur Supabase.'),
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during login',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure('Erreur de connexion inattendue.', error);
    }
  }

  @override
  Future<LoginResult?> loginAuto({
    required String email,
    required String password,
  }) async {
    try {
      // Authentification Supabase
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;

      if (user == null) {
        throw const AuthFailure(
          "Impossible de récupérer l'utilisateur connecté.",
        );
      }

      developer.log(
        'User authenticated: ${user.id}',
        name: 'SupabaseAuthService',
      );

      // Récupérer le profil dans la table utilisateurs (sans filtrer par rôle)
      Map<String, dynamic>? profile;
      try {
        profile = await _client
            .from(_utilisateursTable)
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
      } on PostgrestException catch (e, stackTrace) {
        developer.log(
          'Postgrest error when fetching profile: ${e.message}',
          error: e,
          stackTrace: stackTrace,
          name: 'SupabaseAuthService',
        );
        throw AuthFailure(
          'Erreur lors de la récupération du profil: ${e.message}',
          e,
        );
      }

      if (profile == null) {
        developer.log(
          'No profile found for user: ${user.id}',
          name: 'SupabaseAuthService',
        );
        throw const AuthFailure(
          'Aucun profil associé à ce compte. Veuillez créer un compte.',
        );
      }

      developer.log(
        'Profile found: role=${profile['role']}, id=${profile['id']}',
        name: 'SupabaseAuthService',
      );

      // Détecter le rôle depuis la base de données
      final dbRole = profile['role'] as String?;
      if (dbRole == null) {
        throw const AuthFailure(
          'Rôle non défini pour ce compte.',
        );
      }

      UserRole detectedRole;
      if (dbRole == 'medecin') {
        detectedRole = UserRole.medecin;
      } else if (dbRole == 'patient') {
        detectedRole = UserRole.patient;
      } else {
        throw AuthFailure(
          'Rôle non supporté: $dbRole',
        );
      }

      developer.log(
        'Role detected: $detectedRole',
        name: 'SupabaseAuthService',
      );

      final patient = _mapProfileToPatient(profile, fallbackEmail: user.email ?? email);
      return LoginResult(patient: patient, role: detectedRole);
    } on AuthException catch (error, stackTrace) {
      developer.log(
        'Auth error during loginAuto: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure(
        _messageOrFallback(error.message, 'Connexion impossible.'),
        error,
      );
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error during loginAuto: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure(
        'Erreur Supabase: ${error.message}',
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during loginAuto: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure(
        'Erreur de connexion inattendue: ${error.toString()}',
        error,
      );
    }
  }

  /// Inscription - Crée UNIQUEMENT des comptes patients
  /// Les médecins ne peuvent pas s'inscrire via cette méthode.
  /// Ils doivent être créés par un administrateur.
  @override
  Future<Patient> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Création du compte Supabase Auth - TOUJOURS en tant que patient
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'patient', // Rôle hardcodé : seuls les patients peuvent s'inscrire
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure("Impossible de créer l'utilisateur Supabase.");
      }

      developer.log(
        'User created in auth.users: ${user.id}, email: ${user.email}',
        name: 'SupabaseAuthService',
      );

      // Vérifier si l'email est confirmé
      final emailConfirmed = user.emailConfirmedAt != null;
      developer.log(
        'Email confirmed: $emailConfirmed, confirmedAt: ${user.emailConfirmedAt}',
        name: 'SupabaseAuthService',
      );

      if (!emailConfirmed) {
        developer.log(
          'WARNING: Email not confirmed. User might not be authenticated. '
          'Consider disabling email confirmation in Supabase Dashboard.',
          name: 'SupabaseAuthService',
        );
      }

      // Le trigger Supabase crée automatiquement l'entrée dans utilisateurs
      // Le trigger utilise SECURITY DEFINER donc il fonctionne même si l'utilisateur n'est pas authentifié
      // Attendre un peu pour que le trigger s'exécute
      await Future.delayed(const Duration(milliseconds: 800));

      // Récupérer le profil créé automatiquement par le trigger
      Map<String, dynamic>? profile;
      int retries = 0;
      const maxRetries = 5;
      
      while (profile == null && retries < maxRetries) {
        try {
          profile = await _client
              .from(_utilisateursTable)
              .select()
              .eq('user_id', user.id)
              .maybeSingle();
          
          if (profile == null) {
            retries++;
            developer.log(
              'Profile not found yet, retry $retries/$maxRetries',
              name: 'SupabaseAuthService',
            );
            await Future.delayed(const Duration(milliseconds: 500));
          } else {
            developer.log(
              'Profile found after $retries retries',
              name: 'SupabaseAuthService',
            );
          }
        } on PostgrestException catch (e, st) {
          developer.log(
            'Postgrest error fetching profile (attempt ${retries + 1}): ${e.message}',
            error: e,
            stackTrace: st,
            name: 'SupabaseAuthService',
          );
          retries++;
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e, st) {
          developer.log(
            'Unexpected error fetching profile (attempt ${retries + 1}): $e',
            error: e,
            stackTrace: st,
            name: 'SupabaseAuthService',
          );
          retries++;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (profile == null) {
        throw AuthFailure(
          'Le profil utilisateur n\'a pas pu être créé automatiquement après $maxRetries tentatives. '
          'Vérifiez que le trigger handle_new_user est bien configuré dans Supabase.',
        );
      }

      developer.log(
        'Profile found in utilisateurs (created by trigger): ${profile['id']}',
        name: 'SupabaseAuthService',
      );

      // Mettre à jour les informations supplémentaires (téléphone, prénom, nom si nécessaire)
      // Le trigger a déjà créé l'entrée avec les métadonnées, on met juste à jour le téléphone
      try {
        final updateResult = await _client
            .from(_utilisateursTable)
            .update({
              'telephone': phoneNumber,
              'prenom': firstName, // S'assurer que c'est à jour
              'nom': lastName, // S'assurer que c'est à jour
            })
            .eq('user_id', user.id)
            .select()
            .maybeSingle();
        
        if (updateResult != null) {
          developer.log(
            'Profile updated successfully with phone: $phoneNumber',
            name: 'SupabaseAuthService',
          );
        } else {
          developer.log(
            'Warning: Profile update returned null (profile might not exist)',
            name: 'SupabaseAuthService',
          );
        }
      } on PostgrestException catch (e, st) {
        developer.log(
          'Postgrest error updating profile: ${e.message}, code: ${e.code}',
          error: e,
          stackTrace: st,
          name: 'SupabaseAuthService',
        );
        // Ne pas échouer si la mise à jour échoue, le profil existe déjà
        // L'utilisateur pourra mettre à jour son téléphone plus tard
      } catch (e, st) {
        developer.log(
          'Unexpected error updating profile: $e',
          error: e,
          stackTrace: st,
          name: 'SupabaseAuthService',
        );
        // Ne pas échouer si la mise à jour échoue, le profil existe déjà
      }

      // Utiliser l'ID de la table utilisateurs (pas user_id) pour les références
      final utilisateurId = profile['id']?.toString();
      if (utilisateurId == null || utilisateurId.isEmpty) {
        throw const AuthFailure(
          'Impossible de récupérer l\'identifiant utilisateur créé.',
        );
      }

      developer.log(
        'Signup successful: utilisateurId=$utilisateurId, email=$email',
        name: 'SupabaseAuthService',
      );

      return Patient(
        id: utilisateurId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        birthDate: null,
        avatarUrl: null,
      );
    } on AuthException catch (error, stackTrace) {
      developer.log(
        'Auth error during signup: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      
      // Gestion spécifique de l'erreur 429 (Too Many Requests)
      final errorMessage = error.message.toLowerCase();
      if (errorMessage.contains('429') || 
          errorMessage.contains('too many requests') ||
          errorMessage.contains('rate limit')) {
        throw AuthFailure(
          'Trop de tentatives d\'inscription. Veuillez patienter quelques minutes avant de réessayer.',
          error,
        );
      }
      
      throw AuthFailure(
        _messageOrFallback(error.message, "Création de compte impossible."),
        error,
      );
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Postgrest error during signup: ${error.message}, code: ${error.code}, details: ${error.details}',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      
      // Détecter l'erreur de contrainte date_naissance
      final errorMessage = error.message.toLowerCase();
      final errorDetails = error.details?.toString().toLowerCase() ?? '';
      
      if (errorMessage.contains('date_naissance') || 
          errorMessage.contains('check_patient_has_birthdate') ||
          errorDetails.contains('date_naissance') ||
          errorDetails.contains('check_patient_has_birthdate')) {
        throw AuthFailure(
          'Erreur: La date de naissance est requise. Veuillez contacter le support ou modifier la contrainte SQL.',
          error,
        );
      }
      
      // Détecter les erreurs de permissions RLS
      if (errorMessage.contains('permission') || 
          errorMessage.contains('policy') ||
          errorMessage.contains('row-level security') ||
          error.code == '42501') {
        throw AuthFailure(
          'Erreur de permissions. Vérifiez que les politiques RLS permettent l\'insertion pour les utilisateurs authentifiés.',
          error,
        );
      }
      
      throw AuthFailure(
        'Erreur lors de la création du profil: ${error.message}. Code: ${error.code ?? "N/A"}',
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during signup: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      
      // Si c'est déjà une AuthFailure, la relancer
      if (error is AuthFailure) {
        rethrow;
      }
      
      throw AuthFailure(
        'Erreur inattendue lors de la création du compte: ${error.toString()}',
        error,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error, stackTrace) {
      developer.log(
        'Auth error during logout',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure(
        _messageOrFallback(error.message, 'Impossible de se déconnecter.'),
        error,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during logout',
        error: error,
        stackTrace: stackTrace,
        name: 'SupabaseAuthService',
      );
      throw AuthFailure('Erreur inattendue lors de la déconnexion.', error);
    }
  }

  Patient _mapProfileToPatient(
    Map<String, dynamic> data, {
    required String fallbackEmail,
  }) {
    final birthDateValue = data['date_naissance'] ?? data['birth_date'];
    DateTime? birthDate;
    if (birthDateValue is String && birthDateValue.isNotEmpty) {
      birthDate = DateTime.tryParse(birthDateValue);
    } else if (birthDateValue is DateTime) {
      birthDate = birthDateValue;
    }

    // Utiliser l'ID de la table utilisateurs (pas user_id) pour les références
    // Cet ID sera utilisé dans rendez_vous.patient_utilisateur_id par exemple
    final utilisateurId = data['id']?.toString();
    if (utilisateurId == null || utilisateurId.isEmpty) {
      throw const AuthFailure(
        'Impossible de récupérer l\'identifiant utilisateur.',
      );
    }

    return Patient(
      id: utilisateurId,
      firstName:
          data['prenom'] ?? data['first_name'] ?? data['firstName'] ?? '',
      lastName: data['nom'] ?? data['last_name'] ?? data['lastName'] ?? '',
      email: data['email'] ?? fallbackEmail,
      phoneNumber:
          data['telephone'] ?? data['phone_number'] ?? data['phone'] ?? '',
      birthDate: birthDate,
      avatarUrl: data['photo_profil'] ?? data['avatar_url'] as String?,
    );
  }

  String _messageOrFallback(String? message, String fallback) {
    if (message == null || message.trim().isEmpty) {
      return fallback;
    }
    return message;
  }
}
