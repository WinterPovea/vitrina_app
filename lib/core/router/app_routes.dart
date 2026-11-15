/// Rutas centralizadas: nunca escribir strings de ruta sueltos en las pantallas.
class AppRoutes {
  const AppRoutes._();

  // Públicas
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  // Protegidas (requieren sesión)
  static const home = '/';
  static const specialists = '/specialists';
  static const appointments = '/appointments';
  static const profile = '/profile';

  /// /specialists/:id
  static String specialistDetail(String id) => '/specialists/$id';

  /// Query param para forzar recarga de "Mis turnos" tras reservar o cancelar.
  static const refreshParam = 'refresh';

  /// `/appointments?refresh=<marca de tiempo>`
  static String appointmentsRefreshed() =>
    '$appointments?$refreshParam=${DateTime.now().millisecondsSinceEpoch}';

  /// /specialists/:id/book?serviceId=...
  static String book(String specialistId, {String? serviceId}) =>
      '/specialists/$specialistId/book${serviceId == null ? '' : '?serviceId=$serviceId'}';

  static bool isPublic(String location) => location == signIn || location == signUp;
}
