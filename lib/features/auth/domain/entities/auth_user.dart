/// Usuario autenticado (independiente del SDK remoto).
class AuthUser {
  const AuthUser({required this.id, required this.email, this.fullName});

  final String id;
  final String email;
  final String? fullName;
}
