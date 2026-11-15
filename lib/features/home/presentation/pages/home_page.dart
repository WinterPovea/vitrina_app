import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Inicio',
      todo: [
        'Cabecera con nombre/tagline de la organización (OrganizationRepository.getCurrent).',
        'Carrusel de categorías (ServiceRepository.getCategories).',
        'Sección "Servicios estrella" y "Especialistas destacados" (ordenar por avg_rating).',
        'Usar AsyncStateView + un HomeViewModel con provider.',
      ],
      reference: 'design/stitch_home.html · docs/STITCH_ANALYSIS.md',
    );
  }
}
