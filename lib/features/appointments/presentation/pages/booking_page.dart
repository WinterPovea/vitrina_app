import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_page.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.specialistId, this.serviceId});

  final String specialistId;
  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Reservar turno',
      todo: [
        'Recibe specialistId=$specialistId y serviceId=$serviceId (query param opcional).',
        'Elegir servicio -> fecha (tira de 14 días) -> hora (AppointmentRepository.getAvailableSlots + TimeSlotChip).',
        'Confirmar con BookAppointmentUseCase (valida y llama al repositorio). Manejar conflicto 23P01 (horario tomado).',
        'Al terminar: volver a "Mis turnos" y refrescar.',
      ],
      reference: 'design/stitch_specialist_profile_booking.html (sección "Selecciona Fecha y Hora")',
    );
  }
}
