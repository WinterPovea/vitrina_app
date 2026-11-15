import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppErrorType { network, auth, validation, notFound, conflict, server, unknown }

/// Único tipo de error que cruza hacia ViewModels y vistas.
/// El SDK remoto jamás debe filtrarse fuera de la capa `data` / `core/network`.
class AppException implements Exception {
  const AppException(this.type, this.message);

  final AppErrorType type;
  final String message;

  /// ¿Tiene sentido mostrar el botón "Reintentar"?
  bool get isRetryable => type == AppErrorType.network || type == AppErrorType.server;

  @override
  String toString() => 'AppException($type): $message';

  /// Traduce cualquier excepción técnica a un mensaje entendible por el usuario.
  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is SocketException || error is http.ClientException || error is TimeoutException) {
      return const AppException(
        AppErrorType.network,
        'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
      );
    }
    if (error is AuthException) {
      return AppException(AppErrorType.auth, _authMessage(error));
    }
    if (error is PostgrestException) {
      switch (error.code) {
        case '23P01': // exclusion_violation (turno solapado)
          return const AppException(AppErrorType.conflict, 'Ese horario ya fue tomado. Elige otro.');
        case '23505': // unique_violation
          return const AppException(AppErrorType.conflict, 'Ese registro ya existe.');
        case '42501': // permisos / RLS
          return const AppException(AppErrorType.auth, 'No tienes permiso para realizar esta acción.');
        case 'P0001': // RAISE EXCEPTION de nuestros triggers: el mensaje ya es legible
          return AppException(AppErrorType.validation, error.message);
        case 'PGRST116':
          return const AppException(AppErrorType.notFound, 'No se encontró el elemento solicitado.');
      }
      return const AppException(AppErrorType.server, 'El servicio tuvo un problema. Inténtalo más tarde.');
    }
    return const AppException(AppErrorType.unknown, 'Ocurrió un error inesperado.');
  }

  static String _authMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login')) return 'Correo o contraseña incorrectos.';
    if (msg.contains('already registered') || msg.contains('already been registered')) {
      return 'Ese correo ya tiene una cuenta.';
    }
    if (msg.contains('email not confirmed')) return 'Confirma tu correo antes de iniciar sesión.';
    if (msg.contains('password')) return 'La contraseña no cumple los requisitos (mínimo 6 caracteres).';
    return 'No se pudo completar la autenticación.';
  }
}
