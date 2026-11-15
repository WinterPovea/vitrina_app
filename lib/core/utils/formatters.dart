/// Formateo sin dependencias externas (si se necesita i18n real, agregar `intl` en equipo).
class Formatters {
  const Formatters._();

  static String price(num value, {String symbol = r'$'}) => '$symbol${value.toStringAsFixed(2)}';

  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  static String time(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  static const _days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String weekdayShort(DateTime d) => _days[d.weekday - 1];
  static String monthName(DateTime d) => _months[d.month - 1];

  static String dateLong(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day} de ${monthName(l)}, ${time(l)}';
  }

  /// Fecha `yyyy-MM-dd` para el RPC (p_date).
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
