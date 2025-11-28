import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/domain/patient.dart';
import '../../core/domain/user_role.dart';
import '../../core/services/auth_service.dart';

/// Simple authentication status used by routing logic.
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState({required this.status, this.patient, this.role});

  final AuthStatus status;
  final Patient? patient;
  final UserRole? role;

  AuthState copyWith({AuthStatus? status, Patient? patient, UserRole? role}) {
    return AuthState(
      status: status ?? this.status,
      patient: patient ?? this.patient,
      role: role ?? this.role,
    );
  }

  static const initial = AuthState(status: AuthStatus.unknown);
}

/// Controller in charge of login/logout and exposing auth changes to the router.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authService) : super(AuthState.initial);

  final AuthService _authService;

  final _authStreamController = StreamController<AuthState>.broadcast();

  Stream<AuthState> get authStream => _authStreamController.stream;

  Future<void> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final patient = await _authService.login(
        email: email,
        password: password,
        role: role,
      );
      if (patient == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          patient: patient,
          role: role,
        );
      }
    } on AuthFailure catch (error, stackTrace) {
      developer.log(
        'AuthFailure caught in login',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error in login',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      throw AuthFailure(
        'Impossible de se connecter. Veuillez réessayer.',
        error,
      );
    }
    _authStreamController.add(state);
  }

  /// Connexion avec détection automatique du rôle
  Future<UserRole?> loginAuto({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.loginAuto(
        email: email,
        password: password,
      );
      if (result == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return null;
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          patient: result.patient,
          role: result.role,
        );
        return result.role;
      }
    } on AuthFailure catch (error, stackTrace) {
      developer.log(
        'AuthFailure caught in loginAuto',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error in loginAuto',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      throw AuthFailure(
        'Impossible de se connecter. Veuillez réessayer.',
        error,
      );
    } finally {
      _authStreamController.add(state);
    }
  }

  /// Inscription - crée UNIQUEMENT un compte patient
  /// Les médecins ne peuvent pas s'inscrire via cette méthode.
  /// Ils doivent être créés par un administrateur.
  Future<Patient> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final patient = await _authService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      
      // Après inscription réussie, l'utilisateur est automatiquement connecté
      state = state.copyWith(
        status: AuthStatus.authenticated,
        patient: patient,
        role: UserRole.patient, // Toujours patient lors de l'inscription
      );
      _authStreamController.add(state);
      return patient;
    } on AuthFailure catch (error, stackTrace) {
      developer.log(
        'AuthFailure caught in signup',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error in signup: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      
      // Si c'est déjà une AuthFailure, la relancer avec son message
      if (error is AuthFailure) {
        rethrow;
      }
      
      throw AuthFailure(
        'Impossible de créer le compte: ${error.toString()}',
        error,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on AuthFailure catch (error, stackTrace) {
      developer.log(
        'AuthFailure caught in logout',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error in logout',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthController',
      );
      state = const AuthState(status: AuthStatus.unauthenticated);
      _authStreamController.add(state);
      throw AuthFailure('Erreur lors de la déconnexion.', error);
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
    _authStreamController.add(state);
  }

  @override
  void dispose() {
    _authStreamController.close();
    super.dispose();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final client = Supabase.instance.client;
  return SupabaseAuthService(client);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final service = ref.watch(authServiceProvider);
    return AuthController(service);
  },
);
