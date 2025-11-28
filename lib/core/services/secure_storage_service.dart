/// Abstraction over secure key-value storage (e.g. flutter_secure_storage).
abstract class SecureStorageService {
  Future<void> writeToken(String token);
  Future<String?> readToken();
  Future<void> deleteToken();

  Future<void> writeBiometryEnabled(bool enabled);
  Future<bool> readBiometryEnabled();
}


