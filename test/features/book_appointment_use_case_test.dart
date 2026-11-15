import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_app/core/error/app_exception.dart';
import 'package:vitrina_app/features/appointments/domain/entities/appointment.dart';
import 'package:vitrina_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:vitrina_app/features/appointments/domain/usecases/book_appointment_use_case.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockAppointmentRepository repo;
  late BookAppointmentUseCase useCase;
  final now = DateTime(2026, 1, 1, 10);
  final future = TimeSlot(start: DateTime(2026, 1, 2, 10), end: DateTime(2026, 1, 2, 11));

  setUp(() {
    repo = MockAppointmentRepository();
    useCase = BookAppointmentUseCase(repo);
  });

  test('rechaza si no hay horario elegido', () {
    expect(
      () => useCase(specialistId: 's', serviceId: 'v', slot: null, now: now),
      throwsA(isA<AppException>()),
    );
    verifyZeroInteractions(repo);
  });

  test('rechaza horarios pasados', () {
    final past = TimeSlot(start: DateTime(2025, 12, 31), end: DateTime(2025, 12, 31, 1));
    expect(
      () => useCase(specialistId: 's', serviceId: 'v', slot: past, now: now),
      throwsA(isA<AppException>()),
    );
  });

  test('delega en el repositorio cuando todo es válido', () async {
    final appt = Appointment(
      id: 'a', specialistId: 's', serviceId: 'v',
      startAt: future.start, endAt: future.end, status: AppointmentStatus.pending,
    );
    when(() => repo.create(
          specialistId: any(named: 'specialistId'),
          serviceId: any(named: 'serviceId'),
          startAt: any(named: 'startAt'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => appt);

    final result = await useCase(specialistId: 's', serviceId: 'v', slot: future, notes: '  ', now: now);
    expect(result.id, 'a');
    verify(() => repo.create(specialistId: 's', serviceId: 'v', startAt: future.start, notes: null)).called(1);
  });
}
