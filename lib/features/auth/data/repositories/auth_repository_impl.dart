import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._organizationId);

  final ApiService _api;
  final String _organizationId;

  GoTrueClient get _auth => _api.client.auth;

  AuthUser? _map(User? u) => u == null
      ? null
      : AuthUser(
          id: u.id,
          email: u.email ?? '',
          fullName: u.userMetadata?['full_name'] as String?,
        );

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.onAuthStateChange.map((state) => _map(state.session?.user));

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    return _api.guard(() async {
      final res = await _auth.signInWithPassword(email: email.trim(), password: password);
      final user = _map(res.user);
      if (user == null) {
        throw const AppException(AppErrorType.auth, 'No se pudo iniciar sesión.');
      }
      return user;
    });
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) {
    return _api.guard(() async {
      final res = await _auth.signUp(
        email: email.trim(),
        password: password,
        // El trigger handle_new_user crea el perfil con estos datos (rol siempre 'client').
        data: {
          'organization_id': _organizationId,
          'full_name': fullName.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );
      return res.session != null ? SignUpResult.signedIn : SignUpResult.needsEmailConfirmation;
    });
  }

  @override
  Future<void> signOut() => _api.guard(() => _auth.signOut());
}
