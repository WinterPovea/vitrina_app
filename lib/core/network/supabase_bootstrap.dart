import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import 'secure_session_storage.dart';

/// Inicializa Supabase con sesión en almacenamiento seguro.
/// La sesión se restaura sola al abrir la app (token + refresh).
class SupabaseBootstrap {
  const SupabaseBootstrap._();

  static Future<void> init() {
    return Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        pkceAsyncStorage: SecurePkceStorage(),
      ),
    );
  }
}
