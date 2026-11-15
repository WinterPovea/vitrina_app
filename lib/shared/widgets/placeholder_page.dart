import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'responsive_center.dart';

/// Pantalla pendiente de implementar. Cuando alguien la termine, borra el uso de este widget.
/// Muestra qué hay que construir y dónde mirar (guía rápida para el equipo).
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.todo,
    this.reference,
  });

  final String title;
  final List<String> todo;

  /// Archivo de design/ o docs/ donde está la referencia visual/técnica.
  final String? reference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Icon(Icons.construction_outlined, size: 40, color: theme.colorScheme.tertiary),
              const SizedBox(height: AppSpacing.md),
              Text('Pantalla pendiente', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final item in todo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              if (reference != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Referencia: $reference',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
