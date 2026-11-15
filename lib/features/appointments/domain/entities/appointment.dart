enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  const Appointment({
    required this.id,
    required this.specialistId,
    required this.serviceId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.price,
    this.notes,
    this.specialistName,
    this.serviceName,
  });

  final String id;
  final String specialistId;
  final String serviceId;
  final DateTime startAt;
  final DateTime endAt;
  final AppointmentStatus status;
  final double? price;
  final String? notes;

  /// Nombres traídos con la consulta para listar sin pedir más datos.
  final String? specialistName;
  final String? serviceName;

  bool get isActive =>
      status == AppointmentStatus.pending || status == AppointmentStatus.confirmed;
}

/// Hueco horario disponible para reservar.
class TimeSlot {
  const TimeSlot({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
