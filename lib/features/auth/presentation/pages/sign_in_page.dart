import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/brand.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../viewmodels/auth_view_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // Si es exitoso, el router redirige solo (refreshListenable). Si falla, se ve vm.errorMessage.
    await context.read<AuthViewModel>().signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: ResponsiveCenter(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Text(Brand.appName, style: theme.textTheme.displayLarge, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Inicia sesión para continuar',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Correo electrónico',
                      controller: _email,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Contraseña',
                      controller: _password,
                      validator: Validators.password,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      autofillHints: const [AutofillHints.password],
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Semantics(
                        liveRegion: true,
                        child: Text(vm.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(label: 'Iniciar sesión', isLoading: vm.isSubmitting, onPressed: _submit),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        vm.clearError();
                        context.go(AppRoutes.signUp);
                      },
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
