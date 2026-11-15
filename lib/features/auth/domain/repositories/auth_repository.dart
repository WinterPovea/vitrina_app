import '../entities/auth_user.dart';

enum SignUpResult { signedIn, needsEmailConfirmation }

/// Contrato de autenticación. La implementación (Supabase) vive en `data/`.
abstract class AuthRepository {
  /// Usuario con sesión restaurada o `null`.
  AuthUser? get currentUser;

  /// Emite cada vez que inicia o termina la sesión.
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<void> signOut();
}
