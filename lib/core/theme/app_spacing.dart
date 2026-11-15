/// Medidas del diseño (design/DESIGN.md → spacing / rounded).
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 36;

  /// Margen lateral de pantalla (1.25rem).
  static const double screen = 20;
  static const double radiusCard = 16;
  static const double radiusInput = 12;
  static const double radiusSheet = 24;

  /// Tamaño mínimo táctil (accesibilidad, ≥ 48dp).
  static const double minTap = 48;

  /// Ancho máximo de contenido: en tablet/horizontal se centra y no se estira.
  static const double maxContentWidth = 640;
}
