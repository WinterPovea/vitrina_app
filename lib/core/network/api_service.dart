import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/app_exception.dart';

/// "ApiService" del proyecto: punto único de acceso al servicio remoto (Supabase).
///
/// - Solo las implementaciones de repositorio (`features/*/data`) lo usan.
/// - Los ViewModels y las vistas NUNCA lo importan.
/// - Convierte toda falla técnica en [AppException] (red, auth, servidor...).
class ApiService {
  ApiService(this.client);

  final SupabaseClient client;

  /// Id del usuario autenticado o `null`.
  String? get currentUserId => client.auth.currentUser?.id;

  /// Ejecuta una llamada remota y normaliza los errores.
  Future<T> guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
