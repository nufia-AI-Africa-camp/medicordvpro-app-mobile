import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/patient.dart';
import '../../core/domain/user_role.dart';
import '../../core/services/auth_service.dart';

/// Simple authentication status used by routing logic.
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.patient,
    this.role,
  });

  final AuthStatus status;
  final Patient? patient;
  final UserRole? role;

  AuthState copyWith({
    AuthStatus? status,
    Patient? patient,
    UserRole? role,
  }) {
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
    final patient =
        await _authService.login(email: email, password: password, role: role);
    if (patient == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    } else {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        patient: patient,
        role: role,
      );
    }
    _authStreamController.add(state);
  }

  Future<void> logout() async {
    await _authService.logout();
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
  // In production, replace with a real implementation.
  return MockAuthService();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthController(service);
});


