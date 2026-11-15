import '../entities/appointment.dart';

abstract class AppointmentRepository {
  /// Huecos libres de un especialista para un servicio en [date] (calculados en el servidor).
  Future<List<TimeSlot>> getAvailableSlots({
    required String specialistId,
    required String serviceId,
    required DateTime date,
  });

  /// REGISTRA la transacción en el servicio remoto.
  Future<Appointment> create({
    required String specialistId,
    required String serviceId,
    required DateTime startAt,
    String? notes,
  });

  /// CONSULTA los turnos del usuario autenticado (más recientes primero).
  Future<List<Appointment>> getMyAppointments();

  Future<void> cancel(String appointmentId);
}
