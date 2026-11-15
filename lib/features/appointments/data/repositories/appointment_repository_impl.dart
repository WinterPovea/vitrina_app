import '../../../../core/network/api_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._api);

  final ApiService _api;

  // Trae también el nombre del especialista y del servicio (relaciones).
  static const _select = '*, specialists(display_name), services(name)';

  @override
  Future<List<TimeSlot>> getAvailableSlots({
    required String specialistId,
    required String serviceId,
    required DateTime date,
  }) =>
      _api.guard(() async {
        final res = await _api.client.rpc('get_available_slots', params: {
          'p_specialist_id': specialistId,
          'p_service_id': serviceId,
          'p_date': Formatters.isoDate(date),
        });
        return (res as List)
            .map<TimeSlot>((r) => TimeSlot(
                  start: DateTime.parse((r as Map<String, dynamic>)['slot_start'] as String),
                  end: DateTime.parse(r['slot_end'] as String),
                ))
            .toList();
      });

  @override
  Future<Appointment> create({
    required String specialistId,
    required String serviceId,
    required DateTime startAt,
    String? notes,
  }) =>
      _api.guard(() async {
        // client_id, organization_id, end_at, precio y estado los fija la base de datos.
        final row = await _api.client
            .from('appointments')
            .insert({
              'specialist_id': specialistId,
              'service_id': serviceId,
              'start_at': startAt.toUtc().toIso8601String(),
              if (notes != null) 'notes': notes,
            })
            .select(_select)
            .single();
        return AppointmentModel.fromJson(row);
      });

  @override
  Future<List<Appointment>> getMyAppointments() => _api.guard(() async {
        final rows = await _api.client
            .from('appointments')
            .select(_select)
            .eq('client_id', _api.currentUserId ?? '')
            .order('start_at', ascending: false);
        return rows.map<Appointment>(AppointmentModel.fromJson).toList();
      });

  @override
  Future<void> cancel(String appointmentId) => _api.guard(() async {
        await _api.client
            .from('appointments')
            .update({'status': 'cancelled'}).eq('id', appointmentId);
      });
}
