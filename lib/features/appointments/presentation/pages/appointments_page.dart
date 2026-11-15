import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Mis turnos',
      todo: [
        'Lista de AppointmentRepository.getMyAppointments() con los 4 estados (AsyncStateView).',
        'Mostrar estado (pending/confirmed/completed/cancelled), servicio, especialista y hora.',
        'Acción "Cancelar" (AppointmentRepository.cancel) y "Dejar reseña" si está completed.',
      ],
    );
  }
}
