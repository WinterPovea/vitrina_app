import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  AppointmentModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] as String,
          specialistId: json['specialist_id'] as String,
          serviceId: json['service_id'] as String,
          startAt: DateTime.parse(json['start_at'] as String),
          endAt: DateTime.parse(json['end_at'] as String),
          status: AppointmentStatus.values.byName(json['status'] as String),
          price: (json['price_at_booking'] as num?)?.toDouble(),
          notes: json['notes'] as String?,
          specialistName: (json['specialists'] as Map<String, dynamic>?)?['display_name'] as String?,
          serviceName: (json['services'] as Map<String, dynamic>?)?['name'] as String?,
        );
}
