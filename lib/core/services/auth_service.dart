import '../domain/patient.dart';
import '../domain/user_role.dart';

/// Contract for authentication operations.
abstract class AuthService {
  Future<Patient?> login({
    required String email,
    required String password,
    required UserRole role,
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


