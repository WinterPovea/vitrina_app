import 'package:flutter/material.dart';

/// Campo de formulario con etiqueta flotante (la hereda del tema) y opción de mostrar/ocultar contraseña.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _hidden,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
                icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}
