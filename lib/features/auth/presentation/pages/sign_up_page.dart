import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/auth_view_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final vm = context.read<AuthViewModel>();
    final result = await vm.signUp(
      email: _email.text,
      password: _password.text,
      fullName: _name.text,
      phone: _phone.text,
    );
    if (!mounted) return;
    // signedIn: el router redirige solo. needsEmailConfirmation: avisar y volver a iniciar sesión.
    if (result == SignUpResult.needsEmailConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Confirma tu correo e inicia sesión.')),
      );
      context.go(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            vm.clearError();
            context.go(AppRoutes.signIn);
          },
        ),
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: ResponsiveCenter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Nombre completo',
                    controller: _name,
                    validator: (v) => Validators.required(v, field: 'El nombre'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Correo electrónico',
                    controller: _email,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Teléfono (opcional)',
                    controller: _phone,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Contraseña',
                    controller: _password,
                    validator: Validators.password,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Confirmar contraseña',
                    controller: _confirm,
                    validator: (v) => v == _password.text ? null : 'Las contraseñas no coinciden',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
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
                  AppButton(label: 'Crear cuenta', isLoading: vm.isSubmitting, onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
