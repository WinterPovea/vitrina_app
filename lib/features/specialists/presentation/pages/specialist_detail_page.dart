import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_page.dart';

class SpecialistDetailPage extends StatelessWidget {
  const SpecialistDetailPage({super.key, required this.specialistId});

  final String specialistId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Perfil del especialista',
      todo: [
        'Recibe specialistId=$specialistId (parámetro de ruta). Crear SpecialistDetailViewModel.',
        'Cabecera: foto, nombre, título, RatingBadge, años de experiencia, bio.',
        'Servicios del especialista (ServiceRepository.getServicesBySpecialist) con ServiceCard.',
        'Reseñas (ReviewRepository.getBySpecialist).',
        'Botones de contacto: Launchers.whatsapp / Launchers.call.',
        'CTA "Reservar" -> context.push(AppRoutes.book(id, serviceId: ...)).',
      ],
      reference: 'design/stitch_specialist_profile_booking.html',
    );
  }
}
