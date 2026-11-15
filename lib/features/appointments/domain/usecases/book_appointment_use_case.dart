import '../../../../core/error/app_exception.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Caso de uso con reglas de negocio reutilizables (el trabajo autónomo pide usar
/// casos de uso solo cuando hay reglas/validaciones, como aquí).
class BookAppointmentUseCase {
  const BookAppointmentUseCase(this._repository);

  final AppointmentRepository _repository;

  static const int maxNotesLength = 300;

  Future<Appointment> call({
    required String specialistId,
    required String serviceId,
    required TimeSlot? slot,
    String? notes,
    DateTime? now,
  }) {
    if (slot == null) {
      throw const AppException(AppErrorType.validation, 'Elige un horario para tu turno.');
    }
    if (!slot.start.isAfter(now ?? DateTime.now())) {
      throw const AppException(AppErrorType.validation, 'Ese horario ya pasó. Elige otro.');
    }
    final cleanNotes = notes?.trim();
    if (cleanNotes != null && cleanNotes.length > maxNotesLength) {
      throw const AppException(
        AppErrorType.validation,
        'Las notas no pueden superar $maxNotesLength caracteres.',
      );
    }
    return _repository.create(
      specialistId: specialistId,
      serviceId: serviceId,
      startAt: slot.start,
      notes: (cleanNotes == null || cleanNotes.isEmpty) ? null : cleanNotes,
    );
  }
}
