/// Configuración inyectada en compilación con `--dart-define-from-file=env/dev.json`.
/// Nunca se escriben claves en el código ni se suben al repositorio.
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Organización a la que pertenece esta app (ver docs/WHITE_LABEL.md).
  static const String organizationId = String.fromEnvironment('ORG_ID');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && organizationId.isNotEmpty;
}
