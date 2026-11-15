import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/avatar_image.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Center(child: AvatarImage(name: user?.fullName ?? user?.email ?? '?', radius: 44)),
              const SizedBox(height: AppSpacing.md),
              Text(user?.fullName ?? 'Sin nombre', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(user?.email ?? '', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Cerrar sesión',
                icon: Icons.logout,
                isLoading: auth.isSubmitting,
                onPressed: auth.signOut, // el router redirige a sign-in por sí solo
              ),
            ],
          ),
        ),
      ),
    );
  }
}
