/// Validadores de formularios (devuelven `null` si es válido, o el mensaje de error).
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, field: 'El correo');
    if (empty != null) return empty;
    return _email.hasMatch(value!.trim()) ? null : 'Ingresa un correo válido';
  }

  static String? password(String? value) {
    final empty = required(value, field: 'La contraseña');
    if (empty != null) return empty;
    return value!.length >= 6 ? null : 'Mínimo 6 caracteres';
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opcional
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15 ? null : 'Teléfono no válido';
  }
}
