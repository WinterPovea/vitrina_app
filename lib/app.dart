import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/config/brand.dart';
import 'core/di/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/viewmodels/auth_view_model.dart';

class VitrinaApp extends StatelessWidget {
  const VitrinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: buildAppProviders(), child: const _AppView());
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(context.read<AuthViewModel>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Brand.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}

/// Se muestra si se ejecutó la app sin `--dart-define-from-file=env/dev.json`.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Falta la configuración.\n\nEjecuta:\nflutter run --dart-define-from-file=env/dev.json\n\n'
                '(copia env/dev.example.json a env/dev.json y completa SUPABASE_URL, SUPABASE_ANON_KEY y ORG_ID).',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
