import 'package:flutter/material.dart';

/// Identidad visual de la organización. Para una organización nueva, este es
/// (junto con ORG_ID y el logo) el único archivo de marca que se toca.
/// Valores tomados de design/DESIGN.md (sección Colors, versión en prosa).
class Brand {
  const Brand._();

  static const String appName = 'Vitrina';

  static const Color primary = Color(0xFF6D1A36); // Deep Burgundy
  static const Color secondary = Color(0xFFE8C8C4); // Powder Rose
  static const Color tertiary = Color(0xFFC9A86A); // Champagne Silk (estrellas, acentos)
  static const Color canvas = Color(0xFFFAF6F3); // Fondo base
  static const Color foreground = Color(0xFF261E1D); // Texto principal
  static const muted = Color(0xFF655A57); // Texto secundario
  static const Color success = Color(0xFF2E5D4B); // WhatsApp / confirmado
  static const Color successSoft = Color(0xFFF0F6F3);
  static const Color inputFill = Color(0xFFF5EEEB);
  static const Color error = Color(0xFFBA1A1A);
  static const Color disabled = Color(0xFFD8CFCB);
}
