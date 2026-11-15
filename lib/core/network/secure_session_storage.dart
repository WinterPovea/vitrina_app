import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guarda la sesión (JWT + refresh token) en el almacén seguro del sistema
/// (Android Keystore) en lugar de shared_preferences, como exige el trabajo autónomo.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage();

  static const _key = 'supabase_session';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _key);

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}

/// Almacén para el flujo PKCE (por defecto usaría shared_preferences).
class SecurePkceStorage extends GotrueAsyncStorage {
  SecurePkceStorage();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> getItem({required String key}) => _storage.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key: key);
}
