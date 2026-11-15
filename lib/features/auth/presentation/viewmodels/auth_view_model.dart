import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Estado de sesión global. También es el `refreshListenable` de go_router:
/// cuando cambia la sesión, el router reevalúa las rutas protegidas.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _user = _repository.currentUser;
    _sub = _repository.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthUser?> _sub;

  AuthUser? _user;
  bool _submitting = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// `true` si el inicio de sesión fue exitoso (el router redirige solo).
  Future<bool> signIn(String email, String password) async {
    return await _run(() => _repository.signIn(email: email, password: password)) != null;
  }

  /// `null` si falló (ver [errorMessage]).
  Future<SignUpResult?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) {
    return _run(() => _repository.signUp(
          email: email,
          password: password,
          fullName: fullName,
          phone: phone,
        ));
  }

  Future<void> signOut() async {
    await _run(() => _repository.signOut());
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      _error = AppException.from(e).message;
      return null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
