import 'package:url_launcher/url_launcher.dart';

/// Contacto directo. Devuelve `false` si no se pudo abrir (la vista muestra un SnackBar).
class Launchers {
  const Launchers._();

  /// [phone] en formato internacional sin '+', ej: 593999999999
  static Future<bool> whatsapp(String phone, {String? message}) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.https('wa.me', '/$digits', message == null ? null : {'text': message});
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));
}
