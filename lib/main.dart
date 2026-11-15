import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const ConfigErrorApp());
    return;
  }

  await SupabaseBootstrap.init();
  runApp(const VitrinaApp());
}
